# 496a · Sollen die abgenommenen Kampfbilder (Helden je Klasse, Atmen, Schild, Parade) schon in den Durchspiel-Build?
Team Jerry · 03.11., 07:46 · E Technik · Kurz: Durchspiel mit neuen oder alten Kampffiguren?

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41548422407

**Frage:** Build 204 zeigte dir im Kampf „die alten Männchen, die alten Wölfe, keine Atmung“ (Test 204.1, 07:35). Das ist kein Rückschritt im Code, sondern der Stand von `main`: alles, was du im Kampf seit dem 31.10. mit „passt“ abgenommen hast, liegt nur in Arbeitszweigen auf dem gemeinsamen Grundstand (461.1), und der ist laut Wochenziel (488) „nach dem Durchspielen“ eingefroren. Bleibt das so, spielst du Kapitel 1 im Durchspiel-Build (496) mit den alten Figuren. Soll der Grundstand vorher hinein?

**Votum:** Ja: „496a ja“. Jerry führt den Grundstand mit den abgenommenen Kampfzweigen in den nächsten gemeinsamen Build zusammen; was dort nicht abgenommen ist, bleibt im Spiel aus.

**Berührt:** 496 (Durchspiel-Build), 461.1 (Grundstand), 415 (Strahlenprobe), 403, 453, 453.1, 454, 439, 440, 406, 406.2; Tom 417 (liegt auch im Grundstand).

**Begründung:** Du sollst Kapitel 1 so durchspielen, wie es aussehen wird; sonst sind deine Befunde zum Kampf beim ersten Durchspielen zum Teil schon erledigt, und du testest Arbeit, die längst weiter ist.

**Sachverhalt:**
- Build 204 (Zweig `claude/build-487`) baut auf `main`. Dort fehlen 162 Code-Commits des Grundstands (`claude/grundstand-461`): Held je Klasse im Kampfort (403), Atmen der Helden und Wölfe (453, 453.1), Bissachse (454), Angriffsfolge und Wolfstod (439, 440). Schilde (406) und Parade (406.2) bauen darauf auf.
- Die Strahlenprobe 415 ist darum auch tot: ihr Programm braucht eine Funktion der neuen Kampffiguren (Körpermaße für den Strahl). Am Rechner mit genau dem APK von Build 204 nachgestellt: das Strahlenpaket ist im APK, aber vor dem ersten Strahl kommt jede Sekunde ein Programmfehler; der Kampf bleibt stehen, kein Strahl. Künftig läuft die Probe vor jeder Testbitte einmal am Rechner im APK des Builds.
- Zusammenführen geht: Probe am Rechner ergibt zwei Konflikte (Bauablauf und eine Kennungsdatei), beide klein.

**Auswertung:** Stärkstes Gegenargument: Der Grundstand ist groß (rund 275 Dateien, davon 124 Tests) und enthält auch nicht Abgenommenes, etwa Toms Tragart (417), die wegen 488 ruht. Ein großer Zusammenschluss kurz vor dem Durchspielen kann neue Fehler bringen und kostet etwa eine Sitzung plus einen Lauf. Entkräftet: Nicht Abgenommenes schalte ich im Spiel aus, wie bei 438a; die Kampfzweige wurden bisher alle auf diesem Grundstand gefilmt und geprüft, nur `main` ist der Ausreißer. Ohne den Grundstand müsste jede abgenommene Kampfarbeit nach dem Durchspielen ein zweites Mal geprüft werden.

**Folgerungen:** Bei „ja“: Jerry führt nach dem Parade-Film (406.2) Grundstand und Kampfzweige zusammen, prüft am Rechner (Standbild mit Strahl für 415, Kampf mit Helden je Klasse) und legt sie in den nächsten gemeinsamen Build; Tom erfährt es über seinen Vorrat. Bei „nein“: 415 kommt mit einer Ersatzrechnung ohne die neuen Figuren in den nächsten Build (dann wieder alte Figuren im Bild), alles andere bleibt bis nach dem Durchspielen.

Antwort:
