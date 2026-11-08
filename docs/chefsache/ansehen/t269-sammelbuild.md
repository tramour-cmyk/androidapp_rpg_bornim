# Tom und Jerry · Build 269 · Godot 0.348.283 · Fehler aus 268, Dorf, Ausrüstung, Kampf · [PR #188](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/188)
Ganzes Spiel · Tom (Vorgänge 497, 519, 521–524, 524.1, 528, 581, 540, 555, 558, 583, 591, 605–611, 615, 617–619, 623.7, 624, 629.1, 416.8), Jerry (406.2, 438, 478, 517, 532, 547, 597, 600) · 08.11., 08:24 · [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42454656773/artifacts/13607963652) · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42454656773

Ein Weg, über Build 268 installieren: Hauptmenü (A), Dorf und Schenke (B), Menü des Helden (C), Flüsterwald mit Kampf (D), Reiter „Test“ (E). Was nicht passt, reicht als Zeilennummer mit einem Wort. Fragen stehen fett in der Zeile.

Verglichen: die geänderten Schirme (Tasche, Ausrüstung, Gegenstandsfenster, Blende, Klopfen) gegen die alte Fassung am Rechner (Tests je Zeile); kein neuer Bildabgleich.

## A · Hauptmenü

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 269.1 ✓ | Tom | 623.7, 497 | Hauptmenü, „Über das Spiel“, nach unten | unter „Lizenzen der Engine“ und über dem Logo „Mit Dank an“ mit den Händlern der gekauften Modelle | kein Dank; Dank unter dem Logo |
| 269.2 ✓ | Tom | 624 | Reiter „Test“: Bildrate und Standort einschalten, ins Spiel | Bildrate und Standort gut lesbar, mit der Schriftgröße des Handys; im Reiter „Test“ Messwerte und Geräteangaben größer | „Mikroschrift“ wie in 268 |

## B · Dorf und Schenke

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 269.3 ✗ → 663 | Tom | 540, 583 | (268.4 noch offen) neues Spiel mit klassischer Steuerung; Erwachen in der Schenke, Text lesen | Tipp zur Steuerung kommt auch bei klassischer Steuerung; ▼ unter der letzten Zeile im Rand, Erzähltes schräg, Gesprochenes gerade | kein Tipp; ▼ mitten im Wort; Erzähltes gerade |
| 269.4 ✓ | Tom | 606, 605, 617 | Schenke: an der Theke einen Met kaufen, Gold vorher und nachher ansehen | genau 2 Gold weniger, ein Met | 4 Gold weniger; zwei Fenster nacheinander |
| 269.5 ✓ | Tom | 609 | hinter der Schenke vorbei zum Schlagbaum gehen; dann hinter den anderen Häusern der Waldseite | überall frei | ein Baum oder Busch sperrt |
| 269.6 | Tom | 615 | im Dorf die Kamera drehen und zoomen | der Held bleibt in der Bildmitte, die Kamera dreht um ihn | der Held wandert zum Rand, bis zwei Bildbreiten daneben |
| 269.7 | Tom | 608 | tagsüber hinter Pims Hütte und hinter den Tempel gehen, bis das Haus durchsichtig wird | die Fenster leuchten nur abends und nachts | Licht geht am Tag an |
| 269.8 ✓ | Tom | 611, 629.1 | an verschlossene Türen klopfen: Bäcker, alter Kael, nachts Gwenna und Dorran, Pims Haus | Klopfen ist zu hören; über gesprochenen Zeilen der Name (Bäcker Edrik, Der alte Kael, Gwenna, Schmied Dorran, Pims Mutter), ohne Anführungszeichen; Erzähltes ohne Namen | stumm; kein Name; Name über erzähltem Text |
| 269.9 ✓ | Tom | 607 | Reiter „Test“, Uhrzeit auf etwa 3 Uhr, an Pims Tür klopfen und warten | Pim (auch Liska, Gwenna) ist im Haus oder geht hinein, sobald es Nacht ist | Pim läuft um 3 Uhr vor dem Haus herum |
| 269.10 ✗ | Tom | 591 | auf ein Huhn, dann ein Kaninchen zugehen | Huhn gackert und flattert hörbar beim Weglaufen, Kaninchen huscht hörbar. **Frage: meint „kein Flattern“ den Laut oder die Flügel, die sich nicht bewegen?** | stumm |
| 269.11 ✗ | Tom | 416.8 | vor Aldric oder einer Dorfperson stehen bleiben, etwa 10 s warten, dann um sie herumgehen | sie dreht sich mit kleinen Schritten zum Helden | dreht sich auf der Stelle wie eine Plastikfigur |
| 269.12 | Tom | 610, 522 | Held mit Stab und Schild auf dem Rücken im Dorf stehen lassen; Reiter „Test“, „Waffe“: Dolch, Krummsäbel, Handbeil, Kurzbogen; „Andere Hand“: Dolch | Finger am Stab ruhig; jede dieser Waffen ist am Helden zu sehen; der Dolch der anderen Hand hängt nicht als Schild auf dem Rücken | Finger zucken; Waffe unsichtbar |
| 269.13 | Tom | 558 | Magier mit Robe ansehen | Stoff lebendig wie in Probe 5: Falten, Schatten, Schmutz am Saum | glatte blaue Fläche |

