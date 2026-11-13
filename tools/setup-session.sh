#!/usr/bin/env bash
# Richtet eine Sitzung für schnelle, sparsame Tests ein (siehe docs/LISTE-BAUEN-TESTEN.md). Läuft beim Sitzungsstart
# über .claude/settings.json und lässt sich jederzeit von Hand wiederholen.
#   tools/setup-session.sh          Godot holen, falls es fehlt (~/godot/godot, Fassung wie godot.yml)
#   tools/setup-session.sh --warm   dasselbe im Hintergrund, danach Daten und Import für tools/t logik (Log: /tmp/bornim-warm.log)
# 882.2: ohne Kotlin; kein Vorübersetzen der Kerntests mehr. Gradle-Spiegel nur, solange core/ da ist (1207: wald_daten.sh,
# pruef348/*.sh rufen bis 882.1/870.10 noch gradlew; Maven Central weist die Cloud mit 429 ab).
cd "$(dirname "$0")/.." || exit 1
rm -f ~/.gradle/init.d/maven-mirror.gradle  # Vorgänger von Hand (09.10.)
if [ -d core ] && [ -f tools/gradle-mirror.gradle ]; then
    mkdir -p ~/.gradle/init.d && cp tools/gradle-mirror.gradle ~/.gradle/init.d/bornim-maven-mirror.gradle
else
    rm -f ~/.gradle/init.d/bornim-maven-mirror.gradle
fi
V=$(sed -n 's/^ *GODOT: "\([0-9.]*\)".*/\1/p' .github/workflows/godot.yml | head -1)
holen() {
    [ -x ~/godot/godot ] && return 0
    mkdir -p ~/godot && cd ~/godot || return 1
    curl -sSL --retry 3 -o g.zip "https://github.com/godotengine/godot/releases/download/$V-stable/Godot_v$V-stable_linux.x86_64.zip" \
        && unzip -q -o g.zip && mv "Godot_v$V-stable_linux.x86_64" godot && rm -f g.zip
}
if [ "$1" = "--warm" ]; then
    # Daten wie „Karten und Texte“ und Import: der erste tools/t logik spart so etwa 10 s
    nohup bash -c "$(declare -f holen); V=$V; holen && cd '$PWD' && python3 tools/godot/bau_am_rechner.py 'Karten und Texte' 'Klang' \
        && ~/godot/godot --headless --import --path godot && touch godot/.godot/logik-import" >/tmp/bornim-warm.log 2>&1 </dev/null &
    echo "Bornim: Godot $V und Import für tools/t logik im Hintergrund (/tmp/bornim-warm.log)."
else
    (holen) && echo "Bornim: Godot $V bereit (~/godot/godot)." || echo "Bornim: Godot $V nicht geholt (Netz?)."
fi
# Wer bin ich, was hat sich an den Notizen auf main geändert (CLAUDE.md, „Sitzungsstart“)
tools/notiz.sh --kurz
