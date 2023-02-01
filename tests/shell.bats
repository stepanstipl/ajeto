setup() {
    bats_load_library 'bats-support'
    bats_load_library 'bats-assert' 
    load "utils.bats"

    cd "tests/shell" || exit 1
}

@test "make runs" {
    run "make"
    [ "$status" -eq 0 ]
    assert_output --partial "targets"
}

@test "make sets Shellcheck and Bats vars" {
    SHELLCHECK="shellcheck -s bash"
    BATS="bats"
    BATS_LIB="$(brew --prefix)/lib"

    run "make" "debug.vars"

    [ "$status" -eq 0 ]

    assert_line --partial "SHELLCHECK_CMD=${SHELLCHECK}"
    assert_line --partial "BATS_CMD=${BATS}"
    assert_line --partial "BATS_LIB_PATH=${BATS_LIB}"
}

@test "make finds all bash scripts" {
    TMP_DIR="$(mktemp -d ./test.XXX)"

    touch "${TMP_DIR}/aa.sh" "${TMP_DIR}/bb.sh"

    # shellcheck disable=SC2016
    ARGS='echo "${SHELL_SRCS}"' run "make" "debug.cmd"

    rm -rf "${TMP_DIR}"

    [ "$status" -eq 0 ]

    assert_output "${TMP_DIR}/aa.sh ${TMP_DIR}/bb.sh"
}

@test "make finds all bats scripts" {
    TMP_DIR="$(mktemp -d ./test.XXX)"

    touch "${TMP_DIR}/aa.bats" "${TMP_DIR}/bb.bats"

    # shellcheck disable=SC2016
    ARGS='echo "${BATS_SRCS}"' run "make" "debug.cmd"

    rm -rf "${TMP_DIR}"

    [ "$status" -eq 0 ]

    assert_output "${TMP_DIR}/aa.bats ${TMP_DIR}/bb.bats"
}

@test "make lint will fail on bad bash" {
    TMP_DIR="$(mktemp -d ./test.XXX)"
    # shellcheck disable=SC2016
    echo 'echo $AA' > "${TMP_DIR}/aa.sh"

    run "make" "lint"

    rm -rf "${TMP_DIR}"

    [ "$status" -eq 2 ]
    assert_line --partial "shell.lint"
}

@test "make lint will fail on bad bats" {
    TMP_DIR="$(mktemp -d ./test.XXX)"
    # shellcheck disable=SC2016
    echo 'echo $AA' > "${TMP_DIR}/aa.bats"

    run "make" "lint"

    rm -rf "${TMP_DIR}"

    [ "$status" -eq 2 ]
    assert_line --partial "shell.lint"
}

@test "make test runs bats tests" {
    TMP_DIR="$(mktemp -d ./test.XXX)"
    echo '@test "test bats" {}' > "${TMP_DIR}/aa.bats"

    run "make" "test"

    rm -rf "${TMP_DIR}"

    [ "$status" -eq 0 ]
    assert_line --partial "shell.test"
    assert_line --partial "test bats"
    # interactive output is different to TAP one
    assert_line --partial "ok 1 test bats"
}

# bats test_tags=debug
@test "make test fails on failing bats test" {
    TMP_DIR="$(mktemp -d ./test.XXX)"
    echo '@test "test bats" { false }' > "${TMP_DIR}/aa.bats"

    run "make" "test"

    rm -rf "${TMP_DIR}"

    [ "$status" -eq 2 ]
    assert_line --partial "shell.test"
    # interactive output is different to TAP one
    assert_line --partial "not ok 1"
}
