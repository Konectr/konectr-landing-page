-- Fix RLS Policies for Webhook Integration
-- Run this in Supabase SQL Editor

-- 1. First, drop all existing policies on waitlist_users
DROP POLICY IF EXISTS "Allow webhook inserts for waitlist" ON waitlist_users;
DROP POLICY IF EXISTS "Service role can insert waitlist entries" ON waitlist_users;
DROP POLICY IF EXISTS "Anonymous webhook can insert waitlist entries" ON waitlist_users;
DROP POLICY IF EXISTS "Admins can view all waitlist entries" ON waitlist_users;
DROP POLICY IF EXISTS "Admins can update waitlist entries" ON waitlist_users;
DROP POLICY IF EXISTS "Admins can delete waitlist entries" ON waitlist_users;

-- 2. Create a simple policy that allows anonymous inserts
CREATE POLICY "Enable insert for anon users" 
ON waitlist_users 
FOR INSERT 
TO anon
WITH CHECK (true);

-- 3. Allow authenticated users to select their own data (optional)
CREATE POLICY "Enable read access for authenticated users" 
ON waitlist_users 
FOR SELECT 
TO authenticated
USING (true);

-- 4. Verify the policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'waitlist_users';
