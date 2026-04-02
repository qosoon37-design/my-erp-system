-- permissions-reports-upgrade.sql
-- v6.1 - Permissions System + Monthly Financial Reports

-- ============ 1. Add permissions column to profiles ============
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS permissions jsonb DEFAULT '{}';

-- ============ 2. Monthly Financial Reports Table ============
CREATE TABLE IF NOT EXISTS monthly_reports (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    branch_id uuid REFERENCES branches(id),
    period_start date NOT NULL,
    period_end date NOT NULL,
    total_sales numeric DEFAULT 0,
    tax numeric DEFAULT 0,
    cogs numeric DEFAULT 0,
    expenses numeric DEFAULT 0,
    operator_percentage numeric DEFAULT 30,
    notes text,
    created_by uuid REFERENCES auth.users(id),
    created_at timestamptz DEFAULT now()
);

ALTER TABLE monthly_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY monthly_reports_read ON monthly_reports FOR SELECT USING (get_my_role() IN ('ceo','admin','viewer'));
CREATE POLICY monthly_reports_write ON monthly_reports FOR INSERT WITH CHECK (get_my_role() IN ('ceo','admin'));
CREATE POLICY monthly_reports_update ON monthly_reports FOR UPDATE USING (get_my_role() IN ('ceo','admin'));
CREATE POLICY monthly_reports_delete ON monthly_reports FOR DELETE USING (get_my_role() IN ('ceo','admin'));

CREATE INDEX IF NOT EXISTS idx_monthly_reports_period ON monthly_reports(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_monthly_reports_branch ON monthly_reports(branch_id);

NOTIFY pgrst, 'reload schema';
