---
description: Create one epic from .idea and generate its tasks, mid-project
argument-hint: [idea or epic name, or: list | accept <name> | reject <name>]
allowed-tools: Skill, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, WebSearch, WebFetch
---

Invoke the `epic` skill and follow it in full. Target: **$ARGUMENTS**

- A raw idea not yet in `.idea/`: the skill captures it via `brainstorm` first, then builds the epic.
- `list` / `accept <name>` / `reject <name>` operate on epics the `project-manager` agent suggested.
- Empty: list promising ideas and suggested epics, and ask which to work on.
- This adds to a plan. If the request changes the plan's shape, say so and offer `/shape`.
