# Spike · Build 295 · Sammelbuild: Glühen und Höhlenlicht, Merkmale am Gegnernamen · [PR 213](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/213) · Datei bornim-0.348.546-build-295.apk
E Technik · Spike (1483; ohne dich 1270.4), Jerry (1488; ohne dich 1488, 1275, 601.1, 1340, 1284b, 623.2) · 17.11., 07:15 · [APK (Lauf 546)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/44024918701/artifacts/14303487932)
Rot, bekannt, nicht melden: Typenprüfung (kampf/treffer_fx.gd, kampf/kampfort.gd ohne Typen) und arkan_993 (Arkanpfeil landet 0,95 m neben dem Gegner), Vorgang 1514 (Jerry); wolf_mess_438 – nach einem Tod rücken Wölfe ohne neuen Platz nach (439, F3), Vorgang 1505 (Jerry); tod_ragdoll_1215 – Grak: Gelenk Unterarm klafft 0,083 m, Physik bei 3 Toten 15 ms je Bild; mit 1340 auch Skelett Oberarm 0,096 m und Goblin mit Gift sackt nicht am Platz, Vorgang 1505 (Jerry).

Gegengelesen: Tom 00:25 (295.1 wie Archiv 1270.4, 👍 16.11., 17:32; 295.2 nach Einwand neu gefasst, passt: `herkunft=Jägerkind` in `BrsHeld.herkuenfte()` (testmodus.gd 721), „Lesestufe 3“ von Jerry, nicht nachgerechnet; 295.3 Test auf `claude/spike-295-vorlauf` da). 531 trage ich nach grünem Lauf selbst ein.

Verglichen (alt gegen neu): Glühen und Höhlenlicht im Vergleichsfilm (1270.4, gebilligt 16.11., 17:32); sonst kein Schirm umgebaut (1488 ergänzt den Zusatz am Gegnernamen, 1275 ist eine Regel).

Sammelbuild auf `claude/build-294` (Lauf 539); die Punkte der Liste 294 kommen hier nicht noch einmal. 531 (Tom) fährt im nächsten Build (Wolf im Fackelfilm nicht zu sehen, Tom 01:20).

Nachtrag 17.11., 06:28 (Jerry, nach Ford 06:18): 601.1, 1340, 1284b, 623.2 hinein, alle am Film gebilligt, nicht zu testen. Nachtrag 06:33 (Spike): 1483 (Anmerkung bei Passt, 295.9) hinein.

Ein Weg: über Build 294 installieren; Zeile 295.2 mit „Lage herstellen“.

Im Bau geprüft: Merkmale je Gegner beim Kampfbeginn, höchstens eines je Gegner, Zusatz am Namen nach Lesestufe (1488, `merkmale_1488`); Lösen auch mit der letzten Kerbe (1275, `kerbe_930` Regel 3).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 295.1 | Spike | 1270.4 | ohne dich (am Film gebilligt, 👍 16.11., 17:32) | Glühen an Feuer, Glut, Kristallen, Pilzen ab Grafikstufe Hoch; vorberechnetes Höhlenlicht immer | – | – |
| 295.2 | Jerry | 1488 | Handy | Zeile 295.2 → „Lage herstellen“ (Probekampf Wölfe, Held Jägerkind, Lesestufe 3 gegen Wölfe), auf die Namen über den Wölfen sehen; dann zweimal „Nochmal“ | in jedem Durchgang trägt etwa jeder zweite Wolf hinter dem Namen ein Merkmal mit Wirkung, etwa „Wolf 2 · jung (Leben −15 %, Angriff −10 %, Abwehr +10 %)“; die übrigen nur ihren Namen; von Durchgang zu Durchgang wechselt, welcher Wolf welches Merkmal trägt | in drei Durchgängen trägt kein Wolf oder jeder Wolf ein Merkmal, ein Merkmal steht ohne Wirkung in Klammern, oder ein Wolf trägt zwei Merkmale |
| 295.3 | Jerry | 1488 | ohne dich (Diogenes bestätigt am Lauf) | `merkmale_1488`: höchstens ein Merkmal je Gegner, Zusatz nach Lesestufe | Test grün | Test rot |
| 295.4 | Jerry | 1275 | ohne dich (Diogenes bestätigt am Lauf) | `kerbe_930` Regel 3 „Lösen mit der letzten Kerbe“ | Test grün | Test rot |
| 295.5 | Jerry | 601.1 | ohne dich (am Film gebilligt, 👍 17.11., 06:01) | Pfeil trifft den Getroffenen an der Brust, er zuckt dort (auch mit Schild) | – | – |
| 295.6 | Jerry | 1340 | ohne dich (am Film gebilligt, 👍 17.11., 06:08) | Skelett und Wiedergänger fallen mit Physik in Schlagrichtung | – | – |
| 295.7 | Jerry | 1284b | ohne dich (am Film gebilligt, 👍 17.11., 06:08) | verdeckter Rattenbiss wie im Film, ohne Kamerahebung | – | – |
| 295.8 | Jerry | 623.2 | ohne dich (am Film gebilligt, 👍 17.11., 06:11) | Kampfeffekte Wolfskampf: Klingenspur, Blut, Parade, Luftzug, Staub beim Sprung | – | – |
| 295.9 | Spike | 1483 | Handy | Reiter „Test“, diese Zeile 295.9 aufklappen, ins Feld „Anmerkung, freiwillig …“ ein Wort tippen, dann „Passt“; danach „Ergebnis kopieren“ und irgendwo einfügen | im eingefügten Text steht „- 295.9 ✓ <dein Wort>“ | Feld fehlt, das Wort ist nach „Passt“ weg, oder der Text zeigt nur „✓“ |

## Lagen

- 295.2: probe=WOLVES herkunft=Jägerkind

## Ergebnis

- 295.2 ✓ (Chef 17.11., 08:09, Bildschirmfoto: „wenn der Wolf normal ist, steht sozusagen nichts dabei. Wenn er der Durchschnittswolf ist, dann passt das alles.“ Wolf 1 ohne Merkmal 25/25, Wolf 2 angeschlagen −30 % 18/18, Wolf 3 kräftig +15 % 29/29)
