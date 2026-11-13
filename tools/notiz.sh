#!/usr/bin/env bash
# Notizen (CLAUDE.md, CHANGELOG.md, docs/) leben nur auf main. Dieses Skript hält eine zweite Arbeitskopie
# von main neben dem Arbeitszweig aktuell und zeigt, was sich seit dem letzten Aufruf geändert hat.
#   tools/notiz.sh          main holen, Name der Sitzung und neue Notiz-Änderungen zeigen
#   tools/notiz.sh --kurz   nur eine Zeile (für den Starthaken)
# Bearbeiten danach unter ../bornim-main, committen und sofort pushen (siehe CLAUDE.md).
cd "$(dirname "$0")/.." || exit 1
repo=$(pwd)
# 347: Uhr und Kernregeln als letzte Zeilen jeder Ausgabe (Wortlaut nur in tools/kernregeln.txt)
schluss() {
    echo "Uhr: $(TZ=Europe/Berlin date '+%d.%m., %H:%M') (Berliner Zeit, Systemuhr; so stempeln)"
    cat "$repo/tools/kernregeln.txt" 2>/dev/null
}
wt="$(cd "$repo/.." && pwd)/bornim-main"
mark="$(git rev-parse --git-common-dir)/notiz-zuletzt"

# Wer bin ich? Account aus „Kennungen der Teams“ in docs/ROLLE-BETRIEB.md (seit 274 nicht mehr in CLAUDE.md, 307); auf Max laufen mehrere Rollen (D14, Anregung a).
name="unbekannt"
if [ -n "$CLAUDE_CODE_ACCOUNT_UUID" ]; then
    zeile=$(cat "$wt/docs/ROLLE-BETRIEB.md" docs/ROLLE-BETRIEB.md CLAUDE.md 2>/dev/null | grep -oE "(Tom|Jerry)[^,]{0,20}\`$CLAUDE_CODE_ACCOUNT_UUID" | head -1)
    case "$zeile" in *Tom*) name="Zentrale (Tom, Jerry, Ford, Perikles, Homer, Sokrates oder Diogenes; Rolle aus der ersten Nachricht, auch wenn sie als Systemmeldung von Ford kommt, 853)" ;; *Jerry*) name="Niederlassung (ruht; Rolle aus der ersten Nachricht, 853)" ;; esac
fi

git fetch -q origin main 2>/dev/null || echo "Bornim: main ließ sich nicht holen (Netz?)."
# Arbeitskopie nie auf main neben der Notizkopie (222.2): sonst rückt jeder Notiz-Commit main vor und die
# Arbeitskopie zeigt veraltete Dateien als „ungesichert“ (ein Commit davon löscht fremde Einträge).
if [ "$(git symbolic-ref -q --short HEAD)" = "main" ] && [ "$repo" != "$wt" ]; then
    if [ -z "$(git status --porcelain)" ]; then git checkout -q --detach
    else echo "Bornim (222.2): Arbeitskopie steht auf main und hat Änderungen; nicht committen, prüfen (veraltet → git stash), dann git checkout --detach."; fi
fi
if [ ! -d "$wt/.git" ] && [ ! -f "$wt/.git" ]; then
    git worktree prune
    git worktree add -q "$wt" origin/main 2>/dev/null && git -C "$wt" checkout -q -B main origin/main
