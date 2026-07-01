# huginn

A little CLI for running a personal GitHub **estate** — a folder full of repos — from one place.
Named for Odin's raven that flies the realms and reports back what it sees.

`huginn` gives you an at-a-glance dashboard of every repo, audits them against a shared convention,
scaffolds new repos to that standard, and handles the routine chores (sync, labels, open PRs).

> **Note:** built for my own workflow, but **config-driven** — `huginn init` detects sensible
> defaults (your `gh` login, git identity, `~/github-repos`). It works best alongside a
> `repo-conventions` repo (the standard it audits and applies against) and degrades gracefully
> without one. See the [Roadmap](ROADMAP.md) for what's left before it's truly turnkey.

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
- **The standard lives in `$HUGINN_ROOT/repo-conventions`** — `labels.json`, `ruleset.json`, and
  `apply-conventions.sh`. `doctor` audits against it; `apply`/`new` apply it; `conventions` reads it.
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

Commands that need the conventions repo (`apply`, `conventions`, parts of `doctor`/`new`) degrade
gracefully when it's absent.

## License

[MIT](LICENSE) © 2026 Brett Buskirk
