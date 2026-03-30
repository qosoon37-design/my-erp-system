// API: Get Branches Handler (Vercel Serverless Function)
export default function handler(req, res) {
    if (req.method !== 'GET') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    // في الإنتاج: جلب البيانات من Supabase
    const branches = [
        { id: 'b1', name: '\u0641\u0631\u0639 \u0623\u0628\u0648\u0628\u0643\u0631', employees: [] },
        { id: 'b2', name: '\u0641\u0631\u0639 \u0633\u0644\u0637\u0627\u0646\u0629', employees: [] },
        { id: 'b3', name: '\u0641\u0631\u0639 \u062c\u064a\u0632\u0627\u0646', employees: [] },
        { id: 'b4', name: '\u0641\u0631\u0639 \u0639\u0646\u064a\u0632\u0629', employees: [] },
        { id: 'b5', name: '\u0641\u0631\u0639 \u0627\u0644\u064a\u0627\u0633\u0645\u064a\u0646', employees: [] },
        { id: 'b6', name: '\u0641\u0631\u0639 \u0627\u0644\u062f\u0627\u0626\u0631\u064a', employees: [] },
        { id: 'b7', name: '\u0641\u0631\u0639 \u0627\u0644\u0645\u062a\u062c\u0631', employees: [] },
        { id: 'b8', name: '\u0641\u0631\u0639 \u0627\u0644\u0637\u0627\u0626\u0641', employees: [] },
        { id: 'b9', name: '\u0641\u0631\u0639 \u0627\u0644\u0641\u064a\u062d\u0627\u0621', employees: [] }
    ];

    res.status(200).json({ branches });
}
