#!/usr/bin/env bats
# wtclone test suite.
#
# Invariant: derive_name_from_url must produce the same name that bin/dev's
# derive_project_from_remote produces (post-fix: normalize before comparison).
# The 23-URL fixture table below freezes the expected outputs for all known
# modulotech repos. Any change here must be matched in bin/dev across the
# 23 repos where it lives.

setup() {
  BIN="$BATS_TEST_DIRNAME/../bin/wtclone"
  # shellcheck source=../bin/wtclone
  source "$BIN"
}

assert_derived() {
  local url="$1" expected="$2" actual
  actual=$(derive_name_from_url "$url")
  if [ "$actual" != "$expected" ]; then
    printf 'URL:      %s\n' "$url" >&2
    printf 'expected: %s\n' "$expected" >&2
    printf 'actual:   %s\n' "$actual" >&2
    return 1
  fi
}

# Create a non-bare "remote" fixture with `main` (default) and `staging` branches.
make_fixture_remote() {
  local dir="$1"
  git -C "$dir" init -q -b main
  git -C "$dir" -c user.email=t@t -c user.name=t commit --allow-empty -q -m init-main
  git -C "$dir" checkout -q -b staging
  git -C "$dir" -c user.email=t@t -c user.name=t commit --allow-empty -q -m staging-work
  git -C "$dir" checkout -q main
}

# Simulate a pre-0.2.0 (0.1.0-style) layout: bare clone with the unsafe
# +refs/heads/*:refs/heads/* refspec and a worktree on the default branch.
make_v010_layout() {
  local target="$1" src="$2"
  mkdir -p "$target"
  git clone --bare -q "$src" "$target/.bare"
  printf 'gitdir: ./.bare\n' > "$target/.git"
  git --git-dir="$target/.bare" worktree add -q "$target/main" 1>/dev/null 2>&1
}

# ---- 23-URL fixture assertions --------------------------------------------

@test "derive: fiftycent/50cent" {
  assert_derived "git@source.modulotech.fr:modulosource/modulotech/fiftycent/50cent.git" "fiftycent-50cent"
}

@test "derive: fiftycent/50cent-legacy" {
  assert_derived "git@source.modulotech.fr:modulosource/modulotech/fiftycent/50cent-legacy.git" "fiftycent-50cent-legacy"
}

@test "derive: lastbill/client/fidelia" {
  assert_derived "git@source.modulotech.fr:modulosource/modulotech/lastbill/client/fidelia.git" "client-fidelia"
}

@test "derive: devops/cost-control" {
  assert_derived "git@source.modulotech.fr:modulosource/modulotech/devops/cost-control.git" "devops-cost-control"
}

@test "derive: deliverycar/deliverycar (dedup)" {
  assert_derived "git@source.modulotech.fr:modulosource/modulagency/deliverycar/deliverycar.git" "deliverycar"
}

@test "derive: lastbill/fakir" {
  assert_derived "git@source.modulotech.fr:modulosource/modulotech/lastbill/fakir.git" "lastbill-fakir"
}

@test "derive: ff/fast/core" {
  assert_derived "git@source.modulotech.fr:modulosource/ff/fast/core.git" "fast-core"
}

@test "derive: microservices/fidelia-edi" {
  assert_derived "git@source.modulotech.fr:modulosource/kaze/microservices/fidelia-edi.git" "microservices-fidelia-edi"
}

@test "derive: geoprovider/core" {
  assert_derived "git@source.modulotech.fr:modulosource/RAS/geoprovider/core.git" "geoprovider-core"
}

@test "derive: help_me_by_somfy/help-me-by-somfy (normalize-then-dedup)" {
  assert_derived "git@source.modulotech.fr:modulosource/modulagency/help_me_by_somfy/help-me-by-somfy.git" "help-me-by-somfy"
}

@test "derive: houston/houston (dedup)" {
  assert_derived "git@source.modulotech.fr:modulosource/powerpanne/powerpanne/houston/houston.git" "houston"
}

@test "derive: client/ima-proxy" {
  assert_derived "git@source.modulotech.fr:modulosource/kaze/client/ima-proxy.git" "client-ima-proxy"
}

@test "derive: kaze/lastbill-extranet-fidelia" {
  assert_derived "git@source.modulotech.fr:modulosource/modulotech/kaze/lastbill-extranet-fidelia.git" "kaze-lastbill-extranet-fidelia"
}

@test "derive: logista/logista (dedup)" {
  assert_derived "git@source.modulotech.fr:modulosource/modulagency/logista/logista.git" "logista"
}

@test "derive: microservices/makeyourkaze" {
  assert_derived "git@source.modulotech.fr:modulosource/kaze/microservices/makeyourkaze.git" "microservices-makeyourkaze"
}

