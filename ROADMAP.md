# Roadmap

## Toward public / reusable (the big one)

huginn is currently wired to a single owner and expects a specific `repo-conventions` layout. To be
useful to anyone else, it needs to become **config-driven**:

- [ ] A `huginn config` / `~/.config/huginn/config` (or `.huginnrc`) for `OWNER`, business email,
      the `FAMILY` exclusions, and the conventions source — no hardcoded `brett-buskirk`.
- [ ] Make the `repo-conventions` dependency optional / pluggable (graceful when absent; `doctor`
      degrades to the checks it can still run).
- [ ] A `huginn init` that sets up a new estate (creates a `repo-conventions` from a template).
- [ ] Then flip the repo public.

## Command ideas

- [ ] `status --json` / `doctor --json` — machine-readable output for scripting.
- [ ] `clone` — clone (or update) every repo the owner has into the estate.
- [ ] `doctor` — also check docs-suite completeness (README/LICENSE/SECURITY) and dependabot.
- [ ] `open` — more targets (releases, insights); open a specific PR by number.
- [ ] `new` — also create milestones + a linked project board (currently left as a follow-up).

## Polish

- [ ] `shellcheck` in CI.
- [ ] Bats tests for the pure-logic helpers.
- [ ] Tab completion (bash/zsh).
