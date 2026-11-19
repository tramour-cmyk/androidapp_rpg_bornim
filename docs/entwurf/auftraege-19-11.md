# Aufträge 19.11. (Probe „Auftrag statt Startlektüre“, 1625; Chef 07:31/07:34)

Ford schickt jeden Auftrag wörtlich als Startnachricht, ohne Rollendatei, Vorrat oder Vorgangsregeln. Die Sitzung meldet am Ende nur „fertig“ mit Beleg an Ford; Eintragen und Melden übernimmt der Ablauf (bis zur Rolle dafür: Ford).

## Auftrag 1694 · Griff (Spike)

**Ziel:** Jede Figur des Spiels hält jeden Gegenstand sichtbar richtig: einhändig in der geschlossenen Faust, zweihändig mit beiden Händen am Griff. Heute gezeigt an Handbeil und Langschwert, gelöst für alle.
**Systemfrage (Pflicht):** keine Einzellösung. Gegenstände haben Haltepunkte (Griff, zweiter Griff bei Zweihändern, Höhe je Waffe), Figuren greifen nach Griffart (einhändig, zweihändig, Stab). Prüfe zuerst, wie Spiele das üblich lösen (Haltepunkte am Gegenstand und Handhaltung je Griffart) und ob unser Weg dem folgt. Vorberechnen aller Kombinationen nur, wenn es nachweislich besser ist.
**Stand:** Die alte Prüfung maß Knochen statt der sichtbaren Hand, dadurch 1 cm Luft (hohle Faust). Behoben auf `claude/spike-1694-griff` (`c64616f7a`): Tiefe aus dem Netz der Figur, Daumen schließt; Prüfung `griff_sicht_1694`. Lauf 19.11., 07:4x: Prüfung meldete −0,1 cm Spalt, das Bild zeigte den Stiel über dem Fingerrücken. Die Prüfung misst also noch nicht das Sichtbare; zuerst auf einem Einzelbild am Rechner nachstellen, warum, dann bauen.
**Beachte:** 1. Griff liegt in der Handinnenfläche, Finger ganz herum, Daumen dagegen. 2. Die Waffe ist farbig gebaut; ist sie im Bild schwarz, erst klären. 3. Gemessen wird das gezeichnete Netz in der Endpose. 4. Handwerk: `docs/LISTE-HANDWERK-FIGUR-PRUEFBILD.md`.
**Umsetzen:** Prüfung über alle Figurenarten mal alle gehaltenen Gegenstände (nicht nur zwei); dann genau ein Bildlauf: Handbeil und Langschwert, dazu ein Zweihänder, alt gegen neu, beschriftet, Nahsicht plus Spielkamera in Handygröße, nichts davor.
**Prüfe vor dem Senden:** 1. Liegt jeder Griff sichtbar in der Faust? 2. Ist die Waffe farbig? 3. Sieht man den Unterschied zu alt ohne Erklärung? 4. Ist die Prüfung über alle Kombinationen grün? Ein Nein: nicht senden.
**Zurück:** Bild an den Chef (`meldung.sh`), an Ford eine Zeile „1694 fertig, Bild <Zeit>, Prüfung <Zahl> Kombinationen grün“.

## Auftrag 1535 · Kleidung bei gehobenem Arm (Tom)

**Ziel:** Kleidung beult bei gehobenem Arm nicht über die Körperbreite aus, bei jeder Figur und jedem Kleidungsstück. Gesehen bei Garrick (Jacke) und einem Bewohner im Kittel (Build 299).
**Systemfrage (Pflicht):** keine Lösung nur für Garrick. Prüfe, wie Spiele Kleidung an gehobenen Armen lösen (Gewichte der Kleidung am Körper, Begrenzung der Dehnung) und wende es auf alle Kleidungsstücke an.
**Stand:** Ursache nachgestellt und gebaut (Weg in `ARBEIT-TEAM-TOM.md`, Zu 1535): gedehnte Fläche beim Trinken 0,134 → 0,032 m², bei Stehen_2 0,207 → 0,070 m².
**Beachte:** 1. Kleidung liegt über dem Körper, nie hindurch und nie als Beule daneben. 2. Gemessen wird das gezeichnete Netz in der Endpose. 3. Handwerk: `docs/LISTE-HANDWERK-FIGUR-PRUEFBILD.md`.
**Umsetzen:** Prüfung über alle Kleidungsstücke in allen Ruhebewegungen mit gehobenem Arm; dann genau ein Bildlauf: Garrick und der Bewohner im Kittel, alt (299) gegen neu, beschriftet, Spielkamera in Handygröße, Flanke markiert.
**Prüfe vor dem Senden:** 1. Ist die Beule ohne Erklärung sichtbar kleiner? 2. Ist das neue Modell im Bild (vorher am Rechner nachgewiesen)? 3. Ist die Prüfung über alle Kleidungsstücke grün? Ein Nein: nicht senden.
**Zurück:** Bild an den Chef, an Ford eine Zeile „1535 fertig, Bild <Zeit>, Prüfung <Zahl> Fälle grün“.
