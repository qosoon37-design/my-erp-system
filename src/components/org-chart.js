// ===== Org Chart Component =====

// الهيكل التنظيمي للمؤسسة
export function getOrgStructure(branches) {
    return {
        name: '\u0627\u0644\u0645\u062f\u064a\u0631 \u0627\u0644\u0639\u0627\u0645',
        role: 'CEO',
        children: [
            {
                name: '\u0627\u0644\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u0631\u0643\u0632\u064a\u0629',
                role: 'Admin',
                children: branches.map(b => ({
                    name: b.name,
                    role: '\u0641\u0631\u0639',
                    employeeCount: b.employees?.length || 0
                }))
            }
        ]
    };
}

// حساب إجمالي الموظفين
export function getTotalEmployees(branches) {
    return branches.reduce((sum, b) => sum + (b.employees?.length || 0), 0);
}
