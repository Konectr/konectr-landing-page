-- Fix Supabase RLS Policy for Webhook Integration
-- Run this in your Supabase SQL Editor

-- Option 1: Create a policy that allows webhook inserts (RECOMMENDED)
CREATE POLICY "Allow webhook inserts for waitlist" 
ON waitlist_users 
FOR INSERT 
WITH CHECK (true);

-- Option 2: If you want to be more restrictive, allow only inserts with referral_source = 'tally_form'
-- CREATE POLICY "Allow tally webhook inserts only" 
-- ON waitlist_users 
-- FOR INSERT 
-- WITH CHECK (referral_source = 'tally_form');

-- Option 3: Temporarily disable RLS (NOT RECOMMENDED for production)
-- ALTER TABLE waitlist_users DISABLE ROW LEVEL SECURITY;

-- Verify the policy was created
SELECT * FROM pg_policies WHERE tablename = 'waitlist_users';
