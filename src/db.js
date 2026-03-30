// ===== Supabase Database Client =====
// ملاحظة: Supabase غير مفعّل حالياً - النظام يعمل بالبيانات التجريبية
// عند الجاهزية: أضف مفاتيح Supabase وفعّل الاستيراد

const SUPABASE_URL = '';
const SUPABASE_ANON_KEY = '';

let supabaseInstance = null;

export function getSupabase() {
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
        console.warn('Supabase غير مُعَد - النظام يعمل في وضع تجريبي');
        return null;
    }
    return supabaseInstance;
}

export default getSupabase;
