#!/usr/bin/env bash
# Richtet eine Sitzung für schnelle, sparsame Tests ein (siehe docs/UMGEBUNG.md). Läuft beim Sitzungsstart
# über .claude/settings.json und lässt sich jederzeit von Hand wiederholen.
#   tools/setup-session.sh          Maven-Spiegel für Gradle einrichten (Sekundenbruchteil)
#   tools/setup-session.sh --warm   dazu im Hintergrund die Kerntests vorübersetzen (Log: /tmp/bornim-warm.log)
cd "$(dirname "$0")/.." || exit 1
mkdir -p ~/.gradle/init.d
cp tools/gradle-mirror.gradle ~/.gradle/init.d/bornim-maven-mirror.gradle
rm -f ~/.gradle/init.d/maven-mirror.gradle  # Vorgänger von Hand (09.10.)
if [ "$1" = "--warm" ]; then
    # Nur core: das braucht jede Sitzung vor dem Commit. Die Vorschau übersetzt tools/t bei Bedarf;
    # der Hauptordner zöge das Android-Plugin, das ohne SDK nichts nützt.
    nohup ./gradlew -q -p core testClasses \
        >/tmp/bornim-warm.log 2>&1 </dev/null &
    echo "Bornim: Gradle-Spiegel eingerichtet, Vorwärmen läuft im Hintergrund (/tmp/bornim-warm.log)."
else
    echo "Bornim: Gradle-Spiegel eingerichtet."
fi
