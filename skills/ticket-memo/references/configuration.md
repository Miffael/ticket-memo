# Configuration reference

Read this when creating or changing a project's config, when the user asks to
change a setting, or when a config value is unclear. Day-to-day work only needs
the short summary in `SKILL.md`.

## Contents

- Where the config lives
- All keys
- Paths that work on several machines
- Cloud-synced folders
- Task statuses
- The vault manifest
- Changing settings

## Where the config lives

The config file is `ticket-memo.config.json` at the project root, looked up in
this order — the first one found is used:

1. `.claude/ticket-memo.config.json`
2. `.agents/ticket-memo.config.json` (agent-neutral; read by Antigravity, Codex
   and any other agent using this skill)

Never create both. For new configs the default location is `.agents/`; use
`.claude/` if the project already keeps its agent settings there or the user asks.

If a `ticket-memo.config.local.json` sits next to the config file, its keys
override the config's keys. It holds machine-specific values (usually
`docsRoot`) and should be git-ignored, so the shared config can be committed
while each device points at its own copy of the synced vault:

```gitignore
.agents/ticket-memo.config.local.json
.claude/ticket-memo.config.local.json
```

Write config files as UTF-8 without BOM, 2-space indent. After writing, show the
file (or the changed lines) to the user.

## All keys

```json
{
  "docsRoot": "~/OneDrive/knowledges/<project>",
  "project": "<project-name>",
  "tasksDir": "tasks",
  "planUpdates": "auto",
  "reportUpdates": "on-request",
  "describeSaves": "auto",
  "graphUpdates": "auto",
  "history": "full",
  "language": { "plan": "en", "report": "en", "describe": "en" }
}
```

The template is `assets/config-template.json`. Only `docsRoot` is required;
missing keys take the defaults shown.

| Key | Default | Meaning |
|---|---|---|
| `docsRoot` | — | Folder where this project's notes live: an Obsidian vault root, or a folder inside a vault (the nearest ancestor with `.obsidian/` is the vault). May be inside a cloud-synced folder. See "Paths". |
| `project` | project folder name | This project's name in the vault. Matters when several projects share one `docsRoot`: their tasks carry `project:` in frontmatter, the index gets a Project column, status filters by it. |
| `tasksDir` | `tasks` | Folder inside `docsRoot` holding one subfolder per task. |
| `planUpdates` | `auto` | `auto`: update the plan after every completed action. `on-request`: only when asked. |
| `reportUpdates` | `on-request` | `on-request`: regenerate a report only for a status request. `auto`: also after every completed action. |
| `describeSaves` | `auto` | `auto`: save explanations and write-ups without being asked. `on-request`: only when asked. |
| `graphUpdates` | `auto` | `auto`: create and extend entity, term and topic notes as they come up. `suggest`: list proposed notes at the end of a reply, create on agreement. `off`: only when asked. |
| `history` | `full` | `full`: keep task histories — work, decision records, changes with rollback. `changes`: only entries that changed something outside the vault. `off`: no history notes; plans keep a Rollback section for changes still in effect. Details: `references/history.md`. |
| `language` | `en` | ISO 639-1 code(s). One string for all notes (`"en"`) or an object: `plan` — plan and history notes; `report` — reports and status summaries; `describe` — write-ups, guides, decisions, entity, term and topic notes, the glossary. A missing key falls back to `en`. |
| `statuses` | `["open", "to-do", "research", "in-progress", "review", "blocked", "done"]` | Task statuses allowed in plans' `status:`, kebab-case. Replace the list to match a tracker's workflow (e.g. add `qa`, drop `research`); `done` is always kept. Shown in Title Case in the index and reports. |

## Paths that work on several machines

- `docsRoot` uses forward slashes, also on Windows.
- A leading `~` and `${VAR}` environment variables are expanded:
  `${OneDrive}/knowledges/x`, `~/Library/CloudStorage/GoogleDrive-<account>/My Drive/x`.
  Expand them before checking the path; if a variable is not set on this
  machine, stop and tell the user (suggest a `.local` override).
- If the path differs per machine and no variable fits, put `docsRoot` into
  `ticket-memo.config.local.json` and keep the committed config without it (or
  with the most common value).
- Checks before writing (also done in daily work): the folder exists; for a
  network/rclone mount on Linux, `mountpoint -q <docsRoot>` succeeds.

Typical cloud locations:

