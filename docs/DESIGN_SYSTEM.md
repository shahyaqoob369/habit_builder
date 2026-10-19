# Design System

Source of truth: the Figma file (pulled 2026-10-18). Raw counts are in [figma/tokens.md](figma/tokens.md), and the brand sheet is [figma/assets/fills/branding-guidelines-c834047d.png](figma/assets/fills/branding-guidelines-c834047d.png) (a local file, not in git).

**Brand:** *Monumental: building habits, one step at a time.* Keywords: motivational, inspiring, personal, dedicated, light, energy, new beginning, transparent, honest, guided, well-rounded.

Frame size is **414 × 896**, with a horizontal screen padding of **20** (content width 374).

---

## Colors

### Brand palette (Branding Guideline)
| Name | Hex | Role in screens |
|---|---|---|
| **Eclipse** | `#573353` | **All text** (345 text layers), icons, dark toggle knob, active onboarding dot |
| **Sunset** | `#F65B4E` | Red habit color, accents |
| **Twilight** | `#29319F` | Blue habit color |
| **Morning** | `#FFBA7C` | Light orange accents in illustrations |
| **Fog** | `#FFDEEF` | Pink accents in illustrations |

### UI colors (measured in screens)
| Token | Hex | Used for |
|---|---|---|
| `primary` | `#FDA758` | Primary buttons, typed input text, links ("Custom", "10:00AM", "Restore Purchase"), checkboxes, FAB |
| `primaryDark` | `#FC9D45` | Orange habit color, FAB |
| `primaryLight` | `#F9B566` | Inactive onboarding dots, soft accents |
| `primary20` | `#FDA758` at 20 % | Tinted fills (toggle "On" track, icon tiles) |
| `background` | `#FFF3E9` | Screen background (96 uses), also the field dividers |
| `surface` | `#FFFFFF` | Cards, fields, sheets |
| `surfaceTinted` | `#FFF6ED` (≈ `#FC9D45` at 10 % on white) | Fields on a white card (login panel, reset card) |
| `error` | `#F65B4E` (brand Sunset; not in the design) | Validation errors |
| `textPrimary` | `#573353` | All text |
| `textMuted` | `#573353` at 50 % | Placeholders, secondary text ("Name", "41m ago", "37 Lessons") |
| `habitOrange` / `habitRed` / `habitBlue` / `habitMagenta` | `#FC9D45` / `#F65B4E` / `#29319F` / `#973456` | The 4 habit colors (cells, stat tiles) |
| `disabled` | `#C8C1C8` | Off reminder tiles |
| `placeholderImage` | `#C4C4C4` | Image placeholders |
| `facebook` | `#1772EA` | Facebook icon |
| `scrim` | dark overlay behind sheets and dialogs | Check its exact value in spec 11, 12 and 14 when building |

