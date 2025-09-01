# KONECTR_MOBILE_RULES.md

> 🧭 Konectr Engineering Doctrine — Agent-Driven Development

Obsessively clean, maintainable, high-performance approach to building Konectr's dual-platform ecosystem (Consumer App + Konectr Crowns) with specialized AI agent oversight and long-term engineering excellence.

───────────────────────────────────────────────
📚 KONECTR ENGINEERING FUNDAMENTALS

## AGENT DECISION AUTHORITY
- **ConsumerMaster**: Final UX/UI decisions, user flow approvals
- **BusinessMaster**: B2B feature priorities, venue partner requirements  
- **InfraMaster**: Architecture decisions, scaling strategies, security standards
- **QualityMaster**: Quality gates, release criteria, performance thresholds

## CODE STYLE & FORMATTING
- **Auto-formatting:** Prettier (JS/TS), Black (Python), GoFmt (Go) - enforced pre-commit
- **Naming conventions:**
  - kebab-case for folders (`/activity-matching`, `/venue-discovery`)
  - camelCase for JS/TS files (`activityCard.tsx`, `matchingService.ts`)
  - snake_case for Python (`user_service.py`, `matching_algorithm.py`)
- **Intent-driven naming:** `getUserActiveSlots()` not `getData()`, `isMatchCompatible()` not `check()`
- **Comments:** Explain WHY, not WHAT. Code should be self-documenting

## ARCHITECTURE & PROJECT STRUCTURE
```
/src
  /app           → UI entrypoints (main.dart, App.tsx)
  /features      → domain logic organized by user flow
    /onboarding
    /profile-setup  
    /slot-dropping
    /activity-matching
    /venue-discovery
    /messaging
    /check-ins
    /safety-reporting
  /entities      → core data models (User, Slot, Venue, Match)
  /shared        → utilities, hooks, services
    /components  → 8 core design system components
    /services    → supabase, notifications, analytics
    /utilities   → location, validation, formatting
    /theme       → konectr brand colors, typography scale
  /pages         → route-level components (if web)
```

## UNIDIRECTIONAL FLOW ENFORCEMENT
**UI → Service → Logic → Database**
- Components call services, never direct DB access
- Services handle API/DB calls, return clean data
- Business logic lives in dedicated modules
- Database layer abstracted behind service interface

───────────────────────────────────────────────
1. PROJECT STRUCTURE & ARCHITECTURE (KONECTR)
───────────────────────────────────────────────

### KONECTR FEATURE ORGANIZATION
```
/src
  /features
    /onboarding
    /profile-setup
    /slot-dropping
    /activity-matching
    /venue-discovery
    /messaging
    /check-ins
    /safety-reporting
  /shared
    /components (8 core components from design system)
    /services (supabase, notifications, analytics)
    /utilities (location, validation, formatting)
    /theme (konectr brand colors, typography scale)
```

### KONECTR DESIGN SYSTEM INTEGRATION
- Theme constants: Sunset Orange #FF774D, Solar Amber #FFC845, Graphite Grey #1F1F1F, Cloud White #FAFAFA
- Typography: Inter (body), Manrope (headings), exact scale from brand guidelines
- Components: 8 core components (ActivityCard, SlotPill, VenueCard, MatchModal, SafetyBadge, CTAButton, Toast, EmptyState)

───────────────────────────────────────────────
2. NAVIGATION & STATE MANAGEMENT (KONECTR)
───────────────────────────────────────────────

### KONECTR USER FLOWS
- **Core Navigation:** Onboarding → Profile → Discovery → Matching → Messaging → Meetup → Rating
- **Deep Links:** `/profile`, `/slot/[id]`, `/match/[id]`, `/venue/[id]`, `/check-in/[matchId]`
- **Safety Exits:** Every screen must have clear path to safety reporting

### STATE MANAGEMENT RULES
- **User state:** Profile, preferences, verification status (persistent)
- **Activity state:** Available slots, matches, check-ins (real-time via Supabase)
- **Venue state:** Partner venues, offers, analytics (cached with refresh)
- **UI state:** Loading states, modal visibility, form data (local only)

