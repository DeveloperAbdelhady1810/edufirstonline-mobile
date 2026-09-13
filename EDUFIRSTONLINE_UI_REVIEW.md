# EduFirstOnline Mobile — UI Review Checklist

Status as of the Step 4 checkpoint (flagship screen built, awaiting approval before continuing).

- [x] Design system files (theme, typography, spacing, widget library) exist and are used consistently — no screen defines its own one-off colors or paddings
  - `lib/theme/app_theme.dart`, `app_typography.dart`, `app_spacing.dart`
  - `lib/widgets/`: `AppButton`, `AppCard`, `AppTextField`, `AppBadge`, `EmptyState`, `LoadingSkeleton` (+ `CourseCardSkeleton`, `SkeletonList`)
- [ ] Flagship screen (Step 4) reviewed and approved before other screens were built — **revised for visual appeal per your feedback (decorative hero shapes, larger floating Lottie mascot, gold-accent feature chips, colored icon circles on fields, warmer copy), screenshot sent, awaiting your sign-off**
- [ ] Every list/grid has a loading skeleton state, not a spinner — component exists (`SkeletonList`); not yet used on a real screen (no list screens built yet)
- [ ] Every list/grid has a designed empty state, not a blank screen — component exists (`EmptyState`); not yet used on a real screen
- [ ] RTL layout verified correct on a real Arabic device/simulator — verified in Chrome at a phone-representative width: icons mirror correctly (prefix icons right/start, suffix icons left/end), text aligns correctly, no clipping. **Not yet tested on a real iOS/Android device/simulator.**
- [x] "In collaboration with Quadro Cloud" attribution present somewhere in the app — footer on the login screen (`بالتعاون مع Quadro Cloud`). Rendered via the same pattern as other confirmed-working text on that screen; not independently pixel-verified due to a scroll-automation limitation in this environment (documented below) — please confirm you can see it when scrolling to the bottom of the login screen.
- [x] Buttons have visible pressed/disabled states, not just default Material ripple — `AppButton` has a custom press-scale animation and a distinct disabled style
- [x] At least one Lottie animation used somewhere appropriate — used on the login screen header, now larger with a gentle looping float animation. **This specific animation is a placeholder** (a generic character, verified working but not education-themed or brand-chosen) — swap for a real pick before shipping.
- [x] Gold accent color actually used somewhere (not just defined and unused) — feature-highlight chips beneath the hero ("دروس شيقة" / "شارات وإنجازات" / "تتبع تقدمك") use it on their icons.
- [ ] App feels visually consistent with itself screen-to-screen — only one screen exists so far; applies once more screens are built (Step 5)

## Known gaps / flags (per your own "flag, don't invent" instruction)

- **No Live Sessions / Jitsi API exists on the backend.** Confirmed via `php artisan route:list --path=api` against production — 33 real routes exist (auth, courses, my-courses, lecture progress, quizzes, notifications, dashboard, packages, teachers, HLS video), but nothing for live classes. A mobile "join live class" screen can't be built until that API exists — separate task, not started here.
- Purchases go through a `POST /api/mobile/webview-ticket` bridge (WebView-based checkout), not a native purchase flow — relevant once the course-purchase screen is built.
- Login screen is visually complete but **not yet wired to the real `POST /api/auth/login`** — intentionally deferred until this design direction is approved (see the `TODO(backend-integration)` in `login_screen.dart`).

## Testing note

Verified by running the app live in Chrome (`flutter create --platforms=web` added temporarily for this purpose, then removed — shipped app is iOS/Android only) and screenshotting the actual rendered output at a phone-representative window size, rather than relying on static code review alone. Real device/simulator testing (iOS + Android) still needed once screens are built out further.
