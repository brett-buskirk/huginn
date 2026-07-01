# huginn

A little CLI for running a personal GitHub **estate** — a folder full of repos — from one place.
Named for Odin's raven that flies the realms and reports back what it sees.

`huginn` gives you an at-a-glance dashboard of every repo, audits them against a shared convention,
scaffolds new repos to that standard, and handles the routine chores (sync, labels, open PRs).

> **Note:** this is built for my own workflow. It expects a sibling `repo-conventions/` repo (the
> standard it audits and applies against) and is currently wired to a single GitHub owner. Making it
> config-driven and reusable by others is on the [Roadmap](ROADMAP.md).

## Install

Requirements: `bash`, `git`, [`gh`](https://cli.github.com) (authenticated), `jq`.

```bash
git clone git@github.com:brett-buskirk/huginn.git ~/github-repos/huginn
ln -s ~/github-repos/huginn/huginn ~/.local/bin/huginn   # ~/.local/bin must be on your PATH
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
- **The standard lives in `$HUGINN_ROOT/repo-conventions`** — `labels.json`, `ruleset.json`, and
  `apply-conventions.sh`. `doctor` audits against it; `apply`/`new` apply it; `conventions` reads it.
- **Respects `NO_COLOR`** and non-TTY output.

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `HUGINN_ROOT` | `~/github-repos` | the directory of repos to manage |

## License

[MIT](LICENSE) © 2026 Brett Buskirk