───────────────────────────────────────────────
3. UI/UX & COMPONENT COMPOSITION (KONECTR)
───────────────────────────────────────────────

### KONECTR ATOMIC DESIGN IMPLEMENTATION
- **Atoms:** CTAButton, SafetyBadge, SlotPill, Toast
- **Molecules:** ActivityCard, VenueCard, MatchModal  
- **Organisms:** Activity Feed, Venue List, Match Queue
- **Templates:** Screen layouts with navigation
- **Pages:** Complete user flows (Onboarding, Discovery, etc.)

### KONECTR-SPECIFIC INTERACTION PATTERNS
- **Slot Dropping:** Swipe gestures + haptic feedback
- **Interest Sending:** Double-tap to like + contextual message
- **Venue Selection:** Map view + list toggle
- **Safety Features:** Always accessible via long-press or dedicated button

### ACCESSIBILITY FOR SOCIAL NETWORKING
- **Screen Reader:** "Sarah's coffee slot in Bangsar, 2 hours remaining"
- **Voice Control:** "Send interest to coffee meetup"
- **Large Text:** All typography scales with system font size
- **Color Blind:** Never rely on color alone for status (use icons + text)

───────────────────────────────────────────────
4. PERFORMANCE & BATTERY OPTIMIZATION (KONECTR)
───────────────────────────────────────────────

### KONECTR PERFORMANCE TARGETS
- **App Launch:** <3 seconds cold start, <1 second warm start
- **Slot Discovery:** <500ms load time, infinite scroll without lag
- **Matching:** Real-time updates <200ms latency
- **Check-in:** GPS + venue verification <2 seconds
- **API Response:** <300ms p95 for all endpoints
- **Bundle Size:** <250KB gzipped per route (web), <2MB total app size

### BATTERY OPTIMIZATION FOR SOCIAL FEATURES
- **Location Services:** Only active during slot discovery and check-ins
- **Push Notifications:** Batch non-urgent notifications
- **Real-time Updates:** WebSocket connection management with smart reconnection
- **Background Sync:** Limit to essential match updates only
- **Battery Monitoring:** <5% drain per hour of active usage

### MEMORY MANAGEMENT
- **Image Caching:** Aggressive caching for user photos and venue images
- **List Performance:** Virtualization for activity feeds and venue lists (70% Unit, 20% Integration, 10% E2E)
- **State Cleanup:** Clear completed matches and old slots from memory
- **Memory Target:** <150MB peak consumption

───────────────────────────────────────────────
5. PLATFORM-SPECIFIC HANDLING (KONECTR)
───────────────────────────────────────────────

### iOS KONECTR OPTIMIZATIONS
- **Swipe Gestures:** Native iOS swipe patterns for slot interactions
- **Haptic Feedback:** Match notifications, interest confirmations
- **App Store Guidelines:** No dating app keywords, emphasize "social networking"
- **iOS 17+ Features:** Interactive widgets for quick slot dropping

### ANDROID KONECTR OPTIMIZATIONS  
- **Material Design:** Bottom sheets for venue selection, FAB for slot dropping
- **Android Auto:** Quick slot dropping via voice commands
- **Play Store Guidelines:** Social networking category, safety feature highlights
- **Android 14+ Features:** Predictive back gestures for navigation

───────────────────────────────────────────────
6. NETWORKING & OFFLINE SUPPORT (KONECTR)
───────────────────────────────────────────────

### KONECTR API CLIENT RULES
- **Supabase Integration:** Real-time subscriptions for matches and messages
- **Error Handling:** User-friendly messages ("Network hiccup, trying again...")
- **Retry Logic:** 3 attempts with exponential backoff
- **Request Prioritization:** Matches > Messages > Discovery > Analytics

### OFFLINE KONECTR FUNCTIONALITY
- **View cached:** Recent matches, venue details, conversation history
- **Queue for sync:** Check-ins, ratings, safety reports
- **Offline indicator:** Clear UI state showing limited functionality
- **Smart sync:** Priority order when connection restored

