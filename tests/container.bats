setup() {
    bats_load_library 'bats-support'
    bats_load_library 'bats-assert' 
    load "utils.bats"

    cd "tests/container" || exit 1
}

@test "make runs" {
    run "make"
    [ "$status" -eq 0 ]
    assert_output --partial "targets"
}

@test "make sets Buildah and Hadolint vars" {
    HADOLINT="hadolint"
    BUILDAH="buildah"

    run "make" "debug.vars"

    [ "$status" -eq 0 ]

    assert_line --partial "HADOLINT_CMD=${HADOLINT}"
    assert_line --partial "BUILDAH_CMD=${BUILDAH}"
}

@test "make finds all bash scripts" {
    TMP_DIR="$(mktemp -d ./test.XXX)"

    touch "${TMP_DIR}/Dockerfile" "${TMP_DIR}/aa.Dockerfile"

    # shellcheck disable=SC2016
    ARGS='echo "${DOCKERFILE_SRCS}"' run "make" "debug.cmd"

    rm -rf "${TMP_DIR}"

    [ "$status" -eq 0 ]

    assert_output "${TMP_DIR}/Dockerfile ${TMP_DIR}/aa.Dockerfile"
}

@test "make lint will fail on bad Dockerfile" {
    TMP_DIR="$(mktemp -d ./test.XXX)"
    # shellcheck disable=SC2016
    echo 'echo XXX' > "${TMP_DIR}/aa.Dockerfile"

    run "make" "lint"

    rm -rf "${TMP_DIR}"

    [ "$status" -eq 2 ]
    assert_line --partial "container.lint"
}
