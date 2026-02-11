import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../config/database.js';
import { authMiddleware, requireRole } from '../../middleware/auth.js';

const createBannerSchema = z.object({
  imageUrl: z.string().url(),
  titleUz: z.string().optional(),
  titleRu: z.string().optional(),
  subtitleUz: z.string().optional(),
  subtitleRu: z.string().optional(),
  actionType: z.enum(['none', 'link', 'product', 'category']).default('none'),
  actionValue: z.string().optional(),
  sortOrder: z.number().int().default(0),
  isActive: z.boolean().default(true),
});

export async function bannerRoutes(app: FastifyInstance): Promise<void> {

  app.get('/banners', async (request, reply) => {
    const banners = await prisma.banner.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });
    return reply.send({ success: true, data: banners });
  });

  // Admin
  app.post(
    '/admin/banners',
    { preHandler: [authMiddleware, requireRole('admin')] },
    async (request, reply) => {
      const body = createBannerSchema.parse(request.body);
      const banner = await prisma.banner.create({ data: body as any });
      return reply.status(201).send({ success: true, data: banner });
    },
  );

  app.delete(
    '/admin/banners/:id',
    { preHandler: [authMiddleware, requireRole('admin')] },
    async (request, reply) => {
      await prisma.banner.delete({ where: { id: (request.params as { id: string }).id } });
      return reply.send({ success: true });
    },
  );
}
