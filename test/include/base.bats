setup() {
    load '../test_helper/common-setup'
    _common_setup "include"

    source "$PROJECT_ROOT/include/base.sh"
}
teardown() {
    :
}
#: << HIDE
@test "Beispiel" {
    assert [ 1 -gt 0 ]
}

@test "Globale Variablen" {
    [[ -v ROOT_DIR  ]]
    [[ -f "${ROOT_DIR}/include/base.sh"  ]]
}

@test "Inklusionen" {
    [[ -v Grey  ]]

    [[ -v deepSkyBlue4_1  ]]
}

@test "inkonsistenzen" {
    declare -i declared_nnn            # Nicht gesetzte -i Variable
    run _is_number declared_nnn
        assert_failure 1
    run _var_type  declared_nnn
        assert_success
        assert_output "INT"
}

@test "_is_number" {
    local not_set_var
    local var
    local num=12345
    glob_n=123
    ref=13 # vorher in der Implementation verwendeter Variablenname

  # Fehler bei Anzahl Parameter und Erfolg bei Leerparametern und Zahl
    run _is_number                     # 0 Parameter
        assert_failure 2
    run _is_number $not_declared_var   # 0 Parameter nicht deklarierte $Variable
        assert_failure 2
    run _is_number $not_d1 $not_d1     # 0 Parameter $Variablen nicht deklariert
        assert_failure 2
    run _is_number $not_set_var        # 0 Parameter nicht gesetzte $Variable
        assert_failure 2
    run _is_number $not_set_var $var   # 0 Parameter $Variablen nicht gesetzt
        assert_failure 2
    run _is_number 1 2                 # mehr als 1 Parameter, Zahlen
        assert_failure 2
    run _is_number "ab" "cd"           # mehr als 1 Parameter, Strings
        assert_failure 2
    run _is_number $not_d1 num         # nicht deklarierte $Variable und Zahl
        assert_success
    run _is_number num $not_d1         # Zahl und nicht deklarierte $Variable
        assert_success
    run _is_number $not_set_var num    # nicht gesetzte $Variable und Zahl
        assert_success
    run _is_number num $not_set_var    # Zahl und nicht gesetzte $Variable
        assert_success
  # Fehler keine Zahl
    run _is_number not_declared_var    # Nicht deklarierte Variable
        assert_failure 1
    run _is_number not_set_var         # Nicht gesetzte Variable
        assert_failure 1
    declare -i declared_nnn            # Nicht gesetzte -i Variable
    run _is_number declared_nnn
        assert_failure 1
    run _is_number "abc"               # String
        assert_failure 1
    run _is_number b98765              # Buchstabe und Ziffern
        assert_failure 1
    run _is_number 2b                  # Ziffern und Buchstabe
        assert_failure 1
    var="string"
    run _is_number var                 # Auf String Gesetzte Variable
        assert_failure 1
    run _is_number $var                # Auf String Gesetzte $Variable
        assert_failure 1
    run _is_number "$var"              # Auf String Gesetzte "$Variable"
        assert_failure 1
  # Ok ist Zahl
    var=1
    run _is_number var                 # Auf Nummer gesetzte dekl. Variable
        assert_success
    run _is_number $var                # Auf Nummer Gesetzte dekl. $Variable
        assert_success
    run _is_number "$var"              # Auf Nummer Gesetzte dekl. "$Variable"
        assert_success
    auto_declared=12                   # Auf Nummer Gesetzte undekl. Variable
    run _is_number auto_declared
        assert_success
    run _is_number $auto_declared      # Auf Nummer Gesetzte undekl. $Variable
        assert_success
    run _is_number "$auto_declared"    # Auf Nummer Gesetzte undekl. "$Variable"
        assert_success
    run _is_number glob_n              # Auf Nummer Gesetzte globale Variable
        assert_success
    run _is_number ref                 # Gleichnamige Variable wie in _is_number
        assert_success
    run _is_number 98765               # Ziffern
        assert_success
    run _is_number "98765"             # String mit Ziffern
        assert_success
    run _is_number 0                   # Nur 0
        assert_success
    run _is_number "0"                 # String mit nur 0
        assert_success
    declare -i declared_n=2
    run _is_number declared_n          # Nummer in -i deklarierter Variable
        assert_success
    run _is_number $declared_n         # Nummer in -i deklarierter $Variable
        assert_success
    run _is_number "$declared_n"       # Nummer in -i deklarierter "$Variable"
        assert_success
    declare -i declared_nn="abc"       # String in -i deklarierter Variable
    run _is_number declared_nn
        assert_success
    run _is_number $declared_nn        # String in -i deklarierter $Variable
        assert_success
    run _is_number "$declared_nn"      # String in -i deklarierter "$Variable"
        assert_success
}

