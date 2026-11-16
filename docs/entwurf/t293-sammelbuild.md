# Jerry · Build 293 · · Sammelbuild: Wölfe bleiben am Helden, Leben statt TP, Werkzeugtests · PR folgt
E Kampf · Jerry (1072; ohne dich 1323, 1408, 1409) · 16.11., 12:22 · APK folgt

Sammelbuild auf Build 292 aufgesetzt (enthält alles aus 292, 291, 290 und `main`); die Punkte der Listen 290 bis 292 kommen hier nicht noch einmal. Waldklang 517 fährt mit, seine Prüfung ist die Hörprobe auf Telegram ([517](cs:517)), nicht hier.

Ein Weg: über Build 292 installieren, Zeile 293.1 mit „Lage herstellen“ (Probekampf Wölfe), eine Runde zusehen.

Im Bau geprüft: Kampf- und Verbandmeldungen sagen „Leben“/“Life“ statt TP/HP (1323, `pim_verband_842`), keine Stelle ohne Typ über der Sperrklinke (1408, `typen.py`), Probe des Kauf-Caches ohne die Schalter des Bauservers (1409, `kauf_cache_probe.sh`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 293.1 | Jerry | 1072 | Handy | Zeile 293.1 → „Lage herstellen“ (Probekampf Wölfe), eine ganze Runde zusehen, ohne einzugreifen (Autopilot) | ein Wolf, der gebissen hat, bleibt nah am Helden stehen; wird er nach hinten getauscht, tritt er nur einen ruhigen Schritt zurück; keiner läuft quer über den Kampfort zurück in die Aufstellung | ein Wolf läuft nach dem Biss weit zurück oder quer durch die anderen |
| 293.2 | Jerry | 1323 | ohne dich (Diogenes bestätigt am Lauf) | `pim_verband_842`: Verband meldet „+n Leben“ | Test grün | Test rot |
| 293.3 | Jerry | 1408 | ohne dich (Diogenes bestätigt am Lauf) | `typen.py`: `regeln/mars.gd` unter der Grenze | Test grün | Test rot |
| 293.4 | Jerry | 1409 | ohne dich (Diogenes bestätigt am Lauf) | `kauf_cache_probe.sh`: KAUFCACHE854 gut auf dem Bauserver | Test grün | Test rot |

## Lagen

- 293.1: probe=WOLVES
