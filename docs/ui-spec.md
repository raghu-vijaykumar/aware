# UI Spec (Sleek, Modern, Minimalist)

This document defines the look & feel and the UI building blocks for the app. It is intended to be developer-ready while staying aligned with a clean, modern aesthetic.

## UI Principles
- **Minimal chrome:** content-focused layouts with subtle controls.
- **Calm typography:** clean type scale with generous spacing.
- **Soft surfaces:** light shadows, rounded corners, and subtle depth.
- **Clear hierarchy:** use spacing, color, and typography to guide attention.
- **Consistency:** reuse components and spacing tokens across screens.

## 1) Color Palette
Use a neutral base with a single accent color and soft neutrals for surfaces.
- **Background (light):** `#0B0F13` (dark mode) / `#FFFFFF` (light mode)
- **Surface:** `#141A22` / `#F7F8FA`
- **Primary Accent:** `#4DD0E1` (aqua) or `#2196F3` (blue)
- **Text Primary:** `#FFFFFF` / `#0F172A`
- **Text Secondary:** `#B0BEC5` / `#64748B`
- **Borders/Dividers:** `rgba(255,255,255,0.08)` / `rgba(15,23,42,0.08)`
- **Error:** `#EF4444`
- **Success:** `#10B981`

## 2) Typography
Use a neutral sans-serif (e.g., Inter) and a simple scale.
- **Heading 1:** 28/32, 700
- **Heading 2:** 22/28, 600
- **Heading 3:** 18/24, 600
- **Body:** 16/22, 400
- **Caption:** 14/20, 400
- **Button:** 15/20, 600

## 3) Spacing System
Use a single spacing scale (multiples of 4).
- XS: 4px
- S: 8px
- M: 12px
- L: 16px
- XL: 24px
- XXL: 32px

## 4) Core Components
### 4.1 Bottom Navigation (Primary Nav)
- **Height:** 64px
- **Icon size:** 24px
- **Active icon color:** Accent
- **Inactive icon/text:** Text secondary
- **Background:** Surface
- **Elevation:** 4dp / subtle shadow

### 4.2 App Bar
- **Height:** 56px
- **Background:** Surface
- **Title:** H3 (18/24)
- **Actions:** Icon buttons (24px)
- **Optional:** blur + translucency on scroll

### 4.3 Cards (Feed & Article Items)
- **Background:** Surface
- **Corner radius:** 14px
- **Shadow:** subtle (e.g., rgba(0,0,0,0.14) 0px 2px 10px)
- **Padding:** L (16px)
- **Spacing between cards:** S (8px)
- **States:** default / pressed (scale 0.98, darker surface) / selected (accent border)

### 4.4 Buttons
- **Primary:** filled accent background, white text, 44px min height, 16px horizontal padding
- **Secondary:** outline (1px border), transparent background
- **Text:** uppercase, letter spacing 1px

### 4.5 Inputs & Forms
- **Field height:** 48px
- **Border:** 1px solid divider
- **Corner radius:** 12px
- **Placeholder color:** text secondary
- **Focus:** accent border + subtle shadow

### 4.6 Lists & Lists Items
- Use **dense spacing** for list rows, but keep touch targets >= 48px.
- Divider between items: 1px solid divider.
- Use **swipe actions** for list items (mark read/star, delete) with icon buttons and labels.

## 5) Key Screens (Structure + Components)
### 5.1 Home / Feeds
- Top: App bar + search icon + add-feed icon
- Tab segment: `Subscriptions`, `Marketplace`, `Saved`
- Content: feed cards (feed icon + title + unread badge + last updated timestamp)
- Floating action button (FAB) on mobile for “Add Feed” (optional)

### 5.2 Article List (Feed View)
- Header: feed title + refresh + overflow menu
- Filter bar: Unread / All / Starred (segmented control)
- Article card: title, snippet, source icon, time, read indicator (dot)
- Empty state: illustration + prompt to add feeds

### 5.3 Reader (Swipe Deck)
- Fullscreen card stack (depth effect)
- Top: article title, source, timestamp
- Middle: content preview (text + image), fallback to “Open in browser”
- Bottom toolbar: star, share, open in browser, mark read
- Swipe gesture: right=next, left=previous, up=full content.
- Compact mode: show progress indicator (3/10)

### 5.4 Add Feed / Marketplace
- Tabs: Marketplace / Custom URL
- Marketplace: category chips + grid/list of feed cards
- Custom URL: input + preview card + “Add” button
- Validation errors: inline message in red

### 5.5 Settings / Profile
- Sections: Profile, Appearance, Sync, Notifications, Premium
- Toggles: Dark mode, background sync, notifications
- Buttons: Import OPML, Export OPML, Logout
- Premium section: upgrade CTA card (accent background)

## 6) Motion & Feedback
- Use **smooth transitions** (200–250ms) for navigation and card swipes.
- Provide **haptic feedback** on key actions (star, swipe, add feed).
- Use **skeleton loading** for lists & cards when content loads.
- Show **toast/snackbar** for actions (saved, synced, error).

## 7) Dark Mode & Theming
- Default to system theme, allow manual override in Settings.
- Make sure all text and icons meet contrast ratios (WCAG AA minimum).
- Preserve accent color for interactive elements in both themes.
