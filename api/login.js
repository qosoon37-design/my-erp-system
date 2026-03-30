// API: Login Handler (Vercel Serverless Function)
export default function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const { username, password, department } = req.body;

    if (!username || !password || !department) {
        return res.status(400).json({ error: '\u062c\u0645\u064a\u0639 \u0627\u0644\u062d\u0642\u0648\u0644 \u0645\u0637\u0644\u0648\u0628\u0629' });
    }

    // في الإنتاج: التحقق من Supabase Auth
    const users = {
        'ceo': { name: '\u0639\u0628\u062f\u0627\u0644\u0644\u0647 \u0635\u0627\u0644\u062d', role: '\u0627\u0644\u0645\u062f\u064a\u0631 \u0627\u0644\u0639\u0627\u0645', isCEO: true },
        'admin': { name: '\u0625\u0628\u0631\u0627\u0647\u064a\u0645 \u062c\u0645\u0627\u0644', role: '\u0645\u062f\u064a\u0631 \u0627\u0644\u0625\u062f\u0627\u0631\u0629', isAdmin: true }
    };

    const userData = users[username] || { name: username, role: '\u0645\u0648\u0638\u0641' };

    res.status(200).json({
        success: true,
        user: {
            ...userData,
            department
        }
    });
}
