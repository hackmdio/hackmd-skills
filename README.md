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

```bash
npx skills add hackmdio/hackmd-skills
npx skills add hackmdio/hackmd-cli
```

[`npx skills`](https://github.com/vercel-labs/skills) asks which skills to install and which agents to install them for. The second command installs the `hackmd-cli` skill.

### Other installation methods

<details>
<summary><b>GitHub CLI</b></summary>

```bash
gh skill install hackmdio/hackmd-skills push-to-hackmd --scope user
gh skill install hackmdio/hackmd-cli hackmd-cli --scope user
```

</details>

<details>
<summary><b>Manual copy</b></summary>

Copy a skill folder into your agent's skills directory, such as `~/.claude/skills/` for Claude Code or `~/.cursor/skills/` for Cursor.

```bash
git clone https://github.com/hackmdio/hackmd-skills.git /tmp/hackmd-skills
cp -R /tmp/hackmd-skills/push-to-hackmd ~/.claude/skills/
```

</details>

## Requirements

- [hackmd-cli](https://www.npmjs.com/package/@hackmd/hackmd-cli) (`hackmd-cli login`) for most publish flows
- **Python 3** for `agentic-work-log` collection and `visualize-hmd` build script

## Repository layout

```
hackmd-skills/
├── README.md
├── shared/                  # source for files used by several skills
│   ├── references/          # contract.md, api.md
│   └── scripts/             # safe-sync.sh, resolve-note.sh
├── scripts/sync-shared.sh   # copies shared/ files into each skill
├── agentic-work-log/
├── push-to-hackmd/
└── visualize-hmd/
```

Each skill is self-contained, so it works after `npx skills add` or `gh skill install`. Edit shared files in `shared/`, then run `scripts/sync-shared.sh`; see [shared/README.md](shared/README.md). The cross-skill contract (anti-clobber updates, destination policy) is [shared/references/contract.md](shared/references/contract.md).

## Migrating from `visualize-hmd` standalone repo

The `visualize-hmd` skill previously lived at [hackmd-product/visualize-hmd](https://github.com/hackmd-product/visualize-hmd). Use `hackmd-skills/visualize-hmd/` going forward; the standalone repo can be archived after you update local installs.

Maintained by the HackMD product team.
