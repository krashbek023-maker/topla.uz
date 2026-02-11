import { FastifyInstance } from 'fastify';
import { randomInt } from 'crypto';
import { z } from 'zod';
import { prisma } from '../../config/database.js';
import { authMiddleware } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/auth.js';
import { AppError, NotFoundError } from '../../middleware/error.js';
import { parsePagination, paginationMeta } from '../../utils/pagination.js';
import { notifyOrderStatusChange } from '../notifications/notification.service.js';
import { findAndAssignCourier } from '../courier/courier.service.js';

// ============================================
// Validation Schemas
// ============================================

// ============================================
// Helper: Dynamic delivery fee from AdminSetting
// ============================================

async function getDeliveryFee(): Promise<number> {
  try {
    const setting = await prisma.adminSetting.findUnique({
      where: { key: 'delivery_fee' },
    });
    if (setting) {
      return parseFloat(setting.value) || 15000;
    }
  } catch {
    // fallback
  }
  return 15000; // default
}

const createOrderSchema = z.object({
  addressId: z.string().uuid().optional(),
  deliveryMethod: z.enum(['courier', 'pickup']).default('courier'),
  paymentMethod: z.enum(['cash', 'card', 'payme', 'click']).default('cash'),
  recipientName: z.string().optional(),
  recipientPhone: z.string().optional(),
  deliveryDate: z.string().optional(),
  deliveryTimeSlot: z.string().optional(),
  promoCode: z.string().optional(),
  note: z.string().optional(),
});

const updateStatusSchema = z.object({
  status: z.enum([
    'confirmed',
    'processing',
    'ready_for_pickup',
    'courier_assigned',
    'courier_picked_up',
    'shipping',
    'delivered',
    'cancelled',
  ]),
  cancelReason: z.string().optional(),
});

// ============================================
// Helper: Generate order number
// ============================================

function generateOrderNumber(): string {
  const date = new Date();
  const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
  const random = randomInt(0, 10000).toString().padStart(4, '0');
  return `TOPLA-${dateStr}-${random}`;
}

// ============================================
// Status flow validation (Yandex Go style)
// ============================================

const VALID_TRANSITIONS: Record<string, string[]> = {
  pending: ['confirmed', 'cancelled'],
  confirmed: ['processing', 'cancelled'],
  processing: ['ready_for_pickup', 'cancelled'],
  ready_for_pickup: ['courier_assigned', 'cancelled'],
  courier_assigned: ['courier_picked_up', 'cancelled'],
  courier_picked_up: ['shipping'],
  shipping: ['delivered'],
  delivered: [], // final
  cancelled: [], // final
};

function isValidTransition(currentStatus: string, newStatus: string): boolean {
  return VALID_TRANSITIONS[currentStatus]?.includes(newStatus) ?? false;
}

// ============================================
// Routes
// ============================================

