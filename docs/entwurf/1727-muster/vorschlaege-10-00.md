# 1727 · Vorschläge zu Abgenommenem aus Falltest Lauf 1 und 2 (Sokrates, 21.11., 23:41; nur im Gespräch 10:00 zu ändern, Archiv 20.11., 16:49)

Quelle: `falltest-ergebnis-22-11.md` (Bewertung, Lauf 2). Lauf 2 spielte V1 und V2 in der ersten Fassung. Fassung 2 nach Nachprüfung 1 (23:38, Befunde 14–17).

| Nr. | Text (abgenommen) | heute | Vorschlag | Byte | Fall |
|---|---|---|---|---|---|
| V1 | Kern Leitung, Haltung 6 (Archiv 20.11., 21:10) | „…prüft vor der Vorlage ein frischer Helfer gegen Repo und ganzen Entwurf, ohne deine Begründung; im Chat „Gegengeprüft: <Datei>“ und je Befund …“ | „Was etwas festlegt (Regel, Ablauf, Werte, Werkzeug, Prompt) oder in die Chefsache geht, prüft vor der Vorlage ein frischer Helfer gegen Repo und ganzen Entwurf, ohne deine Begründung, nach jedem Einarbeiten neu, bis nichts Neues kommt; im Chat „Gegengeprüft: <Datei>“, Byte vorher/nachher und je Befund …“ | 2.837 → 2.937 (Grenze 3 KB) | L1 (Lauf 2 bestanden mit Fassung 1), L10 (Chefsache ohne Prüfung); Chef 21.11., 21:37 (Wortlaut nur im Vorrat Sokrates), 20.11., 16:49 |
| V2 | Sockel 7 (Archiv 20.11., 12:06) | „Vor Sitzungsende alles pushen.“ | „Vor Sitzungsende nur Eigenes committen und pushen.“ | 1.109 → 1.129 (Grenze 1,2 KB) | W1; Vorfall 21.11., 20:59 (`023edc9b7`). Gegenargument: Ursache durch 1776/1778 gesperrt; Text trägt nur die Absicht |
| V3 | Kern Arbeitsplaner Feld 7 (1727f) | „erstes Wort „fertig“, „Frage“ oder „abgebrochen““ | „erstes Wort „fertig“, „Frage“ oder „steckt fest“ (nach Ursache und Behebung geht es nicht weiter)“ | 2.649 → 2.698 | K3 (Lauf 2): die Fachkraft meldete zweimal „Frage“ statt „steckt fest“, weil der Auftrag das Wort nicht anbietet; dann greift die Obergrenze B (Chef 21.11., 14:37, `rueckmeldung.py` zählt nur „steckt fest“) nie. „abgebrochen“ kennt das Werkzeug nicht (1797) |

**Zur Kenntnis, kein Textwechsel:** Feld 6 des Auftrags heißt im Kern Arbeitsplaner „Prüfart“, `auftrag.py` verlangt „Prüfart und Prüfe vor dem Senden“; Spike lässt das Werkzeug beide annehmen (1798). Ablage der Profile für Feld 4 („Pfad des Profils“) ist nicht festgelegt; Vorschlag `docs/profile/<Name>.md` mit der Umstellung.
