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
      # Nicht gelingend nicht ausführen, das ergäbe eine nicht endlose Rekursion
    run main_test_sh
    assert_failure 2
    assert_output --partial 'test_sh'
}