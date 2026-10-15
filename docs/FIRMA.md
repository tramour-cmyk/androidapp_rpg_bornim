# WireStormTCS – Handbuch

Nur bei Anlass lesen. Leitlinien, Rollen, „Wo was steht“ und die Regeln der Zusammenarbeit stehen in `CLAUDE.md` (Vorspann, lesen alle). Grundlage: Wortlaute des Chefs zu 98 und 99 (15.10., 18:5x–22:5x), Beschlüsse 90, 90a, D11.1, 99f, Leitbild. Umgebaut 15.10. (98); die Docs-Dokumente Firmenordnung und Rollenkonzept sind seitdem Stand vom 15.10. und werden nicht mehr gepflegt.

## Organigramm

```
                      Chef (Nutzer)
        ┌───────────────┼─────────────────┐
  Sokrates Berater      │            Diogenes (prüft)
  (Stab, nur Zuruf)     │
  Sokrates Kreativ ─────┤
  Sokrates Projekt ─────┤ (Ziele, Vorrang)
                        │
              Ford (Zentrale, Max)        Ford 2 (Niederlassung, Pro)
                        │                          │
                    Team Tom                   Team Jerry
```

Sokrates und Diogenes stehen neben der Linie: sie beraten und prüfen, verteilen keine Arbeit; beide laufen in der Zentrale. Teams und Hüte stoßen sich direkt über die Vorräte an; die Linie zeigt nur, wer startet und zuteilt. Ford 2 untersteht dem Chef, nicht Ford: Ford kann auf Pro nichts starten.

## Dateien je Rolle

Jede Sitzung liest beim Start `CLAUDE.md`, dann nur ihre Rollendatei und ihren Vorrat.

| Rolle | Rollendatei | Vorrat | Bei Bedarf |
|---|---|---|---|
| Team Tom (jede Sitzung) | `ROLLE-TEAM.md` | `ARBEIT-TEAM-TOM.md` | `STORY-…`, `LISTE-FIGUREN.md` (Leitbild, Stil, Abnahme liest das Team beim Start, 76) |
| Team Jerry (jede Sitzung) | `ROLLE-TEAM.md` | `ARBEIT-TEAM-JERRY.md` | wie Team Tom |
| Sokrates Berater | `ROLLE-BERATUNG.md` | `ARBEIT-BERATUNG.md` (Übergabe, Aufträge des Chefs; kein Eingang für Teams) | `DESIGN-LEITBILD.md` |
| Sokrates Kreativ | `ROLLE-KREATIV.md` | `ARBEIT-KREATIV.md` | alle `DESIGN-…`, `STORY-…`, `LISTE-IDEEN.md` |
| Sokrates Projekt | `ROLLE-PROJEKT.md` | `ARBEIT-PROJEKT.md` | Kopfzeilen aller Vorräte |
| Diogenes | `ROLLE-PRUEFUNG.md` | `ARBEIT-PRUEFUNG.md` | Regeln des geprüften Bereichs |
| Ford (Zentrale) | `ROLLE-BETRIEB.md` | `ARBEIT-BETRIEB.md` | Kopfzeilen aller Vorräte, `ARBEIT-BESETZUNG.md` |
| Ford 2 (Niederlassung) | `ROLLE-BETRIEB.md` | `ARBEIT-BETRIEB.md` | Kopfzeile von `ARBEIT-TEAM-JERRY.md` |

Nachschlagen, kein Vorrat: `ARBEIT-ABLAEUFE.md` (Release, Neustart), `ARBEIT-UMGEBUNG.md` (Werkzeuge, Vorschau-Schalter), `ARBEIT-ARCHIV.md` (Verlauf, nur gezielt durchsuchen).

## Vorrat und Vorrang

Alle Vorräte sind gleich gebaut. Die **Reihenfolge der Zeilen ist der Vorrang**: oben steht, was zuerst kommt. „A“ markiert nur, was Arbeit oder Spiel anhält (97a). Jede Zeile: Nummer, Thema mit Wortlaut des Chefs, Stand, gegebenenfalls „fertig, wenn …“, „Wartet auf <Nr>“, Zweig.

| Wer | Entscheidet |
|---|---|
| Bereich | schlägt vor: trägt Neues ein, meldet „A“ an Ford, nennt „Wartet auf“ |
| Sokrates Projekt | sortiert alle Vorräte nach den Zielen, einmal täglich beim Tagesrückblick; setzt „A“ |
| Ford | teilt zu und startet nach dieser Reihenfolge; meldet, wenn ein Bereich leer läuft oder überläuft |
| Chef | nur wenn er will: verschiebt eine Zeile oder setzt „A“ |

Zusammenhänge stehen in „Wartet auf“ mit Nummer, auch über Bereiche hinweg; Ford sieht daran, was blockiert ist.

## Wie Arbeit wandert

| Was | Wohin | Wer kümmert sich |
|---|---|---|
| Anstoß für einen anderen Bereich | Zeile im Vorrat des Bereichs, „von …“ | der Bereich; Ford sieht es an der Kopfzeile |
| Aufgabe, die noch keinem Bereich gehört | Fords Eingang in `ARBEIT-BETRIEB.md` | Ford teilt sie zu; kann er es keinem zuordnen, legt er es im selben Lauf dem Chef vor, nie liegen lassen (Chef 22:3x) |
| Grundsatzfrage | Vorrat von Kreativ oder Projekt | der Hut, mit Empfehlung auf „Dein Zug“ |
| Prüfauftrag | `ARBEIT-PRUEFUNG.md`, dann `send_message` an Ford „Auftrag Diogenes <Nr>“ (von Pro aus nur die Zeile, Ford sieht sie im Stundenlauf) | Ford startet Diogenes |
| Idee („was wäre, wenn …“) | `LISTE-IDEEN.md`, eine Zeile mit Datum | Sokrates Kreativ sichtet wöchentlich, reife Ideen bekommen Nummer und Zeile |
| Erledigtes | `CHANGELOG.md` unter „Unveröffentlicht“ | wer es erledigt hat |
| Lehre für alle | Zeile unter „Lehren für alle“ in `ARBEIT-PROJEKT.md` | Sokrates Projekt übernimmt sie in die passende Rollendatei |

