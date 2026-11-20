# Setup: connecting a project to a new vault (first run)

Read this when the project has no `ticket-memo.config.json` yet, or when the user
asks to set up ticket-memo for a project. If the folder the user picks already
holds notes, switch to `references/connect-existing-vault.md` — an existing vault
is connected, never set up from scratch. Config keys are described in
`references/configuration.md`.

## Step 1 — ask once, with defaults

Ask everything in **one message** with proposed defaults, so the user can answer
"defaults are fine" or change single items:

1. **Where the docs live (`docsRoot`).** Offer concrete candidates found on the
   machine instead of asking an open question:
   - cloud-synced folders, if present — Windows: `$env:OneDrive`,
     `$env:OneDriveConsumer`, `$env:OneDriveCommercial`, Google Drive for desktop
     (`G:/My Drive` or another drive letter showing "My Drive"), `~/Dropbox`,
     `~/iCloudDrive`; macOS: `~/Library/CloudStorage/OneDrive-*`,
     `~/Library/CloudStorage/GoogleDrive-*/My Drive`, `~/Library/CloudStorage/Dropbox`,
     `~/Library/Mobile Documents/com~apple~CloudDocs`; Linux: rclone mounts;
   - existing Obsidian vaults (folders containing `.obsidian/`) under those
     locations and the home folder;
   - a local default such as `~/knowledge/<project>`.

   Suggest `<location>/knowledges/<project-name>` as a **dedicated vault**. If the
   user prefers an **existing vault**, propose a subfolder in it
   (`<vault>/<project-name>`).

   Mark candidates that already hold ticket-memo notes (a `.ticket-memo.json`
   manifest, or an `index.md` with `type: index` plus `tasks/` or `context/`).
   **If the chosen folder is not empty, stop here and follow
   `references/connect-existing-vault.md`.**
2. **Languages.** Default English for everything. Ask whether to use one
   language for all notes or set `plan`, `report` and `describe` separately.
   If the conversation is not in English, mention that as an option
   ("notes in English, or in <conversation language>?").
3. **Update behaviour.** Show the defaults (`planUpdates: auto`,
   `reportUpdates: on-request`, `describeSaves: auto`, `graphUpdates: auto`,
   `history: full`) in
   one line; change only if the user asks.
4. **Where to store the config.** Default `.agents/ticket-memo.config.json`
   (agent-neutral). Use `.claude/ticket-memo.config.json` if the project already
   keeps its agent settings there or the user asks for it. Never create both.

## Step 2 — create

5. Create `docsRoot` if missing. For a dedicated vault, also create an empty
   `.obsidian/` folder so Obsidian recognises it (Obsidian fills it on first
   open). For a subfolder of an existing vault, do not create `.obsidian/`.
6. Create the skeleton — only what is missing, never overwrite existing notes:
   `index.md` and `glossary/glossary.md` from `assets/index-template.md`,
   `<tasksDir>/`, `topics/`, `standards/`, `context/`, `guides/`. Entity kind folders and
   `<tasksDir>/general/` are
   created when their first note is.
7. Write the config file from `assets/config-template.json` (UTF-8, no BOM,
   2-space indent) and show it to the user. Write `.ticket-memo.json` into
   `docsRoot` from `assets/vault-manifest-template.json` with this project as the
   first entry. If `docsRoot` is machine-specific and the project is under git,
   offer to put it into `ticket-memo.config.local.json` and add that file to
   `.gitignore`.

## Step 3 — hand over

8. Tell the user how to open it: Obsidian → "Open folder as vault" → `docsRoot`
   (or the existing vault, for a subfolder). Obsidian is optional — the notes are
   plain Markdown.
9. Offer (do not do it unasked) to add one line to the project's agent
   instructions (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, whichever exists), e.g.
   "Keep project memory with the ticket-memo skill: on task start, after every
   change (with its rollback), for project terms and entities, and on status
   requests."
10. Offer to **seed the graph** from what already exists: the project's README,
    agent instructions or docs — propose the topics, key entities and terms found
    there and create them when the user agrees (following the linking rules in
    `SKILL.md`).

Then continue with what the user originally asked (usually a new task).
