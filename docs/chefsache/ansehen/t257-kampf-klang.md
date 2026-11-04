# Tom und Jerry · Build 257 · Godot 0.348.257 · eine Prüfliste für die Builds 251, 252, 255, 257 · [PR #184](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/184)
E Technik · Tom und Jerry · 04.11., 03:33; zusammengelegt von Sokrates 04.11., 07:5x (Chef 07:57: „bitte die Builds und Fragen konsolidieren“) · [Lauf 257, bornim-godot-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41761514918/artifacts/13292971716) (grün 04:18) · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41761514918 (Tests der Einzelbuilds 251, 252, 255, 257 je grün, Listen in Git)

**Was installieren:** zwei Builds.
1. **Build 250** ([t250](t250-strahlen-ohne.md), ein Punkt, Strahlenmessung 415): diese Messung steckt in keinem späteren Build.
2. Danach **Build 257** darüber installieren. Er enthält alles aus 251, 252 und 255; diese drei musst du nicht installieren, alle ihre Punkte stehen unten.

Die Nummern (251.x, 252.x, 255.x, 257.x) bleiben die der Teams, damit Antworten eindeutig sind. Reihenfolge = ein Weg durchs Spiel.

Verglichen (alt gegen neu): Reiter „Test“ (`TestTab.kt`); `SkirmishScreen.kt`, `MarsTips.kt`, `Monsters.kt`, `Packs.kt`, `DeviceInfo.kt`; `GearUi.kt`, `GearCompare.kt`, `MenuScreen.kt`, `Dialogs.kt`, `SlotsScreen.kt`, `App.kt`; `Battle.kt`, `WildSound.kt`, `WorldScreen.kt` (Fireflies), `TypeLook`, `Story.kt` (levelCap); übrige Punkte nach deinen Befunden zu Build 249.

## A · Hauptmenü — bestanden (Chef 04.11., 11:47: „der komplette Bereich A funktioniert“)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 257.1 | Tom | 498 | Handy-Einstellungen Schriftgröße einmal größer stellen, dann Hauptmenü „Über das Spiel“ | die Schrift wächst mit wie in der Kotlin-Fassung; bei normaler Größe so groß wie alt | Schrift bleibt gleich klein, egal was eingestellt ist |
| 255.1 | Tom | 497 | Hauptmenü, „Über das Spiel“, „Lizenzen der Engine“ antippen, durchrollen | die englischen Lizenztexte laufen in ganzen Absätzen über die Breite; eigene Zeile nur bei Aufzählung („1.“, „(a)“), „Copyright …“ und Überschrift | Zeilen brechen mitten im Satz ab, kurze Stummelzeilen, Sternrahmen, „Â©“ |
| 255.2 | Tom | 526 | Hauptmenü, Spielstände, bei einem Spielstand „Löschen“; dann im Spiel eine Rückfrage des Spielmenüs; jeweils: einmal in den Kasten, einmal daneben tippen, einmal Android-Zurück | in den Kasten tippen tut nichts; daneben tippen oder Zurück schließt nur die Rückfrage | Tippen in den Kasten schließt, Zurück verlässt den ganzen Schirm |

## B · Spielstand laden, Spielmenü

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 251.1 ✗ (Chef 11:52, Zu 555) | Tom | 555 | Reiter „Test“ von oben nach unten ansehen, Zeichen gedrückt halten | da sind: „Letzter Lauf“ und „Absturzbericht zeigen …“ (mit Kopieren); Messwerte mit „Blende: bereit nach …“; Held: Unsterblich, Schnell; Welt: Kartenzoom, Monster, Bosse, Truhen, Merker; Teleport Dorf, Wald, Tiefer Wald, Höhle; Stationen 1–8 (Garrick bis Kapitelende); Kampfhilfen Kritisch, Rettung; unter der Kampfliste „Neben den Helden holen“ | ein Eintrag fehlt, Text abgeschnitten, Zeichen überlappen |
| 251.4 ✓ (Chef 11:58) | Tom | 555 | „Schnell“ an, ein Stück gehen und rennen; „Kartenzoom“ mehrmals | dreifaches Tempo ohne Hängen; Zoom 5,6 / 6,75 / 8,4 / 10,5 Kacheln, dann wie unter Bedienung | Held hängt oder springt, Zoom ändert sich nicht |
| 251.6 ✗ (Chef 11:55, Zu 522) | Tom | 522 | Reiter „Test“: Waffe Langschwert, Andere Hand Schild; Menü schließen; dann im Ausrüstungsschirm etwas anderes anlegen | gleich nach dem Schließen trägt die Figur Langschwert und Schild, ohne Kartenwechsel; die Finger greifen die Waffe | alte Waffe bleibt bis zum Kartenwechsel, Finger glitchen |
| 255.3 ✓ (Chef 11:59) | Tom | 520 | Spielmenü, Reiter „Ausrüstung“ | der Held auf dem Drehteller ist so groß wie in der alten Fassung (165 × 253 dp, bisher 143 dp hoch); Kleidung zeigt er noch nicht (kommt mit 455) | Held klein wie in Build 249 |
| 255.4 ✗ (Chef 12:01, Zu 524 und 521) | Tom | 521, 523 | Reiter „Ausrüstung“, einen Platz antippen (Wechseln); dann Reiter „Tasche“ | je Gegenstand Bild, Name in der Farbe der Seltenheit, darunter Art, Waffe oder Platz, Wert, bei Bedarf „zweihändig“; nicht Tragbares mit „· nicht tragbar“ in Rot; rechts ▲ grün besser, ▼ rot schlechter; in der Tasche nach Platz sortiert; brennt ein Leuchtfunke: Zeile mit „Löschen“ | nur Name und Schaden, alles gleich aussehend |
| 255.5 ✗ (Chef 12:01, Zu 524 und 521) | Tom | 519, 524 | in der Tasche einen Ring und einen Kettenpanzer antippen | das Fenster passt ganz auf den Schirm, Name bricht neben dem Bild um, Knöpfe ganz lesbar; darin Seltenheit und Art, Tragort · Stufe · Gewicht, Schaden je Griff, RK mit GES, Eigenschaften blau, „Ungeübt“ oder „Zauberkraft nützt nur Zauberwirkern“, wenn es zutrifft | rechts abgeschnitten, Knöpfe ragen hinaus, nur Name und eine Zahl |

