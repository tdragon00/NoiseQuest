# Questboard — Software Specification

**Status:** Draft v1.0 — awaiting review
**Codename:** Questboard (placeholder, rename freely)
**Stack:** Flutter / Dart — one codebase → Android, iOS, Linux desktop
**Companion file:** [`openapi.yaml`](./openapi.yaml) — machine-readable API contract + seed data

---

## 0. How to use this document

This spec is written to be read by two audiences:

- **Humans** — product, design, engineering. Read §1–§4, §6 (screens), §11 (theme).
- **AI agents (including Claude)** — implementation. §2 (decisions), §8 (data model), §9 (formulas), §13 (structure), §14 (deps), §21 (acceptance criteria) are normative. If prose and normative sections conflict, **normative wins**.

**Normative keywords:** MUST / MUST NOT / SHOULD / MAY.

**Reading order for an implementer:**

1. §2 Decisions → §9 XP math → §8 data model → §12 API summary
2. §6 screen specs → §11 design tokens
3. §13 structure → §14 dependencies → §21 acceptance criteria
4. Build with the Prism mock (§15), then swap to the real backend by changing one base URL.

---

## 1. Product summary

A task manager reimagined as an adventure game.

Users create **quests**, claim and complete them, earn **XP**, level up, and earn **titles**. The visual language is neon-retro / synthwave. Progress is organised into **guilds** — free-text tags like `Chores`, `Work`, `Errands` — that group quests and produce per-guild XP tallies shown on a banner and in leaderboards.

**Primary targets:** PinePhone (Android port, aarch64), iPhone, Linux desktop.
**Secondary:** web build as a universal fallback (runs on postmarketOS Firefox without an arm64 native build).

### 1.1 Design pillars

| Pillar | Meaning |
|---|---|
| **Game the mundane** | Ordinary chores become quests with XP, levels and titles. Feedback should feel like a reward. |
| **Neon, not gritty** | Synthwave: cyan/magenta on deep indigo, glow, grid lines. Cute and uplifting, never grim. |
| **Works on a $150 phone** | No Play Services. No heavy GPU effects. 2 GB RAM target. |
| **One codebase, many screens** | Phone, tablet, desktop all read from the same widget tree. |

---

## 2. Decisions and rationale

Every decision below was either chosen by the stakeholder or made by the spec author. **Additions made by the spec author are marked ⚠️** and are safe to remove.

### 2.1 Confirmed by stakeholder

| # | Decision | Consequence |
|---|---|---|
| D1 | Endpoint prompt is a **URL field with a pre-filled default** | First screen of the app. Saved locally. Editable later in Settings. The field holds the **origin only** — `http://127.0.0.1:4010` for the local mock, `https://api.questboard.example` for the placeholder backend — and the client appends `/api/v1` (§12.1). |
| D2 | Auth is **email + password** | No magic link, no email verification required for v1. |
| D3 | **Levels and titles are backend-defined**; the client ships defaults and the server overrides | Client can render offline. See §9. |
| D4 | A **guild is a free-text tag** on a quest — not an entity, no membership | Guilds are strings. Sorting/filtering by them is trivial. |
| D5 | **Guild XP is derived**: sum of XP from completed quests carrying that guild tag. It does **not** affect total XP. | No separate guild-XP currency. Level comes from total XP only. |
| D6 | Leaderboards: **global and per-guild** | Leaderboard screen has a scope toggle. |
| D7 | **Phone and desktop from day one** | Adaptive layout, not a stretched phone app. |
| D8 | Navigation is a **"guild board" hub screen** with icons | 3 quest-state tiles + 1 create-quest tile. |
| D9 | Sound: **placeholder tones for now** | Pluggable `SoundService`; real assets later. |
| D10 | **English only for v1**, i18n scaffolded | ARB files + `intl`. Language picker exists in flow. |
| D11 | Account fields: **username and pfp optional**; anonymous display name until set | See §9.3. |
| D12 | Repeatable quests: **reset to available on completion, award XP each time** | Needs an append-only completion log (§8.4). |
| D13 | **Any user can create quests and work any quest concurrently** | Quest state is **per-viewer**, not global. See §2.3. |
| D14 | Sound plays for **my own actions only** | No cross-user notifications in v1. |
| D15 | Settings holds **essentials + data controls**; the **banner editor is its own screen** | Navigation: Settings is a page; Banner Editor is a separate route. |
| D16 | **Offline-first with an outbox queue** | See §12. |
| D17 | **No realtime.** Manual pull-to-refresh and on-open refresh. | REST only. |
| D18 | **Language picker is a launch step**: Endpoint → Language → Signup → Main | §6.2. |
| D19 | **One endpoint** for now, multiple-endpoint switching is a future item | §6.1. |
| D20 | Mock server: **openapi.yaml + Prism** | §15. Spec and mock cannot drift. |
| D21 | Stack: **Flutter — Android + iOS + Linux desktop** | No web in v1 (§2.5). |
| D22 | Quest row shows **icon + name + XP + guild chip** | §11.4. |
| D23 | Search matches **name, description, guild, author, and icon** | Quests therefore need a `description` field (§8.2). |
| D24 | Quest icon is an **emoji picker** | §11.3. |
| D25 | Banner: **preset art**, full custom is a future item | Presets are procedural, not image files. §11.2. |
| D26 | Theme: **neon retro / synthwave** | §11. |
| D27 | Launch order: **Endpoint → Language → Signup → Main** | §6.2. |

### 2.2 Additions by spec author (⚠️ — removable)

| # | Addition | Why |
|---|---|---|
| A1 | ⚠️ **SFX on/off toggle in Settings** | D14 makes sounds frequent; a mute switch is table-stakes. One line to remove. |
| A2 | ⚠️ **Anonymous display name is stored, not regenerated per launch** | Must be stable across devices; regenerating on each launch would be a bug. |
| A3 | ⚠️ **Non-repeatable quest closes globally on first completion** | Resolves the tension between D13 (concurrent work) and a "completed" state. See §2.3. |
| A4 | ⚠️ **Banner art is procedural** (`CustomPainter`), not bundled images | Zero binary assets, scales to any width, trivially extended to custom later (D25). |
| A5 | ⚠️ **Client-generated UUIDs for quests and completions** | Required for D16 (offline queue) — without it, a retried create duplicates the quest. |
| A6 | ⚠️ **Level cap of 50** | Bounds the title table; makes level-UP events finite and predictable. |
| A7 | ⚠️ **No `BackdropFilter`, no large blur, no large-radius shadows** | Mali-400 GLES 3.1 on the PinePhone; blur is the single most expensive effect. §11.6. |
| A8 | ⚠️ **"System default" option in the language picker** | Needed because D10 ships one language; the picker needs a non-empty, meaningful state. |

### 2.3 Resolution of the concurrency question (D13 + A3)

D13 says any user may work a quest concurrently. The three tabs (Available / In Progress / Completed) are therefore **per-viewer**, not global.

**Model:**

- A `Quest` is a global record. It has a lifecycle of `available → in_progress → completed`.
- `in_progress` is global (someone is working it) but **not exclusive** — N users can be working the same quest.
- A user's tab membership comes from their **own** `QuestProgress` row, not from the quest's global status.
- **A3:** when a non-repeatable quest is completed by anyone, it closes globally and disappears from other users' Available list. Repeatable quests immediately reset to `available` (D12) and can be completed again by anyone, including the same user.

**Consequence:** the API returns quests with a per-viewer `my_status` field. See §8.3.

### 2.4 What "guild XP does not affect total XP" means precisely

- `total_xp` = Σ `xp_awarded` over **all** of the user's completions.
- `guild_xp[g]` = Σ `xp_awarded` over the user's completions **where the quest's guild == g**.
- `guild_xp[g]` is therefore always a **subset** of `total_xp`, never additive to it.
- **Level is computed from `total_xp` only.** A guild never grants XP, unlocks, or levels on its own.

### 2.5 Explicitly out of scope for v1

- Web target (D21) — but the Flutter project MUST NOT block a later `flutter build web`.
- Multiple endpoints / profile switching (D19) — endpoint storage is designed to allow it (§12.1).
- Custom banner upload (D25) — presets only.
- Guild entities, membership, roles, permissions (D4) — guilds are strings.
- Push notifications, email verification, password reset (D2, D14).
- Realtime / websockets (D17).
- Avatar image upload — v1 uses an emoji glyph or a preset sigil (§8.1).

---

## 3. Personas and user stories

### 3.1 Personas

| Persona | Context | Device | What they need |
|---|---|---|---|
| **Riley — the doer** | Field worker, phone in one hand, spotty signal | PinePhone / iPhone | Claim a quest, mark done offline, see XP go up |
| **Morgan — the dispatcher** | At a desk, juggling a team | Linux desktop | See all guilds, create quests in bulk, watch the board |
| **Sam — the grinder** | Loves the numbers | Any | Leaderboards, titles, per-guild XP tallies |

