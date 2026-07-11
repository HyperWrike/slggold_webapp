# SLG Golds — Production Deployment (Vercel + Convex)

The app is an **Expo Router (React Native Web)** frontend that exports to a
static site, plus a **Convex** backend (auth, payments, schemes, portfolio,
GST, notifications, crons). These deploy to two separate platforms.

```
┌────────────────────┐        EXPO_PUBLIC_CONVEX_URL        ┌────────────────────┐
│  Vercel            │  ───────────────────────────────▶   │  Convex Cloud      │
│  (static web app)  │      queries / mutations / actions   │  (backend + data)  │
│  project: slg-golds│  ◀───────────────────────────────    │  patient-cobra-66  │
└────────────────────┘                                      └────────────────────┘
```

## Prerequisites
- Node **22** (`.nvmrc` pins it; Vercel reads `engines.node` in package.json).
- `npm i -g vercel` and `npx convex` (Convex CLI ships as a local dep).

## 1. Deploy the Convex backend
```bash
nvm use 22
npx convex login          # once
npx convex deploy         # pushes functions + schema to your prod deployment
```
Set the backend secrets (once per deployment):
```bash
npx convex env set AADHAAR_ENCRYPTION_KEY $(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))") --prod
npx convex env set RAZORPAY_KEY_ID   <live_key_id>     --prod
npx convex env set RAZORPAY_KEY_SECRET <live_secret>   --prod
npx convex env set BREVO_API_KEY     <brevo_key>       --prod
npx convex env set BREVO_SENDER_EMAIL noreply@slggolds.com --prod
npx convex env set BREVO_SENDER_NAME "SLG Golds"       --prod
```
> Without Razorpay/Brevo keys the backend runs in **mock mode** (no real
> charges, OTP printed to logs). Safe for staging, NOT for production.

Copy the deployment URL it prints (e.g. `https://patient-cobra-66.convex.cloud`).

## 2. Deploy the frontend to Vercel (project name: slg-golds)
```bash
vercel login
vercel link --project slg-golds     # creates/links the project
vercel env add EXPO_PUBLIC_CONVEX_URL production   # paste the Convex URL
vercel --prod                        # build + deploy
```
`vercel.json` already sets:
- build command → `expo export --platform web`
- output dir → `dist`
- long-lived caching for `/_expo/static/*` + baseline security headers.

Or via the dashboard: **New Project → import the repo → set name `slg-golds`**,
add `EXPO_PUBLIC_CONVEX_URL`, deploy. Every push to `main` then auto-deploys.

## 3. Verify
- `npm run typecheck` → clean
- `npm test` → 8/8 integration suites pass
- `npm run build:web` → `dist/` generated
- Visit the Vercel URL, register a customer, enroll in a scheme, run a
  (mock) payment, confirm the ledger + portfolio update.

## Env var reference
| Var | Surface | Purpose |
|-----|---------|---------|
| `EXPO_PUBLIC_CONVEX_URL` | Vercel | Convex endpoint the web client calls |
| `AADHAAR_ENCRYPTION_KEY` | Convex | AES-256-GCM key (64 hex chars) for Aadhaar |
| `RAZORPAY_KEY_ID` / `_SECRET` | Convex | Live payments (else mock mode) |
| `BREVO_API_KEY` / `_SENDER_EMAIL` / `_SENDER_NAME` | Convex | OTP + notification email |
