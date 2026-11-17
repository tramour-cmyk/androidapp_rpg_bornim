# Tom und Jerry · Build 294 · Sammelbuild: Wolf bleibt dran und dreht zum Helden, Zurück im Hauptmenü fragt, Leben in Kampfmeldungen, Testreparaturen · [PR 214](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/214) · Datei bornim-0.348.542-build-294.apk
E Kampf · Jerry (1072, 1275, 1439; ohne dich 1453, 1455, 1296, 642), Tom (1418, 1322, 1480; ohne dich 1044, 1417, 1420, 1383), Spike (1385; ohne dich 1426, 1458, 1485) · 17.11., 01:25 · [APK (Lauf 542)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43980603017/artifacts/14284795775)
Gegengelesen: Tom 23:40 (294.1 Wortlaut wie `[1419.*]`, 294.3 wie `MSG72_DRINKS`; 294.11, 294.12 wie die Wünsche 20:27–21:14; Lagen: `herkunft=Zauberlehrling` in `Testmodus.HERKUENFTE`, `probe=SPIDER` = „Riesenspinne und Wolf“, Schlüssel in `LAGE_SCHLUESSEL`; passt).
Gegengelesen: Sokrates 17.11., 01:26 (alle Handy-Zeilen aus frischem Stand über das Testmenü erreichbar, Lagen vorhanden; „Ein Weg“ um 294.11, 294.12, 294.2b, 294.10 ergänzt; 294.12 Sprache getrennt: englisch Grimmzahn, deutsch Wiedergänger und Grabhund; 294.2b Tausch nur, wenn er vorkommt; passt).
Verglichen (alt gegen neu): Kampfschirm, Kasten des Gefährten mit Leben und Mana gegen `BattleScreen.kt` 1719 (1439, Bild `bild_mana_1439`); Hauptmenü, Fenster „Spiel beenden?“ (1418, Toms Abgleich); sonst kein Schirm berührt (Laufwege, Tests).
Sammelbuild auf `main` mit Build 293 (über die Zweige 1072 und 1453); die Punkte der Liste 293 kommen hier nicht noch einmal. Taumeln 1275 fährt mit; das Kerbensystem gibt es nur in Proben ohne Schalter im Spiel, seine Prüfung ist ein Film auf Telegram, nicht hier.

Ein Weg: über Build 293 installieren, im Hauptmenü Android-Zurück (294.1); Reiter „Test“: „Schnell“ an und wieder Lage herstellen (294.11), Sprache und Namen (294.12); dann Zeile 294.2 mit „Lage herstellen“ (Probekampf Wölfe) zwei Runden zusehen, in der zweiten Runde selbst einen Trank trinken (294.3); dann 294.2b (Spinne und Wolf) und 294.10 (Zauberlehrling, Manabalken).

