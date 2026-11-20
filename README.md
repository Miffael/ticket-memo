# ticket-memo

**Long-term project memory for AI agents, as a linked knowledge graph.** An
[Agent Skill](https://agentskills.io) that makes your agent (Claude Code, Google Antigravity, Codex,
Cursor, Gemini CLI, …) keep a Markdown knowledge base — ideally an Obsidian vault — for any project:

- **tasks of any size** — a Jira/GitHub ticket, a piece of project work or a quick to-do — each with a
  short plan (current state) and an append-only history where every change is recorded **with its
  rollback**;
- **entities** — the concrete things of the project: hosts, apps, services, components, repos,
  people/roles, accounts and keys (metadata only), with typed relations ("runs on", "depends on");
- **a glossary** — the project's terms, abbreviations and codenames with what they mean *here*;
- **topics** — hub notes that tie tasks, entities, terms and guides together into a navigable graph.

Agent sessions are forgotten; the vault is not. A week later — in a new session, with another agent or
on another device — the agent reads the vault as context: it knows what *"cold path"* means in your
project, what depends on `postgres`, what was changed last Tuesday and how to undo it.

It started as memory for agents that administer a machine (and is still excellent at that), but works
just as well for software projects, research, homelab, or any other area you want to keep organised.

---

## Contents