───────────────────────────────────────────────
🔧 DOCUMENTATION & CODE GOVERNANCE  
───────────────────────────────────────────────

### DOCUMENTATION STANDARDS
- **Public functions:** Always documented (JSDoc for JS/TS, Docstrings for Python, Swagger for APIs)
- **Architecture Decisions:** Create ADRs in `/docs/adr/yyyymmdd-decision-title.md`
- **API Documentation:** Auto-generate from code annotations, keep current
- **Component Docs:** Storybook or equivalent for UI component library

### COMMIT CONVENTIONS (CONVENTIONAL COMMITS)
```
feat(matching): add real-time interest notifications
fix(auth): resolve login timeout on slow networks  
perf(discovery): optimize slot feed query performance
refactor(ui): extract reusable venue card component
docs(api): update authentication endpoint documentation
test(e2e): add venue check-in flow automation
chore(deps): update security dependencies
```

### GOVERNANCE & RULE EVOLUTION
- **Rule changes:** Via PR + rationale + 2 agent approvals (Master Agent level)
- **Version tracking:** This file versioned as `v1.0.0`, changes logged in `/docs/rules-changelog.md`
- **Deprecation process:**
  1. Add code comment warning with migration path
  2. Update documentation with timeline
  3. Remove in next major version
- **Living document:** Monthly rule review and optimization

───────────────────────────────────────────────
🔄 CI/CD & AUTOMATION (KONECTR)
───────────────────────────────────────────────

### AUTOMATED QUALITY GATES
- **Pre-commit hooks:** Lint + type check + security scan (using Husky/Lefthook)
- **Pre-push hooks:** Run unit tests + integration tests for changed files
- **PR Requirements:** All tests pass + code review + performance benchmarks
- **Security Gates:** Dependency scans + OWASP compliance checks

### KONECTR DEPLOYMENT ENVIRONMENTS
- **Development:** Feature branches, unlimited builds, agent testing
- **Staging:** Weekly releases, venue partner testing, performance validation
- **Production:** Bi-weekly releases, gradual rollout (10% → 50% → 100%)

### SEMANTIC VERSIONING FOR KONECTR
```
v1.2.3 = MAJOR.MINOR.PATCH
- MAJOR: Breaking changes, new user flow paradigms
- MINOR: New features, venue integrations, safety improvements
- PATCH: Bug fixes, performance optimizations, minor UX polish
```

───────────────────────────────────────────────
8. TESTING MOBILE APPS (KONECTR)
───────────────────────────────────────────────

### KONECTR TEST PYRAMID (ATLAS STANDARD)
- **70% Unit:** Matching algorithms, validation logic, utility functions
- **20% Integration:** Supabase queries, component interactions, navigation flows
- **10% E2E:** Complete user journeys (onboarding → match → meetup → rating)

### TEST NAMING & BEHAVIOR FOCUS
- **Name tests after behavior:** `shouldMatchUsersWithSameActivityInterest()` not `testMatchingFunction()`
- **Test user outcomes:** "User can complete onboarding in under 3 minutes"
- **Test edge cases:** Network failures, permission denials, GPS unavailable

### KONECTR-SPECIFIC TEST SCENARIOS
- **Unit Tests:** Interest matching logic, location calculations, validation rules, business logic functions
- **Integration Tests:** Supabase CRUD operations, real-time subscriptions, push notifications, service integrations
- **E2E Tests:** New user onboarding, slot creation, match acceptance, venue check-in, safety reporting
- **Performance Tests:** Slot feed scrolling, map rendering, large venue lists

### MINIMUM COVERAGE REQUIREMENTS
- **Unit Tests:** 90% coverage for business logic and utilities
- **Integration Tests:** 75% coverage for API calls and database operations
- **E2E Tests:** 60% coverage for critical user flows
- **All tests:** Must be fast, independent, and deterministic

