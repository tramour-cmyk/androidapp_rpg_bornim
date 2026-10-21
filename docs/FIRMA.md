# BornWire TCS – Handbuch

Nur bei Anlass lesen. Leitlinien, Rollen, „Wo was steht“ und die Regeln der Zusammenarbeit stehen in `CLAUDE.md` (Vorspann, lesen alle). Grundlage: Wortlaute des Chefs zu 98, 99 und 106.1, Vorgangsarchiv 90, 90a, D11.1, 99f, 124–126, 128, Leitbild. Umgebaut 15.10. (98) und 16.10. (106.1); die Docs-Dokumente Firmenordnung und Rollenkonzept sind Stand vom 15.10., es gilt `main`.

## Organigramm

```
                       Chef (Nutzer)
        ┌────────────────┼─────────────────┐
  Sokrates (Berater,     │            Diogenes (prüft, zählt)
  nur Zuruf)             │
  Homer (Kreativ) ───────┤
  Perikles (Projekt) ────┤ (Wochenziel, Vorrang)
                         │
              Ford (Zentrale, Max)        Ford 2 (Niederlassung, Pro)
                         │                          │
                     Team Tom                   Team Jerry
```

Sokrates und Diogenes stehen neben der Linie: sie beraten und prüfen, verteilen keine Arbeit; beide laufen in der Zentrale. Teams, Homer und Perikles stoßen sich direkt über die Vorräte an; die Linie zeigt nur, wer startet und zuteilt. Ford 2 untersteht dem Chef, nicht Ford: Ford kann auf Pro nichts starten.

## Dateien je Rolle

Jede Sitzung liest beim Start `CLAUDE.md`, dann nur ihre Rollendatei und ihren Vorrat; ihr Handwerk (`LISTE-…`) nur, wo „Start“ es nennt.

| Rolle | Rollendatei | Vorrat | Handwerk, bei Bedarf |
|---|---|---|---|
| Team Tom, Team Jerry | `ROLLE-ENTWICKLUNG.md` | `ARBEIT-TEAM-TOM.md`, `ARBEIT-TEAM-JERRY.md` | `LISTE-BAUEN-TESTEN.md`; `STORY-…`, `LISTE-FIGUREN.md` |
| Sokrates (Berater) | `ROLLE-BERATUNG.md` | `ARBEIT-BERATUNG.md` (nur Aufträge des Chefs) | `DESIGN-LEITBILD.md` |
| Homer (Kreativ) | `ROLLE-KREATIV.md` | `ARBEIT-KREATIV.md` | alle `DESIGN-…`, `STORY-…`, `LISTE-IDEEN.md` |
| Perikles (Projekt) | `ROLLE-PROJEKT.md` | `ARBEIT-PROJEKT.md` | `startbar.py --stand`, `LISTE-VORGAENGE.md`, `LISTE-RELEASE-NEUSTART.md` |
| Diogenes | `ROLLE-PRUEFUNG.md` | `ARBEIT-PRUEFUNG.md` | `LISTE-PRUEFUNG.md` |
| Ford, Ford 2 | `ROLLE-BETRIEB.md` | `ARBEIT-BETRIEB.md` | `LISTE-BETRIEB.md`, `ARBEIT-BESETZUNG.md` |

Verlauf steht in Git; das alte `ARBEIT-ARCHIV.md` (bis 16.10.) und `LISTE-NIEDERLASSUNG.md` sind am 21.10. gelöscht, in Git bis `f3ec7200` (274).

## Vorrat, Vorrang, Wochenziel

Alle Vorräte sind gleich gebaut. Jede Zeile: Nummer, Vorgang mit Wortlaut des Chefs, Stand („Chefsache <Nr>“ oder „wartet auf <was>“, D21.2), gegebenenfalls „fertig, wenn …“, Zweig, dazu die **Klasse** (126):

- **M** (Muss): steht im Wochenziel oder der Chef sagt „jetzt“. **K** (Kür): alles andere. **M?**: wer anlegt, hält es außerhalb des Wochenziels für nötig (mit Halbsatz Grund); Perikles entscheidet beim nächsten Wochenziel, eilt es, der Chef. Einstufen ist kein eigener Schritt.
- Die **Reihenfolge der Zeilen ist der Vorrang**, Muss oben. Kür nur, wenn kein Muss startbar ist (auch keine Übernahme, 118); zuletzt, vor Leerlauf, Zeilen „nach dem Meilenstein“ (190.10). „A“ markiert nur, was Arbeit anhält.
- **Wochenziel:** Perikles setzt es montags, ein Satz plus Nummernliste mit Termin, abgeleitet aus dem Meilenstein, oben in `LISTE-ABNAHME-KAPITEL1.md`. Ford startet danach.

