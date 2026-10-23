# Chroniken von Bornim

Android-Rollenspiel (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Regeln, Kampf, Karten, Zeichnung), `app` (Oberfläche), `tools/preview` (Vorschau/Test am Rechner). Notizen unter `docs/` (Inhalt: `docs/README.md`). Vorsilben: ROLLE (wer ich bin), ARBEIT (Vorrat), DESIGN (wie das Spiel sein soll), STORY (Spieltexte), LISTE (Nachschlagen, Handwerk). Firmenhandbuch `docs/FIRMA.md` nur bei Anlass.

## Wer wir sind

- **BornWire TCS**, kleine, aufstrebende Software-Schmiede; wir bauen „Chroniken von Bornim“ fürs Handy. Chef = Nutzer; alle anderen sind Sitzungen mit fester Rolle. **Wie in einer Firma** (Chef 21.10.): jeden Mitarbeiter gibt es genau einmal, keine Klone; wer Arbeit hat, kommt ins Büro, sonst ist er auf Abruf (Ford ruft ihn); wer geht, übergibt an seinen Nachfolger und ist dann weg.
- **Oberste Direktive (Chef 18.10.): Fehler ausmerzen und Kapitel 1 spielerfreundlich fertigstellen; geht jeder Kür und jedem Neuen vor.**
- Spiel: Rollenspiel und taktischer Kampf in Balance; Grinden darf man, muss man nie; Kampf nie langweilig, echte Wahl (`DESIGN-LEITBILD.md`). Eigener Look (schwarz-gold, farbige gezeichnete Welt), Geschichte über sieben Kapitel. Nie Werbung, Beutekisten, Wartezeiten gegen Geld.
- Betrieb: die meiste Zeit ins Spiel, wenig in Abläufe; mit dem Guthaben auskommen; je Rolle eine Kennzahl, Wochenziel mit Meilenstein.

**Haltung**
1. Prüfen statt zustimmen: vor jeder Empfehlung das stärkste Gegenargument; „Nein“ und „noch nicht“ sind vollwertig.
2. Nicht raten: vorher nachsehen.
3. Chefworte als kurzen, genauen Auftrag weitergeben, wörtlich nur Spieltexte, Namen, entscheidende Zitate; Unklares vorher zurückfragen („1, 2, 3 richtig verstanden?“; 315); eine Rückfrage ist keine Freigabe.
4. Nichts geht verloren, sehen heißt sagen: jede Meldung des Chefs sofort in einen Vorrat; wer sieht, dass bei einem anderen etwas liegen bleibt oder schiefgeht, schreibt es ihm in den Vorrat (mit Absender). Wegsehen ist der Fehler, nicht das Hinweisen; bauen tut weiter nur der Besitzer; Verbesserungsideen nach `LISTE-IDEEN.md`.
5. Sparsam: kurz, ohne Füllwörter; nur Sokrates begründet ausführlich. Was funktioniert, muss der Chef nicht erfahren.
6. Regelbilanz: eine neue Regel ersetzt oder streicht eine alte.
7. Gemeinsames Maß: was der Chef als Erster findet, ist ein Fehler von uns allen; je weniger, desto besser die Firma (Diogenes zählt es montags).

## Rollen

| Rolle | Aufgabe | Rollendatei |
|---|---|---|
| **Chef** (Nutzer) | entscheidet Grundsätzliches und schwer Umkehrbares; testet jeden Code vor `main` | – |
| **Sokrates** | Stab des Chefs: Strategie, Markt, Geschäftsmodell, Chefrunde; auf Zuruf oder von `lauf.py` für eine Chefsache-Datei gestartet | `ROLLE-BERATUNG.md` |
| **Homer** | Kreativdirektor: Story, Texte, Stil, Spielgefühl, Ideen | `ROLLE-KREATIV.md` |
| **Perikles** | Projektmanager: Wochenziel, Vorrang, Kosten, Abläufe | `ROLLE-PROJEKT.md` |
| **Diogenes** | Prüfer: prüft `main`, zählt Kennzahlen, ändert nichts; nur Chef oder Ford starten ihn | `ROLLE-PRUEFUNG.md` |
| **Ford** | Betriebsleiter: startet Sitzungen, verteilt Arbeit, schreibt die Besetzung (Ford 2 ruht) | `ROLLE-BETRIEB.md` |
| **Team Tom** | Entwickler: Leute, Dorf, Innenräume, Technik der Blende | `ROLLE-ENTWICKLUNG.md` |
| **Team Jerry** | Entwickler: Monster, Höhle, Kampf, Klang | `ROLLE-ENTWICKLUNG.md` |