### TESTING ON REAL DEVICES
- **Primary:** iPhone 13 (iOS 16+), Samsung Galaxy S23 (Android 13+)
- **Secondary:** Older devices (iPhone 11, Samsung A54) for performance validation
- **Network Testing:** 3G simulation, airplane mode, spotty WiFi scenarios

───────────────────────────────────────────────
9. NOTIFICATIONS & DEEP LINKING (KONECTR)
───────────────────────────────────────────────

### KONECTR NOTIFICATION STRATEGY
- **Match Notifications:** Immediate delivery, custom sound, high priority
- **Message Notifications:** Grouped by conversation, smart batching
- **Safety Alerts:** Critical priority, bypass Do Not Disturb
- **Venue Offers:** Scheduled delivery, location-based triggering

### DEEP LINKING ARCHITECTURE
- **Match URLs:** `konectr://match/[matchId]` → Match details screen
- **Venue URLs:** `konectr://venue/[venueId]` → Venue profile screen  
- **Profile URLs:** `konectr://profile/[userId]` → User profile screen
- **Safety URLs:** `konectr://report/[matchId]` → Safety reporting flow

### NOTIFICATION-TO-SCREEN MAPPING
- Match notification → Match details with accept/decline actions
- Message notification → Conversation screen with keyboard ready
- Safety alert → Safety center with immediate reporting options
- Venue offer → Venue details with offer highlighted

───────────────────────────────────────────────
10. ACCESSIBILITY & USABILITY (KONECTR)
───────────────────────────────────────────────

### KONECTR ACCESSIBILITY REQUIREMENTS
- **Screen Reader Support:** 
  - "ActivityCard: Sarah's coffee meetup in Bangsar, 2 hours remaining, tap to send interest"
  - "Match notification: You matched with Neil for business lunch"
  - "Safety button: Report user or get help"

- **Voice Commands:**
  - "Drop coffee slot" → Quick slot creation flow
  - "Show matches" → Navigate to matches screen
  - "Call venue" → Initiate venue contact

### SOCIAL SAFETY ACCESSIBILITY
- **Emergency Access:** Safety reporting accessible via triple-tap anywhere
- **Clear Navigation:** Breadcrumbs for complex flows (matching → venue → check-in)
- **Status Clarity:** Always clear what stage user is in (browsing → matched → meeting)

───────────────────────────────────────────────
11. APP STORE COMPLIANCE & GOVERNANCE (KONECTR)
───────────────────────────────────────────────

### KONECTR APP STORE POSITIONING
- **Category:** Social Networking (not Dating)
- **Keywords:** "social meetups," "local connections," "activity partners," "real-world networking"
- **Age Rating:** 17+ (due to meeting strangers functionality)
- **Safety Features:** Prominently featured in app description

### PRIVACY & PERMISSIONS
- **Location:** Only when creating slots or checking in at venues
- **Photos:** Only for profile setup and venue verification
- **Contacts:** Never required, optional for friend finding
- **Camera:** Profile photos and venue check-in verification only

### CONTENT MODERATION COMPLIANCE
- **User-Generated Content:** Profile text, slot descriptions, messages
- **Moderation:** Real-time filtering + human review queue
- **Reporting:** Easy access to report inappropriate behavior
- **Age Verification:** Required for all users, integrated into onboarding

───────────────────────────────────────────────
🎯 KONECTR-SPECIFIC SUCCESS METRICS
───────────────────────────────────────────────

### MOBILE APP KPIs
- **Time to First Slot:** <5 minutes from app install
- **Match Success Rate:** >60% of sent interests result in accepted matches
- **Check-in Rate:** >80% of accepted matches result in venue check-ins
- **App Store Rating:** Maintain >4.5 stars with >100 reviews
- **Crash Rate:** <1% across all platforms and versions

### TECHNICAL PERFORMANCE TARGETS
- **Cold Start:** <3 seconds to usable interface
- **Slot Discovery:** <500ms to load 20 nearby activities
- **Real-time Matching:** <200ms notification delivery
- **Venue Search:** <1 second to display 10 nearby venues with offers
- **Background Sync:** <30 seconds to sync critical updates

