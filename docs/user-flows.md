# User Flows & Navigation (Mobile)

## 1. Overview
This document defines key mobile user flows and navigation patterns for the Flutter client. It focuses on a clean, touch-first experience tuned for quick scanning, reading, and managing feeds.

---

## 2. Primary Screens

### 2.1 Home (Feed List)
**Purpose:** Display the user's subscribed feeds and quick access to curated marketplace collections.

**Layout:**
- Bottom navigation bar: Feeds (home), Saved (starred articles), Briefs (premium), Settings
- Top app bar with: search icon, and add-feed button
- Segmented toggle (tabs) for: `Subscriptions`, `Marketplace`, `Saved`
- Feed list under each tab
  - `Subscriptions` shows folders and feeds
  - `Marketplace` shows category cards + featured feeds
  - `Saved` shows starred/saved articles (alternative view)
- Ad banner at bottom of feed list (free tier only)

**Interactions:**
- Tap folder expands/collapses feeds
- Swipe feed item to reveal actions (mark read, unfollow)
- Tap feed to open Article List
- Tap ad → open ad link or upgrade prompt

---

### 2.2 Article List (Feed View)
**Purpose:** Show the latest items for a selected feed or folder.

**Layout:**
- Top app bar: back button, feed title, overflow menu (refresh, settings)
- Filter bar: Unread / All / Starred toggle
- Article list (card style): title, snippet, timestamp, read indicator

**Interactions:**
- Tap article card → open Reader view
- Swipe left/right on card → mark read/unread, star
- Pull-to-refresh triggers feed sync

---

### 2.3 Reader (Article View) - Swipe Interface
**Purpose:** Display articles in a Tinder-style swipeable interface for quick browsing.

**Layout:**
- Card-based stack: each article as a swipeable card (title, snippet, image)
- Bottom overlay: article counter (e.g., 3/10), quick actions (star, share)
- Full article mode: swipe up on card to expand to full content view
- Interstitial ad after reading 5 articles (free tier only)

**Interactions:**
- Swipe left: previous article (animate card left)
- Swipe right: next article (animate card right)
- Swipe up: toggle to full article mode (expand card to full screen with content)
- Swipe down (in full mode): back to card view
- Tap card: open in browser (premium: voice read-aloud)
- Double-tap: star/unstar

---

### 2.4 Add Feed (URL + Marketplace)
**Purpose:** Allow user to add new feeds via marketplace or custom URL.

**Layout:**
- Tabbed view: `Marketplace` / `Custom URL`
- Marketplace: category chips + list of recommended feeds
- Custom URL: input field + preview button (fetch feed metadata)

**Interactions:**
- Tap marketplace feed → follow + open feed
- Enter URL → validate + show feed info → add subscription

---

### 2.5 Settings / Profile
**Purpose:** Manage account, sync settings, notification preferences, and themes.

**Layout:**
- Sections: Profile (avatar, name, email), Themes (light/dark/auto), Sync, Notifications, About
- Options: logout, import/export OPML, set sync interval, enable push notifications, theme selector
- Premium section: upgrade to subscription (remove ads, faster sync, AI features: daily briefs, weekly summaries, personalized recommendations)

**Interactions:**
- Toggle switches for background sync and notifications
- Tap "Import OPML" → file picker → import flow
- Tap "Theme" → select light/dark/auto
- Tap “Upgrade” → in-app purchase flow

---

### 2.6 Briefs (Premium Feature)
**Purpose:** Display AI-generated daily briefs and weekly summaries.

**Layout:**
- Top app bar: title "Briefs", filter (Daily / Weekly)
- List of briefs: date, title, summary snippet
- Each brief card: tap to expand full AI summary

**Interactions:**
- Tap brief → open full view with article links
- Pull-to-refresh to generate new brief (if premium)

---

### 3.1 App Entry
1. Launch app → Splash screen (brand/logo + optional load state)
2. If logged in → Home (Subscriptions tab)
3. If not logged in → Auth flow (Login / Register)

### 3.2 Typical Read Flow
1. Home → tap feed → Article List
2. Article List → tap article → Reader (swipe interface)
3. Reader → swipe left/right for prev/next, swipe up for full article, back to list

### 3.3 Feed Discovery Flow
1. Home → Marketplace tab
2. Browse category → tap feed → follow
3. Optional: immediately open feed list after follow

### 3.5 Premium Brief Flow
1. Bottom nav → Briefs tab
2. Select Daily/Weekly → view AI-generated summary
3. Tap article link in brief → open Reader view

---

## 4. Flow & Sketch Guidelines
- Use simple, high-contrast visuals for readability
- Keep action buttons in reach (bottom nav + bottom action bars)
- Prioritize content (articles) over chrome (menus) for reading screens
- Maintain consistent spacing and typography across screens
- Include ad placements and subscription upgrade prompts in free tier sketches
- Show premium features (e.g., Briefs tab, voice play button) as locked or premium-only in sketches
- Design Reader as Tinder-style swipeable cards with animations for left/right/up gestures

---

## 5. Next Steps
1. Create low-fidelity wireframe sketches (paper or digital) for each primary screen.
2. Add annotated user flows (with touch targets and transitions).
3. Review with stakeholders and iterate on the navigation hierarchy.
