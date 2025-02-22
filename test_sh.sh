#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Führt die Tests shellcheck und bats für Script Datei BASE.sh aus
  # :name: test_sh.sh
  # :type: script
  # :requ: shellcheck und bats müssen über PATH aufgerufen werden können;
  #        die Dateien BASE.sh und test/BASE.bats müssen existieren;
  #        die Datei BASE.sh muß ausführbar sein
  # :para: 1/BASE - Name des zu testenden Scripts ohne Erweiterung;
  #                 relativ zu test_sh.sh
  #                  falls nicht im test_sh.sh-Verzeichnis Pfad davor.
  #                  Aufruf für my_script.sh:   []$ test_sh my_script
  #                  Aufruf für my_dir/test.sh: []$ test_sh my_dir/test
  # :desc: BASE wird zu BASE.sh und zu test/BASE.bats aufgelöst. Über BASE.sh
  #        wird shellcheck laufen gelassen und danach werden die tests in
  #        test/BASE.bats auf es angewandt.
  # :stat: 1 falls shellcheck oder bats nicht ausführbar sind oder falls die
  #          Datei test/BASE.bats nicht existiert
  #        2 falls BASE.sh keine ausführbare Datei ist oder falls mehr als
  #          ein Argument übergeben wurde.
  #        1 falls shellcheck oder bats fehlschlagen
  #        0 Falls die Formatierung stimmt und alle Tests laufen
  # :retu: Return value in Freitext
#
#
# SOURCES:
. "$(dirname "${BASH_SOURCE[0]}")/include/base.sh"
#
_exit_for_root
# Dateiglobalen Variablen
tag="${Grey}${blue}test_sh >> ${clr}"
#dbg="${Yellow}${red}"
#dbg0="${clr}"
dry=0
verbose=0
#
# :: Gibt die Hilfe aus
  # :name: help_test_sh
  # :type: procedure
  # :scop: readonly
help_test_sh () {
    local description
    read -r -d '' description <<- 'DESCRIPTION'
	AUFRUF: test_sh.sh -h
	        test_sh.sh --help
	        test_sh.sh -v Verbose
	        test_sh.sh -d Dry
	        test_sh.sh [-s] BASE
	Führt shellcheck und bats-core tests für BASE.sh aus, sucht nach Todos

	BASE ist der Name des zu testenden Shell scripts ohne extension *.sh.
	    Die Datei muß aber eine Extension *.sh haben
	    BASE kann auch einen Pfad relativ zu PWD enthalten
	    Eine Datei PWD/test/BASE.bats muß existieren
	    Die Option -s verhindert das Ausführen von shellcheck

	    Enthält die Datei TODO in Kommentarzeilen mit einem # davor, wird mit
	    Fehlercode abgebrochen. Ist der Todo String klein geschrieben "todo"
	    wird nur eine Meldung ausgegeben, aber Erfolg gemeldet.
	DESCRIPTION

    _help "${description}"
};readonly -f help_test_sh
#
# :: Gibt zurück, ob alle Voraussetzungen für das Script erfüllt sind
  # :name: requirements_are_met
  # :type: func
  # :pars: PARA Alle Parameter des Aufrufs des Scripts
  # :pars: Alle Parameter des Aufrufs des Scripts
  # :para: 1/BASE - Name des zu testenden Scripts ohne Erweiterung;
  # :desc: Tests für alle Voraussetzungen, die erfüllt sein müssen, damit eine
  #        Funktion  ausgeführt werden kann, werden hier mit den an die
  #        aufrufenden Funktion übergebenden Argumenten ausgeführt.
  #        Ist eine Voraussetzung nicht erfüllt, wird eine Fehlermeldung
  #        ausgegeben und ein Fehlerstatus zurückgegeben. Folgende Tests werden
  #        nicht ausgeführt.
  #        Wenn alle Tests bestanden wurden, wird der Status 0 zurückgegeben
  # :stat: 0, falls ok
  #        1, falls Kommando shellcheck nicht gefunden wird
  #        1, falls Kommando test/bats/bin/bats nicht gefunden wird
  #        2, falls Anzahl PARS nicht 1 ist
  #        2, falls BASE kein String ist
  #        2, falls BASE".sh" keine Datei ist
  #        2, falls BASE".sh" nicht ausführbar ist
  #        1, falls die Datei test/BASE.bats nicht existiert
  # :retu: falls nicht ok, wird eine Fehlermeldung aus-/zurück-gegeben
  # :scop: readonly