### BATTERY & RESOURCE OPTIMIZATION
- **Battery Drain:** <5% per hour of active usage
- **Memory Usage:** <150MB peak memory consumption
- **Network Usage:** <1MB per session for core flows
- **Storage:** <100MB app size, <50MB cache maximum

───────────────────────────────────────────────
🤖 AGENT COLLABORATION PROTOCOLS
───────────────────────────────────────────────

### WHEN TO INVOKE SPECIFIC AGENTS

**@ConsumerMaster** - User experience decisions, mobile app feature prioritization
**@MobileLead** - Flutter/React Native implementation, cross-platform architecture
**@iOSSpecialist** - iOS-specific optimizations, App Store submissions
**@AndroidSpecialist** - Android-specific features, Play Store optimization
**@FlutterExpert** - Cross-platform widget development, performance optimization
**@SecurityLead** - User data protection, authentication flows, safety features
**@PerformanceLead** - App performance optimization, battery usage, memory management

### AGENT HANDOFF PROTOCOLS
1. **ConsumerMaster** defines user requirements → **MobileLead** creates technical specification
2. **MobileLead** assigns platform work → **iOSSpecialist/AndroidSpecialist** implement native features
3. **FlutterExpert** builds shared components → Platform specialists optimize for native performance
4. **SecurityLead** reviews all user data flows → **QualityMaster** validates implementation
5. **PerformanceLead** benchmarks all features → **ConsumerMaster** approves user experience impact

### CODE REVIEW CHAIN
```
Developer Agent → Tech Lead Agent → Master Agent → QualityMaster (if needed)
```

### ESCALATION TRIGGERS
- **Performance:** >3s load time → Escalate to PerformanceLead
- **Security:** User data exposure → Escalate to SecurityLead  
- **UX:** User confusion in testing → Escalate to ConsumerMaster
- **Integration:** API failures → Escalate to InfraMaster

───────────────────────────────────────────────
🎨 KONECTR BRAND COMPLIANCE
───────────────────────────────────────────────

### MANDATORY DESIGN SYSTEM USAGE
- **Colors:** Only use 4-core palette (Sunset Orange, Solar Amber, Graphite Grey, Cloud White)
- **Typography:** Inter (body), Manrope (headings), exact scale from brand guidelines
- **Components:** Must use 8 core components, extend only with approval
- **Accessibility:** WCAG AA compliance using approved color contrasts

### UI CONSISTENCY RULES
- **Touch Targets:** Minimum 44px for all interactive elements
- **Brand Colors:** Sunset Orange for primary CTAs, Solar Amber for notifications/badges
- **Component Spacing:** 8pt grid system (8px, 16px, 24px, 32px)
- **Animation:** Smooth 300ms transitions, respect platform motion preferences

───────────────────────────────────────────────
🔐 KONECTR SECURITY & SAFETY
───────────────────────────────────────────────

### USER SAFETY REQUIREMENTS
- **Identity Verification:** Phone + photo verification for all users
- **Location Privacy:** Never store exact locations, use venue proximity only
- **Message Security:** End-to-end encryption for all user conversations
- **Safety Reporting:** <2-tap access from any screen, immediate escalation

### DATA PROTECTION COMPLIANCE
- **User Data:** Minimal collection, explicit consent, easy deletion
- **Location Data:** Temporary storage only, automatic cleanup after 24 hours
- **Photos:** Secure upload to Supabase storage, automatic compression
- **Messages:** Encrypted storage, automatic deletion after 30 days of inactivity

───────────────────────────────────────────────
🏪 KONECTR CROWNS (VENUE PLATFORM)
───────────────────────────────────────────────

### VENUE DASHBOARD REQUIREMENTS
- **Platform:** Responsive web app (React/Next.js)
- **Core Features:** Offer management, foot traffic analytics, check-in notifications
- **Performance:** <2s load time, real-time updates via Supabase subscriptions
- **Mobile Responsive:** Works on venue owner's phone for quick updates

