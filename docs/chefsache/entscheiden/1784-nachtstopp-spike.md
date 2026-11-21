# 1784 · Soll Spike heute Nacht trotz Nachtstopp an 1739 (Werkzeuge für die Umstellung) weiterarbeiten, höchstens acht Starts?
Sokrates · 21.11., 21:46 · 7 Firma · aus Ford 21:41 (Nachtstopp hält den Spike-Nachfolger für 1739, Teil 7)
Kurz: Der Nachtstopp hält Spike bis 07:00 an; heute Abend hat jeder Neustart Werkzeuge geliefert, je Sitzung etwa 4 $.
Beim Chef, weil: Geld; Rollen und Accounts (wann eine Rolle arbeitet); ändert Entschiedenes (1643, aus 340.12 Änderung 3, Chef 18.11., 09:45)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/4a76e6f28 (`tools/lauf.py`:201, :272–281; `tools/nachtstarts.py`:3, :15; `docs/KOSTEN-GEBUCHT.tsv`; Git-Verlauf Spike 21.11., 20:08–21:41)

**Frage:** Der Nachtstopp (1643) hält einen Vorgang an, der ab 21:00 schon dreimal gestartet wurde; er entstand aus einer Nacht mit sechs Neustarts ohne Fortschritt für gut 20 $. Spike startete seit 20:08 siebenmal neu, alle 8–18 Minuten, jedes Mal an unserer Kostenschwelle von 200 Tsd. Token (383 A, „günstigste Länge“; der Kontext selbst ist 1 Mio.). Jede Sitzung lieferte Werkzeuge (unter anderem Telegram-Regel in `meldung.sh`, `vorgang.py --hilfe`, Weitergabe nach erstem Wort, Sperre gegen Force-Push, Stop-Haken, Rufnamen; Commits 20:13–21:38). Offen: Rest von 1739, dann 1749 und 1742. Soll Spike heute Nacht weiterarbeiten?

**Votum:** „1784 A“: ja, höchstens acht weitere Starts (etwa 32 $; voraussichtlich bis gegen Mitternacht, spätestens 03:00); Ford startet von Hand trotz der Zeile „angehalten bis 7 Uhr“, und nur, wenn die zuletzt gepushte Übergabe der letzten Spike-Sitzung einen Commit nennt, der laut `git show --stat` etwas unter `tools/` oder `.github/` ändert; sonst Stopp wie sonst. Heute hätte diese Bedingung nie gegriffen, weil jede Sitzung geliefert hat; die Kosten begrenzt allein der Deckel von acht Starts.

**Berührt:** Ford (Neustarts von Hand), Spike (1739), 1643.

**Begründung:** Werkzeuge haben jetzt Vorrang (Chef 21.11., 20:06: „Uns fehlen die restlichen Werkzeuge. Die müssen wir jetzt machen.“). Der Stopp ist für Schleifen ohne Fortschritt gedacht.

**Sachverhalt:**
- Grenze: Start plus zwei Neustarts ab 21:00, danach angehalten bis 07:00 (`nachtstarts.py`:15, `lauf.py`:272–281); kein Schalter, nur Start von Hand.
- Kosten je Sitzung 1739 Teil 1–5: 3,50–5,12 $ (Ford-Commits „Spike (1739 Tn) archiviert, Kosten“ mit `KOSTEN-GEBUCHT.tsv`); bei 4–5 Starts je Stunde etwa 16–20 $ je Stunde.
- Werkzeug-Commits heißen uneinheitlich („1739: …“, „Werkzeug 1739 (…)“, „Spike: 1739 …“), und Sitzungsstarts erzeugen oft selbst einen Commit „Werkzeug: Startwarnungen“ (`startwarnung.py`, nur bei Änderung); nach Titel lässt sich Fortschritt darum nicht sicher erkennen, nach der Übergabe schon.

**Auswertung:**
- **A (Empfehlung):** bis zu acht Starts, etwa 32 $; 1739 voraussichtlich bis morgen früh deutlich weiter.
- **B:** Ruhe bis 07:00; 1739 verzögert sich um etwa 9 Stunden, kostet nichts.
- **C:** Schwelle für Spike heute Nacht auf 400 Tsd. (halb so viele Neustarts, weniger Startlesen); geht heute Nacht nicht, weil dafür `lauf.py` geändert werden müsste und Spike angehalten ist.
- **Stärkstes Gegenargument gegen A:** nachts sieht keiner zu, und 200 Tsd. in 10 Minuten heißt: ein großer Teil jeder Sitzung ist Startlesen; wir zahlen viel für Wiederholung. Entkräftung: Deckel acht Starts und Bedingung „Übergabe nennt Werkzeug-Commit“; die Ursache des teuren Startlesens geht als eigener Punkt an Spike.

**Folgerungen:** A: Ford startet nach der Bedingung, zählt Starts und Kosten, Zeile im Protokoll für den Morgen.

Antwort: …
