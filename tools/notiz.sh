#!/usr/bin/env bash
# Notizen (CLAUDE.md, CHANGELOG.md, docs/) leben nur auf main. Dieses Skript hält eine zweite Arbeitskopie
# von main neben dem Arbeitszweig aktuell und zeigt, was sich seit dem letzten Aufruf geändert hat.
#   tools/notiz.sh          main holen, Name der Sitzung und neue Notiz-Änderungen zeigen
#   tools/notiz.sh --kurz   nur eine Zeile (für den Starthaken)
# Bearbeiten danach unter ../bornim-main, committen und sofort pushen (siehe CLAUDE.md).
cd "$(dirname "$0")/.." || exit 1
repo=$(pwd)
wt="$(cd "$repo/.." && pwd)/bornim-main"
mark="$(git rev-parse --git-common-dir)/notiz-zuletzt"

# Wer bin ich? Account aus der Tabelle in CLAUDE.md (Zeile mit der eigenen Kennung); auf Max laufen mehrere Rollen (D14, Anregung a).
name="unbekannt"
if [ -n "$CLAUDE_CODE_ACCOUNT_UUID" ]; then
    zeile=$(grep -F "$CLAUDE_CODE_ACCOUNT_UUID" CLAUDE.md 2>/dev/null | head -1)
    case "$zeile" in *Tom*) name="Zentrale (Tom, Ford, Sokrates oder Diogenes; Rolle aus der ersten Nachricht)" ;; *Jerry*) name="Jerry" ;; esac
fi

git fetch -q origin main 2>/dev/null || echo "Bornim: main ließ sich nicht holen (Netz?)."
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
    git -C "$wt" merge -q --ff-only origin/main 2>/dev/null || git -C "$wt" merge -q --no-edit origin/main
fi

neu=$(git rev-parse origin/main)
alt=$(cat "$mark" 2>/dev/null)

# Wächter Dokumentnamen (77, 13.10.): alte Dateinamen dürfen weder als Datei noch als Verweis zurückkommen.
# Archiv und Änderungshistorie sind Verlauf und bleiben ausgenommen.
altnamen='BERATER|DIOGENES|LEITBILD|STIL|ENTWICKLUNG|HELDENBAU|BALANCE|ZWISCHENBILD|STORY1|STORY|THEMEN|MERKLISTE|KAPITEL1|OFFEN|SELBST|ABLAEUFE|UMGEBUNG|ARCHIV'
alt_dateien=$(git ls-tree --name-only origin/main docs/ 2>/dev/null | grep -E "^docs/($altnamen)\.md$")
[ -n "$alt_dateien" ] && echo "FEHLER (77): alte Notizdatei wieder da: $(echo $alt_dateien). Inhalt in die neue Datei übernehmen, alte löschen, Nutzer melden."
alt_verweise=$(git grep -l -P "(?<![\w-])($altnamen)\.md" origin/main -- CLAUDE.md docs tools ':!docs/ARBEIT-ARCHIV.md' ':!tools/notiz.sh' 2>/dev/null | sed 's/^origin\/main://')
[ -n "$alt_verweise" ] && echo "Warnung (77): alte Dateinamen erwähnt in: $(echo $alt_verweise). Neue Namen: Vorsilben ROLLE-/DESIGN-/STORY-/LISTE-/ARBEIT- (CLAUDE.md, erster Absatz)."
# Wächter Bilder Dein Zug (108, D15.4): höchstens 60 KB je Datei, höchstens 3 Bilder je Punkt; Größeres über Telegram.
gross=$(git ls-tree -r -l origin/main docs/zug/ 2>/dev/null | awk '$4>61440 && $5 !~ /\.md$/ {print $5}')
[ -n "$gross" ] && echo "Warnung (108): Datei über 60 KB in docs/zug/: $(echo $gross). Verkleinern (800 px, JPG/WebP) oder über Telegram (--datei), Verlauf bleibt."
# Wächter Umbau 98 (15.10.): die alten Vorrats- und Rollennamen dürfen nicht zurückkommen.
altvoll='ARBEIT-OFFEN|ARBEIT-SELBST|ARBEIT-FORD|ROLLE-BERATER|ROLLE-FORD|ROLLE-ENTWICKLER|ROLLE-TESTER'
alt98=$(git ls-tree --name-only origin/main docs/ 2>/dev/null | grep -E "^docs/($altvoll)\.md$")
[ -n "$alt98" ] && echo "FEHLER (98): alte Datei wieder da: $(echo $alt98). Inhalt in den passenden Vorrat oder die neue Rollendatei (docs/FIRMA.md), alte löschen."
alt98v=$(git grep -l -E "($altvoll)\.md" origin/main -- CLAUDE.md docs tools .claude ':!docs/ARBEIT-ARCHIV.md' ':!tools/notiz.sh' 2>/dev/null | sed 's/^origin\/main://')
[ -n "$alt98v" ] && echo "Warnung (98): alte Dateinamen erwähnt in: $(echo $alt98v). Neue Namen in CLAUDE.md „Wo was steht“."
if [ "$1" = "--kurz" ]; then
    if [ -z "$alt" ]; then was="erster Aufruf, tools/notiz.sh zeigt die letzten Änderungen"
    else was="$(git rev-list --count "$alt..$neu" -- CLAUDE.md CHANGELOG.md docs 2>/dev/null) neue Änderungen seit dem letzten Mal (tools/notiz.sh zeigt sie)"; fi
    echo "Bornim: Diese Sitzung ist $name. Notizen auf main: $was."
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
# Größenwarnung (65.4c, 98): jeder Vorrat ARBEIT-*.md höchstens etwa 15 KB (außer Archiv, Abläufe, Umgebung).
for d in $(git ls-tree --name-only origin/main docs/ 2>/dev/null | grep -E '^docs/ARBEIT-.*\.md$' | grep -v -E 'ARBEIT-(ARCHIV|ABLAEUFE|UMGEBUNG)\.md'); do
    n=$(git show "origin/main:$d" 2>/dev/null | wc -c)
    [ "$n" -gt 15000 ] && echo "Warnung: $d hat $((n/100))00 Bytes (Grenze etwa 15000), kürzen (CLAUDE.md „Vorräte klein halten“)."
done
echo "$neu" > "$mark"
echo "Arbeitskopie für Notizen: $wt"
