# 461d · Gültige Entscheidungen an einem Ort: in die DESIGN-Dateien statt eigener Liste?
Sokrates · 01.11., 22:52 · B Abläufe

**Frage** (Chef 22:48): „die Ausschlüsse daraus, sind die nicht in den Designvorlagen, in den Kampfvorlagen … auch schon alle drin? Und wenn sich keiner dran hält, bringt sie wieder nichts. Dann haben wir jetzt die gleichen Sachen wieder an 50 verschiedenen Orten.“ Soll statt der Umbenennung (461d, 22:48) jeder Punkt der Liste in die DESIGN-Datei seines Themas wandern?
**Votum Sokrates:** ja. Die Liste war meine Doppelung (gegen „jeder Text an einem Ort“).

## Sachverhalt (nachgesehen)

- Die Grundsätze stehen in `DESIGN-STIL.md` (Aussehen), `DESIGN-KAMPF.md` (Kampf), `DESIGN-ABNAHME.md` (wann fertig), `DESIGN-SPIELSYSTEM-2-0-ENTWURF.md` (Regeln). **Aber:** die Entscheidungen seit dem Umzug nach Godot (24.10.) fehlen dort fast alle: „Zusammenbruch“ steht in keiner DESIGN-Datei, „Waffe in der Hand“ nur im BRS, „Kaufkörper“ nur im Leitbild. Die DESIGN-Dateien sind Stand Kotlin; nachgezogen wurde nur ins Archiv. Darum gab es die Liste.
- `DESIGN-HELDENBAU.md` (Klassen, 13.10.) ist durch das BRS überholt und steht noch da.

## Vorschlag

1. Jeder der 40 Punkte wandert mit seiner Kennung (A1 …) in die DESIGN-Datei seines Themas: A–D nach `DESIGN-STIL.md`, E–F nach `DESIGN-KAMPF.md`, G nach `DESIGN-ABNAHME.md`. Danach gibt es die Liste nicht mehr.
2. `DESIGN-ABNAHME.md` bekommt oben einen kurzen Abschnitt „Vor jeder Vorlage“: nur die Kennungen mit einem Stichwort und Verweis, kein zweiter Text.
3. Was gilt, steht dann nur dort; das Archiv ist Verlauf (461b); wer neu entscheidet, ändert die DESIGN-Zeile im selben Commit (Commit-Prüfung, 461b).
4. `DESIGN-HELDENBAU.md` oben „überholt durch BRS“, Gültiges daraus ins BRS.
5. Daran halten: Tor 461a (Verstoß hält den Film an), Prüfer prüft nach Kennung, Diogenes zählt Widersprüche.

**Stärkstes Gegenargument:** die DESIGN-Dateien sind lang (24–26 KB) und werden darum seltener gelesen als eine Liste mit 40 Zeilen; genau deshalb blieb dort vieles liegen. **Entkräftet:** gelesen wird vor einer Vorlage nur der kurze Abschnitt „Vor jeder Vorlage“ mit den Kennungen; der Text steht trotzdem nur einmal.

**Folgerungen:** „ja“: Perikles sortiert ein (statt Umbenennung), Homer prüft die Stil-Punkte; „nein“: Umbenennung wie 22:48.

**Zu sagen:** „461d einsortieren“ oder „461d umbenennen“.
