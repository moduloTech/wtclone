# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-24

### Added

- Initial release. `wtclone <git-url> [name]` bootstraps a git repository in worktree layout under `$WTCLONE_ROOT` (default `$HOME/Projects`): bare clone at `.bare/`, pointer file at `.git`, and an initial worktree on the remote's default branch.
- Project-name derivation mirrors `bin/dev`'s `derive_project_from_remote` with the fix to normalize segments (`_` → `-`, lowercase) before the `parent == repo` dedup comparison. Invariance is asserted against a fixture of 23 real modulotech repo URLs in `test/wtclone.bats`.
- Optional shell wrapper pattern documented in `CLAUDE.md` for auto-`cd` into the created worktree (script itself prints the target path on stdout so the wrapper can `cd "$(command wtclone …)"`).
