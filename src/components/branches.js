// ===== Branches Component =====

// البيانات الافتراضية للفروع
export function getDefaultBranches() {
    return [
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
}

// تحميل البيانات التجريبية
export function loadDemoEmployees(branches) {
    branches[0].employees = [
        { id: 1, name: '\u0635\u0627\u0644\u062d \u0645\u062d\u0645\u062f', role: '\u0645\u062f\u064a\u0631 \u0641\u0631\u0639', initials: '\u0635\u0645' },
        { id: 2, name: '\u064a\u0627\u0633\u0631 \u0623\u062d\u0645\u062f', role: '\u0645\u0628\u064a\u0639\u0627\u062a', initials: '\u064a\u0623' }
    ];
    return branches;
}

// إضافة موظف
export function addEmployee(branch, name, role) {
    if (!name) return false;
    branch.employees.push({
        id: Date.now(),
        name,
        role: role || '\u0645\u0648\u0638\u0641',
        initials: name.split(' ').map(n => n[0]).join('').substring(0, 2)
    });
    return true;
}

// حذف موظف
export function deleteEmployee(branch, empId) {
    branch.employees = branch.employees.filter(e => e.id !== empId);
}
