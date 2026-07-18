# huginn cheat sheet

Quick reference for every command, option, and behavior. `huginn` is the **estate CLI** — a dashboard,
auditor, and scaffolder for a whole folder of repos (**`$HUGINN_ROOT`**, default `~/github-repos`),
enumerated straight off disk. It's config-driven: it shares the estate config and skips exempt repos
(`exemptions.json` + `$HUGINN_FAMILY`).

For the narrative version see the [README](README.md); for per-command detail in the terminal, run
`huginn <command> help`.

---

## At a glance

| Command | Aliases | What it does | Options |
|---------|---------|--------------|---------|
| [`new`](#new-name) | | Scaffold a new repo to the full standard | `--public`, `--desc "…"`, `--scope web\|k8s\|infra`, `-n`/`--dry-run` |
| [`init`](#init) | | Write a config with detected defaults | `--force` |
| [`status`](#status) | | At-a-glance dashboard of every repo | `-f`/`--fetch`, `--public`, `--private` |
| [`prs`](#prs) | | Open pull requests across the estate | |
| [`branches`](#branches) | `br` | Repos with stray local branches | `--prune` |
| [`doctor`](#doctor-repo) | | Audit repos against your conventions | `[repo]`, `--fix`, `-v`/`--verbose` |
| [`sync`](#sync) | | Fast-forward every repo to its default branch | |
| [`apply`](#apply-ownerrepo-scope) | | Apply the label taxonomy to a repo | `<owner/repo> <scope>` |
| [`conventions`](#conventions-topic) | `conv`, `std` | Look up the standard | `labels [scope]`, `ruleset`, `suite`, `doc` |
| [`open`](#open-repo-page) | | Open a repo (or a page) on GitHub | `[page]` |
| [`help`](#help) | `-h`, `--help` | The command menu | |

- **Inspect** views (`status` `prs` `branches` `doctor`) describe the estate and are read-only *by
  default*. Two opt into action on a flag: `branches --prune` deletes merged local branches, and
  `doctor --fix` repairs the safe gaps.
- **Operate** commands (`sync` `apply`) change things every run — `sync` pulls, `apply` writes labels.
- **`new`** is the scaffolder: it creates a whole repo — local `git`, a private GitHub repo, guardrails,
  the doc suite, ruleset, and labels — in one shot.
- Unlike vegtam, running `huginn` with **no command** prints the help menu, not a default view. huginn
  has **no `--json`/machine-readable output** — it's a human dashboard.

---

## Requirements & global behavior

- **Requires** `bash`, `git`, [`gh`](https://cli.github.com) (authenticated), and `jq`. huginn is *fast
  and local by default* — plain git per repo; the network (`gh`) is used only where noted (`new`,
  `doctor`, `prs`, `apply`, `status --fetch`/`--public`/`--private`, `open`).
- **The estate** is every top-level directory under `$HUGINN_ROOT` that contains a `.git` — scanned off
  disk, no owner check. Keep foreign/client repos *out* of the root so estate-wide commands don't sweep
  them in.
- **Config model** — settings resolve **env var → config file → smart default**. Run `huginn init` to
  write a config of detected defaults (`gh` login, git identity, estate paths), then edit it. File:
  `${XDG_CONFIG_HOME:-~/.config}/huginn/config` (override with `HUGINN_CONFIG`).

  | Key / env var | Default | Purpose |
  |---|---|---|
  | `HUGINN_OWNER` | your `gh` login | GitHub owner of the estate repos |
  | `HUGINN_ROOT` | `~/github-repos` | directory of repos to manage |
  | `HUGINN_EMAIL` | your git email | commit email for `new` / `doctor --fix` |
  | `HUGINN_NAME` | your git name | committer name |
  | `HUGINN_FAMILY` | *(none)* | space-separated repos to exclude, merged with `exemptions.json` |
  | `HUGINN_CONVENTIONS` | `repo-conventions` | dir under `HUGINN_ROOT` holding `labels.json` / `ruleset.json` / `docs-suite.json` / `exemptions.json` |

- **Exemptions** — repos listed in your conventions repo's `exemptions.json`, merged with any in
  `$HUGINN_FAMILY`, are skipped by the estate-wide commands (`sync`, `doctor`, `prs`, `branches`).
- **Conventions, with a fallback** — commands that read the standard (`new`, `apply`, `conventions`,
  `doctor --fix`) use your `HUGINN_CONVENTIONS` repo when present and fall back to the bundled
  `templates/` otherwise, so they work out of the box.
- **`NO_COLOR`** — set it (`NO_COLOR=1 huginn …`) to disable color; output is also plain automatically
  when piped or redirected (not a TTY).
- **Two-level help** — `huginn help` (also `-h`/`--help`, and the no-argument default) for the menu;
  `huginn <command> help` for one command.
- **Exit codes** — `0` on success; `1` on error (unknown command, no GitHub owner resolvable, a missing
  conventions file, or a usage error such as `open`/`apply` without its arguments).

---

## Create

### `new <name>`

Scaffold a brand-new repo to the full standard, end to end — nothing left half-wired. In one run:
`git init`, the local business email, guardrail files (`.agentgate.yml` + workflow), the doc suite
(README · LICENSE · CHANGELOG · ROADMAP · CONTRIBUTING), a `.gitignore`, a signed genesis commit, a
**private** GitHub repo, the branch-protection ruleset (PR + agentgate + signatures), and the base +
scope labels. Network (`gh`).

```sh
huginn new observatory
huginn new observatory --public
huginn new observatory --scope k8s --desc "DOKS monitoring add-on"
huginn new observatory --dry-run       # print the plan, create nothing
huginn new observatory -n              # same
```

| Option | Effect |
|--------|--------|
| `--public` | Create the GitHub repo public (default: private) |
| `--desc "…"` | Set the repo description |
| `--scope <s>` | Also apply a label scope: `web` \| `k8s` \| `infra` |
| `-n`, `--dry-run` | Print the plan and create nothing |

---

### `init`

Write a config file (`${XDG_CONFIG_HOME:-~/.config}/huginn/config`) populated with detected defaults —
your GitHub login, git email/name, and estate paths — then edit it to taste. An env `HUGINN_*` var
always overrides the file.

```sh
huginn init
huginn init --force       # overwrite an existing config
```

| Option | Effect |
|--------|--------|
| `--force` | Overwrite an existing config file |

Keys written: `HUGINN_OWNER` · `HUGINN_EMAIL` · `HUGINN_NAME` · `HUGINN_ROOT` · `HUGINN_FAMILY` ·
`HUGINN_CONVENTIONS`.

---

## Inspect

### `status`

The flagship: a one-screen dashboard of every git repo in the estate — a row per repo. Fast and local
by default.

Columns: **REPO** (local folder) · **BRANCH** (green = default, cyan = feature) · **LAST** (time since
last commit) · **STATUS**. Status flags: `✓` clean · `● N` changed · `↑ahead` `↓behind` · `⚑N`
stashes · `+N br` (extra local branches) · `✉?` no local email · `✉ <addr>` (local email ≠ business
address).

```sh
huginn status
huginn status --fetch     # git fetch each repo first, for fresh ahead/behind (network)
huginn status -f
huginn status --public    # only public repos  (network — reads visibility via gh)
huginn status --private   # only private repos (network)
```

| Option | Effect |
|--------|--------|
| `-f`, `--fetch` | `git fetch` each repo first so ahead/behind is fresh (network) |
| `--public` | Show only public repos (network — reads visibility via `gh`) |
| `--private` | Show only private repos (network) |

---

### `prs`

Every open pull request across the estate, one line each: repo, `#`, title, author. Handy for "what's
in flight / needs a merge?" after the agents have been working. Excludes exempt repos. Network (one
search query).

```sh
huginn prs
```

*(No options.)*

---

### `branches`

Every repo that carries local branches beyond its default, each marked `(merged)` or `(unmerged)`.
Descriptive by default — the only thing it deletes is what you opt into with `--prune`. Excludes exempt
repos.

```sh
huginn branches
huginn br                 # alias
huginn branches --prune   # delete the merged-in local branches
```

| Option | Effect |
|--------|--------|
| `--prune` | Delete the branches already merged into the default. Safe: `git branch -d`, never the current branch, never unmerged work. |

---

### `doctor [repo]`

Audit repos against your conventions and surface only what's off (pass `-v` to also list the ones that
pass). Runs the whole estate, or a single repo if you name one. Network — reads each repo's ruleset and
security settings, so a full sweep takes a minute or two.

Checks:
- **Baseline (all repos):** local `user.email` = the business address · a ruleset present.
- **Managed (AgentGate-wired) repos, additionally:** agentgate required · signed commits required ·
  `.agentgate.yml` present · secret scanning on (public repos) · the required doc suite present
  (README/LICENSE/CHANGELOG/ROADMAP/CONTRIBUTING) · no leftover classic branch protection (the estate
  standard is rulesets).

Dormant/unwired repos get the baseline only; exempt repos are skipped.

```sh
huginn doctor             # audit the whole estate
huginn doctor huginn      # audit a single repo (fast)
huginn doctor --fix       # auto-fix the safe gaps estate-wide
huginn doctor huginn --fix
huginn doctor -v          # also list repos that pass
```

| Option | Effect |
|--------|--------|
| `[repo]` | Audit a single repo instead of the whole estate |
| `--fix` | Auto-fix the *safe* gaps only: set the business email, and re-apply the standard ruleset on any managed repo where it's missing/drifted |
| `-v`, `--verbose` | Also list the repos that pass (default: only gaps) |

---

## Operate

### `sync`

Pull every repo to its default branch — **fast-forward only**. For each repo: check out the default
branch, then `git pull --ff-only`. Skips repos with uncommitted changes (won't clobber work) and exempt
repos. Never force-pulls or merges — a repo that can't fast-forward is reported, not touched. Ends with
an updated / skipped / problems summary.

```sh
huginn sync
```

*(No options.)*

---

### `apply <owner/repo> <scope>`

Apply the canonical label taxonomy to a repo — idempotent; delegates to `apply-conventions.sh` (your
conventions repo's, or the bundled one). Labels only: ruleset, git identity, metadata, milestones, and
the board are separate steps (see `huginn conventions doc`). Network.

```sh
huginn apply youruser/website web
huginn apply youruser/cluster  k8s
huginn apply youruser/infra    infra
```

| Argument | Meaning |
|--------|--------|
| `<owner/repo>` | The target repo, e.g. `youruser/website` |
| `<scope>` | Domain labels on top of the base set: `web` \| `k8s` \| `infra` |

---

## Reference & navigate

### `conventions [topic]`

Look up the standard you apply and are audited against — your `HUGINN_CONVENTIONS` repo, or the bundled
defaults when there isn't one. No argument prints an overview of what's available.

```sh
huginn conventions            # overview
huginn conv                   # alias (also: huginn std)
huginn conventions labels     # the whole label taxonomy, in each label's real color
huginn conventions labels k8s # just one scope
huginn conventions ruleset    # the branch-protection rules in plain English
huginn conventions suite      # the required document suite
huginn conventions doc        # the full CONVENTIONS.md (paged)
```

| Subtopic | Shows |
|--------|--------|
| `labels [scope]` | The label taxonomy, in each label's real color (`scope` = `web` \| `k8s` \| `infra`; omit for all) |
| `ruleset` | The branch-protection rules, in plain English |
| `suite` | The required document suite (what `doctor` checks and `new` scaffolds) |
| `doc` | The full `CONVENTIONS.md`, paged |
| *(no arg)* | Overview of what's available |

---

### `open <repo> [page]`

Open a repo — or one of its pages — on GitHub in your browser.

```sh
huginn open website           # the repo home
huginn open website rules     # settings → rulesets
huginn open website pr        # open pull requests
huginn open website security  # security & analysis settings
```

| Page | Opens |
|--------|--------|
| *(none)*, `home` | The repo home |
| `pr` (`prs`, `pulls`) | The pull requests tab |
| `settings` (`set`) | Repo settings |
| `rules` (`ruleset`) | Settings → rulesets |
| `security` (`sec`) | Settings → security & analysis |
| `actions` (`ci`) | The Actions tab |
| `issues` | The issues tab |

Any other value is treated as a path under the repo (`open <repo> <anything>` → `…/<anything>`).

---

## `help`

```sh
huginn                 # no command → the menu
huginn help            # the command menu
huginn -h              # same
huginn <command> help  # detail for one command (e.g. huginn doctor help)
```

---

## Recipes

```sh
# Lay of the land: where does every repo stand?
huginn status

# Fresh ahead/behind before a work session (network)
huginn status --fetch

# Just the public repos (e.g. before a hardening pass)
huginn status --public

# What's in flight across the estate right now?
huginn prs

# Where are my stray branches, and which are safe to clean?
huginn branches

# Actually delete the merged-in local branches
huginn branches --prune

# Audit the whole estate against the standard, gaps only
huginn doctor

# Audit one repo, fast
huginn doctor huginn

# Repair the safe gaps (business email + drifted rulesets)
huginn doctor --fix

# Catch every repo up to its default branch (ff-only, skips dirty)
huginn sync

# Stand up a new estate-compliant repo in one shot
huginn new observatory --scope k8s --desc "DOKS monitoring add-on"

# …but see the plan first
huginn new observatory --scope k8s --dry-run

# Put the canonical labels on a repo
huginn apply youruser/website web

# Remind myself what the ruleset actually enforces
huginn conventions ruleset

# Jump to a repo's ruleset settings in the browser
huginn open website rules

# Plain output for a log/pipe (no color)
NO_COLOR=1 huginn status
```
