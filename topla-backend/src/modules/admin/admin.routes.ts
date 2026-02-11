// ============================================
// Admin Routes — Full Admin Panel API
// Dashboard, Users, Shops, Products, Orders,
// Categories, Promo Codes, Delivery Zones,
// Banners, Payouts, Notifications, Reports,
// Logs, Settings
// ============================================

import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../config/database.js';
import { authMiddleware, requireRole } from '../../middleware/auth.js';
import { generateToken, JwtPayload } from '../../utils/jwt.js';
import { AppError, NotFoundError } from '../../middleware/error.js';
import bcrypt from 'bcryptjs';

// ============================================
// Pagination helper
// ============================================
function parsePagination(query: any) {
  const page = Math.max(1, parseInt(query.page) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(query.limit) || 20));
  const skip = (page - 1) * limit;
  return { page, limit, skip };
}

function paginationMeta(total: number, page: number, limit: number) {
  return {
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
    hasMore: page * limit < total,
  };
}

// ============================================
// Admin Auth
// ============================================
const adminLoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

// ============================================
// Route Registration
// ============================================
export async function adminRoutes(app: FastifyInstance) {

  // ==========================================
  // AUTH: Admin Login
  // ==========================================
  app.post('/auth/admin/login', async (request, reply) => {
    const { email, password } = adminLoginSchema.parse(request.body);

    const user = await prisma.profile.findFirst({
      where: { email, role: 'admin' },
    });

    if (!user || !user.passwordHash) {
      throw new AppError('Email yoki parol noto\'g\'ri', 401);
    }

    const isValid = await bcrypt.compare(password, user.passwordHash);
    if (!isValid) {
      throw new AppError('Email yoki parol noto\'g\'ri', 401);
    }

    const token = generateToken({
      userId: user.id,
      role: user.role,
      phone: user.phone,
    });

    // Log activity
    await prisma.activityLog.create({
      data: {
        userId: user.id,
        action: 'admin.login',
        entityType: 'profile',
        entityId: user.id,
        ipAddress: request.ip,
      },
    });

    return reply.send({
      success: true,
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          fullName: user.fullName,
          role: user.role,
          avatarUrl: user.avatarUrl,
        },
      },
    });
  });

  // ==========================================
  // DASHBOARD
  // ==========================================
  app.get('/admin/dashboard', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [
      totalUsers,
      totalShops,
      totalProducts,
      totalOrders,
      todayOrders,
      pendingShops,
      pendingProducts, // has_errors or on_review
      totalRevenue,
      todayRevenue,
    ] = await Promise.all([
      prisma.profile.count({ where: { role: 'user' } }),
      prisma.shop.count({ where: { status: 'active' } }),
      prisma.product.count({ where: { status: 'active' } }),
      prisma.order.count(),
      prisma.order.count({ where: { createdAt: { gte: today } } }),
      prisma.shop.count({ where: { status: 'pending' } }),
      prisma.product.count({ where: { status: { in: ['on_review', 'has_errors'] } } }),
      prisma.order.aggregate({ _sum: { total: true }, where: { paymentStatus: 'paid' } }),
      prisma.order.aggregate({ _sum: { total: true }, where: { paymentStatus: 'paid', createdAt: { gte: today } } }),
    ]);

    // Recent orders
    const recentOrders = await prisma.order.findMany({
      take: 10,
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { fullName: true, phone: true } },
        items: { include: { shop: { select: { name: true } } } },
      },
    });

    return {
      success: true,
      data: {
        stats: {
          totalUsers,
          totalShops,
          totalProducts,
          totalOrders,
          todayOrders,
          pendingShops,
          pendingProducts,
          totalRevenue: totalRevenue._sum.total || 0,
          todayRevenue: todayRevenue._sum.total || 0,
        },
        recentOrders,
      },
    };
  });

  // ==========================================
  // USERS
  // ==========================================
  app.get('/admin/users', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const query = request.query as any;
    const { page, limit, skip } = parsePagination(query);
    const search = query.search as string | undefined;
    const role = query.role as string | undefined;
    const status = query.status as string | undefined;

    const where: any = {};
    if (role) where.role = role;
    if (status) where.status = status;
    if (search) {
      where.OR = [
        { fullName: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
        { email: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [users, total] = await Promise.all([
      prisma.profile.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true, phone: true, email: true, fullName: true,
          role: true, status: true, avatarUrl: true, createdAt: true,
          _count: { select: { orders: true } },
        },
      }),
      prisma.profile.count({ where }),
    ]);

    return { success: true, data: { items: users, pagination: paginationMeta(total, page, limit) } };
  });

  app.put('/admin/users/:id/status', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const { status } = z.object({ status: z.enum(['active', 'blocked', 'inactive']) }).parse(request.body);

    const user = await prisma.profile.update({ where: { id }, data: { status } });

    await prisma.activityLog.create({
      data: {
        userId: request.user!.userId,
        action: `user.${status}`,
        entityType: 'profile',
        entityId: id,
        ipAddress: request.ip,
      },
    });

    return { success: true, data: user };
  });

  // ==========================================
  // SHOPS
  // ==========================================
  app.get('/admin/shops', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const query = request.query as any;
    const { page, limit, skip } = parsePagination(query);
    const status = query.status as string | undefined;
    const search = query.search as string | undefined;

    const where: any = {};
    if (status) where.status = status;
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
      ];
    }

    const [shops, total] = await Promise.all([
      prisma.shop.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          owner: { select: { fullName: true, phone: true, email: true } },
          _count: { select: { products: true, orderItems: true } },
        },
      }),
      prisma.shop.count({ where }),
    ]);

    return { success: true, data: { items: shops, pagination: paginationMeta(total, page, limit) } };
  });

  app.get('/admin/shops/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const shop = await prisma.shop.findUnique({
      where: { id },
      include: {
        owner: { select: { fullName: true, phone: true, email: true, createdAt: true } },
        _count: { select: { products: true, orderItems: true, reviews: true } },
      },
    });
    if (!shop) throw new NotFoundError('Do\'kon');
    return { success: true, data: shop };
  });

  app.put('/admin/shops/:id/status', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const { status, reason } = z.object({
      status: z.enum(['active', 'blocked', 'inactive', 'pending']),
      reason: z.string().optional(),
    }).parse(request.body);

    const shop = await prisma.shop.update({ where: { id }, data: { status } });

    await prisma.activityLog.create({
      data: {
        userId: request.user!.userId,
        action: `shop.${status}`,
        entityType: 'shop',
        entityId: id,
        details: reason ? { reason } : undefined,
        ipAddress: request.ip,
      },
    });

    // Notify shop owner
    if (shop.ownerId) {
      const titleMap: Record<string, string> = {
        active: '✅ Do\'koningiz tasdiqlandi!',
        blocked: '🚫 Do\'koningiz bloklandi',
        inactive: '⏸️ Do\'koningiz to\'xtatildi',
      };
      if (titleMap[status]) {
        await prisma.notification.create({
          data: {
            userId: shop.ownerId,
            type: 'system',
            title: titleMap[status],
            body: reason || `Do'koningiz statusi "${status}" ga o'zgartirildi`,
          },
        });
      }
    }

    return { success: true, data: shop };
  });

  app.put('/admin/shops/:id/commission', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const { commissionRate } = z.object({
      commissionRate: z.number().min(0).max(100),
    }).parse(request.body);

    const shop = await prisma.shop.update({
      where: { id },
      data: { commissionRate },
    });

    await prisma.activityLog.create({
      data: {
        userId: request.user!.userId,
        action: 'shop.commission_change',
        entityType: 'shop',
        entityId: id,
        details: { commissionRate },
        ipAddress: request.ip,
      },
    });

    return { success: true, data: shop };
  });

  // ==========================================
  // PRODUCTS (Admin moderation)
  // ==========================================
  app.get('/admin/products', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const query = request.query as any;
    const { page, limit, skip } = parsePagination(query);
    const status = query.status as string | undefined;
    const search = query.search as string | undefined;
    const shopId = query.shopId as string | undefined;

    const where: any = {};
    if (status) where.status = status;
    if (shopId) where.shopId = shopId;
    if (search) {
      where.OR = [
        { nameUz: { contains: search, mode: 'insensitive' } },
        { nameRu: { contains: search, mode: 'insensitive' } },
        { name: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [products, total, stats] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          shop: { select: { id: true, name: true } },
          category: { select: { id: true, nameUz: true, nameRu: true } },
          brand: { select: { id: true, name: true } },
        },
      }),
      prisma.product.count({ where }),
      Promise.all([
        prisma.product.count({ where: { status: 'active' } }),
        prisma.product.count({ where: { status: 'on_review' } }),
        prisma.product.count({ where: { status: 'has_errors' } }),
        prisma.product.count({ where: { status: 'blocked' } }),
        prisma.product.count({ where: { status: 'hidden' } }),
        prisma.product.count({ where: { status: 'draft' } }),
      ]),
    ]);

    return {
      success: true,
      data: {
        items: products,
        pagination: paginationMeta(total, page, limit),
        stats: {
          active: stats[0],
          onReview: stats[1],
          hasErrors: stats[2],
          blocked: stats[3],
          hidden: stats[4],
          draft: stats[5],
        },
      },
    };
  });

  app.put('/admin/products/:id/block', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const { reason } = z.object({ reason: z.string().min(1) }).parse(request.body);

    const product = await prisma.product.update({
      where: { id },
      data: {
        status: 'blocked',
        moderatedBy: request.user!.userId,
        moderatedAt: new Date(),
      },
      include: { shop: { select: { ownerId: true, name: true } } },
    });

    // Log
    await prisma.productModerationLog.create({
      data: {
        productId: id,
        adminId: request.user!.userId,
        action: 'admin_blocked',
        reason,
      },
    });

    await prisma.activityLog.create({
      data: {
        userId: request.user!.userId,
        action: 'product.block',
        entityType: 'product',
        entityId: id,
        details: { reason, productName: product.nameUz },
        ipAddress: request.ip,
      },
    });

    // Notify vendor
    if (product.shop?.ownerId) {
      await prisma.notification.create({
        data: {
          userId: product.shop.ownerId,
          type: 'system',
          title: '🚫 Mahsulotingiz bloklandi',
          body: `"${product.nameUz}" bloklandi. Sabab: ${reason}`,
          data: { productId: id },
        },
      });
    }

    return { success: true, data: product };
  });

  app.put('/admin/products/:id/unblock', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };

    const product = await prisma.product.update({
      where: { id },
      data: {
        status: 'active',
        moderatedBy: request.user!.userId,
        moderatedAt: new Date(),
      },
      include: { shop: { select: { ownerId: true } } },
    });

    await prisma.productModerationLog.create({
      data: {
        productId: id,
        adminId: request.user!.userId,
        action: 'admin_unblocked',
      },
    });

    await prisma.activityLog.create({
      data: {
        userId: request.user!.userId,
        action: 'product.unblock',
        entityType: 'product',
        entityId: id,
        ipAddress: request.ip,
      },
    });

    if (product.shop?.ownerId) {
      await prisma.notification.create({
        data: {
          userId: product.shop.ownerId,
          type: 'system',
          title: '✅ Mahsulotingiz blokdan chiqarildi',
          body: `"${product.nameUz}" endi saytda ko'rinadi`,
          data: { productId: id },
        },
      });
    }

    return { success: true, data: product };
  });

  app.delete('/admin/products/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };

    await prisma.product.delete({ where: { id } });

    await prisma.activityLog.create({
      data: {
        userId: request.user!.userId,
        action: 'product.delete',
        entityType: 'product',
        entityId: id,
        ipAddress: request.ip,
      },
    });

    return { success: true, message: 'Mahsulot o\'chirildi' };
  });

  // ==========================================
  // ORDERS
  // ==========================================
  app.get('/admin/orders', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const query = request.query as any;
    const { page, limit, skip } = parsePagination(query);
    const status = query.status as string | undefined;
    const search = query.search as string | undefined;

    const where: any = {};
    if (status) where.status = status;
    if (search) {
      where.OR = [
        { orderNumber: { contains: search, mode: 'insensitive' } },
        { user: { phone: { contains: search } } },
        { user: { fullName: { contains: search, mode: 'insensitive' } } },
      ];
    }

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { fullName: true, phone: true } },
          items: {
            include: {
              shop: { select: { name: true } },
              product: { select: { nameUz: true, images: true } },
            },
          },
          address: { select: { fullAddress: true } },
        },
      }),
      prisma.order.count({ where }),
    ]);

    return { success: true, data: { items: orders, pagination: paginationMeta(total, page, limit) } };
  });

  app.get('/admin/orders/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        user: { select: { fullName: true, phone: true, email: true } },
        address: true,
        items: {
          include: {
            shop: { select: { name: true, phone: true } },
            product: { select: { nameUz: true, images: true } },
          },
        },
        statusHistory: { orderBy: { createdAt: 'desc' } },
        courier: {
          include: {
            profile: { select: { fullName: true, phone: true } },
          },
        },
      },
    });
    if (!order) throw new NotFoundError('Buyurtma');
    return { success: true, data: order };
  });

  // ==========================================
  // CATEGORIES
  // ==========================================
  app.get('/admin/categories', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async () => {
    const categories = await prisma.category.findMany({
      orderBy: { sortOrder: 'asc' },
      include: {
        subcategories: { orderBy: { sortOrder: 'asc' } },
        _count: { select: { products: true } },
      },
    });
    return { success: true, data: categories };
  });

  app.post('/admin/categories', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const data = z.object({
      nameUz: z.string().min(1),
      nameRu: z.string().min(1),
      icon: z.string().optional(),
      imageUrl: z.string().optional(),
      sortOrder: z.number().optional(),
    }).parse(request.body);

    const category = await prisma.category.create({ data: data as any });
    return { success: true, data: category };
  });

  app.put('/admin/categories/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const data = z.object({
      nameUz: z.string().min(1).optional(),
      nameRu: z.string().min(1).optional(),
      icon: z.string().optional(),
      imageUrl: z.string().optional(),
      sortOrder: z.number().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);

    const category = await prisma.category.update({ where: { id }, data });
    return { success: true, data: category };
  });

  app.delete('/admin/categories/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    await prisma.category.delete({ where: { id } });
    return { success: true, message: 'Kategoriya o\'chirildi' };
  });

  // Subcategories
  app.post('/admin/subcategories', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const data = z.object({
      categoryId: z.string().uuid(),
      nameUz: z.string().min(1),
      nameRu: z.string().min(1),
      sortOrder: z.number().optional(),
    }).parse(request.body);

    const sub = await prisma.subcategory.create({ data: data as any });
    return { success: true, data: sub };
  });

  app.put('/admin/subcategories/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const data = z.object({
      nameUz: z.string().min(1).optional(),
      nameRu: z.string().min(1).optional(),
      sortOrder: z.number().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);

    const sub = await prisma.subcategory.update({ where: { id }, data });
    return { success: true, data: sub };
  });

  app.delete('/admin/subcategories/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    await prisma.subcategory.delete({ where: { id } });
    return { success: true, message: 'Subkategoriya o\'chirildi' };
  });

  // ==========================================
  // BRANDS
  // ==========================================
  app.get('/admin/brands', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async () => {
    const brands = await prisma.brand.findMany({
      orderBy: { name: 'asc' },
      include: { _count: { select: { products: true } } },
    });
    return { success: true, data: brands };
  });

  app.post('/admin/brands', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const data = z.object({
      name: z.string().min(1),
      logoUrl: z.string().optional(),
    }).parse(request.body);
    const brand = await prisma.brand.create({ data: data as any });
    return { success: true, data: brand };
  });

  app.put('/admin/brands/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const data = z.object({
      name: z.string().min(1).optional(),
      logoUrl: z.string().optional(),
    }).parse(request.body);
    const brand = await prisma.brand.update({ where: { id }, data });
    return { success: true, data: brand };
  });

  app.delete('/admin/brands/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    await prisma.brand.delete({ where: { id } });
    return { success: true, message: 'Brend o\'chirildi' };
  });

  // ==========================================
  // PROMO CODES
  // ==========================================
  app.get('/admin/promo-codes', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const query = request.query as any;
    const { page, limit, skip } = parsePagination(query);

    const [promoCodes, total] = await Promise.all([
      prisma.promoCode.findMany({
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.promoCode.count(),
    ]);

    return { success: true, data: { items: promoCodes, pagination: paginationMeta(total, page, limit) } };
  });

  app.post('/admin/promo-codes', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const data = z.object({
      code: z.string().min(3).toUpperCase(),
      discountType: z.enum(['percentage', 'fixed']),
      discountValue: z.number().positive(),
      minOrderAmount: z.number().optional(),
      maxUses: z.number().optional(),
      expiresAt: z.string().datetime().optional(),
    }).parse(request.body);

    const promo = await prisma.promoCode.create({
      data: {
        ...data,
        expiresAt: data.expiresAt ? new Date(data.expiresAt) : undefined,
      } as any,
    });

    return { success: true, data: promo };
  });

  app.put('/admin/promo-codes/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const data = z.object({
      code: z.string().optional(),
      discountType: z.enum(['percentage', 'fixed']).optional(),
      discountValue: z.number().positive().optional(),
      minOrderAmount: z.number().optional(),
      maxUses: z.number().optional(),
      expiresAt: z.string().datetime().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);

    const promo = await prisma.promoCode.update({
      where: { id },
      data: {
        ...data,
        expiresAt: data.expiresAt ? new Date(data.expiresAt) : undefined,
      },
    });

    return { success: true, data: promo };
  });

  app.delete('/admin/promo-codes/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    await prisma.promoCode.delete({ where: { id } });
    return { success: true, message: 'Promo kod o\'chirildi' };
  });

  // ==========================================
  // DELIVERY ZONES
  // ==========================================
  app.get('/admin/delivery-zones', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async () => {
    const zones = await prisma.deliveryZone.findMany({ orderBy: { name: 'asc' } });
    return { success: true, data: zones };
  });

  app.post('/admin/delivery-zones', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const data = z.object({
      name: z.string().min(1),
      polygon: z.any(),
      deliveryFee: z.number().min(0),
      minOrder: z.number().optional(),
    }).parse(request.body);

    const zone = await prisma.deliveryZone.create({ data: data as any });
    return { success: true, data: zone };
  });

  app.put('/admin/delivery-zones/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const data = z.object({
      name: z.string().optional(),
      polygon: z.any().optional(),
      deliveryFee: z.number().optional(),
      minOrder: z.number().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);

    const zone = await prisma.deliveryZone.update({ where: { id }, data });
    return { success: true, data: zone };
  });

  app.delete('/admin/delivery-zones/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    await prisma.deliveryZone.delete({ where: { id } });
    return { success: true, message: 'Yetkazish zonasi o\'chirildi' };
  });

  // ==========================================
  // BANNERS (extended)
  // ==========================================
  app.get('/admin/banners', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async () => {
    const banners = await prisma.banner.findMany({ orderBy: { sortOrder: 'asc' } });
    return { success: true, data: banners };
  });

  app.post('/admin/banners', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const data = z.object({
      imageUrl: z.string(),
      titleUz: z.string().optional(),
      titleRu: z.string().optional(),
      subtitleUz: z.string().optional(),
      subtitleRu: z.string().optional(),
      actionType: z.string().optional(),
      actionValue: z.string().optional(),
      sortOrder: z.number().optional(),
    }).parse(request.body);

    const banner = await prisma.banner.create({ data: data as any });
    return { success: true, data: banner };
  });

  app.put('/admin/banners/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const data = z.object({
      imageUrl: z.string().optional(),
      titleUz: z.string().optional(),
      titleRu: z.string().optional(),
      subtitleUz: z.string().optional(),
      subtitleRu: z.string().optional(),
      actionType: z.string().optional(),
      actionValue: z.string().optional(),
      sortOrder: z.number().optional(),
      isActive: z.boolean().optional(),
    }).parse(request.body);

    const banner = await prisma.banner.update({ where: { id }, data });
    return { success: true, data: banner };
  });

  app.delete('/admin/banners/:id', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    await prisma.banner.delete({ where: { id } });
    return { success: true, message: 'Banner o\'chirildi' };
  });

  // ==========================================
  // PAYOUTS
  // ==========================================
  app.get('/admin/payouts', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const query = request.query as any;
    const { page, limit, skip } = parsePagination(query);
    const status = query.status as string | undefined;

    const where: any = {};
    if (status) where.status = status;

    const [payouts, total] = await Promise.all([
      prisma.payout.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: { shop: { select: { name: true, balance: true } } },
      }),
      prisma.payout.count({ where }),
    ]);

    return { success: true, data: { items: payouts, pagination: paginationMeta(total, page, limit) } };
  });

  app.put('/admin/payouts/:id/process', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { id } = request.params as { id: string };
    const { status } = z.object({
      status: z.enum(['completed', 'failed']),
    }).parse(request.body);

    const payout = await prisma.payout.update({
      where: { id },
      data: {
        status,
        processedAt: new Date(),
      },
    });

    await prisma.activityLog.create({
      data: {
        userId: request.user!.userId,
        action: `payout.${status}`,
        entityType: 'payout',
        entityId: id,
        ipAddress: request.ip,
      },
    });

    return { success: true, data: payout };
  });

  // ==========================================
  // NOTIFICATIONS (broadcast)
  // ==========================================
  app.post('/admin/notifications/broadcast', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const { title, body, targetRole } = z.object({
      title: z.string().min(1),
      body: z.string().min(1),
      targetRole: z.enum(['user', 'vendor', 'courier', 'all']).default('all'),
    }).parse(request.body);

    const where: any = {};
    if (targetRole !== 'all') where.role = targetRole;

    const users = await prisma.profile.findMany({
      where,
      select: { id: true },
    });

    // Create notifications in bulk
    await prisma.notification.createMany({
      data: users.map(u => ({
        userId: u.id,
        type: 'system' as const,
        title,
        body,
      })),
    });

    return {
      success: true,
      message: `${users.length} ta foydalanuvchiga bildirishnoma yuborildi`,
    };
  });

  // ==========================================
  // REPORTS
  // ==========================================
  app.get('/admin/reports', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const query = request.query as any;
    const period = (query.period as string) || '30d';

    let startDate = new Date();
    if (period === '7d') startDate.setDate(startDate.getDate() - 7);
    else if (period === '30d') startDate.setDate(startDate.getDate() - 30);
    else if (period === '90d') startDate.setDate(startDate.getDate() - 90);
    else startDate.setFullYear(startDate.getFullYear() - 1);

    const [
      orderStats,
      revenueByShop,
      topProducts,
      newUsers,
      newShops,
    ] = await Promise.all([
      prisma.order.groupBy({
        by: ['status'],
        _count: true,
        where: { createdAt: { gte: startDate } },
      }),
      prisma.vendorTransaction.groupBy({
        by: ['shopId'],
        _sum: { amount: true, commission: true, netAmount: true },
        where: { createdAt: { gte: startDate } },
        orderBy: { _sum: { amount: 'desc' } },
        take: 10,
      }),
      prisma.product.findMany({
        where: { createdAt: { gte: startDate } },
        orderBy: { salesCount: 'desc' },
        take: 10,
        select: {
          id: true, nameUz: true, price: true, salesCount: true,
          shop: { select: { name: true } },
        },
      }),
      prisma.profile.count({ where: { role: 'user', createdAt: { gte: startDate } } }),
      prisma.shop.count({ where: { createdAt: { gte: startDate } } }),
    ]);

    return {
      success: true,
      data: {
        period,
        orderStats,
        revenueByShop,
        topProducts,
        newUsers,
        newShops,
      },
    };
  });

  // ==========================================
  // LOGS (Activity)
  // ==========================================
  app.get('/admin/logs', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const query = request.query as any;
    const { page, limit, skip } = parsePagination(query);
    const action = query.action as string | undefined;
    const entityType = query.entityType as string | undefined;

    const where: any = {};
    if (action) where.action = { contains: action };
    if (entityType) where.entityType = entityType;

    const [logs, total] = await Promise.all([
      prisma.activityLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.activityLog.count({ where }),
    ]);

    return { success: true, data: { items: logs, pagination: paginationMeta(total, page, limit) } };
  });

  // ==========================================
  // SETTINGS
  // ==========================================
  app.get('/admin/settings', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async () => {
    const settings = await prisma.adminSetting.findMany();
    // Convert to key-value map
    const map: Record<string, any> = {};
    for (const s of settings) {
      if (s.type === 'number') map[s.key] = parseFloat(s.value);
      else if (s.type === 'boolean') map[s.key] = s.value === 'true';
      else if (s.type === 'json') map[s.key] = JSON.parse(s.value);
      else map[s.key] = s.value;
    }
    return { success: true, data: map };
  });

  app.put('/admin/settings', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const settings = request.body as Record<string, any>;

    for (const [key, value] of Object.entries(settings)) {
      const type = typeof value === 'number' ? 'number'
        : typeof value === 'boolean' ? 'boolean'
        : typeof value === 'object' ? 'json'
        : 'string';

      await prisma.adminSetting.upsert({
        where: { key },
        create: { key, value: String(value), type },
        update: { value: String(value), type },
      });
    }

    await prisma.activityLog.create({
      data: {
        userId: request.user!.userId,
        action: 'settings.update',
        entityType: 'settings',
        details: settings,
        ipAddress: request.ip,
      },
    });

    return { success: true, message: 'Sozlamalar yangilandi' };
  });

  // ==========================================
  // COURIERS (existing, moved here for completeness)
  // ==========================================
  app.get('/admin/couriers', {
    preHandler: [authMiddleware, requireRole('admin')],
  }, async (request) => {
    const query = request.query as any;
    const { page, limit, skip } = parsePagination(query);
    const status = query.status as string | undefined;

    const where: any = {};
    if (status) where.status = status;

    const [couriers, total] = await Promise.all([
      prisma.courier.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          profile: { select: { fullName: true, phone: true, avatarUrl: true } },
        },
      }),
      prisma.courier.count({ where }),
    ]);

    return { success: true, data: { items: couriers, pagination: paginationMeta(total, page, limit) } };
  });
}