@test "_is_number_var" {
    local mein_s mein_i

    run _is_number_var
        assert_failure 2

    run _is_number_var 12 22
        assert_failure 2

    run _is_number_var $mein_s
        assert_failure 2

    run _is_number_var nichtda
        assert_failure 1

    run _is_number_var mein_s
        assert_failure 1

    run _is_number_var "dsafasdf"
        assert_failure 1

    run _is_number_var "b0"
        assert_failure 1

    mein_s="wert"
    run _is_number_var $mein_s
        assert_failure 1

    mein_i=887766
    run _is_number_var $mein_i
        assert_success

    run _is_number_var 12
        assert_success

    run _is_number_var "764012"
        assert_success
}

@test "_var_type" {
    i=1
    run _var_type $i
        assert_success
        assert_output "INT"

    declare -i ii=12
    run _var_type ii
        assert_success
        assert_output "INT"

    run _var_type $ii
        assert_success
        assert_output "INT"

    declare -a arr
        arr[0]="abc"
        arr[1]="def"
        arr[2]="hij"
    run _var_type arr
        assert_success
        assert_output "ARRAY"
    run _var_type $arr
        assert_success
        assert_output "STRING"

    run _var_type ${arr[@]}
        assert_failure 2

    run _var_type ${arr[*]}
        assert_failure 2

    run _var_type "${arr[@]}"
        assert_failure 2

    run _var_type "${arr[*]}"
        assert_success
        assert_output "STRING"


    declare -a a
        a[0]=11
        a[1]=22
        a[2]=33
    run _var_type a
        assert_success
        assert_output "ARRAY"

    run _var_type $a
        assert_success
        assert_output "INT"

    run _var_type ${a[@]}
        assert_failure 2

    run _var_type ${a[*]}
        assert_failure 2

    run _var_type "${a[@]}"
        assert_failure 2

    run _var_type "${a[*]}"
        assert_success
        assert_output "STRING"


    aa=(aa1 bc1 ac1 ed1 aee)
    run _var_type aa
        assert_success
        assert_output "ARRAY"

    run _var_type $aa
        assert_success
        assert_output "STRING"

    run _var_type ${aa[@]}
        assert_failure 2

    run _var_type ${aa[*]}
        assert_failure 2

    run _var_type "${aa[@]}"
        assert_failure 2

    run _var_type "${aa[*]}"
        assert_success
        assert_output "STRING"


    declare -A h
        h["red"]="#ff0000"
        h["green"]="#00ff00"
        h["blue"]="#0000ff"
    run _var_type h
        assert_success
        assert_output "MAP"

    run _var_type $h
        assert_failure 2

    run _var_type ${h[@]}
        assert_failure 2

    run _var_type ${h[*]}
        assert_failure 2

    run _var_type "${h[@]}"
        assert_failure 2

    run _var_type "${h[*]}"
        assert_success
        assert_output "STRING"


    declare -a test=( a b c d e)
    run _var_type test
        assert_success
        assert_output "ARRAY"
    declare -n mytest=test
    run _var_type mytest
        assert_success
        assert_output "ARRAY"
    declare -n newtest=mytest
    run _var_type newtest
        assert_success
        assert_output "ARRAY"
    declare -p newtest
    run _var_type newtest
        assert_success
        assert_output "ARRAY"
    declare -n newtest="mytest"
    run _var_type newtest
        assert_success
        assert_output "ARRAY"
    declare -p mytest
    run _var_type mytest
        assert_success
        assert_output "ARRAY"
    declare -n mytest="test"
    run _var_type mytest
        assert_success
        assert_output "ARRAY"

    declare -a test1=( 1 2 3 )
    run _var_type test1
        assert_success
        assert_output "ARRAY"
    declare -n mytest1=test1
    run _var_type mytest1
        assert_success
        assert_output "ARRAY"
    declare -n newtest1=mytest1
    run _var_type newtest1
        assert_success
        assert_output "ARRAY"
    declare -p newtest1
    run _var_type newtest1
        assert_success
        assert_output "ARRAY"
    declare -n newtest1="mytest1"
    run _var_type newtest1
        assert_success
        assert_output "ARRAY"
    declare -p mytest1
    run _var_type mytest1
        assert_success
        assert_output "ARRAY"
    declare -n mytest1="test1"
    run _var_type mytest1
        assert_success
        assert_output "ARRAY"

    declare -ix myint1=12
    run _var_type myint1
        assert_success
        assert_output "INT"

    declare -xig myint2=12
    declare -xug +l mystr1="str"
    declare -xugl mystr2="str"
    declare -rixg myread=22
    run _var_type myint2
        assert_success
        assert_output "INT"
    run _var_type myread
        assert_success
        assert_output "INT"
    run _var_type mystr1
        assert_success
        assert_output "STRING"
    run _var_type mystr2
        assert_success
        assert_output "STRING"


    declare -xaltu a
        a[0]=11
        a[1]=22
        a[2]=33
    run _var_type a
        assert_success
        assert_output "ARRAY"

    declare -xAltu h
        h["red"]="#ff0000"
        h["green"]="#00ff00"
        h["blue"]="#0000ff"
    run _var_type h
        assert_success
        assert_output "MAP"

    declare -alx test1=( a b c d e)
    # declare -xn test2=test1 Das x gibt hier Probleme - ist es überhaupt sinnig
    declare -n test2=test1
    declare -n test3=test2
    declare -n test4=test3
    declare -n test5=test4
    run _var_type test3
        assert_success
        assert_output "ARRAY"

}

