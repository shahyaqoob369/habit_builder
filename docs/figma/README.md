# How to Share the Figma Design

> **Status:** ✅ The design was pulled on **2026-10-18** with option B. That used 2 of the month's Tier 1 calls. All 20 screens are in [index.md](index.md). Pull again only if the Figma file changes.
>
> **Local-only:** `raw/`, `assets/` and `screens/` are gitignored, because the GitHub repo is public and they reproduce the Pixel True kit. On a new machine, rebuild them with `fetch`, `index`, `render`, `fills` and `spec` (2 Tier 1 calls).

Pick **one** way to connect the design. Each way gives Claude exact values (hex colors, font sizes, spacing, text), not just a picture.

## Option A: Figma MCP (best on a paid Figma plan)

Claude reads frames straight from Figma: layout, exact values, screenshots and variables.

1. In a terminal, run **one** of these:
   ```bash
   claude plugin install figma@claude-plugins-official
   # or, manually:
   claude mcp add --transport http figma https://mcp.figma.com/mcp
   ```
2. In Claude Code, run `/mcp`, select **figma**, sign in, and click **Allow Access**.
3. Share frame links one at a time. In Figma, right-click a frame, choose **Copy/Paste as → Copy link to selection**, and paste the link in chat.

⚠️ On the free **Starter** plan, Figma allows only about **6 MCP calls per month**, which is not enough for a whole app. Use option B instead.

## Option B: Figma REST API token (works on the free plan)

Claude runs a script that pulls **every** frame at once: the node data plus PNG renders, saved into `docs/figma/`.

1. In Figma, go to **Settings → Security → Personal access tokens → Generate new token**.
   - Scope: **File content → Read only** (`file_content:read`). Nothing else is needed.
   - Pick the shortest expiry that still covers the project.
2. Put the token in your shell. Don't put it in the repo, and don't paste it in chat.
   ```bash
   echo 'export FIGMA_TOKEN="figd_xxx..."' >> ~/.zshrc && source ~/.zshrc
   ```
3. Give Claude the **file link** (`https://www.figma.com/design/<FILE_KEY>/...`). Claude runs [tool/figma/figma_pull.py](../../tool/figma/figma_pull.py):
   ```bash
   python3 tool/figma/figma_pull.py fetch <file-link>   # whole file → docs/figma/raw/file.json   (Tier 1 call)
   python3 tool/figma/figma_pull.py index               # screen list → docs/figma/index.md      (offline)
   python3 tool/figma/figma_pull.py render              # PNG per screen, one batch              (Tier 1 call)
   python3 tool/figma/figma_pull.py fills               # illustrations/photos → assets/fills/   (Tier 2 call)
   python3 tool/figma/figma_pull.py spec                # spec.txt per screen + tokens.md        (offline)
   ```
   Output: `docs/figma/screens/NN-name/main.png` and `spec.txt` (exact layout, colors, fonts, text), plus `docs/figma/tokens.md`.

⚠️ **API budget:** files on Figma's free Starter plan get only about **6–20 Tier 1 calls per month** (file reads and image renders). The script caches every result in `docs/figma/raw/` and won't call the API again unless given `--force`. **Never delete `docs/figma/raw/`.**

## Option C: Manual export (no setup at all)

For each screen:
1. Select the frame and export it as **PNG at 2×** (the Export section at the bottom of the right panel).
2. Create a folder `docs/figma/screens/NN-screen-name/` (for example `05-home/`). Drop the PNG in it as `main.png`, and add any other states as `empty.png`, `error.png` and so on.
3. Copy [`SCREEN_NOTES_TEMPLATE.md`](SCREEN_NOTES_TEMPLATE.md) into the folder as `notes.md` and fill in what you know.

Exact values are lost with screenshots alone. If you can, also paste the frame's CSS from the Inspect / Dev Mode panel into `notes.md`.

> **About HTML export plugins** (Anima, Locofy, etc.): Claude can read the output, but it's usually hundreds of absolutely-positioned `<div>`s. That helps only as a source of exact values, not structure. Options A or B are better.

---

## What to share, and in what order

1. **Style guide / components page** (if the file has one): colors, text styles, buttons, inputs, icons.
2. **A zoomed-out overview of all screens**: one big export of the whole canvas, or just the file link for A or B. Seeing the full app first lets Claude work out the data model and backend before building.
3. **Screens by flow**, one flow at a time:
   1. Splash → Onboarding → Sign up → Login → Forgot password
   2. Home / today
   3. Create or edit habit
   4. Habit detail / calendar
   5. Progress / statistics
   6. Community
   7. Profile / settings / notifications
   8. Premium / paywall (if any)

For each screen, include **every state the design has**: empty, loading, error, filled, success, dialogs, bottom sheets.

## What Claude needs for the backend logic

Designs show *what* data exists, but not the *rules*. Claude works out entities, fields and actions from the screens. Please also give:

- **Prototype links**, or a simple list such as "tap X → goes to Y".
- **Rules the design can't show**, in plain words. For example:
  - When does a habit count as "done" for a day? What happens to the streak if a day is missed?
  - Can a habit repeat on specific weekdays, or X times a week?
  - Does sign-in need a backend, or is local-only fine for now?
  - Community: who can post? Are there likes or comments? Is there moderation?
  - What is free, and what is premium?

Claude records everything learned in [../BACKEND_SPEC.md](../BACKEND_SPEC.md) and asks about anything unclear.
