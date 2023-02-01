setup() {
    bats_load_library 'bats-support'
    bats_load_library 'bats-assert' 
    load "utils.bats"

    cd "tests/common" || exit 1
}

@test "make runs" {
    run "make"
    [ "$status" -eq 0 ]
    assert_output --partial "targets"
}

@test "make runs with debug enabled" {
    DEBUG=true \
      run "make" "debug.test"

    [ "$status" -eq 0 ]
    assert_output --partial "[DBG]"
}

@test "make runs using bash shell" {
    run "make" "debug.test"

    [ "$status" -eq 0 ]
    assert_output --partial "bash"
}

@test "make detects host and target platforms" {
    OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')"

    run "make" "debug.vars"

    [ "$status" -eq 0 ]

    assert_line --partial "TARGET_ARCH=${ARCH}"
    assert_line --partial "TARGET_OS=${OS}"
    assert_line --partial "TARGET_PLATFORM=${OS}_${ARCH}"
    assert_line --partial "HOST_ARCH=${ARCH}"
    assert_line --partial "HOST_OS=${OS}"
    assert_line --partial "HOST_PLATFORM=${OS}_${ARCH}"
}

@test "make sets common directory variables" {
    run "make" "debug.vars"
    [ "$status" -eq 0 ]

    COMMON_SELF_DIR="$(realpath "${PWD}/../../lib")"

    assert_line --partial "COMMON_SELF_DIR=${COMMON_SELF_DIR}"
    assert_line --partial "ROOT_DIR=${PWD}"
    assert_line --partial "CACHE_DIR=${PWD}/cache"
    assert_line --partial "OUTPUT_DIR=${PWD}/output"
    assert_line --partial "SCRIPTS_DIR=${PWD}/scripts"
}

@test "make lint checks for required binaries" {
    LINT_REQUIRED_BINS=non-existent \
      run "make" "lint"

    [ "$status" -eq 2 ]
    assert_line --partial "[ERR]"
}

@test "make test checks for required binaries" {
    TEST_REQUIRED_BINS=non-existent \
      run "make" "test"

    [ "$status" -eq 2 ]
    assert_line --partial "[ERR]"
}

@test "make clean removes output dir" {
    OUTPUT_DIR="output"
    mkdir "${OUTPUT_DIR}"

    run "make" "clean"

    [ "$status" -eq 0 ]
    [ ! -d "${OUTPUT_DIR}" ]
}

@test "make distclean removes output and cache dirs" {
    OUTPUT_DIR="output"
    CACHE_DIR="cache"

    mkdir "${OUTPUT_DIR}" "${CACHE_DIR}"

    run "make" "distclean"

    [ "$status" -eq 0 ]
    [ ! -d "${OUTPUT_DIR}" ]
    [ ! -d "${CACHE_DIR}" ]
}

@test "check targets with shellcheck" {
    ALL_TARGETS="$(make debug.targets)"

    for target in ${ALL_TARGETS}; do
	echo "cmd: make -n ${target} | ${SHELLCHECK_CMD}"
    	run bash -c "make -n ${target} | ${SHELLCHECK_CMD}"

	assert_output ""
    	[ "$status" -eq 0 ]
    done
}
