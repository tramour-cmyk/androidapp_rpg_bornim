# 117 · Namen in docs/ und Archiv

Sokrates Projekt · 16.10., 13:10 · fortgeschrieben 13:1x

Kurz: 117.3 Ausmisten (Umgebung halbieren, Niederlassung kürzen); 117.1 `LISTE-RELEASE-NEUSTART` und `LISTE-BAUEN-TESTEN`; 117.2 „Dein Zug“ heißt künftig „Chefsache“ (Empfehlung)

**Entschieden** (Chef 13:1x: „da gehe ich mal voll mit, außer bei Arbeitabläufe und Arbeitumgebung …“): `ARBEIT-ARCHIV.md` einfrieren (Verlauf = Git), `STORY-K1-WELT`, `LISTE-VORGAENGE`, `DESIGN-BLENDE`. Umsetzung nach Sa 21:00 mit 99g-Rest und 102.

**117.1 Frage:** Wie heißen die beiden Nachschlage-Dateien? (Chef: „Abläufe, welche Abläufe? … Und Umgebung? Ja, wie Umgebung? Was denn?“)

**Empfehlung:**
- `ARBEIT-ABLAEUFE.md` → **`LISTE-RELEASE-NEUSTART.md`**: enthält genau zwei Abläufe, Release und Neustart einer Sitzung.
- `ARBEIT-UMGEBUNG.md` → **`LISTE-BAUEN-TESTEN.md`**: enthält Schnellprüfung, Tests, SDK, Bauen über GitHub, Werkzeuge und Vorschau-Schalter.

Gegenargument: Kommt ein dritter Ablauf dazu, passt der Name nicht mehr. Dann bekommt er eine eigene Datei, das ist billiger als ein vager Name.

**117.2 Frage:** Heißt „Dein Zug“ künftig **Chefsache** (Ordner `docs/chefsache/`, in Meldungen „Chefsache 117“)? (Chef: „Wie wäre es denn … Chefsache nennen oder irgendwas in die Richtung … Dein Zug finde ich echt schwierig“)

**Empfehlung:** Ja. „Chefsache“ sagt genau, was es ist: Sachen, die nur der Chef entscheidet oder ansieht; jeder versteht es ohne Erklärung. Erwogen: „Vorlage“ (passt nur fürs Entscheiden, nicht fürs Ansehen), „Eingang Chef“ (klingt nach Posteingang für alles).

Gegenargument: Umbenennen trifft 24 Dateien und vier Werkzeuge (Haken, Übersicht, `meldung.sh`, Action). Deshalb zusammen mit 117 nach Sa 21:00, nicht einzeln.

**117.3 Frage:** Ausmisten wie unten? (Chef 13:2x: „was brauche ich zum Android-SDK? … Vorschläge zum Ausmisten … je kleiner die sind, desto besser“)

**Empfehlung:** Ja, mit den Umbenennungen nach Sa 21:00.
- `ARBEIT-UMGEBUNG.md` (10 KB → etwa 5 KB, wird `LISTE-BAUEN-TESTEN.md`): **streichen** „Android-SDK in der Sitzung?“ (Antwort ist „nicht nötig“, ein Satz reicht), Tabelle „Was gebraucht wird“ samt Nachinstallieren (die Umgebung bringt alles mit, `tools/check-env.sh` prüft es), „Chat-Sitzung (claude.ai)“ (wir arbeiten nur in Cloud-Sitzungen), zweiter GitHub-Account (Pro läuft), „Was nicht im Repository liegt“, alte Messzeiten und Stand-Daten; Zufallsspieler auf eine Zeile. **Bleibt:** `tools/t` mit Anlässen, Kerntest-Befehl, Gradle-Spiegel, Build und APK, Testmodus im Spiel, Vorschau-Schalter.
- `ARBEIT-ABLAEUFE.md` (3 KB): Inhalt nötig; Neustart Schritte 4–6 (Ausweg über geplante Aufgabe) auf zwei Sätze.
- `LISTE-NIEDERLASSUNG.md` (4 KB): Einrichtung ist erledigt; 1a (Freigabeliste) fällt mit 99g weg; Rest auf „was tun, wenn Pro neu eingerichtet werden muss“ kürzen.
- `LISTE-KAPITEL1.md`: bleibt (Ziel offen: vier Punkte); Erledigtes streichen.
- `ARBEIT-ARCHIV.md` (477 KB): eingefroren (117).
- Größere Brocken ohne schnellen Gewinn: `LISTE-IDEEN.md` (17 KB, Ideen bleiben), Rollendateien (Kürzen mit 102).

Gegenargument: Gestrichenes fehlt, wenn die Umgebung sich ändert. Es bleibt in Git, und `tools/check-env.sh` meldet, was fehlt.
