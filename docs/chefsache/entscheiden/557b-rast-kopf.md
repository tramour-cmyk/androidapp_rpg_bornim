# 557b · Rast: Titel auf derselben Höhe wie überall, Flamme daneben?
Tom · 05.11., 07:4x · A Aussehen · berührt 557, 549

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/9af68a618

**Frage:** Nach „557a B“ beginnen alle zwölf Fenster und Schirme oben, die Knöpfe stehen am Inhalt (Bild 07:48, fremder Prüfer 07:46). Nur bei der Rast (Bilder 7, 8) steht über dem Titel die große Flamme (am Feuer) bzw. das Wirtshausschild (an der Theke), 64 dp hoch. Dadurch steht der Titel „RAST“ etwa 200 px tiefer als auf allen anderen Schirmen. Soll das so bleiben, oder soll das Zeichen neben den Titel?

**Votum Tom: B.** Titel auf derselben Höhe wie überall, das Zeichen links daneben, so wie Bild und Name im Kopf des Gegenstandsfensters.

**Berührt:** `rastfeld.gd` (nur Entwurf B), Bilder 7 und 8 der Gruppe 557.

## Auswahl

- **A** wie heute: Flamme groß über dem Titel, Titel 200 px tiefer als auf den anderen Schirmen.
- **B** Titel oben auf derselben Höhe, das Zeichen kleiner (etwa 40 dp) links neben dem Titel, Zierlinie darunter wie überall.

## Begründung

Deine Regel vom 04.11., 20:55 lautet: „Titel immer in derselben Höhe“. Das erfüllt nur B. Der Kopf „Bild links, Name rechts“ ist schon im Gegenstandsfenster und im Mengenkasten so. Die Rast braucht also keinen eigenen Baustein.

## Sachverhalt

Der Prüfer hat die Höhen gemessen (in px bei 1080 × 2340):
- Titelschrift in Bild 1, 2, 4–6: 107–108; in Bild 9–12: 115; in Bild 7, 8: 309–311.
- Der Kopf selbst beginnt überall bei 102–115. In der Rast ist das die Flamme.

Ebenfalls behoben (Commit 91f2f6527, ohne neues Bild, weil beide Läufe verbraucht sind):
- Name im Gegenstandsfenster (Bild 3) stand mittig neben dem Bild, 29 px tiefer; jetzt oben.
- Dem angelegten Stück in der Wechselliste (Bild 11) fehlte das Bild; jetzt hat es eins.

## Auswertung

**Stärkstes Gegenargument gegen B:** Die große Flamme ist das, woran man die Rast sofort erkennt. Du hast den Rastschirm am 04.11., 19:54 abgenommen, abgesehen vom Grund. Klein neben dem Titel wirkt sie weniger.

**Entkräftet:** Die Flamme bleibt da, nur kleiner und auf Augenhöhe mit dem Titel. Die Rast erkennt man außerdem am Titel und an den Wahlen (Kurz rasten, Lange rasten). Wichtiger ist, dass beim Wechsel zwischen den Schirmen nichts springt.

## Folgerungen

- Bei B: Tom baut das Zeichen neben den Titel, Test `gruppe_mass_557` misst die Titelhöhe; das Bild kommt mit dem nächsten Lauf.
- Bei A bleibt es, wie es ist.

**Zu sagen:** „557b A“ oder „557b B“.

Erledigt: Antwort ins Vorgangsarchiv, Datei löschen (Tom).
