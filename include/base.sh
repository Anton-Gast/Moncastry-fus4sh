#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Funktionssammlung für andere Scripte
  # :name: base
  # :proj: fus4sh/Moncastry
  # :type: module
  # :desc: Enthält Funktionen, die von anderen Scripten aufgerufen werden können.
  #        Enthält globale Variablen für alle inkludierenden Scripte.
  #        Der Aufruf dieser Sammlung als Script zeigt die Namen der Funktionen
  #        mit einer Kurzbeschreibung an.
  #
  #        Wenn base.sh inkludiert wird, hat man Zugriff auf alle Funktionen von
  #        fus4sh.
  #
  #        Damit base.sh inkludiert werden kann, muß das
  #        inkludierende Projekt wissen, wo fus4sh zu finden ist.
  #        Dazu sind zwei Möglichkeiten denkbar:
  #        a) Es ist eine Umgebungsvariable für fus4sh gesetzt.
  #        b) Diese Datei base.sh wird direkt mit Pfad inkludiert
  #
  #        Die Projekte der Moncastry Suite stellen beide Möglichkeiten zur
  #        Verfügung.
  #        a) Die Umgebungsvariable SCRIPT_DIR ist auf das parent directory von
  #           fus4sh gesetzt.
  #           Der Pfad zu dieser Datei würde dann sein:
  #           SCRIPT_DIR/fus4sh/include/base.sh
  #        b) fus4sh ist unter diesem Namen ins Wurzelverzeichnis des Projektes
  #           verlinkt.
  #           Das Wurzelverzeichnis wird dadurch erkannt, daß es als unterstes
  #           im Pfad der inkludierenden Datei eine Datei Makefile enthält.
  #           Dieses Wurzelverzeichnis kommt in die Variable PROJECT_DIR.
  #           Die Struktur für diese Datei würde dann sein:
  #           PROJECT_DIR/
  #               Makefile
  #               inkludierendes_script.sh
  #               xyz/anderes_inkludierendes_script.sh
  #           fus4sh@
  #           Der Pfad zu dieser Datei wäre dann
  #           PROJECT_DIR/fus4sh/include/base.sh
  #
  #        Falls die Umgebungsvariable SCRIPT_DIR gesetzt ist und falls sie
  #        korrekt gesetzt ist (id est fus4sh damit gefunden werden kann), wird
  #        diese verwendet und nicht mehr über einen möglichen Link gesucht.
  #
  #        Falls ein Wurzelverzeichnis für das direkt inkludierende Projekt
  #        gefunden wird, wird die Variable PROJECT_DIR readonly.
  # :deps: colors.dat messages.dat
#
#
# DIRECTORIES Variablen
# =====================
# :: Wurzelverzeichnis dieser Sammlung von Skripten.
  # :name: ROOT_DIR
  # :type: variable
  # :desc: Der Name des Wurzelverzeichnisses von fus4sh ist auch fus4sh.
  #        In diesem Wurzelverzeichnis befinden sich eigenständige Skripte,
  #        die dazu gedacht sind, von aussen als Befehl aufgerufen zu werden.
  #        Im Unterverzeichnis include/ befinden sich Script Dateien mit
  #        Funktionen. Wenn include/base.sh als SOURCE verwendet wird, kann
  #        auf alle Funktionen von fus4sh zugegriffen werden.
  # :scop: readonly
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    ROOT_DIR="${ROOT_DIR%/include}" # entfernt trailing "/include"
    readonly ROOT_DIR
#
# :: Verzeichnis der Scripte für den angemeldeten USER
  # :name: SCRIPT_DIR
  # :type: variable
  # :desc: Wenn fus4sh ein Unterverzeichnis von SCRIPT_DIR ist, wird es von
  #        den Projekten der Moncastry Suite so gefunden.
  #
  # :scop: readonly
if ! [[ -v SCRIPT_DIR ]]; then
    SCRIPT_DIR="/home/${LOGNAME}/Scripts"
    echo "Setzte SCRIPT_DIR als Fallback auf ${SCRIPT_DIR}"
    fi
    export SCRIPT_DIR
    readonly SCRIPT_DIR
#
# :: Wurzelverzeichnis des inkludierenden Projekts
  # :name: PROJECT_DIR
  # :type: variable
  # :desc: Für das inkludierend Projekt wo das Makefile und die Datei Vars sind.
  #        Wenn collection alleine verwendet wird, ist PROJECT_DIR gleich
  #        ROOT_DIR.
  # :expl: Das aufrufende Projekt sei txt2db
  #        collection > SCRIPT_DIR:/home/OneDrive/Scripts
  #        collection > ROOT_DIR:$SCRIPT_DIR/collection
  #        collection > PROJECT_DIR:$ROOT_DIR
  #        txt2db > SCRIPT_DIR:/home/OneDrive/Scripts
  #        txt2db > ROOT_DIR:$SCRIPT_DIR/collection
  #        txt2db > PROJECT_DIR:/home/OneDrive/Projekte/txt2db
  # :scop: export