Berührt eine Frage Kreativ und Projekt, nimmt sie der Hut, der zuerst entscheiden muss, und nennt den anderen in der Zeile. Prüfen am 23.10.: Wächst Fords Eingang, ordnen die Teams zu wenig selbst ein.

**Abgrenzung der drei Sokrates-Hüte.** Kreativ (`ARBEIT-KREATIV.md`): Spiel und Design (Story, Texte, Stil, Aussehen, Spielgefühl, Balance, Ideen). Projekt (`ARBEIT-PROJEKT.md`): Ablauf und Aufbau (Abläufe, Regeln, Umbauten, Ziele, Meilensteine, Vorrang, Kosten-Nutzen der Arbeit). Beratung (`ARBEIT-BERATUNG.md`): nur Aufträge des Chefs (Markt, Geschäftsmodell, Strategie, Kosten-Nutzen des Produkts); Stab ohne Eingang für Teams (Chef 21:4x: Fragen zu Markt und Geschäftsmodell entstehen nur im Gespräch mit ihm). Grundsatzfragen der Teams gehen nie direkt auf „Dein Zug“, sondern erst mit Gegenargument und Empfehlung des Huts (Chef 21:3x).

## Zentrale und Niederlassung

Die Zentrale (Toms Account, Max) und die Niederlassung (zweiter Account, Pro) stimmen sich **nur über `main`** ab, wie über eine gemeinsame Ablage: Vorräte, Besetzung, Notizen. Grund: eine Sitzung sieht die Sitzungen des anderen Accounts nicht. Grundlage D11.1 und 99f.

| Fall | Wer merkt es | Was geschieht |
|---|---|---|
| **Normalbetrieb** | – | Ford 2 startet eine Sitzung von Team Jerry, wenn dessen Vorrat offen ist und keine läuft; meldet seine Starts selbst lautlos und schreibt Jerrys Zeilen in `ARBEIT-BESETZUNG.md`. Ford startet kein Team Jerry. |
| **Guthaben auf Pro leer** | Jerry meldet es selbst (Zeile im Vorrat, Telegram) | Ford holt Team Jerry in die Zentrale, wenn Max Luft hat (Wochenstand `rate_limit_info`), und trägt die Sitzung in die Besetzung ein. Hat Max keine Luft, wartet Jerry bis zum Wochenwechsel, Ford sagt es dem Chef. |
| **Stiller Ausfall** (Jerry oder Ford 2 steht, keiner meldet) | Ford: 2 Stunden kein Commit von Team Jerry bei offenem Vorrat; gilt erst, wenn Ford 2 läuft, nie bei „Pause bis“ im Kopf von Jerrys Vorrat (D13.7); bis dahin startet der Chef Jerry von Hand | wie „Guthaben leer“ |
| **Rückkehr** | Ford: Pro hat wieder Guthaben (Meldung von Team Jerry oder vom Chef; Pro wechselt zu eigener Zeit, nicht Sa 21:00, D13.8) | Ford startet kein neues Team Jerry mehr; die laufende Sitzung beendet ihren Punkt mit Übergabe, dann übernimmt Ford 2. Ford 2 startet nie, solange die Besetzung eine Jerry-Sitzung der Zentrale zeigt (98.7). |

- **Voraussetzung:** Telegram-Schlüssel auf dem Pro-Account (Chef, Freitag), dann eine Probe `create_session` dort. Bis dahin startet der Chef Jerry von Hand.
- **Messung:** zwei Tage lang; Ford 2 schreibt nach jedem Lauf seine Kosten als Zeile in `ARBEIT-BETRIEB.md`, Sokrates Projekt wertet aus (von Max aus ist Pro nicht sichtbar). Kostet Ford 2 mehr als 10 % von Jerrys Woche, fällt er weg, und es gilt wieder „von Hand“.
- **Guthaben:** kein Aufstocken. Sokrates Projekt prüft beide Accounts vor der Verlängerung um den 10.11. (99e).

## Vorlage für jede Rollendatei

Feste Reihenfolge; was für eine Rolle nichts enthält, fällt weg. Abschnitte bis „Start“ und „Lehren“ zusammen unter 4 KB; das Handwerk darf länger sein, weil es nur bei passender Arbeit gelesen wird. Stand und Übergabe stehen nie in der Rollendatei, sondern im Vorrat (Chef 21:3x).

**Kopf** (`# <Rolle> (<Name>)`: Startwort, Account, Sitzungstitel, Vorrat) · **Wer du bist** · **Dein Maß** · **Was du tust** (Rahmen für „wie, entscheidest du selbst“) · **Entscheidet selbst** (nur Sokrates) · **Was du nicht tust** (je mit „gehört …“) · **Wen du ansprichst** · **Start** · **Handwerk** · **Begründungen** (nur wer entscheidet oder empfiehlt) · **Lehren** (höchstens fünf, je eine Zeile mit Datum und Nummer; ältere ins Archiv).

**Stärkstes Gegenargument zur Aufteilung** (98): drei Sokrates-Sitzungen kosten dreimal den Start, Fragen zwischen den Hüten brauchen eine Übergabe statt eines Gedankens. Dagegen: jede Sitzung liest weniger, und an den meisten Tagen braucht es nur einen Hut. Prüfen bei der Bilanz am 23.10.
