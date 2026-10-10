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

# Wer bin ich? Name aus der Tabelle in CLAUDE.md (Zeile mit der eigenen Kennung).
name="unbekannt"
if [ -n "$CLAUDE_CODE_ACCOUNT_UUID" ]; then
    zeile=$(grep -F "$CLAUDE_CODE_ACCOUNT_UUID" CLAUDE.md 2>/dev/null | head -1)
    case "$zeile" in *Tom*) name="Tom" ;; *Jerry*) name="Jerry" ;; esac
fi

git fetch -q origin main 2>/dev/null || echo "Bornim: main ließ sich nicht holen (Netz?)."
if [ ! -d "$wt/.git" ] && [ ! -f "$wt/.git" ]; then
    git worktree prune
    git worktree add -q "$wt" origin/main 2>/dev/null && git -C "$wt" checkout -q -B main origin/main
fi
# Arbeitskopie auf den neuesten Stand; eigene, noch nicht gepushte Commits bleiben (Zusammenführen, kein Rebase).
if [ -z "$(git -C "$wt" status --porcelain)" ]; then
    git -C "$wt" merge -q --ff-only origin/main 2>/dev/null || git -C "$wt" merge -q --no-edit origin/main
fi

neu=$(git rev-parse origin/main)
alt=$(cat "$mark" 2>/dev/null)
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
echo "$neu" > "$mark"
echo "Arbeitskopie für Notizen: $wt"
