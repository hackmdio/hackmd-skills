# hackmd-skills

Official [HackMD](https://hackmd.io) agent skills for Claude Code, Cursor, Codex, and compatible harnesses.

Each subdirectory is a self-contained skill (with `SKILL.md`).

## Skills

| Skill | Description |
|-------|-------------|
| [`agentic-work-log/`](agentic-work-log/) | Incrementally sync cross-agent session prompts into a HackMD work log (append or new note; supports scheduling). |
| [`push-to-hackmd/`](push-to-hackmd/) | Publish or back up plans, Markdown, HTML, or files to HackMD (personal or team workspace). |
| [`visualize-hmd/`](visualize-hmd/) | Turn plans and trade-offs into HTML/CSS visualizations and publish to HackMD. |

The skills above build on `hackmd-cli`. Its official skill lives in the CLI repository, so it stays in sync with each CLI release:

| Skill | Description |
|-------|-------------|
| [`hackmd-cli`](https://github.com/hackmdio/hackmd-cli/tree/develop/hackmd-cli) | Manage notes, folders, and any other HackMD v1 API operation with `hackmd-cli`. |

## Installation

Install with the [`skills`](https://github.com/vercel-labs/skills) CLI. It asks which skills and which agents to install to.

```bash
# Skills from this repository
npx skills add hackmdio/hackmd-skills

# The hackmd-cli skill
npx skills add hackmdio/hackmd-cli
```

To install one skill without prompts, name it and add `-g` (all projects) and `-y`:

```bash
npx skills add hackmdio/hackmd-skills --skill push-to-hackmd -g -y
```

To install by hand instead, copy a skill folder into your agent's skills directory, such as `~/.claude/skills/` for Claude Code or `~/.cursor/skills/` for Cursor.

## Requirements

- [hackmd-cli](https://www.npmjs.com/package/@hackmd/hackmd-cli) (`hackmd-cli login`) for most publish flows
- **Python 3** for `agentic-work-log` collection and `visualize-hmd` build script

## Repository layout

```
hackmd-skills/
├── README.md
├── shared/                  # safe-sync, resolve-note, API reference
│   ├── README.md
│   ├── references/api.md
│   └── scripts/
├── agentic-work-log/
├── push-to-hackmd/
└── visualize-hmd/
```

Cross-skill contracts (anti-clobber updates, destination policy): [shared/README.md](shared/README.md).

## Migrating from `visualize-hmd` standalone repo

The `visualize-hmd` skill previously lived at [hackmd-product/visualize-hmd](https://github.com/hackmd-product/visualize-hmd). Use `hackmd-skills/visualize-hmd/` going forward; the standalone repo can be archived after you update local installs.

Maintained by the HackMD product team.
