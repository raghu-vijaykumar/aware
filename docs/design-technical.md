# Technical & Operational Notes

## Background Processing & Scaling

### Polling Strategy
- Use a work queue partitioned by feed
- Prioritize active/most-used feeds
- Respect feed server rate limits (backoff on errors)

### Caching
- Cache fetched article content for N days
- Cache feed metadata to avoid refetching
- Use CDN for static assets

### Rate Limiting & Backoff
- Detect 429/503 responses and apply exponential backoff
- Track failure counts and temporarily disable broken feeds

## Security & Privacy

### Authentication
- Use secure password hashing (bcrypt/argon2)
- Optionally support SSO/SSO via OAuth

### Authorization
- Ensure users can only access their own subscriptions and states
- Validate all input URLs and sanitize output

### Privacy
- Allow users to export/delete their data
- Avoid storing unnecessary personal tracking data
- GDPR/CCPA compliance for data handling and ads

## Extensibility & Future Enhancements
- Support additional feed types: Twitter/X, Mastodon, YouTube, Reddit
- Integrate AI summarization of long articles
- Add collaborative features (shared collections, team access)
- Provide browser extensions for easy subscription

## Next Steps
1. Define minimum viable product (MVP) feature set with a client-first focus:
   - Core mobile UI + local persistence
   - Marketplace feed catalog + follow/unfollow flows
   - Add custom RSS/Atom feed functionality
   - Sync read/unread/star state via minimal API
2. Choose tech stack (backend, database, client framework).
3. Build API schema + database schema (focused on sync, auth, marketplace only).
4. Prototype client-side feed fetching and parsing pipeline (with optional server proxy fallback).
5. Create initial UI wireframes and navigation flows.
6. Integrate ad SDK and test monetization flows.
