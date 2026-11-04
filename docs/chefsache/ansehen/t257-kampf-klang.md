# Tom und Jerry · Build 257 · Godot 0.348.257 · eine Prüfliste für die Builds 251, 252, 255, 257 · [PR #184](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/184)
E Technik · Tom und Jerry · 04.11., 03:33; zusammengelegt von Sokrates 04.11., 07:5x (Chef 07:57: „bitte die Builds und Fragen konsolidieren“) · [Lauf 257, bornim-godot-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41761514918/artifacts/13292971716) (grün 04:18) · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41761514918 (Tests der Einzelbuilds 251, 252, 255, 257 je grün, Listen in Git)

**Was installieren:** nur **Build 257** (t250 erledigt, 415 gemessen 04.11., 10:51). Er enthält alles aus 251, 252 und 255; alle ihre Punkte stehen unten.

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
| 251.10 ✓ Art, ✗ Größe (Chef 16:58: „relativ klein“) | Jerry | 544 | Probekampf: Schrift im Kampfschirm | Alegreya mit Serifen wie im Menü | Ersatzschrift ohne Serifen |
| 252.1 ✓ (Chef 16:56) | Jerry | 552 | Probekampf, oben am Bildschirm | die Zugreihenfolge steht unter der Kamera, ganz lesbar | oben nur ein leerer schwarzer Streifen |
| 252.2 ✗ (Chef 16:58, auch im Bildschirmfoto [551](../bilder/551-kampf-257.webp)) | Jerry | 551 | Probekampf, der Goldrahmen um den Kasten unten, besonders unten links und rechts; bitte ein **Bildschirmfoto** | der Rahmen läuft rundum durch | an den unteren Ecken unterbrochen (zeigt das Bildschirmfoto die Lücke auch, ist es eine andere Ursache) |
| 252.3 ✗ (Chef 16:56, erstes Fenster riesig; Zu 536) | Jerry | 536 | Probekampf, eine halbe Sekunde auf „Angriff“ drücken, dann loslassen; ebenso auf „Abwehr“, „Held“ | unten erscheint eine Erklärung, was der Knopf tut; losgelassen passiert nichts | keine Erklärung, oder der Held greift an |
| 252.4 ✗ (Chef 16:56, Gegnernamen fehlen; Zugkreis 561) | Jerry | 536 | lang auf das Zeichen über einem Wolf drücken (die Ansage), dann lang auf einen Wolf selbst | Ansage: was sie heißt und was hilft; Wolf: Name, Absicht und auf wen | nichts erscheint |
| 252.5 ✓ (Chef 17:06) | Jerry | 546 | Probekampf, zusehen, wenn ein Wolf einem Schlag ausweicht | er springt flink im Lauf zur Seite und kehrt dann zurück | er schleicht im Schritt weg („Schlaftabletten“) |
| 251.8 ✓ (Chef 17:11) | Jerry | 527 | System „Tempo“ schnell, dann noch ein Probekampf | der Kampf läuft schneller; „Kampftext“ ist ausgeblendet | Tempo ohne Wirkung |
| 251.9 – im Probekampf nicht prüfbar (Chef 17:12: Stufe frei wählbar, Werte simuliert); mit eigenem Helden in E | Jerry | 532 | **Im Flüsterwald (E) mit dem eigenen Helden**, wenn er zaubern kann (Zauberwirker, Kleriker, Paladin): einen Zauber wirken, Kampf beenden, gleich noch einen Kampf; danach rasten | Zauberpunkte und Verbrauchtes kommen aus dem ersten Kampf mit, Zustände bleiben; nach der Rast voll | jeder Kampf beginnt voll |

## D · Dorf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 251.7 ✓ (Chef 19:59) | Tom | 530 | Station „1 Garrick“ oder bei Aldric den Auftrag holen, zum Schlagbaum im Norden; dann speichern, Spielstand laden | der Schlagbaum steht offen, auch nach dem Laden | Balken bleibt zu |
| 257.2 – nicht prüfbar (Chef 17:20: Zeit im Testmenü auf Nacht, bleibt taghell; Zu 555) | Tom | 514 | nachts (Testmenü ☾) im Dorf und im Flüsterwald an Blumen, Wiesen, Wasser- und Waldrand stehen; mehrere Nächte | in manchen Nächten Schwärme von Glühwürmchen, treiben langsam, blinken einzeln, ein Nachbar antwortet; im tiefen Wald wenige | keine, oder gleichmäßig leuchtende Punkte, die nicht blinken |

