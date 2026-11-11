# Tom und Jerry · Build 277 · 0.348.355 · Sammelbuild nach Build 276 · PR #196
Ganzes Spiel · Tom (581, 635, 636, 680, 814, 875, 964), Jerry (532, 536, 751, 784, 806, 811, 863, 868, 870.6, 876, 910, 935, 945, 948, 958) · Entwurf 11.11., 16:43, APK 19:12 · [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43060687068/artifacts/13882345442) · Geprüft an: `claude/build-277` `65ea0e915` (Lauf 355)
Rot, bekannt, nicht melden: `held_kampf_403` (Schild des Klerikers im Kampf), `wolf_mess_438`, `begriffe_868` (liest eine beim Umzug gelöschte Datei) – Prüftests des Kampfs, Vorgang 988 (Jerry); Start- und Absturztests grün.
Gegengelesen: Sokrates 11.11., 16:58

Ein Weg: über Build 276 installieren, Hauptmenü, „Weiter“ mit deinem Spielstand aus Build 276; erst Dorf am Tag (A), dann Wald mit Kräutern und Kampf (B), zurück ins Dorf am Abend (C), dann Probekämpfe und Sprünge im Reiter „Test“ (D), zuletzt ein neues Spiel für Jorins Schlagbaum (E). Den Reiter „Test“ gibt es nur im Testmodus: im Hauptmenü siebenmal aufs Firmenzeichen tippen. Was nicht passt, reicht als Nummer (z. B. 277.5) mit einem Wort.

Verglichen (alt gegen neu): keine neuen Schirme; Ausrüstungsseite, Laden und Tasche im Kampf gegen Build 276.

Im Bau geprüft: `auto_945`, `leiste_751` (Knöpfe im Kampf), `tasche_532`, `platztausch_863`, `handlungen_870` (964: in mittlerer und schwerer Rüstung keine Zauber aus Hervorrufung, Illusion, Beschwörung), `waffe_948`, `atem_4531` (910), `kraeutersammeln_875` (Spielstände behalten Wert und Übung), `laden_582`, `menue_breite_581`, `sprung_680`; am Rechner (läuft nicht im Bau): `kampfzustand_532` 0 (958: Metrausch nur über „betrunken“); 811 (Kommentar) und 876 (Simulation) ohne Wirkung im Spiel; 784 misst den Kampftakt, der Film dazu kommt gesondert.

Bekannt (814, aus deinem Film, Ursache wird gesucht): das Huhn fliegt nicht auf, auch wenn der Held direkt daneben steht; der Staub in der Schenke leuchtet auch abends wie im Tageslicht.

## A · Dorf am Tag

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 277.1 | Tom | 581 | Tasche → Reiter „Ausrüstung“, dann die Reiter durchtippen; einen Platz antippen | die Seite passt in den Schirm, links und rechts gleicher Rand; die Reiterzeichen stehen in jedem Reiter an derselben Stelle | Seite breiter als der Schirm, Reiter springen beim Wechsel |
| 277.2 | Jerry | 870.6 | Thessas Kramladen: Ausrüstung ansehen | Stücke ohne „+1“; Namen mit Zusatz wie „… des Fuchses“; Waffen mit „Schaden n · Art“ als Zahl | „+1“ im Namen, Würfel wie „1W8+1“ |
| 277.3 | Jerry | 935 | bei Thessa eine Brandflasche kaufen (fehlt Gold: Reiter „Test“ → Gold) | die Brandflasche liegt in der Tasche | nicht kaufbar |
| 277.4 | Tom | 875 | Tasche → Reiter „Held“, Fertigkeiten | die Fertigkeit heißt „Kräutersammeln“, mit dem Wert, den sie in Build 276 als Kräuterkunde hatte | „Kräuterkunde“, Wert auf 0 gefallen |
| 277.5 | Tom | 814 | auf einem Erdweg im Dorf laufen (nicht auf Pflaster) | bei jedem Schritt ein kleines Staubwölkchen an den Füßen | kein Staub an den Füßen |

