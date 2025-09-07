-- =====================================================
-- KONECTR WEEK 2 DATABASE SCHEMA - MOOD-TIME-VENUE FLOW
-- =====================================================
-- This script creates the core tables for the new user flow:
-- Pick Mood → Pick Time Slot → Pick Venue → Browse Others → Express Interest → Match
-- 
-- Tables created:
-- 1. moods (6 categories with icons and colors)
-- 2. time_slots (4 time periods)
-- 3. user_availability (updated for new flow)
-- 4. Sample data for testing
-- 5. RLS policies for security
-- =====================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. MOODS TABLE
-- =====================================================
-- 6 predefined mood categories for user selection
CREATE TABLE IF NOT EXISTS moods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    icon_url TEXT,
    color_code TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. TIME SLOTS TABLE
-- =====================================================
-- 4 fixed time periods for user availability
CREATE TABLE IF NOT EXISTS time_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. UPDATED USER AVAILABILITY TABLE
-- =====================================================
-- Links users to their mood + time slot + venue preferences
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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure unique combination per user per day
    UNIQUE(user_id, mood_id, time_slot_id, date)
);

-- =====================================================
-- 4. VENUES TABLE UPDATES (if not exists)
-- =====================================================
-- Add new columns to existing venues table
ALTER TABLE venues ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS google_place_id TEXT;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS rating DECIMAL(2,1);
ALTER TABLE venues ADD COLUMN IF NOT EXISTS price_level INTEGER CHECK (price_level BETWEEN 1 AND 4);
ALTER TABLE venues ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- =====================================================
-- 5. INTERESTS TABLE (for Week 4)
-- =====================================================
-- Track when users express interest in each other
CREATE TABLE IF NOT EXISTS interests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    to_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    availability_id UUID NOT NULL REFERENCES user_availability(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'expired')),
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate interests
    UNIQUE(from_user_id, to_user_id, availability_id)
);

-- =====================================================
-- 6. MATCHES TABLE (for Week 5)
-- =====================================================
-- Created when mutual interest is expressed
CREATE TABLE IF NOT EXISTS matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    availability_id UUID NOT NULL REFERENCES user_availability(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled', 'expired')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure unique matches
    UNIQUE(user1_id, user2_id, availability_id)
);

-- =====================================================
-- 7. INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_user_availability_user_id ON user_availability(user_id);
CREATE INDEX IF NOT EXISTS idx_user_availability_mood_time ON user_availability(mood_id, time_slot_id, date);
CREATE INDEX IF NOT EXISTS idx_user_availability_status ON user_availability(status);
CREATE INDEX IF NOT EXISTS idx_interests_from_user ON interests(from_user_id);
CREATE INDEX IF NOT EXISTS idx_interests_to_user ON interests(to_user_id);
CREATE INDEX IF NOT EXISTS idx_interests_status ON interests(status);
CREATE INDEX IF NOT EXISTS idx_matches_users ON matches(user1_id, user2_id);
CREATE INDEX IF NOT EXISTS idx_venues_category ON venues(category);
CREATE INDEX IF NOT EXISTS idx_venues_active ON venues(is_active);

-- =====================================================
-- 8. ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE interests ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- Moods: Public read access
CREATE POLICY "Moods are viewable by everyone" ON moods
    FOR SELECT USING (is_active = true);

-- Time slots: Public read access
CREATE POLICY "Time slots are viewable by everyone" ON time_slots
    FOR SELECT USING (is_active = true);

-- User availability: Users can only see their own and others' active availability
CREATE POLICY "Users can view all active availability" ON user_availability
    FOR SELECT USING (status = 'active');

CREATE POLICY "Users can insert their own availability" ON user_availability
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own availability" ON user_availability
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own availability" ON user_availability
    FOR DELETE USING (auth.uid() = user_id);

-- Interests: Users can see interests they sent/received
CREATE POLICY "Users can view their own interests" ON interests
    FOR SELECT USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

CREATE POLICY "Users can insert interests they send" ON interests
    FOR INSERT WITH CHECK (auth.uid() = from_user_id);

CREATE POLICY "Users can update interests they received" ON interests
    FOR UPDATE USING (auth.uid() = to_user_id);

-- Matches: Users can see their own matches
CREATE POLICY "Users can view their own matches" ON matches
    FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- =====================================================
-- 9. SAMPLE DATA INSERTS
-- =====================================================

