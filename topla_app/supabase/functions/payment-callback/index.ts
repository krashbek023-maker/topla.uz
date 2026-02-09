// Asia Alliance Bank Payment Callback Handler
// Bu Edge Function bankdan keladigan to'lov natijalarini qabul qiladi

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface PaymentCallbackData {
  transaction_id: string
  order_id: string
  status: 'SUCCESS' | 'FAILED' | 'CANCELLED' | 'PENDING'
  amount: number
  currency: string
  card_token?: string
  masked_pan?: string
  card_type?: string
  expiry_date?: string
  error_code?: string
  error_message?: string
  timestamp: string
  signature: string
}

interface CardBindingCallbackData {
  binding_id: string
  user_id: string
  status: 'SUCCESS' | 'FAILED'
  card_token: string
  masked_pan: string
  card_type: string
  expiry_date: string
  card_holder?: string
  error_code?: string
  error_message?: string
  timestamp: string
  signature: string
}

// Signature tekshirish
function verifySignature(data: Record<string, unknown>, signature: string): boolean {
  const secretKey = Deno.env.get('ASIA_ALLIANCE_SECRET_KEY')
  if (!secretKey) {
    console.error('ASIA_ALLIANCE_SECRET_KEY not configured')
    return false
  }

  // Bank signature formatiga qarab o'zgartirish kerak
  // Odatda: HMAC-SHA256(sorted_params + secret_key)
  const sortedKeys = Object.keys(data).filter(k => k !== 'signature').sort()
  const dataString = sortedKeys.map(k => `${k}=${data[k]}`).join('&')
  
  // TODO: Haqiqiy signature tekshirish - bank dokumentatsiyasiga qarab
  // const encoder = new TextEncoder()
  // const keyData = encoder.encode(secretKey)
  // const messageData = encoder.encode(dataString)
  // const cryptoKey = await crypto.subtle.importKey(...)
  // const signatureBuffer = await crypto.subtle.sign(...)
  
  // Hozircha true qaytaramiz, production'da to'g'ri tekshirish kerak
  console.log('Signature verification - data:', dataString)
  return true
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const url = new URL(req.url)
    const path = url.pathname.split('/').pop()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // To'lov natijasi callback
    if (path === 'payment' || req.method === 'POST') {
      const data: PaymentCallbackData = await req.json()
      
      console.log('Payment callback received:', JSON.stringify(data, null, 2))

      // Signature tekshirish
      if (!verifySignature(data as unknown as Record<string, unknown>, data.signature)) {
        console.error('Invalid signature')
        return new Response(
          JSON.stringify({ error: 'Invalid signature' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Transaction ma'lumotlarini yangilash
      const { error: txError } = await supabase
        .from('transactions')
        .update({
          status: data.status.toLowerCase(),
          bank_transaction_id: data.transaction_id,
          processed_at: new Date().toISOString(),
          error_code: data.error_code,
          error_message: data.error_message,
          raw_response: data,
        })
        .eq('order_id', data.order_id)

      if (txError) {
        console.error('Transaction update error:', txError)
      }

      // Buyurtma statusini yangilash
      if (data.status === 'SUCCESS') {
        const { error: orderError } = await supabase
          .from('orders')
          .update({
            payment_status: 'paid',
            paid_at: new Date().toISOString(),
          })
          .eq('id', data.order_id)

        if (orderError) {
          console.error('Order update error:', orderError)
        }

        // Vendor balansini yangilash (trigger orqali avtomatik)
        // Vendor ga to'lov - order items dan hisoblash
        const { data: orderData } = await supabase
          .from('orders')
          .select('*, items:order_items(*)')
          .eq('id', data.order_id)
          .single()

        if (orderData) {
          // Har bir shop uchun vendor_transactions yaratish
          const shopTotals = new Map<string, number>()
          
          for (const item of orderData.items || []) {
            const shopId = item.shop_id
            if (shopId) {
              const current = shopTotals.get(shopId) || 0
              shopTotals.set(shopId, current + (item.price * item.quantity))
            }
          }

          for (const [shopId, amount] of shopTotals) {
            // Komissiya hisoblash
            const { data: commissionData } = await supabase
              .from('commission_settings')
              .select('*')
              .order('min_amount', { ascending: false })
              .limit(1)

            const commissionRate = commissionData?.[0]?.rate || 0.05 // 5% default
            const commission = Math.round(amount * commissionRate)
            const netAmount = amount - commission

            await supabase.from('vendor_transactions').insert({
              shop_id: shopId,
              order_id: data.order_id,
              type: 'order_payment',
              amount: netAmount,
              commission_amount: commission,
              commission_rate: commissionRate,
              status: 'completed',
            })
          }
        }

        // Push notification yuborish
        const { data: userData } = await supabase
          .from('orders')
          .select('user_id, profiles!inner(fcm_token)')
          .eq('id', data.order_id)
          .single()

        if (userData?.profiles?.fcm_token) {
          // Firebase Push Notification yuborish
          await sendPushNotification(
            userData.profiles.fcm_token,
            'To\'lov muvaffaqiyatli!',
            `Buyurtma #${data.order_id.substring(0, 8)} uchun to\'lov qabul qilindi.`
          )
        }
      } else if (data.status === 'FAILED' || data.status === 'CANCELLED') {
        await supabase
          .from('orders')
          .update({
            payment_status: 'failed',
            status: 'cancelled',
          })
          .eq('id', data.order_id)
      }

      return new Response(
        JSON.stringify({ success: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Karta bog'lash callback
    if (path === 'card-binding') {
      const data: CardBindingCallbackData = await req.json()
      
      console.log('Card binding callback received:', JSON.stringify(data, null, 2))

      if (!verifySignature(data as unknown as Record<string, unknown>, data.signature)) {
        return new Response(
          JSON.stringify({ error: 'Invalid signature' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      if (data.status === 'SUCCESS') {
        // Kartani saqlash
        const { error } = await supabase.from('saved_cards').insert({
          user_id: data.user_id,
          card_token: data.card_token,
          masked_pan: data.masked_pan,
          card_type: data.card_type.toLowerCase(),
          expiry_date: data.expiry_date,
          card_holder: data.card_holder,
          is_default: false,
        })

        if (error) {
          console.error('Card save error:', error)
          return new Response(
            JSON.stringify({ error: 'Failed to save card' }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          )
        }

        // Agar birinchi karta bo'lsa, default qilish
        const { count } = await supabase
          .from('saved_cards')
          .select('*', { count: 'exact', head: true })
          .eq('user_id', data.user_id)

        if (count === 1) {
          await supabase
            .from('saved_cards')
            .update({ is_default: true })
            .eq('card_token', data.card_token)
        }
      }

      return new Response(
        JSON.stringify({ success: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ error: 'Unknown endpoint' }),
      { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Webhook error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// Firebase Push Notification yuborish
async function sendPushNotification(token: string, title: string, body: string) {
  const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')
  if (!fcmServerKey) {
    console.error('FCM_SERVER_KEY not configured')
    return
  }

  try {
    await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${fcmServerKey}`,
      },
      body: JSON.stringify({
        to: token,
        notification: {
          title,
          body,
          sound: 'default',
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          type: 'payment_success',
        },
      }),
    })
  } catch (error) {
    console.error('Push notification error:', error)
  }
}