PROJECT_DIR="${ROOT_DIR}"
    export PROJECT_DIR
    if [[ -v "BASH_SOURCE[1]" ]]; then
        prj_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" &>/dev/null && pwd)";
        while [[ "${prj_dir}" != "" ]]; do
            if ls "${prj_dir}/Makefile" &>/dev/null; then break; fi
            prj_dir="${prj_dir%/*}"; done
        if [[ "${prj_dir}" != "" ]]; then
            PROJECT_DIR="${prj_dir}";readonly PROJECT_DIR; fi
        unset prj_dir; else readonly PROJECT_DIR; fi
  # Unterstützung für inkludierende Projekte, aber nicht bats-core
    cnt=${#BASH_SOURCE[@]};(( --cnt ))
    last="${BASH_SOURCE[cnt]}"
    has="${BASH_SOURCE[cnt]%%/bats-core/*}"
    if [[ "${last}" != "${has}" ]]; then :; else
    if (( ${#BASH_SOURCE[@]} > 2 )); then           # SOURCE von anderem Projekt
    if [[ "${SCRIPT_DIR}/fus4sh" != "${ROOT_DIR}" ]]; then # SCRIPT_DIR falsch
        echo "Inklusion über direkten Pfad."
        echo "    \"${SCRIPT_DIR}/fus4sh\" nicht vorhanden."
    if [[ "${PROJECT_DIR}/fus4sh" != "${ROOT_DIR}" ]]; then # PROJECT_DIR falsch
        echo "Keine automatische Inklusion möglich."
        echo "    \"${PROJECT_DIR}/fus4sh\" auch nicht vorhanden."
        echo "    Setzen Sie die Umgebungsvariable \"SCRIPT_DIR\""
        echo "    auf \"${ROOT_DIR%/*}\""
        echo "    oder verlinken Sie \"${ROOT_DIR}\""
        echo "    nach \"${PROJECT_DIR}/fus4sh\""
    fi
    fi
    fi
    fi
#
# Globale Variablen und Includes
# ==============================
. "${ROOT_DIR}/include/colors.dat"
#
# :: Array fest kodierter Nachrichten
  # :name: _MSG
  # :type: variable
  # :desc: _MSG ist ein Array in dem alle Texte, die von dieser
  #        Sammlung zur Verfügung gestellt werden, enthalten sind.
  #        Die Funktion _ sucht darin nach Nachrichten, die mit negativen
  #        Zahlen referenziert werden
  # :scop: readonly
declare -ag _MSG
#
# :: Map fest kodierter Nachrichten
  # :name: _MSG_MAP
  # :type: variable
  # :desc: _MSG_MAP ist eine Map, die die numerischen Schlüssel von _MSG mit
  #        einem menschenlesbaren Schlüssel (Kenner) verbindet
  #        Die Funktion _ sucht darin nach Nachrichten, die mit einem String
  #        bestehend aus "-" und dem Kenner referenziert werden
  #        Der Kenner selbst beginnt nicht mit "-".
  # :scop: readonly
declare -Ag _MSG_MAP
#
. "${ROOT_DIR}/include/messages.dat"
    readonly _MSG
    readonly _MSG_MAP
#
# :: Array für Nachrichten, kann vom inkludierenden Projekt gefüllt werden
  # :name: MSG,
  # :type: variable
  # :desc: MSG ist ein Array, in das ein aufrufendes Projekt mit Nachrichten
  #        füllen kann.
  #        Die Funktion _ sucht darin nach Nachrichten, die mit positiven
  #        Zahlen referenziert werden
  # :scop: export
declare -ag MSG
    export MSG
#
# :: Map für Nachrichten, kann vom inkludierenden Projekt gefüllt werden
  # :name: MSG_MAP
  # :type: variable
  # :desc: MSG_MAP ist eine Map, die die numerischen Schlüssel von MSG mit
  #        einem menschenlesbaren Schlüssel (Kenner) verbindet
  #        Die Funktion _ sucht darin nach Nachrichten, die mit einem String
  #        String Kenner referenziert werden
  # :scop: export
declare -Ag MSG_MAP
    export MSG_MAP
#
# :: Modul intern benutzte Variablen, die Aufrufer meiden müssen
  # :name: __DAHEIM_MONC_VAR[0..9]__
  # :type: variable
  # :desc: Manche Funktionen des Moduls verwenden Parameter by reference.
  #        Dazu wird vom externen Aufrufer als Argument der Name "name" einer
  #        Variable übergeben. Dieser wird lokal in der Funktion dieses Moduls
  #        mit "local -n name_ref=$n" dereferenziert. Damit werden "name_ref"
  #        und "name" identifiziert, sie sind beide eins. Sowohl die Zuweisung
  #        eines neuen Wertes an "name_ref" verändert den Wert der Variable als
  #        auch die Zuweisung eines neuen Wertes an "name". Sobald "name" in der
  #        lokalen Funktion (dieses Moduls) als local deklariert ist, verändern
  #        Zuweisungen an "name" und auch an "name_ref" nur mehr die lokale
  #        Variable.
  #:
  #        Wenn "name_reference" gleich "name" ist, kommt es zu einem Zirkel.
  #        Laut https://tiswww.case.edu/php/chet/bash/NEWS Punkt 1.i. bash-5.0:
  #          "i. A nameref name resolution loop in a function now resolves to a
  #           variable by that name in the global scope."
  #        ist das teilweise gelöst. Wenn der Aufrufer die Variable als local
  #        deklariert hat, funktioniert das nicht.
  #:
  #        Dieses Modul kann Namenskonflikte nicht sicher ausschließen. Doch
  #        in den kritischen Fällen der Dereferenzierung werden die Variablen
  #        __DAHEIM_MONC_VAR0__ - __DAHEIM_MONC_VAR9__ verwendet.
  # :warn: __DAHEIM_MONC_VAR0__ - __DAHEIM_MONC_VAR9__ sollten von
  #        aufrufenden Scripten nicht verwendet werden.
  #        Werden diese Variablen im aufrufenden Code verwendet, kann es zu
  #        unvorhersehbaren und schwer zu findenden Fehlern kommen.
declare __DAHEIM_MONC_VAR0__ __DAHEIM_MONC_VAR1__ \
        __DAHEIM_MONC_VAR2__ __DAHEIM_MONC_VAR3__ \
        __DAHEIM_MONC_VAR4__ __DAHEIM_MONC_VAR5__ \
        __DAHEIM_MONC_VAR6__ __DAHEIM_MONC_VAR7__ \
        __DAHEIM_MONC_VAR8__ __DAHEIM_MONC_VAR9__
#
# Funktionen
# ==========
# :: Gelingt, falls ARG eine natürliche Zahl ist
  # :name: _is_number
  # :type: statement
  # :pref: 1/ARG - Zu prüfender Wert, als Referenz, Variable oder direkt
  # :desc: Für den Erfolg kann eine Variablenreferenz übergeben werden, die eine
  #        natürliche Zahl (inkl. 0) enthält, oder eine Variable, die eine
  #        natürliche Zahl (inkl. 0) enthält oder direkt eine natürlich Zahl
  #        (inkl. 0) oder ein String, der eine natürlich Zahl (inkl. 0) enthält.
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls ARG eine natürliche Zahl referenziert oder ist oder ein
  #            String ist, der (nur) eine natürliche Zahl enthält
  #        1 - sonst
  # :deps: Keine Abhängigkeiten
  # :expl: Beispiele erfolgreicher Aufrufe:
  #        var=876
  #        _is_number var
  #        _is_number $var
  #        _is_number "$var"
  #        _is_number 678
  #        _is_number "678"
  # :also: _var_type :hint:
  # :impl: Verwendet geschützte Namen für Variablen, da sie
  #        Argumente dereferenziert.
  # :scop: readonly
function _is_number {
    (( $# != 1 )) && return 2

    local __DAHEIM_MONC_VAR1__='^[0-9]+$'

      ## Erkennt direkt übergebene natürliche Zahlen (matched nur Ziffern)
    if [[ $1 =~ ${__DAHEIM_MONC_VAR1__} ]]; then
        return 0
    fi

      ## -n dereferenziert übergebenen Variablennamen
       ## Bei einer undeklarierten Variable werden Fehlermeldungen
       ## ausgegeben, deswegen wird die Error Ausgabe verborgen
       ## In einigen Sonderfällen schlägt die Zuweisung fehl, bekannt ist
       ##  - 2b, Name, der mit einer Ziffer beginnt, gefolgt von Buchstaben
       ##  - "${arr[*]}", wobei arr ein initialisiertes Array ist
       ##    der Aufruf ${arr[*]} (ohne Anführungszeichen) gelingt
       ## Wenn es fehlschlägt handelt es sich sicher nicht um eine
       ## natürliche Zahl (inkl. 0)
    declare -n __DAHEIM_MONC_VAR0__=$1 2>/dev/null
    (( $? == 1 )) && return 1

      ## Erkennt natürliche Zahlen in referenzierter Variable (Ziffernmatch)
    if [[ ${__DAHEIM_MONC_VAR0__} =~ ${__DAHEIM_MONC_VAR1__} ]]; then
        return 0
    fi

    return 1
}; readonly -f _is_number
#
# :: Gelingt, falls VAR eine natürliche Zahl ist
  # :name: function _is_number_var
  # :type: statement
  # :para: 1/VAR - Zu prüfender Wert, als Variable oder direkt, keine Referenz
  # :desc: für den Erfolg kann eine Variable, die eine natürliche Zahl (inkl. 0)
  #        enthält oder direkt eine natürlich Zahl (inkl. 0) oder ein String,
  #        der eine natürlich Zahl (inkl. 0) enthält übergeben werden
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls VAR eine natürliche Zahl oder ist oder ein
  #            String ist, der (nur) eine natürliche Zahl enthält
  #        1 - sonst
  # :deps: Keine Abhängigkeiten
  # :expl: Beispiele erfolgreicher Aufrufe:
  #        var=876
  #        _is_number_var $var
  #        _is_number "$var"
  #        _is_number 678
  #        _is_number "678"
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _is_number_var {
    (( $# != 1 )) && return 2

    local __DAHEIM_MONC_VAR4__='^[0-9]+$' # reg

    if [[ $1 =~ ${__DAHEIM_MONC_VAR4__} ]]; then
        return 0
    fi

    return 1
}; readonly -f _is_number_var
#
# :: Gibt den Variablentyp "ARRAY", "MAP", "INT" oder "STRING" zurück
  # :name: _var_type
  # :type: function
  # :pref: 1/ARG - Zu prüfender Wert, als Referenz, Variable oder direkt
  # :desc: Überprüft, ob ARG eine natürliche Zahl (inkl. 0),ein Array oder eine
  #        Map ist, ansonsten wird es als String betrachtet.
  #        Dabei kann ARG eine Referenz sein, jede Art von Variable, auch
  #        deklarierte, aber uninitialisiert, oder auch ein direkter
  #        Ziffernwert
  # :hint: declare -i declared_uninitialized_n, kein Wert zugewiesen
  #        _var_type declared_uninitialized_n gelingt und gibt "INT" zurück
  #        _is_number declared_uninitialized_n schlägt mit Status 1 fehl
  # :todo: Entscheiden, ob uninitialisierte INT fehlschlagen sollen
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - sonst
  # :retu: bei stat=0 einer der folgenden Werte: "ARRAY", "MAP", "INT", "STRING"
  #        bei stat=2 nichts
  # :deps: _is_number
  # :impl: Verwendet geschützte Namen für Variablen, da sie
  #        Argumente dereferenziert.
  # :scop: readonly
function _var_type {
    (( $# != 1 )) && return 2

    local __DAHEIM_MONC_VAR0__ # entspricht local dec
    local __DAHEIM_MONC_VAR1__='^declare -n [^=]+=\"([^\"]+)\"$'
    local __DAHEIM_MONC_VAR2__='^declare -[-x] .*'

    __DAHEIM_MONC_VAR0__=$( declare -p "$1" 2>/dev/null )
    #! echo "!!! DEC:${__DAHEIM_MONC_VAR0__}; °0"
      ## Kann z.B. sein: declare -n test3="test2";
      ## Solange in $dec "declare -n" drinsteht ersetze dec durch
      ## den Teil nach dem "=" und ohne die Anführungszeichen
      ## Am Ende steht in dec die Deklaration der definierenden Variable
    while [[ ${__DAHEIM_MONC_VAR0__} =~ ${__DAHEIM_MONC_VAR1__} ]]; do
        __DAHEIM_MONC_VAR0__=$(declare -p "${BASH_REMATCH[1]}" 2>/dev/null)
        #! echo "        DEC:${__DAHEIM_MONC_VAR0__}; °1"
    done

    #! echo "    DEC:${__DAHEIM_MONC_VAR0__}; °2"
      ## Direkt übergebene Werte und Werte von Variablen ($var) haben keine
      ## Deklaration
      ## Arrays und Maps kann man nicht als Wert oder undeklariert übergeben
      ## undeklarierte Variablen werden anhand von "declare --" erkannt
      ## undeklarierte exportierte Variablen anhand von "declare -x"
      ## _is_number prüft in jedem Fall den Wert darauf, ob er eine
      ## natürliche Zahl (inkl. 0) ist
    if [[ -z ${__DAHEIM_MONC_VAR0__} || \
                        ${__DAHEIM_MONC_VAR0__} =~ ${__DAHEIM_MONC_VAR2__} ]]; then
        _is_number "$1" && _ "-int" && return 0
    fi

    #! echo "    DEC:${__DAHEIM_MONC_VAR0__}; °3"
      ## Alle undeklarierten natürlichen Zahlen (inkl.0) wurden schon ausgegeben
      ## Arrays und Maps können nie undeklariert sein
      ## Alles, was jetzt nicht mit -a, -A oder -i deklariert ist
      ## wird als STRING betrachtet
    case "${__DAHEIM_MONC_VAR0__#declare -}" in
        a*) _ "-arr" ;;
        A*) _ "-map" ;;
        i*) _ "-int" ;;
        * ) _ "-str" ;;
    esac

    return 0
}; readonly -f _var_type
#
# :: Gelingt, falls ARG ein String ist ist
  # :name: _is_string
  # :type: statement
  # :pref: 1/ARG - Zu prüfender Wert, als Referenz, Variable oder direkt
  # :desc: Überprüft, ob ARG keine natürliche Zahl (inkl. 0),kein Array und
  #        keine Map ist; falls das zutrifft, gelingt der Aufruf.
  #        Dabei kann ARG eine Referenz sein, jede Art von Variable, auch
  #        deklariert, aber uninitialisiert, oder auch ein direkter
  #        Ziffernwert
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls ARG ein String ist
  #        1 - sonst
  # :impl: Verwendet geschützte Namen für Variablen, da sie
  #        Funktionen aufruft, die Argumente dereferenzieren.
  # :scop: readonly
function _is_string {
    (( $# != 1 )) && return 2

    local __DAHEIM_MONC_VAR4__ # type
    local __DAHEIM_MONC_VAR5__ # status
    local __DAHEIM_MONC_VAR6__ # str

    __DAHEIM_MONC_VAR5__=$(_var_type "$@")
    __DAHEIM_MONC_VAR4__="$?"
    __DAHEIM_MONC_VAR6__=$(_ "-str")

    case ${__DAHEIM_MONC_VAR5__} in
        "${__DAHEIM_MONC_VAR6__}" ) return "${__DAHEIM_MONC_VAR4__}" ;;
        *                       ) return 1 ;;
    esac
}; readonly -f _is_string
#
# :: Gelingt, falls ARG ein Array ist
  # :name: _is_array
  # :type: statement
  # :pref: 1/ARG - Zu prüfender Wert, als Referenz, Variable oder direkt
  # :desc: Überprüft, ob ARG ein Array ist; falls, gelingt der Aufruf.
  #        Dabei kann ARG eine Referenz sein, jede Art von Variable, auch
  #        deklariert, aber uninitialisiert, oder auch ein direkter Wert
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls ARG ein Array ist
  #        1 - sonst
  # :impl: Verwendet geschützte Namen für Variablen, da sie
  #        Funktionen aufruft, die Argumente dereferenzieren.
  # :scop: readonly
function _is_array {
    (( $# != 1 )) && return 2

    local __DAHEIM_MONC_VAR4__ # type
    local __DAHEIM_MONC_VAR5__ # status
    local __DAHEIM_MONC_VAR6__ # arr

    __DAHEIM_MONC_VAR5__=$(_var_type "$@")
    __DAHEIM_MONC_VAR4__="$?"
    __DAHEIM_MONC_VAR6__=$(_ "-arr")
    case ${__DAHEIM_MONC_VAR5__} in
        "${__DAHEIM_MONC_VAR6__}" ) return "${__DAHEIM_MONC_VAR4__}" ;;
        *                       ) return 1 ;;
    esac
}; readonly -f _is_array
#
# :: Gelingt, falls ARG eine Map ist
  # :name: _is_map
  # :type: statement
  # :pref: 1/ARG - Zu prüfender Wert, als Referenz, Variable oder direkt
  # :desc: Überprüft, ob ARG eine Map ist; falls, gelingt der Aufruf.
  #        Dabei kann ARG eine Referenz sein, jede Art von Variable, auch
  #        deklariert, aber uninitialisiert, oder auch ein direkter Wert
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls ARG eine Map ist
  #        1 - sonst
  # :impl: Verwendet geschützte Namen für Variablen, da sie
  #        Funktionen aufruft, die Argumente dereferenzieren.
  # :scop: readonly
function _is_map {
    (( $# != 1 )) && return 2

    local __DAHEIM_MONC_VAR4__ # type
    local __DAHEIM_MONC_VAR5__ # status
    local __DAHEIM_MONC_VAR6__ # map

    __DAHEIM_MONC_VAR5__=$(_var_type "$@")
    __DAHEIM_MONC_VAR4__="$?"
    __DAHEIM_MONC_VAR6__=$(_ "-map")
    case ${__DAHEIM_MONC_VAR5__} in
        "${__DAHEIM_MONC_VAR6__}" ) return "${__DAHEIM_MONC_VAR4__}" ;;
        *                       ) return 1 ;;
    esac
}; readonly -f _is_map
#
# :: Gelingt, falls ARG ein Array oder eine Map ist
  # :name: _is_array_or_map
  # :type: statement
  # :pref: 1/ARG - Zu prüfender Wert, als Referenz, Variable oder direkt
  # :desc: Überprüft, ob ARG ein Array oder eine Map ist; falls, gelingt der
  #        Aufruf.
  #        Dabei kann ARG eine Referenz sein, jede Art von Variable, auch
  #        deklariert, aber uninitialisiert, oder auch ein direkter Wert
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls ARG ein Array oder eine Map ist
  #        1 - sonst
  # :impl: Verwendet geschützte Namen für Variablen, da sie
  #        Funktionen aufruft, die Argumente dereferenzieren.
  # :scop: readonly
function _is_array_or_map {
    (( $# != 1 )) && return 2

    local __DAHEIM_MONC_VAR4__ # type
    local __DAHEIM_MONC_VAR5__ # status
    local __DAHEIM_MONC_VAR6__ # arr
    local __DAHEIM_MONC_VAR7__ # map

    __DAHEIM_MONC_VAR5__=$(_var_type "$@")
    __DAHEIM_MONC_VAR4__="$?"
    __DAHEIM_MONC_VAR6__=$(_ "-arr")
    __DAHEIM_MONC_VAR7__=$(_ "-map")
    case ${__DAHEIM_MONC_VAR5__} in
        "${__DAHEIM_MONC_VAR6__}" ) return "${__DAHEIM_MONC_VAR4__}" ;;
        "${__DAHEIM_MONC_VAR7__}" ) return "${__DAHEIM_MONC_VAR4__}" ;;
        *                       ) return 1 ;;
    esac
}; readonly -f _is_array_or_map
#
# :: Gelingt, falls NAME eine reguläre Datei ist.
  # :name: _is_file
  # :type: statement
  # :para: 1/NAME
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls NAME eine reguläre Datei ist
  #        1 - falls NAME keine reguläre Datei ist
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _is_file {
    (( $# != 1 )) && return 2

    if [[ -f $1 ]]; then
      return 0;
    fi

    return 1;
}; readonly -f _is_file
#
# :: Gelingt, falls NAME ein Verzeichnis ist.
  # :name: _is_dir
  # :type: statement
  # :para: 1/NAME
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls NAME ein Verzeichnis ist
  #        1 - falls NAME kein Verzeichnis ist
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _is_dir {
    (( $# != 1 )) && return 2

    if [[ -d $1 ]]; then
      return 0;
    fi

    return 1;
}; readonly -f _is_dir
#
# :: Gelingt, falls NAME von der Kommandozeile aufgerufen werden kann.
  # :name: _is_command
  # :type: statement
  # :para: 1/NAME
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls NAME ein Befehl für die Kommandozeile ist
  #        1 - falls NAME kein Befehl für die Kommandozeile ist
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _is_command {
    (( $# != 1 )) && return 2

    command -v "$1" > /dev/null

    return $?
}; readonly -f _is_command
#
# :: Gelingt, falls NAME als Prozess läuft
  # :name: _is_running_cmd
  # :type: statement
  # :para: 1/NAME
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls NAME läuft
  #        1 - falls NAME nicht läuft
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _is_running_cmd {
    (( $# != 1 )) && return 2
    local psid
    psid="$(pgrep "$1")"
    if [[ -z ${psid} ]]; then
        return 1
    fi
    return 0
}; readonly -f _is_running_cmd
#
# :: Gelingt, falls NAME nicht als Prozess läuft
  # :name: _is_not_running_cmd
  # :type: statement
  # :para: 1/NAME
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        0 - falls NAME nicht läuft
  #        1 - falls NAME läuft läuft
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _is_not_running_cmd {
    (( $# != 1 )) && return 2

    _is_running_cmd "$@" && return 1 || return 0
}; readonly -f _is_not_running_cmd
#
# :: Gelingt, falls es NR Argumente außer NR gibt
  # :name: _number_of_args_is
  # :type: statement
  # :para: 1/NR/number
  # :para: (0..n)
  # :stat: 1 - falls 0 Parameter übergeben werden
  #        1 - falls der erste Parameter keine Zahl ist
  #        0 - falls NR n ist
  #        2 - falls NR nicht n ist
  # :impl: In allen anderen Funktionen wird immer 2 zurück gegeben, falls die
  #        Anzahl der Argumente der Funktion nicht stimmt.
  #        Da diese Funktion aber dazu dient, die Anzahl der Argument einer
  #        anderen Funktion zu prüfen, wird 1 zurückgeben, falls das eigene
  #        Argument nicht stimmt und 2 falls die Anzahl der anderen Argumente
  #        nicht stimmt. Somit kann der Status von der aufrufenden Funktion
  #        verwendet werden.
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _number_of_args_is {
    (( $# == 0 )) && return 1

    _is_number "$1" || return 1

    (($# != ($1 + 1))) && return 2

    return 0
}; readonly -f _number_of_args_is
#
# :: Gelingt, falls es mehr als NR Argumente außer NR gibt
  # :name: _number_of_args_gt
  # :type: statement
  # :para: 1/NR/number
  # :para: (0..n)
  # :stat: 1 - falls 0 Parameter übergeben werden
  #        1 - falls der erste Parameter keine Zahl ist
  #        0 - falls NR > n ist
  #        2 - falls NR nicht n ist
  # :impl: In allen anderen Funktionen wird immer 2 zurück gegeben, falls die
  #        Anzahl der Argumente der Funktion nicht stimmt.
  #        Da diese Funktion aber dazu dient, die Anzahl der Argument einer
  #        anderen Funktion zu prüfen, wird 1 zurückgeben, falls das eigene
  #        Argument nicht stimmt und 2 falls die Anzahl der anderen Argumente
  #        nicht stimmt. Somit kann der Status von der aufrufenden Funktion
  #        verwendet werden.
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _number_of_args_gt {
    (( $# == 0 )) && return 1

    _is_number "$1" || return 1

    (( ( $# -1 ) > $1 )) || return 2

    return 0
}; readonly -f _number_of_args_gt
#
# :: Gelingt, falls es weniger als NR Argumente außer NR gibt
  # :name: _number_of_args_lt
  # :type: statement
  # :para: 1/NR/number
  # :para: (0..n)
  # :stat: 1 - falls 0 Parameter übergeben werden
  #        1 - falls der erste Parameter keine Zahl ist
  #        0 - falls NR < n ist
  #        2 - falls NR nicht n ist
  # :impl: In allen anderen Funktionen wird immer 2 zurück gegeben, falls die
  #        Anzahl der Argumente der Funktion nicht stimmt.
  #        Da diese Funktion aber dazu dient, die Anzahl der Argument einer
  #        anderen Funktion zu prüfen, wird 1 zurückgeben, falls das eigene
  #        Argument nicht stimmt und 2 falls die Anzahl der anderen Argumente
  #        nicht stimmt. Somit kann der Status von der aufrufenden Funktion
  #        verwendet werden.
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _number_of_args_lt {
    (( $# == 0 )) && return 1

    _is_number "$1" || return 1

    (( ( $# -1 ) < $1 )) || return 2

    return 0
}; readonly -f _number_of_args_lt
#
# :: Gibt eine Nachricht zurück
  # :name: _msg
  # :type: statement
  # :para: [-]1/nr[int]     - Nachrichtennummer
  #        [-]1/key[string] - Key für Nachricht
  # :desc: Es wird entweder ein key oder eine nr übergeben. Ein key wird in
  #        die entsprechende nr konvertiert.
  #        Beginnt das Argument mit einem "-" wird dieses entfernt und
  #        die lokale Nachrichten aus _MSG und _MSG_MAP ausgegeben,
  #        sonst wird in den globalen Containern gesucht.
  #        Die der nr entsprechende Nachricht wird ausgegeben.
  # :retu: Die entsprechende Nachricht
  # :stat: 2 - falls nicht genau ein Argument übergeben wird
  #        1 - falls es keine Nachricht zu nr/key gibt
  #        0 - bei Erfolg
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _ {
    (( $# != 1 )) && return 2

    local __DAHEIM_MONC_VAR4__   # msg
    local __DAHEIM_MONC_VAR5__   # msg_no
    local __DAHEIM_MONC_VAR6__=1 # own
    local __DAHEIM_MONC_VAR7__=0 # status

    __DAHEIM_MONC_VAR5__=${1#-}
       #shellcheck disable=2034
    if [[ ${__DAHEIM_MONC_VAR5__} == "$1" ]]; then __DAHEIM_MONC_VAR6__=0; fi
    #!echo "!! ARG1:$1; MSG_NO:${__DAHEIM_MONC_VAR5__}; OWN:${__DAHEIM_MONC_VAR6__}"
    if (( __DAHEIM_MONC_VAR6__ )); then
      ! _is_number_var "${__DAHEIM_MONC_VAR5__}" &&\
                         __DAHEIM_MONC_VAR5__=${_MSG_MAP[${__DAHEIM_MONC_VAR5__}]}
      ! _is_number_var "${__DAHEIM_MONC_VAR5__}" &&\
                                __DAHEIM_MONC_VAR5__=0 && __DAHEIM_MONC_VAR7__=1
      __DAHEIM_MONC_VAR4__=${_MSG[${__DAHEIM_MONC_VAR5__}]}
      [[ -z ${__DAHEIM_MONC_VAR4__} ]] &&\
                       __DAHEIM_MONC_VAR4__=${_MSG[0]} && __DAHEIM_MONC_VAR7__=1
    else
      ! _is_number_var "${__DAHEIM_MONC_VAR5__}" &&\
                          __DAHEIM_MONC_VAR5__=${MSG_MAP[${__DAHEIM_MONC_VAR5__}]}
      ! _is_number_var "${__DAHEIM_MONC_VAR5__}" &&\
                                __DAHEIM_MONC_VAR5__=0 && __DAHEIM_MONC_VAR7__=1
      __DAHEIM_MONC_VAR4__=${MSG[${__DAHEIM_MONC_VAR5__}]}
      [[ -z ${__DAHEIM_MONC_VAR4__} ]] &&\
                        __DAHEIM_MONC_VAR4__=${MSG[0]} && __DAHEIM_MONC_VAR7__=1
    fi

    echo "${__DAHEIM_MONC_VAR4__}"
    return "${__DAHEIM_MONC_VAR7__}"
}; readonly -f _
#
# :: Prozedur, die Warnkenner, das Argument und NL ausgibt
  # :name: _warn
  # :type: function
  # :para: 1/MSG
  # :desc: Gibt einen Kenner für eine Warnung und das erste Argument gefolgt
  #        von einem Zeilenumbruch aus
  # :stat: 0 - Nachricht (String);falls alles ok
  #        2 - NULL;falls zu wenig Argumente oder zu viele Argumente
  # :retu: Nachricht (String);falls status 0
  # :scop: readonly
_warn() {
    (( $# != 1 )) && return 2
    #shellcheck disable=2312
    printf '%s%s\n' "$(_ "-warn_sign")" "$1"
}; readonly -f _warn
#
# :: Fehlerbehandlung
  # :name: _error
  # :type: function
  # :para: 1/es/int      - Error Status
  # :para: 2/[-]nr/int   - Nachrichtennummer/-kenner, - davor für lokal
  # :para: 3/name        - Optional. Wird im Fehlerfall als letztes ausgegeben
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _error {
    (( $# < 2 )) && return 2

    #shellcheck disable=SC2312
    (( $1 > 0 )) && echo "$(_ "-err")$(_ "$2")$3" && return "$1"
    return 0
}; readonly -f _error
#
# :: Gelingt, falls von root ausgeführt
  # :name: _am_root
  # :type: statement
  # :desc: Prüft, ob als Root ausgeführt.
  # :stat: 2 - falls die Anzahl der Argumente nicht 0 ist
  #        1 - falls nicht von root ausgeführt
  #        0 - falls von Root ausgeführt
  # :scop: readonly
#shellcheck disable=2120
function _am_root {
    (( $# > 0 )) && return 2

    #shellcheck disable=SC2312
    if [[ "$(id -u)" -gt "0" ]];
        then return 1;
    fi

    return 0
}; readonly -f _am_root
#
# :: Beendet das Programm falls der Aufrufer root ist
  # :name: _exit_for_root
  # :type: procedure
  # :stat: 1 - falls ausführender Nutzer root ist
  #        0 - falls ausführender Nutzer nicht root ist
  # :desc: Nicht nur die Funktion wird beendet, sondern das gesamte
  #        Shell Script, falls der aufrufende Nutzer root ist.
  #
  # :scop: readonly
_exit_for_root() {
    if _am_root; then
        echo "not allowed to run als root"
        exit 1
    fi
    return 0
}; readonly -f _exit_for_root
#
# :: Gibt letzte Ziffer in einer Datei zurück
  # :name: _last_number_in_file
  # :type: function
  # :para: 1/fn
  # :desc: Sucht in der Datei nach Ziffern und gibt die letzte zurück
  # :stat: 0 - falls alles ok
  #        1 - falls die Datei nicht existiert oder keine Ziffer enthält
  #        2 - falls zu wenig Argumente oder zu viele Argumente
  # :retu: Ziffer (String);falls status 0, sonst NULL
  # :scop: readonly
function _last_number_in_file { # File
    (( $# != 1 )) && return 2
    if ! [[ -f "$1" ]]; then return 1; fi

    FILE_NAME=""
    LAST_NUMBER=""
    l=""
    local FILE_NAME LAST_NUMBER l
    FILE_NAME="$1"

    #shellcheck disable=2312
    l=$(grep -o "[0-9]" "${FILE_NAME}" | tr "\n" " " | xargs)
    if [[ -z ${l} ]]; then return 1; fi
    LAST_NUMBER=${l##* }

    echo "${LAST_NUMBER}"
}; readonly -f _last_number_in_file
#
# :: Wandelt long opts in short opts
  # :name: _long2short_opts
  # :type: function
  # :pars: ARGS
  # :desc: Ersetzt die long opts --dry, --help, --verbose durch -d, -h, -v
  #        Fügt vor -n, -e, -E ein Leerzeichen ein, weil die sonst durch
  #        diese Funktion verschwinden würden.
  # :stat: 0 - immer
  # :retu: gewandelte ARGS
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
function _long2short_opts {
    local __DAHEIM_MONC_VAR3__ # arg
    local __DAHEIM_MONC_VAR4__=() # args
    first=" "
    for __DAHEIM_MONC_VAR3__ in "$@"; do
        case "${__DAHEIM_MONC_VAR3__}" in
        --dry)    __DAHEIM_MONC_VAR4__+=("-d") ;;
        --help)   __DAHEIM_MONC_VAR4__+=("-h") ;;
        --verbose)__DAHEIM_MONC_VAR4__+=("-v") ;;
        -n)       __DAHEIM_MONC_VAR4__+=("${first}""-n") ;;
        -e)       __DAHEIM_MONC_VAR4__+=("${first}""-e") ;;
        -E)       __DAHEIM_MONC_VAR4__+=("${first}""-E") ;;
        *)        __DAHEIM_MONC_VAR4__+=("${__DAHEIM_MONC_VAR3__}") ;;
        esac
        first=""
    done
    echo "${__DAHEIM_MONC_VAR4__[@]}"

    return 0
}; readonly -f _long2short_opts
#
# :: Gibt das Argument (+ 1 Zeilenumbruch) als Hilfe formatiert aus
  # :name: _help
  # :type: procedure
  # :pars: 1/MSG
  # :desc: Gibt im Moment MSG aus. Keine NL
  # :stat: 2 - wenn die Anzahl der Argumente nicht 1 ist
  #        0 - sonst
  # :retu: MSG
  # :impl: Verwendet geschützte Namen für Variablen, da sie auch von
  #        Funktionen aufgerufen werden kann, die Argumente dereferenzieren.
  # :scop: readonly
_help() {
    (( $# != 1 )) && return 2
    printf '%s\n' "$1"
}; readonly -f _help
#
# :: Gibt den Wert zu einem Kenner aus einer Datei Vars zurück
  # :name: _value_of
  # :para: 1/Kenner (String)
  # :desc: Sucht den Kenner in der Datei Vars und gibt den Wert zurück
  # :stat: 0 - falls alles ok
  #        1 - falls die Datei Vars nicht existiert
  #        2 - falls zu wenig Argumente oder zu viele Argumente
  # :retu: Wert (String);falls alles ok
  # :scop: readonly
function _value_of {
    (( $# != 1 )) && return 2
    if ! [[ -f "Vars" ]]; then return 1; fi
    local VAR_NAME=$1
    local VAR_VALUE=""
    local VAR_NAME VAR_VALUE
    #shellcheck disable=2312
    VAR_VALUE=$(awk '/^'"${VAR_NAME}"';/ {print $0}' "Vars" | awk -F';' '{print $2}')

    echo "${VAR_VALUE}"
}; readonly -f _value_of;
#
# Script
# ======
# :: Gibt den Namen der Datei aus und alle implementierten Funktionen
  # :name: main_base
  # :type: procedure
  # :desc: Gibt den Namen der Datei aus und gibt danach die Namen aller
  #        implementierten Funktionen mit einer Kurzbeschreibung aus.
  # :impl: Das Einlesen des Heredoc mit der Umleitung "<<-" bewirkt, dass
  #        die Tabulatoren am Zeilenanfang entfernt werden.
  # :scop: readonly
main_base() {
  echo "in base.sh"
  cat <<- AUSGABE
	Funktionen in dieser Sammlung
	=============================
	_ IND:                           gibt die msg für IND(int oder key) zurück
	_am_root:                        läuft diese Abfrage als root
	_exit_for_root:                  Exit mit 1 für root
	_help ARG:                       gibt ARG aus
	_is_array  ARG:                  ist ARG (variable_name) ein array
	_is_array_or_map  ARG:           ist ARG (variable_name) array oder map
	_is_command NAME:                ist NAME ein aufrufbarer Befehl
	_is_dir NAME:                    ist NAME ein Verzeichnis
	_is_file NAME:                   ist NAME eine Datei
	_is_map  ARG:                    ist ARG (variable_name) eine map
	_is_not_running_cmd CMD:         läuft der Befehl CMD nicht
	_is_number ARG:                  ist ARG (variable_name) eine natürliche Zahl
	_is_number_var VAR:              ist VAR eine natürliche Zahl
	_is_running_cmd CMD:             läuft der Befehl CMD
	_is_string ARG:                  ist ARG (variable_name) ein String
	_last_number_in_file FN:         gibt die letzte Ziffer in FN zurück
	_long2short_opts ARGS            gibt ARGS mit short options zurück
	_number_of_args_gt NR ARGS:      ist NR die Anzahl der Argumente größer NR-1
	_number_of_args_is NR ARGS:      ist NR die Anzahl der Argumente außer NR
	_number_of_args_lt NR ARGS:      ist NR die Anzahl der Argumente kleiner NR-1
	_value_of KEY:                   gibt VALUE of KEY in Datei Vars zurück
	_var_type ARG:                   gibt ARRAY, MAP, INT oder STRING zurück
	_warn ARG:                       gibt ARG als Warnung aus
	AUSGABE
}; readonly -f main_base
#
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # Wird nur aufgerufen, wenn die Datei direkt als Skript gestartet wird.
  # Wir weder aufgerufen, wenn sie inkludiert wird, noch wenn sie getestet wird.
    main_base "$@"
fi