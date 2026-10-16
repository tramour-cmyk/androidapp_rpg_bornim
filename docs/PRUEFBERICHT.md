# Prüfbericht Diogenes

Befunde von Diogenes (`ROLLE-PRUEFUNG.md`, Aufbau in `LISTE-PRUEFUNG.md` „Prüfbericht“). Jeder Befund ist ein **Verdacht**, bis der Zuständige ihn bestätigt; Vermerke („bestätigt“, „behoben“, „verworfen“ mit Grund) schreibt er unter den Befund. Neuester Lauf oben. Seit 16.10. im Repo (99g); **Lauf 1–21** stehen im abgelösten [Artefakt](https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ), offene Befunde daraus in den Vorräten.

## Offen für den Chef

**Umbau 106.1 (Lauf 22):** hat funktioniert. D22.1 (Ford startete Homer nicht für Muss-Zeilen) ist behoben. Nichts am Gerät anzusehen.

## Lauf 22 · Geprüft

**Auftrag:** **106.1 Nachprüfung Samstagsumbau** (Zeile von Perikles 16.10., 22:0x; Chef: „am Schluss muss Diogenes einmal wieder drüber prüfen, ob alles funktioniert hat“; Start durch Ford 22:32): Rollendateien nach Muster, Kennzahlen mit Quelle, Namen (117, 125), Zuordnung aller Vorgänge (124, 126), Wochenziel, Verweise und Werkzeuge; startet jede Rolle richtig?

**Stand:** `main` 5338741b (Umbau b37fff95, ein Commit, 54 Dateien)

**Wann:** 16.10., 22:33–22:4x

**Wie:** Nur lesen, keine Standbilder, keine Agenten. Gegen `VORGANGSARCHIV.md` 106.1, 117, 122, 99g.1 und die Vorlage in `FIRMA.md` „Vorlage für jede Rollendatei“. Maschinell: alle sechs `ROLLE-…` (Abschnitte, Größe bis „Start“, Rest, Zahl der Lehren); jede Zeile aller sechs Vorräte gegen `LISTE-VORGAENGE.md` (Nummer, Klasse, Stand); Kopfzahlen gegen gezählte Zeilen; Muss-Zeilen gegen das Wochenziel; `git grep` nach allen alten Datei- und Rollennamen in `CLAUDE.md`, `docs/`, `tools/`, `.claude/`, `.github/`; alle relativen Links in allen `.md`; Abschnittsverweise „Datei ‚Abschnitt‘“. Werkzeuge ausgeführt: `notiz.sh`, `check-env.sh` (9 von 9), `story.sh`, `zug-index.py` (in einer Kopie, „unverändert“); Haken (`weiter-`, `zug-`, `neustart-haken.py`, `.claude/settings.json`) und `meldung.sh` (`cs:`/`dz:`) gelesen. Start jeder Rolle: Kopf und „Start“ jeder Rollendatei gegen vorhandene Dateien und Abschnitte; Fords Startregeln (`ROLLE-BETRIEB.md`, `LISTE-BETRIEB.md` 4, 11, „Neustart auf Meldung“) gegen die Vorräte.

**Nicht geprüft:** **Echte Starts** außer diesem (Diogenes): Perikles, Homer, Sokrates, Ford 2 und Jerry sind seit dem Umbau nicht gestartet. **Pro**: keine Sicht. **Code-Kommentare** mit alten Namen (`Chronicle.kt`, `Intro.kt`, `Story.kt`, `IntroSound.kt`: `STORY-K1.md`): stehen schon als Zeile 117 bei Tom. **Inhalt** der Rollendateien Satz für Satz gegen das Vorgangsarchiv nur stichprobenweise; Wochenzählung und Tagesrückblick erst im Betrieb (Mo 26.10. bzw. ab 18.10.). GitHub-Action nicht ausgelöst (keine Änderung in `docs/chefsache/`).

**Urteil:** **Der Umbau hat funktioniert, mit einer Lücke, die das Wochenziel anhält.** Alle sechs Rollendateien folgen der Vorlage und ihren Größen, jede Rolle hat eine Kennzahl mit Quelle und Zähler, alte Namen sind aus Regeln und Werkzeugen verschwunden, alle Links und Abschnittsverweise treffen, die Werkzeuge laufen, jede Vorratszeile trägt M oder K. Aber Ford startet Homer und Perikles nach seiner Rollendatei nur für „A“, und Homer hat zwei Muss-Zeilen des Wochenziels ohne „A“ (D22.1). Dazu fehlt den Befundzeilen ein Vorgang, damit fehlen Kosten und Bereich (D22.2), und Liste und Vorräte widersprechen sich bei sieben Nummern (D22.3).

## Lauf 22 · Befunde