| Wer | Entscheidet |
|---|---|
| Bereich | legt Zeilen mit Klasse an, nennt „wartet auf“, stellt eigene Grundsatzfragen in die Chefsache (D21.1) |
| Perikles | Wochenziel und Reihenfolge der Vorräte, „M?“ |
| Ford | startet nach Wochenziel und Reihenfolge, Muss vor Kür; hält Anstöße und Befunde nach (107) |
| Chef | wann er will: „jetzt“, Zeile verschieben, umstufen |

## Hauptthemen und Kosten (124)

Jeder Vorgang hat in `LISTE-VORGAENGE.md` einen Bereich: Hauptthema und Unterthema.

| Kürzel | Hauptthema | Unterthemen |
|---|---|---|
| **E** | Entwicklung | Welt und Orte · Figuren und Monster · Kampf und Regeln · Klang · Oberfläche |
| **G** | Gestaltung | Story und Texte · Stil und Aussehen · Balance und Spielgefühl |
| **Q** | Qualität | QS: Builds, Prüflisten, Rückläufer · QM: Prüfläufe, Kennzahlen |
| **B** | Betrieb | Steuerung (Ford, Ford 2) · Abläufe und Notizen · Werkzeuge |
| **M** | Markt und Strategie | Beratung, Veröffentlichung |

**Preis je Vorgang:** Ford und Ford 2 lesen beim Neustart `usage.cost_usd` des Vorgängers und addieren es in der Spalte „Kosten“ (mehrere Vorgänge zu gleichen Teilen; Fords eigene Läufe auf Vorgang „Betrieb“; fehlt die Zahl, „fehlt“). Der Betrag ist der API-Preis, keine Rechnung (Max und Pro sind Pauschalen); als Maß für Anteile taugt er. Testzeit des Chefs ist nicht enthalten, dafür zählen Testrunden. Vier Augen: Ford erfasst, Diogenes zählt, Perikles bewertet.

## Kennzahlen (106.1)

Je Rolle eine Kennzahl (in der Rollendatei unter „Dein Maß“), dazu fünf Firmenkennzahlen: **Kosten der Woche** je Hauptthema und Anteil Spiel (E+G); **Guthaben** je Account gegen die Woche (vor Wochenmitte `allowed_warning` → nur Muss, D20.2); **Fortschritt Meilenstein** (Wochenziel erreicht, Pflichtpunkte Kapitel 1); **Testrunden des Chefs** und Rückläufer darunter; **ersparte Fragen** durch Vorentscheid (unter 5 je Woche fällt er weg, 98.2). Diogenes zählt montags (Tabelle im Prüfbericht, Quellen in `LISTE-PRUEFUNG.md`), Perikles bewertet im Wochenziel. Ausgangswert: Woche 18.–24.10.; Zielwerte danach (D19.4). Mehr Kennzahlen nicht: jede kostet Zählen.

## Wie Arbeit wandert

| Was | Wohin | Wer kümmert sich |
|---|---|---|
| Anstoß für einen anderen Bereich | Zeile im Vorrat des Bereichs, „von …“ | der Bereich; Ford hält das Alter nach (107) |
| Aufgabe, die noch keinem Bereich gehört | Fords Eingang in `ARBEIT-BETRIEB.md` | Ford teilt zu; sonst legt er sie im selben Lauf dem Chef vor |
| Grundsatzfrage | Datei in der Chefsache, angelegt von dem, der sie hat (D21.1); Story und Spieltexte über Homer | der Chef; Homer, Perikles, Sokrates nehmen auf seinen Zuruf Stellung |
| Prüfauftrag | `ARBEIT-PRUEFUNG.md`, dann `send_message` an Ford „Auftrag Diogenes <Nr>“ (von Pro aus nur die Zeile) | Ford startet Diogenes |
| Idee (auch des Chefs) | Zeile im Vorrat des Bereichs, Klasse K (115); lose Einfälle in `LISTE-IDEEN.md` | der Bereich prüft; gebaut wird nach Vorrang |
| Erledigtes | `CHANGELOG.md` unter „Unveröffentlicht“ | wer es erledigt hat |
| Entschiedenes | oben in `VORGANGSARCHIV.md` | wer die Datei in der Chefsache angelegt hat |
| Lehre für alle | Zeile unter „Lehren für alle“ in `ARBEIT-PROJEKT.md` | Perikles übernimmt sie in die passende Rollendatei |

**Abgrenzung Homer, Perikles, Sokrates** (125). Homer (`ARBEIT-KREATIV.md`): Spiel und Design (Story, Texte, Stil, Aussehen, Spielgefühl, Balance, Ideen). Perikles (`ARBEIT-PROJEKT.md`): Ablauf und Aufbau (Abläufe, Regeln, Umbauten, Wochenziel, Meilensteine, Vorrang, Kosten der Arbeit). Sokrates (`ARBEIT-BERATUNG.md`): nur Aufträge des Chefs (Markt, Geschäftsmodell, Strategie, Kosten-Nutzen des Produkts); kein Eingang für Teams.