export async function orderRoutes(app: FastifyInstance): Promise<void> {
  // ============================================
  // MIJOZ (Customer) endpoints
  // ============================================

  /**
   * POST /orders
   * Yangi buyurtma yaratish
   */
  app.post('/orders', { preHandler: authMiddleware }, async (request, reply) => {
    const body = createOrderSchema.parse(request.body);
    const userId = request.user!.userId;

    // 1. Savatdagi mahsulotlarni olish
    const cartItems = await prisma.cartItem.findMany({
      where: { userId },
      include: {
        product: {
          include: { shop: true },
        },
      },
    });

    if (cartItems.length === 0) {
      throw new AppError('Savat bo\'sh');
    }

    // 2. Mahsulot mavjudligini tekshirish
    for (const item of cartItems) {
      if (item.product.stock < item.quantity) {
        throw new AppError(
          `"${item.product.name}" mahsulotidan faqat ${item.product.stock} dona bor`,
        );
      }
      if (!item.product.isActive) {
        throw new AppError(`"${item.product.name}" mahsuloti sotuvda mavjud emas`);
      }
    }

    // 3. Manzilni tekshirish (courier bo'lsa)
    if (body.deliveryMethod === 'courier') {
      if (!body.addressId) {
        throw new AppError('Yetkazib berish uchun manzil kerak');
      }
      const address = await prisma.address.findFirst({
        where: { id: body.addressId, userId },
      });
      if (!address) {
        throw new AppError('Manzil topilmadi');
      }
    }

    // 4. Narxlarni hisoblash
    const subtotal = cartItems.reduce(
      (sum, item) => sum + Number(item.product.price) * item.quantity,
      0,
    );

    let discount = 0;
    // Promo code tekshirish
    if (body.promoCode) {
      const promo = await prisma.promoCode.findFirst({
        where: {
          code: body.promoCode.toUpperCase(),
          isActive: true,
          OR: [{ expiresAt: null }, { expiresAt: { gt: new Date() } }],
        },
      });

      if (promo) {
        if (promo.maxUses && promo.currentUses >= promo.maxUses) {
          throw new AppError('Promo kod limiti tugagan');
        }

        // Oldin ishlatilganmi?
        const alreadyUsed = await prisma.promoCodeUsage.findFirst({
          where: { promoId: promo.id, userId },
        });
        if (alreadyUsed) {
          throw new AppError('Siz bu promo kodni oldin ishlatgansiz');
        }

        discount =
          promo.discountType === 'percentage'
            ? (subtotal * Number(promo.discountValue)) / 100
            : Number(promo.discountValue);
      }
    }

    const deliveryFee = body.deliveryMethod === 'courier'
      ? await getDeliveryFee()
      : 0;
    const total = Math.max(0, subtotal - discount + deliveryFee);

    // 5. Transaction ichida buyurtma yaratish
    const order = await prisma.$transaction(async (tx) => {
      // Buyurtma yaratish
      const newOrder = await tx.order.create({
        data: {
          orderNumber: generateOrderNumber(),
          userId,
          addressId: body.addressId || null,
          status: 'pending',
          paymentStatus: body.paymentMethod === 'cash' ? 'pending' : 'pending',
          paymentMethod: body.paymentMethod,
          deliveryMethod: body.deliveryMethod,
          subtotal,
          deliveryFee,
          discount,
          total,
          recipientName: body.recipientName,
          recipientPhone: body.recipientPhone,
          deliveryDate: body.deliveryDate ? new Date(body.deliveryDate) : null,
          deliveryTimeSlot: body.deliveryTimeSlot,
          promoCode: body.promoCode?.toUpperCase(),
          note: body.note,
        },
      });

      // Order items yaratish
      await tx.orderItem.createMany({
        data: cartItems.map((item) => ({
          orderId: newOrder.id,
          productId: item.productId,
          shopId: item.product.shopId,
          name: item.product.name,
          price: item.product.price,
          quantity: item.quantity,
          imageUrl: item.product.images?.[0] || null,
        })),
      });

      // Stokni kamaytirish
      for (const item of cartItems) {
        await tx.product.update({
          where: { id: item.productId },
          data: { stock: { decrement: item.quantity } },
        });
      }

      // Savatni tozalash
      await tx.cartItem.deleteMany({ where: { userId } });

      // Status history
      await tx.orderStatusHistory.create({
        data: {
          orderId: newOrder.id,
          status: 'pending',
          changedBy: userId,
        },
      });

      // Promo usage
      if (body.promoCode) {
        const promo = await tx.promoCode.findFirst({
          where: { code: body.promoCode.toUpperCase() },
        });
        if (promo) {
          await tx.promoCodeUsage.create({
            data: { promoId: promo.id, userId },
          });
          await tx.promoCode.update({
            where: { id: promo.id },
            data: { currentUses: { increment: 1 } },
          });
        }
      }

      return newOrder;
    });

    // 6. Bildirishnomalar (transaction tashqarisida)
    // Vendorga: "Yangi buyurtma!"
    // Adminga: "Yangi buyurtma tushdi"
    await notifyOrderStatusChange(order.id, 'order_new');

    // 7. Javob
    const fullOrder = await prisma.order.findUnique({
      where: { id: order.id },
      include: {
        items: true,
        address: true,
      },
    });

    return reply.status(201).send({
      success: true,
      data: fullOrder,
    });
  });

  /**
   * GET /orders
   * Mijozning buyurtmalari ro'yxati
   */
  app.get('/orders', { preHandler: authMiddleware }, async (request, reply) => {
    const { status, page = '1', limit = '20' } = request.query as {
      status?: string;
      page?: string;
      limit?: string;
    };

    const where: any = { userId: request.user!.userId };
    if (status) where.status = status;

    const { page: pg, limit: lim, skip } = parsePagination({ page, limit });

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where,
        include: {
          items: {
            include: {
              shop: { select: { id: true, name: true, logoUrl: true } },
            },
          },
          address: true,
          courier: {
            include: {
              profile: {
                select: { id: true, fullName: true, phone: true, avatarUrl: true },
              },
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: lim,
      }),
      prisma.order.count({ where }),
    ]);

    return reply.send({
      success: true,
      data: {
        orders,
        pagination: paginationMeta(pg, lim, total),
      },
    });
  });

  /**
   * GET /orders/:id
   * Buyurtma tafsilotlari (mijoz)
   */
  app.get('/orders/:id', { preHandler: authMiddleware }, async (request, reply) => {
    const { id } = request.params as { id: string };

    const order = await prisma.order.findFirst({
      where: { id, userId: request.user!.userId },
      include: {
        items: {
          include: {
            shop: { select: { id: true, name: true, logoUrl: true, phone: true } },
          },
        },
        address: true,
        statusHistory: { orderBy: { createdAt: 'asc' } },
        courier: {
          include: {
            profile: {
              select: { id: true, fullName: true, phone: true, avatarUrl: true },
            },
          },
        },
        deliveryRating: true,
      },
    });

    if (!order) throw new NotFoundError('Buyurtma');

    return reply.send({ success: true, data: order });
  });

  /**
   * POST /orders/:id/cancel
   * Buyurtmani bekor qilish (mijoz)
   */
  app.post('/orders/:id/cancel', { preHandler: authMiddleware }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { reason } = (request.body as { reason?: string }) || {};

    const order = await prisma.order.findFirst({
      where: { id, userId: request.user!.userId },
    });

    if (!order) throw new NotFoundError('Buyurtma');

    // Faqat pending va confirmed holatlarda bekor qilish mumkin
    if (!['pending', 'confirmed'].includes(order.status)) {
      throw new AppError('Bu holatda buyurtmani bekor qilib bo\'lmaydi');
    }

    await prisma.$transaction(async (tx) => {
      // Status yangilash
      await tx.order.update({
        where: { id },
        data: {
          status: 'cancelled',
          cancelReason: reason || 'Mijoz tomonidan bekor qilindi',
          cancelledAt: new Date(),
        },
      });

      // Stokni qaytarish
      const items = await tx.orderItem.findMany({ where: { orderId: id } });
      for (const item of items) {
        await tx.product.update({
          where: { id: item.productId },
          data: { stock: { increment: item.quantity } },
        });
      }

      // Status history
      await tx.orderStatusHistory.create({
        data: {
          orderId: id,
          status: 'cancelled',
          note: reason,
          changedBy: request.user!.userId,
        },
      });
    });

    await notifyOrderStatusChange(id, 'order_cancelled', { cancelReason: reason });

    return reply.send({ success: true, message: 'Buyurtma bekor qilindi' });
  });

  // ============================================
  // VENDOR endpoints
  // ============================================

  /**
   * GET /vendor/orders
   * Vendorning barcha buyurtmalari
   */
  app.get(
    '/vendor/orders',
    { preHandler: [authMiddleware, requireRole('vendor', 'admin')] },
    async (request, reply) => {
      const { status, page = '1', limit = '20' } = request.query as {
        status?: string;
        page?: string;
        limit?: string;
      };

      // Vendorning do'konini topish
      const shop = await prisma.shop.findUnique({
        where: { ownerId: request.user!.userId },
      });

      if (!shop) throw new AppError('Do\'kon topilmadi');

      const where: any = {
        items: { some: { shopId: shop.id } },
      };
      if (status) where.status = status;

      const skip = (parseInt(page) - 1) * parseInt(limit);

      const [orders, total] = await Promise.all([
        prisma.order.findMany({
          where,
          include: {
            items: { where: { shopId: shop.id } },
            user: {
              select: { id: true, fullName: true, phone: true },
            },
            address: true,
            courier: {
              include: {
                profile: {
                  select: { id: true, fullName: true, phone: true },
                },
              },
            },
          },
          orderBy: { createdAt: 'desc' },
          skip,
          take: parseInt(limit),
        }),
        prisma.order.count({ where }),
      ]);

      return reply.send({
        success: true,
        data: { orders, total },
      });
    },
  );

  /**
   * PUT /vendor/orders/:id/status
   * Vendor buyurtma statusini yangilash
   * 
   * FLOW:
   * pending → confirmed (Vendor qabul qildi)
   * confirmed → processing (Vendor tayyorlayapti)
   * processing → ready_for_pickup (Tayyor - kuryerga berish)
   */
  app.put(
    '/vendor/orders/:id/status',
    { preHandler: [authMiddleware, requireRole('vendor', 'admin')] },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const body = updateStatusSchema.parse(request.body);

      // Vendorning do'konini topish
      const shop = await prisma.shop.findUnique({
        where: { ownerId: request.user!.userId },
      });

      if (!shop) throw new AppError('Do\'kon topilmadi');

      // Buyurtmani tekshirish
      const order = await prisma.order.findFirst({
        where: {
          id,
          items: { some: { shopId: shop.id } },
        },
      });

      if (!order) throw new NotFoundError('Buyurtma');

      // Status o'tishini tekshirish
      if (!isValidTransition(order.status, body.status)) {
        throw new AppError(
          `"${order.status}" holatidan "${body.status}" holatiga o'tish mumkin emas`,
        );
      }

      // Vendor faqat o'z bosqichlarigacha o'zgartira oladi
      const vendorAllowed = ['confirmed', 'processing', 'ready_for_pickup', 'cancelled'];
      if (!vendorAllowed.includes(body.status)) {
        throw new AppError('Vendor bu statusni o\'zgartira olmaydi');
      }

      // Status yangilash
      const timestamps: Record<string, Date> = {};
      if (body.status === 'confirmed') timestamps.confirmedAt = new Date();
      if (body.status === 'ready_for_pickup') timestamps.readyAt = new Date();
      if (body.status === 'cancelled') timestamps.cancelledAt = new Date();

      await prisma.$transaction(async (tx) => {
        await tx.order.update({
          where: { id },
          data: {
            status: body.status as any,
            cancelReason: body.cancelReason,
            ...timestamps,
          },
        });

        await tx.orderStatusHistory.create({
          data: {
            orderId: id,
            status: body.status as any,
            note: body.cancelReason,
            changedBy: request.user!.userId,
          },
        });

        // Bekor qilishda stokni qaytarish
        if (body.status === 'cancelled') {
          const items = await tx.orderItem.findMany({ where: { orderId: id } });
          for (const item of items) {
            await tx.product.update({
              where: { id: item.productId },
              data: { stock: { increment: item.quantity } },
            });
          }
        }
      });

      // Bildirishnomalar
      await notifyOrderStatusChange(id, body.status, {
        cancelReason: body.cancelReason,
      });

      // MUHIM: Agar "ready_for_pickup" bo'lsa → kuryer izlash boshlash!
      if (body.status === 'ready_for_pickup' && order.deliveryMethod === 'courier') {
        // Eng yaqin kuryerni topish va tayinlash
        findAndAssignCourier(id).catch((err) =>
          console.error('Courier assignment error:', err),
        );
      }

      return reply.send({
        success: true,
        message: `Buyurtma statusi "${body.status}" ga o'zgartirildi`,
      });
    },
  );

  // ============================================
  // RATING (baholash)
  // ============================================

  /**
   * POST /orders/:id/rate
   * Yetkazib berishni baholash
   */
  app.post('/orders/:id/rate', { preHandler: authMiddleware }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { rating, comment } = request.body as { rating: number; comment?: string };

    if (!rating || rating < 1 || rating > 5) {
      throw new AppError('Baho 1 dan 5 gacha bo\'lishi kerak');
    }

    const order = await prisma.order.findFirst({
      where: { id, userId: request.user!.userId, status: 'delivered' },
    });

    if (!order) throw new AppError('Buyurtma topilmadi yoki hali yetkazilmagan');
    if (!order.courierId) throw new AppError('Bu buyurtmada kuryer yo\'q');

    // Oldingi baho bormi?
    const existing = await prisma.deliveryRating.findUnique({
      where: { orderId: id },
    });
    if (existing) throw new AppError('Siz allaqachon baholagansiz');

    // Baho yaratish
    await prisma.deliveryRating.create({
      data: {
        orderId: id,
        courierId: order.courierId,
        userId: request.user!.userId,
        rating,
        comment,
      },
    });

    // Kuryer ratingini yangilash
    const avgRating = await prisma.deliveryRating.aggregate({
      where: { courierId: order.courierId },
      _avg: { rating: true },
    });

    await prisma.courier.update({
      where: { id: order.courierId },
      data: { rating: avgRating._avg.rating || 5 },
    });

    return reply.send({ success: true, message: 'Rahmat! Bahoyingiz qabul qilindi' });
  });
}
