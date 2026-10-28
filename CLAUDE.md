---
title: CLAUDE.md — skillsmith
created: 2026-10-27
updated: 2026-10-28
---

# skillsmith

Fork of rebelytics/one-skill-to-rule-them-all (upstream skill `task-observer`): the `skillsmith` skill
(Markdown plus python3/bash helpers). No build step, no dependencies.

## Layout
- `SKILL.md`: skill core; frontmatter `core_max_lines` is its line ceiling
- `references/*.md`: loaded on demand; ceilings in `references/ceilings.txt`
- `scripts/`: shipped in the bundle; `validate-skill-bundle.py` is the gate
- `.claude-plugin/plugin.json`: canonical version

## Checks (run before every commit)
```bash
python3 scripts/validate-skill-bundle.py --repo-only .   # manifests, README list shape
python3 scripts/validate-skill-bundle.py --selftest      # fixtures
d=$(mktemp -d)/skillsmith && mkdir -p "$d" && cp SKILL.md "$d" && cp -r references scripts "$d" && python3 scripts/validate-skill-bundle.py "$d"
```
Never run the skill checks on the repo root: the name and manifest checks fail there by design.

## Gotchas
- Version bump: `.claude-plugin/plugin.json` and `SKILL.md` frontmatter `version` together; `marketplace.json`, README and USER-GUIDE state no version. The `template of vX.Y.Z` stamp in `references/environments.md` moves only when the activation block's text changes.
- Ceilings: the bundle check prints `lines / ceiling` per file and fails over a ceiling. Assume no free lines.
- Reference over its ceiling: trim, or raise it in `ceilings.txt` with a dated reason. A file with more than 12 `Load triggers:` cannot be raised; split it by episode (the check's `note:` line names such files).
- `SKILL.md` over `core_max_lines`: move text to a reference first; a raise needs the commit/PR to say what pays for the lines.
- A trim of 4+ lines also fails: lower that ceiling to the new count in the same commit.
- The activation trigger (a multi-step task: three or more tool calls, a file write, or a plan) is stated in four places: the `SKILL.md` description, the activation block and the SessionStart hook message in `references/environments.md`, and the stop hook's `MIN_TOOL_USES` and write count there. Three more restate it: `SKILL.md` "When to Observe", and in `references/environments.md` the tier-2 preferences template and the "Word the trigger mechanically" paragraph (`references/signals.md` points at `SKILL.md`). Change them together.
- A core pointer `references/x.md` ("Heading") loads only that section through `scripts/ref-section.sh`: from the heading to the next heading of its level or higher. A bold run-in label is not a boundary. The bundle check runs the script on every such pointer, so a renamed, duplicated or bold-only target heading fails the gate. No check reads what the section holds: before turning a whole-file pointer into a section pointer, confirm the section carries every value and rule the core sentence sends the agent for; text above the heading (`starter-principles.md`'s version line) or in a sibling section is not loaded.
- The archival sweep and id derivation exist twice: `scripts/new-observation.sh` and the `SKILL.md` id snippet (kept for installs that ship `SKILL.md` alone). Change both: the bundle check compares the sweep's awk program, its `mv` call and the `n_files`/`seen`/`floor`/`ids`/`hi`/`next_id` lines (comments, indentation and the core's `$ 2` spacing aside), not the guard or message lines. Header values reach awk quoted or with a CRLF `\r`, so readers strip `["\047\r]` before comparing, and run under `LC_ALL=C`: macOS awk in a UTF-8 locale does not match the byte-escaped BOM `\357\273\277`.
- Contribution rules live in `CONTRIBUTING.md`: rewording keeps checkpoints, assertions and mandatory writes; new behaviour is declared; no runtime URL fetches; no real client or project names.
- Publishing a GitHub release triggers `.github/workflows/release-bundle.yml`, which builds `skillsmith.skill`.
