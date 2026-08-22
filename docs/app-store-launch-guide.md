# Anicca — App Store Launch Guide

One step at a time, in order. Every step is one action with a **Done when** so you always know if you can tick it. Phases are sized to one sitting, and **you can stop after any phase — nothing breaks mid-way**.

Legend: 🧑 = needs you (your accounts) · 🤖 = already done by Claude · ⏱ = realistic time

> **Only have 20 minutes today? Do Phase 0 and stop.** It's the only urgent one — a live, billable API key is public on GitHub.

**The big picture:** 0 security → 1 Apple paperwork (starts a multi-day wait) → 2 merge the code fixes → 3 backend switch-on → 4 subscriptions → 5 legal pages → 6 first TestFlight → 7 listing + submit. Roughly **6–7 focused hours** total, spread over as many days as you like, plus Apple's processing waits.

---

## Phase 0 — Stop the bleeding 🧑 ⏱ ~20 min · do this TODAY

- [ ] **0.1 Rotate the Gemini key** ⏱ 10 min
  **Do:** Open [Google AI Studio → API keys](https://aistudio.google.com/apikey) (or Google Cloud console → APIs & Services → Credentials if the key lives there). Delete the key starting `AIzaSyAM…`. Create a new one and copy it.
  **Done when:** the old key is deleted and the new one is in your clipboard.
  *Why: the old key is in the repo's git history on GitHub, and it bills your Google account.*

- [ ] **0.2 Restrict + cap the new key** ⏱ 5 min
  **Do:** In [Google Cloud console → Credentials](https://console.cloud.google.com/apis/credentials), open the new key → API restrictions → restrict to **Generative Language API**. Then set a daily quota cap (APIs & Services → Generative Language API → Quotas), e.g. 5,000 requests/day.
  **Done when:** the key shows "Restricted" and a quota cap exists.

- [ ] **0.3 Put the new key in your local secrets** ⏱ 2 min
  **Do:** Edit `/Users/isa/Anicca/Secrets.xcconfig` → set `GEMINI_API_KEY = ` your new key. (This file is gitignored — keep it that way.)
  **Done when:** saved.

- [ ] **0.4 Confirm Row Level Security is ON** ⏱ 5 min
  **Do:** [Supabase dashboard](https://supabase.com/dashboard) → your project → Table Editor. Check `profiles`, `check_ins`, `emotion_entries`, `ai_insights` — each must show **RLS enabled** with a policy. If any is missing, open the SQL Editor and run the RLS block from `Anicca/Resources/SupabaseSetup.md`.
  **Done when:** all 4 tables show RLS + a policy.
  *Why: the anon key is public by design — RLS is the only wall around user journals.*

---

## Phase 1 — Apple paperwork 🧑 ⏱ ~45 min + multi-day processing · start EARLY

- [ ] **1.1 Confirm your Developer membership is active** ⏱ 3 min
  **Do:** [developer.apple.com/account](https://developer.apple.com/account) — team `P788RWL6YN`, no expiry warnings.
  **Done when:** the account page shows an active membership.

- [ ] **1.2 Register the App ID** ⏱ 5 min
  **Do:** [Identifiers](https://developer.apple.com/account/resources/identifiers/list) → **+** → App IDs → App → **Explicit** bundle ID `com.screenseiji.anicca` → tick the **Sign In with Apple** capability → Register.
  **Done when:** the App ID appears in the list with Sign In with Apple enabled.

- [ ] **1.3 Create the App Store Connect record** ⏱ 10 min
  **Do:** [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → My Apps → **+** → New App → iOS · name **Anicca** (fallbacks if taken: "Anicca — Mood & Energy", "Anicca: Inner Weather") · English (U.S.) · bundle ID from 1.2 · SKU `anicca-ios-001`.
  **Done when:** the app record exists.

- [ ] **1.4 Paid Apps agreement + banking + tax** ⏱ 20 min now, days to process
  **Do:** App Store Connect → **Business** (Agreements, Tax, and Banking) → accept the **Paid Apps** agreement, add your bank account, complete the tax forms.
  **Done when:** status shows Processing or Active. Subscriptions cannot go live without this — kick it off now and do other phases while it churns.

---

## Phase 2 — Code fixes 🤖 done · your part ⏱ ~20 min

Claude already fixed in the `claude/project-status-app-store-a7257b` branch: bundle ID pinned to `com.screenseiji.anicca` everywhere (setup.sh no longer reverts it) · Sign in with Apple entitlements file · `PrivacyInfo.xcprivacy` · Info.plist cleaned (background modes gone, versions driven by build settings) · icon alpha flattened · Apple delete-account re-auth fixed (both bugs) · single Apple sign-in sheet · paywall disclosure + no fabricated prices · Pro override and debug logging compiled out of Release · reminders free for everyone · secrets template scrubbed · shared scheme committed · Supabase docs updated.

- [ ] **2.1 Review + merge the PR** ⏱ 15 min
  **Done when:** merged into `main`.

- [ ] **2.2 Pull and regenerate** ⏱ 3 min
  ```bash
  cd /Users/isa/Anicca && git checkout main && git pull && ./setup.sh
  ```
  **Done when:** `xcodegen` reports "Created project".

- [ ] **2.3 Sanity-open Xcode** ⏱ 5 min
  **Do:** Open `Anicca.xcodeproj`, scheme **Anicca**. Signing & Capabilities should show your team and **Sign In with Apple**. Build to a simulator.
  **Done when:** the auth screen appears in the simulator.

---

## Phase 3 — Backend switch-on 🧑 ⏱ ~30 min

- [ ] **3.1 Install + log in to the Supabase CLI** ⏱ 5 min
  ```bash
  brew install supabase/tap/supabase && supabase login
  ```
  **Done when:** `supabase projects list` shows your project.

- [ ] **3.2 Deploy the delete-account function** ⏱ 5 min
  **Do:** from the repo root (your project ref is the subdomain of `SUPABASE_URL` in `Secrets.xcconfig`):
  ```bash
  supabase link --project-ref YOUR-PROJECT-REF && supabase functions deploy delete-account
  ```
  **Done when:** deploy reports success.
  *Why: an undeployed function makes "Delete My Account" fail — automatic rejection under Guideline 5.1.1(v).*

- [ ] **3.3 Prove it's live** ⏱ 2 min
  ```bash
  curl -i -X POST https://YOUR-PROJECT-REF.supabase.co/functions/v1/delete-account
  ```
  **Done when:** you get **HTTP 401** (deployed and guarding). 404 means not deployed — redo 3.2.

- [ ] **3.4 Enable the Apple auth provider** ⏱ 5 min
  **Do:** Supabase dashboard → Authentication → Providers → **Apple** → enable, and add `com.screenseiji.anicca` to **Authorized Client IDs**.
  **Done when:** saved with the bundle ID listed.

- [ ] **3.5 Point Google sign-in at the new bundle ID** ⏱ 10 min
  **Do:** [Google Cloud console → Credentials](https://console.cloud.google.com/apis/credentials). If your iOS OAuth client's bundle ID isn't `com.screenseiji.anicca`, create a new **iOS** OAuth client with it. Put the client ID in `Secrets.xcconfig` as `GOOGLE_CLIENT_ID` and its reversed form (`com.googleusercontent.apps.…`) as `GOOGLE_URL_SCHEME`. Add the client ID to the Supabase **Google** provider's Authorized Client IDs.
  **Done when:** all three places (Google console, Secrets.xcconfig, Supabase) agree.

---

## Phase 4 — Subscriptions 🧑 ⏱ ~90 min · needs 1.4 processed

- [ ] **4.1 Create the subscription group** ⏱ 5 min
  **Do:** App Store Connect → Anicca → Monetization → Subscriptions → create group **Anicca Pro**.

- [ ] **4.2 Create the 4 products** ⏱ 30 min — use these exact IDs (the app matches on them):

  | Product ID | Duration | Price |
  |---|---|---|
  | `anicca_pro_monthly` | 1 month | $4.99 |
  | `anicca_pro_annual` | 1 year | $39.99 |
  | `anicca_bundle_monthly` | 1 month | $8.99 |
  | `anicca_bundle_annual` | 1 year | $69.99 |

  Each needs a display name, a one-line description, and a price. Screenshot for review can be added later (a paywall screenshot works).
  **Done when:** all four show "Ready to Submit" (metadata complete).

- [ ] **4.3 Connect RevenueCat to the app** ⏱ 15 min
  **Do:** [app.revenuecat.com](https://app.revenuecat.com) → your project → Apps → add an App Store app with bundle ID `com.screenseiji.anicca`, and connect it with an App Store Connect **In-App Purchase key** (RevenueCat's setup page walks you through generating it).
  **Done when:** the app shows as connected.

- [ ] **4.4 Products, entitlements, offering** ⏱ 20 min
  **Do:** Import the 4 products into RevenueCat. Create entitlements **`pro`** (attach both pro products) and **`bundle`** (attach both bundle products). Create offering **`default`** containing all four packages.
  **Done when:** offering `default` lists 4 packages.

- [ ] **4.5 Swap in the production API key** ⏱ 2 min
  **Do:** RevenueCat → API keys → copy the **public app-specific key** (`appl_…`) → `Secrets.xcconfig` → `REVENUECAT_API_KEY`. (The old `test_` key won't work in production.)

- [ ] **4.6 Sandbox purchase test** ⏱ 15 min
  **Do:** App Store Connect → Users and Access → **Sandbox Testers** → create one. Run the app from Xcode, open the paywall, buy Pro with the sandbox account.
  **Done when:** the Settings plan badge flips to **Pro ✦** and the weekly summary unblurs.

---

## Phase 5 — Legal pages 🧑 ⏱ ~30 min

- [ ] **5.1 Audit the privacy policy** ⏱ 15 min
  **Do:** Open https://anicca.lovable.app/privacy and check it clearly states: what's collected (email, name, journal text, emotion logs) · **that free-text entries are sent to Google's Gemini API for analysis** · storage on Supabase · that the account can be deleted in-app and what deletion removes · a contact email. Fix the page if anything's missing — the Lovable host itself is fine; Apple checks content, not domains.
  **Done when:** every item above is on the page.

- [ ] **5.2 Audit the terms** ⏱ 10 min
  **Do:** https://anicca.lovable.app/terms must cover the auto-renewing subscriptions (renewal + cancellation), a "not medical advice / not a substitute for professional care" disclaimer, and contact info.
  **Done when:** all three are on the page.

- [ ] **5.3 If either URL changed, update the app** ⏱ 2 min
  **Do:** `Anicca/Config/AppConfig.swift` → `privacyPolicyURL` / `termsOfUseURL` (or ask Claude).

---

## Phase 6 — First TestFlight 🧑 ⏱ ~60 min + processing

- [ ] **6.1 Final secrets check** ⏱ 3 min — `Secrets.xcconfig` has: the NEW Gemini key (0.3), the `appl_…` RevenueCat key (4.5), both Google values (3.5).

- [ ] **6.2 Regenerate + open** ⏱ 2 min — `./setup.sh`, open Xcode.

- [ ] **6.3 Archive** ⏱ 10 min — destination **Any iOS Device (arm64)** → Product → **Archive**.

- [ ] **6.4 Upload** ⏱ 10 min — Organizer → Distribute App → **App Store Connect** → Upload (automatic signing).
  **Done when:** upload succeeds with no validation errors.

- [ ] **6.5 Install via TestFlight** ⏱ 10 min + wait — App Store Connect → TestFlight → wait for the build to finish processing (email arrives) → add yourself to an Internal Testing group → install on your iPhone.

- [ ] **6.6 The smoke test** ⏱ 20 min — on the TestFlight build, tick every one:
  - [ ] Email sign-up → onboarding → main tabs
  - [ ] Sign out → **Continue with Apple** — the Apple sheet appears exactly **once**
  - [ ] Sign out → **Continue with Google** works
  - [ ] Free-text entry → "Map my feelings" returns emotions → save with intensities
  - [ ] Browse emotions → save a check-in
  - [ ] Insights: radar renders; weekly summary is blurred on a free account
  - [ ] Paywall shows real App Store prices + the renewal disclosure text
  - [ ] Sandbox-purchase Pro → badge flips, weekly insight unblurs
  - [ ] Enable a reminder on a **free** account → notification arrives at the set time
  - [ ] **Force-quit the app, relaunch**, then Delete Account using a throwaway Apple-sign-in account → re-auth sheet appears → user is gone from Supabase Auth → Users. *(The force-quit relaunch is exactly the path that used to be broken.)*

---

## Phase 7 — Listing + submit 🧑 ⏱ ~2 h

- [ ] **7.1 Screenshots** ⏱ 40 min
  **Do:** Seed a demo account with ~2 weeks of varied check-ins first. Capture on iPhone 17 Pro Max simulator (6.9") — and a 6.5" set if App Store Connect asks: Home, free-text entry, mapping result, Insights radar, weekly insight, timeline. (Claude can stage and capture these with you.)

- [ ] **7.2 Metadata** ⏱ 30 min
  **Do:** Subtitle ≤30 chars (e.g. "Mood & energy journaling"). Description that leads with what the app does and includes: *"Anicca is a self-reflection tool, not a medical device or a substitute for professional care."* Keywords: mood tracker, emotion journal, chakra, energy, mindfulness, self care, feelings log. Support URL + copyright.

- [ ] **7.3 Privacy nutrition labels** ⏱ 15 min — enter exactly what the shipped privacy manifest declares:
  Contact Info: **Email Address, Name** · Health & Fitness: **Health** (emotional state) · User Content: **Other User Content** (journal notes) · Identifiers: **User ID** · Purchases: **Purchase History**. All **Linked to you**, **none** used for tracking.

- [ ] **7.4 Age rating** ⏱ 5 min — questionnaire answers are all "None" (including Medical/Treatment Information — the app gives no medical advice) → rating 4+.

- [ ] **7.5 App Review info + demo account** ⏱ 10 min
  **Do:** Create a demo email account, seed 8–10 check-ins, then in RevenueCat (Customers → find the user → grant entitlement `pro`) so reviewers can see gated features. Enter the credentials in App Review Information, with notes: where the paywall is, that free-text is analyzed by Gemini, and that Delete Account requires re-authentication.

- [ ] **7.6 Submit** ⏱ 10 min
  **Do:** Version page → select the TestFlight build → confirm the 4 subscriptions are attached to this first submission → pricing **Free** (with in-app purchases) → availability → **Submit for Review**.
  **Done when:** status says *Waiting for Review*. 🎉 Reviews for new apps typically take 1–3 days.

---

## Parking lot — after approval, not before

Deliberately deferred; none block submission: circumplex emotion library (SS-6) · weekly-summary enrichment (SS-8) · timeline calendar grid (SS-9) · proxy Gemini through a Supabase edge function so the key leaves the app binary, and revisit the `BLOCK_NONE` safety settings · server-side validation of re-auth tokens in delete-account · swipe-to-delete in Insights is a silent no-op (needs a `List`) · the 25-check-in warning is never shown · email confirmations · tests + CI.