@test "derive: houston/mayday" {
  assert_derived "git@source.modulotech.fr:modulosource/powerpanne/powerpanne/houston/mayday.git" "houston-mayday"
}

@test "derive: mayday/mayday-web (no dedup, intentional)" {
  assert_derived "git@source.modulotech.fr:modulosource/powerpanne/powerpanne/mayday/mayday-web.git" "mayday-mayday-web"
}

@test "derive: ffc/mediatheque_ffc" {
  assert_derived "git@source.modulotech.fr:modulosource/modulagency/ffc/mediatheque_ffc.git" "ffc-mediatheque-ffc"
}

@test "derive: tools/mulev2" {
  assert_derived "git@source.modulotech.fr:modulosource/powerpanne/powerpanne/tools/mulev2.git" "tools-mulev2"
}

@test "derive: powerpanne/core" {
  assert_derived "git@source.modulotech.fr:modulosource/powerpanne/powerpanne/core.git" "powerpanne-core"
}

@test "derive: r-and-d/push-to-talk-server" {
  assert_derived "git@source.modulotech.fr:modulosource/modulotech/r-and-d/push-to-talk-server.git" "r-and-d-push-to-talk-server"
}

@test "derive: robots/resilians-supervisor" {
  assert_derived "git@source.modulotech.fr:modulosource/kaze/robots/resilians-supervisor.git" "robots-resilians-supervisor"
}

@test "derive: save-assistance/core" {
  assert_derived "git@source.modulotech.fr:modulosource/RAS/save-assistance/core.git" "save-assistance-core"
}

# ---- URL-form coverage -----------------------------------------------------

@test "derive: https URL" {
  assert_derived "https://source.modulotech.fr/modulosource/ff/fast/core.git" "fast-core"
}

@test "derive: URL without trailing .git" {
  assert_derived "git@source.modulotech.fr:modulosource/ff/fast/core" "fast-core"
}

@test "derive: uppercase segments normalize" {
  assert_derived "git@host:Group/SubGroup/Repo.git" "subgroup-repo"
}

# ---- validate_dns_label ----------------------------------------------------

@test "validate: rejects empty" {
  run validate_dns_label ""
  [ "$status" -ne 0 ]
}

@test "validate: rejects leading hyphen" {
  run validate_dns_label "-foo"
  [ "$status" -ne 0 ]
}

@test "validate: rejects trailing hyphen" {
  run validate_dns_label "foo-"
  [ "$status" -ne 0 ]
}

@test "validate: rejects underscore (pre-normalize input)" {
  run validate_dns_label "foo_bar"
  [ "$status" -ne 0 ]
}

@test "validate: rejects > 50 chars" {
  run validate_dns_label "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  [ "$status" -ne 0 ]
}

@test "validate: accepts digit-leading (50cent pattern)" {
  run validate_dns_label "50cent-legacy"
  [ "$status" -eq 0 ]
}

@test "validate: accepts max-length 50" {
  run validate_dns_label "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  [ "$status" -eq 0 ]
}

# ---- CLI dispatch ----------------------------------------------------------

@test "cli: no args exits 2 with usage" {
  run "$BIN"
  [ "$status" -eq 2 ]
}

@test "cli: --help exits 0 and mentions subcommands" {
  run "$BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"init"* ]]
  [[ "$output" == *"add"* ]]
  [[ "$output" == *"fix"* ]]
}

@test "cli: --version prints version" {
  run "$BIN" --version
  [ "$status" -eq 0 ]
  [[ "$output" == wtclone\ * ]]
}

# ---- init -----------------------------------------------------------------

@test "init: safe refspec + default-branch worktree with upstream tracking" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"

  WTCLONE_ROOT="$dest" run "$BIN" init "$src" test-proj
  [ "$status" -eq 0 ]

  [ -d "$dest/test-proj/.bare" ]
  [ -f "$dest/test-proj/.git" ]
  [ -d "$dest/test-proj/main" ]
  [ "$(cat "$dest/test-proj/.git")" = "gitdir: ./.bare" ]

  # refspec is safe
  local refspec
  refspec=$(git --git-dir="$dest/test-proj/.bare" config remote.origin.fetch)
  [ "$refspec" = "+refs/heads/*:refs/remotes/origin/*" ]

  # refs/heads/* contains ONLY the default branch (others were deleted + recreated)
  local heads
  heads=$(git --git-dir="$dest/test-proj/.bare" for-each-ref --format='%(refname:short)' refs/heads/ | sort | tr '\n' ' ')
  [ "$heads" = "main " ]

  # refs/remotes/origin/* has all remote branches
  local remotes
  remotes=$(git --git-dir="$dest/test-proj/.bare" for-each-ref --format='%(refname:short)' refs/remotes/origin/ | sort | tr '\n' ' ')
  [[ "$remotes" == *"origin/main"* ]]
  [[ "$remotes" == *"origin/staging"* ]]

  # origin/HEAD is wired
  local origin_head
  origin_head=$(git --git-dir="$dest/test-proj/.bare" symbolic-ref --short refs/remotes/origin/HEAD)
  [ "$origin_head" = "origin/main" ]

  # Worktree's `main` branch tracks origin/main
  local upstream
  upstream=$(git -C "$dest/test-proj/main" rev-parse --abbrev-ref "main@{upstream}")
  [ "$upstream" = "origin/main" ]

  # stdout contract: last line is the worktree path
  local last_line
  last_line=$(printf '%s' "$output" | tail -n 1)
  [ "$last_line" = "$dest/test-proj/main" ]

  rm -rf "$src" "$dest"
}

