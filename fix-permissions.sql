-- =============================================
-- إصلاح شامل للصلاحيات والأدوار
-- شغّل هذا الكود في SQL Editor في Supabase
-- =============================================

-- 1. إصلاح دالة get_my_role مع search_path
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT role FROM profiles WHERE id = auth.uid();
$$;

-- 2. إصلاح دالة get_my_branch_id مع search_path
CREATE OR REPLACE FUNCTION get_my_branch_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT branch_id FROM profiles WHERE id = auth.uid();
$$;

-- 3. إصلاح دالة handle_new_user مع search_path
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, role)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)), 'employee');
    RETURN NEW;
END;
$$;

-- 4. تحديث أدوار المستخدمين
UPDATE profiles SET role = 'ceo' WHERE id = '243a9618-e290-4d4a-bc15-04f44de158ca';
UPDATE profiles SET role = 'admin' WHERE id = 'd9d38237-9532-41b7-b79b-bcfe5084820b';

-- 5. إصلاح سياسات أمان الموظفين - الأدمن يدير جميع الفروع
DROP POLICY IF EXISTS "employees_update" ON employees;
CREATE POLICY "employees_update" ON employees FOR UPDATE TO authenticated
    USING (get_my_role() IN ('ceo', 'admin'));

DROP POLICY IF EXISTS "employees_insert" ON employees;
CREATE POLICY "employees_insert" ON employees FOR INSERT TO authenticated
    WITH CHECK (get_my_role() IN ('ceo', 'admin'));

DROP POLICY IF EXISTS "employees_delete" ON employees;
CREATE POLICY "employees_delete" ON employees FOR DELETE TO authenticated
    USING (get_my_role() IN ('ceo', 'admin'));

-- 6. إصلاح سياسات أمان الطلبات - الأدمن يرى جميع الطلبات
DROP POLICY IF EXISTS "requests_read" ON requests;
CREATE POLICY "requests_read" ON requests FOR SELECT TO authenticated
    USING (
        get_my_role() IN ('ceo', 'admin')
        OR created_by = auth.uid()
        OR assigned_to = auth.uid()
    );

DROP POLICY IF EXISTS "requests_update" ON requests;
CREATE POLICY "requests_update" ON requests FOR UPDATE TO authenticated
    USING (
        get_my_role() IN ('ceo', 'admin')
        OR created_by = auth.uid()
    );

DROP POLICY IF EXISTS "requests_delete" ON requests;
CREATE POLICY "requests_delete" ON requests FOR DELETE TO authenticated
    USING (get_my_role() IN ('ceo', 'admin'));

-- 7. إصلاح سياسات التحويل
DROP POLICY IF EXISTS "forwards_read" ON request_forwards;
CREATE POLICY "forwards_read" ON request_forwards FOR SELECT TO authenticated
    USING (
        get_my_role() IN ('ceo', 'admin')
        OR forwarded_by = auth.uid()
    );

DROP POLICY IF EXISTS "forwards_insert" ON request_forwards;
CREATE POLICY "forwards_insert" ON request_forwards FOR INSERT TO authenticated
    WITH CHECK (get_my_role() IN ('ceo', 'admin'));

-- 8. التحقق من النتيجة
SELECT id, full_name, role, branch_id FROM profiles;
