import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import bcrypt from 'bcryptjs';
import { prisma } from '../../config/database.js';
import { verifyFirebaseToken } from '../../config/firebase.js';
import { generateToken, generateRefreshToken, verifyToken, verifyRefreshToken } from '../../utils/jwt.js';
import { authMiddleware } from '../../middleware/auth.js';
import { AppError } from '../../middleware/error.js';
import { env } from '../../config/env.js';
import { sendOtp, verifyOtp, getOtpForTesting, isTelegramConfigured, type OtpChannel } from '../../services/otp.service.js';

// ============================================
// Validation Schemas
// ============================================

const loginSchema = z.object({
  firebaseToken: z.string().min(1, 'Firebase token kerak'),
  phone: z.string().min(9, 'Telefon raqam noto\'g\'ri'),
  fcmToken: z.string().optional(),
  platform: z.enum(['android', 'ios', 'web']).default('android'),
});

const updateProfileSchema = z.object({
  fullName: z.string().min(2).max(100).optional(),
  email: z.string().email().optional(),
  avatarUrl: z.string().url().optional(),
  language: z.enum(['uz', 'ru']).optional(),
});

const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1),
});

const vendorRegisterSchema = z.object({
  email: z.string().email('Email noto\'g\'ri'),
  password: z.string().min(6, 'Kamida 6 ta belgi kerak'),
  fullName: z.string().min(2, 'Ism kerak'),
  phone: z.string().min(9, 'Telefon raqam noto\'g\'ri'),
  shopName: z.string().min(2, 'Do\'kon nomi kerak'),
  shopDescription: z.string().optional(),
  shopAddress: z.string().optional(),
  shopPhone: z.string().optional(),
});

const vendorLoginSchema = z.object({
  email: z.string().email('Email noto\'g\'ri'),
  password: z.string().min(1, 'Parol kerak'),
});

const resetPasswordSchema = z.object({
  email: z.string().email('Email noto\'g\'ri'),
});

const googleLoginSchema = z.object({
  firebaseToken: z.string().min(1, 'Firebase token kerak'),
  fcmToken: z.string().optional(),
  platform: z.enum(['android', 'ios', 'web']).default('android'),
});

// === OTP Schemas ===
const sendOtpSchema = z.object({
  phone: z.string().min(9, 'Telefon raqam noto\'g\'ri'),
  channel: z.enum(['sms', 'telegram']).default('sms'),
});

const verifyOtpSchema = z.object({
  phone: z.string().min(9, 'Telefon raqam noto\'g\'ri'),
  code: z.string().min(4, 'Kod kerak').max(6),
  fcmToken: z.string().optional(),
  platform: z.enum(['android', 'ios', 'web']).default('android'),
});

// ============================================
// Routes
// ============================================