@test "_var_type detailliert für Zahl" {
    glob_n=123
    ref=13 # vorher in der Implementation verwendeter Variablenname

    local not_set_var
    local var
    local num=12345

  # Fehler bei Anzahl Parameter und Erfolg bei Leerparametern und Zahl
    run _var_type                       # 0 Parameter
        assert_failure 2
    run _var_type $not_declared_var     # 0 Parameter nicht deklarierte $Variable
        assert_failure 2
    run _var_type $not_d1 $not_d1       # 0 Parameter $Variablen nicht deklariert
        assert_failure 2
    run _var_type $not_set_var          # 0 Parameter nicht gesetzte $Variable
        assert_failure 2
    run _var_type $not_set_var $var     # 0 Parameter $Variablen nicht gesetzt
        assert_failure 2
    run _var_type 1 2                   # mehr als 1 Parameter, Zahlen
        assert_failure 2
    run _var_type "ab" "cd"             # mehr als 1 Parameter, Strings
        assert_failure 2
    run _var_type $not_d1 num           # nicht deklarierte $Variable und Zahl
        assert_success
        assert_output "INT"
    run _var_type num $not_d1           # Zahl und nicht deklarierte $Variable
        assert_success
        assert_output "INT"
    run _var_type $not_set_var num      # nicht gesetzte $Variable und Zahl
        assert_success
        assert_output "INT"
    run _var_type num $not_set_var      # Zahl und nicht gesetzte $Variable
        assert_success
        assert_output "INT"
  # Fehler keine Zahl
    run _var_type not_declared_var      # Nicht deklarierte Variable
        assert_success
        refute_output "INT"
    run _var_type not_set_var           # Nicht gesetzte Variable
        assert_success
        refute_output "INT"
    declare -i declared_nnn            # Nicht gesetzte -i Variable
    run _var_type declared_nnn          # _is_number scheitert hier
        assert_success                 # _var_type
        assert_output "INT"
    run _var_type "abc"                 # String
        assert_success
        refute_output "INT"
    run _var_type b98765                # Buchstabe und Ziffern
        assert_success
        refute_output "INT"
    run _var_type 2b                    # Ziffern und Buchstabe
        assert_success
        refute_output "INT"
    var="string"
    run _var_type var                   # Auf String Gesetzte Variable
        assert_success
        refute_output "INT"
    run _var_type $var                  # Auf String Gesetzte $Variable
        assert_success
        refute_output "INT"
    run _var_type "$var"                # Auf String Gesetzte "$Variable"
        assert_success
        refute_output "INT"
  # Ok ist Zahl
    var=1
    run _var_type var                 # Auf Nummer gesetzte dekl. Variable
        assert_success
        assert_output "INT"
    run _var_type $var                # Auf Nummer Gesetzte dekl. $Variable
        assert_success
        assert_output "INT"
    run _var_type "$var"              # Auf Nummer Gesetzte dekl. "$Variable"
        assert_success
        assert_output "INT"
    auto_declared=12                   # Auf Nummer Gesetzte undekl. Variable
    run _var_type auto_declared
        assert_success
        assert_output "INT"
    run _var_type $auto_declared      # Auf Nummer Gesetzte undekl. $Variable
        assert_success
        assert_output "INT"
    run _var_type "$auto_declared"    # Auf Nummer Gesetzte undekl. "$Variable"
        assert_success
        assert_output "INT"
    run _var_type glob_n              # Auf Nummer Gesetzte globale Variable
        assert_success
        assert_output "INT"
    run _var_type ref                 # Gleicher Name wie vormals in _var_type
        assert_success               # Das geht bei nameref nicht, was dort
        assert_output "INT"          # verwendet werd
    run _var_type 98765               # Ziffern
        assert_success
        assert_output "INT"
    run _var_type "98765"             # String mit Ziffern
        assert_success
        assert_output "INT"
    run _var_type 0                   # Nur 0
        assert_success
        assert_output "INT"
    run _var_type "0"                 # String mit nur 0
        assert_success
        assert_output "INT"
    declare -i declared_n=2
    run _var_type declared_n          # Nummer in -i deklarierter Variable
        assert_success
        assert_output "INT"
    run _var_type $declared_n         # Nummer in -i deklarierter $Variable
        assert_success
        assert_output "INT"
    run _var_type "$declared_n"       # Nummer in -i deklarierter "$Variable"
        assert_success
        assert_output "INT"
    declare -i declared_nn="abc"       # String in -i deklarierter Variable
    run _var_type declared_nn
        assert_success
        assert_output "INT"
    run _var_type $declared_nn        # String in -i deklarierter $Variable
        assert_success
        assert_output "INT"
    run _var_type "$declared_nn"      # String in -i deklarierter "$Variable"
        assert_success
        assert_output "INT"
}