fi
# Flacher Klon mit altem main in der Arbeitskopie: ohne gemeinsamen Vorfahren bricht das Zusammenführen ab
# („unrelated histories“). Dann den vollen Verlauf nachladen.
if ! git -C "$wt" merge-base HEAD origin/main >/dev/null 2>&1 \
   && [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
    git fetch -q --unshallow origin main 2>/dev/null || echo "Bornim: Verlauf ließ sich nicht nachladen (Netz?)."
fi
# Arbeitskopie auf den neuesten Stand; eigene, noch nicht gepushte Commits bleiben (Zusammenführen, kein Rebase).
if [ -z "$(git -C "$wt" status --porcelain)" ]; then
    git -C "$wt" merge -q --ff-only origin/main 2>/dev/null || git -C "$wt" merge -q --no-edit origin/main 2>/dev/null \
        || { git -C "$wt" merge --abort 2>/dev/null; echo "Bornim (236): Notizkopie $wt ließ sich nicht mit main zusammenführen, abgebrochen. Sicherung und Reset: git -C $wt branch -f backup-lokal-main main && git -C $wt reset --hard origin/main"; }
fi

neu=$(git rev-parse origin/main)
alt=$(cat "$mark" 2>/dev/null)

# Wächter Dokumentnamen (77, 13.10.): alte Dateinamen dürfen weder als Datei noch als Verweis zurückkommen.
# Archiv und Änderungshistorie sind Verlauf und bleiben ausgenommen.
altnamen='BERATER|DIOGENES|LEITBILD|STIL|ENTWICKLUNG|HELDENBAU|BALANCE|ZWISCHENBILD|STORY1|STORY|THEMEN|MERKLISTE|KAPITEL1|OFFEN|SELBST|ABLAEUFE|UMGEBUNG|ARCHIV'
alt_dateien=$(git ls-tree --name-only origin/main docs/ 2>/dev/null | grep -E "^docs/($altnamen)\.md$")
[ -n "$alt_dateien" ] && echo "FEHLER (77): alte Notizdatei wieder da: $(echo $alt_dateien). Inhalt in die neue Datei übernehmen, alte löschen, Nutzer melden."
alt_verweise=$(git grep -l -P "(?<![\w-])($altnamen)\.md" origin/main -- CLAUDE.md docs tools ':!docs/PRUEFBERICHT-ARCHIV.md' ':!docs/VORGANGSARCHIV.md' ':!docs/alt' ':!tools/notiz.sh' 2>/dev/null | sed 's/^origin\/main://')
[ -n "$alt_verweise" ] && echo "Warnung (77): alte Dateinamen erwähnt in: $(echo $alt_verweise). Neue Namen: Vorsilben ROLLE-/DESIGN-/STORY-/LISTE-/ARBEIT- (CLAUDE.md, erster Absatz)."
# Wächter Bilder Chefsache (108, D15.4): höchstens 60 KB je Datei, höchstens 3 Bilder je Punkt; Größeres über Telegram.
gross=$(git ls-tree -r -l origin/main docs/chefsache/ 2>/dev/null | awk '$4>61440 && $5 !~ /\.md$/ {print $5}')
[ -n "$gross" ] && echo "Warnung (108): Datei über 60 KB in docs/chefsache/: $(echo $gross). Verkleinern (800 px, JPG/WebP) oder über Telegram (--datei), Verlauf bleibt."
# Regelwerte (969): die Seite folgt werte.json und dem Spielcode auf main; nach dem Mischen eines Builds neu erzeugen.
[ -f "$wt/tools/regelwerte.py" ] && ! python3 "$wt/tools/regelwerte.py" --pruefen > /dev/null 2>&1 && echo "Warnung (969): docs/LISTE-REGELWERTE.md veraltet (werte.json oder Spielcode auf main geändert); Team Jerry: python3 tools/regelwerte.py in $wt, committen."
# Wächter Umbau 98 (15.10.) und 117 (16.10.): die alten Vorrats-, Rollen- und Listennamen dürfen nicht zurückkommen.
altvoll='ARBEIT-OFFEN|ARBEIT-SELBST|ARBEIT-FORD|ROLLE-BERATER|ROLLE-FORD|ROLLE-ENTWICKLER|ROLLE-TESTER|ROLLE-TEAM|ARBEIT-ABLAEUFE|ARBEIT-UMGEBUNG|STORY-K1-W|STORY-K1|LISTE-THEMEN|DESIGN-ZWISCHENBILD|LISTE-KAPITEL1'
alt98=$(git ls-tree --name-only origin/main docs/ 2>/dev/null | grep -E "^docs/($altvoll)\.md$")
[ -n "$alt98" ] && echo "FEHLER (98): alte Datei wieder da: $(echo $alt98). Inhalt in den passenden Vorrat oder die neue Rollendatei (docs/FIRMA.md), alte löschen."
alt98v=$(git grep -l -E "($altvoll)\.md" origin/main -- CLAUDE.md docs tools .claude ':!docs/PRUEFBERICHT-ARCHIV.md' ':!docs/VORGANGSARCHIV.md' ':!docs/alt' ':!tools/notiz.sh' 2>/dev/null | sed 's/^origin\/main://')
[ -n "$alt98v" ] && echo "Warnung (98): alte Dateinamen erwähnt in: $(echo $alt98v). Neue Namen in CLAUDE.md „Wo was steht“."
if [ "$1" = "--kurz" ]; then
    if [ -z "$alt" ]; then was="erster Aufruf, tools/notiz.sh zeigt die letzten Änderungen"
    else was="$(git rev-list --count "$alt..$neu" -- CLAUDE.md CHANGELOG.md docs 2>/dev/null) neue Änderungen seit dem letzten Mal (tools/notiz.sh zeigt sie)"; fi
    echo "Bornim: Diese Sitzung ist $name. Notizen auf main: $was."
    schluss
    exit 0
fi
echo "Diese Sitzung ist: $name"
if [ -z "$alt" ]; then
    echo "Notizen auf main, letzte Änderungen:"
    TZ=Europe/Berlin git log -5 --format='  %ad  %s' --date=format-local:'%d.%m. %H:%M' origin/main -- CLAUDE.md CHANGELOG.md docs
elif [ "$alt" = "$neu" ]; then
    echo "Notizen auf main: nichts Neues."
else
    echo "Notizen auf main, neu seit dem letzten Aufruf:"
    TZ=Europe/Berlin git log --format='  %ad  %s' --date=format-local:'%d.%m. %H:%M' "$alt..$neu" -- CLAUDE.md CHANGELOG.md docs
fi
# Größenwarnung (65.4c, 98; Grenze 30 KB seit 1129 A 7): jeder Vorrat ARBEIT-*.md (außer dem eingefrorenen Archiv, 117).
# 1129 A 7: Größe und Pflegefehler nur einmal am Tag, sonst stehen sie bei jedem Start und keiner reagiert; sie stehen auch im Tagesbericht.
pw="$HOME/.bornim-pflegewarnung-$(TZ=Europe/Berlin date +%Y%m%d)"
if [ ! -f "$pw" ]; then
    touch "$pw"
    for d in $(git ls-tree --name-only origin/main docs/ 2>/dev/null | grep -E '^docs/ARBEIT-.*\.md$' | grep -v -E 'ARBEIT-ARCHIV\.md'); do
        n=$(git show "origin/main:$d" 2>/dev/null | wc -c)
        [ "$n" -gt 30000 ] && echo "Warnung: $d hat $((n/100))00 Bytes (Grenze etwa 30000), kürzen (CLAUDE.md „Vorräte klein halten“)."
    done
    # Pflegefehler der Vorräte (167.9): erledigte Zeilen, Größe, lange Zeilen; nur melden, wenn etwas da ist
    if [ -f "$wt/tools/regelcheck.py" ]; then pf=$(python3 "$wt/tools/regelcheck.py" --kurz 2>/dev/null | grep -v "keine$"); [ -n "$pf" ] && echo "$pf"; fi
fi
if [ -f "$wt/tools/inhalt.py" ]; then ih=$(python3 "$wt/tools/inhalt.py" --kurz 2>/dev/null); [ -n "$ih" ] && printf "Inhaltsverzeichnis docs/README.md (650.2):\n%s\n" "$ih"; fi
# 340.3: dieselben Hinweise einmal am Tag als Zeile „Pflege“ des Besitzers in der Vorgangsliste (275.2), Rollenspiegel ab Freitag als Zeile „Spiegel“;
# im Hintergrund, eigener Commit auf origin/main ohne Arbeitskopie (tools/pflegehinweis.py)
pm="$HOME/.bornim-pflege-$(TZ=Europe/Berlin date +%Y%m%d)"
if [ -f "$wt/tools/pflegehinweis.py" ] && [ ! -f "$pm" ]; then touch "$pm"; (python3 "$wt/tools/pflegehinweis.py" >/dev/null 2>&1 &); fi
# Commit-Prüfung (192.1): pre-commit-Haken, gilt für Notizkopie und Arbeitskopie (gemeinsames Verzeichnis); fehlt das Skript im Zweig, tut er nichts
hk="$(git rev-parse --git-common-dir)/hooks/pre-commit"
# D55.4: immer die Fassung von main (Notizkopie), auch in Arbeitszweigen ohne neue Fassung; alter Haken wird ersetzt
if [ ! -f "$hk" ] || ! grep -q "commit-pruefung (D55.4)" "$hk" 2>/dev/null; then
    mkdir -p "$(dirname "$hk")"
    printf '#!/bin/sh\n# commit-pruefung (D55.4)\nf=/home/user/bornim-main/tools/commit-pruefung.py; [ -f "$f" ] || f=tools/commit-pruefung.py\nif [ -f "$f" ]; then python3 "$f" || exit 1; fi\nexit 0\n' > "$hk" && chmod +x "$hk"
fi
echo "$neu" > "$mark"
# 658: Reaktionen und Nachrichten des Chefs auf Telegram (👍 gebilligt, ✅ erledigt), letzte 120 Minuten; nur Text, still ohne Schlüssel
[ -f "$wt/tools/reaktionen.py" ] && timeout 40 python3 "$wt/tools/reaktionen.py" 2>/dev/null
echo "Arbeitskopie für Notizen: $wt"
schluss