## B · Wald

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 277.6 | Tom | 875 | Heilkräuter pflücken | Meldung „Du pflückst Heilkräuter“; steigt der Wert, „Kräutersammeln ↑ n“ | „Kräuterkunde ↑ n“ |
| 277.7 | Jerry | 806 | Testmodus → Anzeigen „Bildrate“ an; zum Wolf gehen, Kampf, Bilder/s links ablesen; dann Welt „Kampfnebel“ aus, nächster Kampf, wieder ablesen | Kampfort mit dichtem Gras und Blumen in Flecken, dünner Bodennebel, hinter den Kämpfern zwei Lichtschächte mit Staub; Bilder/s mit Nebel kaum unter denen ohne | kahler Boden zwischen den Büscheln, Nebel bis über die Köpfe, Ruckeln nur mit Nebel (dann beide Zahlen nennen) |
| 277.8 | Jerry | 536 | im Wolfskampf auf die Ansagen der Wölfe achten („! Anspringen“) | die Ansage steht dicht über dem Kopf des Wolfs, nie auf einem Namen | Ansage seitlich mit langer Linie, verdeckt einen Namen |
| 277.9 | Jerry | 532 | im Wolfskampf, wenn Leben fehlt: Leben ablesen, „Tasche“ antippen, Heiltrank trinken | die Tasche ist eine rollbare Liste mit Bildern über die ganze Breite, „Zurück“ darunter; nach „Heiltrank“ die Wahl, wer trinkt, je Name mit Leben „n/max“, wer volles Leben hat, ist ausgegraut; das Leben steigt um 14 (Zahl nennen), höchstens bis voll | Liste abgeschnitten oder nicht rollbar, der Kasten springt, ein anderer Wert als 14 |
| 277.10 | Jerry | 935 | im nächsten eigenen Zug „Tasche“ → Brandflasche auf einen Wolf | der Wurf trifft, der Wolf brennt zwei Züge | Brandflasche fehlt in der Tasche, Wurf ohne Wirkung |
| 277.11 | Jerry | 751, 945 | im Wolfskampf „Held selbst“ antippen bis „Held Auto“ (Söldner, wenn dabei, auch auf Auto); ein paar Züge zusehen, dann beide wieder aus | im Zug der Gegner stehen die Knöpfe matt an ihrem Platz, darüber „<Name> ist dran“; die Auto-Schalter bleiben immer antippbar; nach dem Ausschalten hält der Kampf bei deinem nächsten Zug | Knöpfe weg oder „…“, Auto nicht mehr abschaltbar |

## C · Dorf am Abend

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 277.12 | Tom | 814 | abends (nach 18 Uhr) über den Dorfplatz gehen, Anzeige „Bildrate“ an | Rauch aus den Kaminen, Fackeln flackern, die Fahne weht, Gras weicht dem Helden aus; Fußstaub schwächer als am Tag; Bilder/s wie am Tag | Effekte fehlen oder grell, Ruckeln |

## D · Reiter „Test“

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 277.13 | Jerry | 948 | MARS-Probekampf: „Gegner“ bis „Wolfsrudel“, „Starten als:“ Herumtreiber | der Held hält einen Dolch, Klinge gut sichtbar, mit Parierstange | leere Hand, Klinge nur ein Strich |
| 277.14 | Jerry | 863 | MARS-Probekampf: „Gegner“ bis „Ratten“, „Starten als:“ Wachsoldat | eine Ratte aus der hinteren Reihe tauscht zum Angriff mit einer vorderen den Platz | sie tapst nach vorn und lange wieder zurück |
| 277.15 | Jerry | 868 | MARS-Probekampf als Zauberlehrling, einen Zauber wirken und lange auf „Können“ drücken | nur Ergebnis, Trefferchance und BRS-Wörter | „Rüstungsklasse“, „RK“, „W20“, „SG“, Würfel wie „2W6“ |
| 277.16 | Tom | 635 | Station „Tempel“ | Lyra steht neben dem Helden | Platz leer |
| 277.17 | Tom | 680 | Sprung „Wald“, dann Sprung „Dorf“ und zu Fuß in die Schenke, dort ein paar Met, dann wieder Testmenü und Sprung „Wald“; drei- bis viermal wiederholen | das Spiel bleibt flüssig, kein Absturz | zäher von Runde zu Runde, Absturz beim Öffnen des Testmenüs |

## E · Neues Spiel: Jorin

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 277.18 | Tom | 636 | Testmodus → Anzeigen „Klang“ an; neues Spiel auf einem freien Platz, Aldrics Auftrag holen, zu Jorin, nach „Dann wollen wir mal.“ weitertippen | der Schlagbaum hebt sich hörbar; oben in der Klangzeile `door_n … spielt` | kein Geräusch: dann die Klangzeile abschreiben (ein Foto genügt) |

## Ergebnis

- 277.1 ✓ (Chef 11.11., 20:15, an Sokrates: „277.1 passt“)
- 277.2 ✓ (Chef 11.11., 20:17)
- 277.3 ✓ (Chef 11.11., 20:17)
- 277.4 ✓ (Chef 11.11., 20:20; Wert 0, Held ohne Kräutersammeln)
- Außer der Reihe (Chef 11.11., 20:19, Bild Thessas Kramladen, Tag 2, 16:40): „Die Partikel gehen über den Raum hinaus“ → Vorgang 990 (Tom, aus 814)
