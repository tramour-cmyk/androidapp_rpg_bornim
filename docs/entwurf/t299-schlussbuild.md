# Tom und Spike · Build 299 · Schlussbuild: Schild und Streifen der Wache, Kleidung in der Ruhe, Umhang, Funkenlicht in der Höhle · PR folgt
E Figuren · Tom (Handy 1417, 1515, 1535, 1569; ohne dich 1549, 1571, 1606), Spike (Handy 1211) · 18.11., 13:10 · APK folgt

Sammelbuild aus `main` (nach 1593) mit Build 298 (`claude/build-298`, noch nicht getestet: seine Liste `t298-sammelbuild.md` lässt sich in diesem Build prüfen) und den bis 13:00 gebilligten Zweigen `claude/tom-1515-streifen` (1515, 👍 17.11., 23:54), `claude/tom-1569-umhang` (1569, 1569.1, Vorentscheid gebilligt 18.11., 09:46), `claude/tom-1571-fackel` (1571), `claude/tom-1205-wiese` (1606), `claude/spike-1211-1484` (1211 B, gebilligt 09:46). 1417, 1535, 1549 sind schon auf `main`. Nicht dabei (nicht gebilligt bis 13:00, nächster Sammelbuild): 1406, 1630, 1645.

Verglichen (alt gegen neu): Wachsoldatin im Hauptmenü (Bild 1515 alt gegen neu, 👍), Umhang (Bild 3, `ansehen/1569-umhang.md`), Funkenlicht Höhle (Film A/B/C, `ansehen/1211-licht-abc.md`); alt `WorldScreen.kt` 1443–1458 (Leuchtkugel: Licht in der Höhle immer).

Ein Weg: über Build 298 installieren (sonst 297), Hauptmenü ansehen (299.1, 299.2), „Weiter“ ins Dorf (299.3), Menü → Ausrüstung (299.4), dann Höhle (299.5).

Im Bau geprüft: Schildarm und Kleid ohne Fläche über Unterarm–Rumpf bei allen Figuren mit Kaufkleid (1417, 1515, 1535, `achsel_1515`); wer sitzt, hat nichts in der Hand (1549, `kleid_stufe2_431`); Fackel in der Nebenhand links (1571, Messung im Test); Kartenrand je Gebietskarte, auch mit dem Gras-Kit (1606, `rand_1022`); Funkenlicht 8 m, Abfall 1,0, in der Höhle auch am Tag (1211, `funke_677`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 299.1 | Tom | 1417 | Handy | Hauptmenü: die Wachsoldatin links mit Schild ansehen | Schild ganz, nichts abgeschnitten, er steckt nicht im Körper | Schild links wie abgeschnitten oder im Arm versunken |
| 299.2 | Tom | 1515 | Handy | Hauptmenü wie 299.1, auf die Fläche vor dem Schild der Wachsoldatin achten | vor dem Schild hängt nichts, kein weißer oder heller Streifen zwischen Gürtel und Hand | ein weißer oder heller Streifen vom Gürtel zur Schildhand |
| 299.3 | Tom | 1535 | Handy | Zeile 299.3 → „Lage herstellen“ (Dorf am Schlagbaum, Mittag); bei Jorin und zwei weiteren Bewohnern je einige Sekunden zusehen, während sie stehen und sich in der Ruhebewegung regen | Kleidung bleibt am Körper, auch an den Armen | Stoff hängt an einer Hand oder spannt sich vom Arm zum Rumpf |
| 299.4 | Tom | 1569 | Handy | Zeile 299.4 → „Lage herstellen“ (Vorräte); Menü → Ausrüstung: einen Umhang anlegen, zurück in die Welt, ein paar Schritte gehen; dann ablegen und wieder anlegen | der Umhang ist in der Ausrüstung und in der Welt am Helden zu sehen, nach Ablegen weg, nach Anlegen wieder da; die Kleidung darunter sticht hinten nicht durch | kein Umhang an der Figur in der Welt, oder die Robe ragt hinten durch den Umhang |
| 299.5 | Spike | 1211 | Handy | Zeile 299.5 → „Lage herstellen“ (Höhle am Mittag, Vorräte); Menü → Tasche → Leuchtfunke trinken, dann im Gang an den Wänden entlanggehen | der Funke schwebt kühl weiß über dem Kopf und leuchtet die Wände ringsum weich aus, auch am Tag, schwächer als eine Fackel | in der Höhle am Tag kein Licht vom Funken, oder nur ein heller Fleck direkt am Helden |

## Lagen

- 299.3: ort=village:17:5:UP uhr=12:00
- 299.4: vorraete
- 299.5: station=Krogg uhr=12:00 vorraete