function requirements_are_met_test_sh {
    _is_command "shellcheck"
    _error $? "-no_command" "shellcheck" || return 1

    _is_command "${ROOT_DIR}/test/bats/bin/bats"
    _error $? "-no_command" "${ROOT_DIR}/test/bats/bin/bats" || return 1

    _number_of_args_is 1 "$@"
    _error $? "-nr_args_needed" 1 || return 2

    _is_string "$1"
    _error $? "-no_string" "$1" || return 2

    pwd_dir="$(pwd)"
    _is_file "${pwd_dir}/$1.sh"
    _error $? "-no_file" "${ROOT_DIR}/$1.sh" || return 2

    _is_command "${pwd_dir}/$1.sh"
    _error $? "-no_command" "${ROOT_DIR}/$1.sh" || return 2

    _is_file "${pwd_dir}/test/$1.bats"
    _error $? "-no_command" "${ROOT_DIR}/test/$1.bats" || return 1

    return 0
}; readonly -f requirements_are_met_test_sh
#
# :: Führt das Script aus
  # :name: main
  # :type: procedure
  # :desc: main wird nur ausgeführt, falls das Script direkt aufgerufen wird,
  #        dies wird durch den bedingten Aufruf hinter der Funktionsdefinition
  #        bewirkt.
  # :expl: Aufrufe:
  #        pwd: /home/OneDrive/Scripts/fus4sh
  #          test_sh doit
  #          test_sh include/base
  #        pwd: /home/OneDrive/Scripts
  #          fus4sh/test_sh.sh doit
  #          fus4sh/test_sh.sh include/base
  #        ~
  #          /home/OneDrive/Scripts/fus4sh/test_sh.sh -s doit
  #          /home/OneDrive/Scripts/fus4sh/test_sh.sh include/base
  # :impl: Das Skript kann von überall her aufgerufen werden, der Pfad des
  #        Skriptes ist damit relativ zu pwd
  #        Die verwendeten Dateien zum Testen sind relativ zum Skript.
  #        Das Argument ist relativ zum Skript
  # :scop: readonly
main_test_sh() {
    echo "In test_sh.sh"
  # Variablen
    local arg1 pwd_dir
    local do_shellcheck=1
    local file bats_file
  #
  # Argumente
    #shellcheck disable=2046 disable=2312
    set -- $( _long2short_opts "$@" )
    while getopts dhvs opt; do
        case ${opt} in
            h) help_test_sh; exit 0;;
            d) dry=1;;
            v) verbose=1;;
            s) do_shellcheck=0;;
            ?) help_test_sh; exit 2;;
            *) help_test_sh; exit 2;; # für shellcheck
        esac
    done
    shift $((OPTIND-1))
    requirements_are_met_test_sh "$@"  || exit $?
    arg1="$1"
    pwd_dir="$(pwd)"
    file="${pwd_dir}/${arg1}.sh"
    bats_file="${pwd_dir}/test/${arg1}.bats"
  #
  # Arbeit
    if (( verbose )); then
        echo -e "${tag}grep -e \"^ *#.*TODO\" ${file}"
    fi
    if (( ! dry )); then
        if grep -e "^ *#.*TODO" "${file}" ; then
            echo "${file} enthält TODO Kommentare. Mit TODOs wird nicht eingecheckt."
            exit 1
        fi
    fi
    if (( verbose )); then
        echo -e "${tag}grep -e \"^ *#.*todo\" ${file}"
    fi
    if (( ! dry )); then
        if grep -e "^ *#.*todo" "${file}" ; then
            echo "${file} enthält todo Kommentare."
        fi
    fi

    if [[ ${do_shellcheck} -gt 0 ]]; then
        if (( verbose )); then
            echo -e "${tag}shellcheck -x -o all \"${file}\""
        fi
    if (( ! dry )); then
            echo -n "Shellcheck ..."
            shellcheck -x -o all "${file}"
            echo
        fi
    fi
    if (( verbose )); then
        echo -e "${tag}${pwd_dir}/test/bats/bin/bats \"${bats_file}\""
    fi
    if (( ! dry )); then
        #shellcheck disable=2181
        if [[ $? -eq 0 ]]; then
            "${pwd_dir}"/test/bats/bin/bats "${bats_file}"
        fi
    fi
}; readonly -f main_test_sh
#
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_test_sh "$@"
fi