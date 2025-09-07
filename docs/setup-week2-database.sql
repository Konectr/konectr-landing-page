-- =====================================================
-- KONECTR WEEK 2 DATABASE SETUP - QUICK START
-- =====================================================
-- This is a simplified version for quick setup
-- Run this in your Supabase SQL editor
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. MOODS TABLE (6 categories)
-- =====================================================
CREATE TABLE IF NOT EXISTS moods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    icon_url TEXT,
    color_code TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. TIME SLOTS TABLE (4 periods)
-- =====================================================
CREATE TABLE IF NOT EXISTS time_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. USER AVAILABILITY TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS user_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    mood_id UUID NOT NULL REFERENCES moods(id) ON DELETE CASCADE,
    time_slot_id UUID NOT NULL REFERENCES time_slots(id) ON DELETE CASCADE,
    venue_id UUID REFERENCES venues(id) ON DELETE SET NULL,
    date DATE NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'matched', 'expired', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, mood_id, time_slot_id, date)
);

-- =====================================================
-- 4. INSERT MOODS DATA
-- =====================================================
INSERT INTO moods (name, display_name, icon_url, color_code, description, sort_order) VALUES
('coffee_chat', 'Coffee Chat', '☕', '#FF774D', 'Casual conversations over coffee', 1),
('fitness', 'Fitness', '💪', '#FFC845', 'Workouts, runs, and active pursuits', 2),
('networking', 'Networking', '🤝', '#4CAF50', 'Professional connections and career growth', 3),
('creative', 'Creative', '🎨', '#9C27B0', 'Art, music, writing, and creative projects', 4),
('social', 'Social', '🎉', '#E91E63', 'Parties, events, and social gatherings', 5),
('food', 'Food', '🍽️', '#FF5722', 'Dining, cooking, and culinary experiences', 6)
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 5. INSERT TIME SLOTS DATA
-- =====================================================
INSERT INTO time_slots (name, display_name, start_time, end_time, description, sort_order) VALUES
('morning', 'Morning', '06:00:00', '12:00:00', 'Early morning to noon', 1),
('afternoon', 'Afternoon', '12:00:00', '18:00:00', 'Noon to evening', 2),
('evening', 'Evening', '18:00:00', '00:00:00', 'Evening to midnight', 3),
('late_night', 'Late Night', '00:00:00', '06:00:00', 'Midnight to early morning', 4)
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 6. ENABLE RLS
-- =====================================================
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_availability ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 7. CREATE RLS POLICIES
-- =====================================================

-- Moods: Public read access
CREATE POLICY "Moods are viewable by everyone" ON moods
    FOR SELECT USING (is_active = true);

-- Time slots: Public read access  
CREATE POLICY "Time slots are viewable by everyone" ON time_slots
    FOR SELECT USING (is_active = true);

-- User availability: Users can see all active availability
CREATE POLICY "Users can view all active availability" ON user_availability
    FOR SELECT USING (status = 'active');

CREATE POLICY "Users can insert their own availability" ON user_availability
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own availability" ON user_availability
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own availability" ON user_availability
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 8. CREATE INDEXES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_user_availability_user_id ON user_availability(user_id);
CREATE INDEX IF NOT EXISTS idx_user_availability_mood_time ON user_availability(mood_id, time_slot_id, date);
CREATE INDEX IF NOT EXISTS idx_user_availability_status ON user_availability(status);

-- =====================================================
-- 9. HELPER FUNCTION
-- =====================================================
CREATE OR REPLACE FUNCTION get_availability_by_mood_time(
    p_mood_id UUID,
    p_time_slot_id UUID,
    p_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    availability_id UUID,
    user_id UUID,
    user_name TEXT,
    venue_name TEXT,
    venue_address TEXT,
    notes TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ua.id,
        ua.user_id,
        COALESCE(profiles.display_name, 'Anonymous') as user_name,
        COALESCE(v.name, 'TBD') as venue_name,
        COALESCE(v.address, 'Location TBD') as venue_address,
        ua.notes
    FROM user_availability ua
    LEFT JOIN profiles ON ua.user_id = profiles.id
    LEFT JOIN venues v ON ua.venue_id = v.id
    WHERE ua.mood_id = p_mood_id
        AND ua.time_slot_id = p_time_slot_id
        AND ua.date = p_date
        AND ua.status = 'active'
        AND ua.user_id != auth.uid() -- Exclude current user
    ORDER BY ua.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SETUP COMPLETE!
-- =====================================================
-- 
-- Next steps:
-- 1. Test with: SELECT * FROM moods;
-- 2. Test with: SELECT * FROM time_slots;
-- 3. Create some test availability data
-- 4. Begin Week 2 FlutterFlow development
-- =====================================================