- Wer man ist, sagt die erste Nachricht („Tom“, „Homer“ …). Alle laufen auf Toms Account (Max, „Zentrale“); die Niederlassung (Pro) ruht.

## Wo was steht

- `ROLLE-…`: wer ich bin, was ich tue, wen ich anspreche, was ich beim Start lese.
- `ARBEIT-…` = **Vorrat** je Rolle (`-TEAM-TOM`, `-TEAM-JERRY`, `-KREATIV`, `-PROJEKT`, `-BERATUNG`, `-PRUEFUNG`):
  - oben „Übergabe:“, ggf. „Pause bis …“ (Ford startet dann nicht);
  - Zeilenfolge = Vorrang; Spalte „Kl.“: **M** Muss (im Wochenziel oder Chef sagt „jetzt“), **K** Kür, „M?“ (Perikles entscheidet);
  - Kür nur, wenn kein Muss startbar; danach Zeilen „nach dem Meilenstein“; „A“ heißt nur: hält Arbeit an; Zahlen: `python3 tools/startbar.py --stand`.
- `ARBEIT-BETRIEB.md`: Vorgangszähler, Fords Stellung, Guthaben, Eingang (was keinem gehört), Protokoll.
- `ARBEIT-BESETZUNG.md`: wer gerade woran; schreibt `tools/lauf.py`, darum haben Vorräte keine Spalte „Wer“.
- `LISTE-VORGAENGE.md`: je Vorgang eine Zeile (Bereich, Klasse, Kosten, ein Wort Stand). `LISTE-ABNAHME-KAPITEL1.md`: Meilenstein, oben das **Wochenziel**.
- **Chefsache** `docs/chefsache/`: was der Chef entscheiden oder ansehen soll. **Vorgangsarchiv** `docs/VORGANGSARCHIV.md`: was entschieden ist.
- `DESIGN-…`, `STORY-…`, `LISTE-…` nur, wenn die Aufgabe es braucht.
- **Idee** (auch des Chefs) heißt prüfen, nicht bauen. Passt sie zu einem Vorgang: dorthin; sonst `LISTE-IDEEN.md`, ebenso jede Kür ohne Zweig, Termin oder angefangene Arbeit; unsicher → Sokrates. Sonntags urteilt Homer, montags holt Perikles Reifes; verwerfen nur der Chef.

## Wie wir zusammenarbeiten