@test "_is_string" {
    local not_set_var
    local empty_string_var=""
    local var
  # Parameter errors
    run _is_string "ab" "cd"
        assert_failure 2
    run _is_string 1 2
        assert_failure 2
    run _is_string
        assert_failure 2
    run _is_string $not_set_var
        assert_failure 2
    run _is_string $not_declared_var
        assert_failure 2
  # not string
    run _is_string 1
        assert_failure 1
    declare -i declared_nnn
    run _is_string declared_nnn
        assert_failure 1
    arr=(aa1 bc1 ac1 ed1 aee)
    my_int=22
    run _is_string arr
        assert_failure 1
    run _is_string my_int
        assert_failure 1
    # ok, is string
    run _is_string not_declared_var
        assert_success
    run _is_string not_set_var
        assert_success
    run _is_string empty_string_var
        assert_success
    run _is_string "abc"
        assert_success
    run _is_string "abc def"
        assert_success

    run _is_string status_
        assert_success
    run _is_string typ
        assert_success
    run _is_string $status_
        assert_failure 2
    run _is_string $typ
        assert_failure 2
    run _is_string "$status_"
        assert_success
    run _is_string "$typ"
        assert_success
    local status
    local status_
    local typ
    run _is_string status
        assert_success
    run _is_string typ
        assert_success
    run _is_string $status_
        assert_failure 2
    run _is_string $typ
        assert_failure 2
    run _is_string "$status_"
        assert_success
    run _is_string "$typ"
        assert_success
    status="abcd"
    status_="abcd"
    typ="fghj"
    run _is_string status
        assert_success
    run _is_string typ
        assert_success
    run _is_string $status_
        assert_success
    run _is_string $typ
        assert_success
    run _is_string "$status_"
        assert_success
    run _is_string "$typ"
        assert_success
}

