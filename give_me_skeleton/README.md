# Give (Me) — Flutter Skeleton

This is a starter skeleton for the "Give (Me)" systems-balancing game.

Included:
- App shell + routing (go_router)
- State management (flutter_riverpod)
- Minimal turn engine + meters + actions
- Stub services wired for:
  - Google Play Billing (in_app_purchase)
  - AdMob (google_mobile_ads)
  - Analytics (local logger stub; swap later)

## How to open in Android Studio

1) Install Flutter + Android Studio Flutter plugin.
2) Create a new Flutter project *once* (so you get the Android/iOS folders):

   flutter create give_me

3) Copy this skeleton into that new project:
- Replace the generated `pubspec.yaml` with this one
- Replace the generated `lib/` folder with this one
- Copy `assets/` and this `README.md`

4) Fetch deps:

   flutter pub get

5) Run:

   flutter run

## Monetization notes

### In-App Purchases (Google Play Billing)
- This skeleton includes a Shop screen and an IAP service interface.
- You still need to create products in Google Play Console and set up testing.

### Ads (AdMob)
- The Ad service is stubbed and safe to leave off during development.
- When ready, create an AdMob app + unit IDs and wire them in.

## Project layout

lib/
  main.dart
  app/
    app.dart
    router.dart
  core/
    models/
    services/
    state/
    ui/
  features/
    dashboard/
    game/
    shop/
    settings/

## What to build next

- Flesh out the balancing rules (core/state/turn_engine.dart)
- Add events (random shocks) + scenario presets
- Add store SKUs + bundles + timed offers
- Add save/load (local + cloud)