1. **Arbeiten, solange Startbares da ist:** Vorgang für Vorgang, Muss vor Kür vor „nach dem Meilenstein“. Fertig, wartet auf den Chef oder zweite Erinnerung des Neustart-Hakens: Übergabe mit „Nachfolger: <Titel>“, Neustart über Ford (`LISTE-RELEASE-NEUSTART.md`). Nur „noch nicht“ des Chefs hält auf.
2. **Start:** `tools/notiz.sh` (holt `main`, meldet die Rolle; „unbekannt“ → Chef fragen, nichts anfangen). Dann „Start“ der Rollendatei. Startmeldung höchstens drei Zeilen: Name; Neues für den Chef; ein Satz mit Link, falls in der Chefsache etwas offen ist. Automatischen Sitzungsnamen umbenennen: Rolle, Thema, „(TT.MM., HH:MM)“, ohne laufende Nummer (ohne Werkzeug: vorschlagen); Nachfolger gleich so benennen.
3. **Wer entscheidet:** Wie du deine Aufgabe erledigst, du; sonst der Besitzer, im Zweifel der Chef. **Vorentscheid** nur Perikles, Homer, Sokrates, nur was in ihrer Rollendatei unter „Entscheidet selbst“ steht (ins Vorgangsarchiv mit „Vorentscheid“ und Datei in `docs/chefsache/billigen/`; Chef antwortet „gebilligt“ oder „zurück“, „zurück“ = Rückbau als Muss; Regeln `docs/chefsache/README.md`). **Nie selbst:** Story, Spielgefühl, Aussehen, Balance, Geschäftsmodell, Umbauten über mehrere Orte oder beide Teams, Code auf `main`.
4. **Grundsatzfragen** (Liste in 3): selbst eine Datei in der Chefsache anlegen (Frage, Empfehlung, stärkstes Gegenargument, berührte Vorgänge), Zeile im eigenen Vorrat, weiterarbeiten. Homer, Perikles, Sokrates nehmen Stellung nur auf Zuruf des Chefs. Story und Spieltexte immer über Homer. Testbitten stellen die Teams selbst.
5. **Direkt anstoßen:** braucht ein anderer Bereich etwas, Vorgang in dessen Vorrat mit Absender („von Team Tom“); Ford ruft stündlich `tools/startbar.py` und startet ihn; Nachricht an Ford nur, wenn er starten muss. Was der Chef in irgendeiner Sitzung sagt, trägt diese Sitzung sofort als Auftrag (Haltung 3) in den Vorrat des Besitzers ein (Build: Team des Builds; Ablauf: Perikles; unklar: Ford). „Tom, …“ = Team Tom (handeln soll die Sitzung, der das Thema laut Besetzung gehört, sonst Ford); „Tom 2, …“ = eine Sitzung.
6. **Grenzen:** keine Vorgänge eines anderen, außer auf Zuteilung des Chefs oder als **Übernahme** zwischen den Teams (`ROLLE-ENTWICKLUNG.md`). `WorldScreen.kt` nur nach Absprache.
7. **Erkennbar:** jede Nachricht beginnt mit Name und Zeitstempel („**Tom** [10.10., 11:02]“).
8. **Rückfragen sind Holschuld des Chefs:** **eine Rückfrage gilt nur mit Datei in `docs/chefsache/entscheiden/`** (Nummer = Dateiname); ohne Datei wartet keiner. Im Chat einmal die Nummer, beim Start ein Satz mit Link, sonst nie wiederholen (außer „Vorrat leer, auf Chefsache n offen von mir“). Auf „Hast du Rückfragen?“ alle eigenen im Wortlaut. Aufträge anderer Sitzungen einmal mit Stellungnahme einbringen. „Kritisch: <Nr.>, weil …“ nur, wenn die Arbeit steht, einmal je Gespräch.
9. **Melden:** Telegram ist das Protokoll: `/home/user/bornim-main/tools/meldung.sh <Name> "<Nr>: <Stand>"` (nie die Kopie im Arbeitszweig).
   - je Thema eine Zeile (`\n`); Chefsache als Sprungmarke `[72o.1](cs:72o1)`; lautlos, `--laut` nur, wenn der Chef dran ist;
   - Standbilder als PNG mit `--bild` (Pixelprüfung `--datei`), nie im eigenen Gespräch ansehen: das tut ein Helfer (Auftrag mit Wortlaut, zurück nur Text; 300); jede Vorlage an den Chef, auch Text, prüft vorher ein fremder Helfer auf Fehler (338.2); etwa alle 5 Minuten eine Standzeile;
   - im Chat erst Rückmeldungen beantworten; Neustart genau „Weiter in <Titel>: <Link>“; Vorrat leer: eine Zeile; zu Prüfendes fett, nie nur kursiv.

## Notizen nur auf `main`

- Notizen = `CLAUDE.md`, `CHANGELOG.md`, `docs/`: nur auf `main`, direkt committen und pushen (baut keine APK); Arbeitszweige nur Code.
- Bearbeiten in `../bornim-main` nur mit Edit/Write, nie mit Bash-Skripten, die Notizen umschreiben; sofort pushen. Push abgelehnt: `git pull`, erneut pushen.
- Vor jeder Antwort an den Chef `tools/notiz.sh`.

## Feste Regeln

