# Changelog

All notable changes to this skill. Versions follow [Semantic Versioning](https://semver.org/).

## [1.1.0] — 2026-11-23

### Added
- Task statuses beyond `in-progress | blocked | done`: the default set is now
  `open | to-do | research | in-progress | review | blocked | done`, each with a defined meaning
  ("Task statuses" in `references/configuration.md`).
- `statuses` setting to replace the list with a tracker's workflow (`done` is always kept).

### Changed
- Statuses are kebab-case in frontmatter and Title Case in the index, reports and topic hubs.
- "Cloud-synced folders" rules and the status meanings moved to `references/configuration.md` to keep
  `SKILL.md` under 500 lines.
- Plans' status is updated in Mode 2 when the task moves to another stage.
- Vault check reports plan statuses outside the configured list and treats every status but `done`
  as active when looking for stale plans.

## [1.0.0] — 2026-11-20

### Added
- First public release.
- Knowledge graph beyond tasks: entity notes with typed relations (`context/<kind>/`), a project
  glossary (`glossary/`), topic hubs (`topics/`), and linking rules (search before create, link the
  first mention, no orphans, aliases for synonyms).
- Works for any project, not only machine administration: tracker tickets (`ticket:`/`url:`), small
  and full tasks (`size:`), open-ended entity kinds.
- Mode 0: guided project setup — picks the docs folder (dedicated vault, folder in an existing vault,
  cloud-synced folder), languages and update behaviour, writes `ticket-memo.config.json` and the vault
  skeleton, offers to seed topics and terms from the project's docs.
- Mode 6 lookup over glossary and relations, Mode 8 graph growth, Mode 9 vault upkeep.
- `graphUpdates` setting (`auto` / `suggest` / `off`).
- `language` accepts one code for all notes or a per-type object; English by default.
- Rules for cloud-synced vaults (OneDrive, Google Drive, Dropbox, iCloud).
- Mode 0A: connecting an existing vault (another device, another or shared project, restored backup,
  foreign Obsidian vault) — read-only inspection, adopts the vault's settings, never overwrites or resets.
- Vault manifest `.ticket-memo.json`; `project` setting and `project:` frontmatter for shared vaults;
  `~`/`${VAR}` in `docsRoot`; machine-specific `ticket-memo.config.local.json` override.
- "Existing content is never reset" rule; backups in `.ticket-memo-backup/<date>/` before any restructuring.
- Current context kept apart from history: plans carry "Decisions in force", project rules and final
  standards live in `standards/` (active / superseded), history notes hold the chronology and decision
  records; `general history` for decisions outside any task. Writing and reading history is described in
  `references/history.md`.
- `history` setting: `full` / `changes` / `off`.
- Templates: standard, entity, term, topic, index, config, vault manifest.
- Progressive disclosure: `SKILL.md` holds only the daily rules; setup, connecting an existing vault,
  configuration and vault upkeep live in `references/` and are read only when needed.
- Claude Code plugin/marketplace manifests and install scripts for other agents.
