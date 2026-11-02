# 417 · Tragart Runde 5/6: Schild an der Seite, Axt mit beiden Fäusten · Tom · 02.11., 00:5x

[Film von 02.11., 03:39](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/02-0339-417-Tom.mp4) (eingetragen von meldung.sh, Tom)

[Film von 02.11., 02:24](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/02-0224-417-Tom.mp4) (eingetragen von meldung.sh, Tom)

[Film von 02.11., 00:53](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/02-0053-417-Tom.mp4) (eingetragen von meldung.sh, Tom)

[Film von 01.11., 23:54](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/01-2354-417-Tom.mp4) (eingetragen von meldung.sh, Tom)

[Film von 01.11., 22:53](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/01-2253-417-Tom.mp4) (eingetragen von meldung.sh, Tom)

**Bitte den neuesten Film (02.11., 02:2x) beurteilen; 00:53 und älter sind überholt.** Neu gegenüber 00:53 (Lauf 41368062432): Kriegsaxt und Schwert mit Schild je von beiden Seiten (Raster 3 × 2), Felder mit Waffe und Seite beschriftet, Bild 1,2-fach weiter (Axtblatt nicht mehr am Rand). Je Feld: 1 s Stehen, 2,5 s Gehen, 2,5 s Rennen, 1,5 s Gehen, Stehen. Damit sieht man, ob das Schwert beim Schildträger durch Kopf und Bein geht oder nur hinter dem Körper liegt (gemessen frei).

**Noch nicht behoben: Fuß rutscht im Rennen.** Der Prüfer hatte recht: im Film gleitet der Standfuß im Rennen 10–22 % des Tempos (Bogen 10, Schild 18, Axt 22), obwohl dieselbe Bewegung einzeln abgespielt fest steht (0–4 %). Der Fehler liegt im Abspielen beim Wechsel Gehen–Rennen (Überblendung, Tempo), nicht in der Bewegung; Ursache wird ohne Bild nachgestellt, dann behoben. Nebenbei behoben: das Einhandrennen war 31 % falsch umgetaktet.

**Stärkstes Gegenargument:** das Rutschen kann auch im Spiel stecken (gleicher Ablauf in `held.gd`); dann betrifft die Behebung Held und Leute, nicht nur den Film.

**Zu sagen:** je Waffe „passt“ oder was anders sein soll (ohne das Rutschen).

**Stand 00:53:** Neu gegenüber 23:54 (Lauf 41361118983): Schwertarm beim Schild 15 Grad nach außen (vorher 9), das Schwert beim Rennen nicht mehr im Oberschenkel (frei 7,0 cm; 12 Grad wären 6,0). Messung aller vier Waffen ohne Fehler. Stand 23:54: Neu gegenüber 22:53 (Lauf 41356789633): Füße im Rennen am Boden statt schwebend (tiefster Ballen höchstens 4,0 cm statt 8,4–10,6; Stehen 1,5). Ursache: das Becken wurde im Verhältnis der Beckenhöhen im ersten Bild gesetzt, im Rennen 5–10 % zu hoch; jetzt nach der Beinlänge wie im Kampf (438a). Schild im Gehen: Schildarm 12 Grad nach außen, frei 6,3 cm (vorher 5 von 15 Bildern bis 5 cm im Körper; 8 Grad wäre knapp frei mit 3,9 cm). Schwert beim Rennen mit Schild war in 1 von 15 Bildern 4,9 cm im rechten Oberschenkel (in 00:53 behoben).

Film per Telegram (8,7 s, Raster 2 × 2), wie im Spiel gezeichnet, auf dem Grundstand 461 (`claude/grundstand-461`, 878b15f9f); Ablauf `tom-probe-417.yml`, Lauf 41350556171; noch kein Build. Oben links Kriegsaxt, oben rechts Schwert, unten links Schwert und Schild, unten rechts Bogen; je erst Gehen, dann Rennen. Gehen im Film mit dem Vorschlag 1,5 m/s (heute im Spiel 2,13; Runde 4 „schnelles Staxen“).

**Je Waffe: Bewegung aus Paket, eigene Änderung**

