# Zentrale Vorgangsliste: Pro und Contra (275)

Sokrates, 21.10., 07:4x. Vorbereitung, nichts gebaut; umsetzen frühestens nach dem Meilenstein Kapitel 1 (Vorgangsarchiv 274).

**Chef 07:30** (gekürzt): „Angenommen, wir hätten jetzt eine Vorgangsdatei mit 10.000 Zeilen … jeder schreibt da bloß dahinter … das ist meins … Kannst du das gezielt suchen oder musst du immer alles einlesen?“ **07:39:** „Und dann eine Pro- und Kontra-Abwägung zu einer zentralen Vorgangsdatei … das größte Problem sehe ich persönlich ja darin, dass es zu Konflikten im Zugriff kommt, aber das sollte ja eigentlich lösbar sein … Und dann bräuchte man ja auch nicht mal zwangsweise eine großartige Archivdatei … Weil wenn ihr gezielt suchen könnt und es nicht mehr Token braucht und alles, dann ist doch das perfekt.“

## Heute

Ein Vorgang steht an bis zu sieben Stellen (`LISTE-ABLAUF-274.md`): Zeile im Vorrat und in `LISTE-VORGAENGE.md` (Stand und Klasse doppelt), Wortlaut in Vorrat, Chefsache und Vorgangsarchiv, erledigt in `LISTE-VORGAENGE-ARCHIV.md`. Wandert er, wird abgeschrieben; jede Abweichung ist ein Pflegefehler.

## Vorschlag

1. **Eine Liste** `LISTE-VORGAENGE.md`: je Vorgang eine Zeile mit Nummer, Titel, Bereich, Besitzer, Klasse, Vorrang, Stand, Zweig, Kosten. Einzige Quelle; kein Archiv, erledigt ist ein Stand.
2. **Je Vorgang eine Datei** `docs/vorgang/‹Nr›.md` für Wortlaut des Chefs, Befunde, Einzelheiten. Wandert der Vorgang, ändert sich nur das Feld Besitzer; die Datei bleibt, wo sie ist.
3. **Vorrat** behält nur Übergabe und „Pause bis“; die Arbeitsliste einer Rolle ist eine Suche (`startbar.py --rolle Sokrates` oder `grep`).
4. **Schreiben nur über ein Werkzeug** `tools/vorgang.py` (neu, setze Stand, übergib an): holt `main`, ändert die Zeile, prüft das Format, committet, pusht, bei Ablehnung neu holen und wiederholen. Keiner bearbeitet die Liste von Hand.

## Pro

- **Ein Ort:** kein Abschreiben, kein Abgleich zwischen Vorrat und Liste, deutlich weniger Pflegefehler; Werkzeuge wie `regelcheck.py` werden kleiner.
- **Wenig Token:** gesucht wird nur die Trefferzeile. 10.000 Zeilen sind etwa 1,5 MB, Suche bleibt gleich billig; Skripte lesen alles ohne Token-Kosten.
- **Wandern ist eine Feldänderung**, nicht Streichen hier und Anlegen dort.
- **Kosten** stehen in derselben Zeile; Auswertung nach Bereich ohne zweite Datei.
- **Kein Archiv nötig:** erledigt ist ein Stand; erst ab etwa 10.000 Zeilen nach Jahren teilen, falls überhaupt.
- **Chef** sieht alle Vorgänge auf einer Seite (GitHub filtert nicht, aber Suche im Browser reicht).

## Contra

- **Umbau:** `startbar.py`, `lauf.py`, `regelcheck.py`, `commit-pruefung.py`, `abgleich.py`, `vorgangskosten.py`, `notiz.sh`, die Haken und alle Rollendateien lesen heute die Vorräte. Schätzung 3–5 Sitzungen, 40–70 $, dazu Prüfung.
- **Ein Werkzeug als Nadelöhr:** ist `vorgang.py` kaputt, kann keiner einen Stand setzen. Notweg nötig (Hand mit Prüfung).
- **Ganz lesen wäre teuer:** liest eine Sitzung die Liste aus Versehen ganz, kostet das bei 10.000 Zeilen etwa 500 Tsd. Token. Schutz: Regel „nur suchen“, Werkzeug liefert gefilterte Ansichten.
- **Vorrang über Rollen:** heute die Zeilenfolge im Vorrat; künftig eine Zahl je Zeile, die jemand pflegen muss (Perikles).
- **Übersicht je Rolle** ist keine Datei mehr zum Hineinschauen, sondern eine Ausgabe; der Chef müsste fragen oder eine erzeugte Ansicht lesen.

## Zugriffskonflikte

Jede Sitzung hat eine eigene Kopie und pusht nach `main`. Git führt Änderungen an **verschiedenen** Zeilen von selbst zusammen; Konflikte entstehen bei derselben oder einer **benachbarten** Zeile. Darum:

- **Neue Vorgänge** nicht ans Ende hängen (dort kollidieren alle), sondern nach Nummer einsortieren; die Nummer zieht das Werkzeug.
- **Zähler** „Nächste freie Nummer“ entfällt: das Werkzeug nimmt die höchste Nummer plus eins und pusht sofort; scheitert der Push, neu holen, neue Nummer.
- **Nachbarzeilen:** das Werkzeug wiederholt bei Ablehnung automatisch (holen, Änderung erneut anwenden, pushen); die Sitzung merkt davon nichts.
- **Je-Vorgang-Dateien** kollidieren praktisch nie, weil selten zwei an demselben Vorgang schreiben.

Lösbar, wie der Chef vermutet; die Lösung ist das Werkzeug, nicht eine Regel.

## Mögliche Fehler

| Fehler | Folge | Gegenmittel |
|---|---|---|
| Sitzung liest die Liste ganz | viele Token | Regel „nur suchen“, Ansichten aus dem Werkzeug |
| Sitzung bearbeitet von Hand | Format kaputt, Werkzeuge stolpern | `commit-pruefung.py` lehnt Handänderungen ab |
| Zwei ziehen dieselbe Nummer | doppelte Nummer | Werkzeug pusht vor dem Nennen, Push-Ablehnung zieht neu |
| Werkzeug fehlerhaft | Stillstand der Abläufe | Probe am Rechner, Notweg, Diogenes prüft vor dem Umstieg |
| Umstieg halb fertig | zwei Quellen gleichzeitig | Umstieg an einem Tag, alte Spalten im selben Commit streichen |

## Empfehlung

**Ja, nach dem Meilenstein**, in zwei Stufen: (1) erst `vorgang.py` bauen, das heute beide Orte zugleich schreibt (kein Strukturbruch, Konflikte und Pflegefehler sinken sofort); (2) wenn es eine Woche fehlerfrei läuft, die Vorräte auf Übergabe kürzen und die Liste zur einzigen Quelle machen. **Stärkstes Gegenargument:** der Umbau berührt jedes Werkzeug und jede Rolle, mitten in der Arbeit an Kapitel 1; und 274 bringt einen Teil des Nutzens (Text wandert mit, weniger Abschrift) schon ohne Umbau. Darum nicht jetzt.
