import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../config/database.js';
import { authMiddleware, requireRole, optionalAuth } from '../../middleware/auth.js';
import { AppError, NotFoundError } from '../../middleware/error.js';

// ============================================
// Validation Schemas
// ============================================

const createProductSchema = z.object({
  name: z.string().min(2).max(200),
  description: z.string().optional(),
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

    const where: any = { isActive: true };

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
      // Bugun bu user bu mahsulotni ko'rganmi tekshirish
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      // TODO: ProductView modeli schema.prisma ga qo'shilganda ochiladi
      /*
      const alreadyViewed = await prisma.productView?.findFirst?.({
        where: {
          productId: id,
          userId: request.user.userId,
          createdAt: { gte: today },
        },
      }).catch(() => null);

      if (!alreadyViewed) {
        await prisma.product.update({
          where: { id },
          data: { viewCount: { increment: 1 } },
        });
        // ProductView jadvali bo'lsa saqlash
        await prisma.productView?.create?.({
          data: { productId: id, userId: request.user.userId },
        }).catch(() => {});
      }
      */
      
      // Hozircha faqat oddiy increment
      await prisma.product.update({
        where: { id },
        data: { viewCount: { increment: 1 } },
      });
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

      const { categoryId, subcategoryId, brandId, colorId, ...restBody } = body;

      const product = await prisma.product.create({
        data: {
          ...restBody,
          shop: { connect: { id: shop.id } },
          ...(categoryId && { category: { connect: { id: categoryId } } }),
          ...(subcategoryId && { subcategory: { connect: { id: subcategoryId } } }),
          ...(brandId && { brand: { connect: { id: brandId } } }),
          ...(colorId && { color: { connect: { id: colorId } } }),
        } as any,
      });

      return reply.status(201).send({ success: true, data: product });
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

      const updated = await prisma.product.update({
        where: { id },
        data: body,
      });

      return reply.send({ success: true, data: updated });
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

      return reply.send({ success: true });
    },
  );
}