@test "init: shortcut form (wtclone <url>) is equivalent" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"

  WTCLONE_ROOT="$dest" run "$BIN" "$src" shortcut-proj
  [ "$status" -eq 0 ]
  [ -d "$dest/shortcut-proj/.bare" ]
  [ -d "$dest/shortcut-proj/main" ]
  [ "$(git --git-dir="$dest/shortcut-proj/.bare" config remote.origin.fetch)" = "+refs/heads/*:refs/remotes/origin/*" ]

  rm -rf "$src" "$dest"
}

@test "init: refuses when target exists" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  mkdir -p "$dest/already-there"

  WTCLONE_ROOT="$dest" run "$BIN" init "$src" already-there
  [ "$status" -ne 0 ]
  [[ "$output" == *"target exists"* ]]

  rm -rf "$src" "$dest"
}

@test "init: rejects invalid override name" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"

  WTCLONE_ROOT="$dest" run "$BIN" init "$src" "-badname"
  [ "$status" -ne 0 ]
  [[ "$output" == *"valid DNS label"* ]]

  rm -rf "$src" "$dest"
}

# ---- add ------------------------------------------------------------------

@test "add: remote branch exists → worktree tracks origin/<branch>" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null

  cd "$dest/proj"
  run "$BIN" add staging
  [ "$status" -eq 0 ]
  [ -d "$dest/proj/staging" ]

  local upstream
  upstream=$(git -C "$dest/proj/staging" rev-parse --abbrev-ref "staging@{upstream}")
  [ "$upstream" = "origin/staging" ]

  local last_line
  last_line=$(printf '%s' "$output" | tail -n 1)
  [ "$last_line" = "$dest/proj/staging" ]

  rm -rf "$src" "$dest"
}

@test "add: remote branch absent → new branch off origin/HEAD (no upstream)" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null

  cd "$dest/proj"
  run "$BIN" add feature-foo
  [ "$status" -eq 0 ]
  [ -d "$dest/proj/feature-foo" ]

  # Branch exists locally
  git --git-dir="$dest/proj/.bare" show-ref --verify --quiet refs/heads/feature-foo

  # No upstream set
  run git -C "$dest/proj/feature-foo" rev-parse --abbrev-ref "feature-foo@{upstream}"
  [ "$status" -ne 0 ]

  rm -rf "$src" "$dest"
}

@test "add: refuses when branch already exists locally" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null

  cd "$dest/proj"
  run "$BIN" add main
  [ "$status" -ne 0 ]
  [[ "$output" == *"already exists locally"* ]]

  rm -rf "$src" "$dest"
}

@test "add: works from within a worktree (find_layout_root walks up)" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null

  cd "$dest/proj/main"
  run "$BIN" add staging
  [ "$status" -eq 0 ]
  [ -d "$dest/proj/staging" ]

  rm -rf "$src" "$dest"
}

# ---- rm -------------------------------------------------------------------

@test "rm: clean worktree → removes and deletes branch" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null
  cd "$dest/proj"
  "$BIN" add staging 1>/dev/null

  run "$BIN" rm staging
  [ "$status" -eq 0 ]
  [ ! -d "$dest/proj/staging" ]
  run git --git-dir="$dest/proj/.bare" show-ref --verify --quiet refs/heads/staging
  [ "$status" -ne 0 ]

  rm -rf "$src" "$dest"
}

@test "rm: refuses on uncommitted changes" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null
  cd "$dest/proj"
  "$BIN" add staging 1>/dev/null
  echo "wip" > "$dest/proj/staging/dirty.txt"

  run "$BIN" rm staging
  [ "$status" -ne 0 ]
  [[ "$output" == *"uncommitted changes"* ]]
  [ -d "$dest/proj/staging" ]

  rm -rf "$src" "$dest"
}

