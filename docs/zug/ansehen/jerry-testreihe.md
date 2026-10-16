# Jerry · Testreihe 16.10.: vier Sammelbuilds

Jerry · 16.10., 14:3x · ersetzt die 14 Einzel-Builds (108a: Chef „sinnvolles Bündeln, damit ich nicht alles extra installieren muss“). Vorher-/Nachher-Bilder und Hörproben kamen per Telegram.

Kurz: 4 Sammelbuilds statt 14 Einzel-APKs, je Build eine Prüfliste; Reihenfolge 1 → 4

**Zu tun:** Build 1 installieren, seine Punkte prüfen, Ergebnis je Punkt („1.2 passt“, „1.3 nicht, weil …“) schreiben; dann Build 2, 3, 4. Jeder Build enthält `main` (auch Toms #71) und lässt sich über 0.1.757 und 0.1.773 installieren; die Nummern steigen von 1 nach 4 (0.1.777–0.1.780).

APK: im PR unten unter „Checks“ → „build“ → „Artifacts“. Testmenü: Reiter „Test“ (Uhrzeit +3 h, Teleport, „Held trifft immer kritisch“, „Bosse zurücksetzen“, „Alle Vorräte auf mindestens 10“).

Build 1 und 2 passen, auf `main` (PR #88, #89). Build 3, 4, 5 passen (Chef 16.10., 15:2x–15:4x), werden zusammengeführt. Neu: Build 8, die Probe des neuen Kampfes (nach Build 6 und 7 testen); Build 9 Regen und Donner. Build 7 und 8 neu gebaut (16.10., 20:1x), damit die Nummern über Build 6 liegen: die neue APK aus dem PR nehmen.

## Build 3 · 0.1.779 · Kampf · [PR #90](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/90)

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 3.1 | 38, D4.1 | Höhle, Rauchbündel in der Tasche (beim Händler oder „Vorräte auffüllen“), Kampf gegen Krogg beginnen; danach verlieren | Held wirft das Bündel zu Kampfbeginn selbst, Kroggs erster Hieb geht ins Leere; nach Niederlage liegt das Bündel wieder in der Tasche | Bündel bleibt ungenutzt oder ist nach der Niederlage weg |
| 3.2 | 51 | einen Kampf verlieren (Magier und eine zweite Klasse), dreimal | Held liegt am Boden, kein Arm in der Luft, fällt nicht aus dem Bild | Arm steht nach oben; Held verschwindet links |
| 3.3 | 36.6 | Test: „Held trifft immer kritisch“ an, „Bosse zurücksetzen“, Krogg töten (Schwert und Speer) | Stücke beim Zerteilen und Durchbohren so fein wie Krogg selbst | grobe Pixel an den Stücken (Oberkörper teils hinter dem Rand: bekannt) |
| 3.4 | 53 | Krogg mit Feuer treffen (Feuerzauber oder Alchemistenfeuer) | Flammen sitzen auf Kroggs Umriss | Flammen links neben ihm |

## Build 4 · 0.1.780 · Schänke und Raumklang · [PR #91](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/91)

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 4.1 | 86.9 | in der Schänke Met trinken bis „betrunken“, dann draußen kämpfen und einmal fliehen | Held trifft seltener, Flucht misslingt öfter (im Kampf keine Anzeige, das ist so gewollt) | kein Unterschied zu nüchtern; Absturz beim Kampf nach dem Met |
| 4.2 | 119 | in der Höhle kämpfen und eine Truhe öffnen; in der Schänke Becher und Stühle hören; im Tempel und im Laden eine Tür; draußen kämpfen | Höhle hallt (Hiebe, Stimmen, Tür), Tempel weit, Schänke und Laden nah und gedämpft, draußen trocken wie bisher; Systemklänge überall gleich | Hall draußen; Treffer in der Höhle verschwimmen; Systemklang hallt |

## Build 5 · 0.1.782 · Gegnerstimmen · [PR #85](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/85)

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 5.1 | 18.11 | Höhle und Wald: gegen Keiler, Kobold, Riesenratte, Riesenspinne, Fledermaus kämpfen, dann Krogg (Test: „Bosse zurücksetzen“) | jeder Gegner ruft beim Angriff, bei Treffer und im Tod mit eigener Stimme, wie die Hörproben; Krogg tief und schwer | Gegner stumm; Stimme zu laut gegen die Hiebe; falsche Stimme |

Fällt ein Punkt durch, nehme ich ihn per `git revert` aus dem Build, der Rest geht auf `main` (78a).

## Build 6 · 0.1.797 · Musik in Schichten · [PR #87](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/87)

**Neu gebaut** nach 6.1 „nicht bestanden“: Spur jetzt ab etwa 8 Feldern (Beschluss; war 10), im Dorf keine. Im Menü prüfen, dass 0.1.797 installiert ist. Build 8 (0.1.796) ist niedriger: vorher deinstallieren, sonst lehnt Android ihn ab. Der Held darf höchstens 4 Stufen über dem Gebiet stehen (erster Wald: Stufe 5), sonst weichen gewöhnliche Monster aus und die Musik bleibt, wie sie ist. Stil-Abgleich: Musik orchestral und düster (Spur aus Celli und tiefen Streichern, CC0); Übergänge Ruhe ↔ Jäger nah (2 s weich) ↔ bemerkt (0,4 s in die Stille) ↔ Kampf (hart wie bisher), Jäger dreht ab (2 s zurück); geprüft mit Kerntest `MusicLayersTest`, das Gefühl nur am Gerät.

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 6.1 | 120 | Wald, Musik an; langsam auf einen Wolf oder Goblin zugehen (ab etwa 8 Feldern), vor der Bemerkgrenze (4 Felder) umdrehen und weggehen; dann noch einmal hin, bis er „!“ zeigt | beim Näherkommen wird die Musik leiser und dumpfer, eine dunkle Streicherspur wächst; beim Weggehen kommt alles weich zurück; beim „!“ Stille, dann setzt die Kampfmusik ein; beim nächsten Jäger eine andere Spur | nichts ändert sich; Sprünge in der Lautstärke; die Spur läuft im Kampf weiter |
| 6.2 | 120 | Höhle: wie 6.1 an einem Goblin oder Skelett | über dem Klangbett dieselbe Spur, leiser als draußen; Klangbett bleibt | Spur lauter als die Höhlenmusik |


## Build 7 · D1.14 und Testknopf · [PR #93](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/93)

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 7.1 | D1.14 | Höhle mehrmals betreten (Klangbett wechselt) | Tropfen, Wind, fernes Grollen; keine Hörner, keine Kreaturenrufe | Hörner zu hören |
| 7.2 | D4.1 | Test: „Alle Vorräte auf mindestens 10“ | ein Rauchbündel in der Tasche | kein Rauchbündel |

## Build 8 · 0.1.796 · Probe 72.10: Held und Söldner gegen Grak · [PR #68](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/68)

Erst die neue Kampfart zum Ausprobieren, noch nicht im Spiel: Reiter „Test“ → „Probe 72.10: Held und Söldner gegen Grak“ → Klasse des Söldners. Zahlen und Texte sind vorläufig (Texte bei Kreativ). Stil-Abgleich: gemalte Höhlenhalle mit Fackeln, Figuren im Fackellicht mit Schatten; Übergänge Ruhe ↔ Ausholen (Grak, solange der Ring läuft) ↔ Schlag mit kurzem Ausfall ↔ Ruhe, Treffer lässt zittern; selbst gefilmt durch die echte Oberfläche (Ring, Zielwahl, Wechsel der Züge). Bild des Rings per Telegram (18:5x).

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 8.1 | 72.10 | Probe starten (zuerst Kämpfer als Söldner) | nach 1–2 s stehen Held, Söldner und Grak; über Grak ein Schild mit seiner Absicht (»Rudel rufen«, »Schwerer Hieb«, »Kraft sammeln«) | Höhle bleibt länger als 3 s leer; Absturz |
| 8.2 | 72.11 | warten, bis Grak zuschlägt (nur Grak, Goblins ohne Ring); ein goldener Ring zieht sich um den Angegriffenen; irgendwo in die Szene tippen, wenn er sich schließt (mehrmals, auch zu früh und zu spät) | Grak holt sichtbar aus; oben „Perfekt!“, „Gut“ oder „Verpasst“; bei „Gut“ weniger Schaden, bei „Perfekt!“ keiner | Ring ruckelt; Tippen ohne Wirkung; Moment kaum zu treffen |
| 8.3 | 72.10, 72.13 | Angriff (bei mehreren Gegnern Ziel wählen), Platz, Abwarten; dann „Söldner: selbst“ auf „Automatik“ | Szene und Knöpfe bleiben ruhig an ihrem Platz; auf Automatik handelt der Söldner allein | Szene springt; Söldner wartet trotz Automatik |
| 8.4 | 72.11 | Grak hart treffen, solange er »Schwerer Hieb« oder »Kraft sammeln« angesagt hat | ab einem Fünftel seiner Lebenspunkte taumelt er, die Absicht ist vereitelt | Absicht läuft trotzdem |
| 8.5 | Gefühl | zwei, drei Durchgänge mit anderen Klassen (auch Magier) | spannend, echte Wahl zwischen Angreifen, Platz und Abwarten | langweilig; Takt nervt (dann sagen, was) |

## Build 9 · Regen und Donner · [PR #94](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/94)

Hörproben per Telegram (16.10., 20:0x). Stil-Abgleich: echte Aufnahmen statt Synthese, drei Fassungen je Klang; Übergänge Trocken ↔ Regen setzt ein ↔ Regen hört auf (blendet mit dem Regen), draußen ↔ drinnen (Regen weg), Erkunden ↔ Kampf (still); geprüft mit Kerntest.

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 9.1 | D3.10 | Test: „Regen: immer“; im Wald oder Dorf stehen, 1 min zuhören, dann „Regen: nie“ | Regen rauscht gleichmäßig ohne Knacken an der Schleifenstelle; nach dem Umschalten wird er über einige Sekunden leiser | kein Regen zu hören; Knacken alle 12 s; bricht hart ab |
| 9.2 | D3.10 | bei Regen ein Haus betreten, wieder hinaus; einen Kampf beginnen | drinnen still, draußen wieder Regen; im Kampf still | Regen drinnen gleich laut; im Kampf weiter |
| 9.3 | D3.10 | bei Regen draußen 5–10 min warten (Wetterleuchten kommt selten) | einige Sekunden nach dem Leuchten fernes, tiefes Grollen ohne Krachen | kein Donner; schrilles Krachen |

## Build 10 · Wölfe und Monster auf der Karte · [PR #95](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/95)

Hörproben per Telegram (16.10., 19:36 und 19:5x). Stil-Abgleich: echte Aufnahmen, drei Fassungen je Klang mit eigenem Charakter; „was man sieht, klingt selbst“. Übergänge: Ruhe (Laute) ↔ bemerkt („!“, Laute verstummen, Jagd) ↔ zurück nach Hause (wieder Laute). Geprüft mit Kerntest `MonsterIdleTest`; das Gefühl nur am Gerät.

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 10.1 | D3.8 | Tiefer Wald, 3–5 min stehen (Wolfsgeheul kommt selten) | drei verschieden klingende ferne Wölfe: ein einzelner, ein anderer, ein Rudel | immer derselbe Wolf |
| 10.2 | D3.9 | Wald: Test „Monster greifen nicht an“ an, an Wolf, Keiler, Goblin bis auf 2–5 Felder herangehen, je 30 s stehen | jedes Tier ab und zu leise zu hören (Schnüffeln, Grunzen, Räuspern), näher lauter, ab etwa 7 Feldern still; nie mehrere zugleich | stumm; zu laut oder zu oft; Tiere klingen gleich |
| 10.3 | D3.9 | Höhle (gleicher Testschalter): Skelett, Zombie, Fledermaus, Goblin | Knochen klappern, Stöhnen, Flügel; passt zum Tier | falscher Laut zum Tier |

