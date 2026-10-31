# Nexora v10 — Clean final revision

## Changes
- Home page keeps exactly three primary actions:
  - Register as a professional
  - Register as a client
  - Sign in to a Nexora account
- Public browsing/search and professional profile viewing remain available without an account.
- Customer account is required for in-app messages, favorites, pins, reviews, and booking requests.
- Removed stale guest/anonymous customer wording and configuration references from the product translations/documentation.
- Customer registration no longer describes the account as optional.
- Customer signup now handles Supabase email-confirmation mode safely instead of assuming a session exists.
- Professional signup keeps its pending-profile fallback for Supabase email-confirmation mode.
- Professional profile details now also expose account-gated Favorite and Pin actions, synced through Supabase.
- Kept external WhatsApp/phone contact available without a Nexora customer account.
- Kept the 15-language localization structure.
- Kept Supabase SQL/RLS, Premium/manual-payment flow, notifications, admin controls, emergency numbers, and existing logo.
- Version bumped to 3.2.0.

## Verification
- ZIP archive integrity was checked after packaging.
- TypeScript parser/static check was run. A full Next.js production build could not be completed in this environment because dependency installation from npm timed out; the project still needs `npm install` and `npm run build` in a normal networked development/deployment environment.
