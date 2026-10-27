---
title: CLAUDE.md — skillsmith
created: 2026-10-27
updated: 2026-10-27
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
- A core pointer `references/x.md` ("Heading") loads only that section through `scripts/ref-section.sh`: from the heading to the next heading of its level or higher. A bold run-in label is not a boundary. The bundle check runs the script on every such pointer, so a renamed, duplicated or bold-only target heading fails the gate.
- Contribution rules live in `CONTRIBUTING.md`: rewording keeps checkpoints, assertions and mandatory writes; new behaviour is declared; no runtime URL fetches; no real client or project names.
- Publishing a GitHub release triggers `.github/workflows/release-bundle.yml`, which builds `skillsmith.skill`.
