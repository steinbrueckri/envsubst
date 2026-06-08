#!/usr/bin/env bats

# Requires: docker, bats-core

IMAGE="${IMAGE:-envsubst-test:latest}"

setup_file() {
  docker build -t "$IMAGE" "$(dirname "$BATS_TEST_FILENAME")/.." >&2
}

setup() {
  WORKDIR="$(mktemp -d)"
  PROCESSED="$(mktemp -d)"
}

teardown() {
  rm -rf "$WORKDIR" "$PROCESSED"
}

run_envsubst() {
  docker run --rm \
    --user "$(id -u):$(id -g)" \
    -v "$WORKDIR:/workdir" \
    -v "$PROCESSED:/processed" \
    "$@" \
    "$IMAGE"
}

# --- basic behavior ---

@test "single file: variable is substituted" {
  echo 'hello $NAME' > "$WORKDIR/config.txt"

  run run_envsubst -e NAME=world
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/config.txt")" = "hello world" ]
}

@test "multiple variables in one file are substituted" {
  echo '$GREETING $NAME' > "$WORKDIR/msg.txt"

  run run_envsubst -e GREETING=hello -e NAME=world
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/msg.txt")" = "hello world" ]
}

@test "unset variable is replaced with empty string" {
  echo 'value=$UNDEFINED_VAR' > "$WORKDIR/test.txt"

  run run_envsubst
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/test.txt")" = "value=" ]
}

@test "file without variables is copied unchanged" {
  echo 'no placeholders here' > "$WORKDIR/plain.txt"

  run run_envsubst
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/plain.txt")" = "no placeholders here" ]
}

@test "multiple files are all processed" {
  echo '$A' > "$WORKDIR/a.txt"
  echo '$B' > "$WORKDIR/b.txt"

  run run_envsubst -e A=alpha -e B=beta
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/a.txt")" = "alpha" ]
  [ "$(cat "$PROCESSED/b.txt")" = "beta" ]
}

@test "empty workdir exits with error" {
  run run_envsubst
  [ "$status" -eq 1 ]
  [[ "$output" == *"No files to process"* ]]
}

# --- subdirectory handling ---

@test "files in subdirectory are processed" {
  mkdir -p "$WORKDIR/sub"
  echo '$VAR' > "$WORKDIR/sub/nested.txt"

  run run_envsubst -e VAR=value
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/sub/nested.txt")" = "value" ]
}

@test "subdirectory structure is preserved in output" {
  mkdir -p "$WORKDIR/a/b/c"
  echo '$X' > "$WORKDIR/a/b/c/deep.txt"

  run run_envsubst -e X=deep
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/a/b/c/deep.txt")" = "deep" ]
}

@test "files in root and subdirectory are both processed" {
  echo '$V' > "$WORKDIR/root.txt"
  mkdir -p "$WORKDIR/sub"
  echo '$V' > "$WORKDIR/sub/nested.txt"

  run run_envsubst -e V=ok
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/root.txt")" = "ok" ]
  [ "$(cat "$PROCESSED/sub/nested.txt")" = "ok" ]
}

# --- symlink / k8s configmap behavior ---

@test "symlinked file is processed (k8s configmap style)" {
  # Simulates how k8s mounts ConfigMaps:
  # real data lives in a timestamped dir, accessed via ..data symlink.
  # All symlinks must be relative so they resolve correctly inside the container.
  local TSNAME="..2024_01_01_00_00_00.000000000"
  mkdir -p "$WORKDIR/$TSNAME"
  echo '$APP_ENV' > "$WORKDIR/$TSNAME/config.txt"

  ln -s "$TSNAME" "$WORKDIR/..data"
  ln -s "..data/config.txt" "$WORKDIR/config.txt"

  run run_envsubst -e APP_ENV=production
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/config.txt")" = "production" ]
}

@test "files inside dotdot-prefixed directories are not written to output" {
  # Files that only exist inside ..data / ..timestamp dirs (no top-level symlink)
  # must not appear in $PROCESSED. All symlinks relative so they work in Docker.
  local TSNAME="..2024_01_01_00_00_00.000000000"
  mkdir -p "$WORKDIR/$TSNAME"
  echo '$VAR' > "$WORKDIR/$TSNAME/secret.txt"
  ln -s "$TSNAME" "$WORKDIR/..data"

  run run_envsubst -e VAR=exposed
  # Nothing should land in $PROCESSED
  [ -z "$(find "$PROCESSED" -type f 2>/dev/null)" ]
}

@test "regular symlink to file is followed and processed" {
  mkdir -p "$WORKDIR/real"
  echo '$MSG' > "$WORKDIR/real/actual.txt"
  ln -s "real/actual.txt" "$WORKDIR/link.txt"

  run run_envsubst -e MSG=followed
  [ "$status" -eq 0 ]
  [ "$(cat "$PROCESSED/link.txt")" = "followed" ]
}
