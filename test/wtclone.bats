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

# ---- CLI end-to-end --------------------------------------------------------

@test "cli: no args exits 2 with usage" {
  run "$BIN"
  [ "$status" -eq 2 ]
}

@test "cli: --help exits 0" {
  run "$BIN" --help
  [ "$status" -eq 0 ]
}

@test "cli: --version prints version" {
  run "$BIN" --version
  [ "$status" -eq 0 ]
  [[ "$output" == wtclone\ * ]]
}

@test "e2e: clones a local fixture and creates worktree" {
  local src dest
  src=$(mktemp -d)
  dest=$(mktemp -d)
  git -C "$src" init -q -b main
  git -C "$src" -c user.email=t@t -c user.name=t commit --allow-empty -q -m init

  WTCLONE_ROOT="$dest" run "$BIN" "$src" test-proj
  [ "$status" -eq 0 ]
  [ -d "$dest/test-proj/.bare" ]
  [ -f "$dest/test-proj/.git" ]
  [ -d "$dest/test-proj/main" ]
  [ "$(cat "$dest/test-proj/.git")" = "gitdir: ./.bare" ]

  local last_line
  last_line=$(printf '%s' "$output" | tail -n 1)
  [ "$last_line" = "$dest/test-proj/main" ]

  rm -rf "$src" "$dest"
}

@test "e2e: refuses when target exists" {
  local src dest
  src=$(mktemp -d)
  dest=$(mktemp -d)
  git -C "$src" init -q -b main
  git -C "$src" -c user.email=t@t -c user.name=t commit --allow-empty -q -m init
  mkdir -p "$dest/already-there"

  WTCLONE_ROOT="$dest" run "$BIN" "$src" already-there
  [ "$status" -ne 0 ]
  [[ "$output" == *"target exists"* ]]

  rm -rf "$src" "$dest"
}

@test "e2e: rejects invalid override name" {
  local src dest
  src=$(mktemp -d)
  dest=$(mktemp -d)
  git -C "$src" init -q -b main

  WTCLONE_ROOT="$dest" run "$BIN" "$src" "-badname"
  [ "$status" -ne 0 ]
  [[ "$output" == *"valid DNS label"* ]]

  rm -rf "$src" "$dest"
}