@test "_is_array" {
    local arr

    run _is_array "ab" "cd"
        assert_failure 2
    run _is_array
        assert_failure 2

    run _is_array 22
        assert_failure 1
    run _is_array "abc"
        assert_failure 1

    arr=(aa1 bc1 ac1 ed1 aee)
    run _is_array arr
        assert_success


    declare -a arr
        arr[0]="abc"
        arr[1]="def"
        arr[2]="hij"
    run _is_array arr
        assert_success
    run _is_array $arr
        assert_failure 1

    run _is_array ${arr[@]}
        assert_failure 2

    run _is_array ${arr[*]}
        assert_failure 2

    run _is_array "${arr[@]}"
        assert_failure 2

    run _is_array "${arr[*]}"
        assert_failure 1

}

@test "_is_map" {
    local map

    run _is_map "ab" "cd"
        assert_failure 2
    run _is_map
        assert_failure 2

    run _is_map 22
        assert_failure 1
    run _is_map "abc"
        assert_failure 1

    declare -A h
        h["red"]="#ff0000"
        h["green"]="#00ff00"
        h["blue"]="#0000ff"
    run _is_map h
        assert_success

    run _is_map $h
        assert_failure 2

    run _is_map ${h[@]}
        assert_failure 2

    run _is_map ${h[*]}
        assert_failure 2

    run _is_map "${h[@]}"
        assert_failure 2

    run _is_map "${h[*]}"
        assert_failure 1

}

@test "_is_array_or_map" {
    local arr map

    run _is_array_or_map "ab" "cd"
        assert_failure 2
    run _is_array_or_map
        assert_failure 2

    run _is_array_or_map 22
        assert_failure 1
    run _is_array_or_map "abc"
        assert_failure 1

    declare -a arr
        arr[0]="abc"
        arr[1]="def"
        arr[2]="hij"

    declare -A h
        h["red"]="#ff0000"
        h["green"]="#00ff00"
        h["blue"]="#0000ff"

    run _is_array_or_map arr
        assert_success
    run _is_array_or_map h
        assert_success
    run _is_array_or_map $a
        assert_failure 2
    run _is_array_or_map $h
        assert_failure 2
}

@test "_is_file" {
    run _is_file
        assert_failure 2
    run _is_file "cd" "sed"
        assert_failure 2

    run _is_file "/etc/passwd"
        assert_success

    run _is_file "/dev/stderr"
        assert_failure 1

    run _is_file "/proc/self/fd/2"
        assert_failure 1

}

@test "_is_dir" {
    run _is_dir
        assert_failure 2
    run _is_dir "cd" "sed"
        assert_failure 2

    run _is_dir "/etc"
        assert_success

    run _is_dir "/etc/passwd"
        assert_failure 1
}

@test "_is_command" {
    run _is_command
        assert_failure 2
    run _is_command "cd" "sed"
        assert_failure 2

    run _is_command "which"
        assert_success
    run _is_command awk
        assert_success
    run _is_command "keines_falls_da"
        assert_failure 1
    run _is_command "keines falls da"
        assert_failure 1
    run _is_command 232
        assert_failure 1
    run _is_command "cd ~"
        assert_failure 1
    run _is_command "ls -a"
        assert_failure 1
}

@test "_is_running_cmd" {
    run _is_running_cmd
        assert_failure 2

    run _is_running_cmd "nicht_da"
        assert_failure 1

    run _is_running_cmd "bash"
        assert_success
}

@test "_is_not_running_cmd" {
    run _is_not_running_cmd
        assert_failure 2

    run _is_not_running_cmd "bash"
        assert_failure 1

    run _is_not_running_cmd "nicht_da"
        assert_success

}

@test "_number_of_args_is" {
    run _number_of_args_is
        assert_failure 1
    run _number_of_args_is "abc"
        assert_failure 1

    run _number_of_args_is 1 "which"
        assert_success
    run _number_of_args_is 0
        assert_success
    run _number_of_args_is 4 "which" "what" 22 "über alle Meere"
        assert_success

    run _number_of_args_is 0 "which" "what" 22 "über alle Meere"
        assert_failure 2
    run _number_of_args_is 1 "which" "what" 22 "über alle Meere"
        assert_failure 2
    run _number_of_args_is 2 "which"
        assert_failure 2
    run _number_of_args_is 1
        assert_failure 2

}