## C · Menü des Helden

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 269.14 | Tom | 618 | Menü und Laden verlassen; „Punkte verteilen?“ ablehnen | überall „Zurück“ statt „Schließen“; bei Rückfragen „Abbrechen“ | „Schließen“, „Nein“, „Weiter ansehen“ |
| 269.15 | Tom | 523 | Menü „Tasche“ | je Vorrat Seltenheitsfarbe und Kurzangabe („heilt 2W4+2“); bei Ausrüstung Art und Platz und die ersten Boni (Robe des Ankers nicht nur „Oberkörper“); nach einem Leuchtfunken die Zeile „Leuchtfunke“ mit „Löschen“; Benutzen klingt wie alt | nur Namen; nur „Oberkörper“ |
| 269.16 | Tom | 605, 617, 521, 581 | Reiter „Ausrüstung“ (Seite passt in den Schirm, Reiter springen nicht): leeres Kopffeld antippen, ein Stück wählen, „Abbrechen“, dann „Zurück“; danach ein Stück einmal „Anlegen“ | Wechselschirm wie alt (Bild, Art, Wert, ▲/▼, nicht Tragbares matt); „Abbrechen“ führt in den Wechselschirm, „Zurück“ dort in die Ausrüstung; ein Druck reicht für Anlegen, Wegwerfen, Abbrechen, Zurück | man landet im Fenster des Stücks; jeder Knopf braucht zwei Drücke |
| 269.17 | Tom | 605 | ohne andere Stücke die göttliche Kapuze aufs leere Kopffeld | +1 je Attribut wirkt; „wirkt nicht (Obergrenze)“ steht nur, wenn andere angelegte Stücke die Obergrenze schon füllen | „Obergrenze“ bei allem |
| 269.18 | Tom | 519, 524, 524.1 | ein langes Stück öffnen („Göttlicher Ring des Eisernen Richters“), dann eine Waffe | Fenster passt auf den Schirm; Seltenheit, Tragort, Gewicht wie alt; bei der Waffe dazu Schaden je Griffart; ohne Kasten wie in 524.1 gewählt: Urteil als Zeile unter dem Namen (▲ Besser, ▼ Schlechter, ◆ Gemischt), wirksame Boni in Gold, „ANLEGEN ›“ als Hauptwahl | abgeschnitten; Grundwerte fehlen; Band mit Streifen statt Zeile |
| 269.19 | Tom | 528 | (268.12 neu gestellt) Reiter „Test“, „Held · Stufe“ auf 6; Menü „Held“; dann „Chronik“, einen Nebenauftrag | am EP-Balken „Höchststufe für Kapitel 1 erreicht …“; beim Nebenauftrag „Auf der Karte“ | kein Satz; kein Kartenverweis |