### 3.2 User stories

**Onboarding**
- US-01 As a new user, I can point the app at my server by typing or editing a URL, so my data lands where my team keeps it.
- US-02 As a new user, I can pick my language before signing up.
- US-03 As a new user, I can create an account with just an email and password, and land straight on the main screen.
- US-04 As a new user without a username, I get a themed anonymous display name instead of a blank, and can change it later.

**The board**
- US-05 As a user, I see a hub of four large icons — Available, In Progress, Completed, and Create — each with a live count.
- US-06 As a user, I can open any of the three quest lists and see my quests as rows.
- US-07 As a user, I can search the quests in a list by name, description, guild, author, or icon.
- US-08 As a user, I can sort quests by guild, by date, by XP, or by name.
- US-09 As a user, I can filter a list to a single guild.
- US-10 As a user, I can create a quest with a name, description, icon, guild, XP reward, and repeatability.
- US-11 As a user, I can start a quest, mark it complete, and see XP and level update.
- US-12 As a user, I can see who authored and who completed a quest, and when.

**Progress**
- US-13 As a user, I see my username, avatar, level, and title in a banner at the top of the main screen.
- US-14 As a user, I can edit that banner — currently choosing from preset art.
- US-15 As a user, I can see my total XP and my XP within each guild.
- US-16 As a user, I can see a global leaderboard and a per-guild leaderboard, each row showing the same banner.
- US-17 As a user, I get a satisfying sound and a level-up moment when I complete a quest.

**Settings**
- US-18 As a user, I can change my endpoint, username, avatar, language, and sound preference in Settings.
- US-19 As a user, I can clear cached data, force a full re-sync, export my data, and delete my account.

**Offline**
- US-20 As a user on a bad connection, I can still see my last-known quests and complete them, and they sync later.

---

## 4. Architecture overview

```
┌──────────────────────────────────────────────────────────────┐
│                        Flutter app                           │
│                                                              │
│  presentation/    screens, widgets, theme, l10n              │
│  state/           Riverpod providers (per-screen)           │
│  domain/          models (User, Quest, Progress, Completion) │
│  data/                                                         │
│    ├── remote/    api client (Dio) ←──────────┐              │
│    ├── local/     drift (SQLite) cache        │              │
│    ├── outbox/    queued mutations            │              │
│    └── repository/ single source of truth     │              │
│  services/        sound, settings, haptics, connectivity     │
└──────────────────────────────────────────────────────────────┘
                          │
                    ┌─────▼─────┐
                    │  backend  │  REST/JSON, OpenAPI 3.1
                    └───────────┘
```

**Key rule:** UI never talks to Dio or SQLite directly. It talks to `QuestRepository` / `UserRepository`, which merge local cache + outbox. This keeps D16 (offline-first) from leaking into widgets.

**State management:** Riverpod (v2). Chosen over Bloc for less boilerplate at this scale, and for `AsyncValue` ergonomics.

**Layered offline model:**

| Layer | Holds | Written by |
|---|---|---|
| `QuestCompletion` (append-only log) | every completion event, `xp_awarded` | Server (source of truth for XP) |
| `QuestProgress` | current per-user state of a quest | Server, mirrored locally |
| `Quest` | global quest record | Server, mirrored locally |
| `outbox` | pending local mutations | Client |

---

## 5. Functional requirements

Numbered for tracking. `FR-` prefix.

### 5.1 Connection
- FR-01 The app MUST open on a **Connect** screen (first run) containing a URL field, pre-filled with the default endpoint, and a Continue action.
- FR-02 The app MUST validate the URL (scheme, host, reachability) and MUST show an inline error on failure, preserving the user's typed value.
- FR-03 The app MUST persist the chosen endpoint locally and MUST NOT re-prompt on subsequent launches.
- FR-04 The endpoint MUST be editable in Settings; changing it MUST clear the local cache and outbox and MUST require re-authentication.
- FR-05 The app MUST show the current endpoint in Settings with a health-check action.

### 5.2 Onboarding
- FR-06 After a successful connection, the app MUST present a language selection step.
- FR-07 The app MUST then present account creation (email + password, optional username, optional avatar).
- FR-08 Account creation MUST succeed with email + password alone; username and avatar MUST be optional.
- FR-09 On success the app MUST navigate **directly** to the main screen with no intermediate profile wizard.
- FR-10 The app MUST generate and persist an anonymous themed display name when no username is set (§9.3).
- FR-11 The app MUST support returning-user login from the same screen.

### 5.3 Main screen (Guild Board)
- FR-12 The main screen MUST display a **banner** at the top containing avatar, display name, level, and title.
- FR-13 The main screen MUST display a **Guild Board** hub with four icon targets: Available, In Progress, Completed, Create Quest.
- FR-14 Each of the three quest-state targets MUST display a live count badge.
- FR-15 The main screen MUST be reachable from the banner, which opens the **Banner Editor** (§6.7).

### 5.4 Quest lists
- FR-16 Each of the three quest lists MUST render quests as **rows** showing icon, name, XP reward, and a guild chip.
- FR-17 Each list MUST provide a **search** field matching name, description, guild, author, and icon (D23).
- FR-18 Each list MUST provide a **sort** control with at least: Guild, Newest, Recently completed, XP reward, Name.
- FR-19 Each list MUST provide a **guild filter** (chip row of guilds present in the current result set, plus "All").
- FR-20 Each list MUST be refreshable by pull-to-refresh on phone and by an explicit refresh action on desktop.
- FR-21 Each list MUST show an explicit empty state distinct from "loading" and "error".
- FR-22 Quest state is **per-viewer** (§2.3): the same quest may be Available for one user and In Progress for another.

### 5.5 Quest actions
- FR-23 Any authenticated user MUST be able to create a quest (D13).
- FR-24 Creating a quest MUST require `name` and `xp_reward`; `description`, `icon`, and `guild` are optional.
- FR-25 A user MUST be able to start (claim) a quest they have not started.
- FR-26 A user MUST be able to complete a quest they have started.
- FR-27 Completing a quest MUST award `xp_reward` to the completer, update `total_xp`, and may trigger a level-up (§9).
- FR-28 Completing a **repeatable** quest MUST reset it to available and record another completion (D12).
- FR-29 Completing a **non-repeatable** quest MUST close it for all users (A3).
- FR-30 The author MUST be able to edit or delete their own quest. Others MUST NOT.
- FR-31 A user MUST be able to cancel a quest they started, returning it to their Available list.

### 5.6 Quest detail
- FR-32 The quest detail view MUST show: icon, name, description, XP reward, guild, author, creation date, completion date, completed by, and repeatable flag.
- FR-33 The detail view MUST offer the state-appropriate actions: Start / Complete / Cancel / Edit / Delete.
- FR-34 Destructive actions MUST require confirmation.

### 5.7 Banner, level, guild XP
- FR-35 The banner MUST show avatar, display name, level, and title.
- FR-36 The Banner Editor MUST let the user choose from **preset banner art** (D25) and MUST reflect the choice immediately.
- FR-37 The banner MUST be reusable in leaderboard rows, rendering at a reduced size with identical structure.
- FR-38 The app MUST display total XP and per-guild XP for the current user.
- FR-39 Per-guild XP MUST be derived (§2.4) and MUST NOT influence level.

### 5.8 Leaderboards
- FR-40 A leaderboard screen MUST offer **global** and **per-guild** scopes (D6).
- FR-41 Each leaderboard row MUST show the user's banner, display name, level, title, and XP.
- FR-42 The current user MUST be visually highlighted in the leaderboard.

### 5.9 Settings
- FR-43 Settings MUST contain: endpoint (with health check), account (email, username, avatar, change password), language, sound toggle (A1), and data controls.
- FR-44 Data controls MUST include: clear cache, force full sync, export my data, and delete account.
- FR-45 Deleting an account MUST require typed confirmation.
- FR-46 The Banner Editor MUST NOT live inside Settings (D15) — it is its own route reachable from the banner.

### 5.10 Offline & sync
- FR-47 The app MUST render the last-known local state immediately on launch, before any network call completes.
- FR-48 Creating or completing a quest while offline MUST be queued locally and applied when connectivity returns.
- FR-49 The app MUST surface sync state visibly (a sync indicator showing pending / syncing / error).
- FR-50 Queued mutations MUST be idempotent on the server (A5).

### 5.11 Sound
- FR-51 The app MUST play a sound on the user's own: create quest, start quest, complete quest, and level-up (D14).
- FR-52 The app MUST NOT play sounds for other users' activity.
- FR-53 Sound MUST be suppressible by the Settings toggle (A1).
- FR-54 Sound MUST never block or delay a UI action.