| Waffe | Gehen (Paket) | Rennen (Paket) | eigene Änderung, warum |
|---|---|---|---|
| Kriegsaxt | WalkForwardNormal2HandMelee | Sprint2HandMelee | Axt 0,30 m zur Spitze verschoben, Schaft durch beide Fäuste (Chef 20:4x: „die untere Hand hält die Axt überhaupt nicht“); linke Faust jetzt 0,0 cm (Gehen) und 0,5 cm (Rennen) am Schaft, vorher 5,6 und 9,8 cm |
| Schwert | WalkForwardHold1hMelee | SprintHold1hMelee | keine (Einhand „sieht okay aus“) |
| Schwert und Schild | **WalkNormal2S&S** (neu: entspanntes Gehen, Schild am Arm wie im Stand; vorher Kampfgang WalkForwardS&S, Schild vorn) | RunFastNormalS&S | Schild nicht mehr abgespreizt (Chef 20:4x: „so wie er steht“) |
| Bogen | WalkBow | RunFastBow | keine (Bogen „da ist alles gut“) |

Alle: Tempo auf das Spiel umgetaktet, Oberkörper aufgerichtet (Gehen 6,5–9,7 Grad vor, Stehen 8,0).

**Gemessen** (Waffe gegen Körper, Abstand in cm, negativ = im Körper):
- Axt: Gehen 8,5 frei, Rennen 3,5 frei, 0 Bilder im Körper.
- Schwert: Gehen frei bis −0,4 (Rücken, unter 1 cm), Rennen 4,1 frei.
- **Schild im Gehen: 5 von 15 Bildern bis 5 cm im Körper** (Rücken spine_03, linker Oberschenkel; unterer Schildrand). Das neue Paketgehen hält den Schild dicht am Körper; Behebung folgt (Schild am Arm wenige cm nach außen), Film danach. Rennen mit Schild frei (5,5).
- Bogen: Gehen und Rennen 2,4 frei.

**Stärkstes Gegenargument:** Rennen mit Schwert und mit Schild neigt den Oberkörper im Mittel 37 Grad vor (Paket so; Axt 30, Bogen 15); wirkt das wie Sprint statt Laufen, kommt es aus den Paketen, nicht aus unserer Stellung.

**Zu sagen:** je Waffe „passt“ oder was anders sein soll; Schild: Haltung am Arm so richtig (Durchdringung wird behoben)?

**Prüferbefund (nach dem Versand, 23:0x; Zahlen in Bildpunkten, mit unserer Messung):**
- Stillstand 0–0,9 s und ab 7,9 s; dort Kämpfer stark vorgebeugt, Bogenschützin aufrecht.
- Rundschild als schwarze Scheibe ohne Zeichnung.
- Axt: beide Fäuste am Schaft (Gehen, Rennen); 4,75–5,75 s obere Hand mit gespreiztem Daumen und Fingern; im Stand nur eine Hand am Schaftende.
- Rennen mit Schild: Kopf stark gesenkt, Blick zu Boden.
- Verdacht Schwert über der Schulter durch den Hals (1,75–3,0 s); gemessen nächster Abstand Schlüsselbein 2,0 cm, Hals 3,1 cm, also frei.
- Verdacht Bogenarm durchs Bein im Rennen; gemessen 2,4 cm frei.
- Schild-Durchdringung im Film nicht zu sehen (Schild auf der Kameraseite).
- **Rennen: Füße erreichen den Boden nie, 7–16 Bildpunkte darüber (Figuren schweben)**; Langschwert Rennen Verdacht Rutschen.
- Axtblatt stößt im Rennen an den Feldrand; Beschriftung nur Kennungen ohne „Gehen“, „Rennen“.

