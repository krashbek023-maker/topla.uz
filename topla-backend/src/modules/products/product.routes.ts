import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../config/database.js';
import { authMiddleware, requireRole, optionalAuth } from '../../middleware/auth.js';
import { AppError, NotFoundError } from '../../middleware/error.js';
import { validateProduct, calculateQualityScore } from '../../services/product-validation.service.js';
import { indexProduct, removeProductFromIndex, searchProducts } from '../../services/search.service.js';

// ============================================
// Validation Schemas
// ============================================

const createProductSchema = z.object({
  name: z.string().min(2).max(200),
  nameUz: z.string().min(3).max(200).optional(),
  nameRu: z.string().min(3).max(200).optional(),
  description: z.string().optional(),
  descriptionUz: z.string().optional(),
  descriptionRu: z.string().optional(),
  categoryId: z.string().uuid().optional(),
  subcategoryId: z.string().uuid().optional(),
  brandId: z.string().uuid().optional(),
  colorId: z.string().uuid().optional(),
  price: z.number().positive(),
  originalPrice: z.number().positive().optional(),
  discountPercent: z.number().min(0).max(100).optional(),
  images: z.array(z.string()).default([]),
  stock: z.number().int().min(0).default(0),
  unit: z.string().default('dona'),
  minOrder: z.number().int().min(1).default(1),
  sku: z.string().optional(),
  weight: z.number().optional(),
});

const updateProductSchema = createProductSchema.partial();

const productFilterSchema = z.object({
  categoryId: z.string().uuid().optional(),
  subcategoryId: z.string().uuid().optional(),
  brandId: z.string().uuid().optional(),
  colorId: z.string().uuid().optional(),
  shopId: z.string().uuid().optional(),
  minPrice: z.coerce.number().optional(),
  maxPrice: z.coerce.number().optional(),
  search: z.string().optional(),
  isFlashSale: z.coerce.boolean().optional(),
  hasDiscount: z.coerce.boolean().optional(),
  sortBy: z.enum(['price_asc', 'price_desc', 'newest', 'popular', 'rating']).optional(),
  page: z.coerce.number().default(1),
  limit: z.coerce.number().default(20),
});

// ============================================
// Routes
// ============================================

