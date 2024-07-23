#!/usr/bin/env ./test/libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

setup() {
  export MAKEFILE="./test/Makefile.mock"
}

@test "Deploy with ENABLE_FORCE_RECREATE set to 1" {   
  run make -f $MAKEFILE deploy ENABLE_FORCE_RECREATE=1
  [ "$status" -eq 0 ]
  assert_output --partial "--force-recreate"
}

@test "Deploy with ENABLE_FORCE_RECREATE set to 0" {
  run make -f $MAKEFILE deploy ENABLE_FORCE_RECREATE=0
  [ "$status" -eq 0 ] 
  refute_output --partial "--force-recreate"
}