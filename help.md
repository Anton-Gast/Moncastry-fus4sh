Bash Script Sammlung fus4sh
===========================
# 1. Sinn und Zweck
Skripte, die meine Aufgaben erfüllen und die ich verstehe.
Sie sind getestet. Sie werden während der Entwicklung kontinuierlich getestet.
Sie werden beim Einchecken erzwungenermaßen getestet.
Die Projektdateien kann man als Bundle woanders hin kopieren und die Skripte
darin funktionieren immer noch. Egal ob sie im Pfad liegen oder mit Pfadangabe
aufgerufen werden.

Alle Funktionen und globalen Variablen in der Skripten sind dokumentiert. Die
Dokumentation folgt einem Standard. So ist eine Extraktion möglich.

Die Hilfsdateien gehören zum Framework, das ich aufbaue. Damit kann man auch
größere Linux Projekte entwickeln, seien es reine Skript Sammlungen, Projekte
die mit make arbeiten, Datenbankprojekte, Installationen und Systempflege. Das
ist wenigstens das Ziel.

## 1.1. Was noch fehlt
Dem Framework fehlt noch ein Deploy. Außerdem fehlt das Werkzeug um die
Dokumentation aus den Kommentaren zu extrahieren. Für fertige Skripte, die
beibehalten werden sollen, fehlt noch eine Alias-Erstellung, bei der .sh vom
Skript Namen entfernt wird und so ein normaler Befehlsname entsteht.

# 2. Installation

Um die Sammlung zu verwenden, muß man sie irgendwohin kopieren. Um sie in einem anderen Projekt der Moncastry Suite zu verwenden, muß man eine Umgebungsvariable **SCRIPT_DIR** auf das Elternverzeichnis von **fus4sh** setzen oder im verwendenden Projekt einen Softlinke auf das Wurzelverzeichnis von **fus4sh**

Um die Sammlung weiterzuentwickeln muß [`./include/intern/pre-commit.src`](./include/intern/pre-commit.src) nach [`pre-commit`](./.git/hooks/pre-commit) kopiert sein, [`./include/intern/post-commit.src`](./include/intern/post-commit.src) nach [`post-commit`](./.git/hooks/post-commit) und [`./include/intern/config.src`](./include/intern/config.src) nach [`./git/config`](.git/config). Damit ist [`gitcommit.template`](./include/intern/gitcommit.template) als git commit-template gesetzt.

 Bei Verwendung von **Visual Studio Code** kann [`./include/intern/fus4sh.code-workspace.src`](./include/intern/fus4sh.code-workspace.src) ins Elternverzeichnis als `fus4sh.code-workspace` kopiert als Workspace  verwendet werden.


Für die Entwicklung müssen [git](https://git-scm.com/), [shellcheck](https://www.shellcheck.net/) und [bats-core](https://bats-core.readthedocs.io/en/stable/index.html)  installiert sein. Bats-core wird dabei im Wurzelverzeichnis des Projekts so installiert wie im [Quick Installation](https://bats-core.readthedocs.io/en/stable/tutorial.html#quick-installation) beschrieben.

```
git submodule add https://github.com/bats-core/bats-core.git test/bats
git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
```
Hat man die submodule so hinzugefügt, darf man  `.git/config` nicht mehr durch rüberkopieren von `./include/intern/config.src` ändern, dann muß man es manuell tun. Am besten vorher kopieren.



# 3. Enthaltene Skripte
## 3.1. test_sh
Ein Target dieser Sammlung, das nur für Aufgaben des Frameworks verwendet wird:
Mit diesem Skript werden die Skripte getestet. Es funktioniert auch für sich
selbst.

Aufruf zum Beispiel: test_sh doit

## 3.2. doit.sh
Für dieses Skript existiert noch kein Alias. Es ist ein Template für künftige
Skripte. Es kann auch getestet werden.

## 3.3. create_acl_dir
Für dieses Skript existiert noch kein Alias. Es soll ein Verzeichnis mit ACL
Steuerung erstellt werden. Nach Möglichkeit soll ein existierendes Verzeichnis
auch umgewandelt werden.

# 4. Enthaltene Funktionen

Die Funktionssammlung befindet sich im Verzeichnis `./include`. Zur Zeit nur in der Datei [`base.sh`](./include/base.sh). Der Aufruf von `./include/base.sh` als Script zeigt eine Liste der dort implementierten Funktionen an.

Alle Funktionen haben einen dokumentierenden Header. Es ist angedacht, diesen automatisch zu extrahieren und hier in diese Hilfe hinzuzufügen. Zur Zeit muß man ihn noch in der Datei lesen.

# 5. Aufbau
Im Wurzelverzeichnis liegen direkt ausführbaren Skripte. Im Verzeichnis include/
liegen Dateien mit Funktionen.

Alle anderen Dateien sind Hilfsdateien, die für die Entwicklung sinnvoll sind
oder die zur Information dienen.

## 5.1. Dateien
- [../fus4sh.code-workspace](../fus4sh.code-workspace)
- [.gitignore](.gitignore)
- [.gitmodules](.gitmodules)
- [help](help.md)
- [README](README.md)
- [Version](Version.md)
- [create_acl_dir](create_acl_dir.sh)
- [doit](doit.sh)
- [test_sh](test_sh.sh)
- [config](.git/config)
- [.git/](.git/)
- [.git/hooks/pre-commit](.git/hooks/pre-commit)
- [.git/hooks/post-commit](.git/hooks/post-commit)
- [.vscode/](.vscode/)
- [.vscode/project-words.txt](.vscode/project-words.txt)
- [include/base](include/base.sh)
- [include/colors](include/colors.dat)
- [include/messages](include/messages.dat)
- [include/intern/](include/intern/)
- [include/intern/config Sicherung](include/intern/config.src)
- [include/intern/Workspace Sicherung](include/intern/fus4sh.code-workspace.src)
- [include/intern/pre-commit Sicherung](include/intern/pre-commit.src)
- [include/intern/post-commit Sicherung](include/intern/post-commit.src)
- [include/intern/.gitcommit.template](include/intern/.gitcommit.template)
- [test/](test/)
- [create_acl_dir TEST](test/create_acl_dir.bats)
- [doit TEST](test/doit.bats)
- [test_sh TEST](test/test_sh.bats)
- [base TEST](test/include/base.bats)
- [setup für alle Tests](test/test_helper/common-setup.bash)

