# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `wtclone rm` now detects gitignored entries (caches, build artifacts, vendored deps) before delegating to `git worktree remove`. These pass git's cleanliness check but block the final `rmdir` with the cryptic `failed to delete '...': Directory not empty`. The new pre-check fails with a message that names the offending entries and points to the two remediation paths: `wtclone rm <branch> --force`, or `git -C <wt_path> clean -fdX` to clean first. Behavior is unchanged — `--force` still bypasses the check.
- `wtclone add` now diagnoses the "branch already exists locally" failure with a tailored message per case: (1) branch checked out in another worktree (shows the worktree path); (2) orphan ref matching `origin/<branch>` (suggests the safe `git worktree add <branch>` attach); (3) orphan ref diverged from origin (reports ahead/behind counts and offers both attach-and-keep and `branch -D` + recreate paths); (4) orphan ref with no remote counterpart (suggests local-only attach). The `fetch origin` step now runs before the existing-branch check so the diagnosis works against fresh remote-tracking refs.

## [0.2.0] - 2026-04-24

### Added

- Subcommand-based CLI: `init`, `add`, `rm`, `fix`. The legacy positional form `wtclone <url> [name]` is preserved as a shortcut for `init`.
- `wtclone add <branch> [base]`: creates a worktree that tracks `origin/<branch>` when the remote branch exists; otherwise creates a new local branch off `origin/HEAD` (or off `[base]` if provided) with `--no-track`.
- `wtclone rm <branch> [--force] [--keep-branch]`: safe removal. Refuses if the worktree has uncommitted changes or the branch has unpushed commits relative to its upstream. `--force` bypasses both checks, `--keep-branch` retains the local branch ref.
- `wtclone fix`: migrates layouts created by earlier versions to the safe fetch refspec, populates `refs/remotes/origin/*`, wires `refs/remotes/origin/HEAD`, and sets upstream on each existing worktree's branch when a matching remote branch is present.
- Layout auto-detection: `add`, `rm`, and `fix` walk up from `$PWD` to find the `.bare/` + `.git` pointer, so they work from the layout root or from inside any worktree.

### Changed

- `init` now configures `remote.origin.fetch = +refs/heads/*:refs/remotes/origin/*` on the bare clone and re-fetches so remote-tracking refs populate `refs/remotes/origin/*`. Previously `git clone --bare` left no fetch refspec, which meant subsequent `git fetch` calls only updated `FETCH_HEAD` rather than propagating branch updates — making `git pull` and `git fetch` from worktrees awkward without manual setup.
- `init` wires `refs/remotes/origin/HEAD` symbolically at clone time so `add` can derive the default branch without a network round-trip.
- The initial worktree created by `init` tracks `origin/<default_branch>` (via `git worktree add -b <branch> <path> origin/<branch>`). `git pull` and `git push` from the default worktree now work out of the box.

## [0.1.0] - 2026-04-24

### Added

- Initial release. `wtclone <git-url> [name]` bootstraps a git repository in worktree layout under `$WTCLONE_ROOT` (default `$HOME/Projects`): bare clone at `.bare/`, pointer file at `.git`, and an initial worktree on the remote's default branch.
- Project-name derivation mirrors `bin/dev`'s `derive_project_from_remote` with the fix to normalize segments (`_` → `-`, lowercase) before the `parent == repo` dedup comparison. Invariance is asserted against a fixture of 23 real modulotech repo URLs in `test/wtclone.bats`.
- Optional shell wrapper pattern documented in `CLAUDE.md` for auto-`cd` into the created worktree (script itself prints the target path on stdout so the wrapper can `cd "$(command wtclone …)"`).