## C · MARS-Probekampf (Reiter „Test“, gegen das Wolfsrudel)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 251.10 | Jerry | 544 | Probekampf: Schrift im Kampfschirm | Alegreya mit Serifen wie im Menü | Ersatzschrift ohne Serifen |
| 252.1 | Jerry | 552 | Probekampf, oben am Bildschirm | die Zugreihenfolge steht unter der Kamera, ganz lesbar | oben nur ein leerer schwarzer Streifen |
| 252.2 | Jerry | 551 | Probekampf, der Goldrahmen um den Kasten unten, besonders unten links und rechts; bitte ein **Bildschirmfoto** | der Rahmen läuft rundum durch | an den unteren Ecken unterbrochen (zeigt das Bildschirmfoto die Lücke auch, ist es eine andere Ursache) |
| 252.3 | Jerry | 536 | Probekampf, eine halbe Sekunde auf „Angriff“ drücken, dann loslassen; ebenso auf „Abwehr“, „Held“ | unten erscheint eine Erklärung, was der Knopf tut; losgelassen passiert nichts | keine Erklärung, oder der Held greift an |
| 252.4 | Jerry | 536 | lang auf das Zeichen über einem Wolf drücken (die Ansage), dann lang auf einen Wolf selbst | Ansage: was sie heißt und was hilft; Wolf: Name, Absicht und auf wen | nichts erscheint |
| 252.5 | Jerry | 546 | Probekampf, zusehen, wenn ein Wolf einem Schlag ausweicht | er springt flink im Lauf zur Seite und kehrt dann zurück | er schleicht im Schritt weg („Schlaftabletten“) |
| 251.8 | Jerry | 527 | System „Tempo“ schnell, dann noch ein Probekampf | der Kampf läuft schneller; „Kampftext“ ist ausgeblendet | Tempo ohne Wirkung |
| 251.9 | Jerry | 532 | Zauberwirker: einen Zauber wirken, Kampf beenden, gleich noch einen Kampf; danach rasten | Zauberpunkte und Verbrauchtes kommen aus dem ersten Kampf mit, Zustände bleiben; nach der Rast voll | jeder Kampf beginnt voll |

## D · Dorf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 251.7 | Tom | 530 | Station „1 Garrick“ oder bei Aldric den Auftrag holen, zum Schlagbaum im Norden; dann speichern, Spielstand laden | der Schlagbaum steht offen, auch nach dem Laden | Balken bleibt zu |
| 257.2 | Tom | 514 | nachts (Testmenü ☾) im Dorf und im Flüsterwald an Blumen, Wiesen, Wasser- und Waldrand stehen; mehrere Nächte | in manchen Nächten Schwärme von Glühwürmchen, treiben langsam, blinken einzeln, ein Nachbar antwortet; im tiefen Wald wenige | keine, oder gleichmäßig leuchtende Punkte, die nicht blinken |