@test "_number_of_args_gt" {
    run _number_of_args_gt
        assert_failure 1
    run _number_of_args_gt "abc"
        assert_failure 1

    run _number_of_args_gt 0
        assert_failure 2
    run _number_of_args_gt 0 "which"
        assert_success
    run _number_of_args_gt 4 "which" "what" 22 "über alle Meere"
        assert_failure 2

    run _number_of_args_gt 0 "which" "what" 22 "über alle Meere"
        assert_success

    run _number_of_args_gt 1 "which"
        assert_failure 2
    run _number_of_args_gt 1 "which" "what"
        assert_success
    run _number_of_args_gt 1 "which" "what" 22 "über alle Meere"
        assert_success
    run _number_of_args_gt 2 "which" "what"
        assert_failure 2
    run _number_of_args_gt 2 "which" "what" 22
        assert_success
}

@test "_number_of_args_lt" {
    run _number_of_args_lt
        assert_failure 1
    run _number_of_args_lt "abc"
        assert_failure 1

    run _number_of_args_lt 1 "which"
        assert_failure 2
    run _number_of_args_lt 0
        assert_failure 2
    run _number_of_args_lt 4 "which" "what" 22 "über alle Meere"
        assert_failure 2

    run _number_of_args_lt 0 "which" "what" 22 "über alle Meere"
        assert_failure 2
    run _number_of_args_lt 1 "which"
        assert_failure 2
    run _number_of_args_lt 1
        assert_success
    run _number_of_args_lt 2 "which"
        assert_success
    run _number_of_args_lt 2 "which" "what"
        assert_failure 2

}

@test "_" {
    run _
        assert_failure 2

    run _ "-nichtda"
        assert_failure 1
        assert_output "Msg is not found"

    run _ -9999999
        assert_failure 1
        assert_output "Msg is not found"

    run _ "-9999999"
        assert_failure 1
        assert_output "Msg is not found"

    run _ -0
        assert_success
        assert_output "Msg is not found"

    run _ "-0"
        assert_success
        assert_output "Msg is not found"

    run _ "-nichtda"
        assert_failure 1
        assert_output "Msg is not found"

    run _ -1
        assert_success
        assert_output "TEST TEST"

    run _ "-1"
        assert_success
        assert_output "TEST TEST"

    run _ "-testtest"
        assert_success
        assert_output "TEST TEST"

    run _ -testtest
        assert_success
        assert_output "TEST TEST"

    MSG[0]="Böser Fehler"
    MSG_MAP["behler"]="0"
    MSG[1]="SO SOLL ES SEIN"
    MSG_MAP["amen"]="1"
    MSG[42]="Das ist die Antwort"
    MSG_MAP["antwort"]="42"

    run _ "1"
        assert_success
        assert_output "SO SOLL ES SEIN"

    run _ "amen"
        assert_success
        assert_output "SO SOLL ES SEIN"

    run _ amen
        assert_success
        assert_output "SO SOLL ES SEIN"

}

@test "_warn " {

    # 1 Readonly function
    readonly -f | grep ' _warn$'
    # 2 Zu wenig Argumente
    run _warn
        assert_failure 2

    # 3 Zu viele Argumente
    run _warn "arg1_needed" 22
        assert_failure 2

    # 4 ok - das Newline kann ich nicht testen
    run _warn "Das darfst du nicht tun"
        warn="$(_ "-warn_sign")"
        assert_success
        assert_output --partial "$warn"
        assert_output --partial "Das darfst du nicht tun"
}

@test "_error" {
    run _error
    assert_failure 2

    run _error 1 -1001 "plumps"
        assert_failure 1
        assert_output "ERROR: Kein Kommando: plumps"

    run _error 1 "-no_command" "plumps"
        assert_failure 1
        assert_output "ERROR: Kein Kommando: plumps"

    run _error 1 -1002 3
        assert_failure 1
        assert_output "ERROR: Benötigte Anzahl von Argumenten: 3"

    run _error 1 "-nr_args_needed" 3
        assert_failure 1
        assert_output "ERROR: Benötigte Anzahl von Argumenten: 3"

    run _error 1 -1005 1
        assert_failure 1
        assert_output "ERROR: Muss ein String sein. Argument Nummer: 1"

    run _error 1 "-no_string" 1
        assert_failure 1
        assert_output "ERROR: Muss ein String sein. Argument Nummer: 1"

    run _error 1 -1006 "plumps"
        assert_failure 1
        assert_output "ERROR: Keine Datei: plumps"

    run _error 1 "-no_file" "plumps"
        assert_failure 1
        assert_output "ERROR: Keine Datei: plumps"

    run _error 1 "-no_file"
        assert_failure 1
        assert_output "ERROR: Keine Datei: "
}

