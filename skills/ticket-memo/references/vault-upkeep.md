# Vault upkeep and migration (on request)

Read this when the user asks to tidy or check the vault ("check the vault",
"check the links", "clean up the vault"), or agrees to migrate a vault from an
earlier layout. Never run it unasked.

## Check

Find and list:

- broken wikilinks;
- orphan notes — no link to a hub and no `topics:`;
- duplicate notes for the same thing (by file name and `aliases`);
- terms missing from `glossary/glossary.md`, topics missing from `index.md`;
- plans whose `updated:` is old while the task is active (any status but `done`);
- plan statuses outside the configured `statuses` (including the Title Case or
  tracker spelling, such as `In Progress`), with the kebab-case value to use;
- current and history mixed: chronology ("was X, became Y") in plans, entities,
  topics or standards; a rule or decision in force that exists only in a history
  entry; "Decisions in force" lines without a link to their record (when history
  is kept); superseded standards without `superseded_by:`;
- sync-conflict copies (`<name>-<DEVICE>.md`, `<name> (1).md`,
  `<name> (conflicted copy).md`);
- a missing or outdated `.ticket-memo.json` (this project not listed, `tasksDir`
  or languages that no longer match);
- layout left over from an earlier version (for example no `topics/` or
  `glossary/`, entity notes without `type: entity`, task notes without
  `topics:`).

## Report and fix

1. Report the findings as a short list with a proposed fix per item. Change
   nothing yet.
2. Apply only what the user agrees to.
3. Before any rename, merge or migration, copy the affected notes to
   `<docsRoot>/.ticket-memo-backup/<YYYY-MM-DD>/` (same relative paths).
4. Merging duplicates: keep one note, move the content over, add the other name to
   `aliases`, rewrite the links that pointed at the removed note.
5. After renames, fix every wikilink that points at the old name.
6. Report the list of changed files and where the backup is.

## Migrating an earlier layout

Additive first: add missing frontmatter keys (`type`, `topics`, `kind`), create
`topics/` hubs for clear clusters and `glossary/` entries for terms found in
plans' Shorthand sections, and link them. Old `<slug> decisions` notes stay where they
are (they are history); propose a "Decisions in force" section in the plan and
`standards/` notes for the rules they established. Renaming or moving existing notes is a
separate step that the user approves explicitly, with the backup above.