## E · Flüsterwald

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 257.3 | Jerry | 517 | Flüsterwald am Tag eine halbe Minute stehen; nachts dasselbe; dann Tiefer Flüsterwald zwei bis drei Minuten (nachts) | am Tag Vögel, nachts Grillen, im Flüsterwald manchmal eine Eule; im Tiefen Wald keine Vögel, fern von einer Seite ein Wolf heulen | nur Wind und Feuer, oder Vögel im Tiefen Wald |
| 251.3 | Tom | 554 | Teleport „Wald“, „Monster“ antippen (beachten nicht), an Wölfen und Ratten vorbeigehen, dann in eine hineinlaufen | Monster laufen wie sonst, jagen nicht, kein Überfall im Gras; Hineinlaufen beginnt den Kampf; noch einmal antippen: sie jagen wieder | Monster greifen an, oder Hineinlaufen tut nichts |
| 251.5 | Tom | 555 | Im Wald „Neben den Helden holen“: Wolf; „Merker“ öffnen, „Grimmzahn besiegt“ an, „Ort neu“ | der Wolf steht neben dir und tut 2 Minuten nichts; mit dem Merker ist Grimmzahn im Tiefen Wald fort, „Bosse“ bringt ihn wieder | Wolf greift gleich an, Merker wirkt nicht |
| 257.4 | Jerry | 535 | gegen Riesenratten oder -fledermäuse kämpfen, im Kampftext lesen | Ratte und Fledermaus sagen nur „Biss“ an, Fledermaus „flattert davon – daneben!“ manchmal; nach drei Ratten etwa 25 EP | „Anspringen“, „Einkreisen“, „Umwerfen“ wie beim Wolf, 80 EP |
| 252.6 | Jerry | 553 | nach dem Rattenkampf an den Wölfen auf der Karte vorbeigehen | Wölfe sehen aus und laufen wie Wölfe | ein graues, hochbeiniges Tier mit langem Hals |

## F · Stationen (Reiter „Test“)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 251.2 | Tom | 555 | Station „2 Morwen“, dann „5 Krogg“, dann „6 Grak“ (den Weg hinauf gehen) | jeweils Blende, der Held steht neben der Person, Morwen spricht wie beim ersten Besuch mit Rauchbündel; Krogg spricht und kämpft; vor Graks Halle spricht Grak | falscher Ort, Held im Felsen, Person fehlt, falsche Worte für den Stand |
| 252.7 | Jerry | 533 | Kampf mit Grimmzahn (Station oder Tiefer Wald) | kein Knopf „Flucht“; „Held Auto“ sagt „Nicht gegen Bosse.“; fällt Grimmzahn: „Ihr Leitwolf ist gefallen – die Wölfe verschwinden heulend im Wald!“, Sieg mit mehr als 450 EP | Flucht möglich, die Wölfe kämpfen weiter, Grimmzahn so schwach wie ein Wolf |
| 257.6 | Tom | 538 | mit Garrick sprechen, nachdem der Held Stufe 3 erreicht hat (Testmenü Stufe); in Kapitel 1 bis über Stufe 6 kämpfen | ab Stufe 3 warnt Garrick nicht mehr vor Krogg; in Kapitel 1 bleibt der Held bei Stufe 6, mehr EP verfallen | Garrick warnt immer; Held steigt über Stufe 6 |

## G · Neues Spiel

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 257.5 | Jerry | 534 | Held mit Charisma oder orkblütig anlegen und kämpfen; Ausrüstung mit Lebensraub, wenn vorhanden | zu Kampfbeginn manchmal: ein Gegner ist eingeschüchtert und verliert seinen ersten Zug; orkblütig: einmal je Kampf bleibt der Held mit 1 TP stehen, mit Text | nichts davon geschieht, Held fällt orkblütig sofort |
| 255.6 | Tom | 550 | mit diesem Helden im Wald zum ersten Mal Heilkräuter pflücken, dann ein zweites Mal | der kurze Hinweis oben ist beide Male gleich klein, eine Zeile | beim ersten Mal ein riesiger Kasten über den halben Schirm |

**Bekannt, nicht in diesem Build:** kein Regen (Godot hat noch keinen; Testmenü und Waldklang dann still); Schalter „Sichtlinie“ erst mit dem Nebel (505); keine Elite, kein Schimmernd, Stufe und EP je Gegner ruhen bis 478 (Durchspielregel, 512a ja); „Letztes Ende der App“ (Android) fehlt; Grimmzahns Fang (Amulett) fehlt, Einzelstücke gibt es noch nicht; Grimmzahn sieht aus wie bisher (neuer auf dem Kaufwolf erst nach deinem Wort, 533); Ratten fallen von selbst, Haken und Kreuz (548, 545) bei Jerry (548a beantwortet: nichts getippt, lief wie ein Film); „in die Knie“ ohne Sturz (547) bei Homer; Schamane heilt und flucht noch nicht (Ansagen bei Homer); vier Zauber und Unglaubliches Ausweichen ruhen bis 478, Untote vertreiben kommt mit 506 (Durchspielregel); Laden, Morwen, Rast warten auf [525](525-brauen.md); Kleidung am Drehteller kommt mit 455; Gegenstandsfenster besser als alt wartet auf [524.1](5241-fenster.md); Gesichter der Leute (475) und schwarze Blenden (556) sind noch nicht gebaut.
