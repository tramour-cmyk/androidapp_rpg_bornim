#!/usr/bin/env bash
# Prüft, ob eine Sitzung alles hat, was die Arbeit an "Chroniken von Bornim" braucht (siehe docs/LISTE-BAUEN-TESTEN.md).
# Aufruf im Hauptordner:  tools/check-env.sh          kurz: Programme und Versionen
#                         tools/check-env.sh --full   dazu der Godot-Logiksatz (tools/t logik, etwa 2 Minuten)
# 882.2: ohne Kotlin (kein Java, Gradle, Maven-Spiegel, tools/preview mehr).
cd "$(dirname "$0")/.." || exit 1
ok=0; bad=0
pass() { echo "  OK    $1"; ok=$((ok + 1)); }
fail() { echo "  FEHLT $1"; bad=$((bad + 1)); }

echo "Programme:"
V=$(sed -n 's/^ *GODOT: "\([0-9.]*\)".*/\1/p' .github/workflows/godot.yml | head -1)
if [ -x ~/godot/godot ]; then
    g=$(~/godot/godot --version 2>/dev/null | tail -1)
    case "$g" in "$V".*) pass "Godot $g (wie godot.yml)" ;; *) fail "Godot $g gefunden, godot.yml baut mit $V (rm ~/godot/godot; tools/setup-session.sh)" ;; esac
else fail "Godot $V: tools/setup-session.sh"; fi
command -v git >/dev/null && pass "git" || fail "git"
command -v python3 >/dev/null && pass "python3 (kleine Textänderungen an Dateien)" || fail "python3"
python3 -c "import yaml" 2>/dev/null && pass "python3 yaml (tools/godot/logik.py, bau_am_rechner.py)" || fail "python3 yaml: pip install pyyaml"
if command -v montage >/dev/null && command -v convert >/dev/null; then pass "ImageMagick (montage, convert: Filmbilder zuschneiden und zusammensetzen)"
else fail "ImageMagick: sudo apt-get install -y imagemagick"; fi

echo "Repository:"
[ -f CLAUDE.md ] && [ -f docs/ARBEIT-TEAM-TOM.md ] && [ -f docs/DESIGN-STIL.md ] && pass "CLAUDE.md, docs/ARBEIT-TEAM-TOM.md, docs/DESIGN-STIL.md" || fail "Projektdateien unvollständig"
[ -f godot/tests/logik.txt ] && pass "Logiksatz godot/tests/logik.txt ($(grep -cv '^#' godot/tests/logik.txt) Tests)" || fail "godot/tests/logik.txt"
if git ls-files --error-unmatch local.properties >/dev/null 2>&1; then fail "local.properties ist eingecheckt (darf nicht)"; else pass "local.properties nicht im Repository"; fi
if git ls-files | grep -qiE '\.(jks|keystore)$'; then fail "Keystore im Repository (darf nicht)"; else pass "kein Keystore im Repository"; fi

if [ "$1" = "--full" ]; then
    echo "Testen (dauert):"
    t0=$(date +%s)
    if python3 tools/godot/logik.py >/tmp/check-logik.log 2>&1; then pass "Logiksatz ($(tail -1 /tmp/check-logik.log), $(( $(date +%s) - t0 )) s)"
    else fail "Logiksatz, siehe /tmp/check-logik.log"; fi
fi

echo
echo "Ergebnis: $ok in Ordnung, $bad fehlen."
[ "$bad" -eq 0 ]
