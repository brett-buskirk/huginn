# Roadmap

## Toward public / reusable

- [x] **Config-driven** — `~/.config/huginn/config` (env → file → smart defaults) for owner, email,
      name, root, family, and the conventions source. No hardcoded owner; `huginn init` detects
      defaults from `gh` + git.
- [x] **`repo-conventions` dependency made optional** — huginn ships bundled `templates/` (guardrail
      workflow, `.agentgate.yml`, `ruleset.json`, `labels.json`, `apply-conventions.sh`) and falls
      back to them, so `new`/`apply`/`conventions`/`doctor` work without a conventions repo. Point
      `HUGINN_CONVENTIONS` at your own repo to override.
- [ ] **Doc-accuracy pass** — reconcile README / CHANGELOG / in-tool help / header comments with the
      config-driven, self-contained reality before going public.
- [ ] **Flip the repo public.**

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
