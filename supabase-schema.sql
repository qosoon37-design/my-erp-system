-- =============================================
-- نظام ERP - قاعدة بيانات Supabase
-- شغّل هذا الملف في SQL Editor في Supabase
-- =============================================

-- 1. جدول الفروع
CREATE TABLE branches (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    code text NOT NULL UNIQUE,
    created_at timestamptz DEFAULT now()
);

-- 2. جدول الملفات الشخصية (مرتبط بـ auth.users)
CREATE TABLE profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name text NOT NULL DEFAULT '',
    role text NOT NULL DEFAULT 'employee' CHECK (role IN ('ceo','admin','employee')),
    branch_id uuid REFERENCES branches(id),
    created_at timestamptz DEFAULT now()
);

-- 3. جدول الموظفين
CREATE TABLE employees (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    role_title text NOT NULL DEFAULT 'موظف',
    branch_id uuid NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
    phone text,
    email text,
    created_at timestamptz DEFAULT now()
);

-- 4. جدول الطلبات
CREATE TABLE requests (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    description text,
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected','forwarded','urgent')),
    priority text DEFAULT 'normal' CHECK (priority IN ('normal','urgent')),
    created_by uuid NOT NULL REFERENCES profiles(id),
    branch_id uuid REFERENCES branches(id),
    assigned_to uuid REFERENCES profiles(id),
    is_read boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 5. جدول سجل التحويل
CREATE TABLE request_forwards (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id uuid NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
    forwarded_by uuid NOT NULL REFERENCES profiles(id),
    from_branch_id uuid REFERENCES branches(id),
    to_branch_id uuid REFERENCES branches(id),
    to_role text,
    note text,
    created_at timestamptz DEFAULT now()
);

-- =============================================
-- الدوال المساعدة
-- =============================================

-- دالة لمعرفة دور المستخدم الحالي
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT role FROM profiles WHERE id = auth.uid();
$$;

-- دالة لمعرفة فرع المستخدم الحالي
CREATE OR REPLACE FUNCTION get_my_branch_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT branch_id FROM profiles WHERE id = auth.uid();
$$;

-- تحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER requests_updated_at
    BEFORE UPDATE ON requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- إنشاء profile تلقائياً عند تسجيل مستخدم جديد
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO profiles (id, full_name, role)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email), 'employee');
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- =============================================
-- تفعيل RLS
-- =============================================
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE request_forwards ENABLE ROW LEVEL SECURITY;

-- =============================================
-- سياسات الأمان - branches
-- =============================================
CREATE POLICY "branches_read" ON branches FOR SELECT TO authenticated USING (true);
CREATE POLICY "branches_manage" ON branches FOR ALL TO authenticated USING (get_my_role() = 'ceo');

-- =============================================
-- سياسات الأمان - profiles
-- =============================================
CREATE POLICY "profiles_read" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_update" ON profiles FOR UPDATE TO authenticated
    USING (id = auth.uid() OR get_my_role() = 'ceo');

-- =============================================
-- سياسات الأمان - employees
-- =============================================
CREATE POLICY "employees_read" ON employees FOR SELECT TO authenticated USING (true);
CREATE POLICY "employees_insert" ON employees FOR INSERT TO authenticated
    WITH CHECK (get_my_role() IN ('ceo','admin'));
CREATE POLICY "employees_update" ON employees FOR UPDATE TO authenticated
    USING (
        get_my_role() = 'ceo'
        OR (get_my_role() = 'admin' AND branch_id = get_my_branch_id())
    );
CREATE POLICY "employees_delete" ON employees FOR DELETE TO authenticated
    USING (get_my_role() = 'ceo');

-- =============================================
-- سياسات الأمان - requests
-- =============================================
CREATE POLICY "requests_read" ON requests FOR SELECT TO authenticated
    USING (
        get_my_role() = 'ceo'
        OR created_by = auth.uid()
        OR assigned_to = auth.uid()
        OR (get_my_role() = 'admin' AND branch_id = get_my_branch_id())
    );
CREATE POLICY "requests_insert" ON requests FOR INSERT TO authenticated
    WITH CHECK (true);
CREATE POLICY "requests_update" ON requests FOR UPDATE TO authenticated
    USING (
        get_my_role() = 'ceo'
        OR created_by = auth.uid()
        OR (get_my_role() = 'admin' AND branch_id = get_my_branch_id())
    );
CREATE POLICY "requests_delete" ON requests FOR DELETE TO authenticated
    USING (get_my_role() = 'ceo');

-- =============================================
-- سياسات الأمان - request_forwards
-- =============================================
CREATE POLICY "forwards_read" ON request_forwards FOR SELECT TO authenticated
    USING (
        get_my_role() = 'ceo'
        OR forwarded_by = auth.uid()
    );
CREATE POLICY "forwards_insert" ON request_forwards FOR INSERT TO authenticated
    WITH CHECK (get_my_role() IN ('ceo','admin'));

-- =============================================
-- الفهارس
-- =============================================
CREATE INDEX idx_employees_branch ON employees(branch_id);
CREATE INDEX idx_requests_created_by ON requests(created_by);
CREATE INDEX idx_requests_branch ON requests(branch_id);
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_forwards_request ON request_forwards(request_id);

-- =============================================
-- البيانات الأولية - الفروع التسعة
-- =============================================
INSERT INTO branches (name, code) VALUES
    ('فرع أبوبكر', 'b1'),
    ('فرع سلطانة', 'b2'),
    ('فرع جيزان', 'b3'),
    ('فرع عنيزة', 'b4'),
    ('فرع الياسمين', 'b5'),
    ('فرع الدائري', 'b6'),
    ('فرع المتجر', 'b7'),
    ('فرع الطائف', 'b8'),
    ('فرع الفيحاء', 'b9');
