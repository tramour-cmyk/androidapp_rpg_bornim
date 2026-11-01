# 461b · Nur die gültige Entscheidung steht: wer prüft auf Widersprüche?
Sokrates · 01.11., 22:24 · B Abläufe

**Frage:** Chef 22:23: „Wichtig ist, dass am Schluss nur die gültige Entscheidung steht. Nichts ist für die Ewigkeit einmal entschieden. Wer prüft denn nach, dass nicht gegensätzliche Entscheidungen an verschiedenen Stellen stehen?“ Heute: niemand verlässlich. Das Vorgangsarchiv darf alte Einträge nicht ändern; so stehen 410 (Rücken, 31.10.) und 417 (Hand, 01.11.) gleichrangig nebeneinander, und Perikles schrieb heute 20:57 die überholte Fassung in den Grundstand E1 (berichtigt 22:2x).
**Votum Sokrates:** drei Stellen, ein Prüfer:
1. **Grundstand gilt** (`LISTE-GRUNDSTAND-461.md`, später je Bereich eine solche Liste): nur dort steht, was jetzt gilt; das Vorgangsarchiv ist Verlauf.
2. **Wer neu entscheidet, löst das Alte ab, im selben Commit:** neuer Archiveintrag mit „ersetzt <Nr., Datum>“; der alte Eintrag bekommt am Ende „→ ersetzt durch <Nr., Datum>“ (statt „nie ändern“, Regelbilanz); die Grundstandzeile wird geändert.
3. **Prüfer:** die Commit-Prüfung hält an, wenn ein Archiveintrag zu Figuren, Bewegung, Kampf oder Regeln ohne Änderung im Grundstand kommt; Diogenes zählt montags Widersprüche (Stichprobe Archiv gegen Grundstand) als Kennzahl.
**Berührt:** 461, Vorgangsarchiv-Kopf, `tools/commit-pruefung.py` (Perikles), Diogenes.

## Auswertung

- **Stärkstes Gegenargument:** alte Einträge anzufassen öffnet die Tür zum stillen Umschreiben des Verlaufs.
- **Entkräftet:** erlaubt ist nur der Anhang „→ ersetzt durch …“, kein anderer Text; Git zeigt jeden Eingriff, die Commit-Prüfung lässt nur diesen Anhang zu.
- Wenn neue Technik kommt (Pakete, Engine), stellt der Vorlegende die betroffenen Grundstandzeilen in seiner Vorlage zur Prüfung („berührt E1, alt: …, neu: …“); so entscheidet der Chef ausdrücklich, statt dass zwei Fassungen bleiben.

## Folgerungen

- „ja“: Perikles baut 2 und 3 (Kopf des Archivs, Commit-Prüfung, Vorlagenpflicht), Diogenes bekommt die Kennzahl; Sokrates sucht einmal das Archiv nach Widersprüchen zu Figuren und Kampf ab und legt die Liste vor.
- „nein“: wie heute, Pflege nur durch den Eintragenden.

**Zu sagen:** „461b ja“ oder was anders sein soll.
