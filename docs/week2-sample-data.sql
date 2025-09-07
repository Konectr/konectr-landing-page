-- =====================================================
-- KONECTR WEEK 2 SAMPLE DATA
-- =====================================================
-- This script inserts sample data for testing the Mood-Time-Venue flow
-- Run this AFTER running week2-database-schema.sql
-- =====================================================

-- =====================================================
-- SAMPLE USER AVAILABILITY DATA
-- =====================================================
-- Note: Replace the user_id values with actual user IDs from your auth.users table
-- You can get these by running: SELECT id FROM auth.users LIMIT 5;

-- Sample availability for testing (replace user_id with real IDs)
INSERT INTO user_availability (user_id, mood_id, time_slot_id, venue_id, date, notes) VALUES
-- User 1: Coffee Chat in the morning
((SELECT id FROM auth.users LIMIT 1), 
 (SELECT id FROM moods WHERE name = 'coffee_chat'), 
 (SELECT id FROM time_slots WHERE name = 'morning'), 
 (SELECT id FROM venues WHERE name = 'Starbucks KLCC'), 
 CURRENT_DATE, 
 'Looking for a casual coffee chat'),

-- User 2: Fitness in the afternoon  
((SELECT id FROM auth.users LIMIT 1 OFFSET 1), 
 (SELECT id FROM moods WHERE name = 'fitness'), 
 (SELECT id FROM time_slots WHERE name = 'afternoon'), 
 (SELECT id FROM venues WHERE name = 'Fitness First Pavilion'), 
 CURRENT_DATE, 
 'Gym buddy needed'),

-- User 3: Networking in the evening
((SELECT id FROM auth.users LIMIT 1 OFFSET 2), 
 (SELECT id FROM moods WHERE name = 'networking'), 
 (SELECT id FROM time_slots WHERE name = 'evening'), 
 (SELECT id FROM venues WHERE name = 'The Gardens Mall'), 
 CURRENT_DATE, 
 'Professional networking event'),

-- User 4: Creative in the morning
((SELECT id FROM auth.users LIMIT 1 OFFSET 3), 
 (SELECT id FROM moods WHERE name = 'creative'), 
 (SELECT id FROM time_slots WHERE name = 'morning'), 
 (SELECT id FROM venues WHERE name = 'KLCC Park'), 
 CURRENT_DATE, 
 'Art session in the park'),

-- User 5: Social in the evening
((SELECT id FROM auth.users LIMIT 1 OFFSET 4), 
 (SELECT id FROM moods WHERE name = 'social'), 
 (SELECT id FROM time_slots WHERE name = 'evening'), 
 (SELECT id FROM venues WHERE name = 'Zouk KL'), 
 CURRENT_DATE, 
 'Party night out'),

-- User 6: Food in the afternoon
((SELECT id FROM auth.users LIMIT 1 OFFSET 5), 
 (SELECT id FROM moods WHERE name = 'food'), 
 (SELECT id FROM time_slots WHERE name = 'afternoon'), 
 (SELECT id FROM venues WHERE name = 'Jalan Alor Food Court'), 
 CURRENT_DATE, 
 'Food adventure time')
ON CONFLICT (user_id, mood_id, time_slot_id, date) DO NOTHING;

-- =====================================================
-- TEST QUERIES
-- =====================================================

-- Test 1: Get all moods
-- SELECT * FROM moods ORDER BY sort_order;

-- Test 2: Get all time slots
-- SELECT * FROM time_slots ORDER BY sort_order;

-- Test 3: Get availability for Coffee Chat + Morning
-- SELECT * FROM get_availability_by_mood_time(
--     (SELECT id FROM moods WHERE name = 'coffee_chat'),
--     (SELECT id FROM time_slots WHERE name = 'morning'),
--     CURRENT_DATE
-- );

-- Test 4: Get availability for Fitness + Afternoon
-- SELECT * FROM get_availability_by_mood_time(
--     (SELECT id FROM moods WHERE name = 'fitness'),
--     (SELECT id FROM time_slots WHERE name = 'afternoon'),
--     CURRENT_DATE
-- );

-- Test 5: Get all active availability for today
-- SELECT 
--     m.display_name as mood,
--     ts.display_name as time_slot,
--     v.name as venue,
--     ua.date,
--     ua.notes
-- FROM user_availability ua
-- JOIN moods m ON ua.mood_id = m.id
-- JOIN time_slots ts ON ua.time_slot_id = ts.id
-- LEFT JOIN venues v ON ua.venue_id = v.id
-- WHERE ua.date = CURRENT_DATE
--     AND ua.status = 'active'
-- ORDER BY m.sort_order, ts.sort_order;

-- =====================================================
-- SAMPLE DATA COMPLETE
-- =====================================================
