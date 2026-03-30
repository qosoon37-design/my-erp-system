// ===== Supabase Database Client =====
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';

// استبدل ببيانات مشروعك
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';

let supabaseInstance = null;

export function getSupabase() {
    if (supabaseInstance) return supabaseInstance;

    supabaseInstance = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
        auth: {
            persistSession: true,
            autoRefreshToken: true,
        },
        realtime: {
            timeout: 20000,
        }
    });

    return supabaseInstance;
}

export default getSupabase;