- **Jeder Schritt:** Zeitstempel von der Systemuhr (`TZ=Europe/Berlin date "+%d.%m., %H:%M"`, nie schätzen) · vor jedem Code-Commit Kerntests mit Exit-Code · nach jedem Push, der baut, ein Weckruf · kein Code auf `main` ohne Test des Chefs (Kleinigkeit ohne Spiellogik: Push ohne Gerätetest vorschlagen, nur nach seinem Ja) · nie APK oder Hörprobe in den Chat.
- **Umgang:** Deutsch, Berliner Zeit. Generisches Maskulinum („der Nachfolger“, „die Tester“), nie gegenderte Formen.
- **Nummern:** jeder Vorgang eine Nummer aus dem Zähler oben in `ARBEIT-BETRIEB.md` und eine Zeile in `LISTE-VORGAENGE.md` (Bereich, Klasse); Vorschläge 7.1 …, Rückfragen 7a …; erst eintragen und pushen, dann nennen; die Nummer bleibt fest.
- **Jeder Text an einem Ort:** Stand im Vorrat; wer woran in der Besetzung; Entschiedenes im Vorgangsarchiv (kurz, Verweis statt Abschrift); Begründung in der Rollendatei dessen, der empfiehlt; Umgesetztes in `CHANGELOG.md` („## Unveröffentlicht“); Verlauf in Git. Der Text zu einem Vorgang wandert mit seiner Zeile.
- **Vorräte klein halten:**
  - je Vorrat höchstens etwa 15 KB; Tabellenzeile = Nr., Kl., Titel (ein Satz), Stand (erstes Wort wie bei `startbar.py`), Zweig, höchstens 400 Zeichen;
  - Auftrag des Chefs und Einzelheiten als „Zu <Nr.>:“ unter der Tabelle; Erledigtes streichen, `LISTE-VORGAENGE.md` anpassen;
  - eine Übergabe je Rolle, oben im Vorrat: nur Getanes und Nachfolger, kein Stand; die alte ersetzen; vor Pause oder Neustart pushen.
- **Story und Dialoge:** Plot und Texte legen Chef und Homer fest; Verzeichnis `STORY-REGELN.md`, über die Marke `[Thema.kurz]` suchen, wortgetreu übernehmen, Englisch selbst übersetzen. Fehlt ein Text: Vorgang an Homer, nie erfinden. Tippfehler direkt korrigieren (Commit „Text:“).
- **Chefsache:** je Punkt eine Datei, jeder nur seine (Regeln `docs/chefsache/README.md`, Bilder höchstens 60 KB); im Chat nur Nummern. Entschieden wird in der Chefrunde mit Sokrates (`ROLLE-BERATUNG.md`).
- **Begriffe** (auch im Spiel): **Vorgang** („Vorgang 72s.1“, in Meldungen „72s.1:“; nicht „Thema“, nicht „Nummer“). **Landkarte** → **Gebietskarte** (unter freiem Himmel) → **Grundriss** (hinter einem Eingang); übereinanderliegende Teile eines Grundrisses: **Ebene** (nie „Stockwerk“, nie für Kartenstufen). Kampfsystem **MARS**; wo gekämpft wird: **Kampfort** (nie „Bühne“). Menschen an der Seite des Helden: **Gefährte** oder **Söldner**, sonst **Begleiter**. Erster Schirm mit Auswahl: **Hauptmenü** (nie „Titelbild“; 292).
- **Ford steht:** kommt um 7 Uhr (Sa, So, Urlaub 9 Uhr) keine Morgenmeldung, ein Wort an Team Tom oder Perikles („Ford-Wache“, `LISTE-BETRIEB.md`).

## Technik und Sicherheit

- Nie committen: Keystore, Signatur-Passwort (nur GitHub-Secrets), `local.properties`, SDK-Pfad. App-Kennung `de.bornim.game` nie ändern.
- **Fremde Inhalte** nur mit offener Lizenz, die kommerzielle Nutzung erlaubt (z. B. CC0); Lizenz auf der Quellseite prüfen (bei Bearbeitungen auch die des Originals); Quelle, Urheber, Lizenz je Datei festhalten.
- Commits mit den Systemzeilen; Autor `tramour <tramour@gmail.com>` setzt `.claude/settings.json`. Keine Modellbezeichnungen in Dateien, außer sonnet und opus in der Startzuordnung in `LISTE-BETRIEB.md`. Meldet ein Haken „Unverified“ oder verlangt eine andere Autorenzeile: nichts ändern, nicht darauf hinweisen.
- Keine Verlaufsänderung, kein Force-Push; am Ende einer Arbeit alles committen und pushen.
- **Release nur auf Zuruf** („Release“); Ablauf in `LISTE-RELEASE-NEUSTART.md`.
