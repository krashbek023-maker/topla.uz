import { Server as SocketIOServer, Socket } from 'socket.io';
import { Server as HttpServer } from 'http';
import { verifyToken } from '../utils/jwt.js';
import { prisma } from '../config/database.js';
import { env } from '../config/env.js';

let io: SocketIOServer | null = null;

// ============================================
// Active connections tracking
// ============================================

// orderId → Set<socketId> (mijozlar kuzatmoqda)
const orderWatchers = new Map<string, Set<string>>();

// courierId → socketId
const courierSockets = new Map<string, string>();

// userId → socketId
const userSockets = new Map<string, string>();

// ============================================
// Initialize WebSocket Server
// ============================================

export function initWebSocket(httpServer: HttpServer): SocketIOServer {
  io = new SocketIOServer(httpServer, {
    cors: {
      origin: env.CORS_ORIGINS.split(','),
      methods: ['GET', 'POST'],
    },
    path: '/ws',
    pingInterval: 25000,
    pingTimeout: 60000,
  });

  // Authentication middleware
  io.use(async (socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;

    if (!token) {
      return next(new Error('Token kerak'));
    }

    try {
      const payload = verifyToken(token as string);
      (socket as any).user = payload;
      next();
    } catch {
      next(new Error('Token yaroqsiz'));
    }
  });

  io.on('connection', (socket: Socket) => {
    const user = (socket as any).user;

    // Track user socket
    userSockets.set(user.userId, socket.id);

    // ============================================
    // KURYER events
    // ============================================

    if (user.role === 'courier') {
      handleCourierConnection(socket, user);
    }

    // ============================================
    // MIJOZ events — buyurtmani kuzatish
    // ============================================

    // Mijoz buyurtmani kuzata boshlaydi
    socket.on('track:order', (orderId: string) => {
      if (!orderWatchers.has(orderId)) {
        orderWatchers.set(orderId, new Set());
      }
      orderWatchers.get(orderId)!.add(socket.id);
      socket.join(`order:${orderId}`);
    });

    // Mijoz kuzatishni to'xtatdi
    socket.on('track:stop', (orderId: string) => {
      orderWatchers.get(orderId)?.delete(socket.id);
      socket.leave(`order:${orderId}`);
    });

    // ============================================
    // VENDOR events — buyurtmalarni kuzatish
    // ============================================

    socket.on('vendor:watch-orders', async () => {
      if (user.role !== 'vendor' && user.role !== 'admin') return;

      const shop = await prisma.shop.findUnique({
        where: { ownerId: user.userId },
        select: { id: true },
      });

      if (shop) {
        socket.join(`shop:${shop.id}`);
      }
    });

    // ============================================
    // DISCONNECT
    // ============================================

    socket.on('disconnect', () => {
      userSockets.delete(user.userId);

      // Kuryer disconnect
      if (user.role === 'courier') {
        const courierId = [...courierSockets.entries()].find(
          ([, sid]) => sid === socket.id,
        )?.[0];
        if (courierId) {
          courierSockets.delete(courierId);
        }
      }

      // Order watchers dan o'chirish
      for (const [orderId, watchers] of orderWatchers) {
        watchers.delete(socket.id);
        if (watchers.size === 0) {
          orderWatchers.delete(orderId);
        }
      }
    });
  });

  return io;
}

// ============================================
// Courier-specific handlers
// ============================================

function handleCourierConnection(socket: Socket, user: any): void {
  // Kuryerni track qilish
  socket.on('courier:online', async (courierId: string) => {
    // Tekshirish: courierId shu userga tegishlimi?
    const courier = await prisma.courier.findFirst({
      where: { id: courierId, profileId: user.userId },
    });
    if (!courier) {
      socket.emit('error', { message: 'Courier ID yaroqsiz' });
      return;
    }
    courierSockets.set(courierId, socket.id);
    socket.join(`courier:${courierId}`);
  });

  // GPS joylashuvni yangilash (har 5 soniya)
  socket.on(
    'courier:location',
    async (data: {
      courierId: string;
      orderId?: string;
      latitude: number;
      longitude: number;
      speed?: number;
      heading?: number;
    }) => {
      // Tekshirish: courierId shu userga tegishlimi?
      const courier = await prisma.courier.findFirst({
        where: { id: data.courierId, profileId: user.userId },
      });
      if (!courier) {
        socket.emit('error', { message: 'Courier ID yaroqsiz' });
        return;
      }

      // DB da yangilash
      await prisma.courier.update({
        where: { id: data.courierId },
        data: {
          currentLatitude: data.latitude,
          currentLongitude: data.longitude,
          lastLocationAt: new Date(),
        },
      });

      // Agar yetkazmoqda bo'lsa — tarix saqlash
      if (data.orderId) {
        await prisma.courierLocation.create({
          data: {
            courierId: data.courierId,
            latitude: data.latitude,
            longitude: data.longitude,
            speed: data.speed,
            heading: data.heading,
          },
        });

        // Buyurtmani kuzatayotgan mijozlarga yuborish
        emitToOrderWatchers(data.orderId, 'tracking:location', {
          courierId: data.courierId,
          latitude: data.latitude,
          longitude: data.longitude,
          speed: data.speed,
          heading: data.heading,
          timestamp: new Date().toISOString(),
        });
      }
    },
  );
}

// ============================================
// Emit functions (boshqa modullardan chaqirish uchun)
// ============================================

/**
 * Buyurtmani kuzatayotgan barcha mijozlarga event yuborish
 */
export function emitToOrderWatchers(
  orderId: string,
  event: string,
  data: any,
): void {
  if (!io) return;
  io.to(`order:${orderId}`).emit(event, data);
}

/**
 * Vendorga (do'kon egasiga) event yuborish
 */
export function emitToShop(shopId: string, event: string, data: any): void {
  if (!io) return;
  io.to(`shop:${shopId}`).emit(event, data);
}

/**
 * Kuryerga event yuborish
 */
export function emitToCourier(courierId: string, event: string, data: any): void {
  if (!io) return;
  const socketId = courierSockets.get(courierId);
  if (socketId) {
    io.to(socketId).emit(event, data);
  }
}

/**
 * Ma'lum bir foydalanuvchiga event yuborish
 */
export function emitToUser(userId: string, event: string, data: any): void {
  if (!io) return;
  const socketId = userSockets.get(userId);
  if (socketId) {
    io.to(socketId).emit(event, data);
  }
}

/**
 * Buyurtma status o'zgarganda — real-time yangilash
 */
export function emitOrderStatusUpdate(
  orderId: string,
  status: string,
  extra?: Record<string, any>,
): void {
  emitToOrderWatchers(orderId, 'order:status-changed', {
    orderId,
    status,
    timestamp: new Date().toISOString(),
    ...extra,
  });
}

/**
 * Vendorga yangi buyurtma keldi — real-time
 */
export function emitNewOrderToVendor(shopId: string, order: any): void {
  emitToShop(shopId, 'order:new', {
    order,
    timestamp: new Date().toISOString(),
  });
}

/**
 * Kuryerga yangi yetkazma taklifi — real-time
 */
export function emitDeliveryOfferToCourier(
  courierId: string,
  offer: {
    orderId: string;
    orderNumber: string;
    shopName: string;
    shopAddress: string;
    deliveryAddress: string;
    distanceKm: number;
    estimatedMinutes: number;
    deliveryFee: number;
    expiresAt: string;
  },
): void {
  emitToCourier(courierId, 'delivery:offer', offer);
}

export function getIO(): SocketIOServer | null {
  return io;
}