Im Bau geprüft: Wölfe und Goblins rücken ohne neuen Platz nicht, jedes erlaubte Ziel steht im Bild vorn, Ansagen laufen bis zum Ende (1453: `stehen_973`, `reihe_1305`, `ansage_946`); verdeckte Rattenbisse nur als Auskunft, Luftbisse bleiben Fehler (1455, `biss_1284`); nach der Eingebung zum Wechsel ist „Wechsel“ im nächsten Zug des Helden aktiv (1296, `eingebung_1296`); tote SRD-Reste entfernt, alle Tests laufen ohne sie (1458).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 294.1 | Tom | 1418 | Handy | Spiel starten, im Hauptmenü einmal Android-Zurück; dann „Abbrechen“; noch einmal Zurück und neben das Fenster tippen | nach Zurück steht „Spiel beenden?“ mit „Abbrechen“ und „Beenden“; Abbrechen und Tippen daneben lassen dich im Hauptmenü; nur „Beenden“ schließt das Spiel | das Spiel schließt sich gleich beim ersten Zurück, oder Abbrechen beendet es |
| 294.2 | Jerry | 1072 | Handy | Zeile 294.2 → „Lage herstellen“ (Probekampf Wölfe), eine Runde mit Automatik zusehen; dann „Nochmal“ und noch eine Runde | in beiden Durchgängen bleibt ein Wolf nach dem Biss nah am Helden; ein Wolf, der angreift oder „Anspringen“ ansagt, steht mit dem ganzen Körper zum Helden, nicht nur mit dem Kopf; Wölfe rücken auch seitlich an den Helden (Umzingeln bleibt) | im ersten Durchgang läuft ein Wolf nach dem Biss weit zurück oder quer durch die anderen, oder ein Wolf steht nach seinem Angriff schräg oder seitlich zum Helden, oder alle Wölfe stehen nur vorn in einer Reihe |
| 294.2b | Jerry | 1072 | Handy | Zeile 294.2b → „Lage herstellen“ (Probekampf Riesenspinne und Wolf), eine Runde mit Automatik zusehen | Spinne und Wolf bleiben nach dem Angriff am Helden, stehen mit dem Körper zu ihm und rücken auch seitlich an ihn; tauschen Held und Söldner den Platz (nur, wenn es vorkommt), gehen sie aneinander vorbei, nicht durcheinander | ein Gegner läuft nach dem Angriff weit zurück, steht schräg zum Helden, alle stehen nur vorn in einer Reihe, oder Held und Söldner laufen beim Tausch durcheinander |
| 294.3 | Tom | 1322 | Handy | im Probekampf (294.2) die Automatik ausschalten, in deinem Zug über die Leiste „Tasche“ einen Heiltrank trinken | in der Zeile steht „<Name> trinkt (Heiltrank): +n Leben.“ | in der Zeile steht TP, HP oder „Trefferpunkte“ |
| 294.4 | Jerry | 1453 | ohne dich (Diogenes bestätigt am Lauf) | `stehen_973`, `reihe_1305` (Seed 7, 9), `ansage_946`, `dreh_1072` (Flanke, Seed 7, 9), `wolf_mess_438` | Tests grün | Test rot |
| 294.5 | Jerry | 1455 | ohne dich (Diogenes bestätigt am Lauf) | `biss_1284` (Seed 7, 9, 13): verdeckter Biss nur Auskunft, Luftbiss Fehler | Test grün | Test rot |
| 294.6 | Jerry | 1296 | ohne dich (Diogenes bestätigt am Lauf) | `eingebung_1296`: nach der Eingebung „Wechsel“ im nächsten Zug aktiv | Test grün | Test rot |
| 294.7 | Spike | 1426 | ohne dich (Diogenes bestätigt am Lauf) | Schritt „Bildrate je Ort“: Ladezeit und Bildrate je Ort gegen Lauf 524 als Zahlen im Protokoll | Zahlen stehen da | keine Zahlen |
| 294.8 | Spike | 1458 | ohne dich (Diogenes bestätigt am Lauf) | Prüfschritt ohne die entfernten SRD-Reste | Prüfschritt ohne Fehler aus 1458 | Fehler aus 1458 |
| 294.9 | Jerry | 642 | ohne dich (Diogenes bestätigt am Lauf) | `wolf_mess_438`: kein Wolf in einem anderen, keiner am Bildrand angeschnitten | Test grün | Test rot |
| 294.10 | Jerry | 1439 | Handy | Zeile 294.10 → „Lage herstellen“ (Probekampf Wölfe mit Zauberlehrling), auf die Kästen unten sehen | im Kasten des Helden zwei Balken untereinander ohne Wort davor: Leben in Lebensfarbe, Mana blau wie in der Weltleiste; beide gleich lang und bündig, dahinter je die Zahl „n/n“ | „Mana 40/40“ als Text hinter dem Leben, kein blauer Balken, oder Balken verschieden lang |
| 294.11 | Tom | 1480 | Handy | Reiter „Test“ → „Schnell“ an; dann „Lage herstellen“ einer beliebigen Zeile | mit „Schnell“ an steht die rote Zeile „Schnell an: verfälscht Prüfpunkte“; nach „Lage herstellen“ ist „Schnell“ aus und die Zeile weg | keine rote Zeile, oder „Schnell“ bleibt nach „Lage herstellen“ an |
| 294.12 | Spike | 1385 | Handy | Testmenü auf Englisch stellen, Probekampf Grimmzahn wählen; dann zurück auf Deutsch, Probekampf Wiedergänger und Grabhund wählen | auf Englisch heißt Grimmzahn „Grimfang, the Pack Leader“; auf Deutsch heißen die beiden „Wiedergänger“ und „Grabhund“ | alte Namen (Zombie, Ghul) oder Grimmzahn ohne englischen Namen |
| 294.13 | Tom | 1044 | ohne dich (am Bild gebilligt, 👍 15:48) | Grundstand der Leute | – | – |
| 294.14 | Tom | 1417 | ohne dich (am Bild gebilligt, 👍 19:41) | Schild im Heldenmenü, `schild_menue_1417` | Test grün | Test rot |
| 294.15 | Tom | 1420 | ohne dich (am Film gebilligt, 👍 19:40) | Fußstaub sanfter, auch im Wald | – | – |
| 294.16 | Tom | 1383 | ohne dich (Diogenes bestätigt am Lauf) | `ziege_4162` | Test grün | Test rot |
| 294.17 | Jerry | 517 | ohne dich (an der Hörprobe gebilligt, 👍 16.11., 12:29) | Waldklang: keine Vögel nachts und im Tiefen Wald, ferner Wolf nach 8–20 s (`601e67974`, im Build) | – | – |

## Lagen

- 294.2: probe=WOLVES tasche=voll
- 294.2b: probe=SPIDER
- 294.10: probe=WOLVES herkunft=Zauberlehrling

## Ergebnis

Chef 17.11., 06:51 (Chat Sokrates); übrige Punkte „ohne dich“ wie in der Liste bestätigt oder gebilligt:
- 294.1 ✓
- 294.2 ✓
- 294.2b ✓
- 294.3 ✓
- 294.10 ✓
- 294.11 ✓
- 294.12 ✓
- Rest ✓