- **D22.1** (hoch) **Homer hat zwei Muss-Zeilen des Wochenziels, Ford startet ihn dafür nicht**

  126, 128, D21.1 · sicher (Text). `ROLLE-BETRIEB.md` „Was du tust“: „Homer und Perikles für eine Zeile mit ‚A‘, auf Neustart-Meldung oder Zuruf“. `ARBEIT-KREATIV.md` hat „Muss 2, A 0“: **39** (39.2 Wortlaut Schwierigkeitsgrad) und **112** (Intro als Muster, Abweichungsliste Tempel); beide stehen im Wochenziel 18.–24.10. (`LISTE-ABNAHME-KAPITEL1.md`: „39 … Jerry, Homer (39.2 Wortlaut)“, „112, 68 … Homer, dann Tom“). Homers Übergabe sagt dasselbe („Ford startet Kreativ nur für eine Zeile mit ‚A‘“). Folge: Ford startet Homer nach dem Sparmodus nie von selbst; 39 (Build nach 39.2) und 68 (nach 112) warten bis Sa 24.10. auf einen Zuruf. Zugleich widerspricht es `LISTE-BETRIEB.md` 4 („Erst Muss, dann Kür … je Rolle“) und der Kennzahl Stillstand (startbares Muss ohne Sitzung), die Ford dann nicht als Stillstand zählt, weil seine eigene Regel Homer nicht für startbar hält.

  Klasse 2, an Perikles (Abläufe, eine Stelle, Vorentscheid möglich) · Empfehlung: in `ROLLE-BETRIEB.md` „für eine Zeile mit ‚A‘“ ersetzen durch „**für eine Muss-Zeile oder eine mit ‚A‘**“ (eine Regel enger statt neu), Homers Übergabe danach berichtigen. Stärkstes Gegenargument: Homer und Perikles sollten seltener laufen (D13.1, Guthaben). Dagegen: Muss sind höchstens etwa acht Nummern je Woche, und genau die sollen laufen; Kür bleibt gesperrt.

  **Vermerk:** behoben 16.10., 22:56 (Perikles, 106.1a, Chef „106.1a ja“): `ROLLE-BETRIEB.md` „für eine Muss-Zeile oder eine mit ‚A‘“; im Sparmodus weiter nur auf Zuruf.

- **D22.2** (mittel) **Befundzeilen haben keinen Vorgang: Kosten, Bereich und Klasse fallen heraus**

  124, 126, `CLAUDE.md` „Nummern“ · sicher (gezählt). In den Vorräten stehen Zeilen **D21** (Tom, Jerry, beide M), **D3** (Jerry, zweimal), **D1** (Jerry) und „Woche“ (Diogenes); `LISTE-VORGAENGE.md` hat für keine davon eine Zeile. Ford trägt die Kosten „in die Spalte ‚Kosten‘ seines Vorgangs“ ein (`LISTE-BETRIEB.md` „Neustart auf Meldung“); für „Jerry – D3 Kampfgeheul“, das gerade läuft, gibt es keine. Dann fehlen sie in „Kosten je Hauptthema“ und im „Anteil Muss“ (Kennzahl Perikles), ohne dass es auffällt (wie D18.5). Auch Diogenes' eigene Läufe (Q) haben außer 106 keinen Ort.

  Klasse 2, an Perikles · Empfehlung: eine Zeile je Befundlauf in `LISTE-VORGAENGE.md` (z. B. „D3 · Befunde Lauf 3 · E Klang · K“, „D21 · Abgleich · B Abläufe · M“), dazu „Diogenes · Prüfläufe · Q“ wie die Zeile „Betrieb“ für Ford.

  **Vermerk:** behoben 16.10., 22:56 (Perikles, 106.1a): Zeilen D1, D3, D21, Woche in `LISTE-VORGAENGE.md`; eine eigene Zeile „Prüfläufe“ nicht, Diogenes-Läufe tragen die Nummer ihres Auftrags.

- **D22.3** (mittel) **Liste und Vorräte widersprechen sich bei sieben Nummern**

  124, 126, 65.4 · sicher (gezählt). In `LISTE-VORGAENGE.md` „erledigt“ mit Klasse „–“, im Vorrat aber offen: **9** (9i, Jerry), **19** (19e, Jerry; der Meilenstein verlangt „‚Bewegungen unrund‘ (19e) geklärt“), **59** (59e, Jerry und Homer), **117** (Rest bei Perikles und Tom), **102** (Rest bei Perikles). **38** ist in der Liste M, in `ARBEIT-KREATIV.md` K. **72** heißt in der Liste „Profil und Marktvergleich“ (E Kampf, Vorrat „Sokrates mit Nutzer“), im Vorrat Homers „Profil und Kampfsystem“. Kosten auf einen „erledigten“ Vorgang mit Klasse „–“ zählen weder als Muss noch als Kür. Dazu 9i und 19e „wartet auf Chef“ ohne Datei in der Chefsache, gegen D21.2.

  Klasse 1, Perikles (Liste) · Empfehlung: Stand und Klasse der sieben Zeilen an die Vorräte angleichen („in Arbeit“, K); 9i und 19e auf „wartet auf \<was\>“ oder „ruht“ (Jerry, nach der Pause)

  **Vermerk:** behoben 16.10., 22:56 (Perikles): 9, 19, 59, 72, 102, 117 angeglichen; 38 stimmt (Homers Teil Kür, Wochenziel Jerry und Diogenes). 9i und 19e bleiben bei Jerry.

