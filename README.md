# AgriConnect Pro — Flutter

Mobile UI for the AgriConnect Pro PRD, converted from the React/TanStack web prototype to Flutter. Includes context-aware background images for every screen, with light & dark variants.

## Run

```bash
flutter create .          # generates android/ ios/ platform folders
flutter pub get
flutter run
```

## Structure

- `lib/main.dart` — app, routes, theme toggle (`ThemeScope`)
- `lib/theme.dart` — colors + Google Fonts (Inter / DM Serif Display)
- `lib/widgets/phone_shell.dart` — shared scaffold with bg image, gradient overlay, bottom tab bar
- `lib/screens/` — 10 screens: home, vets, suppliers, market, assistant, reminders, weather, livestock, community, profile
- `assets/backgrounds/` — 20 jpgs (light + `-dark` variant per screen)

## Backgrounds

Every screen passes `bgImage` and `bgImageDark` to `PhoneShell`, which automatically swaps based on `Theme.of(context).brightness`. Toggle from the Home or Profile screen via the moon/sun button.
