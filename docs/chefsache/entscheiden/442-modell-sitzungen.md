# 442 · Welches Modell läuft in welcher Sitzung?
Sokrates · 31.10., 23:5x · B Abläufe

**Frage:** Du hast gefragt, warum „alle auf Sonnet“ laufen und nicht mehr auf Opus. Soll die Zuordnung so bleiben (alle Rollen Opus, nur Ford Sonnet), und wie stellen wir sicher, dass auch eine von dir in der App gestartete Sitzung auf Opus läuft?
**Votum Sokrates:** Zuordnung bleibt (167.2, 156.1, `tools/lauf.py` `MODELL`): alle Rollen Opus, Ford Sonnet. Eine Sitzung, die du selbst in der Desktop-App startest, bekommt das Modell, das du dort im Auswahlfeld hast; stell es für Sokrates-Sitzungen auf Opus. Diese Sitzung übergibt jetzt an einen Nachfolger, den Ford über `lauf.py` auf Opus startet.
**Berührt:** `tools/lauf.py` (Startzuordnung), `LISTE-BETRIEB.md`, Kosten.

## Sachverhalt (gemessen 31.10., 23:53, 13 Sitzungen mit Tätigkeit am 31.10.)

- **11 von 12 Sitzungen, die Ford oder `lauf.py` starten, laufen auf Opus**: Tom, Tuffy, Spike, Jerry, Homer, Perikles (2), Diogenes (3), dazu der Sokrates der Chefrunde vom 29.10. Alle mit `configured_model` opus.
- **Sonnet laufen genau zwei:** Ford (festgelegt, 167.2: „Ford bleibt auf Sonnet“) und **diese Sokrates-Sitzung**. Sie wurde nicht von Ford gestartet (Herkunft `desktop_app`, ohne Elternsitzung) und läuft auf dem in der App gewählten Modell (Sonnet).
- Eine Sitzung, die ein anderes Modell fährt als eingetragen, gibt es nicht: bei allen 13 stimmt `session_context.model` mit `configured_model` überein.

## Auswertung

*Stärkstes Gegenargument gegen Opus für Sokrates:* Sonnet ist deutlich billiger (die zwei Sonnet-Sitzungen kosteten 6–7 $ bei 300–400 Tsd. Token; Tom und Jerry kosten im Mittel etwa 21 $ je Sitzung, 31.10., 404). Das Guthaben ist begrenzt. *Dafür:* Beratung, Entwürfe wie das Spielsystem 2.0 und Prüfungen leben von Gründlichkeit; die Chefrunde und Grundsatzfragen sind Entscheidungen, die schwer rückgängig zu machen sind (Oberste Direktive: Fehler ausmerzen). Die Startzuordnung hat der Chef am 17.10. so gewollt.

## Folgerung

Ja: Startzuordnung unverändert. Der Nachfolger dieser Sitzung (`Sokrates – 422 Abgleich, 427 Bestiarium`) startet über Ford auf Opus. Sag mir, wenn du auch für Sokrates dauerhaft Sonnet möchtest, dann tragen wir es in `lauf.py` ein.

Erledigt: deine Antwort in das Vorgangsarchiv, Datei löschen (Sokrates).
