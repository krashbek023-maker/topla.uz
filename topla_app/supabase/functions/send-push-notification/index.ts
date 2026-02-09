// deno-lint-ignore-file
/// <reference types="https://deno.land/x/types/index.d.ts" />
// @ts-nocheck - Deno runtime types
// Supabase Edge Function: Push Notification yuborish
// Deploy: supabase functions deploy send-push-notification

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface NotificationPayload {
  user_id: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const FIREBASE_SERVER_KEY = Deno.env.get("FIREBASE_SERVER_KEY");
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!FIREBASE_SERVER_KEY) {
      throw new Error("FIREBASE_SERVER_KEY is not set");
    }

    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

    const { user_id, title, body, data } = (await req.json()) as NotificationPayload;

    // Foydalanuvchining FCM tokenini olish
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("fcm_token")
      .eq("id", user_id)
      .single();

    if (profileError || !profile?.fcm_token) {
      console.log("FCM token topilmadi:", user_id);
      return new Response(
        JSON.stringify({ success: false, error: "FCM token not found" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // FCM ga notification yuborish
    const fcmResponse = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `key=${FIREBASE_SERVER_KEY}`,
      },
      body: JSON.stringify({
        to: profile.fcm_token,
        notification: {
          title,
          body,
          sound: "default",
          badge: 1,
        },
        data: {
          ...data,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        priority: "high",
      }),
    });

    const fcmResult = await fcmResponse.json();
    console.log("FCM response:", fcmResult);

    return new Response(
      JSON.stringify({ success: true, result: fcmResult }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
