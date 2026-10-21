# 270 · Perikles und Diogenes auf das große Modell?
Sokrates · 21.10., 06:24 · B Betrieb · M? (Chef 21.10., 06:24, Wortlaut: „Macht das? Sind das unsere obersten Regelwächter? Nämlich Diogenes und Perikles, die die Regeln schreibt, und Diogenes, der sie prüfen soll, nur mit [kleinem Modell] laufen? Macht das Sinn?“)

## Befund

- **Heute** (Startzuordnung Chef 17.10., `tools/lauf.py` MODELL): Tom, Jerry, Homer, Sokrates großes Modell; Perikles, Diogenes, Ford kleines. Ford bleibt klein (Chef 18.10., 167.2).
- **Wo es hakt, sind Regeln:** jeden Morgen ein Umbau am Ablauf (261.4, Chef 06:00); Perikles schreibt diese Regeln und Werkzeuge, Diogenes prüft sie. Regelwerk, das in sich widerspruchsfrei bleiben soll, ist die schwerste Leseaufgabe im Haus, schwerer als vieles, was die Teams bauen.
- **Leitlinie 156.1:** Fehler ausmerzen (179) geht vor Modellkosten.
- **Kosten:** Perikles und Diogenes laufen kurz (Tagesbericht, Wochenzählung, Prüfaufträge); der große Posten sind die Builds der Teams. Mehrkosten gering im Vergleich.

## Vorschlag

1. **Perikles und Diogenes ab dem nächsten Start auf das große Modell** (eine Zeile in `tools/lauf.py`, Startzuordnung in `LISTE-BETRIEB.md`), auf Probe bis Mo 26.10.
2. **Ford bleibt klein**: er führt nur aus, was `lauf.py` sagt.
3. **Messen bis 26.10.:** Umbauten am Ablauf je Tag, Befunde von Diogenes, die sich später als falsch oder fehlend zeigen, Kosten beider Rollen; Wochenzählung legt es vor.

## Stärkstes Gegenargument

Das Modell ist nicht die Hauptursache. Das Regelwerk ist zu groß (`CLAUDE.md`, `ARBEIT-BETRIEB.md` 28 KB, `LISTE-VORGAENGE.md` 32 KB, alle über der Grenze); auch Sitzungen mit großem Modell machen Fehler (heute Morgen schätzte Sokrates eine Uhrzeit). Ein größeres Modell kann das Symptom verdecken, statt dass Regeln gestrichen werden (Regelbilanz, 90a). Darum gehört zu 1 der Auftrag an Perikles, die drei Dateien unter die Grenze zu bringen.

## Berührt

156, 156.1, 167.2, 261.4, 261.5, `tools/lauf.py` MODELL.

## Nachtrag (21.10., 06:25, Chef: „Ist das vielleicht Teil des Problems?“)

Ja, wahrscheinlich ein Teil, belegt ist es nicht. Spur in Git (18.–21.10.): 83 Commits von Perikles, davon viele „berichtigt“ an eigenen Werkzeugen und Regeln (166, 167, 167.6, 167.8; Widersprüche W1–W8 erst nachträglich gefunden). Der Fehler heute Morgen war Fords (kleines Modell: las nur die ersten Seiten, 261.4). Der andere Teil: jede Panne bringt eine neue Regel, kaum eine fällt weg (90a nicht gehalten). Das Modell zu wechseln ändert daran nichts.

**Antwort:** „270 ja“ / „270 nur Diogenes“ / „270 alle drei“ (auch Ford) / „270 nein“.