## D · Flüsterwald und Kampf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 269.20 | Tom | 619 | Ortswechsel und Kampfbeginn; die Blende mit einem ganzen Tipp beenden, einmal den Finger beim Kommen der Blende schon unten lassen | sie endet nur durch einen ganzen Tipp auf ihr. **Frage: wann sprang sie in 268 weg, beim Tipp auf den Aktionsknopf oder von selbst?** | sie springt weg, bevor sie gelesen ist |
| 269.21 | Jerry | 438, 406.2 | Kampf gegen Wölfe, Held mit Schild; auf Wölfe und Abwehr achten | Wölfe laufen mit Schritten, nicht ineinander, Kopf nicht im Helden; der Held wehrt zur Seite des Angreifers ab | Gleiten; Rennen mit Gehopse |
| 269.22 | Jerry | 597 | Wölfe, dann Probekampf Ratten, Fledermäuse | über jedem Wolf vor dem Sprung „! Anspringen“ (oder „Einkreisen“), das Ziel an der Farbe des Rahmens; Wolf, Ratte, Fledermaus nie mit Ring | Sprung ohne Ansage; Ring ohne Ansage |
| 269.23 | Jerry | 600 | Knopf links neben den Würfeln dreimal antippen | 1, 2, 3 Spitzen, jede Stufe gleich hell, Tempo wechselt, Menü „Tempo“ gleich | Stufe 2 dunkler |
| 269.24 | Jerry | 547 | (268.24 offen) warten, bis ein Wolf den Helden niederstößt | Homers Zwischentext | „geht in die Knie“, „steht wieder auf“ |
| 269.25 | Jerry | 532 | (268.14 offen) Met bis betrunken, dann Kampf im Wald, aufs Schild tippen | „Betrunken“ am Helden mit Erklärung; Werte wie in der Welt | kein Schild; Werte des Probekampfs |
| 269.26 | Jerry | 517 | Wald bei Tag, nachts, Tiefer Wald | Vögel am Tag, Grillen und Eule nachts, im Tiefen Wald fernes Heulen | Stille; Vögel nachts |

## E · Reiter „Test“

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 269.27 | Tom | 555 | (268.27 neu gestellt) „Kampf beschwören“ | wählbar sind nur Gruppen, für die alle Gegner ein Modell haben; fehlt eines, steht unter den Gruppen grau „Noch ohne Modell: …“ (in 268 hatten alle eins, darum war die Zeile nicht da) | Gruppe wählbar, die dann Wölfe statt Spinne zeigt |
| 269.28 | Jerry | 478 | nur wer mag: Kampfhilfen, „Rechnung“ auf BRS, dann Probekampf Ratte, Wölfe, Spinne | Wurfzeile „37 gegen 70 % · Treffer“; Ratte leicht, Spinne meist verloren | Absturz; W20-Zeile |

**Zur Frage aus 268.26 (543):** „Stufe 2“ heißt bei uns nur Gegenstandsstufe 2 (je Kampf 38 % ein Stück; in Kapitel 1 ab Heldenstufe 2 zu 15 % ungewöhnlich, sonst gewöhnlich) und andere Gegner. EP und Gold nach Gegnerart: Wolf 50 EP und 1W6 Gold, je Jungwolf 30 % mehr (65 EP). Die alte Fassung gab bei Gegnern über der Gebietsstufe mehr (EP bis etwa ×1,4, Gold ×1,3 je Stufe darüber); Godot noch nicht, das liegt bei Jerry.

**Bekannt:** Nicht drin sind 562 (zügiger Angriffsgang: damit liefen die Wölfe in der Messung ineinander) und 587 (alle Gegner 1,3-fach: die Spinne steckte im Wolf); Jerry baut beide nach. 565 (Kasten dessen, der am Zug ist) ist aus, Bilder kommen eigens. Der Held zeigt nur Waffen und Schild, keine Kopf- und Rüstungsteile (Trachten 463). Ohne Modell bleiben Streitkolben, Speer, Rapier, Äxte, Hämmer, Hellebarde, Langbogen, Armbrust, Turmschild, Fokusse (458.3). Das Zeichen am Pfeiler beim Zwerg (611) fehlt noch. Die Höhle (Ende von Kapitel 1) kommt mit dem nächsten Build.

## Ergebnis

Chef 08.11., 15:23 (an Sokrates), laufend:
- 269.1 ✓
- 269.2 ✓
- 269.3 ✗ klassische Steuerung ganz raus, nur Touch (Vorgang 663)
- 269.4 ✓
- 269.5 ✓
- 269.8 ✓
- 269.9 ✓ (dazu 665: nachts kaum dunkel, alle Fenster hell)
- 269.10 ✗ Kaninchen nicht hörbar; Huhn gackert kaum, Flattern kaum hörbar; Huhn soll wie alt wirklich wegflattern (Flügel schlagen, kurz auffliegen „tschack, tschack, tschack … weg“), nicht nur laufen (Chef 15:41)
- 269.11 ✗ Leute drehen sich auf der Stelle; beim Annähern richtet sich keiner zum Helden aus (Stil: bis 3 Felder anschauen), Hineinlaufen schiebt sie weg; so nicht testbar (Chef 15:43); Drehen weiter auf der Stelle wie eine Plastikfigur, keine Schritte zu erkennen (Chef 15:44, wiederholt)
