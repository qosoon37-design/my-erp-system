-- =============================================
-- إضافة موظفين تجريبيين في الفروع
-- =============================================

-- فرع أبوبكر
INSERT INTO employees (name, role_title, branch_id) VALUES
    ('صالح محمد', 'مدير فرع', (SELECT id FROM branches WHERE code='b1')),
    ('ياسر أحمد', 'مبيعات', (SELECT id FROM branches WHERE code='b1')),
    ('أنور علي', 'كاشير', (SELECT id FROM branches WHERE code='b1'));

-- فرع سلطانة
INSERT INTO employees (name, role_title, branch_id) VALUES
    ('عادل خالد', 'مدير فرع', (SELECT id FROM branches WHERE code='b2')),
    ('مرشاد حسن', 'مبيعات', (SELECT id FROM branches WHERE code='b2'));

-- فرع جيزان
INSERT INTO employees (name, role_title, branch_id) VALUES
    ('فهد عبدالرحمن', 'مدير فرع', (SELECT id FROM branches WHERE code='b3')),
    ('سعيد محمد', 'مبيعات', (SELECT id FROM branches WHERE code='b3'));

-- فرع عنيزة
INSERT INTO employees (name, role_title, branch_id) VALUES
    ('خالد إبراهيم', 'مدير فرع', (SELECT id FROM branches WHERE code='b4')),
    ('نواف سالم', 'كاشير', (SELECT id FROM branches WHERE code='b4'));

-- فرع الياسمين
INSERT INTO employees (name, role_title, branch_id) VALUES
    ('طارق عمر', 'مدير فرع', (SELECT id FROM branches WHERE code='b5')),
    ('ماجد حسين', 'مبيعات', (SELECT id FROM branches WHERE code='b5'));

-- فرع الدائري
INSERT INTO employees (name, role_title, branch_id) VALUES
    ('بدر ناصر', 'مدير فرع', (SELECT id FROM branches WHERE code='b6'));

-- فرع المتجر
INSERT INTO employees (name, role_title, branch_id) VALUES
    ('عبدالله فيصل', 'مدير فرع', (SELECT id FROM branches WHERE code='b7')),
    ('أحمد ريان', 'مبيعات', (SELECT id FROM branches WHERE code='b7'));

-- فرع الطائف
INSERT INTO employees (name, role_title, branch_id) VALUES
    ('محمد عايض', 'مدير فرع', (SELECT id FROM branches WHERE code='b8'));

-- فرع الفيحاء
INSERT INTO employees (name, role_title, branch_id) VALUES
    ('سلطان راشد', 'مدير فرع', (SELECT id FROM branches WHERE code='b9')),
    ('وليد سعود', 'مبيعات', (SELECT id FROM branches WHERE code='b9'));

-- إضافة طلبات تجريبية
INSERT INTO requests (title, description, status, priority, created_by, branch_id) VALUES
    ('طلب موافقة على ميزانية Q2', 'طلب اعتماد ميزانية الربع الثاني', 'pending', 'normal', '243a9618-e290-4d4a-bc15-04f44de158ca', (SELECT id FROM branches WHERE code='b3')),
    ('طلب نقل موظف - أحمد', 'طلب نقل الموظف أحمد من فرع أبوبكر إلى فرع الطائف', 'forwarded', 'normal', 'd9d38237-9532-41b7-b79b-bcfe5084820b', (SELECT id FROM branches WHERE code='b8')),
    ('شكوى عاجلة - عطل في النظام', 'النظام متوقف في فرع الفيحاء منذ أمس', 'urgent', 'urgent', '243a9618-e290-4d4a-bc15-04f44de158ca', (SELECT id FROM branches WHERE code='b9'));
