# Tom und Jerry · Build 268 · Godot 0.348.268 · Menüs wie alt, Dorf, Kampf, Kapitelende · [PR #186](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/186)
Ganzes Spiel · Tom (Vorgänge 603, 512b, 525, 528, 529, 532, 537, 539–543, 555–557, 571, 574, 581–583, 591, 592, 504.1, 524.1, 549, 477), Jerry (532, 533, 536, 544, 545, 547, 548, 561, 562, 588, 594, 596, 597, 600, 601; Übernahme Tom) · 06.11., 12:35 · [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42202853277/artifacts/13499146340) · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42202853277

Ein Weg (Chef 06.11., 09:36: „soviel rein wie geht“): über Build 266 installieren (Lauf 267 war rot, nie ausgeliefert); Hauptmenü und neuer Held (A), Dorf und Schenke (B), Flüsterwald mit Kampf (C), Reiter „Test“ (D), Kapitelende (E). Es ist viel; was nicht passt, reicht als Zeilennummer mit einem Wort.

Verglichen (512b): 76 Menüzustände alt gegen neu, Helfer 1 Aufnahme, Helfer 2 Vergleich 05.11., 08:17 (21 Funde → 580–585, behoben in 581–583, 580 war nur alt); seitdem geändert: Stil „ohne Kasten“ eingeschaltet (557). Kein neuer Bildabgleich vor dieser Bitte: Woche über 95 % (Ford 09:36: keine Bildläufe außer dem Build).

## A · Hauptmenü, Spielstände, neuer Held

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 268.1 | Tom | 557, 529 | Hauptmenü, „Laden“ | Spielstände ohne Kästen (wie im Entwurf 557 abgenommen); je Spielstand die Figur des Helden, „Gespielt“ mit Spielzeit, „Gespeichert“ mit der Uhrzeit des Speicherns; „× Löschen“ in Warnfarbe als Nebenwahl | Kästen wie in Build 266; keine Figur, keine Spielzeit; Uhrzeit um eine Stunde falsch |
| 268.2 | Tom | 571 | Neues Spiel, Erschaffung: Finger auf einen Knopf (Volk, Klasse, Punktekauf) legen und hoch und runter wischen; dann tippen; dann lange drücken | Wischen rollt die Liste und wählt nichts; Tippen wählt; langes Drücken erklärt | die Liste steht, wenn der Finger auf einem Knopf beginnt; Wischen wählt |
| 268.3 | Tom | 543 | Held fertig, Menü „Tasche“ | Startgold der Klasse (15–25 Gold) und ihre Heiltränke in der Tasche wie alt | 0 Gold oder immer gleich viel; keine Heiltränke |
| 268.4 | Tom | 540, 583 | Erwachen in der Schenke, mit klassischer Steuerung; Text lesen | Tipp zur Steuerung kommt auch bei klassischer Steuerung; im Textkasten steht ▼ unter der letzten Zeile im Rand, Erzähltes schräg, Gesprochenes gerade | kein Tipp; ▼ mitten im Wort („Sammel▼“); Erzähltes gerade |

