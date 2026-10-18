# Backend Spec

The data model, operations and business rules the app needs, **worked out from the Figma design** (pulled 2026-10-18, 20 screens) and the owner's answers.

Each rule shows its source and a confidence level:
- ✅ **Shown**: the design shows it directly.
- 🟡 **Inferred**: strongly implied by the design.
- ❓ **Question**: the design is unclear; the owner must answer. Questions are collected at the bottom.

Screen numbers refer to [figma/index.md](figma/index.md).

---

## 1. What the app is

Building habits "one step at a time … keeping a streak alive" (Branding Guideline). The app has five areas:

| Area | Screens | Needs a server? |
|---|---|---|
| Habit tracking: create habits, mark days, streaks, reminders | 09–14 | No, it can work offline. A server is needed only for sync and backup. |
| Courses: video lesson courses about habits | 15, 16 | **Yes**, for content, video hosting and premium locks |
| Community: posts from users, likes, comments, share | 17 | **Yes**, it's shared data |
| Account and profile: sign up, login, social login, password reset, profile stats | 06–08, 18, 19 | **Yes**, for authentication |
| Premium: subscription with three plans and a time-limited offer | 20 | **Yes**, through store billing and entitlement checks |

**Conclusion:** this is not a local-only app. It needs authentication, a cloud database, file and video storage, and in-app subscriptions.

---

## 2. Entities

### User (06, 07, 18, 19)
| Field | Source | Notes |
|---|---|---|
| id | — | from the auth provider |
| name | ✅ Sign Up ("Mira Passaquindici"), Profile ("Marilyn Aminoff") | |
| email | ✅ Sign Up, Login, Settings ("jonathansmith@gmail.com") | |
| password | ✅ Sign Up, Login | held by the auth provider only, never stored by us |
| authProviders | ✅ Google, Facebook, email | iOS also needs **Sign in with Apple** (App Store rule 4.8) |
| avatar | ✅ Profile, Home, Community (illustrated avatars) | Premium unlocks "all avatar illustrations" (20), so avatars come from a catalogue with free and premium items |
| marketingOptIn | ✅ Sign Up ("Email me about special pricing and more") | |
| keepSignedIn | ✅ Sign Up | ❓ what does unchecked mean? See Q11 |
| premium | 🟡 Premium (20) | plan, status, expiry. Mirrored from the store or RevenueCat |
| createdAt, timezone | 🟡 | timezone is needed so "today" and streaks use the user's local day |

### Habit (09, 10, 11, 12, 13)
| Field | Source | Notes |
|---|---|---|
| id, userId, createdAt | — | |
| name | ✅ "Enter habit name" (10) | examples: Read A Book, Exercise, Wake Up Early, Walk Dog, Water Plants |
| icon | ✅ icon button with "+" next to the name (10) | ❓ the icon picker isn't designed (Q5) |
| color | ✅ each habit has one color (09): Orange `#FC9D45`, Red `#F65B4E`, Blue `#29319F`, Magenta `#973456` | ❓ chosen by the user or assigned automatically? (Q4) |
| frequency | ✅ "Habit Frequency: Custom" with Sun–Sat day toggles (10); "Repeat everyday" (13) | 🟡 type is `daily` or `custom` (a set of weekdays) |
| reminders[] | ✅ several times per habit, each with its own on/off toggle (11, 12) | entries are `{time: "HH:mm", enabled}`. The summary row shows one time ("10:00AM", "Reminders: 5:00 am") |
| notificationsEnabled | ✅ "Notification" On/Off toggle (10) | master switch for this habit's reminders |
| archived / deleted | 🟡 | no delete UI in the design (Q6) |