| Service | Windows | macOS |
|---|---|---|
| OneDrive | `${OneDrive}/…` (also `${OneDriveConsumer}`, `${OneDriveCommercial}`) | `~/Library/CloudStorage/OneDrive-*/…` |
| Google Drive for desktop | `G:/My Drive/…` (drive letter may differ) | `~/Library/CloudStorage/GoogleDrive-*/My Drive/…` |
| Dropbox | `~/Dropbox/…` | `~/Library/CloudStorage/Dropbox/…` |
| iCloud Drive | `~/iCloudDrive/…` | `~/Library/Mobile Documents/com~apple~CloudDocs/…` |

On Linux: the official client where one exists, or an rclone mount.

## Cloud-synced folders

`docsRoot` can live directly in a OneDrive, Google Drive, Dropbox or iCloud
folder — that is how the vault reaches the user's other devices. Rules:

- Write to the local synced path, never through a web API.
- If a note you are about to edit is an online-only placeholder (OneDrive Files
  On-Demand, Google Drive "streamed" files), reading it downloads it first; if
  that fails, tell the user to mark the folder "Always keep on this device" /
  "Available offline".
- If you find sync-conflict copies (`<name>-<DEVICE>.md`, `<name> (1).md`,
  `<name> (conflicted copy).md`), do not merge or delete them silently — report
  them and offer to merge.

## Task statuses

`statuses` lists the values allowed in a plan's `status:`, in kebab-case. Default
meanings:

| Status | Meaning |
|---|---|
| `open` | registered (e.g. a tracker ticket), not yet triaged or planned |
| `to-do` | planned and ready, work not started |
| `research` | investigating or designing; no implementation yet |
| `in-progress` | being implemented |
| `review` | the work is done and waits for review, approval or a team choice |
| `blocked` | cannot move until something outside the task happens; the plan names the blocker |
| `done` | finished |

A project may replace the list to match its tracker's workflow (add `qa`, drop
`research`); `done` is always kept. Statuses are shown in Title Case in the
index, reports and topic hubs. Every status but `done` counts as active. A value
outside the list is reported by a vault check, not silently rewritten.

## The vault manifest

`<docsRoot>/.ticket-memo.json` describes the vault itself, independent of any
project (template: `assets/vault-manifest-template.json`):

```json
{
  "schema": 1,
  "created": "2026-11-20",
  "tasksDir": "tasks",
  "language": { "plan": "en", "report": "en", "describe": "en" },
  "projects": [
    { "name": "home-server", "connected": "2026-11-20", "device": "<hostname>" }
  ]
}
```

- It marks the folder as a ticket-memo vault and carries the vault's own layout
  and language, so a project connecting later adopts them instead of guessing.
- `projects` lists every project and device that connected — names and dates
  only, no paths with personal data, no secrets.
- Created during setup or connection. Update it by **adding or editing only this
  project's entry**; never drop other entries or change shared keys without the
  user's agreement.
- A project config's `tasksDir`/`language` that differ from the manifest win for
  that project; mention the difference when connecting or changing settings.
- Obsidian ignores dot-files, so the manifest does not appear among the notes.

## Changing settings

The user can change any setting by asking ("stop auto-updating plans", "move
tasks to projects/", "write plans in German", "don't create glossary notes on
your own", "move my docs to Google Drive"). In every case: update the config
file (or the `.local` override, if the key lives there) and show the changed
lines. Specific cases:

- **`docsRoot` changes** (new location, other cloud drive):
  1. If the new folder is not empty, treat it as connecting an existing vault —
     follow `references/connect-existing-vault.md` instead of copying over it.
  2. Otherwise ask whether to move the existing notes. Moving = copy the whole
     `docsRoot` (including `.obsidian/` and `.ticket-memo.json`) to the new
     place, verify the file count matches, switch the config, and only then offer
     to delete the old copy — deleting needs explicit confirmation.
  3. If the vault is shared with other projects (manifest lists more than one),
     say that their configs still point at the old location.
- **`tasksDir` changes:** ask whether to move the existing task folders; if yes,
  move them, then fix path-qualified wikilinks that contain the old folder name
  and update the manifest's `tasksDir` only if this is the only project.
- **`language` changes:** existing notes stay as they are; new notes and new
  entries use the new language. Offer to translate existing notes only if the
  user wants it. Structural parts (frontmatter, note-name suffixes, `index.md`)
  stay English regardless.
- **`history` changes:** follow "What the `history` setting changes" in
  `references/history.md` — existing history notes are never deleted or rewritten;
  when switching to `off`, say once what will no longer be recorded.
- **Update behaviour** (`planUpdates`, `reportUpdates`, `describeSaves`,
  `graphUpdates`): just change the value; takes effect immediately.
- **Sharing the vault with another project:** set `project` in both configs, add
  `project:` to this project's existing task plans and a Project column to the
  index (additive edits), add the project to the manifest.
- **Moving the config file** between `.claude/` and `.agents/`: move, never keep
  both.
