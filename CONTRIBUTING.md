# Contributing

- **No direct commits to `main`** — branch → PR (`gh pr create`) → green checks → merge.
- **AgentGate runs on every PR** — `secrets` + `dangerous_patterns` block; `scope` is advisory.
- Commits are signed & Verified; never commit secrets (`.env`, keys are gitignored).

## Working on the script

`huginn` is a single Bash script (plus `repo-status.sh`, the `status` module). Keep it dependency-light:
`bash`, `git`, `gh`, `jq` only.

- **Syntax-check before pushing:** `bash -n huginn && bash -n repo-status.sh`.
- **Run `shellcheck`** if you have it: `shellcheck huginn repo-status.sh`.
- Colors go through the `$R/$G/$Y/…` vars (empty when non-TTY / `NO_COLOR`) — don't hardcode escapes
  except where a comment already does (the truecolor label swatches, which check `$X` first).
- Each subcommand is a `cmd_<name>` function with a matching `help_<name>`; wire new ones into the
  `case` dispatcher and the `cmd_help` menu.
- Paths: `$HERE` = where the tool lives (and its bundled `templates/`); `$ROOT` = the estate it
  manages (`$HUGINN_ROOT`); `$CONV` = the conventions source. Resolve conventions files with
  `first_of "$CONV/<file>" "$HERE/templates/<file>"` so commands fall back to the bundled defaults.