export async function productRoutes(app: FastifyInstance): Promise<void> {

  // ============================================
  // PUBLIC: Mahsulotlar
  // ============================================

  /**
   * GET /products
   * Mahsulotlar ro'yxati (filterlash, qidirish, saralash)
   */
  app.get('/products', { preHandler: optionalAuth }, async (request, reply) => {
    const filters = productFilterSchema.parse(request.query);

    const where: any = { isActive: true, status: 'active' };

    if (filters.categoryId) where.categoryId = filters.categoryId;
    if (filters.subcategoryId) where.subcategoryId = filters.subcategoryId;
    if (filters.brandId) where.brandId = filters.brandId;
    if (filters.colorId) where.colorId = filters.colorId;
    if (filters.shopId) where.shopId = filters.shopId;

    if (filters.minPrice !== undefined || filters.maxPrice !== undefined) {
      where.price = {};
      if (filters.minPrice) where.price.gte = filters.minPrice;
      if (filters.maxPrice) where.price.lte = filters.maxPrice;
    }

    // Flash sale filter
    if (filters.isFlashSale) {
      where.isFlashSale = true;
      where.flashSaleEnd = { gte: new Date() };
    }

    // Discount filter
    if (filters.hasDiscount) {
      where.discountPercent = { gt: 0 };
    }

    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { description: { contains: filters.search, mode: 'insensitive' } },
      ];
    }

    // Saralash
    let orderBy: any = { createdAt: 'desc' };
    switch (filters.sortBy) {
      case 'price_asc': orderBy = { price: 'asc' }; break;
      case 'price_desc': orderBy = { price: 'desc' }; break;
      case 'newest': orderBy = { createdAt: 'desc' }; break;
      case 'popular': orderBy = { salesCount: 'desc' }; break;
      case 'rating': orderBy = { rating: 'desc' }; break;
    }

    const skip = (filters.page - 1) * filters.limit;

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        include: {
          shop: { select: { id: true, name: true, logoUrl: true, rating: true } },
          category: { select: { id: true, nameUz: true, nameRu: true } },
          subcategory: { select: { id: true, nameUz: true, nameRu: true } },
          brand: { select: { id: true, name: true } },
          color: { select: { id: true, nameUz: true, nameRu: true, hexCode: true } },
        },
        orderBy,
        skip,
        take: filters.limit,
      }),
      prisma.product.count({ where }),
    ]);

    return reply.send({
      success: true,
      data: {
        products,
        pagination: {
          page: filters.page,
          limit: filters.limit,
          total,
          totalPages: Math.ceil(total / filters.limit),
        },
      },
    });
  });

  /**
   * GET /products/featured
   * Tavsiya etilgan mahsulotlar
   * NOTE: Bu route /products/:id dan OLDIN bo'lishi kerak!
   */
  app.get('/products/featured', async (request, reply) => {
    const { limit = '20' } = request.query as { limit?: string };

    const products = await prisma.product.findMany({
      where: { isActive: true, isFeatured: true },
      include: {
        shop: { select: { id: true, name: true, logoUrl: true } },
      },
      orderBy: { salesCount: 'desc' },
      take: parseInt(limit),
    });

    return reply.send({
      success: true,
      data: {
        products,
        pagination: { page: 1, limit: parseInt(limit), total: products.length, totalPages: 1 },
      },
    });
  });

  /**
   * GET /products/:id
   * Mahsulot tafsilotlari
   */
  app.get('/products/:id', { preHandler: optionalAuth }, async (request, reply) => {
    const { id } = request.params as { id: string };

    const product = await prisma.product.findUnique({
      where: { id },
      include: {
        shop: {
          select: { id: true, name: true, logoUrl: true, rating: true, reviewCount: true, phone: true },
        },
        category: true,
        subcategory: true,
        brand: true,
        color: true,
      },
    });

    if (!product) throw new NotFoundError('Mahsulot');

    // Ko'rish sonini oshirish (faqat autentifikatsiya qilingan foydalanuvchilar uchun, deduplicated)
    if (request.user) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const alreadyViewed = await prisma.productView.findFirst({
        where: {
          productId: id,
          userId: request.user.userId,
          createdAt: { gte: today },
        },
      });

      if (!alreadyViewed) {
        await prisma.product.update({
          where: { id },
          data: { viewCount: { increment: 1 } },
        });
        await prisma.productView.create({
          data: { productId: id, userId: request.user.userId },
        });
      }
    } else {
      // Anonim foydalanuvchilar uchun oddiy increment
      await prisma.product.update({
        where: { id },
        data: { viewCount: { increment: 1 } },
      });
    }

    // Sevimlilarmi tekshirish
    let isFavorite = false;
    if (request.user) {
      const fav = await prisma.favorite.findUnique({
        where: {
          userId_productId: {
            userId: request.user.userId,
            productId: id,
          },
        },
      });
      isFavorite = !!fav;
    }

    return reply.send({
      success: true,
      data: { ...product, isFavorite },
    });
  });

  // ============================================
  // CATEGORIES
  // ============================================

  /**
   * GET /categories
   */
  app.get('/categories', async (request, reply) => {
    const categories = await prisma.category.findMany({
      where: { isActive: true },
      include: {
        subcategories: {
          where: { isActive: true },
          orderBy: { sortOrder: 'asc' },
        },
        _count: { select: { products: true } },
      },
      orderBy: { sortOrder: 'asc' },
    });

    return reply.send({ success: true, data: categories });
  });

  /**
   * GET /brands
   */
  app.get('/brands', async (request, reply) => {
    const { categoryId } = request.query as { categoryId?: string };
    const where: any = {};
    if (categoryId) {
      where.products = { some: { categoryId } };
    }
    const brands = await prisma.brand.findMany({
      where,
      include: { _count: { select: { products: true } } },
      orderBy: { name: 'asc' },
    });
    return reply.send({ success: true, data: brands });
  });

  /**
   * GET /colors
   */
  app.get('/colors', async (request, reply) => {
    const colors = await prisma.color.findMany({ orderBy: { nameUz: 'asc' } });
    return reply.send({ success: true, data: colors });
  });

  // ============================================
  // CART (Savat)
  // ============================================

  /**
   * GET /cart
   */
  app.get('/cart', { preHandler: authMiddleware }, async (request, reply) => {
    const cartItems = await prisma.cartItem.findMany({
      where: { userId: request.user!.userId },
      include: {
        product: {
          include: {
            shop: { select: { id: true, name: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const total = cartItems.reduce(
      (sum, item) => sum + Number(item.product.price) * item.quantity,
      0,
    );

    return reply.send({
      success: true,
      data: { items: cartItems, total, itemCount: cartItems.length },
    });
  });

  /**
   * POST /cart
   * Savatga qo'shish
   */
  app.post('/cart', { preHandler: authMiddleware }, async (request, reply) => {
    const { productId, quantity = 1 } = request.body as { productId: string; quantity?: number };

    const product = await prisma.product.findUnique({ where: { id: productId } });
    if (!product || !product.isActive) throw new NotFoundError('Mahsulot');
    if (product.stock < quantity) throw new AppError('Yetarli mahsulot yo\'q');

    const cartItem = await prisma.cartItem.upsert({
      where: {
        userId_productId: {
          userId: request.user!.userId,
          productId,
        },
      },
      update: { quantity: { increment: quantity } },
      create: {
        userId: request.user!.userId,
        productId,
        quantity,
      },
      include: { product: true },
    });

    return reply.send({ success: true, data: cartItem });
  });

  /**
   * PUT /cart/:productId
   * Savatdagi mahsulot sonini yangilash
   */
  app.put('/cart/:productId', { preHandler: authMiddleware }, async (request, reply) => {
    const { productId } = request.params as { productId: string };
    const { quantity } = request.body as { quantity: number };

    if (quantity <= 0) {
      await prisma.cartItem.deleteMany({
        where: { userId: request.user!.userId, productId },
      });
      return reply.send({ success: true, message: 'Savatdan o\'chirildi' });
    }

    const product = await prisma.product.findUnique({ where: { id: productId } });
    if (product && product.stock < quantity) {
      throw new AppError(`Faqat ${product.stock} dona mavjud`);
    }

    const cartItem = await prisma.cartItem.update({
      where: {
        userId_productId: {
          userId: request.user!.userId,
          productId,
        },
      },
      data: { quantity },
      include: { product: true },
    });

    return reply.send({ success: true, data: cartItem });
  });

  /**
   * DELETE /cart/:productId
   * Savatdan o'chirish
   */
  app.delete('/cart/:productId', { preHandler: authMiddleware }, async (request, reply) => {
    const { productId } = request.params as { productId: string };

    await prisma.cartItem.deleteMany({
      where: { userId: request.user!.userId, productId },
    });

    return reply.send({ success: true });
  });

  /**
   * DELETE /cart
   * Savatni tozalash
   */
  app.delete('/cart', { preHandler: authMiddleware }, async (request, reply) => {
    await prisma.cartItem.deleteMany({
      where: { userId: request.user!.userId },
    });
    return reply.send({ success: true });
  });

  // ============================================
  // FAVORITES (Sevimlilar)
  // ============================================

  /**
   * GET /favorites
   */
  app.get('/favorites', { preHandler: authMiddleware }, async (request, reply) => {
    const favorites = await prisma.favorite.findMany({
      where: { userId: request.user!.userId },
      include: {
        product: {
          include: {
            shop: { select: { id: true, name: true, logoUrl: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return reply.send({ success: true, data: favorites });
  });

  /**
   * POST /favorites/:productId
   * Sevimliga qo'shish
   */
  app.post('/favorites/:productId', { preHandler: authMiddleware }, async (request, reply) => {
    const { productId } = request.params as { productId: string };

    await prisma.favorite.upsert({
      where: {
        userId_productId: {
          userId: request.user!.userId,
          productId,
        },
      },
      update: {},
      create: {
        userId: request.user!.userId,
        productId,
      },
    });

    return reply.send({ success: true });
  });

  /**
   * DELETE /favorites/:productId
   */
  app.delete('/favorites/:productId', { preHandler: authMiddleware }, async (request, reply) => {
    const { productId } = request.params as { productId: string };

    await prisma.favorite.deleteMany({
      where: { userId: request.user!.userId, productId },
    });

    return reply.send({ success: true });
  });

  // ============================================
  // VENDOR: Mahsulot boshqarish
  // ============================================

  /**
   * POST /vendor/products
   * Yangi mahsulot qo'shish
   */
  app.post(
    '/vendor/products',
    { preHandler: [authMiddleware, requireRole('vendor', 'admin')] },
    async (request, reply) => {
      const body = createProductSchema.parse(request.body);

      const shop = await prisma.shop.findUnique({
        where: { ownerId: request.user!.userId },
      });

      if (!shop) throw new AppError('Do\'kon topilmadi');

      // Auto-moderation: validate product data
      const validation = validateProduct({
        nameUz: body.nameUz || body.name,
        nameRu: body.nameRu || body.name,
        descriptionUz: body.descriptionUz || body.description || '',
        descriptionRu: body.descriptionRu || body.description || '',
        images: body.images,
        price: body.price,
        categoryId: body.categoryId,
        stock: body.stock,
      });

      const qualityScore = calculateQualityScore({
        nameUz: body.nameUz || body.name,
        nameRu: body.nameRu || body.name,
        descriptionUz: body.descriptionUz || body.description || '',
        descriptionRu: body.descriptionRu || body.description || '',
        images: body.images,
        price: body.price,
        originalPrice: body.originalPrice,
        categoryId: body.categoryId,
        brandId: body.brandId,
        colorId: body.colorId,
        sku: body.sku,
        weight: body.weight,
        stock: body.stock,
      });

      // Determine status based on validation
      const status = validation.isValid ? 'active' : 'has_errors';

      const { categoryId, subcategoryId, brandId, colorId, ...restBody } = body;

      const product = await prisma.product.create({
        data: {
          ...restBody,
          nameUz: body.nameUz || body.name,
          nameRu: body.nameRu || body.name,
          descriptionUz: body.descriptionUz || body.description || null,
          descriptionRu: body.descriptionRu || body.description || null,
          status,
          qualityScore,
          validationErrors: validation.isValid ? [] : validation.errors.map(e => e.message),
          thumbnailUrl: body.images?.[0] || null,
          moderatedAt: new Date(),
          shop: { connect: { id: shop.id } },
          ...(categoryId && { category: { connect: { id: categoryId } } }),
          ...(subcategoryId && { subcategory: { connect: { id: subcategoryId } } }),
          ...(brandId && { brand: { connect: { id: brandId } } }),
          ...(colorId && { color: { connect: { id: colorId } } }),
        } as any,
        include: {
          category: { select: { id: true, nameUz: true, nameRu: true } },
          shop: { select: { id: true, name: true } },
        },
      });

      // Index in Meilisearch if active
      if (status === 'active') {
        try { await indexProduct(product); } catch (e) { /* non-blocking */ }
      }

      // Create moderation log
      await prisma.productModerationLog.create({
        data: {
          productId: product.id,
          action: status === 'active' ? 'auto_approved' : 'auto_rejected',
          reason: status === 'active' 
            ? `Avtomatik tasdiqlandi. Sifat balli: ${qualityScore}/100`
            : `Xatoliklar topildi: ${validation.errors.map(e => e.message).join(', ')}`,
        },
      });

      return reply.status(201).send({
        success: true,
        data: {
          ...product,
          qualityScore,
          validationErrors: validation.errors,
          moderationStatus: status,
        },
      });
    },
  );

  /**
   * PUT /vendor/products/:id
   */
  app.put(
    '/vendor/products/:id',
    { preHandler: [authMiddleware, requireRole('vendor', 'admin')] },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const body = updateProductSchema.parse(request.body);

      const shop = await prisma.shop.findUnique({
        where: { ownerId: request.user!.userId },
      });

      if (!shop) throw new AppError('Do\'kon topilmadi');

      const product = await prisma.product.findFirst({
        where: { id, shopId: shop.id },
      });

      if (!product) throw new NotFoundError('Mahsulot');

      // Merge existing data with updates for validation
      const merged = {
        nameUz: body.nameUz || body.name || (product as any).nameUz || product.name,
        nameRu: body.nameRu || body.name || (product as any).nameRu || product.name,
        descriptionUz: body.descriptionUz || body.description || (product as any).descriptionUz || product.description || '',
        descriptionRu: body.descriptionRu || body.description || (product as any).descriptionRu || product.description || '',
        images: body.images || product.images as string[],
        price: body.price || Number(product.price),
        categoryId: body.categoryId || product.categoryId,
        stock: body.stock ?? product.stock,
        originalPrice: body.originalPrice || (product.originalPrice ? Number(product.originalPrice) : undefined),
        brandId: body.brandId || product.brandId,
        colorId: body.colorId || product.colorId,
        sku: body.sku || (product as any).sku,
        weight: body.weight || (product as any).weight,
      };

      const validation = validateProduct(merged);
      const qualityScore = calculateQualityScore(merged);
      const status = validation.isValid ? 'active' : 'has_errors';

      const updated = await prisma.product.update({
        where: { id },
        data: {
          ...body,
          nameUz: merged.nameUz,
          nameRu: merged.nameRu,
          descriptionUz: merged.descriptionUz || null,
          descriptionRu: merged.descriptionRu || null,
          status,
          qualityScore,
          validationErrors: validation.isValid ? [] : validation.errors.map(e => e.message),
          thumbnailUrl: merged.images?.[0] || (product as any).thumbnailUrl,
          moderatedAt: new Date(),
        } as any,
        include: {
          category: { select: { id: true, nameUz: true, nameRu: true } },
          shop: { select: { id: true, name: true } },
        },
      });

      // Update Meilisearch index
      try {
        if (status === 'active') {
          await indexProduct(updated);
        } else {
          await removeProductFromIndex(id);
        }
      } catch (e) { /* non-blocking */ }

      // Create moderation log
      await prisma.productModerationLog.create({
        data: {
          productId: id,
          action: 'revalidated',
          reason: `Qayta tekshirildi. Status: ${status}, Sifat: ${qualityScore}/100`,
        },
      });

      return reply.send({
        success: true,
        data: {
          ...updated,
          qualityScore,
          validationErrors: validation.errors,
          moderationStatus: status,
        },
      });
    },
  );

  /**
   * DELETE /vendor/products/:id
   */
  app.delete(
    '/vendor/products/:id',
    { preHandler: [authMiddleware, requireRole('vendor', 'admin')] },
    async (request, reply) => {
      const { id } = request.params as { id: string };

      const shop = await prisma.shop.findUnique({
        where: { ownerId: request.user!.userId },
      });

      if (!shop) throw new AppError('Do\'kon topilmadi');

      await prisma.product.deleteMany({
        where: { id, shopId: shop.id },
      });

      // Remove from search index
      try { await removeProductFromIndex(id); } catch (e) { /* non-blocking */ }

      return reply.send({ success: true });
    },
  );
}
