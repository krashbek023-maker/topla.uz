/**
 * Eskiz.uz SMS Service
 * API: https://notify.eskiz.uz
 * 
 * Token 30 kun amal qiladi, avtomatik yangilanadi.
 * Narx: 95 so'm / 1 SMS (O'zbekiston ichki)
 */

import { env } from './env.js';

const ESKIZ_BASE_URL = 'https://notify.eskiz.uz/api';

let cachedToken: string | null = null;
let tokenExpiresAt: number = 0;

/**
 * Eskiz API token olish (30 kunlik)
 */
async function getEskizToken(): Promise<string> {
  // Cache'dan qaytarish
  if (cachedToken && Date.now() < tokenExpiresAt) {
    return cachedToken;
  }

  if (!env.ESKIZ_EMAIL || !env.ESKIZ_PASSWORD) {
    throw new Error('ESKIZ_EMAIL va ESKIZ_PASSWORD .env da belgilanmagan');
  }

  console.log('🔑 Eskiz tokenga ulanilmoqda...');

  const formData = new URLSearchParams();
  formData.append('email', env.ESKIZ_EMAIL);
  formData.append('password', env.ESKIZ_PASSWORD);

  try {
    const response = await fetch(`${ESKIZ_BASE_URL}/auth/login`, {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      const text = await response.text();
      console.error(`❌ Eskiz auth: ${response.status} — ${text}`);
      throw new Error(`Eskiz auth xatolik: ${response.status} — ${text}`);
    }

    const data = (await response.json()) as {
      data: { token: string };
      message: string;
    };

    if (!data?.data?.token) {
      throw new Error('Eskiz token javobda yo\'q');
    }

    cachedToken = data.data.token;
    // 29 kundan keyin yangilash (30 kun amal qiladi)
    tokenExpiresAt = Date.now() + 29 * 24 * 60 * 60 * 1000;

    console.log('✅ Eskiz token olindi');
    return cachedToken;
  } catch (error) {
    cachedToken = null;
    tokenExpiresAt = 0;
    throw error;
  }
}

/**
 * SMS yuborish Eskiz orqali
 * @param phone - Telefon raqam (998901234567 formatda, + belgisiz)
 * @param message - SMS matni
 */
export async function sendSmsViaEskiz(
  phone: string,
  message: string,
): Promise<{ success: boolean; messageId?: string; error?: string }> {
  try {
    const token = await getEskizToken();

    // +998... formatni 998... ga o'zgartirish
    const cleanPhone = phone.replace(/^\+/, '');

    const formData = new URLSearchParams();
    formData.append('mobile_phone', cleanPhone);
    formData.append('message', message);
    formData.append('from', '4546'); // Default sender ID, keyinroq "TOPLA" ga o'zgartiriladi

    const response = await fetch(`${ESKIZ_BASE_URL}/message/sms/send`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
      },
      body: formData,
    });

    const responseText = await response.text();

    if (!response.ok) {
      // Token eskirgan bo'lsa yangilash
      if (response.status === 401) {
        cachedToken = null;
        tokenExpiresAt = 0;
        console.log('🔄 Eskiz token eskirdi, qayta olinmoqda...');
        // Qayta urinish
        return sendSmsViaEskiz(phone, message);
      }

      console.error(`❌ Eskiz SMS xatolik: ${response.status} — ${responseText}`);
      return { success: false, error: `SMS xatolik: ${response.status}. Qayta urinib ko'ring.` };
    }

    let data: { id?: string; status?: string; message?: string } = {};
    try {
      data = JSON.parse(responseText);
    } catch {
      // JSON bo'lmasa ham davom etamiz
    }

    console.log(`📱 SMS yuborildi: ${cleanPhone.slice(0, 5)}***`);

    return {
      success: true,
      messageId: data.id || data.status || 'sent',
    };
  } catch (error) {
    console.error('❌ Eskiz SMS xatolik:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Noma\'lum xatolik',
    };
  }
}

/**
 * Eskiz balansni tekshirish
 */
export async function getEskizBalance(): Promise<{ balance: number } | null> {
  try {
    const token = await getEskizToken();

    const response = await fetch(`${ESKIZ_BASE_URL}/user/get-limit`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (!response.ok) return null;

    const data = (await response.json()) as { data: { balance: number } };
    return { balance: data.data.balance };
  } catch {
    return null;
  }
}
