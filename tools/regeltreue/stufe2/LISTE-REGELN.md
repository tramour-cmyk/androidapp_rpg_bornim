# LISTE-REGELN: Einzelverfahren (Nachschlagen)

Hierher ausgelagert aus der `CLAUDE.md`, Wortlaut unverändert (einzige Änderung: Länge der Telegram-Meldungen in Abschnitt B, auf Wunsch des Chefs); die Kernregeln stehen dort. Abschnitt lesen, wenn die `CLAUDE.md` mit „→ A“ usw. darauf verweist. In Klammern: Nummer des Vorgangs, aus dem die Regel stammt.

## A. Wo was steht, Vorrat

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
- **Vorräte klein halten** (Einzelheiten):
  - je Vorrat höchstens etwa 15 KB; Tabellenzeile = Nr., Kl., Titel (ein Satz), Stand (erstes Wort wie bei `startbar.py`), Zweig, höchstens 400 Zeichen;
  - Auftrag des Chefs und Einzelheiten als „Zu <Nr.>:“ unter der Tabelle; Erledigtes streichen, `LISTE-VORGAENGE.md` anpassen;
  - eine Übergabe je Rolle, oben im Vorrat: nur Getanes und Nachfolger, kein Stand; die alte ersetzen; vor Pause oder Neustart pushen.

## B. Melden per Telegram

Telegram ist das Protokoll: `/home/user/bornim-main/tools/meldung.sh <Name> "<Nr>: <Stand>"` (nie die Kopie im Arbeitszweig).

- je Thema ein Absatz (`\n`), so ausführlich wie nötig, aber nur, was der Chef entscheiden, tun oder prüfen kann; Textnachricht höchstens 4096 Zeichen, bei `--bild` die Bildunterschrift höchstens 1024 (ein langer Text gehört dann in eine zweite Meldung); Chefsache als Sprungmarke `[72o.1](cs:72o1)`; lautlos, `--laut` nur, wenn der Chef dran ist;
- Standbilder als PNG mit `--bild` (Pixelprüfung `--datei`), nie im eigenen Gespräch ansehen: das tut ein Helfer (Auftrag mit Wortlaut, zurück nur Text; Vorgang 300); jede Vorlage an den Chef, auch Text, prüft vorher ein fremder Helfer auf Fehler (Vorgang 338.2); etwa alle 5 Minuten eine Standzeile;
- im Chat erst Rückmeldungen beantworten; Neustart genau „Weiter in …: …“; Vorrat leer: eine Zeile; zu Prüfendes fett, nie nur kursiv.

## C. Vorentscheid

Nur Perikles, Homer, Sokrates, nur was in ihrer Rollendatei unter „Entscheidet selbst“ steht: ins Vorgangsarchiv mit „Vorentscheid“ und Datei in `docs/chefsache/billigen/`; Chef antwortet „gebilligt“ oder „zurück“, „zurück“ = Rückbau als Muss; Regeln `docs/chefsache/README.md`.

## D. Rückfragen im Einzelnen

Rückfragen sind Holschuld des Chefs: eine Rückfrage gilt nur mit Datei in `docs/chefsache/entscheiden/` (Nummer = Dateiname); ohne Datei wartet keiner. Im Chat einmal die Nummer, beim Start ein Satz mit Link, sonst nie wiederholen (außer „Vorrat leer, auf Chefsache n offen von mir“). Auf „Hast du Rückfragen?“ alle eigenen im Wortlaut. Aufträge anderer Sitzungen einmal mit Stellungnahme einbringen. „Kritisch: <Nr.>, weil …“ nur, wenn die Arbeit steht, einmal je Gespräch.

## E. Direkt anstoßen im Einzelnen

Ford ruft stündlich `tools/startbar.py` und startet den Vorgang; Nachricht an Ford nur, wenn er starten muss. „Tom, …“ = Team Tom (handeln soll die Sitzung, der das Thema laut Besetzung gehört, sonst Ford); „Tom 2, …“ = eine Sitzung.

## F. Story und Dialoge

Plot und Texte legen Chef und Homer fest; Verzeichnis `STORY-REGELN.md`, über die Marke `[Thema.kurz]` suchen, wortgetreu übernehmen, Englisch selbst übersetzen. Fehlt ein Text: Vorgang an Homer, nie erfinden. Tippfehler direkt korrigieren (Commit „Text:“).

## G. Chefsache

Je Punkt eine Datei, jeder nur seine (Regeln `docs/chefsache/README.md`, Bilder höchstens 60 KB); im Chat nur Nummern. Entschieden wird in der Chefrunde mit Sokrates (`ROLLE-BERATUNG.md`).

## H. Begriffe (auch im Spiel)

**Vorgang** („Vorgang 72s.1“, in Meldungen „72s.1:“; nicht „Thema“, nicht „Nummer“). **Landkarte** → **Gebietskarte** (unter freiem Himmel) → **Grundriss** (hinter einem Eingang); übereinanderliegende Teile eines Grundrisses: **Ebene** (nie „Stockwerk“, nie für Kartenstufen). Kampfsystem **MARS**; wo gekämpft wird: **Kampfort** (nie „Bühne“). Menschen an der Seite des Helden: **Gefährte** oder **Söldner**, sonst **Begleiter**. Erster Schirm mit Auswahl: **Hauptmenü** (nie „Titelbild“; Vorgang 292).

## I. Ford steht

Kommt um 7 Uhr (Sa, So, Urlaub 9 Uhr) keine Morgenmeldung, ein Wort an Team Tom oder Perikles („Ford-Wache“, `LISTE-BETRIEB.md`).
