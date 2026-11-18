# Tom und Spike · Build 299 · 0.1.563 (Godot 0.348.563) · Schlussbuild: Schild und Streifen der Wache, Kleidung in der Ruhe, Umhang, Funkenlicht in der Höhle · [PR 220](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/220)
E Figuren · Tom (Handy 1417, 1515, 1535, 1569; ohne dich 1571, 1606), Spike (Handy 1211) · 18.11., 14:20 · [APK (Lauf 563, Tests grün)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/44301568081/artifacts/14429688295)

Sammelbuild aus `main` (nach 1593) mit Build 298 (`claude/build-298`, noch nicht getestet: seine Liste `t298-sammelbuild.md` lässt sich in diesem Build prüfen) und den bis 13:00 gebilligten Zweigen `claude/tom-1515-streifen` (1515, 👍 17.11., 23:54), `claude/tom-1569-umhang` (1569, 1569.1, Vorentscheid gebilligt 18.11., 09:46), `claude/tom-1571-fackel` (1571), `claude/tom-1205-wiese` (1606), `claude/spike-1211-1484` (1211 B, gebilligt 09:46). 1417, 1535, 1549 sind schon auf `main`; 1549 ohne Prüfpunkt (im Spiel sitzt der Held nie, der Fix betrifft nur das Bildwerkzeug der Prüfbilder 431h). Nicht dabei (nicht gebilligt bis 13:00, nächster Sammelbuild): 1406, 1630, 1645.

Bekannt, schon gemeldet, noch drin: Beutel und Detailansicht zeigen keine Trankwirkung (1663, Tom); Goblins gleiten im Kampf ohne Gehbewegung (1664, Jerry).

Verglichen (alt gegen neu): Wachsoldatin im Hauptmenü (Bild 1515 alt gegen neu, 👍), Umhang (Bild 3, `ansehen/1569-umhang.md`), Funkenlicht Höhle (Film A/B/C, `ansehen/1211-licht-abc.md`); alt `WorldScreen.kt` 1443–1458 (Leuchtkugel: Licht in der Höhle immer).

Ein Weg: über Build 298 installieren (sonst 297), „Weiter“ und Lage am Schlagbaum (299.3), Neues Spiel als Wachsoldat (299.4), dann Lage Höhle (299.5).

Im Bau geprüft: Schildarm und Kleid ohne Fläche über Unterarm–Rumpf bei allen Figuren mit Kaufkleid (1417, 1515, 1535, `achsel_1515`); Fackel in der Nebenhand links (1571, Messung im Test); Kartenrand je Gebietskarte, auch mit dem Gras-Kit (1606, `rand_1022`); Funkenlicht 8 m, Abfall 1,0, in der Höhle auch am Tag (1211, `funke_677`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 299.1 | Tom | 1417 | Bild | Hauptmenü vom Stand `claude/build-299` (c2f5499da) in Handygröße, alle Stufen; rechts die Wachsoldatin vergrößert, alt Build 297 gegen neu Build 299 ([Bild](../bilder/t299-1-hauptmenue.webp)) [Bild von 18.11., 15:56](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/18-1555-t299.1-Tom.png) | Schild ganz, nichts abgeschnitten, er steckt nicht im Körper | Schild links wie abgeschnitten oder im Arm versunken |
| 299.2 | Tom | 1515 | Bild | dasselbe Bild wie 299.1, die Fläche vor dem Schild der Wachsoldatin ([Bild](../bilder/t299-1-hauptmenue.webp)) [Bild von 18.11., 15:56](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/18-1556-t299.2-Tom.png) | vor dem Schild hängt nichts, kein weißer oder heller Streifen zwischen Gürtel und Hand | ein weißer oder heller Streifen vom Gürtel zur Schildhand |
| 299.3 | Tom | 1535 | Handy | Zeile 299.3 → „Lage herstellen“ (Dorf am Schlagbaum, Mittag); Jorin geht vor dir hin und her: wenn er an einem Ende seines Wegs stehen bleibt, einige Sekunden zusehen; ebenso bei zwei weiteren Bewohnern, sobald sie stehen und sich in der Ruhebewegung regen | Kleidung bleibt am Körper, auch an den Armen | Stoff hängt an einer Hand oder spannt sich vom Arm zum Rumpf |
| 299.4 | Tom | 1569 | Handy | nach 299.3: Hauptmenü → Neues Spiel, Herkunft Wachsoldat (trägt den Umhang von Beginn an); im Dorf ein paar Schritte gehen, dann Menü → Ausrüstung: Umhang ablegen, zurück in die Welt, wieder anlegen | der Umhang ist in der Ausrüstung und in der Welt am Helden zu sehen, nach Ablegen weg, nach Anlegen wieder da; die Kleidung darunter sticht hinten nicht durch | kein Umhang an der Figur in der Welt, oder Kleidung ragt hinten durch den Umhang |
| 299.5 | Spike | 1211 | Handy | Zeile 299.5 → „Lage herstellen“ (Höhle am Mittag, Vorräte); Menü → Tasche → Leuchtfunke trinken, dann im Gang an den Wänden entlanggehen | der Funke schwebt kühl weiß über dem Kopf und leuchtet die Wände ringsum weich aus, auch am Tag, schwächer als eine Fackel | in der Höhle am Tag kein Licht vom Funken, oder nur ein heller Fleck direkt am Helden |

## Lagen

- 299.3: ort=village:17:5:UP uhr=12:00
- 299.5: station=Krogg uhr=12:00 vorraete

Gegengelesen: Tom 18.11., 13:10. 299.1 stimmt. 299.2 stimmt. 299.3 stimmt (Jorin geht auf y 3 zwischen x 15 und 20, zwei Felder vor dem Helden; Pim 9 Felder südlich). 299.4 Einwand: „vorraete“ gibt nur Verbrauchsgüter und Fackeln (`testmodus.gd` 301), keinen Umhang; kein Lage-Schlüssel gibt einen (`ruestung` nur Brustrüstungen, `brustruestungen()`); ohne Umhang in der Tasche ist 299.4 nicht prüfbar, Lage-Schlüssel für den Umhang nötig (Spike). 1549 berichtigt (Bildwerkzeug, nicht `kleid_stufe2_431`).
Einwand 299.4 erledigt (Spike 18.11., 13:16): Weg über Neues Spiel mit Herkunft Wachsoldat (`werte.json` start: cloak), ohne Lage.
Gegengelesen: Sokrates 18.11., 14:22. 299.1 stimmt. 299.2 stimmt. 299.3 Frage: Jorin geht laut Tom hin und her; „während sie stehen“ dann an seinen Halten prüfen oder einen stehenden Bewohner nennen. 299.4 stimmt (`tools/sim444/werte.json` start Wachsoldat mit cloak). 299.5 stimmt (Lage „vorraete“ gibt jeden Vorrat außer Schlüsseln, also auch den Leuchtfunken, `testmodus.gd` 300). Einwand Kopf: als „bekannt“ aufnehmen, was der Chef heute in Build 298 fand und hier noch drin ist: Goblins gleiten im Kampf (1664, 14:20), Beutel und Detailansicht ohne Wirkung der Tränke (1663, 14:17).

## Ergebnis

- 299.1 ✓
- 299.2 ✓
- 299.3 ✗ Kleidung zieht in der Ruhebewegung mit gehobenem Arm (Garrick 15:33, Bewohner im Kittel 15:59; Zu 1535)
- 299.4 ✓
- offen: 299.5
