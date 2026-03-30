// API: Forward Request Handler (Vercel Serverless Function)
export default function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const { requestId, target, note, userName, userDept } = req.body;

    if (!requestId || !target) {
        return res.status(400).json({ error: '\u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u062a\u062d\u0648\u064a\u0644 \u063a\u064a\u0631 \u0645\u0643\u062a\u0645\u0644\u0629' });
    }

    // في الإنتاج: تحديث قاعدة البيانات
    res.status(200).json({
        success: true,
        message: '\u062a\u0645 \u0627\u0644\u062a\u062d\u0648\u064a\u0644 \u0628\u0646\u062c\u0627\u062d',
        data: {
            requestId,
            target,
            note,
            forwardedBy: userName,
            forwardedFrom: userDept,
            date: new Date().toISOString()
        }
    });
}
