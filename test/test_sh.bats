setup() {
    load './test_helper/common-setup'
    _common_setup

    source "$PROJECT_ROOT/test_sh.sh"
}

teardown() {
    :
}

@test "Beispiel" {
    assert [ 1 -gt 0 ]
}

@test "Inklusionen" {
    [[ -v Grey  ]]

    [[ -v deepSkyBlue4_1  ]]
}

@test "requirements_are_met_test_sh" {
    run requirements_are_met_test_sh "include/base"
    assert_success

    run requirements_are_met_test_sh "include/base_"
    assert_failure 2
}
@test "main_test_sh" {
    local base="adsfadsfxse"
    local bats_file="test/${base}.bats"
      # Gelingend nicht ausführen, das ergäbe eine endlose Rekursion
    run main_test_sh
    assert_failure 2
    assert_output --partial 'test_sh'

    echo "   # xyz TODO abc" > "${base}.sh"
    chmod 777 "${base}.sh"
    touch "${bats_file}"

    run main_test_sh "${base}"
    assert_failure 1
    assert_output --partial "   # xyz TODO abc"
    assert_output --partial "${base}.sh enthält TODO Kommentare."

    echo "   # xyz todo abc" > "${base}.sh"
    run main_test_sh "${base}"
    assert_success
    assert_output --partial "   # xyz todo abc"
    assert_output --partial "${base}.sh enthält todo Kommentare."

    rm "${base}.sh"
    rm "${bats_file}"
}