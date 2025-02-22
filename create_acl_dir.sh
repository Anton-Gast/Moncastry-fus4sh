#!/usr/bin/env bash
#x_shellcheck disable=all
#:: Noch Kommentieren
#
. "$(dirname "${BASH_SOURCE[0]}")/include/base.sh"
#
  # :scop: readonly
function get_acl_dir {
  echo "dirname"
}; readonly -f get_acl_dir
#
  # :name: main_create_acl_dir
  # :desc: Ist noch nicht fertig
  # :scop: readonly
main_create_acl_dir() {
  echo "In create_acl_dir.sh"
  local acl_dir=get_acl_dir;
    # ^ Wir brauchen den Namen eines Verzeichnisses
    # Den können wir interaktiv erfragen
    # Oder wir bekommen ihn als Parameter
    #  Dieser kann als Parameter an einer bestimmten Position bestimmt werden
    #  oder er kann durch eine Option bestimmt werden
: << LATER
  sudo mkdir /home/${acl_dir}
  sudo setfacl -bkR /home/${acl_dir} # Alle ACL und Default ACLs löschen
  sudo chgrp -RP ${acl_dir} /home/${acl_dir}
  sudo find /home/${acl_dir} -type d -exec chmod 770 {} \;
  sudo find /home/${acl_dir} -type f -exec chmod 640 {} \;
  sudo find /home/${acl_dir} -name "*.sh" -exec chmod 770 {} \;
  sudo chmod 770 /home/${acl_dir}
  sudo chmod g+s /home/${acl_dir} # setgid mode - all new entries inherit group id from directory
  sudo find /home/${acl_dir} -type d -exec chmod g+s {} \;
  sudo setfacl -dm u::rwx,g::rwx,o::- /home/${acl_dir}
  sudo find /home/${acl_dir} -type d -exec setfacl -PRdm u::rwx,g::rwx,o::-  {} \;
  sudo find /home/${acl_dir} -type f -exec setfacl -PRm u::rw,g::rw,o::-  {} \;
  sudo find /home/${acl_dir} -name "*.sh" -exec setfacl -PRm u::rwx,g::rwx,o::-  {} \;
LATER
}; readonly -f main_create_acl_dir
#
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
main_create_acl_dir "$@"
fi