-- Insert moods data
INSERT INTO moods (name, display_name, icon_url, color_code, description, sort_order) VALUES
('coffee_chat', 'Coffee Chat', '☕', '#FF774D', 'Casual conversations over coffee', 1),
('fitness', 'Fitness', '💪', '#FFC845', 'Workouts, runs, and active pursuits', 2),
('networking', 'Networking', '🤝', '#4CAF50', 'Professional connections and career growth', 3),
('creative', 'Creative', '🎨', '#9C27B0', 'Art, music, writing, and creative projects', 4),
('social', 'Social', '🎉', '#E91E63', 'Parties, events, and social gatherings', 5),
('food', 'Food', '🍽️', '#FF5722', 'Dining, cooking, and culinary experiences', 6)
ON CONFLICT (name) DO NOTHING;

-- Insert time slots data
INSERT INTO time_slots (name, display_name, start_time, end_time, description, sort_order) VALUES
('morning', 'Morning', '06:00:00', '12:00:00', 'Early morning to noon', 1),
('afternoon', 'Afternoon', '12:00:00', '18:00:00', 'Noon to evening', 2),
('evening', 'Evening', '18:00:00', '00:00:00', 'Evening to midnight', 3),
('late_night', 'Late Night', '00:00:00', '06:00:00', 'Midnight to early morning', 4)
ON CONFLICT (name) DO NOTHING;

-- Insert sample venue categories (if venues table exists)
-- Note: This assumes you have a venues table. Adjust as needed.
INSERT INTO venues (name, address, latitude, longitude, category, rating, price_level, is_active) VALUES
('Starbucks KLCC', 'Kuala Lumpur City Centre, 50088 Kuala Lumpur', 3.1579, 101.7116, 'cafe', 4.2, 2, true),
('Fitness First Pavilion', 'Pavilion Kuala Lumpur, 55100 Kuala Lumpur', 3.1494, 101.7107, 'gym', 4.5, 3, true),
('Jalan Alor Food Court', 'Jalan Alor, 50200 Kuala Lumpur', 3.1478, 101.7042, 'restaurant', 4.0, 1, true),
('KLCC Park', 'Kuala Lumpur City Centre, 50088 Kuala Lumpur', 3.1579, 101.7116, 'outdoor', 4.3, 1, true),
('The Gardens Mall', 'Mid Valley City, 59200 Kuala Lumpur', 3.1189, 101.6769, 'shopping', 4.1, 2, true),
('Zouk KL', 'TREC, 55100 Kuala Lumpur', 3.1494, 101.7107, 'club', 4.0, 3, true)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 10. HELPER FUNCTIONS
-- =====================================================

-- Function to get active availability by mood and time slot
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

-- Function to create a match from mutual interests
CREATE OR REPLACE FUNCTION create_match_from_interests(
    p_user1_id UUID,
    p_user2_id UUID,
    p_availability_id UUID
)
RETURNS UUID AS $$
DECLARE
    match_id UUID;
BEGIN
    -- Check if mutual interest exists
    IF EXISTS (
        SELECT 1 FROM interests 
        WHERE from_user_id = p_user1_id 
            AND to_user_id = p_user2_id 
            AND availability_id = p_availability_id
            AND status = 'accepted'
    ) AND EXISTS (
        SELECT 1 FROM interests 
        WHERE from_user_id = p_user2_id 
            AND to_user_id = p_user1_id 
            AND availability_id = p_availability_id
            AND status = 'accepted'
    ) THEN
        -- Create match
        INSERT INTO matches (user1_id, user2_id, availability_id)
        VALUES (p_user1_id, p_user2_id, p_availability_id)
        RETURNING id INTO match_id;
        
        -- Update availability status
        UPDATE user_availability 
        SET status = 'matched' 
        WHERE id = p_availability_id;
        
        RETURN match_id;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 11. TRIGGERS FOR UPDATED_AT
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to all tables
CREATE TRIGGER update_moods_updated_at BEFORE UPDATE ON moods
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_time_slots_updated_at BEFORE UPDATE ON time_slots
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_availability_updated_at BEFORE UPDATE ON user_availability
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_interests_updated_at BEFORE UPDATE ON interests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SCHEMA CREATION COMPLETE
-- =====================================================
-- 
-- Next steps:
-- 1. Run this script in your Supabase SQL editor
-- 2. Test the sample data with the helper functions
-- 3. Begin Week 2 development with mood and time slot selection
-- 4. Use the get_availability_by_mood_time() function for browsing
-- 5. Use create_match_from_interests() for Week 5 matching logic
--
-- =====================================================
