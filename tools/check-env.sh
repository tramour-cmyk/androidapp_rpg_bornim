#!/usr/bin/env bash
# Prüft, ob eine Sitzung alles hat, was die Arbeit an "Chroniken von Bornim" braucht (siehe docs/UMGEBUNG.md).
# Aufruf im Hauptordner:  tools/check-env.sh          kurz: Programme und Versionen
#                         tools/check-env.sh --full   dazu Kerntests und ein Vorschaubild (warm unter 15 s, kalt einige Minuten)
cd "$(dirname "$0")/.." || exit 1
ok=0; bad=0
pass() { echo "  OK    $1"; ok=$((ok + 1)); }
fail() { echo "  FEHLT $1"; bad=$((bad + 1)); }

echo "Programme:"
if command -v java >/dev/null; then
    v=$(java -version 2>&1 | grep -m1 version | sed -E 's/.*"([0-9]+).*/\1/')
    if [ "${v:-0}" -ge 21 ]; then pass "Java $v (JDK 21 nötig für tools/preview)"; else fail "Java $v gefunden, JDK 21 nötig"; fi
else fail "Java (JDK 21)"; fi
[ -x ./gradlew ] && pass "Gradle-Wrapper (lädt Gradle $(sed -n 's/.*gradle-\([0-9.]*\)-bin.*/\1/p' gradle/wrapper/gradle-wrapper.properties) selbst)" || fail "./gradlew nicht ausführbar"
command -v git >/dev/null && pass "git" || fail "git"
command -v python3 >/dev/null && pass "python3 (kleine Textänderungen an Dateien)" || fail "python3"
if command -v montage >/dev/null && command -v convert >/dev/null; then pass "ImageMagick (montage, convert: Filmbilder zuschneiden und zusammensetzen)"
else fail "ImageMagick: sudo apt-get install -y imagemagick"; fi

echo "Repository:"
[ -f CLAUDE.md ] && [ -f docs/OFFEN.md ] && [ -f docs/STIL.md ] && pass "CLAUDE.md, docs/OFFEN.md, docs/STIL.md" || fail "Projektdateien unvollständig"
if git ls-files --error-unmatch local.properties >/dev/null 2>&1; then fail "local.properties ist eingecheckt (darf nicht)"; else pass "local.properties nicht im Repository"; fi
if git ls-files | grep -qiE '\.(jks|keystore)$'; then fail "Keystore im Repository (darf nicht)"; else pass "kein Keystore im Repository"; fi

echo "Netz (Abhängigkeiten für Gradle):"
# Eine echte Bibliotheksdatei, nicht die Startseite: die antwortet auch dann, wenn Downloads mit 429 abgewiesen werden.
pom=org/jetbrains/kotlin/kotlin-stdlib/2.1.21/kotlin-stdlib-2.1.21.pom
code() { curl -sS -o /dev/null -m 20 -w '%{http_code}' "$1" 2>/dev/null; }
c=$(code "https://repo.maven.apache.org/maven2/$pom")
m=$(code "https://maven-central.storage-download.googleapis.com/maven2/$pom")
if [ -f ~/.gradle/init.d/bornim-maven-mirror.gradle ]; then
    if [ "$m" = 200 ]; then pass "Gradle lädt über den Google-Spiegel von Maven Central (erreichbar; Maven Central selbst: $c)"
    else fail "Google-Spiegel antwortet mit $m (Netzwerkregel der Umgebung prüfen)"; fi
elif [ "$c" = 200 ]; then pass "Maven Central liefert Dateien (Spiegel nicht eingerichtet: tools/setup-session.sh)"
else fail "Maven Central antwortet mit $c und der Spiegel fehlt: tools/setup-session.sh ausführen"; fi

if [ "$1" = "--full" ]; then
    echo "Bauen und Testen (dauert):"
    t0=$(date +%s)
    if ./gradlew -q -p core test >/tmp/check-core.log 2>&1; then pass "Kerntests (./gradlew -p core test, $(( $(date +%s) - t0 )) s)"; else fail "Kerntests, siehe /tmp/check-core.log"; fi
    t0=$(date +%s)
    rm -f tools/preview/build/screens/vermin_stirge_0.png
    if (cd tools/preview && VERMINANIM=stirge:0 ../../gradlew -q run >/tmp/check-preview.log 2>&1) && [ -f tools/preview/build/screens/vermin_stirge_0.png ]; then
        pass "Vorschauwerkzeug (tools/preview, Bild build/screens/vermin_stirge_0.png, $(( $(date +%s) - t0 )) s)"
    else fail "Vorschauwerkzeug, siehe /tmp/check-preview.log"; fi
fi

echo
echo "Ergebnis: $ok in Ordnung, $bad fehlen."
[ "$bad" -eq 0 ]
