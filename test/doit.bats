setup() {
    load './test_helper/common-setup'
    _common_setup

    source "$PROJECT_ROOT/doit.sh"
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

@test "main_doit" {
    run main_doit
    assert_success
    assert_output --partial 'doit'
}