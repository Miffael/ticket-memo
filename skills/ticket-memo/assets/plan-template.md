---
type: plan
task: <slug>
status: in-progress     # one of the configured statuses: open | to-do | research | in-progress | review | blocked | done
size: full              # small | full
ticket:                 # optional tracker key, e.g. PROJ-123
url:                    # optional tracker link
topics: ["[[topic <name>]]"]
updated: <YYYY-MM-DD>
tags: []
---

# <slug>: <Short title>

Last updated: <YYYY-MM-DD>. History: [[<slug> history]]

## Goal

<What this task is about and what "done" looks like. 2-4 lines.>

## Current state

<3-6 lines: what works, what does not, the single biggest blocker right now.
No chronology — that lives in history.>

## What is left

- [ ] <Remaining item, with enough detail to act on>
- [ ] <Remaining item>

## Decisions in force

<The latest answer to each settled question, one line each. Only what holds now — superseded
answers live in history. Link each line to its decision record.>

- <Question>: <decision> — [[<slug> history#<YYYY-MM-DD> — Decision: <title>|why]]
- Follows: [[standard <name>]]

## Shorthand

<Every short code used in this task's notes. One line each: code, one-sentence
meaning, source note. Drop the section if the task uses no codes.>

- **<CODE>** — <one-sentence meaning> — [[<note>]]

## Open questions

- <Unresolved question or dependency, and who or what it waits on>

## Risks

| Risk | Mitigation |
|---|---|
| <Live risk only, e.g. "may cut off remote access over Tailscale"> | <How it is handled / rollback> |

## Rollback

<Only when history is off (history: off). Every change still in effect and how to undo it.
Drop the section otherwise — rollbacks then live in history.>

| What | Where | Rollback |
|---|---|---|
| <change> | <path / resource> | <exact undo> |

## Links

- Topics: [[topic <name>]]
- Entities: [[<kind> <name>]], [[<kind> <name>]]
- Terms: [[<Term>]]
- Standards: [[standard <name>]]
- Ticket: <tracker link, if any>
- Config / paths: <files, compose projects, units this task touches>
- Endpoints: <ports, URLs, tailnet names>
- Upstream docs: <links>
- Task notes: [[<slug> <topic>]] — <what it holds>
