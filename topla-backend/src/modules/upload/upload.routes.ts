import { FastifyInstance, FastifyRequest } from 'fastify';
import multipart from '@fastify/multipart';
import { writeFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import path from 'path';
import { randomUUID } from 'crypto';
import { authMiddleware } from '../../middleware/auth.js';
import { env } from '../../config/env.js';
import { uploadFile, getStorageClient } from '../../config/storage.js';

/**
 * File Upload routes
 * POST /upload/image - Upload a single image
 * POST /upload/images - Upload multiple images (max 10)
 */
export async function uploadRoutes(app: FastifyInstance): Promise<void> {
  // Register multipart support
  await app.register(multipart, {
    limits: {
      fileSize: 10 * 1024 * 1024, // 10MB
      files: 10,
    },
  });

  // Local uploads directory (development fallback)
  const UPLOADS_DIR = path.join(process.cwd(), 'uploads');

  /**
   * Upload single image
   * POST /upload/image
   * Body: multipart/form-data with field "file" and optional "folder" text field
   */
  app.post('/upload/image', {
    preHandler: [authMiddleware],
  }, async (request: FastifyRequest, reply) => {
    const data = await request.file();
    if (!data) {
      return reply.status(400).send({ error: 'No file uploaded' });
    }

    // Validate type
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    if (!allowedTypes.includes(data.mimetype)) {
      return reply.status(400).send({
        error: 'Invalid file type. Allowed: jpeg, png, webp, gif',
      });
    }

    const buffer = await data.toBuffer();
    const ext = data.mimetype.split('/')[1] === 'jpeg' ? 'jpg' : data.mimetype.split('/')[1];
    const fileName = `${randomUUID()}.${ext}`;

    // Get folder from fields (if sent before file in multipart)
    const rawFolder = (data.fields as any)?.folder?.value as string || 'general';
    // Sanitize folder: only allow alphanumeric, dash, underscore — prevent path traversal
    const folder = rawFolder.replace(/\.\.+/g, '').replace(/[^a-zA-Z0-9_\-\/]/g, '').replace(/^\/+/, '');
    const filePath = `${folder}/${fileName}`;

    try {
      let url: string;

      if (getStorageClient()) {
        // S3/MinIO upload
        const bucket = folder.startsWith('shop') ? env.S3_BUCKET_SHOPS
          : folder.startsWith('product') ? env.S3_BUCKET_PRODUCTS
          : folder.startsWith('avatar') ? env.S3_BUCKET_AVATARS
          : env.S3_BUCKET_PRODUCTS;

        url = await uploadFile(bucket, filePath, buffer, data.mimetype);
      } else {
        // Local file system (development)
        const dir = path.join(UPLOADS_DIR, folder);
        if (!existsSync(dir)) {
          await mkdir(dir, { recursive: true });
        }
        await writeFile(path.join(dir, fileName), buffer);
        url = `http://localhost:${env.PORT}/uploads/${folder}/${fileName}`;
      }

      return { url, fileName: filePath, size: buffer.length };
    } catch (error: any) {
      request.log.error(error, 'File upload failed');
      return reply.status(500).send({ error: 'File upload failed' });
    }
  });

  /**
   * Upload multiple images
   * POST /upload/images
   * Body: multipart/form-data with multiple "files" fields and optional "folder"
   */
  app.post('/upload/images', {
    preHandler: [authMiddleware],
  }, async (request: FastifyRequest, reply) => {
    const parts = request.parts();
    const results: Array<{ url: string; fileName: string; size: number }> = [];
    let folder = 'general';
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

    for await (const part of parts) {
      if (part.type === 'field') {
        if (part.fieldname === 'folder') {
          folder = (part as any).value as string || 'general';
        }
        continue;
      }

      // File part
      if (!allowedTypes.includes(part.mimetype)) {
        continue; // Skip invalid files
      }

      const buffer = await part.toBuffer();
      const ext = part.mimetype.split('/')[1] === 'jpeg' ? 'jpg' : part.mimetype.split('/')[1];
      const fileName = `${randomUUID()}.${ext}`;
      const filePath = `${folder}/${fileName}`;

      try {
        let url: string;

        if (getStorageClient()) {
          const bucket = folder.startsWith('shop') ? env.S3_BUCKET_SHOPS
            : folder.startsWith('product') ? env.S3_BUCKET_PRODUCTS
            : folder.startsWith('avatar') ? env.S3_BUCKET_AVATARS
            : env.S3_BUCKET_PRODUCTS;

          url = await uploadFile(bucket, filePath, buffer, part.mimetype);
        } else {
          const dir = path.join(UPLOADS_DIR, folder);
          if (!existsSync(dir)) {
            await mkdir(dir, { recursive: true });
          }
          await writeFile(path.join(dir, fileName), buffer);
          url = `http://localhost:${env.PORT}/uploads/${folder}/${fileName}`;
        }

        results.push({ url, fileName: filePath, size: buffer.length });
      } catch (error: any) {
        request.log.error(error, `Failed to upload ${part.filename}`);
      }
    }

    if (results.length === 0) {
      return reply.status(400).send({ error: 'No valid files uploaded' });
    }

    return { files: results, count: results.length };
  });
}
