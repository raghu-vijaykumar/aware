# aware Client

This is the Flutter mobile client for the **aware** feed reader app.

## Getting Started

1. Install Flutter: https://flutter.dev/docs/get-started/install

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

- `lib/models/` - Data models (Feed, Article, etc.)
- `lib/services/` - API and database services
- `lib/providers/` - State management with Provider
- `lib/screens/` - Main UI screens
- `lib/widgets/` - Reusable UI components

## Features Implemented

- Basic app structure with bottom navigation
- Local SQLite database for feeds and articles
- Provider-based state management
- Placeholder screens for feeds, saved articles, and settings

## Next Steps

- Implement feed fetching and RSS parsing
- Add article reader with swipe gestures
- Integrate with backend API for auth and marketplace
- Add offline sync and background refresh
