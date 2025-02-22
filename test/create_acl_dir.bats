setup() {
    load './test_helper/common-setup'
    _common_setup

    source "$PROJECT_ROOT/create_acl_dir.sh"
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

@test "main_create_acl_dir" {
    run main_create_acl_dir
    assert_success
    assert_output --partial 'create_acl_dir'
}