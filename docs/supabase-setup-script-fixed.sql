-- Konectr Supabase Database Setup Script (FIXED VERSION)
-- Run this in your Supabase SQL Editor after project creation
-- This version avoids permission errors with auth.users table

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create waitlist table for early users
CREATE TABLE waitlist_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE,
  first_name VARCHAR(100),
  gender VARCHAR(20) CHECK (gender IN ('Female', 'Male', 'Non-binary', 'Prefer not to say')),
  area VARCHAR(100), -- General area like "KLCC", "Bangsar" - NOT exact location
  age_range VARCHAR(10) CHECK (age_range IN ('18-25', '26-35', '36-45', '45+')),
  
  -- Consent tracking (PDPA compliance)
  data_processing_consent BOOLEAN NOT NULL DEFAULT false,
  marketing_consent BOOLEAN DEFAULT false,
  women_only_features_consent BOOLEAN DEFAULT false,
  
  -- Security fields
  ip_address INET,
  user_agent TEXT,
  referral_source VARCHAR(100),
  
  -- Verification status
  email_verified BOOLEAN DEFAULT false,
  phone_verified BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security for waitlist
ALTER TABLE waitlist_users ENABLE ROW LEVEL SECURITY;

-- Create user profiles table (for full app later)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Basic profile info
  display_name VARCHAR(100),
  age_range VARCHAR(10) CHECK (age_range IN ('18-25', '26-35', '36-45', '45+')),
  gender VARCHAR(20) CHECK (gender IN ('Female', 'Male', 'Non-binary', 'Prefer not to say')),
  
  -- Location (privacy-focused)
  area VARCHAR(100), -- General area only, never exact coordinates
  city VARCHAR(100) DEFAULT 'Kuala Lumpur',
  
  -- Profile media
  profile_photo_url TEXT,
  photo_verified BOOLEAN DEFAULT false,
  
  -- Safety & verification
  phone_verified BOOLEAN DEFAULT false,
  id_verified BOOLEAN DEFAULT false,
  safety_score INTEGER DEFAULT 100, -- Decreases with reports
  
  -- Preferences
  looking_for TEXT[], -- ['coffee', 'lunch', 'workout', 'study']
  women_only_mode BOOLEAN DEFAULT false, -- For female users who want women-only spaces
  
  -- Activity preferences
  preferred_times TEXT[], -- ['morning', 'afternoon', 'evening', 'weekend']
  activity_radius INTEGER DEFAULT 5, -- km radius for activity discovery
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_active TIMESTAMP DEFAULT NOW()
);

-- Enable RLS for user profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access their own profile
CREATE POLICY "Users can manage own profile" ON user_profiles
  FOR ALL USING (auth.uid() = user_id);

-- Create activity slots table
CREATE TABLE activity_slots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Activity details
  activity_type VARCHAR(50) NOT NULL, -- 'coffee', 'lunch', 'workout', 'study', etc.
  title VARCHAR(200) NOT NULL,
  description TEXT,
  
  -- Location (privacy-focused)
  area VARCHAR(100) NOT NULL, -- 'Bangsar', 'KLCC', etc.
  venue_name VARCHAR(200), -- Optional specific venue
  
  -- Timing
  scheduled_for TIMESTAMP NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  flexible_timing BOOLEAN DEFAULT false, -- Can be +/- 30 minutes
  
  -- Slot settings
  max_participants INTEGER DEFAULT 1, -- 1 for 1-on-1, higher for group activities
  women_only BOOLEAN DEFAULT false, -- Restricts to female users only
  age_range_preference VARCHAR(20), -- Preferred age range of participants
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  is_filled BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP -- Auto-cleanup old slots
);

-- Enable RLS for activity slots
ALTER TABLE activity_slots ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can see public slots and manage their own
CREATE POLICY "Users can view active slots" ON activity_slots
  FOR SELECT USING (
    is_active = true AND 
    expires_at > NOW() AND
    (women_only = false OR 
     (women_only = true AND 
      EXISTS(SELECT 1 FROM user_profiles WHERE user_id = auth.uid() AND gender = 'Female')
     )
    )
  );

CREATE POLICY "Users can manage own slots" ON activity_slots
  FOR ALL USING (auth.uid() = user_id);

