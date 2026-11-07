# 623 · Effektpakete REEBOO Labs: was kaufen, wie festhalten, Dank im Spiel · Sokrates · 07.11., 17:4x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/LISTE-QUELLEN.md

**Frage (Chef 07.11., 17:2x, elf Links, acht Fragen; „Können wir sicherstellen, dass wir nicht Sachen selbst bauen, wenn wir gute Effekte … in unserer Bibliothek haben? … spräche etwas dagegen, wenn man Reeboolabs an einer Stelle im Spiel erwähnt“):** Welche der Punkte A–F gelten? **Ersetzt 415d.1** (dort: Stylized VFX Pack 1, Status Effects, Beams).

**Votum Sokrates:** A, B1, C, D, E, F ja; B kaufen, wenn der Einbau ansteht (nach dem Durchspielen).

**Berührt:** 415, 415d, 415d.1 (geht hierin auf), 572, 488, 478, 2.17 (Zauber), 566, 591, 596, 598, 601, 497 („Über das Spiel“), 621 A (eine Probe je Thema).

Matrix je Paket mit Link: `LISTE-QUELLEN.md` (R1–R11). Zuordnung je Held, Monster, Ort: `LISTE-EFFEKTE.md`.

## Punkte

- **A · Jetzt kaufen, Kern für Kampf und Zauber (≈ 55,94 $):** R1 Combat VFX Mega (19,99), R2 Projectiles (7,99), R3 Weapon Trails (6,99), R4 VFX Pack 3 (6,99), R5 Character Shaders nur als Zusatzschicht (6,99), Status Effects (6,99, aus 415d.1). Passt zu 478: Jerry baut das BRS ohnehin am Kampf, Effekte kommen in einem Zug mit; Zauberliste 2.17 braucht sie.
- **B1 · Gras und Wasser jetzt kaufen (≈ 14,98 $), neu nach Chef 07.11., 17:4x:** „das sah schon wirklich sehr gut aus mit unterschiedlichen Gräsern, Blumen, Windrichtungen … Und der Fluss sah auch ernsthaft etwas besser aus als das, was wir da zu bieten haben. Oder Teich oder später … in Höhlen“. R9 Grass & Wind und R10 Water Kit dürfen dann auch unser Gras und unseren Fluss **ersetzen**; Einbau nach dem Durchspielen (488), vorher eine Probe am Dorfbach und im Flüsterwald (621 A), eigen gegen Kit, mit Tusche und auf deinem Handy. *Gegenargument:* Unser Fluss ist auf „wie alt“ und die Signatur abgestimmt (dunkel, ohne Tuschelinie); Spiegelung und Lichtbrechung des Kits können am Handy wegfallen. *Entkräftet:* genau das zeigt die eine Probe; der Höhlenteich (507) nimmt das Kit ohnehin.
- **B · Mit der Welt (≈ 26,99 $, ohne R9 und R10), kaufen wenn der Einbau ansteht:** R7 VFX Pack 2 **statt** Pack 1 (Pack 2 enthält Pack 1), R8 Weather FX, R9 Grass & Wind, R10 Water Kit. Grund für später: Aussehen der Welt ist bis zum Durchspielen eingefroren (488), und die Pakete werden gerade fast täglich verbessert (Water und Grass: Fassung von heute).
- **C · R6 Beams & Lasers erst nach R1:** R1 hat 10 Strahlen; fehlen dort Heiliger Strahl und Heilband, R6 dazu (6,99).
- **D · R11 Surface Shaders (19,99) erst Gratisprobe:** Compatibility ungetestet; vier Gratis-Shader (Runen, Schnee, Eis, Lava) im Spiel probieren, eine Probe (621 A).
- **E · Bibliothek vor Eigenbau, fest an Figur und Ort:** (1) Jede Effektwahl steht in `LISTE-EFFEKTE.md` und im Datenfeld `fx` je Waffe, Zauber, Zustand, Monster, Ort, nicht verstreut im Code; so sieht jeder Kampf gegen den Egel gleich aus. (2) Vor jedem Eigenbau eines Effekts dort und in `LISTE-BESTAND.md` nachsehen (wie Regel 377). (3) Perikles lässt die Commit-Prüfung warnen, wenn ein neuer Shader oder Teilchenknoten ohne Zeile in `LISTE-EFFEKTE.md` kommt.
- **F · Dank an REEBOO Labs im Spiel:** ja, in „Über das Spiel“ (497) unter „Mit Dank an“, zusammen mit allen fremden Quellen (Quaternius, Protofactor, Janpec und andere), Wortlaut von Homer; nicht im Spielgeschehen.

## Begründung und Gegenargumente

- **A:** Am meisten gewinnt der Kampf („nie langweilig“): heute hat MARS kaum Effekte, jeder Treffer sieht gleich aus. 106 + 36 + 25 + 24 Effekte für 50 $ statt Eigenbau, der laut 621 der teuerste Posten war. *Stärkstes Gegenargument:* Android ist bei keinem Paket getestet, und unsere Godot-Fassung (4.7.2) ist neuer als getestet. *Entkräftet:* Die Gratisproben liefen bei uns in 4.7 und Compatibility (415, 572); Bildrate misst Jerry am ersten Kampf mit Effekten, eine Probe je Thema.
- **R5 nur als Zusatzschicht:** Toon, Umriss, Randlicht des Pakets würden unsere Signatur (Toon-Licht, Tusche) ersetzen; darum nur Trefferblitz, Auflösen, Zustände, Schatten, Zielwahl als zweite Schicht über unserem Material.
- **E:** *Gegenargument:* noch eine Liste, noch eine Pflicht. *Entkräftet:* eine Zeile je Effekt; ohne sie baut die nächste Sitzung wieder selbst (417, 438 kosteten zusammen 339 $).
- **F:** Die Lizenz verlangt keine Nennung, erlaubt sie aber. *Gegenargument:* Spieler könnten „zusammengekauft“ denken. *Entkräftet:* Dank an Werkzeuge ist üblich und ehrlich; nur einer allein wäre ungerecht gegen die anderen Quellen, darum alle.
- **Lizenz (alle):** kommerziell, unbefristet, ohne Nennungspflicht, ohne Umsatzgrenze, keine Engine-Bindung im Text; Weitergabe der Dateien verboten. Darum nie in dieses öffentliche Repo: Kauf in `bornim-kaufmodelle`, der Bau holt sie (wie die Modelle).

## Folgerungen

- **Ja:** Du kaufst A auf itch.io und legst die Dateien ins private Repo (wie 572); Jerry baut sie mit 478 ein und trägt sie in `LISTE-BESTAND.md` und `LISTE-EFFEKTE.md` ein; Perikles setzt E (3); Homer schreibt den Dank (F) für 497. 415d.1 entfällt (Pack 1 nicht kaufen).
- **Nein:** 415d.1 gilt wie entschieden (Pack 1, Status, Beams), der Rest bleibt Vorschlag.

Antwort: „623 A B1 C D E F“ (oder die Buchstaben, die gelten), dazu B jetzt oder später.
