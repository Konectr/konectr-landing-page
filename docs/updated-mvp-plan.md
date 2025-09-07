# Konectr Updated MVP Development Plan (Mood-Time-Venue Flow)

## **Updated User Flow Architecture**
**New Flow:** Pick Mood → Pick Time Slot → Pick Venue → Browse Others → Express Interest → Match

---

## **Updated Weekly Ship Plan (12 weeks)**

| Week | Outcome | Tool(s) | My 12-hr Blocks | Success Metric |
|------|---------|---------|-----------------|----------------|
| 1 | Landing page + waitlist | Netlify + Tally + Supabase Setup | Setup(4h) + Content(4h) + Design(4h) | 50 signups ✓ |
| 2 | **Mood + Time Slot System** | Figma + Supabase schema | MoodUI(4h) + TimeSlots(4h) + Testing(4h) | 6 mood categories + 4 time slots working |
| 3 | **Venue Discovery + Google Maps** | FlutterFlow + Google Maps API | VenueAPI(4h) + CategoryUI(4h) + Integration(4h) | Venue search by category working |
| 4 | **Browse Users Flow + Interest System** | FlutterFlow + Supabase | BrowseUI(4h) + InterestLogic(4h) + UserCards(4h) | Users can browse and express interest |
| 5 | **Matching Engine + Mutual Interest** | FlutterFlow + Supabase | MatchLogic(4h) + MatchUI(4h) + Messaging(4h) | Mutual interest creates matches |
| 6 | **User Profiles + Verification** | FlutterFlow + Supabase | ProfileUI(4h) + Verification(4h) + Safety(4h) | Complete user profiles with verification |
| 7 | **Women-Only Filter + Safety Features** | FlutterFlow | SafetyToggles(4h) + WomenFilter(4h) + Reporting(4h) | Women-only mode functional |
| 8 | **Check-ins + GPS Verification** | FlutterFlow + GPS APIs | CheckinUI(4h) + GPSLogic(4h) + Verification(4h) | Location-based check-ins work |
| 9 | **Push Notifications + Real-time Updates** | OneSignal + FlutterFlow | Notifications(4h) + RealTime(4h) + Testing(4h) | Users get match notifications |
| 10 | **Rating System + Post-Meetup Flow** | FlutterFlow + Supabase | RatingUI(4h) + FeedbackFlow(4h) + Analytics(4h) | Post-meetup experience complete |
| 11 | **Performance Optimization + Bug Fixes** | FlutterFlow | Performance(4h) + BugFixes(4h) + Polish(4h) | <3s load times, smooth UX |
| 12 | **Launch Preparation + User Testing** | FlutterFlow + TestFlight | LaunchPrep(4h) + UserTesting(4h) + Refinement(4h) | Ready for beta launch |

---

## **Updated Database Schema Changes**

### **New Tables Required:**

**Moods Table:**
```sql
CREATE TABLE moods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL, -- 'Coffee Chat', 'Fitness', 'Networking', 'Creative', 'Social', 'Food'
    icon_url TEXT,
    color_code TEXT,
    description TEXT
);
```

**Time Slots Table:**
```sql
CREATE TABLE time_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL, -- 'Morning', 'Afternoon', 'Evening', 'Late Night'
    start_time TIME NOT NULL, -- 06:00, 12:00, 18:00, 00:00
    end_time TIME NOT NULL, -- 12:00, 18:00, 00:00, 06:00
    is_active BOOLEAN DEFAULT TRUE
);
```

**Updated User Availability Table:**
```sql
CREATE TABLE user_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    mood_id UUID REFERENCES moods(id),
    time_slot_id UUID REFERENCES time_slots(id),
    venue_id UUID REFERENCES venues(id),
    date DATE NOT NULL,
    status TEXT DEFAULT 'active', -- 'active', 'matched', 'expired'
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Updated Venues Table:**
```sql
ALTER TABLE venues ADD COLUMN category TEXT; -- 'gym', 'restaurant', 'cafe', 'club', 'pub', 'bar'
ALTER TABLE venues ADD COLUMN google_place_id TEXT;
ALTER TABLE venues ADD COLUMN rating DECIMAL(2,1);
ALTER TABLE venues ADD COLUMN price_level INTEGER; -- 1-4 scale
```

---

## **Updated Technical Architecture**

### **Core User Flow Implementation:**

**Step 1: Mood Selection**
- 6 predefined moods with icons and colors
- Single selection UI with visual feedback
- Store mood_id for user session

**Step 2: Time Slot Selection**
- 4 fixed time slots displayed as cards
- Show current time indicator
- Disable past time slots for today

**Step 3: Venue Discovery**
- Google Maps API integration for venue search
- Filter by category (gym, restaurant, cafe, club, pub, bar)
- Show distance, rating, price level
- Allow venue selection from map or list view

**Step 4: Browse Available Users**
- Query users with same mood + time slot + venue
- Display user cards with basic info and verification badges
- Show "Express Interest" button for each user

**Step 5: Interest & Matching**
- Send interest notification to target user
- If mutual interest → create match
- Open basic messaging channel

---

## **Updated Core Features List:**

### **Week 2-4 MVP Core:**
1. **Mood Selection System** (6 categories with visual UI)
2. **Fixed Time Slot Picker** (4 time periods)
3. **Venue Category Browser** (6 venue types)
4. **Google Maps Venue Discovery** (search by location + category)
5. **User Browse Interface** (see others at same venue/time)
6. **Express Interest System** (send/receive interest)
7. **Mutual Interest Matching** (creates match when both interested)

### **Week 5-8 Safety & Polish:**
8. **User Profile Creation** (photos, verification, interests)
9. **Phone Verification System** (OTP-based)
10. **Women-Only Toggle** (female users can filter to women-only)
11. **User Reporting & Blocking** (safety features)
12. **Basic In-App Messaging** (for matched users)

### **Week 9-12 Launch Features:**
13. **GPS Check-in System** (verify users actually met)
14. **Post-Meetup Rating** (rate user and venue)
15. **Push Notifications** (match alerts, reminders)
16. **Real-time Status Updates** (online/offline, "on the way")

---

## **Updated Success Metrics by Week:**

**Week 2:** Mood + time slot selection working smoothly
**Week 3:** Can discover and select venues using Google Maps
**Week 4:** Users can browse others and express interest
**Week 5:** Mutual interest creates functional matches
**Week 6:** Complete user profiles with verification working
**Week 7:** Women-only filter reduces safety concerns
**Week 8:** Check-ins verify real-world meetups
**Week 9:** Push notifications drive user engagement
**Week 10:** Rating system provides feedback loop
**Week 11:** App performance meets quality standards
**Week 12:** Beta-ready for initial user testing

---

## **Key Technical Dependencies:**

**Google Maps API:** Required for venue discovery (Week 3)
**OneSignal:** Push notification service (Week 9)
**Phone Verification:** Twilio or similar (Week 6)
**Image Storage:** Supabase storage for profile photos (Week 6)
**Real-time:** Supabase real-time for messaging and status (Week 9)

---

## **Updated Agent Assignments:**

**@ConsumerMaster:** User experience for mood → time → venue flow
**@MobileLead:** FlutterFlow implementation of browse and interest system
**@SecurityLead:** Women-only filtering and verification system
**@VenueLead:** Google Maps API integration and venue data management
**@UXLead:** Interface design for simplified 3-step user flow

This updated plan reflects your refined product vision: a venue-first, time-slot-based social discovery app rather than a flexible availability matching system.