**Prüferbefund zum Film 23:54 (nach dem Versand, 00:0x; Bildpunkte im Feld, dazu unsere Messung):**
- Rennen am Boden: Einhand, Schild, Bogen 0 Bildpunkte über dem Gehen, Axt 4–6 (vorher 7–16).
- Neu gesehen: Axt beim Gehen beidfüßig 12–16 Bildpunkte in der Luft (2,0, 2,8, 3,6 s), Einhand 8–9; gemessen tiefster Ballen Gehen Axt 2,8 cm, Einhand 4,7 (Stehen 1,5).
- Schwert beim Rennen mit Schild sichtbar im Oberschenkel, etwa 7 von 15 Bildern je Schritt (ab 4,73 s), Knauf hinten; gemessen 1 Bild tiefer als 1 cm (4,9 cm). Behebung wird gemessen.
- Rennen mit Schild stark vorgebeugt, Kopf vor der Schulter; Stillstand 0–0,97 s gebeugt, dann Sprung der Pose; Axt im Stand nur eine Hand.
- Schild nicht im Körper. Axtblatt am Feldrand abgeschnitten; Beschriftung nur Kennungen.

**Prüferbefund zum Film 00:53 (nach dem Versand, 00:5x; Bildpunkte, dazu unsere Messung):**
- Schildträger: Schwert beim Gehen waagerecht in Mundhöhe, Klinge quer durch den Kopf (2,1 s, 2,75 s); beim Rennen Klinge durch Hüfte und Oberschenkel, Knauf hinten aus dem Mantel (4,33, 5,33, 6,0 s). Gemessen im Raum: frei (Gehen Schlüsselbein 3,3 cm, Hals 4,9; Rennen Oberschenkel 7,0). Der Schildträger ist von links gefilmt, das Schwert in der rechten Hand liegt hinter dem Körper; ob Durchdringung oder Verdeckung, klärt der Nachfolger mit einem Bild von rechts.
- Axt beim Gehen einhändig senkrecht wie eine Fahne, linke Hand nicht am Stiel (2,0–3,7 s); gemessen linke Faust 0,0 cm am Schaft (von rechts gefilmt, die linke Hand liegt hinten). Rennen beide Hände sichtbar am Stiel.
- Füße: Gehen bis 16 Bildpunkte über dem Boden (Axt), Schild setzt nie ganz auf (6–10); Rennen setzt auf. **Rennen: Fuß 17–28 % langsamer als der Boden, rutscht (alle vier).**
- Schild verdeckt Kinn und Bart (4,67 s), nicht im Körper. Axtblatt am Feldrand abgeschnitten; Beschriftung nur Kennungen.

**Prüferbefund zum Film 02:2x (nach dem Versand, 02:3x; Felder 1–6 wie beschriftet):**
- Zuerst auffällig: bei 1,0 s springt die Haltung in einem Bild von stark vorgebeugt in aufrecht (Axt, Schwert, Schild von links); Stand am Anfang und Ende verschieden.
- **Schild von rechts, Gehen: Klinge durch den Kopf in Mundhöhe (1,75–3,25 s), jetzt von der Waffenseite bestätigt**; unsere Messung „frei“ war also falsch (Nachfolger prüft, warum der Kopf in der Messung fehlt). Rennen: Klinge nicht durch die Hüfte.
- Axt von links, Rennen: in etwa der Hälfte des Schritts keine Hand am Stiel, Stielende an Kinn oder Hals (4,1, 4,5, 4,7, 5,1, 5,7 s); Gehen eine Faust am Stiel; im Stand Axt waagerecht, Kopf vorn, beim Gehen Kopf oben.
- Schild beim Gehen tiefer an der Hüfte und pendelnd, nicht wie im Stand (Grundstand E8); im Stand fast schwarz.
- Bogen kreuzt beim Rennen schräg die Beine, Arm verschwindet hinter dem Bein (5,7 s).
- Füße: Rennen 6–8 Bildpunkte über dem Stand (Axt, Bogen nie ganz unten); **Rennen Fuß langsamer als der Boden: Axt 12 und 8 %, Schwert 22 %, Schild 12 und 17 %, Bogen 3 %**; Gehen gleichmäßig im Rahmen; Anlaufen (1,1–1,5 s) und Auslaufen (6,5–7,3 s) Füße gleiten deutlich (40–145 %).
- Grundstand: A1, A4, C2, G1, G2 ja; D4, E1, E3, E6, E8 nein. Text lesbar und richtig.
