-- Add is_closed column to branches table
ALTER TABLE branches ADD COLUMN IF NOT EXISTS is_closed boolean DEFAULT false;

-- Update RLS policy to allow managers to update branches
DROP POLICY IF EXISTS "Managers can update branches" ON branches;
CREATE POLICY "Managers can update branches" ON branches
  FOR UPDATE USING (get_my_role() IN ('ceo','admin'));

-- Allow managers to insert branches
DROP POLICY IF EXISTS "Managers can insert branches" ON branches;
CREATE POLICY "Managers can insert branches" ON branches
  FOR INSERT WITH CHECK (get_my_role() IN ('ceo','admin'));
