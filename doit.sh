#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Führt das Script aus
  # :name: doit.sh
  # :type: script
  # :requ: Das Script muß existieren
  # :pars: Keine
  # :desc: Gibt eine Fehlermeldung aus, falls es mit Argumenten aufgerufen wird
  # :stat: 2 falls es Argumente hat
  #        0 sonst
  # :retu: Nur im Fehlerfall
#
. "$(dirname "${BASH_SOURCE[0]}")/include/base.sh"
#
# :: Gibt zurück, ob alle Voraussetzungen für das Script erfüllt sind
  # :name: requirements_are_met
  # :type: func
  # :pars: PARA Alle Parameter des Aufrufs des Scripts
  # :para: 1/NAME -
  # :desc: Tests für alle Voraussetzungen, die erfüllt sein müssen, damit eine
  #        Funktion  ausgeführt werden kann, werden hier mit den an die
  #        aufrufenden Funktion übergebenden Argumenten ausgeführt.
  #        Ist eine Voraussetzung nicht erfüllt, wird eine Fehlermeldung
  #        ausgegeben und ein Fehlerstatus zurückgegeben. Weitere Tests werden
  #        nicht ausgeführt.
  #        Wenn alle Tests bestanden wurden, wird der Status 0 zurückgegeben
  # :stat: 0, falls ok
  #        2, falls Anzahl Argumente in PARA nicht gleich 0
  # :retu: falls nicht ok, wird eine Fehlermeldung aus-/zurück-gegeben
  # :scop: readonly
function requirements_are_met_doit {
    _number_of_args_is 0 "$@"
    _error $? "nr_args_needed" 0 || return 2

    return 0
}; readonly -f requirements_are_met_doit
#
# :: Führt das Script aus
  # :name: main_doit
  # :type: procedure
  # :desc: main wird nur ausgeführt, falls das Script direkt aufgerufen wird,
  #        dies wird durch den bedingten Aufruf hinter der Funktionsdefinition
  #        bewirkt.
  # :scop: readonly
main_doit() {
    echo "In doit.sh"
    requirements_are_met_doit "$@"  || exit $?

    echo -e "${color2}Test Farbe${clr}"

    exit 0
}; readonly -f main_doit
#
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main_doit "$@"
fi