### VENUE INTEGRATION STANDARDS
- **Onboarding:** <10 minutes from signup to live venue profile
- **Analytics:** Real-time foot traffic attribution from Konectr users
- **Offer Management:** Create/edit/disable offers in <30 seconds
- **Support:** Built-in help system and direct support chat

───────────────────────────────────────────────
📊 KONECTR ANALYTICS & MONITORING
───────────────────────────────────────────────

### CRITICAL EVENTS TO TRACK
```javascript
// User Journey Events
track('profile_completed', { user_id, completion_time, verification_status });
track('slot_dropped', { user_id, activity_type, location_area, time_slot });
track('interest_sent', { from_user_id, to_user_id, activity_type, response_time });
track('match_created', { match_id, activity_type, venue_selected, time_to_match });
track('checkin_completed', { match_id, venue_id, checkin_method, verification_success });
track('meetup_rated', { match_id, user_rating, venue_rating, would_meet_again });

// Business Events  
track('venue_onboarded', { venue_id, onboarding_time, offers_created });
track('offer_redeemed', { venue_id, offer_id, user_id, redemption_value });
track('venue_analytics_viewed', { venue_id, dashboard_session_time });

// Safety Events
track('safety_report_submitted', { reporter_id, reported_user_id, reason, severity });
track('user_blocked', { blocker_id, blocked_user_id, reason });
```

### PERFORMANCE MONITORING
- **Real User Monitoring:** Core Web Vitals for web, custom metrics for mobile
- **Error Tracking:** Sentry integration with user context and session replay
- **Performance Budgets:** Bundle size <2MB, Time to Interactive <3s
- **Battery Monitoring:** iOS/Android battery usage tracking

───────────────────────────────────────────────
🚀 KONECTR DEPLOYMENT & RELEASE
───────────────────────────────────────────────

### RELEASE STRATEGY
- **Mobile App:** Bi-weekly releases with gradual rollout (10% → 50% → 100%)
- **Venue Dashboard:** Weekly releases with instant deployment
- **API Changes:** Backward compatible, versioned endpoints
- **Database Migrations:** Zero-downtime with rollback capability

### FEATURE FLAG STRATEGY
```javascript
// Core feature flags for gradual rollout
flags: {
  'advanced_matching': false,     // AI-powered matching algorithm
  'group_activities': false,      // 1-to-many invitations  
  'venue_premium': false,         // Premium venue features
  'safety_plus': false,          // Enhanced safety features
  'gamification': false          // Badges and reputation system
}
```

### ROLLBACK PROTOCOLS
- **Critical Bug:** Immediate rollback within 15 minutes
- **Performance Regression:** Rollback if >20% performance degradation
- **User Safety Issue:** Immediate rollback + incident response
- **Venue Partner Impact:** Rollback if partner dashboard affected

───────────────────────────────────────────────
💡 KONECTR ENGINEERING PRINCIPLES
───────────────────────────────────────────────

### CORE DEVELOPMENT PHILOSOPHY
**"If it's not documented, it doesn't exist. If it's not tested, it's broken. If it doesn't connect people better, it's bloat."**

### ATLAS + KONECTR COMBINED STANDARDS
- **Maintainability:** Write code your future self will thank you for
- **User Impact:** Every technical decision filtered through user experience
- **Safety First:** User protection and data privacy non-negotiable
- **Performance:** Mobile-first optimization, respect battery and bandwidth
- **Scalability:** Build for 100 users, architect for 100,000 users

### FINAL DESIGN PRINCIPLES
- **Design for interruptions:** Users will be distracted, network will be flaky
- **One-hand usage:** Critical flows must work single-handed
- **Battery constraints:** Optimize for all-day usage without charging
- **Platform respect:** Use native idioms, but maintain brand consistency
- **Build for the user's world** — not just your development environment

───────────────
**Maintainer:** CTO (Konectr)  
**Version:** v1.0.0 (Atlas + Konectr Unified)
**Last Updated:** 2025-08-31
**Agent System:** 45-person virtual engineering team
───────────────
