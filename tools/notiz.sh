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
# 1701 (Sokrates 18.11., 20:29: Notizkopie mit 60 eigenen, 341 fehlenden Commits, Stand 03:39): ein neuer Container kann eine alte
# Notizkopie mitbringen (gesicherter Stand der Umgebung). Eigene Commits werden vor jeder Pause gepusht (CLAUDE.md); sind alle nicht
# gepushten Commits älter als 2 Stunden, ist es eine alte Kopie: sichern (Zweig backup-alt-<Zeit>) und auf origin/main setzen,
# statt sie hineinzumischen (das Mischen brachte gestrichenen Text zurück).
if [ -z "$(git -C "$wt" status --porcelain)" ] && [ -n "$(git -C "$wt" rev-list -1 origin/main..HEAD 2>/dev/null)" ]; then
    juengst=$(git -C "$wt" log -1 --format=%ct origin/main..HEAD 2>/dev/null)
    if [ -n "$juengst" ] && [ $(( $(date +%s) - juengst )) -gt 7200 ]; then
        b="backup-alt-$(TZ=Europe/Berlin date +%m%d-%H%M)"
        n=$(git -C "$wt" rev-list --count origin/main..HEAD)
        git -C "$wt" branch -f "$b" HEAD && git -C "$wt" reset -q --hard origin/main \
            && echo "Bornim (1701): alte Notizkopie ($n nicht gepushte Commits, jüngster $(TZ=Europe/Berlin date -d @"$juengst" '+%d.%m., %H:%M')) gesichert als Zweig $b und auf origin/main gesetzt; nur prüfen, falls dort Eigenes fehlt."
    fi
fi
# Arbeitskopie auf den neuesten Stand; eigene, noch nicht gepushte Commits bleiben (Zusammenführen, kein Rebase).
if [ -z "$(git -C "$wt" status --porcelain)" ]; then
    git -C "$wt" merge -q --ff-only origin/main 2>/dev/null || git -C "$wt" merge -q --no-edit origin/main 2>/dev/null \
        || { git -C "$wt" merge --abort 2>/dev/null; echo "Bornim (236): Notizkopie $wt ließ sich nicht mit main zusammenführen, abgebrochen. Sicherung und Reset: git -C $wt branch -f backup-lokal-main main && git -C $wt reset --hard origin/main"; }
fi

neu=$(git rev-parse origin/main)
alt=$(cat "$mark" 2>/dev/null)

# Startwarnungen mit festem Besitzer (1642; 340.12 Änderung 1): Wächter 77, 98, 108, 969, 650.2 bei jedem Start, Größe und
# Pflegefehler einmal am Tag (1129 A 7); Prüfungen und Besitzer nur in tools/startwarnung.py.
pw="$HOME/.bornim-pflegewarnung-$(TZ=Europe/Berlin date +%Y%m%d)"
sw_alle=""; [ "$1" != "--kurz" ] && [ ! -f "$pw" ] && { touch "$pw"; sw_alle="--alle"; }
[ -f "$wt/tools/startwarnung.py" ] && python3 "$wt/tools/startwarnung.py" --zeigen $sw_alle 2>/dev/null
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
# 1642: Startwarnungen fortschreiben (nach 6 h Vorgang beim Besitzer, gelöste schließen) bei jedem Start; Rollenspiegel ab Mittwoch
# nach dem Tagesbericht als Zeile „Spiegel“ (1461; darum ein zweiter Lauf, sobald der Tagesbericht des Tages steht);
# im Hintergrund, eigener Commit auf origin/main ohne Arbeitskopie
[ -f "$wt/tools/startwarnung.py" ] && (python3 "$wt/tools/startwarnung.py" --pflegen >/dev/null 2>&1 &)
# Commit-Prüfung (192.1): pre-commit-Haken, gilt für Notizkopie und Arbeitskopie (gemeinsames Verzeichnis); fehlt das Skript im Zweig, tut er nichts
hk="$(git rev-parse --git-common-dir)/hooks/pre-commit"
# D55.4: immer die Fassung von main (Notizkopie), auch in Arbeitszweigen ohne neue Fassung; alter Haken wird ersetzt
if [ ! -f "$hk" ] || ! grep -q "commit-pruefung (D55.4)" "$hk" 2>/dev/null; then
    mkdir -p "$(dirname "$hk")"
    printf '#!/bin/sh\n# commit-pruefung (D55.4)\nf=/home/user/bornim-main/tools/commit-pruefung.py; [ -f "$f" ] || f=tools/commit-pruefung.py\nif [ -f "$f" ]; then python3 "$f" || exit 1; fi\nexit 0\n' > "$hk" && chmod +x "$hk"
fi
echo "$neu" > "$mark"
# 658: Reaktionen und Nachrichten des Chefs auf Telegram (👍 gebilligt, 👎 falsch, ✅ erledigt; Prüfpunkte t<n>.<k> je Build eine Zeile, 1217), letzte 120 Minuten; nur Text, still ohne Schlüssel
[ -f "$wt/tools/reaktionen.py" ] && timeout 40 python3 "$wt/tools/reaktionen.py" 2>/dev/null
echo "Arbeitskopie für Notizen: $wt"
schluss
