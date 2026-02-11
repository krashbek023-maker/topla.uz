import { FastifyReply, FastifyRequest } from 'fastify';

/**
 * Global error handler
 */
export function errorHandler(
  error: Error & { statusCode?: number; validation?: any },
  request: FastifyRequest,
  reply: FastifyReply,
): void {
  const statusCode = error.statusCode || 500;

  // Validation errors (Zod/Fastify)
  if (error.validation) {
    reply.status(400).send({
      error: 'Validation Error',
      message: 'Noto\'g\'ri ma\'lumot kiritildi',
      details: error.validation,
    });
    return;
  }

  // Known errors
  if (statusCode < 500) {
    reply.status(statusCode).send({
      error: error.name || 'Error',
      message: error.message,
    });
    return;
  }

  // Server errors — log but don't expose details
  console.error(`[ERROR] ${request.method} ${request.url}:`, error);
  reply.status(500).send({
    error: 'Internal Server Error',
    message: 'Serverda xatolik yuz berdi. Iltimos qayta urinib ko\'ring.',
  });
}

/**
 * Custom application error
 */
export class AppError extends Error {
  statusCode: number;

  constructor(message: string, statusCode = 400) {
    super(message);
    this.statusCode = statusCode;
    this.name = 'AppError';
  }
}

export class NotFoundError extends AppError {
  constructor(resource = 'Resurs') {
    super(`${resource} topilmadi`, 404);
    this.name = 'NotFoundError';
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Avtorizatsiya talab qilinadi') {
    super(message, 401);
    this.name = 'UnauthorizedError';
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Ruxsat yo\'q') {
    super(message, 403);
    this.name = 'ForbiddenError';
  }
}