## B · Dorf und Schenke

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 268.5 | Tom | 556 | jeder Ortswechsel und später jeder Kampfbeginn | Blende reines Schwarz ohne Leuchten und Ringe; jeder Satz bleibt lange genug zum Lesen (2–6 s), Tippen beendet früher | heller Fleck in der Mitte; Satz weg, bevor er gelesen ist |
| 268.6 | Tom | 591 | auf ein Huhn, dann ein Kaninchen zugehen | es rennt mit Gackern (Huhn) oder Huschen (Kaninchen) ein Stück weg, bleibt wachsam stehen und streift dann heim | es bleibt stehen oder läuft durch den Helden |
| 268.7 | Tom | 541 | vor Brunnen, Marktstand, Fass, Laterne, Bank stehen, Aktionsknopf | Knopf „Ansehen“ und ein Satz zum Ding; Marktstände sagen je Lage etwas anderes | kein Knopf; immer derselbe Satz |
| 268.8 | Tom | 504.1, 540 | an eine verschlossene Tür mehrmals klopfen; vor und nach Aldrics Auftrag gegen den Schlagbaum laufen | beim ersten Mal der bekannte Satz, danach wechselnde Wortlaute, nie zweimal derselbe hintereinander; am Schlagbaum nach dem Auftrag „Sprich mit Wache Jorin, damit er ihn öffnet.“ | immer derselbe Satz; nach dem Auftrag noch „Ohne Erlaubnis des Ältesten …“ |
| 268.9 | Tom | 582, 525, 557 | Laden Thessa: Vorräte, Ausrüstung, einen Heiltrank kaufen (Mengenfenster), mit voller Tasche „Verkaufen“ öffnen und die Liste hoch und runter wischen, etwas verkaufen und zurückkaufen | Vorräte mit Kurzangabe („heilt 2W4+2“) in ihrer Seltenheitsfarbe; bei Ausrüstung der Platz; ▲ grün, ▼ rot; Mengenfenster mit Seltenheit und Wirkung; die lange Liste rollt, „‹ SCHLIESSEN“ bleibt unten im Schirm; Rückkauf in Seltenheitsfarbe | langer Beschreibungstext; alles weiß; ▲/▼ ohne Farbe; Liste läuft unten aus dem Schirm |
| 268.10 | Tom | 525 | Morwen: Brauen öffnen | je Zutat „hat / braucht“, „Fehlt“ oder „Reicht für n“, nicht Brauares matt | Zutaten ohne Mengen |
| 268.11 | Tom | 581, 557, 524.1 | Menü, Reiter „Ausrüstung“, zwischen den Reitern wechseln, einen Gegenstand antippen | die Seite passt in den Schirm, die Reiter springen nicht; Gegenstandsfenster ohne Kasten: Name oben neben dem Bild, Urteil als Zeile, Boni in Gold, „ANLEGEN ›“ als Hauptwahl, „× WEGWERFEN“ in Warnfarbe; alle Knöpfe gleich groß | Seite rechts abgeschnitten; Reiter rutschen; Fenster mit Goldrahmen wie Build 266; Knöpfe abgeschnitten |
| 268.12 | Tom | 528 | Menü „Held“, „Karte“, „Chronik“ | am EP-Balken der Satz zur Höchststufe des Kapitels; Kartenzeichen in der oberen Leiste; bei Nebenaufträgen „Auf der Karte“ | kein Satz; kein Zeichen |
| 268.13 | Tom | 557, 549 | Schenke: Rast an der Theke, dann an Garricks Feuer | Rastfenster ohne Kasten, Titel auf derselben Höhe wie jeder Schirm, Zeichen (Wirtshausschild, Flamme) links daneben, „›“ an jeder Wahl, „‹ WEITERGEHEN“ links | kleines Fenster mit vielen Kästen wie Build 266 |
| 268.14 | Jerry, Tom | 532, 536 | in der Schenke Met trinken, bis der Held betrunken ist; dann in den Wald und kämpfen; im Kampf auf das Schild „Betrunken“ tippen | Schild „Betrunken“ am Helden, Angriffe und Flucht mit Nachteil; Tipp erklärt Name und Wirkung | kein Schild; der Rausch zählt im Kampf nicht |
| 268.15 | Tom | 592 | im Dorf rennen, bis die Ausdauer leer ist | der Held hält 1 s an, Hände auf den Knien, keucht, dann wieder steuerbar | er beugt sich bei jedem Halt vor; er bleibt hängen |
| 268.16 | Tom | 539, 555 | Reiter „Test“: „Uhrzeit“ antippen (je drei Stunden vor), bis es nach Mitternacht ist; ins Spiel; dann so stellen, dass es 18–19 Uhr ist, und im Spiel warten; nachts speichern und laden; zuletzt „Tag / Nacht“ | nach Mitternacht Nacht; ab 19 Uhr wird es langsam dunkel; nachts geladen ist es Nacht; „Tag / Nacht“ springt auf Mittag oder 23 Uhr und das Licht folgt; das Testmenü bleibt nach jedem Antippen offen und meldet kurz die Wirkung | taghell um 1 Uhr (wie Build 257); Licht springt in der Dämmerung; nachts geladen ist Tag |