### In code (step 2)
- Raw values: `AppPalette` in `lib/app/theme/app_palette.dart`.
- Semantic tokens: `AppColors` (ThemeExtension), read with `context.colors`. The token names match the **Token** column above, plus `primarySoft`, `divider`, `disabled`, `scrim` (`#040920` at 50 %) and `facebook`.
- Text: `AppTextStyles` in `lib/app/theme/app_text_styles.dart`. The style names are listed in the type scale below.
- Spacing, radii, shadows: `AppSpacing`, `AppRadii`, `AppShadows` in `lib/app/theme/app_dimens.dart`.
- The developer preview of every token is the **design-system page** (the app's home until step 3).

---

## Typography

| Family | Weights used | Role | In project? |
|---|---|---|---|
| **Klasik** (design) → **Fredoka** (app) | Klasik Regular → **Fredoka SemiBold 600** | Display headings, always UPPERCASE ("WELCOME TO MONUMENTAL HABITS", "CREATE YOUR ACCOUNT", "20 DAYS") | ✅ `assets/font/Fredoka-SemiBold.ttf`, family `fredoka` (OFL, license in `assets/font/OFL-Fredoka.txt`) |
| **Manrope** | Medium 500, Bold 700 | All other text | ✅ (only 500 and 700 are needed) |

**Why Fredoka:** Klasik (Muhajir Anwar / Font co id) is "only available for testing … non-commercial … contact the author for purchase", which doesn't work for a paid app. Twelve open-license fonts were compared against the Figma renders, and Fredoka SemiBold matched best: the same weight, rounded stroke ends and round O/C/S.

**Converting Klasik values to Fredoka** (Klasik's cap height is 0.583 of its size; Fredoka's is 0.700):
- `fontSize` = Klasik size × **0.83** → 40→33, 36→30, 32→26.5, 24→20, 18→15
- `letterSpacing` = fontSize × **0.015** (Fredoka is slightly narrower; this matches the line widths to within 1 %)
- `height` (line height): keep the Figma line-height px, so `height = figmaLineHeight / fontSize`

Figma reports some Manrope weights as `1`. That's a variable-font quirk; the style names (Medium, Bold) are correct.

### Type scale (`AppTextStyles`, implemented in step 2)
Line heights are the exact Figma values, with `leadingDistribution: even` (Figma spreads leading evenly). Every Manrope style uses −3 % letter spacing.

| `AppTextStyles.` | Figma source | Used for |
|---|---|---|
| `displayLarge` | Klasik 40/40 | Splash title |
| `displayMedium` | Klasik 36/32 | Courses banner "HABIT COURSES" |
| `displaySmall` | Klasik 32/32 | Onboarding titles |
| `headline` | Klasik 24/32 | "CREATE YOUR ACCOUNT", "FORGOT YOUR PASSWORD?", "CONGRATULATIONS!" |
| `stat` | Klasik 24/16 | "20 DAYS", "98 %" |
| `quote` | Klasik 18/20.5 | Home quote card |
| `pickerSelected` / `pickerOption` | Manrope 700 32/32 · 500 22/32 | Time picker |
| `price` | Manrope 700 24/14 | Paywall prices |
| `timeTile` | Manrope 700 20/16 | Reminder tiles "06:00 AM" |
| `title` | Manrope 700 18/32 | Screen and sheet titles |
| `cardTitle` | Manrope 700 18/25 | Course titles |
| `lead` | Manrope 700 17/24 | Onboarding subtitle, Skip and Next |
| `button` | Manrope 700 16/16 | Buttons, typed input text, row values |
| `sectionLabel` | Manrope 500 16/24 | "Log in with email" |
| `optionLabel` | Manrope 500 16/22 | Checkbox labels |
| `body` | Manrope 500 16/16 | Placeholders, list rows |
| `bodyStrong` | Manrope 700 16/14 | "37 Lessons (2h 41m)", countdown |
| `labelStrong` | Manrope 700 14/13 | Habit names, day numbers |
| `label` | Manrope 500 14/16 | Progress-ring numbers |
| `helper` | Manrope 500 14/22 | Links and helper text |
| `paragraph` | Manrope 500 14/20 | Community posts |
| `caption` / `captionStrong` | Manrope 500 12/14 · 700 12/13 | Meta text · plan names |
| `overline` | Manrope 700 10/13 | SUN, MON; On and Off |
| `micro` | Manrope 500 10/13 | "06/14", "Today" |
| `tiny` | Manrope 500 8/10.9 | Like and comment counts |

---

## Shape and elevation

| Token | Value | Where |
|---|---|---|
| radius-m | **12** | Cards, fields, habit cells (203 uses, the default) |
| radius-button | **8** | Primary buttons (374×60) |
| radius-pill | 25 | Toggles, pills |
| radius-l | 15 / 20 | Large cards, dialog |
| radius-sheet | 12 on the top corners | Bottom sheets |
| radius-panel | 20 on the top corners | Login panel (`AppRadii.panel`) |
| radius-checkbox | 6 | Checkboxes (`AppRadii.checkbox`) |
| shadow-sm | `0 2 6` `#573353` at 50 % | Toggles, small controls |
| shadow-card | `0 20 60` `#573353` at 15 % | Floating cards |
| shadow-primary | `2 3 6` `#FDA758` at 50 % | Orange toggle knobs |
| shadow-fab | `0 20 60` `#D07E32` at 50 % | Center + FAB glow |

## Components (from Figma component sets)

| Component | Variants | Spec |
|---|---|---|
| **PrimaryButton** ✅ `core/widgets/primary_button.dart` | 374× and 334× widths | 60 tall, radius 8, fill `#FDA758`, label Manrope 700 16 `#573353`; loading state |
| **SecondaryButton** | — | Cream fill `#FFF3E9`, plum label ("Continue") |
| **SocialButton** ✅ `features/auth/presentation/widgets/social_button.dart` | Google, Facebook; `wide` (Login) or compact (Sign Up) | 50 tall, white, radius 12; wide: logo 63 pt in, label 29 pt after; compact: centered, 16 pt gap; logo shadow baked into the WebP |
| **TextField** ✅ `core/widgets/app_text_field.dart` | default, typing, password | 374×56, white or `surfaceTinted`, radius 12; icon cell 49 + 1 px divider `#FFF3E9`, text at 65 (20 without icon); placeholder plum 50 %; typed text **orange bold**; icon orange when focused or filled; Show/Hide 20 from the right |
| **Checkbox** ✅ `core/widgets/app_checkbox.dart` | on, off | 20 square, radius 6, orange with plum check; off (not designed): white with orange outline; label 11 after |
| **IconButton (header)** ✅ `core/widgets/header_icon_button.dart` | Back, Edit, Help, Menu, Search | 44 circle, plum 10 % fill, 48 touch target; placed right below the status bar |
| **TextLink** ✅ `core/widgets/text_link.dart` | underlined, prompt + bold | Manrope 500 14/22 ("Forgot Password?", "Don’t have an account? **Sign up**") |
| **HabitCell** (`Component 3`) | Large / Medium × **Full / Half** × Orange / Red / Blue / Magenta | 54 box at 10 % tint, radius 12; Full = 50 square; Half = diagonal triangle |
| **DayChip** | Default, Today | Weekday + date; Today has a bar on top |
| **CalendarDay** (`Calendar`) | Sun–Sat | Month calendar cell with a HabitCell |
| **Toggle** (`Toggle OnOff`, `Reminder Toggle`) | On, Off | Pill with "On"/"Off" text and a knob |
| **ReminderTile** (`Time Set`) | On, Off | Time + toggle; Off = grey `#C8C1C8` |
| **BottomNav** (`Menu`) | — | 4 illustrated tab icons (Home tent, Courses easel, Community people, Settings compass) plus a centre FAB on a curved notch. The active tab is in color and the others are greyscale. |
| **FAB** (`Menu Button`) | Add (+), Saved (✓) | Orange circle with a glow |
| **StatTile** (`Analytics`) | 4 colors | Number + label + round icon |
| **SettingsRow** (`Setting 7/8`) | About, Contact, Feedback, Privacy Policy, More customization | Icon tile + title (+ subtitle) + chevron |
| **PostCard** (`Share Post`) | — | Avatar, name, time, share button, text, ♥ and 💬 counts |
| **PageDots** ✅ `core/widgets/page_dots.dart` (`Onboarding`) | 3 states | Active: 13 plum dot in a 17 ring at 20 %; others: 11 `#F9B566`; 7 apart |
| **HighlightedText** ✅ `core/widgets/highlighted_text.dart` | — | Words in `<h>…</h>` get the highlight color (`#FC9D45` on onboarding) |
| **CongratulationDialog** | — | Illustration, Klasik title, body, 2 buttons, close button |

## Imagery

- Illustrations are raster images (hiker girl, teepee, campfire, mountains). The originals are in `docs/figma/assets/fills/`, and many are very large (2–9 MB). **Export optimized @2x/@3x PNG or WebP into `assets/img/` while building each screen.**
- The bottom-nav tab icons and several header icons are detailed illustrations (366 layers). Export them as PNGs, not SVG.
- Simple UI icons (back, edit, menu, search, lock, bell) can be SVG.
