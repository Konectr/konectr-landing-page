# Konectr MVP Technical Architecture

## FlutterFlow + Supabase Stack

### Database Schema (Supabase)

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(20) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  photo_url TEXT,
  location_area VARCHAR(100), -- General area, not exact location
  verified_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Activity slots
CREATE TABLE slots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  activity_type VARCHAR(50) NOT NULL, -- coffee, lunch, workout, etc.
  venue_area VARCHAR(100) NOT NULL, -- Bangsar, KLCC, etc.
  time_slot TIMESTAMP NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Matches
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_id UUID REFERENCES slots(id),
  requester_id UUID REFERENCES users(id),
  slot_owner_id UUID REFERENCES users(id),
  status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, declined, completed
  venue_selected VARCHAR(200),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Messages
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id),
  sender_id UUID REFERENCES users(id),
  content TEXT NOT NULL,
  sent_at TIMESTAMP DEFAULT NOW()
);

-- Safety reports
CREATE TABLE safety_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES users(id),
  reported_user_id UUID REFERENCES users(id),
  match_id UUID REFERENCES matches(id),
  reason VARCHAR(100),
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### FlutterFlow Integration Points

#### 1. Authentication Flow
- Supabase Auth with phone verification
- Custom onboarding screens
- Photo upload to Supabase Storage

#### 2. Real-time Subscriptions
```dart
// Listen for new matches
supabase
  .from('matches')
  .stream(primaryKey: ['id'])
  .eq('slot_owner_id', currentUserId)
  .listen((data) {
    // Update UI with new matches
  });

// Listen for new messages
supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('match_id', currentMatchId)
  .order('sent_at')
  .listen((data) {
    // Update chat UI
  });
```

#### 3. Location Handling
- Use Flutter location package with FlutterFlow custom code
- Store only general area (Bangsar, KLCC) for privacy
- Never store exact coordinates

### Performance Optimizations

#### 1. Caching Strategy
```dart
// Cache user profiles and venue data
SharedPreferences prefs = await SharedPreferences.getInstance();
// Cache recent matches for offline viewing
```

#### 2. Image Optimization
- Supabase image transformations
- Progressive loading for activity feed
- Compression before upload

#### 3. Battery Optimization
- Location services only during slot dropping and check-ins
- Smart notification batching
- Background sync limitations

### Security Implementation

#### 1. Data Protection
- Row Level Security (RLS) policies in Supabase
- End-to-end encryption for messages
- Automatic data cleanup (24-hour location data)

#### 2. Content Moderation
- Real-time text filtering
- Image content scanning via Supabase Edge Functions
- User reporting system

### Deployment Strategy

#### 1. Development Environment
- FlutterFlow preview for rapid iteration
- Supabase staging database
- Feature flags for gradual rollout

#### 2. Production Deployment
- Export Flutter code from FlutterFlow
- CI/CD pipeline with GitHub Actions
- Gradual rollout: 10% → 50% → 100%

## Success Metrics Tracking

### Analytics Events (Mixpanel Integration)
```dart
// Track key user actions
analytics.track('profile_completed', {
  'user_id': userId,
  'completion_time': completionTime,
  'verification_status': verified
});

analytics.track('slot_dropped', {
  'user_id': userId,
  'activity_type': activityType,
  'location_area': locationArea
});

analytics.track('match_created', {
  'match_id': matchId,
  'activity_type': activityType,
  'time_to_match': timeToMatch
});
```

### Performance Monitoring
- App launch time tracking
- API response time monitoring
- Crash reporting with Sentry
- Battery usage analytics

## MVP Launch Checklist

### Week 1: Foundation
- [ ] FlutterFlow project setup
- [ ] Supabase backend configuration
- [ ] Design system implementation
- [ ] Basic navigation structure

### Week 2: Core Features
- [ ] User authentication flow
- [ ] Profile setup screens
- [ ] Slot dropping functionality
- [ ] Basic discovery feed

### Week 3: Social Features
- [ ] Interest sending mechanism
- [ ] Match acceptance flow
- [ ] Basic messaging system
- [ ] Safety reporting features

### Week 4: Polish & Deploy
- [ ] Performance optimization
- [ ] Error handling improvement
- [ ] App store preparation
- [ ] Analytics implementation
- [ ] Beta testing with real users

## Post-MVP Roadmap

### Month 2: Enhanced Features
- Venue integration (Konectr Crowns)
- Advanced matching algorithms
- Group activities support
- Enhanced safety features

### Month 3: Scale & Optimize
- Performance improvements
- Advanced analytics
- International expansion prep
- Premium features planning
