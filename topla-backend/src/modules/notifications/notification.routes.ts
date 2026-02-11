import { FastifyInstance } from 'fastify';
import { prisma } from '../../config/database.js';
import { authMiddleware } from '../../middleware/auth.js';

export async function notificationRoutes(app: FastifyInstance): Promise<void> {
  /**
   * GET /notifications
   * Foydalanuvchining barcha bildirishnomalarini olish
   */
  app.get('/notifications', { preHandler: authMiddleware }, async (request, reply) => {
    const { page = '1', limit = '20' } = request.query as { page?: string; limit?: string };
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [notifications, total, unreadCount] = await Promise.all([
      prisma.notification.findMany({
        where: { userId: request.user!.userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: parseInt(limit),
      }),
      prisma.notification.count({
        where: { userId: request.user!.userId },
      }),
      prisma.notification.count({
        where: { userId: request.user!.userId, isRead: false },
      }),
    ]);

    return reply.send({
      success: true,
      data: {
        notifications,
        unreadCount,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          totalPages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  });

  /**
   * PUT /notifications/:id/read
   * Bildirishnomani o'qilgan deb belgilash
   */
  app.put('/notifications/:id/read', { preHandler: authMiddleware }, async (request, reply) => {
    const { id } = request.params as { id: string };

    await prisma.notification.update({
      where: { id, userId: request.user!.userId },
      data: { isRead: true },
    });

    return reply.send({ success: true });
  });

  /**
   * PUT /notifications/read-all
   * Barcha bildirishnomalarni o'qilgan deb belgilash
   */
  app.put('/notifications/read-all', { preHandler: authMiddleware }, async (request, reply) => {
    await prisma.notification.updateMany({
      where: { userId: request.user!.userId, isRead: false },
      data: { isRead: true },
    });

    return reply.send({ success: true });
  });

  /**
   * GET /notifications/unread-count
   * O'qilmagan bildirishnomalar soni
   */
  app.get('/notifications/unread-count', { preHandler: authMiddleware }, async (request, reply) => {
    const count = await prisma.notification.count({
      where: { userId: request.user!.userId, isRead: false },
    });

    return reply.send({ success: true, data: { count } });
  });
}