export async function authRoutes(app: FastifyInstance): Promise<void> {

  // ============================================
  // DUAL CHANNEL OTP (Telegram + Eskiz SMS)
  // ============================================

  /**
   * POST /auth/send-otp
   * OTP yuborish — Telegram yoki SMS orqali
   */
  app.post('/auth/send-otp', async (request, reply) => {
    const body = sendOtpSchema.parse(request.body);
    const phone = body.phone.startsWith('+998')
      ? body.phone
      : body.phone.startsWith('998')
        ? `+${body.phone}`
        : `+998${body.phone}`;

    const channel: OtpChannel = body.channel || 'sms';
    const result = await sendOtp(phone, channel);

    if (!result.success) {
      throw new AppError(result.error || 'OTP yuborib bo\'lmadi', 429);
    }

    // Dev mode: OTP'ni faqat server logga yozish (responsga HECH QACHON bermang!)
    if (env.NODE_ENV !== 'production') {
      const devOtp = getOtpForTesting(phone);
      if (devOtp) {
        console.log(`[DEV] OTP for ${phone}: ${devOtp}`);
      }
    }

    const channelMessage = result.channel === 'telegram'
      ? 'Telegram orqali kod yuborildi'
      : 'SMS kod yuborildi';

    return reply.send({
      success: true,
      data: {
        phone,
        channel: result.channel,
        telegramAvailable: isTelegramConfigured(),
      },
      message: channelMessage,
    });
  });

  /**
   * POST /auth/verify-otp
   * OTP tekshirish va JWT token berish
   */
  app.post('/auth/verify-otp', async (request, reply) => {
    const body = verifyOtpSchema.parse(request.body);
    const phone = body.phone.startsWith('+998')
      ? body.phone
      : body.phone.startsWith('998')
        ? `+${body.phone}`
        : `+998${body.phone}`;

    // 1. OTP tekshirish
    const otpResult = verifyOtp(phone, body.code);
    if (!otpResult.valid) {
      throw new AppError(otpResult.error || 'Noto\'g\'ri kod', 401);
    }

    // 2. Profilni topish yoki yaratish
    let profile = await prisma.profile.findUnique({
      where: { phone },
    });

    if (!profile) {
      // Yangi foydalanuvchi
      profile = await prisma.profile.create({
        data: {
          phone,
          fcmToken: body.fcmToken || null,
        },
      });
    } else {
      // FCM tokenni yangilash
      if (body.fcmToken) {
        profile = await prisma.profile.update({
          where: { id: profile.id },
          data: { fcmToken: body.fcmToken },
        });
      }
    }

    // 3. FCM device saqlash
    if (body.fcmToken) {
      await prisma.userDevice.upsert({
        where: {
          userId_fcmToken: {
            userId: profile.id,
            fcmToken: body.fcmToken,
          },
        },
        update: { isActive: true, platform: body.platform },
        create: {
          userId: profile.id,
          fcmToken: body.fcmToken,
          platform: body.platform,
        },
      });
    }

    // 4. JWT token yaratish
    const tokenPayload = {
      userId: profile.id,
      role: profile.role,
      phone: profile.phone,
    };

    const accessToken = generateToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    return reply.send({
      success: true,
      data: {
        user: {
          id: profile.id,
          phone: profile.phone,
          fullName: profile.fullName,
          email: profile.email,
          avatarUrl: profile.avatarUrl,
          role: profile.role,
          language: profile.language,
        },
        accessToken,
        refreshToken,
      },
    });
  });

  // ============================================
  // FIREBASE AUTH (Legacy — backward compatibility)
  // ============================================

  /**
   * POST /auth/login
   * Firebase OTP orqali kirish. Yangi foydalanuvchi bo'lsa yaratadi.
   */
  app.post('/auth/login', async (request, reply) => {
    const body = loginSchema.parse(request.body);

    // 1. Firebase token tekshirish
    let firebaseUser;
    try {
      firebaseUser = await verifyFirebaseToken(body.firebaseToken);
    } catch (error) {
      throw new AppError('Firebase token yaroqsiz', 401);
    }

    // 2. Profilni topish yoki yaratish
    let profile = await prisma.profile.findUnique({
      where: { phone: body.phone },
    });

    if (!profile) {
      // Yangi foydalanuvchi
      profile = await prisma.profile.create({
        data: {
          phone: body.phone,
          firebaseUid: firebaseUser.uid,
          fcmToken: body.fcmToken || null,
        },
      });
    } else {
      // Mavjud foydalanuvchi - Firebase UID va FCM tokenni yangilash
      profile = await prisma.profile.update({
        where: { id: profile.id },
        data: {
          firebaseUid: firebaseUser.uid,
          fcmToken: body.fcmToken || profile.fcmToken,
        },
      });
    }

    // 3. FCM token qurilmaga saqlash
    if (body.fcmToken) {
      await prisma.userDevice.upsert({
        where: {
          userId_fcmToken: {
            userId: profile.id,
            fcmToken: body.fcmToken,
          },
        },
        update: { isActive: true, platform: body.platform },
        create: {
          userId: profile.id,
          fcmToken: body.fcmToken,
          platform: body.platform,
        },
      });
    }

    // 4. JWT token yaratish
    const tokenPayload = {
      userId: profile.id,
      role: profile.role,
      phone: profile.phone,
    };

    const accessToken = generateToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    return reply.send({
      success: true,
      data: {
        user: {
          id: profile.id,
          phone: profile.phone,
          fullName: profile.fullName,
          email: profile.email,
          avatarUrl: profile.avatarUrl,
          role: profile.role,
          language: profile.language,
        },
        accessToken,
        refreshToken,
      },
    });
  });

  /**
   * POST /auth/refresh
   * Token yangilash
   */
  app.post('/auth/refresh', async (request, reply) => {
    const body = refreshTokenSchema.parse(request.body);

    try {
      const payload = verifyRefreshToken(body.refreshToken);

      // Profil hali ham borligini tekshirish
      const profile = await prisma.profile.findUnique({
        where: { id: payload.userId },
      });

      if (!profile || profile.status === 'blocked') {
        throw new AppError('Foydalanuvchi topilmadi yoki bloklangan', 401);
      }

      const newPayload = {
        userId: profile.id,
        role: profile.role,
        phone: profile.phone,
      };

      return reply.send({
        success: true,
        data: {
          accessToken: generateToken(newPayload),
          refreshToken: generateRefreshToken(newPayload),
        },
      });
    } catch {
      throw new AppError('Refresh token yaroqsiz', 401);
    }
  });

  /**
   * GET /auth/me
   * Joriy foydalanuvchi ma'lumotlari
   */
  app.get('/auth/me', { preHandler: authMiddleware }, async (request, reply) => {
    const profile = await prisma.profile.findUnique({
      where: { id: request.user!.userId },
      include: {
        shop: true,
        courier: true,
        addresses: { orderBy: { isDefault: 'desc' } },
      },
    });

    if (!profile) {
      throw new AppError('Profil topilmadi', 404);
    }

    return reply.send({
      success: true,
      data: {
        id: profile.id,
        phone: profile.phone,
        fullName: profile.fullName,
        email: profile.email,
        avatarUrl: profile.avatarUrl,
        role: profile.role,
        language: profile.language,
        status: profile.status,
        shop: profile.shop,
        courier: profile.courier,
        addresses: profile.addresses,
      },
    });
  });

  /**
   * PUT /auth/profile
   * Profilni yangilash
   */
  app.put('/auth/profile', { preHandler: authMiddleware }, async (request, reply) => {
    const body = updateProfileSchema.parse(request.body);

    const profile = await prisma.profile.update({
      where: { id: request.user!.userId },
      data: body,
    });

    return reply.send({
      success: true,
      data: profile,
    });
  });

  /**
   * POST /auth/fcm-token
   * FCM tokenni yangilash
   */
  app.post('/auth/fcm-token', { preHandler: authMiddleware }, async (request, reply) => {
    const { fcmToken, platform } = request.body as { fcmToken: string; platform?: string };

    if (!fcmToken) {
      throw new AppError('FCM token kerak');
    }

    // Profile va device ni yangilash
    await Promise.all([
      prisma.profile.update({
        where: { id: request.user!.userId },
        data: { fcmToken },
      }),
      prisma.userDevice.upsert({
        where: {
          userId_fcmToken: {
            userId: request.user!.userId,
            fcmToken,
          },
        },
        update: { isActive: true },
        create: {
          userId: request.user!.userId,
          fcmToken,
          platform: platform || 'android',
        },
      }),
    ]);

    return reply.send({ success: true });
  });

  /**
   * POST /auth/logout
   * Chiqish - FCM tokenni o'chirish
   */
  app.post('/auth/logout', { preHandler: authMiddleware }, async (request, reply) => {
    const { fcmToken } = (request.body as { fcmToken?: string }) || {};

    const updates: Promise<any>[] = [
      prisma.profile.update({
        where: { id: request.user!.userId },
        data: { fcmToken: null },
      }),
    ];

    if (fcmToken) {
      updates.push(
        prisma.userDevice.updateMany({
          where: { userId: request.user!.userId, fcmToken },
          data: { isActive: false },
        }),
      );
    }

    await Promise.all(updates);

    return reply.send({ success: true });
  });

  // ============================================
  // VENDOR: Email + Password Authentication
  // ============================================

  /**
   * POST /auth/vendor/register
   * Vendor ro'yxatdan o'tishi (email + parol)
   */
  app.post('/auth/vendor/register', async (request, reply) => {
    const body = vendorRegisterSchema.parse(request.body);

    // Email band emasligini tekshirish
    const existing = await prisma.profile.findFirst({
      where: {
        OR: [
          { email: body.email },
          { phone: body.phone },
        ],
      },
    });

    if (existing) {
      if (existing.email === body.email) {
        throw new AppError('Bu email allaqachon ro\'yxatdan o\'tgan');
      }
      throw new AppError('Bu telefon raqam allaqachon ro\'yxatdan o\'tgan');
    }

    // Parolni hashlash
    const passwordHash = await bcrypt.hash(body.password, 12);

    // Profile + Shop yaratish
    const result = await prisma.$transaction(async (tx) => {
      const profile = await tx.profile.create({
        data: {
          email: body.email,
          phone: body.phone,
          fullName: body.fullName,
          passwordHash,
          role: 'vendor',
        },
      });

      const shop = await tx.shop.create({
        data: {
          name: body.shopName,
          description: body.shopDescription,
          address: body.shopAddress,
          phone: body.shopPhone || body.phone,
          ownerId: profile.id,
          status: 'pending', // Admin tasdiqlashi kerak
        },
      });

      return { profile, shop };
    });

    // JWT token yaratish
    const tokenPayload = {
      userId: result.profile.id,
      role: result.profile.role,
      phone: result.profile.phone,
    };

    const accessToken = generateToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    return reply.status(201).send({
      success: true,
      data: {
        user: {
          id: result.profile.id,
          phone: result.profile.phone,
          fullName: result.profile.fullName,
          email: result.profile.email,
          role: result.profile.role,
        },
        shop: result.shop,
        accessToken,
        refreshToken,
      },
    });
  });

  /**
   * POST /auth/vendor/login
   * Vendor kirish (email + parol)
   */
  app.post('/auth/vendor/login', async (request, reply) => {
    const body = vendorLoginSchema.parse(request.body);

    // Profilni email orqali topish
    const profile = await prisma.profile.findFirst({
      where: { email: body.email },
      include: { shop: true },
    });

    if (!profile || !profile.passwordHash) {
      throw new AppError('Email yoki parol noto\'g\'ri', 401);
    }

    // Parolni tekshirish
    const isValid = await bcrypt.compare(body.password, profile.passwordHash);
    if (!isValid) {
      throw new AppError('Email yoki parol noto\'g\'ri', 401);
    }

    // Bloklangan emasmi?
    if (profile.status === 'blocked') {
      throw new AppError('Hisobingiz bloklangan. Admin bilan bog\'laning.', 403);
    }

    // JWT generatsiya
    const tokenPayload = {
      userId: profile.id,
      role: profile.role,
      phone: profile.phone,
    };

    const accessToken = generateToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    return reply.send({
      success: true,
      data: {
        user: {
          id: profile.id,
          phone: profile.phone,
          fullName: profile.fullName,
          email: profile.email,
          avatarUrl: profile.avatarUrl,
          role: profile.role,
          language: profile.language,
        },
        shop: profile.shop,
        accessToken,
        refreshToken,
      },
    });
  });

  /**
   * POST /auth/reset-password
   * Parol tiklash (email orqali)
   */
  app.post('/auth/reset-password', async (request, reply) => {
    const body = resetPasswordSchema.parse(request.body);

    const profile = await prisma.profile.findFirst({
      where: { email: body.email },
    });

    // Xavfsizlik uchun har doim "yuborildi" deb javob beramiz
    if (!profile) {
      return reply.send({
        success: true,
        message: 'Agar email mavjud bo\'lsa, tiklash ko\'rsatmalari yuboriladi',
      });
    }

    // TODO: Email xizmati ulanganda:
    // 1. UUID token yaratish
    // 2. Bazaga saqlash (reset_token, reset_token_expires)
    // 3. Email yuborish
    // Hozircha log qilib qo'yamiz — production'da email service ulanadi
    console.log(`[Auth] Password reset requested for: ${body.email} (user: ${profile.id})`);
    // Future: await emailService.sendPasswordReset(profile.email, resetToken);

    return reply.send({
      success: true,
      message: 'Agar email mavjud bo\'lsa, tiklash ko\'rsatmalari yuboriladi',
    });
  });

  /**
   * POST /auth/google
   * Google Sign-In orqali kirish. Firebase token qabul qiladi.
   * Yangi foydalanuvchi bo'lsa yaratadi.
   */
  app.post('/auth/google', async (request, reply) => {
    const body = googleLoginSchema.parse(request.body);

    // 1. Firebase token tekshirish
    let firebaseUser;
    try {
      firebaseUser = await verifyFirebaseToken(body.firebaseToken);
    } catch (error) {
      console.error('Firebase token verification error:', error);
      throw new AppError('Firebase token yaroqsiz', 401);
    }

    const email = firebaseUser.email;
    const name = firebaseUser.name || firebaseUser.displayName || '';
    const picture = firebaseUser.picture || '';
    const phone = firebaseUser.phone_number || '';

    // 2. Profilni topish - avval firebaseUid, keyin email bo'yicha
    let profile = await prisma.profile.findFirst({
      where: {
        OR: [
          { firebaseUid: firebaseUser.uid },
          ...(email ? [{ email }] : []),
        ],
      },
    });

    if (!profile) {
      // phone maydoni majburiy va unique, Google foydalanuvchilarda telefon yo'q bo'lishi mumkin
      // Shuning uchun vaqtincha unique placeholder yaratamiz
      const tempPhone = phone || `google_${firebaseUser.uid}`;

      // Yangi foydalanuvchi yaratish
      profile = await prisma.profile.create({
        data: {
          firebaseUid: firebaseUser.uid,
          email: email || null,
          fullName: name || null,
          avatarUrl: picture || null,
          phone: tempPhone,
          fcmToken: body.fcmToken || null,
        },
      });
    } else {
      // Mavjud foydalanuvchini yangilash
      profile = await prisma.profile.update({
        where: { id: profile.id },
        data: {
          firebaseUid: firebaseUser.uid,
          ...(email && !profile.email ? { email } : {}),
          ...(name && !profile.fullName ? { fullName: name } : {}),
          ...(picture && !profile.avatarUrl ? { avatarUrl: picture } : {}),
          fcmToken: body.fcmToken || profile.fcmToken,
        },
      });
    }

    // 3. FCM token saqlash
    if (body.fcmToken) {
      await prisma.userDevice.upsert({
        where: {
          userId_fcmToken: {
            userId: profile.id,
            fcmToken: body.fcmToken,
          },
        },
        update: { isActive: true, platform: body.platform },
        create: {
          userId: profile.id,
          fcmToken: body.fcmToken,
          platform: body.platform,
        },
      });
    }

    // 4. JWT token yaratish
    const tokenPayload = {
      userId: profile.id,
      role: profile.role,
      phone: profile.phone,
    };

    const accessToken = generateToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    return reply.send({
      success: true,
      data: {
        user: {
          id: profile.id,
          phone: profile.phone,
          fullName: profile.fullName,
          email: profile.email,
          avatarUrl: profile.avatarUrl,
          role: profile.role,
          language: profile.language,
        },
        accessToken,
        refreshToken,
      },
    });
  });
}