@test "rm: --force skips uncommitted check" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null
  cd "$dest/proj"
  "$BIN" add staging 1>/dev/null
  echo "wip" > "$dest/proj/staging/dirty.txt"

  run "$BIN" rm staging --force
  [ "$status" -eq 0 ]
  [ ! -d "$dest/proj/staging" ]

  rm -rf "$src" "$dest"
}

@test "rm: --keep-branch retains the ref" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null
  cd "$dest/proj"
  "$BIN" add staging 1>/dev/null

  run "$BIN" rm staging --keep-branch
  [ "$status" -eq 0 ]
  [ ! -d "$dest/proj/staging" ]
  git --git-dir="$dest/proj/.bare" show-ref --verify --quiet refs/heads/staging

  rm -rf "$src" "$dest"
}

@test "rm: refuses on gitignored entries with actionable message" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"

  # Track a .gitignore on staging in the source remote so the worktree starts clean.
  git -C "$src" checkout -q staging
  echo "/cache/" > "$src/.gitignore"
  git -C "$src" -c user.email=t@t -c user.name=t add .gitignore
  git -C "$src" -c user.email=t@t -c user.name=t commit -q -m "ignore cache/"
  git -C "$src" checkout -q main

  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null
  cd "$dest/proj"
  "$BIN" add staging 1>/dev/null

  # Drop an ignored entry — git status stays clean, but rmdir would fail.
  mkdir "$dest/proj/staging/cache"
  echo "junk" > "$dest/proj/staging/cache/file.txt"

  run "$BIN" rm staging
  [ "$status" -ne 0 ]
  [[ "$output" == *"gitignored entries"* ]]
  [[ "$output" == *"cache/"* ]]
  [[ "$output" == *"--force"* ]]
  [[ "$output" == *"clean -fdX"* ]]
  [ -d "$dest/proj/staging" ]

  # --force bypasses the check and removes everything.
  run "$BIN" rm staging --force
  [ "$status" -eq 0 ]
  [ ! -d "$dest/proj/staging" ]

  rm -rf "$src" "$dest"
}

@test "rm: refuses on unpushed commits" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null
  cd "$dest/proj"
  "$BIN" add staging 1>/dev/null
  git -C "$dest/proj/staging" -c user.email=t@t -c user.name=t commit --allow-empty -q -m "local work"

  run "$BIN" rm staging
  [ "$status" -ne 0 ]
  [[ "$output" == *"unpushed"* ]]

  rm -rf "$src" "$dest"
}

# ---- fix ------------------------------------------------------------------

@test "fix: migrates a 0.1.0-style layout to safe refspec + sets upstream" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  make_v010_layout "$dest/proj" "$src"

  # Pre-conditions: refspec is not the safe form yet (git clone --bare leaves
  # it unset by default), and the worktree has no upstream configured.
  local pre_refspec
  pre_refspec=$(git --git-dir="$dest/proj/.bare" config remote.origin.fetch 2>/dev/null || true)
  [ "$pre_refspec" != "+refs/heads/*:refs/remotes/origin/*" ]
  run git -C "$dest/proj/main" rev-parse --abbrev-ref "main@{upstream}"
  [ "$status" -ne 0 ]

  cd "$dest/proj/main"
  run "$BIN" fix
  [ "$status" -eq 0 ]

  # Post: safe refspec
  [ "$(git --git-dir="$dest/proj/.bare" config remote.origin.fetch)" = "+refs/heads/*:refs/remotes/origin/*" ]

  # origin/* refs populated
  git --git-dir="$dest/proj/.bare" show-ref --verify --quiet refs/remotes/origin/main
  git --git-dir="$dest/proj/.bare" show-ref --verify --quiet refs/remotes/origin/staging

  # origin/HEAD wired
  [ "$(git --git-dir="$dest/proj/.bare" symbolic-ref --short refs/remotes/origin/HEAD)" = "origin/main" ]

  # Existing worktree's branch tracks origin/main
  [ "$(git -C "$dest/proj/main" rev-parse --abbrev-ref "main@{upstream}")" = "origin/main" ]

  rm -rf "$src" "$dest"
}

@test "fix: idempotent on an already-safe layout" {
  local src dest
  src=$(mktemp -d); dest=$(mktemp -d)
  make_fixture_remote "$src"
  WTCLONE_ROOT="$dest" "$BIN" init "$src" proj 1>/dev/null
  cd "$dest/proj"

  run "$BIN" fix
  [ "$status" -eq 0 ]
  [[ "$output" == *"refspec already safe"* ]]

  rm -rf "$src" "$dest"
}

@test "fix: fails outside a wtclone layout" {
  local outside
  outside=$(mktemp -d)
  cd "$outside"
  run "$BIN" fix
  [ "$status" -ne 0 ]
  [[ "$output" == *"not inside a wtclone layout"* ]]
  rm -rf "$outside"
}
