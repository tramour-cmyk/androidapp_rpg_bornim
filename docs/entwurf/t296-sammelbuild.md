# Tom · Build 296 · Sammelbuild: Höhlenwände in voller Höhe, Garricks Fackel, Leiste ohne Wörter, Schneidern · [PR 215](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/215)
E Welt · Tom (Handy 1423; ohne dich 1460, 531, 1448) · 17.11., 06:50 · APK folgt
Rot, bekannt, nicht melden: wie Build 295: Typenprüfung (kampf/treffer_fx.gd, kampf/kampfort.gd) und arkan_993, Vorgang 1514 (Jerry); wolf_mess_438, Vorgang 1505 (Jerry); tod_ragdoll_1215, Vorgang 1505 (Jerry).

Verglichen (alt gegen neu): Höhle Lager und Krogg am Bild (1423, 👍 17.11., 06:09), Garricks Fackelabwehr im Film (531, 👍 06:06), Weltleiste und Heldenmenü am Bild (1448, 👍 06:02); Umbau überall: die Balken ohne Wörter gibt es nur in Weltleiste und Heldenmenü, den Kampfschirm baut Jerry mit 1439.

Sammelbuild auf `claude/build-295`; die Punkte der Liste 295 kommen hier nicht noch einmal.

Ein Weg: über Build 295 installieren; Zeile 296.1 mit „Lage herstellen“.

Gegengelesen: Jerry 17.11., 07:00 (Lage-Schlüssel gültig, alle vier Zweige in `claude/build-296`, `hoehle_492` und `schneidern_1460` stehen in `godot.yml`; ob der Platz am Leuchtpilz die hohe Wand zwischen Kamera und Held hat, prüft erst `lage_1156` im Bau)

Im Bau geprüft: Höhlenwände mindestens 2,2 m, Loch um den Helden hinter einer Wand, am Eingang keins (1423, `hoehle_492`); Fertigkeit heißt Schneidern (EN Tailoring), Lederarbeit aus alten Spielständen übernommen (1460, `schneidern_1460`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 296.1 | Tom | 1423 | Handy | Zeile 296.1 → „Lage herstellen“ (Höhle, Westflügel unten am Leuchtpilz, die hohe Wand zum Teich steht zwischen dir und dem Helden); drei Schritte nach rechts und wieder zurück | der Held bleibt ganz zu sehen: in der Wand vor ihm ist ein rundes Loch, das mit ihm geht; links und rechts davon steht der Fels hoch | der Held verschwindet hinter der Wand, das Loch bleibt stehen oder flackert, oder die ganze Wand ist weg |
| 296.2 | Tom | 1460 | ohne dich (Diogenes bestätigt am Lauf) | `schneidern_1460`: Fertigkeit Schneidern statt Lederarbeit, alte Spielstände übernommen | Test grün | Test rot |
| 296.3 | Tom | 531 | ohne dich (am Film gebilligt, 👍 17.11., 06:06) | Garrick vertreibt den Wolf mit der Fackel; seine Fackel leuchtet im Nebel | – | – |
| 296.4 | Tom | 1448 | ohne dich (am Bild gebilligt, 👍 17.11., 06:02) | Weltleiste und Heldenmenü ohne Wörter Leben/Mana/EP, Balken bündig, dahinter die Zahl, bei Erfahrung die Stufe | – | – |

## Lagen

- 296.1: station=Krogg ort=cave:2:11:RIGHT ruhig
