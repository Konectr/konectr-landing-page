-- Test Database Setup for Konectr Integration Testing
-- Run this in your Supabase SQL Editor to ensure everything is ready

-- 1. Verify waitlist_users table exists and has correct structure
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'waitlist_users' 
ORDER BY ordinal_position;

-- 2. Check current data in waitlist_users table
SELECT 
  id,
  email,
  first_name,
  gender,
  area,
  age_range,
  data_processing_consent,
  marketing_consent,
  women_only_features_consent,
  referral_source,
  created_at
FROM waitlist_users 
ORDER BY created_at DESC 
LIMIT 10;

-- 3. Test insert permissions (this should work)
-- This is a test insert - you can delete it after testing
INSERT INTO waitlist_users (
  email, 
  first_name, 
  gender, 
  area, 
  age_range, 
  data_processing_consent,
  referral_source
) VALUES (
  'test@konectr.app',
  'Test User',
  'Female',
  'KLCC',
  '26-35',
  true,
  'manual_test'
);

-- 4. Verify the test insert worked
SELECT * FROM waitlist_users WHERE email = 'test@konectr.app';

-- 5. Clean up test data (optional)
-- DELETE FROM waitlist_users WHERE email = 'test@konectr.app';