## C · Flüsterwald und Kampf (eigener Held)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 268.17 | Tom | 542 | Jorins Auftrag annehmen (Brett), im Flüsterwald zum Steinkreis | am Stein Knopf „Ansehen“, Jorins Fetzen wird gefunden | kein Knopf, nichts zu finden |
| 268.18 | Tom | 541 | im Wald vor ein Monster stellen, Aktionsknopf; einmal von hinten | Knopf „Kampf“; von hinten greift der Held zuerst an | Kampf nur durch Hineinlaufen |
| 268.19 | Jerry | 561, 562 | Kampf gegen Wölfe; Held mit Schild greift an | Zug- und Zielring liegen als Band am Boden, die Figur verdeckt sie; der Held geht zügig hin und gleichmäßig im Schritt zurück | Ring über allem gemalt; Schlaftablettengang hin, Gleiten zurück |
| 268.20 | Jerry | 536, 544 | Ziel wählen; Angriffsknopf lange drücken; Handy-Schriftgröße vorher größer stellen | Name über jedem Ziel bei der Wahl, nach langem Drücken über allen; Erklärfenster auch beim ersten Mal normal groß; Schrift im Kampf folgt der Schriftgröße des Handys | keine Namen; riesiger Textkasten beim ersten Mal; Kampfschrift bleibt klein |
| 268.21 | Jerry | 597 | auf Ansagen der Gegner achten (Wolf, Ratte, Fledermaus, Goblin) | ein Ring kommt nur mit einer Ansage; Wolf, Ratte, Fledermaus zeigen nie einen Ring (wie alt) | Ring ohne Ansage |
| 268.22 | Jerry | 600 | Knopf links neben den Würfeln antippen | 1–3 Spitzen, der Kampf läuft schneller, die Wahl gilt auch im Menü „Tempo“ | kein Knopf; Tempo ändert sich nicht |
| 268.23 | Jerry | 545, 548 | Wolfsrudel; Testknopf ✓ oder ✗ drücken, während die Gegner dran sind | wirkt sofort; die Knöpfe sehen aus wie Würfel und Raster | wirkt erst, wenn der Held am Zug ist |
| 268.24 | Jerry | 547 | warten, bis der Held niedergestoßen wird | Homers Zwischentext statt „geht zu Boden“ / „steht wieder auf“ | der alte Text |
| 268.25 | Jerry | 596 | mehrere Gegner besiegen | sie sterben mal zur einen, mal zur anderen Seite, weicher | immer gleich zur selben Seite |
| 268.26 | Tom | 543 | einen Kampf im Tiefen Wald gewinnen; einen verlieren | Beute nach Stufe 2; nach der Niederlage Wiederkehr im Tempel | Beute wie Flüsterwald; Wiederkehr anderswo |

## D · Reiter „Test“

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 268.27 | Tom | 555, 571 | „Kampf beschwören“: Liste wischen, auch auf einer Zeile beginnend | nur Gruppen mit eigenem Modell wählbar, die anderen unter „Noch ohne Modell“; Wischen rollt | Spinne oder Fledermäuse zeigen Wölfe; Liste steht |
| 268.28 | Jerry | 594 | Probekampf „Riesenspinne und Wolf“ | die Blende nennt die Spinne | Wolfstext in der Blende |
| 268.29 | Jerry | 533 | Probekampf gegen Grimmzahn | Blende mit seinen eigenen Sätzen, seine Stimme; er kämpft wie ein Wolf mit Rudel | „gelbe Augen“ wie ein gewöhnlicher Wolf |
| 268.30 | Jerry | 601 | Probekampf „Goblin-Späher“, ausweichen oder ducken lassen | auch beim Fehlschuss fliegt ein Pfeil | kein Pfeil beim Fehlschuss |

## E · Kapitelende und Protokoll

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 268.31 | Tom | 537 | Reiter „Test“, „Stationen“ bis vor Aldric mit dem Amulett; ihm das Amulett geben | Schirm „Ende von Kapitel 1“ ohne Kasten, dann Tempelszene, Nacht, Morgen im Tempel mit Lyras Sätzen; in der Chronik die Morgenandacht | nach Aldric geht es einfach weiter |
| 268.32 | Tom, Jerry | 574, 588 | am Schluss Reiter „Test“, „Absturzbericht zeigen …“, „Seit Start, Fehler“ | kein „Lambda capture at index 0 was freed“, kein „buffer_size == 0“ | eine der Zeilen steht da |
| 268.33 | Tom | 477 | nur wenn zur Hand: APK im MuMu Player | Hauptmenü mit Bild | schwarzer Schirm |

**Bekannt:** Kleinigkeiten der Menüs (halbfette Köpfe 584, Titelumbruch und Knopf „Lizenzen der Engine“ 585) warten auf Perikles; die Schussbewegung des Spähers fehlt noch (601 ruht bis Sa); Goblins fallen noch steif (596); den Sturz selbst gibt es erst mit 438a; der Kampf in der Höhle steht noch auf der Waldlichtung (507); die Trachten (463) und Kampftränke (481.1) stecken nur in Werkzeugen, im Spiel nichts zu sehen.
