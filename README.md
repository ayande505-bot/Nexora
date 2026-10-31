# Nexora 3.2.0 — Complete 2026

Nexora is an international professional directory for finding professionals by profession, country and city.

## Included
- 249 countries and 750 professions
- 15-language UI with a persistent app-wide language preference
- Free professional registration with Supabase Auth
- Photo/avatar storage
- Search by profession, country, city and keywords
- Premium-first ranking using active expiration dates
- Premium-only filter
- Premium badge and admin-controlled Verified badge
- Reviews and ratings
- Favorites and pinned professionals require a signed-in customer account and are synced to the account
- In-app messaging for professionals and registered customer accounts
- Booking requests with date/time
- In-app notifications for new messages, booking requests and reviews
- Emergency numbers
- Admin dashboard with search, Premium activation/removal by Weekly, Monthly or Quarterly plan, verification, ban/unban and deletion
- Premium plans: 7 days / 130 HTG / $0.99; 30 days / 450 HTG / $3.49; 90 days / 1,200 HTG / $9.49
- Manual Premium payment: MonCash, NatCash, Taptap Send and Ria Money Transfer
- No automatic payment gateway and no customer API key
- WhatsApp proof flow with a pre-filled message to +509 36246316; MonCash +509 3624-6316 and NatCash +509 4006-1709 are preconfigured as defaults
- PWA manifest and privacy/terms pages for publishing preparation

## Manual Premium flow
1. Professional signs in and opens Pro Space.
2. Selects Weekly, Monthly or Quarterly.
3. Selects MonCash, NatCash, Taptap Send or Ria.
4. Pays using the receiving details configured in `.env.local`.
5. Creates a pending payment record in Supabase.
6. Opens WhatsApp with a pre-filled proof message.
7. Admin verifies the payment and activates Premium for 7, 30 or 90 days.
8. Premium is shown with a crown badge and ranked first.
9. When the Premium period ends, it should no longer be treated as active.

## Important configuration
Copy `.env.example` to `.env.local` and set:
- NEXT_PUBLIC_SUPABASE_URL
- NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY
- SUPABASE_SERVICE_ROLE_KEY (server only; never expose it in client code)
- ADMIN_CODE (use your own long random secret)
- NEXT_PUBLIC_MONCASH
- NEXT_PUBLIC_NATCASH
- NEXT_PUBLIC_TAPTAP_SEND
- NEXT_PUBLIC_RIA
- NEXT_PUBLIC_ADMIN_WHATSAPP

Do not commit `.env.local`.

The Taptap Send and Ria fields are receiving instructions/details you control. Do not publish someone else's account details. Availability and eligibility of money-transfer services depend on the country and provider rules.

## Supabase setup
Run `NEXORA_DATABASE_SETUP_RUN_THIS_FIRST.sql` once in the Supabase SQL Editor. It creates the core profile schema, countries, professions, payment tables, subscriptions and the additional Nexora feature tables.

Then configure the environment variables and run:
```bash
npm install
npm run lint
npm run build
npm start
```

## Production / Play Store
This project is a Next.js web app/PWA. It is not an Android AAB by itself. For Google Play, package the deployed HTTPS web app with a suitable Android wrapper/PWA workflow, create a signed release, and complete Play Console privacy, Data Safety, content rating and testing requirements.

## Verification note
The ZIP was validated structurally and the archive integrity is checked. A complete production build still requires dependency installation in a networked environment; therefore this package is not represented as a guarantee of zero runtime issues until `npm run lint` and `npm run build` pass in deployment.

## Multilingual + Emergency System (2026)
- 15 selectable UI languages: Français, Kreyòl Ayisyen, English, Español, Português, Deutsch, Italiano, 日本語, 한국어, العربية, 中文, Русский, Türkçe, Nederlands, हिन्दी.
- The selected language is saved locally and applied across the main interface, forms, Premium area, admin area, messages, reviews, bookings, and country names where the browser supports localized region names.
- 249 countries/territories remain available in the directory.
- Every country has an emergency number entry in the app. Country-specific numbers are used for many countries; 112 is the fallback general emergency line where a country-specific entry is not defined. Emergency numbers can change, so users should verify locally before relying on them.

## Final verification
- 15 interface languages are defined and share the same translation-key set.
- WhatsApp Premium payment-proof messages are defined for all 15 languages.
- The countries dataset contains 249 country entries, each with police/fire/ambulance fallback data.
- Emergency UI collapses identical service numbers into one general emergency call button.
- Secrets remain environment variables; do not commit `.env.local` or expose `SUPABASE_SERVICE_ROLE_KEY`.
- A full production `npm run build` could not be completed in this environment because dependency installation timed out; archive integrity and static consistency checks were performed instead.


## Customer access
Anyone can search the directory and view professional profiles without an account. A signed-in customer account is required for messages, favorites, pins, reviews and booking requests. Professional accounts use the professional dashboard.

### Required Supabase Auth setting
No anonymous Supabase Auth is required for customer actions. Customers must create an account or sign in before using messages, favorites, pins, reviews or booking requests.

## Home registration buttons
The Home page shows exactly three primary actions: **Register as a professional**, **Register as a client**, and **Sign in to a Nexora account**. Browsing and profile viewing are public; customer actions require a customer account.

- Official Nexora logo is displayed on the home page hero.

- Anyone can search and view professional profiles without an account. A customer account is required for in-app messages, favorites, pins, reviews, and booking requests.


## 3 main home buttons
- 💼 Enskri kòm pwofesyonèl
- 👤 Enskri kòm kliyan
- 🔐 Konekte ak kont Nexora ou
Search remains available without an account.


## Customer account rules
- Anyone can search the directory and view professional profiles without an account.
- A customer account is required before using in-app messages, favorites, pins, reviews, or booking requests.
- WhatsApp and phone contact remain available as external contact options when provided by the professional.
- The home page has exactly three primary actions: register as a professional, register as a client, and sign in to a Nexora account.
