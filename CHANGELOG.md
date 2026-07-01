# Changelog

All notable changes to huginn are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Config-driven** — settings resolve env → config file → smart defaults: `HUGINN_OWNER`
  (auto-detects from your `gh` login), `HUGINN_EMAIL`/`HUGINN_NAME` (from git config), `HUGINN_ROOT`,
  `HUGINN_FAMILY`, `HUGINN_CONVENTIONS`. Config lives at `~/.config/huginn/config`.
- **`init`** — writes a config file with detected defaults.

### Changed
- Removed the hardcoded owner/email/name/conventions path. Commands that need the conventions repo
  now degrade gracefully when it's absent (a step toward the tool being reusable by others).

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