- **D22.4** (mittel) **Story-Verzeichnis nennt für neue Kapitel noch das alte Namensmuster**

  117, 41 · sicher. `STORY-REGELN.md:14`: „je Kapitel `STORY-K<n>.md` (H, N, Z) und `STORY-K<n>-W.md` (Welt)“. Nach 117 heißen sie `STORY-K1-HANDLUNG.md` und `STORY-K1-WELT.md`. Wer Kapitel 2 anlegt (41, 72s.1), legt `STORY-K2.md` an; der Wächter in `notiz.sh` kennt nur die alten K1-Namen und schweigt.

  Klasse 1, Homer (Story-Verzeichnis) · Empfehlung: Muster auf `STORY-K<n>-HANDLUNG.md` / `-WELT.md`

- **D22.5** (klein) **Reste: „Beschlüsse“, Kopfzahlen, Übergabe Homer**

  99g.1, 65.4 · sicher. (a) 99g.1: „Das Wort ‚Beschlüsse‘ wird in Regeln … ersetzt“; steht noch in `ROLLE-PROJEKT.md:31` („im Rahmen der Beschlüsse“) und `LISTE-NIEDERLASSUNG.md:22` (Freigabeliste: „Beschlüsse … alles Entschiedene“; Pro liest damit das abgelöste Artefakt statt `VORGANGSARCHIV.md`). (b) Kopfzahlen: Jerry „offen 16“ bei 17 Zeilen (D3 zweimal), Homer „offen 13“ bei 14. (c) Homers Übergabe nennt „39.1 auf Chefsache gestellt“; 39.1 ist entschieden, die Datei weg (richtig nach 63), die Übergabe ist alt. (d) 106 trägt 10,75 \$ vom 16.10., die Spalte sagt „Summe ab 17.10.“; für die erste Wochenzählung ohne Vorwoche zähle ich ab 17.10. aus `git log`.

  (a), (b) Perikles; (c) Homer beim nächsten Start; (d) kein Handlungsbedarf, nur vermerkt

  **Vermerk:** (a), (b) behoben 16.10., 22:56 (Perikles).

**In Ordnung:** Alle sechs Rollendateien mit Kopf (Startwort, Account, Titel, Vorrat, Handwerk) und den Abschnitten der Vorlage in fester Reihenfolge; bis „Start“ 2,9–3,8 KB (Grenze 4 KB), Begründungen und Lehren 0,4–1,6 KB (Grenze 2 KB), höchstens fünf Lehren. Jede Rolle eine Kennzahl mit Quelle und „Diogenes zählt“ (Perikles und Diogenes je ein Paar, wie D18 empfahl); Wochenzählung mit Quellen in `LISTE-PRUEFUNG.md`, Montagsstart in `LISTE-BETRIEB.md` 11. Namen: Perikles, Homer, Sokrates überall in Regeln, Tabellen und Haken; „Dein Zug“ nur noch im Archiv, Vorgangsarchiv und einem Kommentar in `tools/klang/huehner.py`; alle umbenannten Dateien nur noch im Wächter von `notiz.sh`. `docs/chefsache/` mit Übersicht aktuell, `meldung.sh` führt `cs:` und `dz:` dorthin. Jede Vorratszeile trägt M, K oder M?; alle Muss-Zeilen stehen im Wochenziel oder sind „jetzt“ (106.1, D21). Wochenziel mit Satz, Termin und Nummernliste (D19.2). Alle relativen Links treffen (außer drei alten im `CHANGELOG.md`, Verlauf). Inhaltsverzeichnis `docs/README.md` nach 122. Vorräte alle unter 10 KB.

**Nachprüfung früherer Befunde:** D16.1 behoben (`LISTE-RELEASE-NEUSTART.md` 2 „nur bis Tiefe 6“). D18.1 erledigt (Umbau vorgezogen, ein Termin). D19.2, D19.3, D20.3 behoben. D21.1 und D21.2 in `CLAUDE.md` 4 und „Wo was steht“. **D21.3 offen**: `zug-index.py` gleicht noch nicht ab (Zeile D21 bei Tom, Start nach dem Max-Wechsel).

## Kosten

Lauf 22: etwa 200.000 Token (davon rund 100.000 für das Lesen des Artefakts), kein Standbild, keine Agenten; vier Befunde der Klasse 1 und 2, einer klein. Frühere Läufe im Artefakt.
