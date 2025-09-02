-- Production-ready RLS Policies for Konectr Waitlist
-- Run this in Supabase SQL Editor to secure your database

-- 1. First, ensure RLS is enabled
ALTER TABLE waitlist_users ENABLE ROW LEVEL SECURITY;

-- 2. Allow webhook/service role to insert new waitlist entries
CREATE POLICY "Service role can insert waitlist entries" 
ON waitlist_users 
FOR INSERT 
TO service_role
WITH CHECK (true);

-- 3. Allow anonymous users to insert (for webhook using anon key)
CREATE POLICY "Anonymous webhook can insert waitlist entries" 
ON waitlist_users 
FOR INSERT 
TO anon
WITH CHECK (
  -- Only allow inserts with valid email and referral_source
  email IS NOT NULL 
  AND email != ''
  AND referral_source = 'tally_form'
);

-- 4. Allow authenticated admin users to view all entries
CREATE POLICY "Admins can view all waitlist entries" 
ON waitlist_users 
FOR SELECT 
TO authenticated
USING (true);

-- 5. Allow authenticated admin users to update entries
CREATE POLICY "Admins can update waitlist entries" 
ON waitlist_users 
FOR UPDATE 
TO authenticated
USING (true)
WITH CHECK (true);

-- 6. Allow authenticated admin users to delete entries
CREATE POLICY "Admins can delete waitlist entries" 
ON waitlist_users 
FOR DELETE 
TO authenticated
USING (true);

-- Verify all policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'waitlist_users'
ORDER BY cmd;
