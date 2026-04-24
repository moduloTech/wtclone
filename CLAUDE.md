# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A single-file Bash CLI (`bin/wtclone`) that bootstraps a git repository into a worktree layout: `.bare/` clone + `.git` pointer file + an initial worktree on the remote's default branch. Distributed via Homebrew (`modulotech/tap`).

Running `wtclone <git-url>` creates:

```
$WTCLONE_ROOT/<name>/
  .bare/              bare clone
  .git                pointer file ("gitdir: ./.bare")
  <default_branch>/   initial worktree (e.g. main/)
```

`<name>` is derived from the URL, mirroring `bin/dev`'s `derive_project_from_remote` function that lives in each of the 23 modulotech Rails repos. Subsequent worktrees are created with native `git worktree add` — wtclone only handles the initial bootstrap.

## Running

```bash
# Bootstrap using the derived name
wtclone git@source.modulotech.fr:modulosource/powerpanne/powerpanne/core.git
# → $HOME/Projects/powerpanne-core/

# Override the name
wtclone git@source.modulotech.fr:modulosource/ff/fast/core.git fast-special

# Override the root
WTCLONE_ROOT=$HOME/code wtclone <url>
```

Optional shell wrapper (drop into `~/.zshrc` or `~/.bashrc`) to auto-cd into the worktree:

```bash
wtclone() {
  local target
  target=$(command wtclone "$@") || return $?
  cd "$target"
}
```

## Invariant with `bin/dev`

`wtclone`'s `derive_name_from_url` MUST produce the same name that `bin/dev`'s `derive_project_from_remote` produces for the same URL. This is a hard invariant: `bin/dev` derives `APP_NAME` from the same URL via `git remote get-url origin`, and consumers of `APP_NAME` (Traefik routing, Docker Compose project names, `.dev.test` hostnames) depend on both tools agreeing.

The invariant is enforced by the 23-URL fixture table in `test/wtclone.bats`. Every real modulotech repo URL is asserted against its expected output. If `bin/dev` changes in the 23 repos, update `derive_name_from_url` here to match and adjust the fixture assertions in the same commit.

### Normalize-before-compare

The comparison `parent == repo` that triggers dedup (e.g. `deliverycar/deliverycar` → `deliverycar`) happens **after** normalization (`_` → `-`, lowercase). This fixes the case `help_me_by_somfy/help-me-by-somfy`, which otherwise would produce `help-me-by-somfy-help-me-by-somfy`. `bin/dev` was patched in parallel with wtclone's 0.1.0 release to match this behavior.

### Intentionally-kept quirk

`mayday/mayday-web` → `mayday-mayday-web` (no prefix dedup). The algorithm only dedups on strict equality, not on shared prefixes. This is intentional and not a bug.

## Conventions

- Bash, `set -euo pipefail`, POSIX-friendly where practical.
- No runtime deps beyond `git`, `bash ≥ 4`, coreutils (`basename`, `dirname`, `tr`, `grep`, `sed`, `mkdir`).
- The script guards `wtclone_main "$@"` with a `BASH_SOURCE` check so `test/wtclone.bats` can `source` it and call individual functions.
- stdout is reserved for the final worktree path (last line). All informational logs go to stderr, including `git clone` / `git worktree add` output, which is explicitly redirected with `1>&2`. This contract is what makes the shell wrapper above work.

## Testing

```bash
cd wtclone
bats test/wtclone.bats
```

Install bats-core via `brew install bats-core` on macOS or `apt install bats` on Debian.

## Release Workflow

Handled by the `/release` skill at the repo root. Updates `CHANGELOG.md`, commits, tags, creates the GitHub release, and updates the Homebrew formula in the tap (`Formula/wtclone.rb`, when it exists).