### HabitEntry: one per habit per day (09, 13)
| Field | Source | Notes |
|---|---|---|
| habitId, date (`yyyy-MM-dd`, user's local day) | ✅ the grid and calendar are per day | |
| status | ✅ cells are **Full** or **Half** (`Component 3`, `Property 2=Full / Half`), and some days are empty. Buttons: "Mark Habit as Complete" / "Mark Habit as Missed" (13) | 🟡 Full = completed, Half = missed (or partly done?), Empty = no record. **Q1** |
| easinessScore | ✅ "Average Easiness Score: 7" (13) | ❓ there's no rating input in the design. Is it a 1–10 rating on completion? **Q2** |
| updatedAt | — | |

### Derived habit stats (13): computed, not stored
| Stat | Rule |
|---|---|
| Current streak | 🟡 count of consecutive **due** days marked complete, ending today or yesterday. Days that aren't due don't break a streak. |
| Longest streak | 🟡 the longest such run ever (13 and Profile 18: "20 Days") |
| Completion rate | 🟡 completed ÷ due days, from habit creation to today |
| Average easiness | 🟡 mean of easinessScore (Q2) |

### Quote (09)
✅ Home shows a quote card: "We first make our habits, and then our habits makes us. – Anonymous". 🟡 Fields are text and author, and the quote rotates daily. ❓ Do we provide the quote list, or does it come from the server? (Q7)

### Course (15, 16)
| Field | Source |
|---|---|
| title, coverImage | ✅ "30 Day Journal Challenge – Establish a Habit of Daily Journaling" |
| totalDuration, lessonCount | ✅ "2h 41m", "37 Lessons" |
| popularity / sort fields | ✅ "Sort By: Popular" (other sort options aren't designed) |
| category / tags for Filters | ✅ a "Filters" dropdown exists; ❓ which filters? (Q8) |
| isPremium | 🟡 Premium: "Access to all courses" |

### Lesson (16)
| Field | Source |
|---|---|
| courseId, order, title, duration, videoUrl | ✅ "1. Introduction 2:16", with a video preview and play button |
| locked | ✅ lesson 1 has a play icon; lessons 2–5 have locks. 🟡 Locked = premium only, with lesson 1 a free preview. ❓ Or are lessons unlocked one after another? (Q9) |

### Bookmark (15)
✅ A bookmark icon on each course card, and the bottom-menu component has a "Saved" variant. 🟡 Fields are userId and courseId. ❓ Where is the "Saved courses" list shown? (Q8)

### Community post (17)
| Field | Source |
|---|---|
| author (name, avatar) | ✅ Jerome, Gretchen, Al, Colin |
| text | ✅ long text, cut off with "…" (so there's a post detail view) |
| createdAt | ✅ "41m ago" |
| likeCount, commentCount | ✅ ♥ 3.1k, 💬 22 |
| share | ✅ share button on each post (`Share Post` component) |
| Like, Comment (sub-entities) | 🟡 counts imply both exist. Comment UI isn't designed. |
❓ Who can post, and how? There's no "create post" UI (Q10). Posts read like course reviews: are they linked to a course?

### Subscription (20)
| Field | Source |
|---|---|
| plans | ✅ Monthly **$19.00**, Yearly **$29.00** ("Most Popular"), Lifetime **$49.00** ("-75%") |
| intro offer | ✅ "60% off your upgrade", "Expires in 23:56:48" countdown |
| benefits | ✅ Unlimited habits · Access to all courses · Access to all avatar illustrations |
| store | ✅ "Secured with Goggle Play. Cancel anytime" (typo in the design), "Restore Purchase" |
⚠️ The small text under every price says "6-month plan for 39.99 usd". This is placeholder copy. Real prices must come from the store.

### Profile stats (18)
✅ Period selector ("This week"), **Task Completed: 12**, **Total Work Hours: 18**, and a row of daily progress rings (7, 0, 6, 5, 4, 9, 10 with "Today").
- 🟡 Task Completed = habit entries marked complete in the period.
- 🟡 Daily ring = completed ÷ due habits that day, with the count shown in the middle.
- ❓ **Total Work Hours** needs habit durations or time tracking, and neither appears anywhere else (Q3).

### Other
- **Feedback / Contact** (19): 🟡 a feedback message stored on the server, or sent by email.
- **Billing methods** (18): 🟡 probably opens the store's subscription management, since the store handles payment methods.

---

## 3. Flows and operations

| Flow | Operations | Screens |
|---|---|---|
| Sign up | create account (name, email, password, marketingOptIn) → signed in → Home | 07 |
| Log in | email and password · Google · Facebook (· Apple on iOS) | 06 |
| Forgot password | send reset link to email | 08 |
| Sign out / delete account | ⚠️ not in design. **Account deletion is required by both stores** if users can sign up. | — |
| Create habit | name, icon, frequency, reminders[], notifications on/off → save (✓ FAB) | 10–12 |
| Edit habit | pencil on habit detail. 🟡 reuses the New Habit form | 13 |
| Mark a day | complete / missed for a habit and date | 13 (and 🟡 tap a cell on Home?) |
| View habit | month calendar (prev/next), streaks, rates | 13 |
| Celebrate | Congratulation popup → "Create New Habit" or "Continue". ❓ what triggers it? (Q12) | 14 |
| Reminders | schedule a **local notification** at each enabled time on the habit's due days | 10–12 |
| Browse courses | list, sort, filter, search, bookmark | 15 |
| Watch lesson | play video. Locked lessons → paywall | 16 |
| Community | list posts (newest first?), like, comment, share | 17 |
| Profile | stats for a period; edit profile (pencil) | 18 |
| Upgrade | buy a plan, restore purchases, check entitlement | 20 |

---

## 4. Business rules

| # | Rule | Confidence |
|---|---|---|
| R1 | A habit is **due** on a date if its frequency includes that weekday (daily means every day). | 🟡 |
| R2 | One entry per habit per day. Marking a day again replaces the earlier status. | 🟡 |
| R3 | Streaks count only due days. A day that isn't due neither breaks nor extends a streak. Today counts as pending until midnight local time. | 🟡 |
| R4 | Free users get a limited number of habits. Premium removes the limit. | ✅ benefit text; ❓ the limit (Q13) |
| R5 | Premium unlocks all courses (free users get previews) and all avatars. | ✅ / 🟡 |
| R6 | The intro offer shows a 24-hour countdown. | ✅ shown; ❓ when it starts (Q14) |
| R7 | Reminders are per habit, there can be several, each can be toggled, and they fire only on due days and only when notifications are on for that habit. | 🟡 |
| R8 | "Today" and all date logic use the user's local timezone. | 🟡 |
| R9 | Typed input text is orange and bold, while placeholders are plum at 50 %. (A UI rule recorded here so it isn't lost.) | ✅ |

---

## 5. Recommended backend

> **Recommendation: Firebase + RevenueCat.** Waiting for the owner's decision. Record the answer in [MEMORY.md](MEMORY.md).

| Need | Service | Why |
|---|---|---|
| Auth: email and password, Google, Facebook, Apple, reset email | **Firebase Auth** | Covers screens 06–08 exactly, with reset emails built in |
| Habits and entries working offline | **Cloud Firestore** (offline persistence on) | Habit tracking keeps working without network and syncs later, so no separate local database is needed |
| Courses, community, quotes | Firestore | Read-heavy content plus user-generated posts |
| Course videos | **Firebase Storage** for a start, or a streaming host (Mux / Bunny / Vimeo) for adaptive playback | Lessons are videos (16) |
| Like and comment counters, moderation | **Cloud Functions** | Keeps counts consistent and stops clients writing counts directly |
| Subscriptions | **RevenueCat** (Google Play Billing and StoreKit) | Plans, intro offer, "Restore Purchase", entitlement checks, webhooks |
| Reminders | **flutter_local_notifications** on the device | No server needed |
| Push (community activity) | FCM | Optional, later |

**Alternative:** Supabase (Postgres, Auth and Storage) suits a team that wants SQL for analytics and community queries. Offline habit tracking then needs a local database (for example drift) with a sync layer, which is more work.

### Data layout (Firestore)
```
users/{uid}                         name, email, avatarId, marketingOptIn, timezone, premium{...}, createdAt
users/{uid}/habits/{habitId}        name, icon, color, frequency{type, days[]}, reminders[{time, enabled}],
                                    notificationsEnabled, order, createdAt, archivedAt
users/{uid}/habits/{habitId}/entries/{yyyy-MM-dd}   status, easiness, updatedAt
users/{uid}/bookmarks/{courseId}    createdAt
quotes/{id}                         text, author
avatars/{id}                        imageUrl, isPremium
courses/{id}                        title, coverUrl, durationSec, lessonCount, popularity, tags[], isPremium
courses/{id}/lessons/{id}           order, title, durationSec, videoUrl, isFreePreview
posts/{id}                          authorId, authorName, authorAvatar, text, createdAt, likeCount, commentCount
posts/{id}/likes/{uid}              createdAt
posts/{id}/comments/{id}            authorId, text, createdAt
feedback/{id}                       uid, message, createdAt
```

---

## 6. Open questions for the owner

| # | Question | Screen | My default if there's no answer |
|---|---|---|---|
| Q1 | **Habit cell states:** full = completed, half = ? (missed, or partly done?), empty = ? | 09, 13 | Full = completed, Half = missed, Empty = not marked |
| Q2 | How is the **easiness score** entered? A 1–10 rating when completing? | 13 | Rating 1–10 in a sheet after "Mark as Complete" |
| Q3 | **Total Work Hours** on Profile: what does it measure? | 18 | Drop it, or replace it with "Habits Completed" |
| Q4 | Does the user **pick the habit color**, or is it assigned automatically? | 09, 10 | Auto-rotate through the 4 colors, editable later |
| Q5 | **Habit icon picker**: which icons, and are any premium? | 10 | A fixed set of about 24 icons, all free |
| Q6 | Can habits be **deleted or archived**? Where? | — | Delete from the edit screen, with confirmation |
| Q7 | **Quotes**: our own list or from the server? How many? | 09 | Server collection, one per day |
| Q8 | **Courses**: who creates the content? Which sort options and filters? Where are saved courses listed? | 15 | Admin-managed in Firestore; sort Popular/Newest; filter by topic; saved list in the side menu |
| Q9 | **Lesson locks**: premium-only, or unlocked in sequence? | 16 | Premium-only, lesson 1 free |
| Q10 | **Community**: can every user post? Are posts course reviews? Moderation? | 17 | Signed-in users post text; report button; admin removal |
| Q11 | **"Keep me signed in"** unchecked: what happens? | 07 | Ignore it, since mobile sessions normally persist. Or sign out when the app is killed. |
| Q12 | When does the **Congratulation popup** appear? | 14 | When a streak milestone is reached (7 / 21 / 30 days) |
| Q13 | **Free habit limit**: how many habits? | 20 | 3 habits |
| Q14 | **60 % offer countdown**: starts when? For everyone? | 20 | 24 h from the first time the paywall is shown |
| Q15 | **Side menu (☰)** on Home, Courses, Community and Settings: what's in it? | 09, 15, 17, 19 | Profile, Saved courses, Premium, Sign out |
| Q16 | **Backend choice**: Firebase + RevenueCat (recommended) or something else? | — | Firebase + RevenueCat |
| Q17 | **Platforms**: Android and iOS both? (iOS then needs Sign in with Apple) | — | Both |
