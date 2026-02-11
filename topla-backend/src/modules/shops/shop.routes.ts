import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../config/database.js';
import { authMiddleware, requireRole, optionalAuth } from '../../middleware/auth.js';
import { AppError, NotFoundError } from '../../middleware/error.js';
import { parsePagination, paginationMeta } from '../../utils/pagination.js';

const createShopSchema = z.object({
  name: z.string().min(2).max(200),
  description: z.string().optional(),
  logoUrl: z.string().url().optional(),
  bannerUrl: z.string().url().optional(),
  phone: z.string().optional(),
  address: z.string().optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  telegram: z.string().optional(),
  instagram: z.string().optional(),
  minOrderAmount: z.number().optional(),
  deliveryFee: z.number().optional(),
  freeDeliveryFrom: z.number().optional(),
  deliveryRadius: z.number().optional(),
});

export async function shopRoutes(app: FastifyInstance): Promise<void> {

  /**
   * GET /shops
   * Do'konlar ro'yxati
   */
  app.get('/shops', async (request, reply) => {
    const { page = '1', limit = '20', search } = request.query as {
      page?: string;
      limit?: string;
      search?: string;
    };

    const where: any = { status: 'active' };
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const { page: pg, limit: lim, skip } = parsePagination({ page, limit });

    const [shops, total] = await Promise.all([
      prisma.shop.findMany({
        where,
        select: {
          id: true, name: true, description: true, logoUrl: true, bannerUrl: true,
          rating: true, reviewCount: true, address: true, isOpen: true,
          deliveryFee: true, freeDeliveryFrom: true, minOrderAmount: true,
          _count: { select: { products: true } },
        },
        orderBy: { rating: 'desc' },
        skip,
        take: lim,
      }),
      prisma.shop.count({ where }),
    ]);

    return reply.send({ success: true, data: { shops, total } });
  });

  /**
   * GET /shops/:id
   */
  app.get('/shops/:id', async (request, reply) => {
    const { id } = request.params as { id: string };

    const shop = await prisma.shop.findUnique({
      where: { id },
      include: {
        _count: { select: { products: true, reviews: true } },
      },
    });

    if (!shop) throw new NotFoundError('Do\'kon');

    return reply.send({ success: true, data: shop });
  });

  /**
   * GET /shops/:id/products
   */
  app.get('/shops/:id/products', async (request, reply) => {
    const { id } = request.params as { id: string };
    const { page = '1', limit = '20' } = request.query as { page?: string; limit?: string };
    const { page: pg2, limit: lim2, skip: skip2 } = parsePagination({ page, limit });

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where: { shopId: id, isActive: true },
        include: {
          category: { select: { id: true, nameUz: true, nameRu: true } },
          brand: { select: { id: true, name: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip: skip2,
        take: lim2,
      }),
      prisma.product.count({ where: { shopId: id, isActive: true } }),
    ]);

    return reply.send({ success: true, data: { products, total } });
  });

  /**
   * GET /shops/:id/reviews
   */
  app.get('/shops/:id/reviews', async (request, reply) => {
    const { id } = request.params as { id: string };

    const reviews = await prisma.shopReview.findMany({
      where: { shopId: id },
      include: {
        user: { select: { id: true, fullName: true, avatarUrl: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    return reply.send({ success: true, data: reviews });
  });

  /**
   * POST /shops/:id/reviews
   */
  app.post('/shops/:id/reviews', { preHandler: authMiddleware }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { rating, comment } = request.body as { rating: number; comment?: string };

    if (!rating || rating < 1 || rating > 5) {
      throw new AppError('Baho 1 dan 5 gacha bo\'lishi kerak');
    }

    await prisma.shopReview.upsert({
      where: {
        shopId_userId: { shopId: id, userId: request.user!.userId },
      },
      update: { rating, comment },
      create: { shopId: id, userId: request.user!.userId, rating, comment },
    });

    // Ratingni qayta hisoblash
    const avg = await prisma.shopReview.aggregate({
      where: { shopId: id },
      _avg: { rating: true },
      _count: true,
    });

    await prisma.shop.update({
      where: { id },
      data: {
        rating: avg._avg.rating || 0,
        reviewCount: avg._count || 0,
      },
    });

    return reply.send({ success: true });
  });

  // ============================================
  // VENDOR: Do'kon boshqarish
  // ============================================

  /**
   * POST /vendor/shop
   * Do'kon yaratish
   */
  app.post(
    '/vendor/shop',
    { preHandler: [authMiddleware] },
    async (request, reply) => {
      const body = createShopSchema.parse(request.body);
      const userId = request.user!.userId;

      // Telefon tasdiqlangan ekanligini tekshirish
      const profile = await prisma.profile.findUnique({
        where: { id: userId },
        select: { phone: true, status: true },
      });
      if (!profile?.phone) {
        throw new AppError('Do\'kon yaratish uchun telefon raqamingiz tasdiqlangan bo\'lishi kerak', 400);
      }
      if (profile.status === 'blocked') {
        throw new AppError('Hisobingiz bloklangan', 403);
      }

      const existing = await prisma.shop.findUnique({ where: { ownerId: userId } });
      if (existing) throw new AppError('Sizda allaqachon do\'kon bor');

      const shop = await prisma.shop.create({
        data: { 
          ...body,
          status: 'pending', // Admin tasdiqlashi kerak
          owner: { connect: { id: userId } }
        } as any,
      });

      // role ni vendor qilmaslik — admin tasdiqlangandan keyin
      // await prisma.profile.update({
      //   where: { id: userId },
      //   data: { role: 'vendor' },
      // });

      return reply.status(201).send({ 
        success: true, 
        data: shop,
        message: 'Do\'kon yaratildi. Admin tasdiqlashini kuting.',
      });
    },
  );

  /**
   * PUT /vendor/shop
   * Do'kon ma'lumotlarini yangilash
   */
  app.put(
    '/vendor/shop',
    { preHandler: [authMiddleware, requireRole('vendor', 'admin')] },
    async (request, reply) => {
      const body = createShopSchema.partial().parse(request.body);

      const shop = await prisma.shop.update({
        where: { ownerId: request.user!.userId },
        data: body,
      });

      return reply.send({ success: true, data: shop });
    },
  );

  /**
   * GET /vendor/dashboard
   * Vendor statistika
   */
  app.get(
    '/vendor/dashboard',
    { preHandler: [authMiddleware, requireRole('vendor', 'admin')] },
    async (request, reply) => {
      const shop = await prisma.shop.findUnique({
        where: { ownerId: request.user!.userId },
      });

      if (!shop) throw new NotFoundError('Do\'kon');

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const [totalOrders, todayOrders, pendingOrders, productsCount] = await Promise.all([
        prisma.order.count({
          where: { items: { some: { shopId: shop.id } } },
        }),
        prisma.order.count({
          where: {
            items: { some: { shopId: shop.id } },
            createdAt: { gte: today },
          },
        }),
        prisma.order.count({
          where: {
            items: { some: { shopId: shop.id } },
            status: 'pending',
          },
        }),
        prisma.product.count({ where: { shopId: shop.id } }),
      ]);

      return reply.send({
        success: true,
        data: {
          shop,
          stats: {
            totalOrders,
            todayOrders,
            pendingOrders,
            productsCount,
            balance: Number(shop.balance),
          },
        },
      });
    },
  );
}
