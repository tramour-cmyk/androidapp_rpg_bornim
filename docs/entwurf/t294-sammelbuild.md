# Tom und Jerry · Build 294 · Sammelbuild: Wolf bleibt dran und dreht zum Helden, Zurück im Hauptmenü fragt, Leben in Kampfmeldungen, Testreparaturen · PR folgt
E Kampf · Jerry (1072, 1275; ohne dich 1453, 1455, 1296, 642), Tom (1418, 1322), Spike (ohne dich 1426, 1458) · 16.11., 23:05 · APK folgt
Gegengelesen: Tom 20:27 (294.1 Wortlaut wie `[1419.*]`, 294.3 wie `MSG72_DRINKS` auf `claude/build-294`; passt); neu seit 23:05: 294.2 Umzingeln, 294.2b, 294.4, 294.5, 294.9, bitte noch einmal

Sammelbuild auf `main` mit Build 293 (über die Zweige 1072 und 1453); die Punkte der Liste 293 kommen hier nicht noch einmal. Taumeln 1275 fährt mit; das Kerbensystem gibt es nur in Proben ohne Schalter im Spiel, seine Prüfung ist ein Film auf Telegram, nicht hier.

Ein Weg: über Build 293 installieren, im Hauptmenü Android-Zurück (294.1); dann Zeile 294.2 mit „Lage herstellen“ (Probekampf Wölfe) zwei Runden zusehen, in der zweiten Runde selbst einen Trank trinken (294.3).

Im Bau geprüft: Wölfe und Goblins rücken ohne neuen Platz nicht, jedes erlaubte Ziel steht im Bild vorn, Ansagen laufen bis zum Ende (1453: `stehen_973`, `reihe_1305`, `ansage_946`); verdeckte Rattenbisse nur als Auskunft, Luftbisse bleiben Fehler (1455, `biss_1284`); nach der Eingebung zum Wechsel ist „Wechsel“ im nächsten Zug des Helden aktiv (1296, `eingebung_1296`); Ladezeit und Bildrate je Ort gegen den Vorgänger als Zahlen (1426, `bildrate.py`); tote SRD-Reste entfernt, alle Tests laufen ohne sie (1458).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 294.1 | Tom | 1418 | Handy | Spiel starten, im Hauptmenü einmal Android-Zurück; dann „Abbrechen“; noch einmal Zurück und neben das Fenster tippen | nach Zurück steht „Spiel beenden?“ mit „Abbrechen“ und „Beenden“; Abbrechen und Tippen daneben lassen dich im Hauptmenü; nur „Beenden“ schließt das Spiel | das Spiel schließt sich gleich beim ersten Zurück, oder Abbrechen beendet es |
| 294.2 | Jerry | 1072 | Handy | Zeile 294.2 → „Lage herstellen“ (Probekampf Wölfe), eine Runde mit Automatik zusehen; dann „Nochmal“ und noch eine Runde | in beiden Durchgängen bleibt ein Wolf nach dem Biss nah am Helden; ein Wolf, der angreift oder „Anspringen“ ansagt, steht mit dem ganzen Körper zum Helden, nicht nur mit dem Kopf; Wölfe rücken auch seitlich an den Helden (Umzingeln bleibt) | im ersten Durchgang läuft ein Wolf nach dem Biss weit zurück oder quer durch die anderen, oder ein Wolf steht nach seinem Angriff schräg oder seitlich zum Helden, oder alle Wölfe stehen nur vorn in einer Reihe |
| 294.2b | Jerry | 1072 | Handy | Zeile 294.2b → „Lage herstellen“ (Probekampf Riesenspinne und Wolf), eine Runde mit Automatik zusehen | Spinne und Wolf bleiben nach dem Angriff am Helden, stehen mit dem Körper zu ihm und rücken auch seitlich an ihn; tauschen Held und Söldner den Platz, gehen sie aneinander vorbei, nicht durcheinander | ein Gegner läuft nach dem Angriff weit zurück, steht schräg zum Helden, alle stehen nur vorn in einer Reihe, oder Held und Söldner laufen beim Tausch durcheinander |
| 294.3 | Tom | 1322 | Handy | im Probekampf (294.2) die Automatik ausschalten, in deinem Zug über die Leiste „Tasche“ einen Heiltrank trinken | in der Zeile steht „<Name> trinkt (Heiltrank): +n Leben.“ | in der Zeile steht TP, HP oder „Trefferpunkte“ |
| 294.4 | Jerry | 1453 | ohne dich (Diogenes bestätigt am Lauf) | `stehen_973`, `reihe_1305` (Seed 7, 9), `ansage_946`, `dreh_1072` (Flanke, Seed 7, 9), `wolf_mess_438` | Tests grün | Test rot |
| 294.5 | Jerry | 1455 | ohne dich (Diogenes bestätigt am Lauf) | `biss_1284` (Seed 7, 9, 13): verdeckter Biss nur Auskunft, Luftbiss Fehler | Test grün | Test rot |
| 294.6 | Jerry | 1296 | ohne dich (Diogenes bestätigt am Lauf) | `eingebung_1296`: nach der Eingebung „Wechsel“ im nächsten Zug aktiv | Test grün | Test rot |
| 294.7 | Spike | 1426 | ohne dich (Diogenes bestätigt am Lauf) | Schritt „Bildrate je Ort“: Ladezeit und Bildrate je Ort gegen Lauf 524 als Zahlen im Protokoll | Zahlen stehen da | keine Zahlen |
| 294.8 | Spike | 1458 | ohne dich (Diogenes bestätigt am Lauf) | Prüfschritt ohne die entfernten SRD-Reste | Prüfschritt ohne Fehler aus 1458 | Fehler aus 1458 |
| 294.9 | Jerry | 642 | ohne dich (Diogenes bestätigt am Lauf) | `wolf_mess_438`: kein Wolf in einem anderen, keiner am Bildrand angeschnitten | Test grün | Test rot |

## Lagen

- 294.2: probe=WOLVES tasche=voll
- 294.2b: probe=SPIDER
