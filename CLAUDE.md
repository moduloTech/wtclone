# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A single-file Bash CLI (`bin/wtclone`) that bootstraps a git repository into a worktree layout — `.bare/` clone + `.git` pointer file + a worktree on the default branch — and provides ergonomic subcommands to add and remove worktrees. Distributed via Homebrew (`modulotech/tap`).

The layout produced by `wtclone init`:

```
$WTCLONE_ROOT/<name>/
  .bare/              bare clone
  .git                pointer file ("gitdir: ./.bare")
  <default_branch>/   initial worktree (e.g. main/ or master/)
```

`<name>` is derived from the URL, mirroring `bin/dev`'s `derive_project_from_remote` function that lives in each of the 23 modulotech Rails repos.

## Running

```bash
# Bootstrap a new project (shortcut form)
wtclone git@source.modulotech.fr:modulosource/powerpanne/powerpanne/core.git
# → $HOME/Projects/powerpanne-core/, with a `main`/`master` worktree tracking origin/*

# Explicit subcommand form — equivalent
wtclone init git@source.modulotech.fr:modulosource/ff/fast/core.git fast-special

# Add a worktree for an existing remote branch (tracks origin/staging)
cd ~/Projects/powerpanne-core
wtclone add staging

# Add a worktree with a brand-new branch off origin/HEAD (no upstream set)
wtclone add feature/my-work

# Add with an explicit base commit-ish
wtclone add hotfix v1.2.3

# Remove a worktree (refuses if uncommitted changes or unpushed commits)
wtclone rm feature/my-work
wtclone rm feature/my-work --force        # bypass safety checks
wtclone rm feature/my-work --keep-branch  # remove worktree but keep the branch ref

# Override the root directory
WTCLONE_ROOT=$HOME/code wtclone <url>
```

Optional shell wrapper (drop into `~/.zshrc` or `~/.bashrc`) to auto-cd into a newly-created worktree. Works for both `init` and `add`, which both print the created worktree path as their last stdout line:

```bash
wtclone() {
  local target
  target=$(command wtclone "$@") || return $?
  # Only cd when we got a path back (init/add), not for rm/fix/--help.
  [ -d "$target" ] && cd "$target"
}
```

## Fetch refspec and why it matters

`wtclone init` configures the bare clone with `remote.origin.fetch = +refs/heads/*:refs/remotes/origin/*`. This is the same refspec a normal (non-bare) `git clone` sets up, and it means:

- `git fetch` from any worktree populates `refs/remotes/origin/*` — the standard mental model.
- Branches checked out in worktrees have a proper upstream (set by `git worktree add -b <branch> <branch> origin/<branch>`), so `git pull` / `git push` without arguments just work.

By contrast, the bare-clone-plus-worktrees pattern as documented on many blogs uses `+refs/heads/*:refs/heads/*` — which makes every `git fetch` **force-update** local branches to match the remote, destroying unpushed local commits. `wtclone init` deliberately avoids this.

`git clone --bare` in modern git (≥ 2.39) actually leaves `remote.origin.fetch` unset by default, so the force-update disaster doesn't happen out of the box — but fetching branch updates from worktrees is awkward (no remote-tracking refs). `wtclone init` sets the safe refspec explicitly to get the best of both worlds.

### Migrating a pre-0.2.0 layout

`wtclone fix`, run from anywhere inside an existing layout (layout root or any worktree), will:

1. Rewrite `remote.origin.fetch` to the safe form if needed.
2. Fetch so that `refs/remotes/origin/*` populates.
3. Wire `refs/remotes/origin/HEAD` to the default branch.
4. Set upstream (`branch.<name>.remote/merge` config) on each existing worktree's branch when a matching `origin/<branch>` exists.

It is idempotent — safe to run on an already-fixed layout.

## Invariant with `bin/dev`

`wtclone`'s `derive_name_from_url` MUST produce the same name that `bin/dev`'s `derive_project_from_remote` produces for the same URL. This is a hard invariant: `bin/dev` derives `APP_NAME` from the same URL via `git remote get-url origin`, and consumers of `APP_NAME` (Traefik routing, Docker Compose project names, `.dev.test` hostnames) depend on both tools agreeing.

The invariant is enforced by the 23-URL fixture table in `test/wtclone.bats`. Every real modulotech repo URL is asserted against its expected output. If `bin/dev` changes in the 23 repos, update `derive_name_from_url` here to match and adjust the fixture assertions in the same commit.

### Normalize-before-compare

The comparison `parent == repo` that triggers dedup (e.g. `deliverycar/deliverycar` → `deliverycar`) happens **after** normalization (`_` → `-`, lowercase). This fixes the case `help_me_by_somfy/help-me-by-somfy`, which otherwise would produce `help-me-by-somfy-help-me-by-somfy`. `bin/dev` was patched in parallel with wtclone's 0.1.0 release to match this behavior.

### Intentionally-kept quirk

`mayday/mayday-web` → `mayday-mayday-web` (no prefix dedup). The algorithm only dedups on strict equality, not on shared prefixes. This is intentional and not a bug.

## Conventions

- Bash, `set -euo pipefail`, POSIX-friendly where practical.
- No runtime deps beyond `git`, `bash ≥ 4`, coreutils (`basename`, `dirname`, `tr`, `grep`, `sed`, `awk`, `mkdir`).
- The script guards `wtclone_main "$@"` with a `BASH_SOURCE` check so `test/wtclone.bats` can `source` it and call individual functions.
- stdout is reserved for the final worktree path (printed by `init` and `add` as the last line). All informational logs go to stderr, including `git` subprocess output, which is explicitly redirected with `1>&2`. `rm` and `fix` print no stdout. This contract is what makes the shell wrapper above work.
- Subcommands that operate on an existing layout (`add`, `rm`, `fix`) walk up from `$PWD` until they find a `.bare/` + `.git` pointer pair, so they work from the layout root or from inside any worktree.

## Testing

```bash
cd wtclone
bats test/wtclone.bats
```

Install bats-core via `brew install bats-core` on macOS or `apt install bats` on Debian. The suite covers name derivation (23 real URLs), DNS validation, CLI dispatch, and end-to-end init/add/rm/fix flows against a local fixture repo.

## Release Workflow

Handled by the `/release` skill at the repo root. Updates `CHANGELOG.md`, commits, tags, creates the GitHub release, and updates the Homebrew formula in the tap (`Formula/wtclone.rb`).
