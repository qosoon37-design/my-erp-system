-- financial-upgrade.sql
-- v6.0 - Financial Dashboard, Viewer Role, Branch Sales, Report Upload

-- ============ 1. Branch Sales Table ============
CREATE TABLE IF NOT EXISTS branch_sales (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    branch_id uuid REFERENCES branches(id) ON DELETE CASCADE,
    month integer NOT NULL CHECK (month >= 1 AND month <= 12),
    year integer NOT NULL CHECK (year >= 2020 AND year <= 2100),
    total_sales numeric DEFAULT 0,
    total_expenses numeric DEFAULT 0,
    depreciation numeric DEFAULT 0,
    net_profit numeric GENERATED ALWAYS AS (total_sales - total_expenses - depreciation) STORED,
    notes text,
    created_by uuid REFERENCES auth.users(id),
    created_at timestamptz DEFAULT now(),
    UNIQUE(branch_id, month, year)
);

-- ============ 2. Financial Reports (uploaded files metadata) ============
CREATE TABLE IF NOT EXISTS financial_reports (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    title text NOT NULL,
    report_type text NOT NULL DEFAULT 'other',
    branch_id uuid REFERENCES branches(id),
    period_month integer,
    period_year integer,
    file_url text NOT NULL,
    file_name text NOT NULL,
    file_type text,
    notes text,
    uploaded_by uuid REFERENCES auth.users(id),
    created_at timestamptz DEFAULT now()
);

-- ============ 3. Enable RLS ============
ALTER TABLE branch_sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_reports ENABLE ROW LEVEL SECURITY;

-- ============ 4. Branch Sales Policies ============
CREATE POLICY branch_sales_read ON branch_sales FOR SELECT USING (
    get_my_role() IN ('ceo', 'admin', 'viewer')
);
CREATE POLICY branch_sales_write ON branch_sales FOR INSERT WITH CHECK (
    get_my_role() IN ('ceo', 'admin')
);
CREATE POLICY branch_sales_update ON branch_sales FOR UPDATE USING (
    get_my_role() IN ('ceo', 'admin')
);
CREATE POLICY branch_sales_delete ON branch_sales FOR DELETE USING (
    get_my_role() IN ('ceo', 'admin')
);

-- ============ 5. Financial Reports Policies ============
CREATE POLICY financial_reports_read ON financial_reports FOR SELECT USING (
    get_my_role() IN ('ceo', 'admin', 'viewer')
);
CREATE POLICY financial_reports_write ON financial_reports FOR INSERT WITH CHECK (
    get_my_role() IN ('ceo', 'admin')
);
CREATE POLICY financial_reports_delete ON financial_reports FOR DELETE USING (
    get_my_role() IN ('ceo', 'admin')
);

-- ============ 6. Storage Bucket for Reports ============
INSERT INTO storage.buckets (id, name, public) VALUES ('reports', 'reports', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "reports_upload" ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'reports' AND auth.role() = 'authenticated'
);
CREATE POLICY "reports_read" ON storage.objects FOR SELECT USING (
    bucket_id = 'reports' AND auth.role() = 'authenticated'
);
CREATE POLICY "reports_delete" ON storage.objects FOR DELETE USING (
    bucket_id = 'reports' AND auth.role() = 'authenticated'
);

-- ============ 7. Viewer Role - Read Access to Existing Tables ============
DROP POLICY IF EXISTS viewer_read_employees ON employees;
CREATE POLICY viewer_read_employees ON employees FOR SELECT USING (get_my_role() = 'viewer');

DROP POLICY IF EXISTS viewer_read_branches ON branches;
CREATE POLICY viewer_read_branches ON branches FOR SELECT USING (get_my_role() = 'viewer');

DROP POLICY IF EXISTS viewer_read_payroll ON payroll;
CREATE POLICY viewer_read_payroll ON payroll FOR SELECT USING (get_my_role() = 'viewer');

DROP POLICY IF EXISTS viewer_read_vacations ON vacations;
CREATE POLICY viewer_read_vacations ON vacations FOR SELECT USING (get_my_role() = 'viewer');

DROP POLICY IF EXISTS viewer_read_profiles ON profiles;
CREATE POLICY viewer_read_profiles ON profiles FOR SELECT USING (get_my_role() = 'viewer');

-- ============ 8. Update Requests RLS for Viewer ============
DROP POLICY IF EXISTS requests_read ON requests;
CREATE POLICY requests_read ON requests FOR SELECT USING (
    get_my_role() IN ('ceo', 'viewer')
    OR created_by = auth.uid()
    OR target_type = 'all'
    OR (get_my_role() = 'admin' AND target_type = 'branch_manager' AND branch_id = get_my_branch_id())
    OR (get_my_role() = 'admin' AND target_type = 'specific_branch' AND target_branch_id = get_my_branch_id())
    OR (target_type = 'ceo' AND get_my_role() = 'ceo')
);

-- ============ 9. Indexes ============
CREATE INDEX IF NOT EXISTS idx_branch_sales_branch ON branch_sales(branch_id);
CREATE INDEX IF NOT EXISTS idx_branch_sales_period ON branch_sales(year, month);
CREATE INDEX IF NOT EXISTS idx_financial_reports_type ON financial_reports(report_type);
CREATE INDEX IF NOT EXISTS idx_financial_reports_period ON financial_reports(period_year, period_month);