### 5.12 Localization
- FR-55 All user-facing strings MUST come from ARB files; no hard-coded strings in widgets.
- FR-56 The app MUST ship English for v1 with the localization plumbing proven by at least one additional locale stub (D10).
- FR-57 The language picker MUST offer "System default" plus the built locales (A8).

---

## 6. Screen inventory

### 6.1 Routing map

```
/connect                     Connect (first run only)          D1
/language                    Language picker (first run only)  D10
/auth                        Create account / Sign in          D2
/                            Main — Guild Board hub + banner    §6.3
/quests/available            Quest list — Available            §6.4
/quests/in_progress          Quest list — In Progress          §6.4
/quests/completed            Quest list — Completed            §6.4
/quest/new                   Create quest                      §6.5
/quest/:id                   Quest detail                      §6.6
/banner                      Banner Editor                     §6.7
/leaderboard                 Leaderboards (global | guild)     §6.8
/settings                    Settings                          §6.9
/settings/data               Data controls (sub-page)          §6.9
```

Auth guard: all routes except `/connect` and `/language` require a session. Unauthenticated access redirects to `/auth`.

### 6.2 Onboarding sequence

**Screen 1 — Connect**

```
┌────────────────────────────────┐
│                                │
│         ⚡ QUESTBOARD          │
│                                │
│  Server endpoint               │
│ ┌────────────────────────────┐ │
│ │ https://api.example.com    │ │
│ └────────────────────────────┘ │
│  [ Testing connection… ]      │
│                                │
│  ┌──────────────────────────┐ │
│  │       Continue →         │ │
│  └──────────────────────────┘ │
└────────────────────────────────┘
```

- URL field, pre-filled with the default endpoint (D1).
- Live validation on blur; explicit "Test connection" is implicit in Continue.
- Errors render inline beneath the field, e.g. `Couldn't reach this server. Check the URL and try again.`
- Continue is disabled while validating.

**Screen 2 — Language**

- A list of built locales plus "System default" (A8). Large tappable rows, current selection highlighted with a neon check.
- A "Continue" affordance. Selecting a language and tapping Continue advances.

**Screen 3 — Create account / Sign in**

- Segmented toggle: **Create account** / **Sign in**.
- Create account fields: email, password, confirm password, username *(optional)*, avatar *(optional — emoji picker, 24-cell grid, 2 rows visible + scroll)*.
- Sign in fields: email, password.
- Primary button label reflects the mode: `Create account` / `Sign in`.
- On success → **Main** (FR-09). No wizard.

### 6.3 Main — Guild Board

```
┌────────────────────────────────────────┐
│ ╔════════════════════════════════════╗ │
│ ║ [avatar]  Riley_42        LVL 7    ║ │  ← banner (tappable → Banner Editor)
│ ║       Pulse Weaver      ▰▰▰▰▱ 2475/2800 XP ║ │
│ ╚════════════════════════════════════╝ │
│                                        │
│   GUILD BOARD                          │
│                                        │
│   ┌────────────┐   ┌────────────┐      │
│   │   ⚔️       │   │   🔥       │      │
│   │  AVAILABLE │   │ IN PROGRESS│      │
│   │     (12)   │   │    (3)     │      │
│   └────────────┘   └────────────┘      │
│   ┌────────────┐   ┌────────────┐      │
│   │   ✅       │   │   ➕       │      │
│   │ COMPLETED  │   │   CREATE   │      │
│   │     (28)    │   │   QUEST    │      │
│   └────────────┘   └────────────┘      │
│                                        │
│  Total XP 1,240   🏠 Chores 380  💼 Work 860 │
└────────────────────────────────────────┘
```

- **Banner** — top, full width, rounded, neon border. Contains avatar, display name, level badge, title, and an XP progress bar. Tapping opens the Banner Editor (FR-15).
- **Guild Board** — 2×2 grid of large tiles on phone; 4-across row on desktop. Each tile: emoji glyph, label, count badge.
- **XP footer strip** — total XP plus a chip per guild with that guild's XP. Guild chips are tappable and jump to the matching guild filter in the relevant list.

**Desktop variant:** left `NavigationRail` (the same four targets), banner spans the top of the content area, quest lists become tables.

### 6.4 Quest lists

Shared structure across Available / In Progress / Completed.

**Phone (list)**
```
┌────────────────────────────────────────┐
│  ← Available                    12     │
│  ┌────────────────────────────┐        │
│  │ 🔍 Search quests…           │        │
│  └────────────────────────────┘        │
│  Sort: Guild ▾   [All][Chores][Work]   │
│  ┌────────────────────────────────────┐ │
│  │ 🧹  Clean the kitchen       50 XP  │ │
│  │     Chores · by Riley_42           │ │
│  └────────────────────────────────────┘ │
│  ┌────────────────────────────────────┐ │
│  │ 📄  File the quarterly report 200 XP│ │
│  │     Work · by Morgan_88            │ │
│  └────────────────────────────────────┘ │
└────────────────────────────────────────┘
```

**Row anatomy** (D22): `icon` (emoji, 28–32px) · `name` (title, 1 line, ellipsis) · `xp_reward` (right-aligned, monospace, cyan) · `guild chip` (small pill) · `author` (secondary line, 12px).

**Desktop (table)** — columns: checkbox-free, Icon, Name, Guild, XP, Author, Created, Status. Sortable headers mirror the sort control.

**States:** loading (skeleton rows), empty (illustration + "No quests here yet" + CTA to create), error (message + Retry), offline (banner strip "Offline — showing cached data").

**Completed list** additionally shows the completion date in place of the creation date, and a `completed_by` chip.

### 6.5 Create quest

