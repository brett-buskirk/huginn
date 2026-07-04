# Changelog

All notable changes to huginn are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **`status --public` / `--private`** — filter the dashboard by repo visibility. Opt-in (one `gh repo
  list` call); `status` stays fast and local by default.
- **Configurable exemptions** — repos that aren't code projects (profile repo, personal/creative
  repos, repos managed elsewhere) are read from `repo-conventions/exemptions.json` and merged with the
  `HUGINN_FAMILY` env var; exempt repos are skipped in `doctor`/`sync`/`prs`/`branches`. (Renamed the
  internal `is_family` helper to `is_exempt`.)
- **Classic-protection check** — `doctor` flags any managed repo that still has legacy *classic* branch
  protection (`classic-protection`), which conflicts with the ruleset-based standard.
- **Document-suite convention** — `doctor` now verifies each managed repo carries the required docs
  (README · LICENSE · CHANGELOG · ROADMAP · CONTRIBUTING), flagging any missing as `docs:<name>`;
  `new` scaffolds CHANGELOG + ROADMAP alongside the existing README/LICENSE/CONTRIBUTING; and
  `conventions suite` lists the required + recommended docs. The list is read from
  `repo-conventions/docs-suite.json` (bundled fallback in `templates/`).

## [0.2.0] - 2026-07-01

Generalized from a personal script into a config-driven, self-contained tool — and made public.

### Added
- **Config-driven** — settings resolve env → config file → smart defaults: `HUGINN_OWNER`
  (auto-detects from your `gh` login), `HUGINN_EMAIL`/`HUGINN_NAME` (from git config), `HUGINN_ROOT`,
  `HUGINN_FAMILY`, `HUGINN_CONVENTIONS`. Config lives at `~/.config/huginn/config`.
- **`init`** — writes a config file with detected defaults.
- **Bundled default templates** (`templates/`) — huginn now ships the guardrail workflow,
  `.agentgate.yml`, `ruleset.json`, `labels.json`, and `apply-conventions.sh`. `new`, `apply`, and
  `conventions` fall back to these when no `repo-conventions` repo is present, so the tool is
  self-contained; a `HUGINN_CONVENTIONS` repo overrides them.

### Changed
- Removed the hardcoded owner/email/name/conventions path. Commands that need the conventions repo
  now degrade gracefully when it's absent (a step toward the tool being reusable by others).
- Docs and in-tool help reworded for the config-driven, self-contained reality: generic
  `$HUGINN_FAMILY`/`HUGINN_CONVENTIONS` references instead of estate-specific ones, and a complete
  command list in the script header.

### Fixed
- `status` no longer compares every repo against a hardcoded personal email — `repo-status.sh` now
  reads the business email from `HUGINN_EMAIL` (passed by `huginn`) or falls back to `git config
  user.email`. Previously a fresh clone flagged all repos as wrong-email.

## [0.1.0] - 2026-07-01

First cut — extracted from a loose script into a real repo.

### Added
- **`status`** — at-a-glance dashboard of every repo (branch, dirty state, ahead/behind, last
  commit, stashes, extra local branches, and a business-email compliance flag). `--fetch` for fresh
  ahead/behind.
- **`doctor`** — audit every repo against the estate conventions (ruleset present, `agentgate`
  required, signed commits required, `.agentgate.yml`, secret scanning, local email). `--fix` sets
  the business email and re-applies a missing/drifted ruleset on managed repos.
- **`new`** — scaffold a brand-new repo to the full standard (guardrails, signed genesis commit,
  private GitHub repo, ruleset, labels). `--dry-run`, `--public`, `--desc`, `--scope`.
- **`sync`** — pull every repo to its default branch (fast-forward only, skips dirty).
- **`prs`** — list open PRs across the estate.
- **`branches`** — surface stray local branches; `--prune` deletes the merged ones.
- **`apply`** — apply the label taxonomy to a repo (delegates to `apply-conventions.sh`).
- **`conventions`** — look up the standard: `labels` (in real colors), `ruleset` (plain English),
  `doc`.
- **`open`** — open a repo (or its prs/settings/rules/actions) on GitHub.
- Two-level help: `huginn help` overview + `huginn <command> help` per-command detail.
- `HUGINN_ROOT` config so the tool can live anywhere and manage any estate directory.
