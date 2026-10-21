# Working Rules

How this project is built. Set by the owner on 2026-10-18. Claude follows these on every step. To change a rule, the owner says so, and this file is updated in the next step's PR.

## 1. Step workflow

The steps are listed in [PLAN.md](PLAN.md). For **every** step:

1. **Keep going.** Since 2026-10-20 the owner wants the steps done back to back, without waiting for a "go" between them, until they stop for a review. Stop at any blocker (below).
2. **Branch** from the latest `main`: `step/NN-short-name` (for example `step/03-design-tokens`).
3. **Build** only that step's scope. Anything else that turns up goes into [KNOWN_ISSUES.md](KNOWN_ISSUES.md) or a later step.
4. **Verify**: `flutter analyze` reports no new issues, and `flutter test` passes.
5. **Mark the step ✅** in PLAN.md and update the other docs it touches (SCREENS, KNOWN_ISSUES, the MEMORY session log).
6. **Commit, push and open a PR** using the template in §2.
7. **Self-review** the whole diff against the checklist in §3. Fix what it finds, then post the review result as a PR comment. (GitHub doesn't let an author approve their own PR.)
8. **Merge**: squash merge, delete the branch, update local `main`.
9. **Check it on the iOS Simulator** the owner has open (**iPhone and the App Store come first**, Android after). Open a screen directly with `--dart-define=INITIAL_ROUTE=/route` (debug builds) and screenshot with `xcrun simctl io booted screenshot`; compare against Figma.
10. **Report** what changed, the PR link and review findings, then move to the next step. Stop and report fully when the owner asks for a review or a step is blocked.

**Blockers:** if a step needs a decision, a paid action, or access to the owner's accounts (Firebase, Apple, Google, Facebook, RevenueCat, stores), stop and ask. Claude prepares exact instructions; the owner does or approves the action. Never guess on these.

## 2. Git

- Branches: `step/NN-name` for plan steps, `fix/name` for urgent fixes.
- Commit messages: `type(scope): summary` in the imperative mood, where type is `feat`, `fix`, `chore`, `docs`, `refactor` or `test`. Examples: `feat(auth): add reset password screen`, `chore: normalize line endings`.
- One step = one PR = one squash commit on `main`. Never force-push `main`.
- PR description sections: **Summary**, **Changes**, **How to test on device**, **Placeholder copy replaced** (if any), **Checklist**.

## 3. Self-review checklist

- [ ] Only this step's scope; no unrelated changes
- [ ] No secrets, tokens or personal data in the diff
- [ ] `flutter analyze`: no new issues. `flutter test`: passes. The CI check on the PR is green.
- [ ] Screens match `docs/figma/screens/NN-*/main.png` (layout, colors, fonts, spacing within about 2 px at 414×896)
- [ ] Theme tokens and shared widgets used; no hex values or raw font sizes in screen files
- [ ] No overflow on a small phone (375×667) or at 1.3× text scale
- [ ] Data screens have loading, empty and error states
- [ ] Docs updated (PLAN ✅, SCREENS, KNOWN_ISSUES, MEMORY log)

## 4. Code

- Folder layout and principles are in [ARCHITECTURE.md](ARCHITECTURE.md): feature-first `lib/features/<area>/{presentation,application,domain,data}`.
- **State: Riverpod. Navigation: go_router** (routes in the `AppRoute` enum). These are the defaults until the owner says otherwise.
- **Lints: `very_good_analysis`.** `flutter analyze` must report *No issues found*. Run `dart format` before every commit.
- **No hardcoded design values:** use `context.colors`, `AppTextStyles`, `AppSpacing`, `AppRadii` and `AppShadows`.
- **No hardcoded user-facing text:** add it to `lib/l10n/arb/app_en.arb` and read it with `context.l10n`.
- Extract a widget when it's reused, or when a `build` method grows past about 80 lines. Prefer `const` constructors and small private widget classes over helper methods.
- Dart naming conventions; `snake_case` file names.
- Comments explain *why*, not *what*. No `print()`; use `debugPrint` or `log`.
- Every new component or page gets widget tests; pure logic gets unit tests (`test/` mirrors `lib/`).

## 5. Design fidelity

- Exact values come from `docs/figma/screens/NN-*/spec.txt`; `main.png` is for the visual check. Turn absolute positions into real layout (padding, rows, columns), not `Positioned` everywhere.
- **Responsive:** frames are 414 dp wide, but the test phone is **360 × 800 dp**. Keep the design's paddings, component heights and type sizes, and let widths flex. Vertical rhythm on full-screen layouts (splash, onboarding) uses flexible space proportional to the design. Never scale fonts by screen size.
- **Pixel check:** each screen is compared side by side with its Figma render (a device screenshot next to `main.png`), and the comparison is noted in the PR.
- **Display font is Fredoka SemiBold**, the free (OFL) stand-in for Klasik: **Fredoka size = Klasik size × 0.83**, letter spacing = size × 0.015. Everything else is Manrope 500 or 700.
- **Placeholder copy** in the design (lorem ipsum, "6-month plan for 39.99 usd", "Goggle Play", "TUE 18" twice, "habits makes us") is replaced with real copy. Each replacement is listed in the PR.
- **Screens missing from the design** are built in the app's style from existing components, and flagged in the PR for the owner to review.

## 6. Assets

- Originals are in `docs/figma/assets/fills/` (local-only). Export optimized versions into `assets/img/<area>/`, using Flutter's `2.0x/` and `3.0x/` folders. Aim for ≤ 300 KB per image.
- Name files in `snake_case` with an area prefix, for example `onboarding_intro_1.png`.
- Use SVG for simple UI icons and PNG for illustrated icons (the bottom-nav tabs).

## 7. Secrets and public repo

- **The GitHub repo is public.** Figma exports (`docs/figma/raw`, `assets`, `screens`) stay local-only (gitignored).
- Never put tokens, keys, passwords or keystores in the repo or in chat. Use environment variables or gitignored local files.
- Firebase config files are kept out of git (owner, step 13), and so is the Firebase project ID ([FIREBASE.md](FIREBASE.md)). CI uses a placeholder (`tool/ci/firebase_options_stub.dart`), not GitHub secrets.
