# EduFirstOnline Mobile — UI Review Checklist

Status as of Step 5 (full app built on top of the approved flagship screen; real backend wired end-to-end and verified against production).

## Design system

- [x] Design system files (theme, typography, spacing, widget library) exist and are used consistently — no screen defines its own one-off colors or paddings
  - `lib/theme/app_theme.dart`, `app_typography.dart`, `app_spacing.dart`
  - `lib/widgets/`: `AppButton`, `AppCard`, `AppTextField`, `AppBadge`, `EmptyState`, `LoadingSkeleton` (+ `CourseCardSkeleton`, `SkeletonList`), plus two added in Step 5: `DecorativeHeader`/`DecorativeBlob` (the gradient-hero-with-shapes treatment from the approved login screen, now reused on every screen with a header: dashboard, discover, my courses, notifications, profile, course/package/teacher detail, course player, quiz screens) and `StatChip`/`WebviewScreen`.
- [x] Flagship screen (Step 4) reviewed and approved (**"much better"**, user feedback) — its decorative-header treatment was then generalized into a shared component and applied to every other screen, per the explicit follow-up instruction.
- [x] Every list/grid has a loading skeleton state, not a spinner — `SkeletonList`/`LoadingSkeleton` used on discover, my courses, notifications, packages, teachers, quiz list, course/package/teacher detail.
- [x] Every list/grid has a designed empty state, not a blank screen — `EmptyState` used for: no search results, no enrolled courses yet, no notifications, no packages/teachers/quizzes, and network-error-with-retry everywhere.
- [ ] RTL layout verified correct on a real Arabic device/simulator — verified in Chrome at a phone-representative width across the login/register screens; other screens verified via `flutter analyze` + a live API/model integration check (see Testing note below), not yet visually screenshotted one-by-one. **Full visual RTL pass on a real iOS/Android device/simulator still outstanding.**
- [x] "In collaboration with Quadro Cloud" attribution present in two places — login screen footer and the profile screen (About section + bottom of the main list).
- [x] Buttons have visible pressed/disabled states — `AppButton`'s press-scale animation, used throughout.
- [x] Lottie animation used on the login screen header (still the placeholder character noted below).
- [x] Gold accent color used beyond the login screen — package/quiz icons, "premium teacher" badge, feature chips.
- [x] App feels visually consistent screen-to-screen — every screen with a header uses `DecorativeHeader`; every list uses `AppCard` tiles with the same icon-chip + title + meta-row shape; every loading/empty/error state goes through the same three shared components.

## What Step 5 actually built

- **Foundation**: `ApiClient` (auth header injection, Laravel validation-error unwrapping), `AuthService` (session bootstrap/login/register/logout via `shared_preferences`), typed models + services for courses, dashboard, quizzes, packages, teachers, notifications, and the webview-ticket bridge.
- **Screens**: splash (session bootstrap gate) → login/register (both wired to the real API) → 5-tab shell (home dashboard, discover/browse, my courses, notifications, profile) → course detail → course player (curriculum + progress + lecture webview) → quiz list/take/result → package list/detail → teacher list/detail.
- **Education data** (`lib/data/education_data.dart`) mirrors `config/education.php` exactly (stage/grade keys, subject labels) since no endpoint exposes it — used for the register form and for labeling course grade/subject everywhere.

## Known gaps / flags (per your own "flag, don't invent" instruction)

- **No Live Sessions / Jitsi API exists on the backend** — unchanged from Step 4, still a separate future task.
- **The public course-detail endpoint doesn't expose whether the current student is enrolled.** Worked around by cross-checking the student's own `/my-courses` list client-side (an extra request) rather than inventing a new backend field — flagging in case a dedicated `enrolled: true/false` field would be worth adding server-side later.
- **Video/document/live lecture content and both purchase flows (course + package) render inside an in-app WebView** pointed at the existing web player/checkout via `POST /mobile/webview-ticket` — there's no native video player or native payment flow, by design (matches how the backend is actually built; not something this app should invent). Neither flow has a completion callback, so the app just refreshes its own state when the WebView screen is closed.
- **Lecture "mark complete" is a manual tap** (a checkbox next to each lecture, calling `POST /lectures/{id}/complete`), not automatic playback-position tracking — the `POST /lectures/{id}/progress` endpoint exists for real scrub-position tracking, but that requires a JS bridge into the WebView player that doesn't exist yet. Flagging as a possible Step 6 improvement, not built now.
- **No forgot-password endpoint exists** — the login screen's "نسيت كلمة المرور؟" link is a visual placeholder with no action, matching current backend capability.
- Login screen is now **wired to the real `POST /api/auth/login`** (previously a `TODO`) — the identifier field was narrowed from "phone or email" to "email" only, since the backend endpoint only validates/looks up by email.

## Testing note

Two different execution paths were needed because neither of this project's usual verification methods fully applied here:

1. **Visual check (Chrome)**: `flutter create --platforms=web` added temporarily, ran the app, screenshotted the login/register screens at a phone-representative size, then removed `web/` again (shipped app is iOS/Android only). `webview_flutter` has no web implementation, so screens that open a WebView weren't exercised this way — expected, not a bug.
2. **Live backend/model check**: `flutter test`'s test binding fakes all HTTP traffic (returns a blanket 400, confirmed by trying), so it can't validate anything against the real API. Instead, a temporary standalone script (`dart run`, deleted afterward) drove `ApiClient`/`ContentService`/`DirectoryService`/`NotificationService` directly against **production** — registered one real throwaway student, then exercised `/me`, login, dashboard, my-courses, browse courses, course detail (with real sections/lectures), teacher directory + detail, packages + detail, notifications, logout, and confirmed the token was rejected post-logout. **23/23 checks passed** — every model parses real production response shapes correctly. The throwaway student was deleted afterward via SSH (`students` row, `personal_access_tokens` row, `users` row).

**Still outstanding**: a full interactive tap-through on a real iOS/Android device/simulator (this project's synthetic-OS-input tooling doesn't reliably drive a Flutter render surface, so that kind of test couldn't be done here either) — recommended once you pull this onto your Mac.