## Zentrale und Niederlassung

Die Zentrale (Toms Account, Max) und die Niederlassung (zweiter Account, Pro) stimmen sich **nur über `main`** ab: Vorräte, Besetzung, Notizen. Grund: eine Sitzung sieht die Sitzungen des anderen Accounts nicht (D11.1, 99f).

| Fall | Wer merkt es | Was geschieht |
|---|---|---|
| **Normalbetrieb** | – | Ford 2 startet Team Jerry, wenn dessen Vorrat offen ist und keine läuft; meldet seine Starts selbst lautlos, schreibt Jerrys Zeilen in `ARBEIT-BESETZUNG.md`. Ford startet kein Team Jerry (außer bei ruhender Niederlassung, 159; dann auch keine Übernahme durch Tom). |
| **Guthaben auf Pro leer oder eingeteilt** (128) | Jerry meldet es selbst; eingeteilt: Ford 2 („Pause bis …“ oben in Jerrys Vorrat) | Team Tom übernimmt Jerrys Zeilen nach Regel 6 (118), **zuerst die Testergebnisse des Chefs** (Freigabe → PR zusammenführen, Rückläufer → beheben). Wer ein Ergebnis hört, trägt es sofort in Jerrys Vorrat ein. Hat Max keine Luft, wartet die Arbeit bis zum Wochenwechsel; Ford sagt es dem Chef. |
| **Stiller Ausfall** (Jerry oder Ford 2 steht, keiner meldet) | Ford: 2 Stunden kein Commit von Team Jerry bei offenem Vorrat, nie bei „Pause bis“ (D13.7) | wie „Guthaben leer“ |
| **Rückkehr** | Pro hat wieder Guthaben (Meldung Jerry oder Chef; Pro wechselt zu eigener Zeit, D13.8) | Ford 2 startet Jerry wieder; eine laufende Übernahme von Tom beendet ihren Punkt |

Ford 2 kostet höchstens 10 % von Jerrys Woche, sonst fällt er weg und der Chef startet Jerry von Hand (99f; gemessen über die Kosten je Vorgang). Abos: Perikles prüft beide Accounts vor der Verlängerung um den 10.11. (99e). Einrichten und Neueinrichten von Pro: `LISTE-NIEDERLASSUNG.md` aus Git (bis `f3ec7200`). **Ruht die Niederlassung** (Schalter in `ARBEIT-BETRIEB.md`, 159; Pro gekündigt 17.10.): Ford 2 und seine Regeln ausgesetzt, Jerry läuft in der Zentrale (`LISTE-BETRIEB.md`), Abo-Prüfung 10.11. nur Max.

## Sparmodus (99d, 102)

Ruft nur der Chef aus, mit Ende („Sparmodus bis <Zeit>“ oben in `ARBEIT-BETRIEB.md`). Solange gilt: die Teams arbeiten weiter, nur Muss; Homer, Perikles, Sokrates und Diogenes nur auf Zuruf des Chefs (Prüfaufträge nach einem Umbau gelten als Zuruf, wenn er sein Go gibt); kein Tagesrückblick, keine Wochenzählung; Ford startet keine Leihsitzungen und läuft als Co-Pilot. Zur genannten Zeit stellt Fords erster Lauf zurück, streicht die Zeile und meldet lautlos.

## Vorlage für jede Rollendatei (106.1)

Feste Reihenfolge; was für eine Rolle nichts enthält, fällt weg. Bis einschließlich „Start“ unter 4 KB, Begründungen und Lehren zusammen höchstens etwa 2 KB; Mechanik (Uhren, Kennungen, Test-Builds, Prüflisten) steht im Handwerk `LISTE-…`. Stand und Übergabe stehen nie in der Rollendatei, sondern im Vorrat.

**Kopf** (`# <Rolle> (<Name>)`: Startwort, Account, Sitzungstitel, Vorrat, Handwerk) · **Wer du bist** · **Gutes Ergebnis** (ein echtes Beispiel mit Vorgang) · **Dein Maß** (eine Kennzahl mit Quelle und wer zählt) · **Dein typischer Fehler** (einer, mit Vorgang) · **Was du tust** · **Entscheidet selbst** (nur Perikles, Homer, Sokrates) · **Was du nicht tust** (je mit „gehört …“) · **Wen du ansprichst** · **Start** · **Handwerk** (nur, wenn kurz) · **Begründungen** (nur wer empfiehlt) · **Lehren** (höchstens fünf, je eine Zeile mit Datum und Vorgang).

**Stärkstes Gegenargument zur Aufteilung** (98, 125): drei Stabssitzungen kosten dreimal den Start, Fragen zwischen ihnen brauchen eine Übergabe statt eines Gedankens. Dagegen: jede Sitzung liest weniger, an den meisten Tagen braucht es nur eine. Prüfen bei der Bilanz am 23.10.
