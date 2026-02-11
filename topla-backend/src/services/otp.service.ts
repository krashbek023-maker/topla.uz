/**
 * OTP Service — Dual Channel (Telegram Gateway + Eskiz SMS)
 *
 * In-memory store (keyinroq Redis'ga ko'chirish mumkin)
 * - 4 xonali tasodifiy kod
 * - 2 daqiqa (120 soniya) TTL
 * - Maksimum 3 ta urinish
 * - Rate limiting: 1 daqiqada 1 ta
 *
 * Kanallar:
 * - telegram: Telegram Gateway API (rasmiy, bot kerak emas!)
 * - sms: Eskiz orqali (95 so'm/sms)
 */

import { env } from '../config/env.js';
import { randomInt } from 'crypto';
import { sendSmsViaEskiz } from '../config/eskiz.js';
import { sendOtpViaTelegram, isTelegramGatewayConfigured } from '../config/telegram.js';

export type OtpChannel = 'sms' | 'telegram';

interface OtpEntry {
  code: string;
  phone: string;
  attempts: number;
  createdAt: number;
  expiresAt: number;
  verified?: boolean; // Kod tasdiqlangan, lekin hali o'chirilmagan
}

// In-memory OTP store: phone -> OtpEntry
const otpStore = new Map<string, OtpEntry>();

// Rate limiting: phone -> last sent timestamp
const rateLimitStore = new Map<string, number>();

// Tozalash interval — har 5 daqiqada eskirgan OTP'larni o'chirish
setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of otpStore.entries()) {
    if (now > entry.expiresAt) {
      otpStore.delete(key);
    }
  }
  for (const [key, timestamp] of rateLimitStore.entries()) {
    if (now - timestamp > 120_000) {
      rateLimitStore.delete(key);
    }
  }
}, 5 * 60 * 1000);

/**
 * Tasodifiy OTP kod generatsiya qilish
 */
function generateOtpCode(length: number = 4): string {
  let code = '';
  for (let i = 0; i < length; i++) {
    code += randomInt(0, 10).toString();
  }
  return code;
}

/**
 * Telegram Gateway sozlanganmi
 */
export function isTelegramConfigured(): boolean {
  return isTelegramGatewayConfigured();
}

/**
 * OTP yuborish — kanal tanlash
 *
 * telegram: Telegram Gateway API orqali (bot kerak emas, foydalanuvchi hech narsa qilmaydi)
 * sms: Eskiz SMS orqali
 */
export async function sendOtp(
  phone: string,
  channel: OtpChannel = 'sms',
): Promise<{ success: boolean; error?: string; channel: OtpChannel }> {
  // 1. Rate limiting tekshirish — 60 sekundda 1 marta
  const lastSent = rateLimitStore.get(phone);
  if (lastSent) {
    const elapsed = Date.now() - lastSent;
    const waitSeconds = Math.ceil((60_000 - elapsed) / 1000);
    if (elapsed < 60_000) {
      return {
        success: false,
        error: `${waitSeconds} soniyadan keyin qayta yuboring`,
        channel,
      };
    }
  }

  // 2. OTP generatsiya
  const code = generateOtpCode(env.OTP_LENGTH);
  const now = Date.now();
  const ttlMs = env.OTP_TTL_SECONDS * 1000;

  // 3. Saqlash
  otpStore.set(phone, {
    code,
    phone,
    attempts: 0,
    createdAt: now,
    expiresAt: now + ttlMs,
  });

  // 4. Kanalga qarab yuborish
  let result: { success: boolean; error?: string };

  if (channel === 'telegram') {
    if (!isTelegramGatewayConfigured()) {
      // Gateway sozlanmagan — SMS fallback
      result = await sendSmsViaEskiz(
        phone,
        `TOPLA tasdiqlash kodi: ${code}. Kod 2 daqiqa amal qiladi.`,
      );
      if (result.success) {
        rateLimitStore.set(phone, now);
        return { ...result, channel: 'sms' };
      }
      otpStore.delete(phone);
      return { ...result, channel: 'sms' };
    }

    // Telegram Gateway orqali yuborish — telefon raqam orqali to'g'ridan-to'g'ri
    result = await sendOtpViaTelegram(phone, code, env.OTP_TTL_SECONDS);

    if (!result.success) {
      // Telegram xatolik (raqam Telegramda yo'q va h.k.) — SMS fallback
      result = await sendSmsViaEskiz(
        phone,
        `TOPLA tasdiqlash kodi: ${code}. Kod 2 daqiqa amal qiladi.`,
      );
      if (result.success) {
        rateLimitStore.set(phone, now);
        return { ...result, channel: 'sms' };
      }
      otpStore.delete(phone);
      return { ...result, channel: 'sms' };
    }

    rateLimitStore.set(phone, now);
    return { success: true, channel: 'telegram' };
  }

  // SMS kanal (default)
  result = await sendSmsViaEskiz(
    phone,
    `TOPLA tasdiqlash kodi: ${code}. Kod 2 daqiqa amal qiladi.`,
  );

  if (result.success) {
    rateLimitStore.set(phone, now);
  } else {
    otpStore.delete(phone);
  }

  return { ...result, channel: 'sms' };
}

/**
 * OTP tekshirish
 */
export function verifyOtp(
  phone: string,
  code: string,
): { valid: boolean; error?: string } {
  // Debug log
  
  const entry = otpStore.get(phone);

  if (!entry) {
    return { valid: false, error: 'Kod topilmadi. Qayta yuboring' };
  }

  // Muddati tugaganmi?
  if (Date.now() > entry.expiresAt) {
    otpStore.delete(phone);
    return { valid: false, error: 'Kod muddati tugagan. Qayta yuboring' };
  }

  // Urinishlar soni
  if (entry.attempts >= 3) {
    otpStore.delete(phone);
    return { valid: false, error: 'Juda ko\'p urinish. Qayta yuboring' };
  }

  // Kodlar mos kelmaydimi?
  if (entry.code !== code) {
    entry.attempts++;
    return {
      valid: false,
      error: `Noto'g'ri kod. ${3 - entry.attempts} ta urinish qoldi`,
    };
  }

  // ✅ Kod to'g'ri — o'chirmaymiz, faqat belgilaymiz (duplicate so'rovlar uchun)
  // Agar allaqachon verified bo'lsa, qayta muvaffaqiyat qaytaramiz
  if (!entry.verified) {
    entry.verified = true;
    // 10 sekunddan keyin o'chirish (idempotent so'rovlar uchun)
    setTimeout(() => otpStore.delete(phone), 10_000);
  }
  return { valid: true };
}

/**
 * Dev/test uchun — OTP'ni olish (production'da o'chiriladi)
 */
export function getOtpForTesting(phone: string): string | null {
  if (env.NODE_ENV === 'production') return null;
  const entry = otpStore.get(phone);
  return entry?.code ?? null;
}
