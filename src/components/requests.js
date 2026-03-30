// ===== Requests Component =====

// البيانات التجريبية للطلبات
export function getDemoCEORequests() {
    return [
        {
            id: 1,
            title: '\u0637\u0644\u0628 \u0645\u0648\u0627\u0641\u0642\u0629 \u0639\u0644\u0649 \u0645\u064a\u0632\u0627\u0646\u064a\u0629',
            from: '\u0641\u0631\u0639 \u062c\u064a\u0632\u0627\u0646',
            date: '2026-03-30',
            status: 'pending',
            statusText: '\u0645\u0639\u0644\u0651\u0642',
            read: false,
            forwarded: false
        },
        {
            id: 2,
            title: '\u0637\u0644\u0628 \u0646\u0642\u0644 \u0645\u0648\u0638\u0641',
            from: '\u0641\u0631\u0639 \u0627\u0644\u0637\u0627\u0626\u0641',
            date: '2026-03-29',
            status: 'forwarded',
            statusText: '\u0645\u062d\u0648\u0651\u0644',
            read: true,
            forwarded: true,
            originalBranch: '\u0641\u0631\u0639 \u0623\u0628\u0648\u0628\u0643\u0631'
        }
    ];
}

export function getDemoMyRequests() {
    return [
        {
            id: 1,
            title: '\u0637\u0644\u0628 \u0625\u062c\u0627\u0632\u0629',
            from: '\u0623\u0646\u0627',
            date: '2026-03-30',
            status: 'pending',
            statusText: '\u0628\u0627\u0646\u062a\u0638\u0627\u0631 \u0627\u0644\u0645\u0648\u0627\u0641\u0642\u0629'
        }
    ];
}

// إنشاء طلب جديد
export function createRequest(title, userName) {
    return {
        id: Date.now(),
        title,
        from: userName,
        date: new Date().toISOString().split('T')[0],
        status: 'pending',
        statusText: '\u0628\u0627\u0646\u062a\u0638\u0627\u0631 \u0627\u0644\u0645\u0648\u0627\u0641\u0642\u0629'
    };
}

// تحويل طلب
export function forwardRequest(request, target, note, userName, userDept, branches) {
    request.forwarded = true;
    request.originalBranch = request.from || userDept;
    request.from = userName;
    request.to = target === 'ceo' ? '\u0627\u0644\u0645\u062f\u064a\u0631 \u0627\u0644\u0639\u0627\u0645' :
        branches.find(b => b.id === target)?.name;
    request.status = 'forwarded';
    request.statusText = '\u0645\u062d\u0648\u0651\u0644';
    request.note = note;

    return request;
}

// فلترة طلبات المدير العام
export function filterRequests(requests, filter) {
    if (filter === 'all') return requests;
    return requests.filter(r => r.status === filter);
}
