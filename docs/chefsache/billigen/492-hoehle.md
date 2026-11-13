# 492 · Vorentscheid „Blutzahnhöhle in Fassung B passt“ billigen?
Sokrates · 13.11., 03:33 · E Technik · Vorentscheid in der Nacht (Archiv 1077), nach deiner Wahl „492b“ (08.11., 21:46)
Kurz: Die Höhle in Fassung B ist jetzt auch im Spiel der Standard (vorher nur im Bildlauf). Das Lager zeigt die Kamera von unten mittig. Die Höhle fährt im nächsten Build, dann spielst du sie durch.

Geprüft an: [Lauf 412](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43341811945) (alle Prüftests grün), [Commit c063de7](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/c063de736) auf `claude/tom-492-durchspiel`; Vorlage Tom 03:29 (`ansehen/492-hoehle.md`, in Git), Bild `bilder/492-hoehle-b.jpg`

**Frage:** Seit dem 08.11. war noch ein Punkt offen: Im Lager stand eine Gestalt am Bildrand (G1). Passt die Höhle jetzt?

**Entschieden:** Ja, 492 passt. Das Lager mit dem Feuer und den Figuren ist ganz im Bild. Fassung B gilt jetzt im Spiel, nicht nur im Bildlauf. An allen acht Stellen (Eingang, Graks Halle, Gang, Lager, Krogg, Gitter, Teich, Westflügel) kommt das Licht nur von Fackel, Feuer und Kristallen, wie du es gewählt hast.

**Berührt:** 492 (Tom), 505 (Nebel)

**Begründung:** Erledigt ist genau das, was am 08.11. offen blieb. Dazu hat Tom einen Fehler gefunden, den keiner gesehen hatte: Im Spiel stand noch Fassung A mit den lila Wänden.

**Sachverhalt:**
- Acht Bilder aus Sicht des Helden, vom Wald aus durchgegangen, mit Nebel (Gesehenes gedämpft, der Rest schwarz).
- Fackeln brannten unter dem Nebel auch dort, wo der Held noch nicht war. Das ist behoben und mit einem Test belegt.
- Am Eingang liegt unten links ein heller, scharf umrissener Fleck auf Schwarz. Er war schon im Bild vom 08.11. zu sehen, ebenso am Teich.

**Auswertung:**
- **Stärkstes Gegenargument:** Der helle Fleck am Eingang kann ein Fehler des Nebels sein, und dann sähe ihn jeder Spieler beim Betreten der Höhle. Dagegen: Du hast ihn am 08.11. gesehen und trotzdem B gewählt. Tom nennt die Ursache am Rechner. Ist es ein Fehler, bekommt er einen eigenen Vorgang, der den Build nicht aufhält.

**Folgerungen:** 492 fährt im nächsten Build (Tom); danach spielst du die Höhle durch.

**Umgesetzt:** `c063de7` (Fassung B als Standard, Lager-Kamera, Fackeln unter dem Nebel)

**Rückbau:** Sagst du „zurück“, nennst du die Stelle im Bild; Fassung A wäre ein Wert in `c063de7`.

**Kosten:** ein Bildlauf

Antwort: …
