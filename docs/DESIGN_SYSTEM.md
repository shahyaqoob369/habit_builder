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
| `textPrimary` | `#573353` | All text |
| `textMuted` | `#573353` at 50 % | Placeholders, secondary text ("Name", "41m ago", "37 Lessons") |
| `habitOrange` / `habitRed` / `habitBlue` / `habitMagenta` | `#FC9D45` / `#F65B4E` / `#29319F` / `#973456` | The 4 habit colors (cells, stat tiles) |
| `disabled` | `#C8C1C8` | Off reminder tiles |
| `placeholderImage` | `#C4C4C4` | Image placeholders |
| `facebook` | `#1772EA` | Facebook icon |
| `scrim` | dark overlay behind sheets and dialogs | Check its exact value in spec 11, 12 and 14 when building |

### Mapping from the current code (`AppColor`)
| Current | Value now | Change to |
|---|---|---|
| `primary` | `#FEA800` | **`#FDA758`** |
| `primaryText` | `#1B237E` (navy) | **`#573353`** (Eclipse) |
| `secondaryText` | `#573353` | merge into `textPrimary` / `textMuted` |
| `bg` | `#F5F5F5` | **`#FFF3E9`** |
| `bgSecondary` | `#FEF3DE` | **`#FFF3E9`** (same as background) |
| `secondary`, `primaryTextLight`, `placeholder`, `titleText`, `rate*`, `unselect`, `red`, `green` | various | not in the design. Remove them. |

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

### Type scale (most used first)
| Style | Font | Size / line height | Example |
|---|---|---|---|
| display-xl | Klasik 400 | 40/40, 36/32 | Course banner "HABIT COURSES" |
| display-l | Klasik 400 | 32/32 | Splash and onboarding titles |
| display-m | Klasik 400 | 24/32 | "CREATE YOUR ACCOUNT", "FORGOT YOUR PASSWORD?" |
| display-s | Klasik 400 | 24/16, 18/20.5 | Stat values ("20 DAYS"), quote card |
| title | Manrope 700 | 20/16 – 22/32 | Screen titles ("Homepage", "New Habit") |
| heading | Manrope 700 | 18/25 – 18/32, 17/24 | Card titles, course titles |
| button | Manrope 700 | 16/16, letter-spacing −0.48 | Primary buttons |
| body | Manrope 500 | 16/16, 16/22 | Inputs, list rows, post text |
| label-bold | Manrope 700 | 14/13 – 14/32, letter-spacing −0.42 | Habit names, labels (the most used style) |
| label | Manrope 500 | 14/16 – 14/22 | Secondary labels |
| caption | Manrope 500 / 700 | 12/13 – 12/14 | Meta info |
| micro | Manrope 700 / 500 | 10/13 – 10/14, 8/11 | Weekday labels (SUN, MON), counts |

---

## Shape and elevation

| Token | Value | Where |
|---|---|---|
| radius-m | **12** | Cards, fields, habit cells (203 uses, the default) |
| radius-button | **8** | Primary buttons (374×60) |
| radius-pill | 25 | Toggles, pills |
| radius-l | 15 / 20 | Large cards, dialog |
| radius-sheet | 12 on the top corners | Bottom sheets |
| shadow-sm | `0 2 6` `#573353` at 50 % | Toggles, small controls |
| shadow-card | `0 20 60` `#573353` at 15 % | Floating cards |
| shadow-primary | `2 3 6` `#FDA758` at 50 % | Orange toggle knobs |
| shadow-fab | `0 20 60` `#D07E32` at 50 % | Center + FAB glow |

## Components (from Figma component sets)

| Component | Variants | Spec |
|---|---|---|
| **PrimaryButton** | 374× and 334× widths | 60 tall, radius 8, fill `#FDA758`, label Manrope 700 16 `#573353` |
| **SecondaryButton** | — | Cream fill `#FFF3E9`, plum label ("Continue") |
| **SocialButton** | Google, Facebook (full-width or half) | White, radius 12, brand icon + Manrope 700 label |
| **TextField** | default, typing, password | 374×56, white or cream, radius 12; prefix icon + 1 px divider `#FFF3E9` at x=49; placeholder plum 50 %; typed text **orange bold** |
| **Checkbox** | on, off | Orange rounded square with plum check |
| **IconButton (header)** | Back, Edit, Help, Menu, Search | 44 circle, tinted fill, top-left and top-right at y≈28 |
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
| **OnboardingDots** (`Onboarding`) | 3 states | Active plum with a ring, others orange |
| **CongratulationDialog** | — | Illustration, Klasik title, body, 2 buttons, close button |

## Imagery

- Illustrations are raster images (hiker girl, teepee, campfire, mountains). The originals are in `docs/figma/assets/fills/`, and many are very large (2–9 MB). **Export optimized @2x/@3x PNG or WebP into `assets/img/` while building each screen.**
- The bottom-nav tab icons and several header icons are detailed illustrations (366 layers). Export them as PNGs, not SVG.
- Simple UI icons (back, edit, menu, search, lock, bell) can be SVG.
