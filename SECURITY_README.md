# Nexora security update

1. For a NEW Supabase database, run NEXORA_DATABASE_SETUP_RUN_THIS_FIRST.sql and then NEXORA_SECURITY_PATCH.sql. For an EXISTING database, back it up and run ONLY NEXORA_SECURITY_PATCH.sql.
2. Set ADMIN_CODE to a strong random secret of at least 16 characters; set SUPABASE_SERVICE_ROLE_KEY on Vercel server environment only. Never expose it as NEXT_PUBLIC.
3. Admin login: five failed attempts from one IP in 15 minutes cause a 15-minute lock. This is IP-based and should be supplemented by edge/WAF protections for distributed attacks.
4. Admin deletion now deletes auth.users through Supabase Admin API, which cascades to profiles if schema foreign keys are configured. Check dependent records and retention policy before using it.
5. Premium updates now use one database RPC transaction; profile premium_until is protected against owner edits.
6. npm install, npm run lint, npm run build, live Supabase/RLS and end-to-end testing still required before public launch.