@test "_am_root" {
    run _am_root 1 2 3
        assert_failure 2
    run _am_root
    if [[ "$(id -u)" -eq "0" ]]; then
        assert_success
    else
        assert_failure 1
    fi
}

@test "_exit_for_root" {
    run _exit_for_root
    if [[ "$(id -u)" -eq "0" ]]; then
        assert_failure 1
    else
        assert_success
    fi
}

@test "_last_number_in_file" {
    # 1 Readonly function
    readonly -f | grep ' _last_number_in_file$'

    # 2 Zu wenig Argumente
    run _last_number_in_file
        assert_failure 2

    # 3 Zu viele Argumente
    run _last_number_in_file "arg1_needed" 22
        assert_failure 2

    # 4 Datei gibt es nicht
    run _last_number_in_file "arg1_needed"
        assert_failure 1

    # 5 keine Ziffer in Datei
    echo " dasf xxxx " > test.file
    echo "a b c" >> test.file
    echo "q und noch was" >> test.file
    run _last_number_in_file "test.file"
        assert_failure 1
    rm test.file

    # 6 ok
    echo "1 dasf xxxx8 " > test.file
    echo "0 4 2" >> test.file
    echo "7 und noch was" >> test.file
    run _last_number_in_file "test.file"
        assert_success
        assert_output "7"
    rm test.file
}

@test "_long2short_opts" {
    run _long2short_opts --nicht-da
    assert_output "--nicht-da"

    run _long2short_opts 1 2 3
    assert_output "1 2 3"

    run _long2short_opts -n --help
    assert_output " -n -h"

    run _long2short_opts -e --help
    assert_output " -e -h"

    run _long2short_opts -E --help
    assert_output " -E -h"

    run _long2short_opts --help -n
    assert_output "-h -n"

    run _long2short_opts -e olla
    assert_output " -e olla"

    run _long2short_opts --help
    assert_output "-h"

    run _long2short_opts --dry "abc"
    assert_output "-d abc"

    run _long2short_opts --dry 123 345
    assert_output "-d 123 345"

    run _long2short_opts --help "abc"
    assert_output "-h abc"

    run _long2short_opts --dry "abc"
    assert_output "-d abc"

    run _long2short_opts --verbose "abc"
    assert_output "-v abc"
}

@test "_help" {
    run _help
        assert_failure 2

    run _help 1 2
        assert_failure 2

    run _help 1
        assert_success
        assert_output "1"

    run _help "abc\ndef\n"
        assert_success
        assert_output "abc\ndef\n"
}

@test "_value_of" {
    local vars_created local priv_created
    local vars_file="${PROJECT_DIR}/Vars"
    local priv_file="${PROJECT_DIR}/.Vars"
    if [[ ! -a  "${vars_file}" ]]; then
        echo "!!!ERZEUGE Vars:$vars_file"
        touch "${vars_file}"
        vars_created=1
    fi
    if [[ ! -a  "${priv_file}" ]]; then
        echo "!!!ERZEUGE Priv:$priv_file"
        touch "${priv_file}"
        priv_created=1
    fi
    echo "ab;ne ne;" >> "${vars_file}"
    echo "abc;def;" >> "${vars_file}"
    run _value_of "abc"
        assert_success
        assert_output "def"

    echo "abc;uvw;" >> "${priv_file}"
    run _value_of "abc"
        assert_success
        assert_output "uvw"

    if [[ -v vars_created ]]; then
        echo "!!!Lösche Vars"
        rm "${vars_file}"
    fi
    if [[ -v priv_created ]]; then
        echo "!!!Lösche Priv"
        rm "${priv_file}"
    fi
}

@test "main_base" {
    run main_base
    assert_success
    assert_output --partial 'base'
    assert_output --partial '_is_command'
}
#HIDE
