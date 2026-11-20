---
type: entity
kind: <kind folder: host | apps | docker | services | components | repos | people | access | ...>
status: active
updated: <YYYY-MM-DD>
topics: ["[[topic <name>]]"]
aliases: []
tags: []
---

# <kind> <name>

<1–2 lines: what this is and why it matters to the project.>

## Facts

<What is known and worth keeping. Use the sub-points that fit, drop the rest.>

- Version / identifier: <x.y, ID, URL>
- Installed / created via: <method>; config and data: <paths, volumes>
- Runs as / lives in: <unit, container, cluster, account, team>
- Endpoints: <ports, URLs>
- Owner / contact: <role or [[person …]]>

## Relations

<One line per relation, typed. This is what lets the graph answer "what breaks if X goes down".>

- runs on [[<entity>]]
- depends on [[<entity>]]
- used by [[<entity>]]
- part of [[<entity>]] · replaces [[<entity>]]

## Operations

<For things that run. Drop the section otherwise.>

- Health check: <command>
- Update: <command / steps>
- Remove: <command / steps, what data is lost>

## Access

<For anything with credentials. NEVER the secret value.>

- What it grants: <scope>
- Stored at: <path or store>, permissions <600>
- Used by: <service / agent / role>
- Expiry and rotation: <date, steps>

## Notes and gotchas

- <YYYY-MM-DD> — <something learned the hard way>

## Related tasks

- [[<slug> plan]] — <what it changed here>
