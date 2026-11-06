# Anicca — Supabase + RevenueCat Setup

## Supabase

1. Create a new Supabase project at https://app.supabase.com.
2. Copy your project URL and `anon` (public) key into `Secrets.xcconfig` at the project root.
3. Open the Supabase **SQL editor** and run the SQL below in order. It creates the schema and enables Row Level Security.

### Schema SQL

```sql
-- profiles table (extends auth.users)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  display_name text,
  plan_tier text not null default 'free',
  check_in_streak integer not null default 0,
  last_check_in_date timestamptz,
  total_check_ins integer not null default 0,
  reminder_enabled boolean not null default false,
  reminder_time timestamptz,
  yggdrasil_user_id text,          -- reserved for future deep integration
  created_at timestamptz default now()
);

-- check_ins table
create table check_ins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  note text,
  created_at timestamptz default now()
);

-- emotion_entries table
create table emotion_entries (
  id uuid primary key default gen_random_uuid(),
  check_in_id uuid references check_ins(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  emotion_name text not null,
  energy_center text not null,
  intensity integer not null check (intensity >= 1 and intensity <= 5),
  created_at timestamptz default now()
);

-- Enable RLS on all tables
alter table profiles enable row level security;
alter table check_ins enable row level security;
alter table emotion_entries enable row level security;

-- RLS Policies (users can only access their own data)
create policy "Users can manage own profile" on profiles for all using (auth.uid() = id) with check (auth.uid() = id);
create policy "Users can manage own check-ins" on check_ins for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can manage own entries" on emotion_entries for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

> **Legacy `ai_insights` table:** earlier versions cached Gemini weekly insights in an `ai_insights` table. The app no longer reads or writes it (reflections are now built on device). Existing projects can leave it in place, or drop it once the old rows aren't needed: `drop table ai_insights;`

### Auth providers

1. **Email**: enable in Supabase Auth → Providers → Email. Then in Authentication → URL Configuration, set **Site URL** to `https://anicca.lovable.app` and add `com.screenseiji.anicca://auth-callback` to **Redirect URLs**. The app sends that URL with every sign-up, so the confirmation link opens Anicca and signs the user in; if it isn't on the list, Supabase falls back to the Site URL (by default `http://localhost:3000`, a dead page on a phone). With "Confirm email" on, the app shows a "check your email" message after sign-up and creates the `profiles` row on the first signed-in launch.
2. **Apple**: enable Apple provider. Add your bundle ID (`com.screenseiji.anicca`) to the Apple provider configuration's authorized client IDs.
3. **Google**: enable Google provider. Create an **iOS** OAuth 2.0 client in Google Cloud console for bundle ID `com.screenseiji.anicca` and add its client ID to the Supabase Google provider's authorized client IDs. Put the iOS client ID in `Secrets.xcconfig` as `GOOGLE_CLIENT_ID` and the reversed client ID as `GOOGLE_URL_SCHEME`.

### Edge Functions

The `delete-account` function (in `supabase/functions/delete-account/`) performs the actual `auth.users` deletion for the in-app "Delete My Account" flow. **It must be deployed to the hosted project or account deletion will fail** — an automatic App Review rejection under Guideline 5.1.1(v).

```bash
# from the repo root, with the Supabase CLI logged in and linked to the project
supabase link --project-ref YOUR-PROJECT-REF
supabase functions deploy delete-account
```

The function reads `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` from the function environment. All three are provided automatically by the Supabase platform — no manual secrets setup is needed for a standard deploy.

Verify after deploying: sign in as a throwaway account in the app, delete it from Settings, and confirm the user is gone from **Auth → Users** in the dashboard (cascade removes the profile and check-ins).

## RevenueCat

1. Create a RevenueCat account at https://app.revenuecat.com and add a new app for your bundle ID `com.screenseiji.anicca`.
2. Set your **public iOS API key** in `Secrets.xcconfig` as `REVENUECAT_API_KEY`.

### Entitlements

Create two entitlements in the dashboard:

| Entitlement ID | Notes |
|---|---|
| `pro` | Unlocks Pro features |
| `bundle` | Unlocks Pro + Bundle features (Yggdrasil deep integration) |

### Products (App Store Connect)

Create the four auto-renewing subscriptions in App Store Connect, then attach each to RevenueCat:

| Product ID | Price | Entitlement |
|---|---|---|
| `anicca_pro_monthly` | $4.99 / month | `pro` |
| `anicca_pro_annual` | $39.99 / year | `pro` |
| `anicca_bundle_monthly` | $8.99 / month | `bundle` |
| `anicca_bundle_annual` | $69.99 / year | `bundle` |

### Offering

Create a RevenueCat offering called `default` and attach all four packages. The Paywall uses these IDs directly — keep them stable.
