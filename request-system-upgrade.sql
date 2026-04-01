-- =============================================
-- Request System Upgrade Migration
-- Adds: request types, routing (target_type), improved RLS
-- =============================================

-- 1. Add new columns to requests table
ALTER TABLE requests ADD COLUMN IF NOT EXISTS request_type text;
ALTER TABLE requests ADD COLUMN IF NOT EXISTS target_type text NOT NULL DEFAULT 'branch_manager';
ALTER TABLE requests ADD COLUMN IF NOT EXISTS target_branch_id uuid REFERENCES branches(id);

-- 2. Indexes for performance
CREATE INDEX IF NOT EXISTS idx_requests_type ON requests(request_type);
CREATE INDEX IF NOT EXISTS idx_requests_target ON requests(target_type);
CREATE INDEX IF NOT EXISTS idx_requests_target_branch ON requests(target_branch_id);

-- 3. Update RLS policy for requests (read) - routing-aware
DROP POLICY IF EXISTS requests_read ON requests;
CREATE POLICY requests_read ON requests FOR SELECT USING (
  get_my_role() = 'ceo'
  OR created_by = auth.uid()
  OR target_type = 'all'
  OR (get_my_role() = 'admin' AND target_type = 'branch_manager' AND branch_id = get_my_branch_id())
  OR (get_my_role() = 'admin' AND target_type = 'specific_branch' AND target_branch_id = get_my_branch_id())
  OR (target_type = 'ceo' AND get_my_role() = 'ceo')
);

-- 4. Keep existing insert/update/delete policies unchanged
-- (managers can insert/update, which is already set)
