#!/usr/bin/env ./test/libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "Deploy with ENABLE_FORCE_RECREATE set to 1" {
  run make -f Makefile deploy ENABLE_FORCE_RECREATE=1
  [ "$status" -eq 0 ]  # Check if make deploy command succeeded
  echo "status code: $status"
  assert_output --partial "--force-recreate"
}

@test "Deploy with ENABLE_FORCE_RECREATE set to 0" {
  run make -f Makefile deploy ENABLE_FORCE_RECREATE=0
  [ "$status" -eq 0 ]  # Check if make deploy command succeeded
  echo "status code: $status"
  refute_output --partial "--force-recreate"
}


@test "Deploy with DISABLE_ANSI set to 1" {
  run make -f Makefile deploy DISABLE_ANSI=1
  [ "$status" -eq 0 ]
  echo "status code: $status"
  refute_output --partial "--ansi"
}

@test "Deploy with DISABLE_ANSI set to 0" {
  run make -f Makefile deploy DISABLE_ANSI=0
  [ "$status" -eq 0 ]
  echo "status code: $status"
  assert_output --partial "--ansi"
}


@test "Deploy with DISABLE_REMOVE_ORPHANS set to 1" {
  run make -f Makefile deploy DISABLE_REMOVE_ORPHANS=1
  [ "$status" -eq 0 ]  # Check if make deploy command succeeded
  echo "status code: $status"
  refute_output --partial "--remove-orphans"
}

@test "Deploy with DISABLE_REMOVE_ORPHANS set to 0" {
  run make -f Makefile deploy DISABLE_REMOVE_ORPHANS=0
  [ "$status" -eq 0 ]  # Check if make deploy command succeeded
  echo "status code: $status"
  assert_output --partial "--remove-orphans"
}


@test "Deploy with ENABLE_GIT_PULL set to 1" {
  run make -f Makefile deploy ENABLE_GIT_PULL=1
  [ "$status" -eq 0 ]
  echo "status code: $status"
  assert_output --partial "git pull"
}

@test "Deploy with ENABLE_GIT_PULL set to 0" {
  run make -f Makefile deploy ENABLE_GIT_PULL=0
  [ "$status" -eq 0 ]
  echo "status code: $status"
  refute_output --partial "git pull"
}


@test "Deploy with DISABLE_PULL set to 1" {
  run make -f Makefile deploy DISABLE_PULL=1
  [ "$status" -eq 0 ]  # Check if make deploy command succeeded
  echo "status code: $status"
  refute_output --partial "docker compose --ansi never -p bhasai pull"
}

@test "Deploy with DISABLE_PULL set to 0" {
  run make -f Makefile deploy DISABLE_PULL=0
  [ "$status" -eq 0 ]  # Check if make deploy command succeeded
  echo "status code: $status"
  assert_output --partial "docker compose --ansi never -p bhasai pull"
}