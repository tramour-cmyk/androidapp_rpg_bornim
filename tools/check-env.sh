#!/usr/bin/env bash
# Prüft, ob eine Sitzung alles hat, was die Arbeit an "Chroniken von Bornim" braucht (siehe docs/UMGEBUNG.md).
# Aufruf im Hauptordner:  tools/check-env.sh          kurz: Programme und Versionen
#                         tools/check-env.sh --full   dazu Kerntests und ein Vorschaubild (einige Minuten)
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
if curl -sS -o /dev/null -m 20 -w '%{http_code}' https://repo.maven.apache.org/maven2/ 2>/dev/null | grep -qE '^(200|301|302)$'; then pass "Maven Central erreichbar"
else fail "Maven Central nicht erreichbar (Netzwerkregel der Umgebung prüfen)"; fi

if [ "$1" = "--full" ]; then
    echo "Bauen und Testen (dauert):"
    if ./gradlew -q :core:test >/tmp/check-core.log 2>&1; then pass "Kerntests (./gradlew :core:test)"; else fail "Kerntests, siehe /tmp/check-core.log"; fi
    rm -f tools/preview/build/screens/vermin_stirge_0.png
    if (cd tools/preview && VERMINANIM=stirge:0 ../../gradlew -q run >/tmp/check-preview.log 2>&1) && [ -f tools/preview/build/screens/vermin_stirge_0.png ]; then
        pass "Vorschauwerkzeug (tools/preview, Bild build/screens/vermin_stirge_0.png)"
    else fail "Vorschauwerkzeug, siehe /tmp/check-preview.log"; fi
fi

echo
echo "Ergebnis: $ok in Ordnung, $bad fehlen."
[ "$bad" -eq 0 ]
