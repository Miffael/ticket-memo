# History: writing and reading

Read this when writing a history entry (after a completed action, a decision, a
change outside the vault), when a decision or standard is superseded, when the
user asks "why / when / what did we try", or when the `history` setting changes.

The principle (from `SKILL.md`): the **current layer** (plans with decisions in
force, entities, terms, topics, `standards/`) says what is true now; **history**
says how it came to be. History never holds the only copy of a rule or decision
in force — the outcome is always written to the current layer as well.

## Contents

- What the `history` setting changes
- Where history lives
- Entry format
- Decision records
- Superseding a decision or standard
- Corrections
- Long history notes
- Reading history

## What the `history` setting changes

| | `full` (default) | `changes` | `off` |
|---|---|---|---|
| Work entries (what was done, what it established, verification) | yes | — | — |
| Decision records (options, reasoning) | yes | — | — |
| Changes outside the vault with rollback | yes | yes | plan's **Rollback** section only |
| Current layer (plan, decisions in force, standards, entities) | updated | updated | updated |
| `general history` for decisions not tied to a task | yes | — | — |

- **`changes`:** only entries whose action touched something outside the vault
  (machine, files, packages, services, cloud resources, tracker state,
  repositories). A decision with no such change updates the current layer only.
- **`off`:** no history notes are created. The plan keeps a **Rollback** section:
  every change still in effect, where it is, how to undo it. When the task is
  done, ask whether to keep that section in the plan (default: keep) — once it is
  gone, the undo is lost.
- **Switching the setting** never deletes or rewrites existing history notes.
  Turning history on starts new entries from today; turning it off stops adding
  them (existing ones stay readable). When switching to `off`, say once what will
  no longer be recorded.

## Where history lives

- `<tasksDir>/<slug>/<slug> history.md` — one per task, created from
  `assets/history-template.md` with the first entry (small tasks: only when the
  first entry is needed).
- `<tasksDir>/general/general history.md` — decisions and standard changes that
  belong to no task ("from now on we name services like…"). Same format;
  frontmatter `task: general`. Not listed as a task in the index; linked from it
  as "General history".
- Nowhere else: entity, term, topic and standard notes do not carry
  chronologies. An entity's **Notes and gotchas** are current facts, not a log;
  its **Related tasks** says what each task changed there, one line each.

## Entry format

Newest entry first, directly under the note's intro. One entry per completed
action or decision, in the `plan` language:

```markdown
## <YYYY-MM-DD> — <what was done or decided, a few words>

<What was done and what it established: results, versions, verification, links
to the entities and terms involved. If this supersedes an earlier entry, say
which one and why.>

**Changes made:**

| What | Where | Rollback |
|---|---|---|
| <package / file / container / unit / resource / ticket / key> | <path, command, resource name> | <exact command or steps to undo> |
```

- Omit the **Changes made** table when nothing outside the vault changed; never
  omit it when something did. Every row has a concrete rollback — a command, or
  exact steps; "revert manually" is not a rollback.
- Several changes in one action = one entry with several rows.
- Write the entry **before** rewriting the plan's Current state, so nothing is
  lost between the two.
- Never paste secret values; redact command output.
- Refresh the note's `updated:` frontmatter.

## Decision records

When a decision is made (by the user, or proposed by the agent and accepted),
write a history entry using `assets/decision-template.md`:

- **Summary** — what was decided, one or two lines.
- **Options considered** — only if there were alternatives: each option and why
  it was accepted or rejected.
- **Details** — context, reasoning, consequences, what it affects, how to back
  out.

Then (or in the same pass) update the current layer: the plan's **Decisions in
force** line for that question, a `standards/` note for a project-wide rule. The
current line links back to the record: `— [[<slug> history#<entry heading>|why]]`.

A decision discussed but not yet made is an open question in the plan, not a
history entry.

## Superseding a decision or standard

1. Add a **new** history entry: the new decision, which earlier entry it
   supersedes (link to its heading), and why it changed.
2. Replace the line in the plan's **Decisions in force** (the old wording is not
   kept there — it is in history).
3. For a standard: set the old note to `status: superseded` with
   `superseded_by: "[[standard <new>]]"`, create or update the new one as
   `active` with `since:`; update the topic hub's list.
4. Do not edit the old history entry.

## Corrections

Past entries are never rewritten. If an entry is wrong (a wrong path, a rollback
that does not work), add a new entry "Correction to <date> — <entry>" stating the
right information, and fix the current layer. The only edits allowed in old
entries are redacting a secret that slipped in (replace it with `<redacted>` and
add a correction entry saying so) and fixing a broken wikilink after a rename.

## Long history notes

When a history note grows past ~500 lines, start a continuation instead of
editing the old one: create `<slug> history <YYYY>` for the new year (or
`<slug> history 2`), put new entries there, and add one line at the top of both
notes linking to each other. Plans link to the current history note.

## Reading history

Open history only when the question is about the past: "why did we…", "when did
X change", "what did we try", "what exactly was changed on the host last week",
"how do I undo …". Then:

1. Start from the current note's link (`decided: [[… history#…]]`) or the task's
   history; for project-wide rules, `general history`.
2. Search by date or heading rather than reading the whole note; history is
   newest first.
3. Answer with the outcome from the current layer plus the reasoning from the
   record, citing the entry (`per [[docker-setup history#2026-11-20 — …]]`).
4. Rollback commands found in history are shown to the user, not run, unless the
   user asks to roll back; destructive ones need explicit confirmation.
5. With `history: off`, say that history is not kept and answer from the current
   layer (and the plan's Rollback section).