- [What it does](#what-it-does)
- [What the vault looks like](#what-the-vault-looks-like)
  - [How the graph is linked](#how-the-graph-is-linked)
  - [Current context and history](#current-context-and-history)
  - [Inside the skill](#inside-the-skill)
- [Installation](#installation)
- [First run: setting up a project](#first-run-setting-up-a-project)
- [Connecting an existing vault](#connecting-an-existing-vault)
- [Configuration reference](#configuration-reference)
- [Languages](#languages)
- [Obsidian: dedicated vault or a folder in an existing one](#obsidian-dedicated-vault-or-a-folder-in-an-existing-one)
- [Storing the vault in Google Drive, OneDrive, Dropbox or iCloud](#storing-the-vault-in-google-drive-onedrive-dropbox-or-icloud)
- [Everyday usage](#everyday-usage)
- [Updating and uninstalling](#updating-and-uninstalling)
- [Security](#security)
- [FAQ](#faq)
- [License](#license)

---

## What it does

The skill gives the agent a fixed routine:

| Mode | When | What the agent does |
|---|---|---|
| 0. Setup | No config in the project yet | Asks where to keep the docs and in which language, creates the config and the vault skeleton, offers to seed topics/terms from your README |
| 1. New task | "new task: tailscale-ssh", "start working on PROJ-123" | Creates `<slug> plan` (small or full), reads the related topics, entities and terms first |
| 2. Keep current | After **every** completed action (automatic) | Updates the plan, appends a dated history entry listing every change **with its rollback**, updates the affected entities |
| 3. Remember | "remember this", "from now on we…", a decision is made | Updates what holds now (plan's decisions in force, a `standards/` note, an entity or term) and records why in history |
| 4. Describe | "explain how X is set up", "write up …" | Answers in chat and saves the explanation as a standalone note or guide |
| 5. Status | "what's the status of …", "what's open in networking" | Regenerates short reports per task or per topic |
| 6. Lookup | "what does SLO mean here", "what depends on postgres", "what is installed" | Answers from glossary, entities and their relations; verifies live systems read-only |
| 7. Resume | "back to docker-setup", "back to the backups topic" | Read-only "where you left off" summary |
| 8. Grow the graph | A term is defined, an entity gets facts, a theme emerges (automatic) | Creates/extends term, entity and topic notes and links them |
| 9. Upkeep | "check the vault", "clean up links" | Reports broken links, orphans, duplicates, stale plans, sync conflicts; fixes after approval |

Principles built into the skill:

- **Every change has an undo.** History entries record *what* changed, *where*, and the exact rollback.
- **The plan is short** — only the current state. Everything finished moves to history (append-only).
- **The graph is the context.** Before guessing, the agent looks up the project's terms and entities;
  every note links to a topic hub, so nothing is orphaned.
- **Search before create.** No duplicate notes for the same thing — synonyms become `aliases`.
- **No secrets in notes, ever.** Only metadata: what a key grants, where it is stored, how to rotate it.
- **Plain Markdown + wikilinks + YAML frontmatter.** Works in Obsidian, but any editor will do.

No ticket tracker is needed — tasks are identified by short kebab-case slugs (`docker-setup`). If you
use one, the slug can be the ticket key (`proj-123`) and the plan links to the ticket.

## What the vault looks like

```text
<docsRoot>/
  index.md                          home: tasks table, topics list, link to glossary
  tasks/
    docker-setup/
      docker-setup plan.md          current state + decisions in force
      docker-setup history.md       chronology, decision records, every change with rollback
      docker-setup report.md        generated status digest
      docker-setup notes.md         write-ups for this task
    general/general history.md      decisions not tied to any task
    proj-123/                       a tracker ticket works the same way
  topics/                           hubs: topic networking.md, topic backups.md, …
  context/                          entities, one subfolder per kind
    host/        host machine.md, host network.md
    apps/        app lazydocker.md
    services/    service billing-api.md
    people/      person platform team.md        (roles, not private data)
    access/      access ssh-keys.md             (metadata only, never values)
  glossary/                         glossary.md + one note per term: cold path.md, SLO.md, …
  standards/                        rules and final standards in force: standard service-naming.md, …
  guides/<topic>/                   longer write-ups not tied to one task
```

Entity kinds are open-ended — the agent reuses existing folders and adds new kinds (`repos`,
`components`, `documents`, `vendors`, …) when your project needs them.

### How the graph is linked

```text
          topic networking  ◄──── topic homelab (parent)
          ▲      ▲       ▲
          │      │       │ topics:
 tailscale-ssh  host     [[MagicDNS]] (term)
    plan ─────► network ◄── runs on ── app tailscale
      │                                    ▲
      └──── history: "installed tailscale" ┘ (Related tasks)
```

- every note lists its hubs in `topics:` frontmatter; every topic is in `index.md`, every term in
  `glossary/glossary.md` — so there are no orphans in Obsidian's graph view;
- entity notes carry **typed relations** (`runs on`, `depends on`, `used by`, `owned by`, `replaces`),
  which lets the agent answer "what breaks if X goes down";
- the first mention of a known term or entity in any note is a wikilink; synonyms and translations are
  `aliases`, so `[[k8s]]` and `[[Kubernetes]]` resolve to the same note;
- a note is created only when it carries facts worth keeping (mentioned twice, central to a task, or
  you asked) — no empty stubs.

A history entry looks like this:

```markdown
## 2026-11-20 — Installed Portainer behind Caddy

Portainer CE 2.21 runs as a Compose stack, reachable only over the tailnet.

**Changes made:**

| What | Where | Rollback |
|---|---|---|
| Compose stack `portainer` | `/opt/stacks/portainer/compose.yml` | `docker compose -f /opt/stacks/portainer/compose.yml down -v` |
| Caddy site block | `/etc/caddy/Caddyfile` (lines 40–52) | remove the block, `systemctl reload caddy` |
```

The skill ships the templates it uses in [`skills/ticket-memo/assets/`](skills/ticket-memo/assets/):
plan, history, report, decision, standard, entity, term, topic, index, config and vault manifest.

### Current context and history

The vault keeps **what holds now** apart from **how it came to be**:

| Layer | Notes | Rule |
|---|---|---|
| **Current context** | task plans (state + *Decisions in force*), entities, terms, topics, `standards/` | Always rewritten to be accurate. No chronology — a reader sees the state, the decisions in force and the final rules, nothing superseded. |
| **History** | `<slug> history` per task, `general/general history` for decisions outside any task | Append-only, newest first, dated: work done, decision records (options considered, why), every change outside the vault with its rollback. Never edited — corrections and superseding decisions are new entries. |

When a decision is made, the agent writes the **outcome** to the current layer (replacing the old line or
marking the old standard `superseded`) and the **reasoning** to history, linking the two. Day-to-day work
and lookups read only the current layer; history is opened for "why / when / what did we try / how do I
undo". A rule never lives only in history.

`standards/` holds the project's rules, conventions and final standards (`standard service-naming`,
`standard backup-policy`): the rule, its scope, a short why, how to follow it, exceptions, and a link to
the decision that set it. The agent follows active standards in its work and points out requests that
break one.

The `history` setting decides how much history is kept:

| Value | Work and decision records | Changes with rollback | Use when |
|---|---|---|---|
| `full` (default) | yes | yes, in history | you want to know *why* later |
| `changes` | — | yes, in history | you only need an audit trail of what was changed and how to undo it |
| `off` | — | only while in effect, in the plan's *Rollback* section | lightweight projects; past reasoning is not kept |

Switching the setting never deletes existing history.

### Inside the skill

```text
skills/ticket-memo/
  SKILL.md                         daily rules: layout, linking, tasks, modes — always loaded
  references/                      one-off procedures, read only when needed
    setup-new-vault.md             first run: connect a project to a new vault
    connect-existing-vault.md      attach a vault from another device, project or a backup
    configuration.md               every config key, the vault manifest, changing settings
    vault-upkeep.md                "check the vault": links, duplicates, migration
    history.md                     writing and reading history: entries, decision records, superseding
  assets/                          note, config and manifest templates
```

Keeping setup and configuration out of `SKILL.md` means the agent's everyday context holds only the rules
for keeping the vault; the setup procedures are loaded once, when they are actually needed.

---

## Installation

The skill itself is just the folder [`skills/ticket-memo/`](skills/ticket-memo/) (`SKILL.md` + `references/` + `assets/`)
in the open [Agent Skills](https://agentskills.io) format, so it works with any agent that supports
skills. Pick one method.

### Option A — Claude Code plugin (recommended for Claude Code)

Inside Claude Code:

```text
/plugin marketplace add Miffael/ticket-memo
/plugin install ticket-memo@ticket-memo
```

Updates arrive with `/plugin marketplace update ticket-memo`. Installed as a plugin, the skill is named
`ticket-memo:ticket-memo`.

### Option B — `npx skills` (any agent: Claude Code, Codex, Cursor, OpenCode, Gemini CLI, …)

The [skills CLI](https://github.com/vercel-labs/skills) detects installed agents and copies the skill
into each of them. Requires Node.js.

```bash
npx skills add Miffael/ticket-memo                 # interactive: choose agents and scope
npx skills add Miffael/ticket-memo -a claude-code  # one specific agent
```

### Option C — git clone + link (best for using it on all your own devices)

One clone, linked into every agent; `git pull` updates them all. Links mean edits you make to the
skill go straight back into your clone, ready to commit.

**Windows (PowerShell):**

```powershell
git clone https://github.com/Miffael/ticket-memo.git "$env:USERPROFILE\src\ticket-memo"
cd "$env:USERPROFILE\src\ticket-memo"
.\scripts\install.ps1 -Target claude,antigravity   # or: -Target all ; add -WhatIf to preview
```

If script execution is blocked: `powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 ...`.
Windows uses directory junctions — no admin rights or Developer Mode needed.

**Linux / macOS:**

```bash
git clone https://github.com/Miffael/ticket-memo.git ~/src/ticket-memo
cd ~/src/ticket-memo
scripts/install.sh --target claude,antigravity     # or: --target all ; add --dry-run to preview
```

Targets known to the scripts:

| Target | Folder | Agent |
|---|---|---|
| `claude` | `~/.claude/skills/` | Claude Code |
| `agents` | `~/.agents/skills/` | the cross-agent skills folder (Codex, Gemini CLI and others) |
| `antigravity` | `~/.gemini/config/skills/` | Google Antigravity (older builds: `~/.gemini/antigravity/skills/`) |

Existing installs are never overwritten: the scripts skip them unless you pass `-Force` / `--force`, which
moves the old folder to `ticket-memo.bak-<timestamp>`. `--copy` / `-Copy` installs a plain copy instead of a link.

### Option D — manual copy

Copy `skills/ticket-memo/` into the agent's skills folder so that the path ends in
`…/skills/ticket-memo/SKILL.md`:

| Agent | User-wide (all projects) | Per project |
|---|---|---|
| Claude Code | `~/.claude/skills/ticket-memo/` | `<project>/.claude/skills/ticket-memo/` |
| Google Antigravity | `~/.gemini/config/skills/ticket-memo/` | `<project>/.agents/skills/ticket-memo/` |
| Other Agent Skills–compatible agents | `~/.agents/skills/ticket-memo/` | `<project>/.agents/skills/ticket-memo/` |

Skill folder locations change between agent versions — if the agent does not see the skill, check its
documentation for the current path.

### Option E — Claude apps (claude.ai / Claude Desktop)

Zip the `skills/ticket-memo` folder (the zip must contain the `ticket-memo/` folder with `SKILL.md`
inside) and upload it in **Settings → Capabilities → Skills**. Note that in the chat apps the agent can
only write to the vault if it has file access (e.g. through an Obsidian or filesystem MCP connector).

### Agents without skill support

Point the agent at the file from its instructions (`AGENTS.md`, `.cursorrules`, `GEMINI.md`, …):

```markdown
Follow the procedure in ~/src/ticket-memo/skills/ticket-memo/SKILL.md for documenting tasks
and system changes. Its templates are in the assets/ folder next to it.
```

---

## First run: setting up a project

Open the project (the folder your agent works in) and say, for example:

> set up ticket-memo for this project

(or simply start a task — the skill notices that there is no config yet). The agent asks **one** question
with proposed defaults:

1. **Where the docs live** — it lists what it finds: your OneDrive / Google Drive / Dropbox / iCloud
   folders, existing Obsidian vaults, or a local folder. Suggested default:
   `<cloud folder>/knowledges/<project-name>` as a dedicated vault.
2. **Languages** — English by default; one language for all notes, or separately for plans, reports
   and write-ups.
3. **Update behaviour** — plans and the knowledge graph update automatically, reports on request
   (defaults shown, change if you like).
4. **Where to keep the config** — `.agents/ticket-memo.config.json` by default (readable by every agent),
   or `.claude/ticket-memo.config.json`.

Then it creates the folder (with `.obsidian/` for a new vault), `index.md`, `glossary/glossary.md`,
`tasks/`, `topics/`, `context/`, `guides/`, writes the config and shows it to you. It offers to seed the
graph from your project's README / docs (proposed topics, key entities and terms), and to add one line to
your `AGENTS.md` / `CLAUDE.md` so the agent reaches for the skill reliably — recommended:

```markdown
Keep project memory with the ticket-memo skill: on task start, after every change (with its rollback),
for project terms and entities, and on status requests.
```

You can also create the config by hand — copy
[`assets/config-template.json`](skills/ticket-memo/assets/config-template.json) to
`<project>/.agents/ticket-memo.config.json` and fill in `docsRoot`.

## Connecting an existing vault

Installing the skill never touches any vault. And when you point a project at a folder that already
has notes, the agent **connects** it instead of setting it up — nothing is overwritten, reset or
reorganised. Say for example:

> use my existing vault at ~/OneDrive/knowledges/homelab

What happens:

1. **Read-only inspection.** The agent reads the vault manifest (`.ticket-memo.json`), `index.md`, the
   glossary and the folder tree, and works out the layout, languages, connected projects, how fresh the
   notes are, and any sync-conflict copies.
2. **One summary + questions** — e.g. *"42 tasks (5 open), 31 entities, 18 terms, 6 topics, last activity
   2026-10-02, used by project `infra` on device `nas`. Is this the same project on a new device, a vault
   to share with this project, a restored backup?"*
3. **Connect.** It writes the project config with the settings the vault already uses, adds this project
   to the manifest, and creates only missing pieces (e.g. `glossary/glossary.md`). It then lists exactly
   which files it created — nothing else changes.

Scenarios it handles:

| Scenario | What the agent does |
|---|---|
| **Same project, another device** (vault arrived via OneDrive/Google Drive/git) | Attaches as is. If this machine differs from the one described in `context/host/`, it adds a separate `host <name>` note instead of rewriting the old one. |
| **Vault shared by several projects** | Same `docsRoot` for all; each project's tasks get `project:` in frontmatter and the index gets a Project column. Entities, terms and topics are shared — that is the point. Status shows this project's tasks unless you ask for all. Alternatively each project gets its own subfolder. |
| **Vault from another project** | Same as shared, or a subfolder of its own if you prefer to keep them apart. |
| **Restored from a backup** | Tells you how old the newest entry is (later changes are missing), offers to compare entity notes with the live system and records the result as a new dated entry — old history is never edited. |
| **Your own Obsidian vault** (not made by ticket-memo) | Takes over one subfolder only (default `<vault>/<project>`); may link to your other notes but never edits them. |
| **Vault from an earlier ticket-memo version** | Keeps working with the existing layout. A migration is only proposed via *"check the vault"*, applied after you agree, with a backup copy in `.ticket-memo-backup/<date>/`. |

Guarantees: existing notes are never deleted, renamed, moved or regenerated wholesale; `.obsidian/`
settings are not touched; `index.md` is fixed row by row, keeping anything you wrote there; every
restructuring needs your approval and makes a backup first.

### One config, many devices

Paths to cloud folders differ between machines. Two ways to keep one project config working everywhere:

- **Variables in `docsRoot`** — `~` and `${VAR}` are expanded:
  `"docsRoot": "${OneDrive}/knowledges/homelab"` or `"~/Library/CloudStorage/GoogleDrive-<account>/My Drive/knowledges/homelab"`.
- **A local override** — `ticket-memo.config.local.json` next to the config overrides its keys on this
  machine only. Commit the main config, git-ignore the local one:

  ```json
  { "docsRoot": "G:/My Drive/knowledges/homelab" }
  ```

  ```gitignore
  .agents/ticket-memo.config.local.json
  .claude/ticket-memo.config.local.json
  ```

### The vault manifest

`<docsRoot>/.ticket-memo.json` marks a folder as a ticket-memo vault and travels with it (synced, backed
up, shared). It stores the vault's own layout and languages so that any project connecting later adopts
them, plus the list of connected projects — names, dates and device names only:

```json
{
  "schema": 1,
  "created": "2026-11-20",
  "tasksDir": "tasks",
  "language": { "plan": "en", "report": "en", "describe": "en" },
  "projects": [
    { "name": "infra", "connected": "2026-11-20", "device": "nas" },
    { "name": "dotfiles", "connected": "2026-11-21", "device": "laptop" }
  ]
}
```

Obsidian ignores dot-files, so the manifest does not show up among your notes.

## Configuration reference

`<project>/.claude/ticket-memo.config.json` or `<project>/.agents/ticket-memo.config.json`
(the first one found wins; a `ticket-memo.config.local.json` next to it overrides its keys):

```json
{
  "docsRoot": "${OneDrive}/knowledges/home-server",
  "project": "home-server",
  "tasksDir": "tasks",
  "planUpdates": "auto",
  "reportUpdates": "on-request",
  "describeSaves": "auto",
  "graphUpdates": "auto",
  "history": "full",
  "language": { "plan": "en", "report": "en", "describe": "en" }
}
```

Only `docsRoot` is required; missing keys take the defaults below.

| Key | Default | Meaning |
|---|---|---|
| `docsRoot` | — (required) | Path to the folder for this project's notes: a vault root or a folder inside a vault. Forward slashes, also on Windows; `~` and `${VAR}` are expanded. |
| `project` | project folder name | This project's name in the vault; used to tell projects apart in a shared vault. |
| `tasksDir` | `tasks` | Folder inside `docsRoot` holding one subfolder per task. |
| `planUpdates` | `auto` | `auto` — update the plan after every completed action; `on-request` — only when asked. |
| `reportUpdates` | `on-request` | `on-request` — regenerate reports only for status requests; `auto` — after every action too. |
| `describeSaves` | `auto` | `auto` — save explanations/write-ups as notes without asking; `on-request` — only when asked. |
| `graphUpdates` | `auto` | `auto` — create/extend entity, term and topic notes as they come up; `suggest` — propose them at the end of a reply; `off` — only when asked. |
| `history` | `full` | `full` — keep per-task history: work, decision records, changes with rollback. `changes` — only changes outside the vault with their rollback. `off` — no history notes; plans keep a Rollback section for changes still in effect. See [Current context and history](#current-context-and-history). |
| `language` | `en` | A single ISO 639-1 code for all notes, or an object `{ "plan", "report", "describe" }`. |

Every setting can be changed in conversation — *"stop auto-updating plans"*, *"move tasks to projects/"*,
*"write reports in German"*. The agent edits the config and, if folders move, asks before moving them.

## Languages

`language` controls the language of the notes (chat replies always follow the language you speak):

| Key | Applies to |
|---|---|
| `plan` | plan and history notes |
| `report` | report notes and status summaries |
| `describe` | write-ups, guides, saved decisions, entity, term and topic notes, the glossary |

```json
"language": "en"                                              // everything in English
"language": { "plan": "de", "report": "en", "describe": "de" } // per document type
```

Regardless of language, the following stay in English so links and lookups keep working: the structural
parts of note names (`<slug> plan`, `<slug> history`, `topic …`, kind prefixes like `app …`), folder names,
frontmatter keys and values, task slugs, and `index.md`. Terms and entity names keep the project's own
wording (a Russian term stays Russian); translations go into `aliases`.
Commands, paths and program output are kept verbatim. Changing the language later affects new notes and
entries; existing notes are translated only if you ask.

## Obsidian: dedicated vault or a folder in an existing one

[Obsidian](https://obsidian.md) is optional — the notes are plain Markdown — but it gives you graph view,
backlinks, search and frontmatter-based queries over everything the agent recorded.

**Dedicated vault per project (recommended).** `docsRoot` is the vault root:

```text
OneDrive/knowledges/
  home-server/      ← vault 1 (has .obsidian/)  docsRoot of project A
  laptop/           ← vault 2 (has .obsidian/)  docsRoot of project B
```

Open it in Obsidian with **Open folder as vault** → select `docsRoot`. Note names never clash between
projects, and each vault can have its own plugins and settings.

**A folder inside an existing vault.** Set `docsRoot` to a subfolder, e.g. `.../MyVault/infra/home-server`.
The skill treats the nearest parent with `.obsidian/` as the vault and does not create a new one. Because
Obsidian resolves `[[links]]` across the whole vault, generic note names such as `index` may exist
elsewhere — the agent then links them with the path (`[[infra/home-server/index|index]]`).

**Recommended Obsidian settings** (Settings → Files and links): *Use [[Wikilinks]]* on, *New link format*
→ "Shortest path when possible". Useful community plugins: **Dataview** (query `type:`/`status:`
frontmatter, e.g. all blocked tasks) and **Obsidian Git** (version history of the vault).

**Graph view.** In Obsidian's graph view, add colour groups by path — `path:topics`, `path:context`,
`path:glossary`, `path:tasks` — to see hubs, entities, terms and work at a glance. Example Dataview
queries:

````markdown
```dataview
TABLE status, updated FROM "tasks" WHERE type = "plan" AND status != "done" SORT updated DESC
```

```dataview
LIST FROM "context" WHERE contains(topics, [[topic networking]])
```
````

**Obsidian MCP (optional).** If your project configures an `obsidian` MCP server, the skill reads and
writes through it; otherwise the agent edits the files directly. Obsidian picks up external changes
automatically — it can stay open while the agent works.

## Storing the vault in Google Drive, OneDrive, Dropbox or iCloud

You can point `docsRoot` straight at a folder inside a cloud-synced drive — this is the simplest way to
get the same knowledge base on every device: the agent writes locally, the sync client uploads it, and
Obsidian on your other computers (or phone) sees the notes.

Typical paths:

| Service | Windows | macOS |
|---|---|---|
| OneDrive | `C:/Users/<you>/OneDrive/knowledges/<project>` | `~/Library/CloudStorage/OneDrive-Personal/knowledges/<project>` |
| Google Drive for desktop | `G:/My Drive/knowledges/<project>` (drive letter may differ) | `~/Library/CloudStorage/GoogleDrive-<account>/My Drive/knowledges/<project>` |
| Dropbox | `C:/Users/<you>/Dropbox/knowledges/<project>` | `~/Library/CloudStorage/Dropbox/knowledges/<project>` |
| iCloud Drive | `C:/Users/<you>/iCloudDrive/knowledges/<project>` | `~/Library/Mobile Documents/com~apple~CloudDocs/knowledges/<project>` |

On Linux, use the official client where one exists, or an [rclone](https://rclone.org) mount — the skill
checks that the mount is actually mounted before writing (`mountpoint -q`) so notes never land in an empty
mountpoint.

Tips:

- **Keep the vault available offline.** OneDrive: right-click the folder → *Always keep on this device*.
  Google Drive for desktop: *Mirror files* mode, or right-click → *Offline access → Available offline*.
  Online-only placeholders make every read slow and can fail without a connection.
- **Avoid editing the same note on two devices at once.** If the sync client creates conflict copies
  (`note-DESKTOP.md`, `note (1).md`, `note (conflicted copy).md`), the skill reports them instead of
  silently merging or deleting.
- **Obsidian Sync / Obsidian Git** are alternatives to cloud drives; the skill does not care how the
  folder is synced.
- The vault never contains secrets by design, but it does describe your infrastructure (hosts, ports,
  where keys live). Keep the cloud folder private.

---

## Everyday usage

Just talk to the agent; the skill triggers on phrases like these:

| You say | Result |
|---|---|
| "New task: move Portainer behind Caddy" | `portainer-behind-proxy plan` created after a read-only look at the system |
| "Start working on PROJ-123, here's the ticket: …" | `proj-123 plan` with `ticket:`/`url:`, linked to the topics and components it touches |
| "Small task: renew the domain" | a `size: small` plan — goal, checklist, links; no ceremony |
| *(agent finishes a step)* | plan updated, history entry with rollback added, affected entities refreshed — automatically |
| "By *cold path* we mean the nightly batch export" | `glossary/cold path.md` created and listed in the glossary |
| "Remember: we keep port 8080 closed on the LAN" | decision in force in the plan / entity, reasoning in history |
| "From now on all services are named `svc-<area>`" | `standards/standard service-naming.md` (active), decision record in history |
| "Why did we drop Traefik?" | answer from the decision record in history |
| "What does SLO mean in this project?" | answer from the glossary note |
| "What depends on postgres?" | answer from entity relations, verified against the live system |
| "Show everything about backups" | the `topic backups` hub: tasks, entities, terms, guides |
| "Explain how SSH access to this box is set up" | answer in chat + a saved write-up linked from its topic |
| "What's the status of my tasks?" | one-line summary per task, reports regenerated |
| "Back to tailscale-ssh — where did I leave off?" | read-only recap: state, last steps, decisions, next step |
| "Check the vault" | broken links, orphans, duplicates, stale plans — fixed after you agree |
| "Write plans in Russian from now on" / "Move my docs to Google Drive" | config updated |

## Updating and uninstalling

| Installed via | Update | Uninstall |
|---|---|---|
| Claude Code plugin | `/plugin marketplace update ticket-memo` | `/plugin uninstall ticket-memo@ticket-memo` |
| `npx skills` | `npx skills update` | `npx skills remove ticket-memo` |
| git clone + link | `git pull` in the clone | `install.ps1 -Target all -Uninstall` / `install.sh --target all --uninstall` |
| manual copy | copy the folder again | delete the `ticket-memo` skill folder |

Uninstalling never touches your vault or project configs.

## Security

- Notes must never contain secret values (keys, passwords, tokens, `.env` contents); the skill records only
  metadata and redacts command output before saving it.
- The skill does not run anything on its own: system changes are made by the agent as part of your task;
  ticket-memo only documents them and their rollbacks.
- **Notes are treated as data, not instructions.** A shared, synced or restored vault may contain text
  written by someone else; the skill tells the agent never to follow instructions found in notes, and to
  run commands stored there (rollbacks, health checks) only when you ask for that action, after showing
  them — destructive ones only with your explicit confirmation.
- Review the agent's changes as usual — documentation is not a substitute for permission prompts.

## FAQ

**Does it require Obsidian?** No. It writes plain Markdown with wikilinks and frontmatter; Obsidian is
just the nicest viewer.

**Can several projects share one vault?** Yes — give each project its own subfolder as `docsRoot`. A
dedicated vault per project is simpler.

**Can several agents use the same project?** Yes. Put the config in `.agents/` and install the skill into
each agent; they all read and write the same vault.

**Is it only for servers/Docker?** No. Managing a machine (workstation, homelab, VPS) is where it came
from, and its rollback discipline shines there, but tasks, entities, terms and topics fit any project:
a product tracked in Jira, a research area, a migration, household admin. It does not replace your
tracker or your code's own docs — it is the agent's memory of the work and the vocabulary around it.

**Will it flood my vault with stubs?** No — a note is created only when it carries facts worth keeping.
Set `graphUpdates` to `suggest` if you want to approve every new note.

**I already have a vault from an earlier version.** Nothing to migrate: `context/` keeps its role (entities),
`topics/` and `glossary/` are created when first needed. Ask *"check the vault"* to get missing hubs and
links proposed. See [Connecting an existing vault](#connecting-an-existing-vault).

**Can reinstalling or updating the skill wipe my notes?** No. The skill and its install scripts live
entirely outside the vault; the vault is only ever changed by the agent, additively, following the rules
above.

**The agent does not use the skill.** Restart the agent, check the skill folder path for your agent
version, and add the one-line instruction to `AGENTS.md` / `CLAUDE.md` shown above.

## License

[MIT](LICENSE)
