# Tom und Jerry · Build 270 · Godot 0.348.304 · Kampf, Ausrüstung, Erschaffung, Dorf · [PR #189](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/189)
Ganzes Spiel · Jerry (562, 560, 587, 536, 662, 593, 296.3), Tom (605, 499, 635, 604, 636, 677) · 08.11., 18:35 · [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42498993200/artifacts/13626749176) · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42498993200

Ein Weg, über Build 269 installieren: Erschaffung (A), Dorf und Schenke (B), Menü des Helden (C), Flüsterwald (D), Probekämpfe im Reiter „Test“ (E). Was nicht passt, reicht als Zeilennummer mit einem Wort.

Verglichen: keine Schirme neu (nur Gegenstandsfenster 605, am Rechner mit `kopffeld_605`); Kampf am Rechner mit Kaufmodellen gemessen (`groesse_587`, `effekt_mess_6235` je 0 Befunde); im Bau `wolf_mess_438`, `wenden_560`, `ausweichen_593`, `lyra_635`, `schlagbaum_636`, `funke_677` je 0.

## A · Erschaffung

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 270.1 | Tom | 499 | neues Spiel, Kämpfer wählen, Held im Drehteller einmal ganz drehen | Schild auf dem Rücken, Oberkante am Nacken wie früher, liegt an; Schwert an der Seite | Schild steht unten ab oder schwebt; Schwert in der Luft |

Bekannt: Drehung um die Mittelachse statt ums Standbein (Chef 17:03) ist noch nicht drin; „halbtransparent“ (Chef 15:23) ist in diesem Build nicht behoben (697). Messung im Bau: beim Kleriker steht der Schild unten 7–15 cm vom Rücken ab (`drehteller_499`, Tom).

## B · Dorf und Schenke

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 270.2 | Tom | 604 | Erwachen in der Schenke, Erdgeschoss ansehen | kein Bett unten, dafür mehr Tische und Bänke | Bett im Gastraum |
| 270.3 | Tom | 635 | in den Tempel gehen | Lyra steht als Figur dort (in der Höhle nur am Rechner geprüft) | Platz leer |
| 270.4 | Tom | 636 | mit Jorin am Schlagbaum sprechen, bis er ihn öffnet | Türgeräusch beim Öffnen; der Balken springt auf offen wie früher | stumm |

## C · Menü des Helden

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 270.5 | Tom | 605 | Reiter „Ausrüstung“: leeres Kopffeld antippen, die göttliche Kapuze (aus dem Testmenü) wählen | Fenster passt in den Schirm, der Inhalt rollt, unten „Abbrechen“ und „Anlegen“; ein Tipp auf „Anlegen“ legt sie an | nur „Wegwerfen“ zu sehen; Fenster unten abgeschnitten |
| 270.6 | Tom | 677 | im Dunkeln (nachts oder in der Höhle) Leuchtfunke aus der Tasche benutzen | kühl weißer Funke treibt und wippt über dem Kopf, leuchtet schwächer als die Fackel | nichts zu sehen, nur „Der Funke verglimmt“ |

Bekannt: das Aussehen des Gegenstandsfensters (Zeilen „wirkt nicht (Obergrenze)“, alte Wörter, kein Zurück aus der Auswahl) ist 521, 581, 683, nicht drin.

## D · Flüsterwald

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 270.7 | Jerry | 560 | langsam auf einen Wolf zugehen, bis er „!“ zeigt; Grimmzahn ab 4 Kacheln | dreht sich mit Schritten zum Helden | dreht auf der Stelle |

## E · Probekämpfe (Reiter „Test“)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 270.8 | Jerry | 562 | Wölfe, Held mit Schild greift an | hin zügig wie das Gehen auf der Karte, Schritte mit; zurück gleichmäßig im Schritt | Schlaftablettengang; Gleiten |
| 270.9 | Jerry | 662 | Wölfe, Held mit Schild wird gebissen und pariert | dreht sich zum Wolf und hebt den Schild, greift danach normal an | bleibt verdreht stehen |
| 270.10 | Jerry | 536 | Wölfe, lange auf einen Gegner drücken | Name und Ansage dicht über dem Kopf | Ansage der Jungwölfe weit weg |
| 270.11 | Jerry | 296.3 | Wölfe als Magier, einen Wolf mit Feuerpfeil töten | er jault beim Sturz einmal auf wie beim tödlichen Hieb | stirbt stumm |
| 270.12 | Jerry | 593 | Ratten, dann Spinne allein, Grak: mehrmals angreifen, bis sie ausweichen | etwa jedes dritte Ausweichen geht rasch nach hinten, keiner läuft in einen anderen | nur links und rechts; rückwärts im Schneckentempo |
| 270.13 | Jerry | 587 | Spinne, Keiler, Ratten, Krogg, Grimmzahn | alle 1,3-fach groß wie die Wölfe, Krogg und Grak 1,5-fach; keiner steckt im anderen | kleiner als die Wölfe; ineinander |

Bekannt: kurze Schildschritte beim Angriff, der Held trippelt (562); Wege eckig statt im Bogen (682, nicht drin).

## Ergebnis

- 270.1 ✓ (Chef 20:20)
- 270.2 ✓ (Chef 20:20)