-- Create matches table
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slot_id UUID REFERENCES activity_slots(id) ON DELETE CASCADE,
  requester_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  slot_owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Match status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'completed', 'cancelled')),
  
  -- Meeting details
  venue_selected VARCHAR(200),
  final_time TIMESTAMP,
  
  -- Safety & verification
  requester_checked_in BOOLEAN DEFAULT false,
  owner_checked_in BOOLEAN DEFAULT false,
  both_checked_in_at TIMESTAMP,
  
  -- Ratings (post-meetup)
  requester_rating INTEGER CHECK (requester_rating BETWEEN 1 AND 5),
  owner_rating INTEGER CHECK (owner_rating BETWEEN 1 AND 5),
  would_meet_again BOOLEAN,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP
);

-- Enable RLS for matches
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see their own matches
CREATE POLICY "Users can view own matches" ON matches
  FOR SELECT USING (auth.uid() = requester_id OR auth.uid() = slot_owner_id);

CREATE POLICY "Users can update own matches" ON matches
  FOR UPDATE USING (auth.uid() = requester_id OR auth.uid() = slot_owner_id);

-- Create messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Message content (encrypted)
  content TEXT NOT NULL,
  message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'system', 'image')),
  
  -- Status
  read_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS for messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see messages from their matches
CREATE POLICY "Users can view messages from own matches" ON messages
  FOR SELECT USING (
    EXISTS(
      SELECT 1 FROM matches 
      WHERE matches.id = messages.match_id 
      AND (matches.requester_id = auth.uid() OR matches.slot_owner_id = auth.uid())
    )
  );

-- Create safety reports table
CREATE TABLE safety_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  reported_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  match_id UUID REFERENCES matches(id) ON DELETE SET NULL,
  
  -- Report details
  reason VARCHAR(100) NOT NULL, -- 'harassment', 'fake_profile', 'no_show', 'inappropriate_behavior'
  description TEXT,
  severity VARCHAR(20) DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  
  -- Evidence
  screenshot_urls TEXT[],
  additional_evidence TEXT,
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
  admin_notes TEXT,
  resolved_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS for safety reports
ALTER TABLE safety_reports ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see their own reports
CREATE POLICY "Users can view own safety reports" ON safety_reports
  FOR SELECT USING (auth.uid() = reporter_id);

-- Create analytics events table
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  
  -- Event data
  event_name VARCHAR(100) NOT NULL,
  properties JSONB,
  
  -- Context
  ip_address INET,
  user_agent TEXT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS for analytics
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see their own analytics
CREATE POLICY "Users can view own analytics" ON analytics_events
  FOR SELECT USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX idx_waitlist_email ON waitlist_users(email);
CREATE INDEX idx_waitlist_created ON waitlist_users(created_at);
CREATE INDEX idx_user_profiles_area ON user_profiles(area);
CREATE INDEX idx_slots_active ON activity_slots(is_active, expires_at);
CREATE INDEX idx_slots_area ON activity_slots(area, scheduled_for);
CREATE INDEX idx_matches_status ON matches(status, created_at);
CREATE INDEX idx_messages_match ON messages(match_id, created_at);
CREATE INDEX idx_safety_reports_status ON safety_reports(status, created_at);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to relevant tables
CREATE TRIGGER update_waitlist_users_updated_at BEFORE UPDATE ON waitlist_users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_activity_slots_updated_at BEFORE UPDATE ON activity_slots FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create functions for common operations
-- Function to safely get user's area (privacy-focused)
CREATE OR REPLACE FUNCTION get_user_general_area(user_uuid UUID)
RETURNS TEXT AS $$
BEGIN
  RETURN (SELECT area FROM user_profiles WHERE user_id = user_uuid);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user can see a slot (women-only logic)
CREATE OR REPLACE FUNCTION can_user_see_slot(slot_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS(
    SELECT 1 FROM activity_slots s
    LEFT JOIN user_profiles up ON up.user_id = user_uuid
    WHERE s.id = slot_uuid
    AND s.is_active = true
    AND s.expires_at > NOW()
    AND (s.women_only = false OR (s.women_only = true AND up.gender = 'Female'))
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Setup complete message
SELECT 'Konectr database setup completed successfully! 🚀' as status;
