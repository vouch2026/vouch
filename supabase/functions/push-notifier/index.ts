import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8"
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.1/mod.ts"

// Helper function to exchange Service Account private key for an FCM access token
async function getAccessToken(clientEmail: string, privateKey: string): Promise<string> {
  // Clean the PEM format key
  const pemHeader = "-----BEGIN PRIVATE KEY-----";
  const pemFooter = "-----END PRIVATE KEY-----";
  
  const pemContents = privateKey
    .replace(pemHeader, "")
    .replace(pemFooter, "")
    .replace(/\s/g, "");

  // Convert Base64 PEM to binary array
  const binaryDerString = atob(pemContents);
  const binaryDer = new Uint8Array(binaryDerString.length);
  for (let i = 0; i < binaryDerString.length; i++) {
    binaryDer[i] = binaryDerString.charCodeAt(i);
  }

  // Import Key using SubtleCrypto (RSASSA-PKCS1-v1_5 + SHA-256)
  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"]
  );

  // Create Signed JWT token
  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: clientEmail,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      exp: getNumericDate(3600), // Expiry: 1 hour
      iat: getNumericDate(0),
    },
    key
  );

  // Exchange JWT for OAuth2 Access Token
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const data = await response.json();
  if (data.error) {
    throw new Error(`OAuth exchange failed: ${data.error_description || data.error}`);
  }
  return data.access_token;
}

serve(async (req) => {
  try {
    const payload = await req.json();
    const record = payload.record;

    // 1. Initialize Supabase Client with Service Role
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 2. Query target FCM tokens
    let tokenQuery = supabase.from('user_fcm_tokens').select('fcm_token');

    // Note: user_fcm_tokens stores the auth user ID ('auth_id' in public.users).
    // The notifications table target IDs ('target_user_id') refer to the primary key 'id' in public.users.
    if (record.notification_type === 'personal') {
      const { data: targetUser, error: userErr } = await supabase
        .from('users')
        .select('auth_id')
        .eq('id', record.target_user_id)
        .single();
      if (userErr) throw userErr;
      
      if (!targetUser?.auth_id) {
        console.log('Target user does not have a valid auth_id mapped.');
        return new Response(JSON.stringify({ message: 'No target tokens found.' }), { status: 200 });
      }
      tokenQuery = tokenQuery.eq('user_id', targetUser.auth_id);
    } else if (record.notification_type === 'program') {
      const { data: users, error: userErr } = await supabase
        .from('users')
        .select('auth_id')
        .eq('program_id', record.target_program_id);
      if (userErr) throw userErr;
      
      const authIds = (users || []).map((u) => u.auth_id).filter(Boolean);
      tokenQuery = tokenQuery.in('user_id', authIds);
    } else if (record.notification_type === 'faculty') {
      const { data: users, error: userErr } = await supabase
        .from('users')
        .select('auth_id')
        .eq('faculty_id', record.target_faculty_id);
      if (userErr) throw userErr;
      
      const authIds = (users || []).map((u) => u.auth_id).filter(Boolean);
      tokenQuery = tokenQuery.in('user_id', authIds);
    } else if (record.notification_type === 'campus') {
      const { data: users, error: userErr } = await supabase
        .from('users')
        .select('auth_id')
        .eq('campus_id', record.target_campus_id);
      if (userErr) throw userErr;
      
      const authIds = (users || []).map((u) => u.auth_id).filter(Boolean);
      tokenQuery = tokenQuery.in('user_id', authIds);
    }

    const { data: tokens, error: dbError } = await tokenQuery;
    if (dbError) throw dbError;

    if (!tokens || tokens.length === 0) {
      console.log('No matching tokens found for this scope.');
      return new Response(JSON.stringify({ message: 'No target tokens found.' }), { status: 200 });
    }

    const fcmTokens = tokens.map((t) => t.fcm_token);

    // 3. Get Firebase Service Account JSON
    const rawSecret = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
    if (!rawSecret) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON secret is not set in Supabase Edge Function environment.');
    }

    let serviceAccountJson: Record<string, any>;
    try {
      const cleaned = rawSecret.trim();
      serviceAccountJson = JSON.parse(cleaned);
      if (typeof serviceAccountJson === 'string') {
        serviceAccountJson = JSON.parse(serviceAccountJson);
      }
    } catch (e) {
      throw new Error(`FIREBASE_SERVICE_ACCOUNT_JSON secret is invalid JSON: ${e.message}. Ensure valid JSON formatted with double quotes.`);
    }

    const clientEmail = serviceAccountJson.client_email;
    const privateKey = serviceAccountJson.private_key ? serviceAccountJson.private_key.replace(/\\n/g, '\n') : '';
    const projectId = serviceAccountJson.project_id;

    if (!clientEmail || !privateKey || !projectId) {
      throw new Error('Service Account config is missing properties.');
    }

    // 4. Generate Access Token natively
    const accessToken = await getAccessToken(clientEmail, privateKey);

    // 5. Send FCM requests
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    const sendPromises = fcmTokens.map((token) => {
      const message = {
        message: {
          token: token,
          notification: {
            title: record.title,
            body: record.content,
          },
          data: {
            category: record.category || 'general',
            action_route: record.action_route || '/',
            metadata: JSON.stringify(record.metadata || {}),
          },
        },
      };

      return fetch(fcmUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(message),
      });
    });

    const results = await Promise.all(sendPromises);
    console.log(`Sent ${results.length} push notifications successfully.`);

    return new Response(JSON.stringify({ success: true, count: fcmTokens.length }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error('Error during execution:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
})