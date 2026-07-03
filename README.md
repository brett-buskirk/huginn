# huginn

A little CLI for running a personal GitHub **estate** — a folder full of repos — from one place.
Named for Odin's raven that flies the realms and reports back what it sees.

`huginn` gives you an at-a-glance dashboard of every repo, audits them against a shared convention,
scaffolds new repos to that standard, and handles the routine chores (sync, labels, open PRs).

> **Note:** built for my own workflow, but **config-driven and self-contained** — `huginn init`
> detects sensible defaults (your `gh` login, git identity, `~/github-repos`), and it ships default
> guardrail templates (`templates/`) so it works out of the box. Point `HUGINN_CONVENTIONS` at your
> own `repo-conventions` repo to override the built-in standard. See the [Roadmap](ROADMAP.md) for
> what's next.

## Install

Requirements: `bash`, `git`, [`gh`](https://cli.github.com) (authenticated), `jq`.

```bash
git clone git@github.com:brett-buskirk/huginn.git ~/github-repos/huginn
ln -s ~/github-repos/huginn/huginn ~/.local/bin/huginn   # ~/.local/bin must be on your PATH
huginn init                                              # write a config with detected defaults
```

`huginn` manages the repos in **`$HUGINN_ROOT`** (default `~/github-repos`).

## Commands

```
create
  new <name> [opts]      scaffold a new repo to the full standard
inspect
  status [--fetch]       at-a-glance dashboard (branch · dirty · ahead/behind · flags)
  prs                    open PRs across the estate
  branches [--prune]     stray local branches; prune merged ones
  doctor [repo] [--fix]  audit repos vs your conventions; --fix the safe gaps
operate
  sync                   pull every repo to its default branch (ff-only, skips dirty)
  apply <repo> <scope>   apply the label taxonomy to a repo (web|k8s|infra)
reference / navigate
  conventions [topic]    look up the standard (labels · ruleset · doc)
  open <repo> [page]     open a repo (or prs/settings/rules) on GitHub
  help                   this menu
```

Run **`huginn <command> help`** for details and options on any command.

## How it works

- **Fast and local by default** — git operations only. Network (`gh`) is used only where noted
  (`doctor`, `prs`, `new`, `apply`).
- **Conventions, with a fallback** — huginn ships default guardrail templates in `templates/`, so
  `new`, `apply`, and `conventions` work out of the box. Point `HUGINN_CONVENTIONS` at your own
  `repo-conventions` repo (`labels.json`, `ruleset.json`, `apply-conventions.sh`) to override them.
- **Respects `NO_COLOR`** and non-TTY output.

## Configuration

Settings resolve **environment variable → config file → smart default**. Run `huginn init` to write
a config with detected defaults, then edit it. Config file:
`${XDG_CONFIG_HOME:-~/.config}/huginn/config` (override with `HUGINN_CONFIG`).

| Key / env var | Default | Purpose |
|---|---|---|
| `HUGINN_OWNER` | your `gh` login | GitHub owner of the estate repos |
| `HUGINN_ROOT` | `~/github-repos` | directory of repos to manage |
| `HUGINN_EMAIL` | your git email | commit email for `new` / `doctor --fix` |
| `HUGINN_NAME` | your git name | committer name |
| `HUGINN_FAMILY` | _(none)_ | space-separated repos to exclude from `sync`/`doctor` |
| `HUGINN_CONVENTIONS` | `repo-conventions` | dir under `HUGINN_ROOT` with `labels.json`/`ruleset.json` |

Commands that use conventions (`new`, `apply`, `conventions`, `doctor --fix`) fall back to the
bundled `templates/` when no conventions repo is present, so they work out of the box.

## Backstory

huginn is the estate-management tool behind the "GitHub AI Overlord" — the orchestrating agent in a
piece I wrote on running AI coding agents with a chain of command:
[*I Built an Org Chart for My AI Agents*](https://www.linkedin.com/pulse/i-built-org-chart-my-ai-agents-brett-buskirk-h0iic/).

## License

[MIT](LICENSE) © 2026 Brett Buskirk
