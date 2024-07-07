#!/usr/bin/env ./test/libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

# Integration test running against the actual Makefile and deployment scripts
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
