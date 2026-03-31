-- ============================================
-- ERP New Features Migration
-- 1. Employee accounts (user_id link)
-- 2. Residence & vacation tracking
-- 3. Salary & payroll
-- ============================================

-- ====== 1. ALTER employees TABLE ======
ALTER TABLE employees ADD COLUMN IF NOT EXISTS user_id uuid UNIQUE REFERENCES auth.users(id);
ALTER TABLE employees ADD COLUMN IF NOT EXISTS base_salary numeric(10,2) DEFAULT 0;
ALTER TABLE employees ADD COLUMN IF NOT EXISTS residence_expiry date;
ALTER TABLE employees ADD COLUMN IF NOT EXISTS vacation_days_entitled integer DEFAULT 21;

-- ====== 2. CREATE vacations TABLE ======
CREATE TABLE IF NOT EXISTS vacations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  start_date date NOT NULL,
  end_date date NOT NULL,
  days integer NOT NULL,
  type text NOT NULL DEFAULT 'annual' CHECK (type IN ('annual','sick','emergency','unpaid')),
  notes text,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_vacations_employee ON vacations(employee_id);

-- ====== 3. CREATE payroll TABLE ======
CREATE TABLE IF NOT EXISTS payroll (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  month integer NOT NULL CHECK (month BETWEEN 1 AND 12),
  year integer NOT NULL CHECK (year >= 2020),
  base_salary numeric(10,2) NOT NULL DEFAULT 0,
  bonus numeric(10,2) DEFAULT 0,
  overtime numeric(10,2) DEFAULT 0,
  deductions numeric(10,2) DEFAULT 0,
  net_salary numeric(10,2) GENERATED ALWAYS AS (base_salary + bonus + overtime - deductions) STORED,
  notes text,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(employee_id, month, year)
);
CREATE INDEX IF NOT EXISTS idx_payroll_employee ON payroll(employee_id, year, month);

-- ====== 4. HELPER FUNCTION ======
CREATE OR REPLACE FUNCTION get_my_employee_id()
RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM employees WHERE user_id = auth.uid() LIMIT 1;
$$;

-- ====== 5. UPDATE handle_new_user TRIGGER ======
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role, branch_id)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'مستخدم جديد'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'employee'),
    (NEW.raw_user_meta_data->>'branch_id')::uuid
  );
  RETURN NEW;
END;
$$;

-- ====== 6. RLS for vacations ======
ALTER TABLE vacations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "vacations_read" ON vacations
  FOR SELECT USING (
    get_my_role() IN ('ceo','admin')
    OR employee_id = get_my_employee_id()
  );

CREATE POLICY "vacations_insert" ON vacations
  FOR INSERT WITH CHECK (get_my_role() IN ('ceo','admin'));

CREATE POLICY "vacations_update" ON vacations
  FOR UPDATE USING (get_my_role() IN ('ceo','admin'));

CREATE POLICY "vacations_delete" ON vacations
  FOR DELETE USING (get_my_role() = 'ceo');

-- ====== 7. RLS for payroll ======
ALTER TABLE payroll ENABLE ROW LEVEL SECURITY;

CREATE POLICY "payroll_read" ON payroll
  FOR SELECT USING (
    get_my_role() IN ('ceo','admin')
    OR employee_id = get_my_employee_id()
  );

CREATE POLICY "payroll_insert" ON payroll
  FOR INSERT WITH CHECK (get_my_role() IN ('ceo','admin'));

CREATE POLICY "payroll_update" ON payroll
  FOR UPDATE USING (get_my_role() IN ('ceo','admin'));

CREATE POLICY "payroll_delete" ON payroll
  FOR DELETE USING (get_my_role() = 'ceo');