## E · Flüsterwald

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 257.3 – Tag: Tiere zu hören; Nacht nicht prüfbar, es wird nie Nacht (Chef 17:22; Zu 555) | Jerry | 517 | Flüsterwald am Tag eine halbe Minute stehen; nachts dasselbe; dann Tiefer Flüsterwald zwei bis drei Minuten (nachts) | am Tag Vögel, nachts Grillen, im Flüsterwald manchmal eine Eule; im Tiefen Wald keine Vögel, fern von einer Seite ein Wolf heulen | nur Wind und Feuer, oder Vögel im Tiefen Wald |
| 251.3 ✓ (Chef 20:02) | Tom | 554 | Teleport „Wald“, „Monster“ antippen (beachten nicht), an Wölfen und Ratten vorbeigehen, dann in eine hineinlaufen | Monster laufen wie sonst, jagen nicht, kein Überfall im Gras; Hineinlaufen beginnt den Kampf; noch einmal antippen: sie jagen wieder | Monster greifen an, oder Hineinlaufen tut nichts |
| 251.5 ✓ Wolf, ✗ „Ort neu“ (Chef 20:08, 20:11: Grimmzahn erst nach Teleport fort; Zu 555) | Tom | 555 | Im Wald „Neben den Helden holen“: Wolf; „Merker“ öffnen, „Grimmzahn besiegt“ an, „Ort neu“ | der Wolf steht neben dir und tut 2 Minuten nichts; mit dem Merker ist Grimmzahn im Tiefen Wald fort, „Bosse“ bringt ihn wieder | Wolf greift gleich an, Merker wirkt nicht |
| 257.4 ✓ Text (Chef 20:14 Fledermaus, 20:15 Ratten: „Der Text ist in Ordnung“; Fledermaus als Kapsel, Modell in 510); EP nicht genannt | Jerry | 535 | gegen Riesenratten oder -fledermäuse kämpfen, im Kampftext lesen | Ratte und Fledermaus sagen nur „Biss“ an, Fledermaus „flattert davon – daneben!“ manchmal; nach drei Ratten etwa 25 EP | „Anspringen“, „Einkreisen“, „Umwerfen“ wie beim Wolf, 80 EP |
| 252.6 ✓ (Chef 20:17) | Jerry | 553 | nach dem Rattenkampf an den Wölfen auf der Karte vorbeigehen | Wölfe sehen aus und laufen wie Wölfe | ein graues, hochbeiniges Tier mit langem Hals |

## F · Stationen (Reiter „Test“)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 251.2 – 5 Krogg, 6 Grak nicht prüfbar (Chef 20:29: Stationen nur 1–4 und 8; die Höhlenkarte ist nicht im Build, `testmodus.gd` `da()` blendet 5–7 aus; Zu 555); ✓ Morwen (Chef 20:33) | Tom | 555 | Station „2 Morwen“, dann „5 Krogg“, dann „6 Grak“ (den Weg hinauf gehen) | jeweils Blende, der Held steht neben der Person, Morwen spricht wie beim ersten Besuch mit Rauchbündel; Krogg spricht und kämpft; vor Graks Halle spricht Grak | falscher Ort, Held im Felsen, Person fehlt, falsche Worte für den Stand |
| 252.7 ✓ Regeln (Chef 20:33: „bis auf das, was ich dir jetzt erzählt habe, hat auch alles gepasst“); ✗ Blende mit Wolfsätzen, erster Hinweis riesig (536), Tod zu flott (alt, Zu 533) | Jerry | 533 | Kampf mit Grimmzahn (Station oder Tiefer Wald) | kein Knopf „Flucht“; „Held Auto“ sagt „Nicht gegen Bosse.“; fällt Grimmzahn: „Ihr Leitwolf ist gefallen – die Wölfe verschwinden heulend im Wald!“, Sieg mit mehr als 450 EP | Flucht möglich, die Wölfe kämpfen weiter, Grimmzahn so schwach wie ein Wolf |
| 257.6 ✓ (Chef 20:34) | Tom | 538 | mit Garrick sprechen, nachdem der Held Stufe 3 erreicht hat (Testmenü Stufe); in Kapitel 1 bis über Stufe 6 kämpfen | ab Stufe 3 warnt Garrick nicht mehr vor Krogg; in Kapitel 1 bleibt der Held bei Stufe 6, mehr EP verfallen | Garrick warnt immer; Held steigt über Stufe 6 |

## G · Neues Spiel

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 257.5 ✗ Unerbittlichkeit (Chef 20:44: Halbork fällt ohne „bleibt mit eisernem Willen stehen“; Zu 534); Einschüchtern offen | Jerry | 534 | Held mit Charisma oder orkblütig anlegen und kämpfen; Ausrüstung mit Lebensraub, wenn vorhanden | zu Kampfbeginn manchmal: ein Gegner ist eingeschüchtert und verliert seinen ersten Zug; orkblütig: einmal je Kampf bleibt der Held mit 1 TP stehen, mit Text | nichts davon geschieht, Held fällt orkblütig sofort |
| 255.6 | Tom | 550 | mit diesem Helden im Wald zum ersten Mal Heilkräuter pflücken, dann ein zweites Mal | der kurze Hinweis oben ist beide Male gleich klein, eine Zeile | beim ersten Mal ein riesiger Kasten über den halben Schirm |

**Bekannt, nicht in diesem Build:** kein Regen (Godot hat noch keinen; Testmenü und Waldklang dann still); Schalter „Sichtlinie“ erst mit dem Nebel (505); keine Elite, kein Schimmernd, Stufe und EP je Gegner ruhen bis 478 (Durchspielregel, 512a ja); „Letztes Ende der App“ (Android) fehlt; Grimmzahns Fang (Amulett) fehlt, Einzelstücke gibt es noch nicht; Grimmzahn sieht aus wie bisher (neuer auf dem Kaufwolf erst nach deinem Wort, 533); Ratten fallen von selbst, Haken und Kreuz (548, 545) bei Jerry (548a beantwortet: nichts getippt, lief wie ein Film); „in die Knie“ ohne Sturz (547) bei Homer; Schamane heilt und flucht noch nicht (Ansagen bei Homer); vier Zauber und Unglaubliches Ausweichen ruhen bis 478, Untote vertreiben kommt mit 506 (Durchspielregel); Laden, Morwen, Rast (525) kommen im nächsten Build, ihre Form mit [557](557-spielstaende.md); Kleidung am Drehteller kommt mit 455; Gegenstandsfenster besser als alt kommt als Bild mit der nächsten Vorlage [557](557-spielstaende.md) (524.1 nach B); Gesichter der Leute (475) und schwarze Blenden (556) sind noch nicht gebaut.
