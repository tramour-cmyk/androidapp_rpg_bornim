# Jerry · Build 293 · · Sammelbuild: Wölfe bleiben am Helden, Nebenhand nur Schild und Fackel, Rennen mit Renntaste, Leben statt TP, Werkzeugtests · [PR #212](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/212)
E Kampf · Jerry (1072, 1291, 1421, 1284; ohne dich 1292, 1323, 1408, 1409), Spike (1303) · 16.11., 12:52 · APK folgt
Gegengelesen: Tom 16.11., 14:00 (alle Wege am Stand `claude/build-293` nachgesehen, Tests der Zeilen „ohne dich“ stehen in `godot.yml`; 293.7: der Schalter heißt in Menü → System → Bedienung „Rennen“ mit den Werten „Ring“/„Taste“, nicht „Renntaste“; Wortlaut bitte so anpassen)

Sammelbuild auf Build 292 aufgesetzt (enthält alles aus 292, 291, 290 und `main`); die Punkte der Listen 290 bis 292 kommen hier nicht noch einmal. Waldklang 517 fährt mit, seine Prüfung ist die Hörprobe auf Telegram ([517](cs:517)), nicht hier.

Ein Weg: über Build 292 installieren, Zeile 293.1 mit „Lage herstellen“ (Probekampf Wölfe), eine Runde zusehen; danach Hauptmenü, „Weiter“, Menü → Ausrüstung (293.2); zuletzt mit Fackel in die Blutzahnhöhle (293.6, 293.7).

Im Bau geprüft: Kampf- und Verbandmeldungen sagen „Leben“/“Life“ statt TP/HP (1323, `pim_verband_842`), keine Stelle ohne Typ über der Sperrklinke (1408, `typen.py`), Probe des Kauf-Caches ohne die Schalter des Bauservers (1409, `kauf_cache_probe.sh`), eine Einhandwaffe zeigt „Haupthand · Stufe n“ (1291, `gegenstand_524`), Wundsegen nach dem zweiten Segen im Kampf gesperrt (1292, `handlungen_870`; den Knopf „· 2/2“ hast du am Bild gebilligt, 14:15).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 293.1 | Jerry | 1072 | Handy | Zeile 293.1 → „Lage herstellen“ (Probekampf Wölfe), eine ganze Runde zusehen, ohne einzugreifen (Autopilot) | ein Wolf, der gebissen hat, bleibt nah am Helden stehen; wird er nach hinten getauscht, tritt er nur einen ruhigen Schritt zurück; keiner läuft quer über den Kampfort zurück in die Aufstellung | ein Wolf läuft nach dem Biss weit zurück oder quer durch die anderen |
| 293.2 | Jerry | 1291 | Handy | Hauptmenü, „Weiter“ mit deinem Spielstand, Menü → Ausrüstung: den Platz „Nebenhand“ antippen; dann eine Waffe in der Tasche antippen | über der Liste steht „Die Nebenhand hält einen Schild oder eine Fackel.“, die Liste zeigt keine Waffen; bei der Waffe gibt es keinen Knopf „Nebenhand“; lag vorher eine Waffe in der Nebenhand, kam beim Laden die Zeile „Aus deiner Nebenhand in die Tasche gelegt: …“ und die Waffe liegt in der Tasche | Waffen in der Liste der Nebenhand, Knopf „Nebenhand“ bei einer Waffe, oder die Waffe aus der Nebenhand ist weg |
| 293.3 | Jerry | 1323 | ohne dich (Diogenes bestätigt am Lauf) | `pim_verband_842`: Verband meldet „+n Leben“ | Test grün | Test rot |
| 293.4 | Jerry | 1408 | ohne dich (Diogenes bestätigt am Lauf) | `typen.py`: `regeln/mars.gd` unter der Grenze | Test grün | Test rot |
| 293.5 | Jerry | 1409 | ohne dich (Diogenes bestätigt am Lauf) | `kauf_cache_probe.sh`: KAUFCACHE854 gut auf dem Bauserver | Test grün | Test rot |
| 293.6 | Spike | 1303 | Handy | „Weiter“ mit deinem Spielstand, Fackel in der Nebenhand, in die Blutzahnhöhle (Höhlenmund im Norden des Waldes); durch den Gang bis zum Lager gehen und an den Rändern des Lichtkreises auf Wände und Boden schauen | dunkle Flächen gehen glatt ins Schwarze über; im Fackelschein erkennst du Fels und Boden mit ihrer Zeichnung; die Fackel hat einen weichen Schein | rote, gelbgrüne oder fleckige Ränder im Dunkeln, oder du erkennst auch im Fackelschein den Fels nicht, oder das Dunkel ist grau statt schwarz |
| 293.7 | Jerry | 1421 | Handy | in der Höhle (wie 293.6) den Joystick erst wenig, dann weit ausschlagen; dann Menü → System → Bedienung „Rennen“ auf „Taste“, zurück, Joystick weit ausschlagen, dann den Knopf zum Rennen antippen | bei „Ring“: im Ring geht er immer gleich schnell (keine gedehnten Zeitlupenschritte), über den Ring rennt er; bei „Taste“: weit ausgeschlagen geht er nur, erst mit angetipptem Knopf rennt er | er geht bei kleinem Ausschlag langsamer mit großen Schritten, oder er rennt bei „Taste“, ohne den Knopf anzutippen |
| 293.8 | Jerry | 1292 | ohne dich (Diogenes bestätigt am Lauf) | `handlungen_870`: nach dem zweiten Wundsegen im Kampf gesperrt, auch mit Mana | Test grün | Test rot |
| 293.9 | Jerry | 1284 | Film | Probekampf Ratten, Held Ansgar mit Schild, Stand `claude/build-293` (`a71c46f61`): drei Bisse von vorn, bei denen der Held die Zähne verdeckt (alle drei Treffer), zuletzt ein Fehlbiss zum Vergleich; einen verdeckten Fehlbiss gab es im Lauf nicht (1284b D) [Film von 16.11., 14:28](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261116-142842-t293.9/2026-11/16-1428-t293.9-Jerry.mp4) | du liest an Zucken, Blut und Zahl, dass die drei Ratten treffen, beim vierten Biss, dass sie verfehlt | ob die Ratte trifft, siehst du nicht; dann Fall für die Kampfkamera 1402 |

## Lagen

- 293.1: probe=WOLVES
