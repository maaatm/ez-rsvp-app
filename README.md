# 🎁 e-z.rsvp — iOS (SwiftUI)

> **Say yes first. Find out later.**
> RSVP to a mystery experience before you know what it is. Get clues, bring
> friends, and on reveal day experience a cinematic, confetti-soaked reveal.

A premium, App-Store-quality SwiftUI app — **BeReal × Eventbrite × a mystery
box.** Built MVVM, iOS 18+, dark-mode-first, glassmorphic.

---

## ⚡️ Build & Run

This is an **[XcodeGen](https://github.com/yonwoo9/XcodeGen)** project — the
`.xcodeproj` is generated from `project.yml` (so it stays merge-conflict free).

```bash
# 1. Generate the Xcode project
brew install xcodegen        # if you don't have it
cd ez-rsvp-app
xcodegen generate

# 2. Open & run
open EZRsvp.xcodeproj         # ⌘R on an iOS 18 simulator (e.g. iPhone 16)
```

> **Requires Xcode 16+** (iOS 18 SDK). The app runs in **demo mode** out of the
> box — rich in-memory sample data, instant sign-in, zero backend setup. Ideal
> for a live hackathon demo on the simulator or a device.

### 🎬 Demo flow (for judges)
1. Launch → animated **"Say yes first." / "Find out later."** onboarding → pick interests.
2. **Sign in** (Apple / Google / Email all work instantly in demo mode).
3. **Home** → your headline mystery: live countdown, clues, attendees.
4. Tap **Open the reveal room** → **"Trigger the reveal now"** to fire the full
   ceremony on demand: darken → shake → glow → **confetti + heavy haptic** →
   3D card flip → **MapKit blur-to-zoom** with pin drop → share card.

---

## 🌟 What's inside

| Feature | Where |
|---|---|
| 🎬 **Cinematic reveal** (5-stage, haptics, 3D flip) | `Features/Reveal/RevealCeremony.swift` |
| 🗺️ **MapKit blur → zoom reveal** | `Components/BlurredMapView.swift` |
| 🎊 **Native confetti** (Canvas particle system, no Lottie) | `Components/ConfettiView.swift` |
| ⏱️ **Live countdown** (TimelineView) | `Components/CountdownView.swift` |
| 👥 **Group RSVP + live lobby** (readiness, polls) | `Features/Groups` |
| 🔍 **Clue unlock system** (time-gated) | `Components/ClueCard.swift`, `Models/Event.swift` |
| 📤 **Viral share card** (ImageRenderer + QR + Share Sheet) | `Features/Reveal/ShareCardView.swift` |
| 🤖 **Recommendation engine** | `Services/RecommendationEngine.swift` |
| 🔔 **Local notifications** (clues, RSVP, reveal day) | `Services/NotificationService.swift` |
| 💾 **SwiftData offline cache** | `Services/EventCache.swift` |
| 💡 **TipKit** onboarding hints | `Features/Profile/Tips.swift` |
| 📍 **Core Location** | `Services/LocationService.swift` |

## 🏗 Architecture (MVVM + DI)

```
Sources/
├── App/            EZRsvpApp (entry), RootView (router)
├── Models/         AppUser, MysteryEvent, RSVPGroup, RSVP, Enums
├── Services/       BackendService protocol ─┬─ MockBackend (demo)
│                                            └─ SupabaseBackend (prod, gated)
│                   SessionStore (state + DI), RecommendationEngine,
│                   NotificationService, LocationService, EventCache, SampleData
├── Components/     Reusable UI (glass, gradient bg, mystery box, cards…)
├── Features/       Onboarding, Authentication, Home, Events, Groups,
│                   Reveal, Profile  (View + view-state per feature)
├── Utilities/      Theme (design tokens), Haptics, Formatting, ViewModifiers
└── Resources/      Assets.xcassets, Info.plist
```

The whole app talks to a single `BackendService` **protocol**. Demo mode injects
`MockBackend` (an `actor`); production injects `SupabaseBackend`. Nothing else in
the app knows which is live — swap by flipping one flag.

---

## ⚡️ Enabling Supabase (Auth + Postgres + Storage)

The app is intentionally **zero-dependency** by default so it always builds.
To go live:

1. In `project.yml`, **uncomment** the `packages:` and `dependencies:` Supabase
   blocks.
2. `xcodegen generate` (resolves the `supabase-swift` SPM package).
3. Create a Supabase project, then copy its **Project URL** and **anon key**
   (Project Settings → API) into `AppConfig.supabaseURL` / `supabaseAnonKey`.
4. In **Supabase → Authentication → Providers**, enable **Apple**, **Google**,
   and **Email**.
5. Run `supabase-schema.md`'s tables + row-level-security policies.
6. Set `AppConfig.useSupabase = true`.

`SupabaseBackend.swift` already implements the data/auth methods (gated behind
`#if canImport(Supabase)`); the `SupabaseClient` initializes lazily from
`AppConfig`, so there's no global configure step.

### Sign in with Apple (production)
Real Sign in with Apple is implemented (`AppleSignIn.swift` + the production branch
in `AuthView`): it generates a secure nonce, sends its SHA256 to Apple, and exchanges
the returned identity token via Supabase's `signInWithIdToken`. To activate it:
1. In Xcode → target → **Signing & Capabilities → + Capability → Sign in with Apple**.
2. Enable Apple as a provider in **Supabase → Authentication → Providers** (add your
   Services ID + key).

(In demo mode the Apple button signs you in locally so it works without an entitlement.)

### Account deletion
The App-Store-required **Delete account** flow lives in **Profile** (with a
confirmation dialog). `SessionStore.deleteAccount()` calls
`SupabaseBackend.deleteAccount` (removes the `profiles` row, then deletes the auth
user via a `delete_account` Postgres RPC) and resets the app to a clean first-run state.

---

## ✅ Design & quality

- **HIG-aligned:** native Tab Bar, Sign in with Apple button, 44pt+ targets,
  Dynamic Type, **Reduce Motion** respected across every animation, safe areas.
- **Glassmorphism** via `.ultraThinMaterial`, violet→fuchsia→cyan brand gradient.
- **No emoji as icons** — SF Symbols throughout (emoji only ever appears as
  expressive copy, e.g. the "👋" greeting).
- **Haptics** on key moments (selection, success, the reveal's heavy burst).
- **Skeleton + shimmer** loading states.

---

## 📝 Notes
- The reveal map uses real MapKit with the venue's coordinates — it genuinely
  zooms from city-scale to the door.
- Times in `SampleData` are relative to "now," so the demo always shows a
  realistic upcoming reveal. Use **"Trigger the reveal now"** to skip the wait.

Built with ❤️ and a little mystery.