Fields, in order:
1. **Name** (required, 1–80 chars)
2. **Description** (optional, 0–500 chars)
3. **Icon** (optional — emoji picker; 8×3 grid of curated adventure emoji + a "clear" option)
4. **Guild** (optional — free text with **autocomplete from existing guild names already present in the user's data**; D4 says guilds are strings, but suggesting existing ones is pure convenience and does not create guild entities)
5. **XP reward** (required, integer 1–10000, with quick-pick chips: 10 / 25 / 50 / 100 / 250)
6. **Repeatable** (switch, default off) — helper text: *"Repeatable quests reset to Available when completed and can be earned again."*

Primary button `Create quest`. Disabled until name + XP are valid.

**Offline:** the create is queued and the new quest appears immediately in the user's list with a `Pending sync` marker.

### 6.6 Quest detail

Full-screen on phone, centred dialog/panel on desktop.

Sections: hero (large icon + name + guild chip + XP badge), description, metadata grid (Author, Created, Completed, Completed by, Repeatable), and a sticky action bar whose buttons depend on state:

| User's relationship to the quest | Available | In Progress | Completed (non-repeatable) |
|---|---|---|---|
| Author | `Start` `Edit` `Delete` | `Mark complete` `Cancel` `Edit` | `—` |
| Other user | `Start` | `Mark complete` `Cancel` | `—` |

Destructive actions (Delete) require a confirmation dialog (FR-34).

### 6.7 Banner Editor

Its own route, NOT inside Settings (D15, FR-46).

- **Preview** at the top — a live, full-width render of the banner exactly as it will appear in the main screen and in leaderboard rows.
- **Art presets** — a grid of preset tiles. Each preset renders procedurally (§11.2).
- **Avatar** — a horizontal strip of emoji glyphs; the currently selected one is highlighted. This is the profile picture, shared between the banner and the account.
- **Save** / **Cancel**. Changes apply to the preview immediately and persist on Save.

**Future (D25):** custom image upload, custom gradient stops, custom pattern, custom title text.

### 6.8 Leaderboards

- Header: scope toggle — **Global** | **Guild**, with a guild picker appearing when the Guild scope is selected.
- Rows: a **compact banner** (avatar + name + level badge + title) + XP on the right. The current user's row is highlighted with a neon border and a `YOU` tag.
- Rank numbers 1–3 get a distinct treatment (gold/silver/bronze accent, per the theme palette).
- A "My guilds" summary card above the list shows the current user's total XP and per-guild XP.

### 6.9 Settings

Grouped list, each row navigates to a sub-page or toggles inline.

**Connection**
- `Server endpoint` → shows the current URL, `Test connection` action, `Change endpoint` (clears cache + requires re-auth).

**Account**
- `Username` (shows the anonymous name if unset, with a hint)
- `Profile picture` (emoji picker)
- `Email` (read-only, shows the signed-in address)
- `Change password`

**Preferences**
- `Language` → the same picker as the onboarding step
- `Sound effects` → toggle (A1)

**Data**
- `Clear cached data`
- `Force full re-sync`
- `Export my data` → downloads a JSON file (quests, completions, XP, profile)
- `Delete account` → typed-confirmation flow, then returns to `/connect`

**About**
- App version, build number, and the OpenAPI spec version the client was built against.

---

## 7. Non-functional requirements

| ID | Requirement |
|---|---|
| NFR-01 | Cold start to interactive UI < 2.5 s on PinePhone (A53). |
| NFR-02 | List scroll maintains ≥ 30 fps on PinePhone; ≥ 60 fps on desktop. |
| NFR-03 | Idle memory < 150 MB; peak < 300 MB on a 2 GB device. |
| NFR-04 | APK < 25 MB (arm64 + armv7). |
| NFR-05 | Zero network calls required to render the main screen from cache. |
| NFR-06 | **No Google Play Services dependency**, directly or transitively. |
| NFR-07 | No runtime font/image fetching — all assets bundled. |
| NFR-08 | `flutter analyze` reports zero issues; `flutter test` green; CI blocks on failure. |
| NFR-09 | No crashes when the server returns malformed JSON — degrade to the cached/empty state with an error message. |
| NFR-10 | All user-facing strings localized (§5.12). |
| NFR-11 | Secrets (passwords, tokens) stored in platform secure storage: `flutter_secure_storage` (Keystore / Keychain / libsecret). |
| NFR-12 | Tokens never written to logs. |

---

## 8. Data model

### 8.1 User

| Field | Type | Req. | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes | Server-assigned. |
| `email` | string | yes | Unique, lowercased. |
| `username` | string \| null | no | `null` ⇒ use `display_name`. |
| `display_name` | string | yes | Anonymous themed name when `username` is null (A2). |
| `avatar` | string \| null | no | Emoji glyph or preset sigil id. `null` ⇒ default sigil. |
| `banner_preset_id` | string | yes | One of the preset ids (§11.2). Default `"neon_grid"`. |
| `total_xp` | int | yes | Σ `xp_awarded` over the user's completions. Maintained server-side. |
| `created_at` | string (ISO 8601 UTC) | yes | |
| `updated_at` | string (ISO 8601 UTC) | yes | |

> `password_hash` exists server-side only and MUST NOT appear in any API response.

**Level and title are NOT stored on the user.** They are derived from `total_xp` via the level table (§9). The server MAY return an override table (§9.4).

### 8.2 Quest

| Field | Type | Req. | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes | **Client-generated** for offline creates (A5). |
| `name` | string | yes | 1–80 chars. |
| `description` | string \| null | no | ≤ 500 chars. Needed for search (D23). |
| `icon` | string \| null | no | Emoji glyph. |
| `guild` | string \| null | no | Free-text tag (D4). Case-insensitive for grouping. |
| `xp_reward` | int | yes | 1–10000. |
| `is_repeatable` | bool | yes | Default `false`. |
| `author_id` | string | yes | Reference to a `User`. |
| `author_name` | string | yes | Denormalized for display and search. |
| `status` | enum | yes | `available` \| `in_progress` \| `completed`. |
| `created_at` | string (ISO 8601 UTC) | yes | |
| `updated_at` | string (ISO 8601 UTC) | yes | |
| `completed_at` | string \| null | no | Null unless the quest is closed (non-repeatable) or on the most recent completion (repeatable). |
| `completed_by_id` | string \| null | no | |
| `completed_by_name` | string \| null | no | Denormalized for display. |
| `completion_count` | int | yes | Total completions across all users. |

**Per-viewer fields** (added to the quest when returned to a specific user):

| Field | Type | Notes |
|---|---|---|
| `my_status` | enum | `available` \| `in_progress` \| `completed` — **this user's** state (FR-22). |
| `my_progress_id` | string \| null | Present when `my_status` is not `available`. |
| `my_completion_count` | int | How many times **this user** completed it. |

### 8.3 QuestProgress

One row per (user, quest). Represents the user's current relationship with a quest.

| Field | Type | Req. | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes | |
| `quest_id` | string | yes | |
| `user_id` | string | yes | |
| `status` | enum | yes | `in_progress` \| `completed`. |
| `started_at` | string (ISO 8601 UTC) | yes | |
| `updated_at` | string (ISO 8601 UTC) | yes | |
| `completed_at` | string \| null | no | Latest completion by this user. |

### 8.4 QuestCompletion (append-only log)

The XP source of truth. **Never mutated, never deleted.** One row per completion event.

| Field | Type | Req. | Notes |
|---|---|---|---|
| `id` | string (uuid) | yes | **Client-generated** for offline completes (A5). Idempotency key (FR-50). |
| `quest_id` | string | yes | |
| `user_id` | string | yes | |
| `guild` | string \| null | no | Denormalized from the quest at completion time, so historical guild XP survives a guild rename. |
| `xp_awarded` | int | yes | Equals the quest's `xp_reward` at completion time. |
| `completed_at` | string (ISO 8601 UTC) | yes | |

### 8.5 Guild

Not an entity. A derived grouping.

| Concept | Definition |
|---|---|
| Guild name | The `guild` string on a quest, trimmed, lowercased for grouping, original case for display. |
| Guild list | Distinct non-null guild names across the user's quests, ordered alphabetically. |
| `guild_xp[g]` | Σ `xp_awarded` over the user's `QuestCompletion`s where `guild == g` (§2.4). |
| `total_xp` | Σ `xp_awarded` over **all** of the user's `QuestCompletion`s. |

### 8.6 Local cache schema (drift / SQLite)

| Table | Purpose | Key columns |
|---|---|---|
| `users` | Cached profiles (self + leaderboard rows) | `id` PK, `email`, `username`, `display_name`, `avatar`, `banner_preset_id`, `total_xp`, `updated_at` |
| `quests` | Cached quest records | `id` PK, all §8.2 fields, `my_status`, `my_progress_id`, `my_completion_count` |
| `progress` | Cached per-user progress | `id` PK, `quest_id`, `status`, `started_at`, `updated_at` |
| `completions` | Cached completion log | `id` PK, `quest_id`, `guild`, `xp_awarded`, `completed_at` |
| `outbox` | Pending mutations | `id` PK (uuid), `op` (`create_quest`\|`start_quest`\|`complete_quest`\|`cancel_quest`\|`update_quest`\|`delete_quest`), `payload` (JSON), `client_id` (uuid), `created_at`, `attempts`, `last_error` |
| `meta` | Key/value | `key` PK, `value` — holds `endpoint`, `access_token`, `refresh_token`, `last_sync_at`, `server_level_config` |

> Tokens live in `flutter_secure_storage`, not in the `meta` table.

### 8.7 Entity relationship

```
User 1 ────< Quest            (author_id)
User 1 ────< QuestProgress   (user_id)
User 1 ────< QuestCompletion (user_id)
Quest 1 ───< QuestProgress
Quest 1 ───< QuestCompletion
```

---

## 9. XP, levels, and titles

### 9.1 Total XP

```
total_xp = Σ xp_awarded  over all QuestCompletion rows for the user
```

### 9.2 Level curve (client default)

**Cumulative XP required to reach level L:**

```
cumXP(L) = 50 × (L − 1) × L
```

| L | cumXP | L | cumXP | L | cumXP | L | cumXP | L | cumXP |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 11 | 5,500 | 21 | 21,000 | 31 | 46,500 | 41 | 82,000 |
| 2 | 100 | 12 | 6,600 | 22 | 23,100 | 32 | 49,600 | 42 | 86,100 |
| 3 | 300 | 13 | 7,800 | 23 | 25,300 | 33 | 52,800 | 43 | 90,300 |
| 4 | 600 | 14 | 9,100 | 24 | 27,600 | 34 | 56,100 | 44 | 94,600 |
| 5 | 1,000 | 15 | 10,500 | 25 | 30,000 | 35 | 59,500 | 45 | 99,000 |
| 6 | 1,500 | 16 | 12,000 | 26 | 32,500 | 36 | 63,000 | 46 | 103,500 |
| 7 | 2,100 | 17 | 13,600 | 27 | 35,100 | 37 | 66,600 | 47 | 108,100 |
| 8 | 2,800 | 18 | 15,300 | 28 | 37,800 | 38 | 70,300 | 48 | 112,800 |
| 9 | 3,600 | 19 | 17,100 | 29 | 40,600 | 39 | 74,100 | 49 | 117,600 |
| 10 | 4,500 | 20 | 19,000 | 30 | 43,500 | 40 | 78,000 | 50 | 122,500 |

**Level cap: 50** (A6). At cap, the XP bar shows a full bar and a `MAX` badge.

**Level-up detection:** on any XP change, if `cumXP(new_level) ≤ total_xp` and `new_level > previous_level`, emit a level-up event (sound + banner animation).

### 9.3 Titles

| L | Title | L | Title | L | Title | L | Title |
|---|---|---|---|---|---|---|---|
| 1 | Signal Wanderer | 9 | Neon Monk | 17 | Twilight Vigil | 25 | Synthetica Sage |
| 2 | Neon Novice | 10 | Signal Hunter | 18 | Starlight Seeker | 26 | Obsidian Vanguard |
| 3 | Grid Scout | 11 | Arcade Ranger | 19 | Grid Sovereign | 27 | Starlit Archmage |
| 4 | Chrome Adept | 12 | Cyber Knight | 20 | Neon Paladin | 28 | Circuit Overlord |
| 5 | Voltage Runner | 13 | Plasma Warden | 21 | Arcade Ascendant | 29 | Grid Deity |
| 6 | Alley Hacker | 14 | Chrome Lancer | 22 | Chrome Hierophant | 30 | Legend of the Neon Spire |
| 7 | Pulse Weaver | 15 | Neon Arcanist | 23 | Pulse Sovereign | 31–40 | `Ascendant I` … `Ascendant X` |
| 8 | Data Drifter | 16 | Quantum Ranger | 24 | Voltage Champion | 41–50 | `Sovereign I` … `Sovereign X` |

**Roman numerals for 31–50:** `I II III IV V VI VII VIII IX X`.

**Anonymous display name** (A2, D11): a themed name chosen from the pools below at account creation, stored on the server, and stable forever. Format: `<Adjective> <Noun>` + optional numeric suffix for uniqueness (e.g. `Silent Runner`, `Neon Runner 42`).

- Adjectives: `Silent`, `Neon`, `Crimson`, `Quiet`, `Lucky`, `Wild`, `Cosmic`, `Digital`, `Feral`, `Midnight`
- Nouns: `Runner`, `Ranger`, `Drifter`, `Walker`, `Seeker`, `Nomad`, `Strider`, `Blade`, `Pioneer`, `Wanderer`

### 9.4 Server override

The client MUST ship the §9.2 curve and §9.3 titles as defaults. The server MAY override them via `GET /meta/levels`:

```json
{
  "version": "2026-10-01",
  "levels": [
    { "level": 1, "min_xp": 0,    "title": "Signal Wanderer" },
    { "level": 2, "min_xp": 100,  "title": "Neon Novice" }
  ]
}
```

- If the response is absent, a 404, or malformed, the client MUST silently use its built-in defaults (FR-09, NFR-09).
- The override is cached locally with a `version` string; a changed version triggers a re-fetch.
- The client computes `level` and `title` from `total_xp` and the (possibly overridden) table. The server MAY also return `level`/`title` on the user object, in which case the client's computed value MUST win if they disagree — the client is the single source of truth for display (D3: *"client has default levels and titles, server overwrites them"*).

---

## 10. Guild XP rules (normative)

1. `guild_xp[g] = Σ xp_awarded` over the user's `QuestCompletion` rows where `guild == g`. (D5)
2. `total_xp = Σ xp_awarded` over **all** the user's `QuestCompletion` rows.
3. `guild_xp[g] ≤ total_xp` for every `g`. Guild XP is a **subset**, never additive. (D5, §2.4)
4. **Level is a function of `total_xp` only.** Guild XP never affects level, title, or any unlock. (FR-39)
5. `guild` is captured onto the `QuestCompletion` row at completion time, so renaming a quest's guild does not rewrite history.
6. A completion whose quest had no guild contributes to `total_xp` only.
7. Guild names are compared case-insensitively and trimmed. `"Chores"` and `"chores "` are the same guild.
8. A guild with zero completions in the current window is omitted from the guild XP strip but still appears in the guild filter list if it has quests.

---

## 11. Design system — neon retro / synthwave

### 11.1 Palette

| Token | Hex | Use |
|---|---|---|
| `bg` | `#0A0714` | App background — near-black indigo |
| `bgGradient` | `#0A0714` → `#171034` | Subtle vertical gradient behind everything |
| `surface` | `#16112C` | Cards, panels, list rows |
| `surfaceRaised` | `#1F1840` | Elevated elements, dialogs, sheets |
| `outline` | `#2E2560` | Default borders |
| `primary` | `#00E5FF` | Cyan — primary actions, XP, focus, selected |
| `secondary` | `#FF2FB9` | Magenta — accents, "create" action, glows |
| `tertiary` | `#7C4DFF` | Purple — gradients, secondary glow |
| `success` | `#00FFA3` | Completed state |
| `warning` | `#FFB300` | In-progress state, pending-sync marker |
| `danger` | `#FF3D71` | Delete, destructive |
| `textPrimary` | `#F2F0FF` | Body text |
| `textSecondary` | `#A79FC4` | Metadata, captions |
| `gold` | `#FFD166` | Rank 1, legendary titles |

### 11.2 Typography

| Role | Family | Notes |
|---|---|---|
| Display / titles | `Orbitron` | Geometric, wide. Used for the app name, level numbers, screen titles, titles/rankings. |
| Body / UI | `Rajdhani` | Condensed humanist. Used for labels, quest names, buttons. |
| Numeric / XP | `Share Tech Mono` | Monospace, so XP values align in columns. |

All three **MUST be bundled as assets** — no runtime font fetching (NFR-07). Ship a `.ttf` per weight actually used; drop the rest.

### 11.3 Quest icons

A **curated set of ~120 emoji**, adventure-flavoured, bundled as a Dart constant list (not the OS emoji picker — consistency across platforms matters more than coverage):

- Combat: ⚔️ 🛡️ 🏹 🪓 🗡️ 🐉 🦅 🐺 🕷️ 👹
- Travel/exploration: 🗺️ 🧭 🏕️ 🌋 🏰 🌲 🏜️ 🌊 🚪 🌀
- Tasks: 🧹 🗑️ 🧺 🧽 🍽️ 🛏️ 🧺 📦 🧰 🔧 🏗️ 📚 ✍️ 🧪
- Abstract: 🔥 💎 ⭐ 🌟 ✨ ⚡ 🎯 🏆 🥇 🎁 🧩 🎲 🗝️ 💰 ⏳ 🌙

Users may also enter a single arbitrary Unicode character. The picker is a scrollable grid, 8 columns on phone, 12+ on desktop.

### 11.4 Banner art presets (D25, A4)

Presets are **procedural** — rendered by a `CustomPainter` from a descriptor. No image files, infinite resolution, trivial to extend.

| Preset id | Description |
|---|---|
| `neon_grid` | Perspective grid receding to a horizon glow. Default. |
| `synthwave_sunset` | Magenta-to-orange gradient with horizontal scanlines and a sun disc. |
| `matrix_rain` | Dark green-black with falling glyph columns. |
| `chrome_canyon` | Angular chrome bands over a violet gradient. |
| `vapor_horizon` | Teal/pink haze with soft horizontal light bands. |
| `pulse_wave` | Concentric cyan rings radiating from the left edge. |
| `retro_orbit` | Dark field with a tilted ringed planet and star specks. |
| `midnight_pulse` | Deep indigo with a slow diagonal cyan sweep. |

Each preset also carries a `accent` colour used for the banner border and glow, so the banner reads as a distinct object rather than a rectangle.

### 11.5 Shape, elevation, glow

- Corner radius: **12** for cards and rows, **16** for the banner, **8** for chips, fully rounded for pills.
- Borders: **1 px** in `outline`, or **1.5 px** in the accent colour for the banner and active tiles.
- Glow: achieved with a **1 px neon border + a low-alpha solid shadow** (e.g. `primary` at 18% spread, 8 px blur). **No large blur radii** (A7).
- Grid/scanline overlays: rendered as a `CustomPainter` behind the banner at ≤ 6% opacity.

### 11.6 Performance guardrails for weak GPUs (A7)

The PinePhone's Mali-400 provides GLES 3.1 under Lima/ANGLE-equivalent paths. Therefore:

- **MUST NOT** use `BackdropFilter` or `ImageFilter.blur` anywhere.
- **MUST NOT** use shadow blur radii > 12 px.
- **MUST NOT** use large `RadialGradient` fills over full-screen areas.
- **SHOULD** prefer `CustomPainter` for decorative overlays over image assets.
- Text shadows, if used at all, MUST be `blurRadius ≤ 4`.

### 11.7 Adaptive layout breakpoints

| Breakpoint | Width | Layout |
|---|---|---|
| Compact | < 600 dp | Bottom-aligned single column, 2×2 tile grid, cards for quests. |
| Medium | 600–1023 dp | Two-pane for list+detail, 4-across tiles. |
| Expanded | ≥ 1024 dp | `NavigationRail` + content, quest lists as data tables, banner spans content width, master-detail for quest detail. |

---

## 12. API contract

**Full machine-readable contract: [`openapi.yaml`](./openapi.yaml)** — this section is the human summary; the YAML is normative.

### 12.1 Base and conventions

- Base path: `/api/v1` — **included in the paths inside `openapi.yaml`**, so the
  Connect screen's endpoint field holds only the origin (`scheme://host[:port]`) and the
  client appends `/api/v1` itself. Local mock: `http://127.0.0.1:4010`.
- Content type: `application/json`
- Auth: `Authorization: Bearer <access_token>`
- Timestamps: ISO 8601 UTC, e.g. `2026-10-22T14:03:11Z`
- IDs: lowercase UUID v4
- Errors: RFC 7807-ish envelope — `{"error": {"code": "VALIDATION", "message": "…", "field": "name"}}`
- `GET` list endpoints: `limit` (default 50, max 200) + `cursor` pagination; response `{ "items": [...], "next_cursor": "..." | null }`
- Idempotency: `POST /quests` and `POST /quests/{id}/complete` accept a client-generated `id`; a repeat `POST` with the same `id` returns the existing record with `200` instead of creating a duplicate (A5, FR-50).

### 12.2 Endpoints

| Method | Path | Purpose | Auth |
|---|---|---|---|
| `GET` | `/health` | Liveness + server version. Used by the Connect screen. | No |
| `POST` | `/auth/register` | Create account → tokens + user. | No |
| `POST` | `/auth/login` | Exchange credentials → tokens. | No |
| `POST` | `/auth/refresh` | Rotate the access token. | Refresh token |
| `GET` | `/auth/me` | Current user profile. | Yes |
| `PATCH` | `/users/me` | Update username, avatar, banner preset. | Yes |
| `POST` | `/users/me/password` | Change password. | Yes |
| `DELETE` | `/users/me` | Delete account. | Yes |
| `GET` | `/quests` | List quests, filtered to the caller's view. | Yes |
| `POST` | `/quests` | Create a quest. | Yes |
| `GET` | `/quests/{id}` | Quest detail incl. per-viewer state. | Yes |
| `PATCH` | `/quests/{id}` | Edit a quest (author only). | Yes |
| `DELETE` | `/quests/{id}` | Delete a quest (author only). | Yes |
| `POST` | `/quests/{id}/start` | Start/claim → `QuestProgress`. | Yes |
| `POST` | `/quests/{id}/complete` | Complete → `QuestCompletion` + XP award. | Yes |
| `POST` | `/quests/{id}/cancel` | Cancel the caller's progress. | Yes |
| `GET` | `/guilds` | Distinct guilds + the caller's XP per guild. | Yes |
| `GET` | `/leaderboard` | `?scope=global\|guild&guild=<name>`. | Yes |
| `GET` | `/meta/levels` | Optional level/title override table. | Yes |
| `GET` | `/meta/banner-presets` | Banner preset catalogue. | Yes |
| `GET` | `/me/export` | Full personal data export. | Yes |

> The paths in this table are relative to the base path. In `openapi.yaml` they are
> written out in full — `/api/v1/quests`, `/api/v1/auth/login`, … — so the file can be
> served directly by the mock and by any generator without a path-prefix setting.

### 12.3 Quest list query parameters

| Param | Type | Notes |
|---|---|---|
| `status` | enum | `available` \| `in_progress` \| `completed` — **per-viewer** (FR-22). |
| `guild` | string | Exact (case-insensitive) guild match. |
| `q` | string | Full-text over name, description, guild, author, icon. |
| `sort` | enum | `guild` \| `created_at` \| `completed_at` \| `xp_reward` \| `name`. Default `created_at` desc. |
| `since` | string | Delta sync — return records with `updated_at > since`. |
| `limit`, `cursor` | int, string | Pagination. |

### 12.4 Sync model (D16, D17)

There is no realtime channel. Sync is:

1. **Push** — replay the local `outbox` in creation order. Each op carries a client-generated `client_id`; the server is idempotent on it.
2. **Pull** — `GET /quests?since=<last_sync_at>` plus `GET /auth/me` and `GET /guilds`.
3. **Merge** — server `updated_at` wins, EXCEPT for records with a pending outbox op, which are protected until that op is acked.

The sync indicator in the app chrome shows `idle` / `pending (n)` / `syncing` / `error`.

---

## 13. Project structure

```
questboard/
├── openapi.yaml                    # normative API contract + seed examples
├── SPEC.md                         # this document
├── README.md
├── analysis_options.yaml
├── pubspec.yaml
├── l10n.yaml                       # ARB config
├── assets/
│   ├── fonts/                      # Orbitron, Rajdhani, ShareTechMono (.ttf)
│   └── icons/                      # app icon, banner icons (procedural — none needed)
├── lib/
│   ├── main.dart
│   ├── app.dart                    # MaterialApp.router, theme, l10n wiring
│   ├── l10n/
│   │   ├── app_en.arb
│   │   ├── app_es.arb              # stub proving the plumbing (D10, FR-56)
│   │   └── generated/              # flutter gen-l10n output (generated, do not edit)
│   ├── core/
│   │   ├── theme/
│   │   │   ├── tokens.dart         # colours, spacing, radii (§11.1, §11.5)
│   │   │   ├── theme.dart          # ThemeData, light/dark
│   │   │   └── typography.dart
│   │   ├── constants/
│   │   │   ├── emoji.dart          # curated icon set (§11.3)
│   │   │   ├── titles.dart         # level titles (§9.3)
│   │   │   └── banner_presets.dart # preset descriptors (§11.2)
│   │   └── utils/
│   │       ├── result.dart
│   │       └── debouncer.dart
│   ├── domain/
│   │   ├── user.dart
│   │   ├── quest.dart
│   │   ├── quest_progress.dart
│   │   ├── quest_completion.dart
│   │   ├── guild.dart
│   │   ├── level.dart              # curve + title resolution (§9)
│   │   └── enums.dart
│   ├── data/
│   │   ├── remote/
│   │   │   ├── api_client.dart     # Dio setup, auth interceptor, error mapping
│   │   │   ├── auth_api.dart
│   │   │   ├── quest_api.dart
│   │   │   ├── meta_api.dart
│   │   │   └── leaderboard_api.dart
│   │   ├── local/
│   │   │   ├── database.dart       # drift setup
│   │   │   ├── tables.dart
│   │   │   └── dao/*.dart
│   │   ├── outbox/
│   │   │   ├── outbox.dart         # queue model
│   │   │   └── sync_service.dart   # push/pull/merge (§12.4)
│   │   └── repository/
│   │       ├── auth_repository.dart
│   │       ├── quest_repository.dart
│   │       ├── user_repository.dart
│   │       └── guild_repository.dart
│   ├── services/
│   │   ├── sound_service.dart      # abstract + placeholder impl (§5.11)
│   │   ├── haptics_service.dart
│   │   ├── settings_service.dart
│   │   ├── connectivity_service.dart
│   │   └── endpoint_service.dart   # endpoint storage + health check
│   ├── state/
│   │   ├── providers.dart          # riverpod root providers
│   │   ├── session_provider.dart
│   │   ├── quests_provider.dart
│   │   ├── guilds_provider.dart
│   │   ├── leaderboard_provider.dart
│   │   └── settings_provider.dart
│   ├── features/
│   │   ├── connect/                # §6.2 screen 1
│   │   ├── language/               # §6.2 screen 2
│   │   ├── auth/                   # §6.2 screen 3
│   │   ├── board/                  # §6.3 main
│   │   ├── quests/                 # §6.4 list, §6.5 create, §6.6 detail
│   │   ├── banner/                 # §6.7 editor
│   │   ├── leaderboard/            # §6.8
│   │   └── settings/               # §6.9
│   └── widgets/                    # shared: neon_card, xp_bar, quest_row, guild_chip, sync_indicator, empty_state
├── test/
│   ├── unit/                       # xp math, level resolution, guild xp, sorting, search
│   ├── widget/
│   └── integration/
├── integration_test/
└── .github/workflows/
    ├── ci.yml
    ├── build.yml
    └── build-linux-arm64.yml
```

**Convention:** `features/<name>/` contains `screen.dart`, `widgets/`, and `providers.dart`. Shared presentation primitives live in `lib/widgets/`. Domain models never import Flutter UI code.

---

## 14. Dependencies

**Core**
| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `dio` | HTTP client (interceptors, timeouts) |
| `drift` + `drift_dev` + `sqlite3_flutter_libs` | Local cache + outbox (SQLite) |
| `flutter_secure_storage` | Token storage (NFR-11) |
| `go_router` | Routing (§6.1) |
| `intl` + `flutter_localizations` | Localization (§5.12) |
| `shared_preferences` | Non-secret local settings |

**Feature**
| Package | Purpose |
|---|---|
| `uuid` | Client-generated ids (A5) |
| `equatable` | Value equality for domain models |
| `json_annotation` + `json_serializable` | JSON codegen for domain models |
| `collection` | Collection utilities |

**Sound (§5.11)** — v1 uses `SystemSound` + `HapticFeedback` only; **no audio package**. This keeps the APK small and avoids a Linux-desktop audio dependency that may not behave on every distro. A real `audioplayers` integration is a later milestone, gated behind the `SoundService` interface.

**Fonts** — bundled `.ttf` files from Google Fonts (OFL). No `google_fonts` runtime fetching (NFR-07).

**Explicitly excluded** — Firebase, `google_fonts` (runtime), `flutter_bloc`, any Play Services dependency (NFR-06).

---

## 15. Mock server and seed data (D20)

### 15.1 Approach

`openapi.yaml` is the single source of truth. The mock is generated from it:

```bash
npx @stoplight/prism-cli mock openapi.yaml -p 4010
```

- Every example in the YAML becomes the mock's response body.
- The client can therefore be built and demoed with **zero backend code**.
- Because the mock is generated from the spec, spec and mock **cannot drift**.
- The mock listens on `http://127.0.0.1:4010` and serves the paths exactly as written in
  the YAML — i.e. `http://127.0.0.1:4010/api/v1/quests`. The Connect screen's default
  endpoint is therefore `http://127.0.0.1:4010` (origin only, §12.1).
- Prism answers with the **static** examples from the YAML (not `--dynamic`), so the
  demo data is deterministic. Consequence: **every** `2xx` response, including the
  idempotent-replay `200` responses, carries an `examples` block. Prism serves the
  lowest `2xx` code of an operation, and a response without examples falls back to
  generating values from the schema.
- Prism enforces the bearer scheme: requests without `Authorization: Bearer <token>`
  get the `401` example; any non-empty token is accepted.

### 15.2 Seed data

The YAML embeds examples for every response. A `seed.json` file MAY be added later for a richer fixture set (10+ users, 30+ quests across 5 guilds, mixed states) without changing the contract.

**Minimum seed set** (embedded as examples in `openapi.yaml`):

- **Users** — `Riley_42` (the signed-in user, level 7, 2,475 XP, `Pulse Weaver`), plus
  `Morgan_88` (3,150 XP, level 8, `Data Drifter`), `Sam_77` (1,450 XP, level 5,
  `Voltage Runner`), `Ada_01` (900 XP, level 4, `Chrome Adept`), `Quiet_Runner`
  (420 XP, level 3, `Grid Scout`). Every level/title is derived from the §9.2 curve —
  the seed values are chosen so the curve and the title table agree.
- **Guilds** — `Chores`, `Work`, `Errands`, `Fitness`, `Learning`.
- **Quests** — at least 3 in each of the three per-viewer states, including one repeatable, one with no guild, one with a long description, and one authored by the signed-in user.
- **Completions** — 10 for the signed-in user, summing to `total_xp = 2,475`: 1,250 XP on
  `Chores`, 1,200 XP on `Work`, and 25 XP from a quest with **no** guild. The guild
  totals are therefore a strict subset of the total, exactly as §10 requires.

### 15.3 Switching to the real backend

One change: the endpoint field on the Connect screen. No code change, no rebuild.

---

## 16. Build and release

| Target | Command | Notes |
|---|---|---|
| Android APK | `flutter build apk --release` | `--split-per-abi` → `arm64-v8a` + `armeabi-v7a` (PinePhone is aarch64; armv7 kept for older ARM devices) |
| Android App Bundle | `flutter build appbundle` | For Play Store, if ever needed |
| iOS | `flutter build ipa` | Requires macOS + Xcode. macOS CI runner. $99/yr Apple Developer account for App Store. |
| Linux desktop | `flutter build linux --release` | x86_64 bundle → AppImage / deb / rpm / Flatpak |
| Linux arm64 | `flutter build linux --release` **on an arm64 host** | Upstream Flutter cannot cross-compile linux-arm64 from x64 (flutter#117826). Use a native arm64 CI runner. |
| Web (future) | `flutter build web` | Not in v1 (D21) but must not be blocked by the codebase. |

**Distribution**
- **Android** — sideload the APK (PinePhone has no Play Store).
- **iOS** — App Store, or TestFlight for internal distribution.
- **Linux desktop** — AppImage for zero-friction internal distribution; Flatpak for distro-level distribution; optionally a postmarketOS `apk` package.
- **postmarketOS native** — only if the arm64 Linux build is required; package as an Alpine `apk`.

**Release signing** — Android keystore and iOS distribution certificates MUST be stored in CI secrets, never in the repo.

---

## 17. Continuous integration

### 17.1 `ci.yml` (every push and PR)
1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze` — zero issues (NFR-08)
4. `flutter test` — unit + widget
5. `flutter test integration_test/` on an Android emulator

### 17.2 `build.yml` (tags and manual dispatch)
Matrix producing: Android APK, Linux x86_64 bundle, iOS IPA (macOS runner).

### 17.3 `build-linux-arm64.yml` (manual dispatch + weekly)
Runs on `ubuntu-24.04-arm`. **Free for public repos only** — for a private repo either self-host an arm64 runner or use QEMU via `uraimo/run-on-arch-action` (slower but works everywhere). Uploads the arm64 Linux bundle as an artifact.

---

## 18. Milestones

Each milestone is independently shippable and ends with a demoable increment.

| # | Milestone | Deliverable | Depends on |
|---|---|---|---|
| **M0** | Skeleton | Flutter project, all three platform targets, theme tokens, typography, fonts bundled, router shell, CI green | — |
| **M1** | Contract | `openapi.yaml` complete with examples; Prism mock running | — |
| **M2** | Onboarding | Connect → Language → Create account → Main (empty board). Secure token storage. | M0, M1 |
| **M3** | Board & lists | Guild Board hub with live counts, three quest lists, rows, search, sort, guild filter, empty/error/loading states | M2 |
| **M4** | Quest lifecycle | Create quest form (emoji picker, guild autocomplete, XP quick-picks), quest detail, start / complete / cancel / edit / delete | M3 |
| **M5** | Progression | XP totals, level curve, titles, level-up moment, XP bar in the banner, per-guild XP strip | M4 |
| **M6** | Banner & leaderboards | Banner presets, Banner Editor screen, global + per-guild leaderboards with banner rows | M5 |
| **M7** | Offline | drift cache, outbox queue, push/pull sync, sync indicator, offline banner | M4 |
| **M8** | Settings | Endpoint, account, language, sound toggle, data controls (clear / resync / export / delete) | M6, M7 |
| **M9** | Sound | `SoundService` with placeholder tones, haptics, level-up sting | M5 |
| **M10** | Desktop | Adaptive breakpoints, `NavigationRail`, table layout, master-detail, desktop packaging (AppImage/Flatpak) | M3–M6 |
| **M11** | Polish & release | i18n stub locale, accessibility pass, performance tuning, release signing, CI release pipeline | M1–M10 |

**Critical path:** M1 → M2 → M3 → M4 → M5 → M6 → M8 → M11.

---

## 19. Risks and mitigations

| # | Risk | Impact | Mitigation |
|---|---|---|---|
| R1 | Backend team lands a different contract | High | §12 is normative; the OpenAPI file is the arbiter. Changes go through a spec PR, not via the client. |
| R2 | PinePhone GPU cannot run the app smoothly | High | §11.6 guardrails; test on real hardware early (M0). Fallback: `--no-enable-impeller` / `LIBGL_ALWAYS_SOFTWARE=1`. |
| R3 | Impeller fails on the PinePhone (no Vulkan) | Medium | On Android, Impeller falls back to OpenGL automatically below API 29 or without Vulkan. Ship the manifest flag to force Skia. |
| R4 | arm64 Linux build cannot be produced in CI | Medium | Manual dispatch workflow on `ubuntu-24.04-arm`; QEMU fallback; this target is not on the critical path (§18). |
| R5 | Offline merge causes data loss | High | Outbox ops are protected from server overwrite until acked; completion ids are idempotent; completions are append-only. |
| R6 | Emoji rendering differs across platforms | Low | Curated set (§11.3) validated on Android, iOS, and Linux; fallback glyph for unsupported emoji. |
| R7 | The "guild" concept outgrows a string tag | Medium | Guilds are strings in the model and the UI; a later migration to entities is a server-side change plus a client type change. No UI rework assumed. |
| R8 | User expects guild XP to be an independent progression | Medium | §10 is normative and explicit: guild XP is a subset of total XP and never affects level. |
| R9 | iOS PWA/desktop expectation mismatch | Low | iOS is a native build in this plan. |
| R10 | Scope creep into a full RPG | Medium | §2.5 out-of-scope list is normative. |

---

## 20. Glossary

| Term | Meaning |
|---|---|
| **Quest** | A task. The core entity. |
| **Guild** | A free-text tag grouping quests. Not an entity. |
| **Available** | A quest the current user has not started. |
| **In Progress** | A quest the current user has started and not completed. |
| **Completed** | A quest the current user has completed. |
| **Repeatable** | A quest that resets to Available on completion and can be earned again. |
| **XP** | Experience points. Awarded on completion. |
| **Level** | Derived from total XP via the level curve. |
| **Title** | A name derived from level. |
| **Total XP** | Σ of all XP the user has earned. The only input to level. |
| **Guild XP** | Σ of XP earned on quests in a given guild. A subset of total XP. |
| **Banner** | The header card showing avatar, name, level, title, and XP. Reused in leaderboards. |
| **Outbox** | The local queue of unsent mutations. |

---

## 21. Acceptance criteria

### 21.1 Onboarding
- [ ] A fresh install opens on `/connect` with a pre-filled default endpoint.
- [ ] Entering an unreachable URL shows an inline error and does not advance.
- [ ] A reachable URL advances to `/language`.
- [ ] Selecting a language advances to `/auth`.
- [ ] Registering with only email + password succeeds and lands on `/` (main).
- [ ] A registered user with no username displays a themed anonymous display name.
- [ ] Setting a username replaces the anonymous name everywhere.

### 21.2 Board and lists
- [ ] The main screen shows a banner with avatar, display name, level, title, and an XP bar.
- [ ] The Guild Board shows four tiles: Available, In Progress, Completed, Create Quest.
- [ ] The three quest-state tiles show correct live counts.
- [ ] Each list renders rows with icon, name, XP, and guild chip.
- [ ] Search matches name, description, guild, author, and icon.
- [ ] Sort works by guild, newest, recently completed, XP, and name.
- [ ] The guild filter narrows the list to one guild, and `All` restores it.
- [ ] Empty, loading, and error states are visually distinct.

### 21.3 Quest lifecycle
- [ ] Creating a quest requires a name and an XP reward; the button is disabled otherwise.
- [ ] The emoji picker lets a user choose an icon and clear it.
- [ ] The guild field suggests existing guilds but accepts free text.
- [ ] `Start` moves the quest to In Progress for that user only.
- [ ] `Mark complete` awards XP, updates the total, and moves the quest to Completed.
- [ ] Completing a repeatable quest returns it to Available and records another completion.
- [ ] Completing a non-repeatable quest removes it from other users' Available lists.
- [ ] The author can edit and delete their own quest; another user sees no edit or delete affordance.
- [ ] Delete requires confirmation.

### 21.4 Progression, banner, leaderboards
- [ ] Level matches the §9.2 curve for the user's total XP.
- [ ] Title matches the §9.3 table for the user's level.
- [ ] Per-guild XP equals the sum of that guild's completions, and never exceeds total XP.
- [ ] Level is unaffected by guild XP.
- [ ] The Banner Editor shows a live preview and persists a preset choice.
- [ ] The leaderboard has Global and Guild scopes; each row shows a compact banner.
- [ ] The current user's leaderboard row is highlighted.

### 21.5 Offline
- [ ] With the network down, the app still renders the cached main screen.
- [ ] A quest completed offline appears in Completed immediately, marked pending.
- [ ] On reconnect the queue drains and the pending markers clear.
- [ ] Replaying the same completion twice does not double the XP.

### 21.6 Settings
- [ ] The endpoint can be changed, and doing so clears the cache and returns to `/connect`.
- [ ] The language can be changed and the UI updates immediately.
- [ ] The sound toggle suppresses all sound effects.
- [ ] Clear cache, force re-sync, export, and delete account all function.
- [ ] Delete account requires typing a confirmation phrase.
- [ ] The Banner Editor is reachable from the banner, not from Settings.

### 21.7 Sound
- [ ] Creating, starting, and completing a quest each play a distinct sound.
- [ ] A level-up plays its own sound.
- [ ] Another user's activity plays no sound.
- [ ] Sound never delays the UI action that triggered it.

### 21.8 Quality gates
- [ ] `flutter analyze` → zero issues.
- [ ] `flutter test` → all green, including unit tests for the §9 curve, the §10 guild rules, sorting, and search.
- [ ] The app builds and runs on the PinePhone, an iPhone, and Linux desktop.
- [ ] No Play Services dependency appears in the dependency tree (NFR-06).

---

## 22. Open questions

These are **not** blocking M0–M2 and can be resolved during implementation. Each carries a recommended default so work can proceed.

| # | Question | Recommended default |
|---|---|---|
| Q1 | Does a user need to be a member of anything to complete a quest? | No. D13 says any user can work any quest. |
| Q2 | Can two users complete the same non-repeatable quest? | Yes — both get XP; the quest closes on the first completion (A3). Confirm with the backend team. |
| Q3 | Is a completed non-repeatable quest visible in others' Completed lists? | No — only in the completer's list. |
| Q4 | Should the guild autocomplete be case-insensitive? | Yes. |
| Q5 | What is the XP cap per quest per day? | None in v1. Repeatable quests are a deliberate, self-limited mechanism. |
| Q6 | Should `total_xp` ever decrease (e.g. quest deletion refunds XP)? | No refund in v1. Deleting a quest removes it from the board but leaves earned XP. |
| Q7 | Do we need a password reset flow? | Not in v1. The backend team should provide a reset-by-email endpoint later. |
| Q8 | Should the app support multiple accounts on one device? | Not in v1. One session at a time; logout returns to `/auth`. |
| Q9 | Should guilds be creatable separately from quests? | No. A guild exists as soon as a quest uses that tag (D4). |
| Q10 | Should the app show a "quest detail" preview inline on desktop? | Yes — master-detail at the Expanded breakpoint (§11.7). |
| Q11 | Are the level titles final? | They are placeholders per D3. The server can override the whole table (§9.4). |
| Q12 | What backend will the app point at by default? | A placeholder constant `DEFAULT_ENDPOINT`, replaced before release. |
| Q13 | Does the PinePhone user base need a specific APK ABI? | `arm64-v8a` primary; keep `armeabi-v7a` for compatibility. |
| Q14 | Should quest creation be restricted to guild members? | No — guilds are tags, not groups (D4). |

---

## Appendix A — Glossary of API examples

The `openapi.yaml` file carries live examples for every endpoint. The most important:

**`POST /api/v1/auth/register`**
```json
{
  "email": "riley@example.com",
  "password": "correct-horse-battery",
  "username": "Riley_42",
  "avatar": "⚔️"
}
```
→ `201`
```json
{
  "access_token": "eyJhbGciOi...",
  "refresh_token": "dG9rZW4...",
  "user": {
    "id": "3f2b1c44-8a2e-4f3b-9d11-6b0e5a7c1d90",
    "email": "riley@example.com",
    "username": "Riley_42",
    "display_name": "Riley_42",
    "avatar": "⚔️",
    "banner_preset_id": "neon_grid",
    "total_xp": 2475,
    "created_at": "2026-10-01T09:12:00Z",
    "updated_at": "2026-10-22T13:58:04Z"
  }
}
```

**`GET /api/v1/quests?status=available&sort=guild`**
```json
{
  "items": [
    {
      "id": "a1b2c3d4-1111-4222-9333-444455556666",
      "name": "Clean the kitchen",
      "description": "Wipe the counters, take out the bins, run the dishwasher.",
      "icon": "🧹",
      "guild": "Chores",
      "xp_reward": 50,
      "is_repeatable": true,
      "author_id": "3f2b1c44-8a2e-4f3b-9d11-6b0e5a7c1d90",
      "author_name": "Riley_42",
      "status": "available",
      "created_at": "2026-10-18T07:30:00Z",
      "updated_at": "2026-10-18T07:30:00Z",
      "completed_at": null,
      "completed_by_id": null,
      "completed_by_name": null,
      "completion_count": 0,
      "my_status": "available",
      "my_progress_id": null,
      "my_completion_count": 0
    }
  ],
  "next_cursor": null
}
```

**`GET /api/v1/guilds`**
```json
{
  "total_xp": 2475,
  "guilds": [
    { "name": "Chores", "xp": 1250, "quest_count": 6 },
    { "name": "Work",   "xp": 1200, "quest_count": 4 }
  ]
}
```
> `1,250 + 1,200 = 2,450 < 2,475` — the missing 25 XP is a completion on a quest with no
> guild. Guild XP is a subset of total XP, never additive (§10).

---

## Appendix B — Change log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-10-22 | Initial spec. Covers FR-01…FR-57, NFR-01…NFR-12, M0–M11, AC §21. |
