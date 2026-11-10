# 894 · Godot-Build startet von selbst: ohne Gerätetest auf main?
Perikles · 10.11., 19:34 · B Werkzeuge · aus deinem Wort 19:31 zu Build 275 (über Sokrates)
Kurz: Testbuilds `claude/build-<n>` bauen künftig von selbst die Godot-APK; der Kotlin-Lauf erscheint am PR nicht mehr.

Geprüft an: fd8971a20 (Zweig `claude/perikles-894-build-start`)

**Frage:** Darf diese Änderung ohne Gerätetest auf `main`? Sie ändert nur die Abläufe auf GitHub, keine Spiellogik und nichts in der APK.

**Votum:** „894 A“: ja, auf main; ich führe zusammen und ziehe `LISTE-CHECK-BUILD-TEST.md` 4 nach.

**Berührt:** Tom und Jerry (jeder Testbuild), Sokrates (Zusammenführen nach „passt“, 13); 870.10 (Kotlin-Bau ganz aus) bleibt.

**Begründung:** Chef 19:31: „Tom hat 1 Stunde meiner Lebenszeit wieder verschwendet, um dann festzustellen, hoppala, ich habe ja doch keine APK gebaut, sondern nur die alte Kotlin-Fassung.“

**Sachverhalt:**
- `godot.yml` startete nur bei Push auf `claude/tom-348-**`, `claude/jerry-348-**` oder von Hand; `claude/build-275` passte nicht.
- Am PR lief nur `android.yml` (Kotlin, „Build APK“) und wurde grün; das sah aus wie der Build.
- Die Version in den Prüflisten kam ebenfalls aus dem Kotlin-Lauf (0.1.<n>), nicht aus der Godot-APK (0.348.<n>).

**Auswertung:**
- **A (Empfehlung):** `godot.yml` baut bei jedem Push auf `claude/build-**`, bei mehreren Pushes hintereinander nur den neuesten; `android.yml` heißt „Kotlin alt (kein Testbuild)“ und läuft nur noch auf main und von Hand; Version in Prüflisten aus dem Godot-Lauf. Kosten: keine Spielzeit, ein Lauf je Push auf einen Testbuild.
- **B:** nur umbenennen, Godot weiter von Hand starten; der Fehler bleibt möglich.
- **Stärkstes Gegenargument gegen A:** jeder Push auf einen Testbuild kostet einen Lauf von etwa einer Stunde; wer drei Zweige nacheinander hineinmischt und jedes Mal pusht, startet drei. Antwort: der neueste Push bricht den älteren Lauf ab, es läuft nur einer.

**Folgerungen:** nach A: Zusammenführen auf main, Liste 4 nachziehen, Tom und Jerry per Vorrat Bescheid (Perikles).

Antwort: …
