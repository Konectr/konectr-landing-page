-- Temporarily disable RLS to test webhook integration
-- Run this in Supabase SQL Editor

-- 1. Disable RLS on waitlist_users table
ALTER TABLE waitlist_users DISABLE ROW LEVEL SECURITY;

-- 2. Verify RLS is disabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'waitlist_users';

-- 3. After testing is complete and working, you can re-enable RLS with proper policies:
-- ALTER TABLE waitlist_users ENABLE ROW LEVEL SECURITY;
-- Then create appropriate policies for your use case
