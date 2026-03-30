// ===== Authentication Module =====

// قائمة المستخدمين التجريبيين
const demoUsers = {
    'ceo': { name: '\u0639\u0628\u062f\u0627\u0644\u0644\u0647 \u0635\u0627\u0644\u062d', role: '\u0627\u0644\u0645\u062f\u064a\u0631 \u0627\u0644\u0639\u0627\u0645', isCEO: true },
    'admin': { name: '\u0625\u0628\u0631\u0627\u0647\u064a\u0645 \u062c\u0645\u0627\u0644', role: '\u0645\u062f\u064a\u0631 \u0627\u0644\u0625\u062f\u0627\u0631\u0629', isAdmin: true }
};

export async function handleLogin(username, password, department, branches) {
    // محاكاة تسجيل الدخول (في الإنتاج: Supabase Auth)
    return new Promise((resolve) => {
        setTimeout(() => {
            const userData = demoUsers[username] || { name: username, role: '\u0645\u0648\u0638\u0641' };

            const user = {
                ...userData,
                initials: userData.name.split(' ').map(n => n[0]).join(''),
                department: department === 'ceo' ? '\u0627\u0644\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0639\u0644\u064a\u0627' :
                    branches.find(b => b.id === department)?.name || '\u0627\u0644\u0625\u062f\u0627\u0631\u0629'
            };

            resolve(user);
        }, 800);
    });
}

export function logout() {
    // في الإنتاج: supabase.auth.signOut()
    return { success: true };
}

export function canAccess(user, page) {
    if (user.isCEO) return true;
    if (page === 'branches') return true;
    if (page === 'requests') return true;
    return false;
}

export function canEdit(user) {
    return user.isCEO || user.isAdmin;
}

export function canDelete(user) {
    return user.isCEO;
}

export function canForward(user, req) {
    return !req.forwarded && (user.isCEO || user.isAdmin);
}
