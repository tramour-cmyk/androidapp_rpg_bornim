# 750 · Ford startet ohne `lauf.py`: Sperre per Haken · Sokrates · 09.11., 13:30
B Werkzeuge

Geprüft an: https://claude.ai/code/session_01Hmoj76jJSNHHX8bmPvFvzZ

**Anlass:** Chef 13:28: „gibt es jetzt einen Grund, warum Ford keine Startsperre schreibt? … woran liegt das?“

**Befund (Fords Sitzung nachgelesen):** Bis 00:03 lief jeder Ford-Lauf über `lauf.py --sperre --besetzung` (`LISTE-BETRIEB.md` Schritt 4); `lauf.py` rechnet, wer startet, schreibt die Startsperre und gibt die START-Zeilen aus. Seit dem Selbstneustart 01:05 ruft der neue Ford nur noch `startbar.py`, sucht sich daraus selbst aus, wen er startet, und ruft `create_session` von Hand (heute 10:05 Perikles, 12:08 Perikles, 13:06 Diogenes). `lauf.py` nutzt er nur noch für Kosten und Besetzung. Damit fehlen Startsperre, Doppelstart-Schutz, Pausen-Prüfung und die Regel „Ford beurteilt nichts“. Die Regel steht richtig da; der Nachfolger hat den Ablauf beim Selbstneustart nicht übernommen, und nichts hielt ihn an. Ford ist als einzige Rolle auf sonnet; ob das mitspielt, lässt sich nicht belegen.

**Frage:** Wie verhindern wir, dass Ford am Werkzeug vorbei startet?

- **A (Empfehlung Sokrates):** ein Haken in `.claude/settings.json` vor jedem `create_session`: er lässt den Start nur durch, wenn für diese Rolle in den letzten 10 Minuten eine Startsperre auf `main` steht (also `lauf.py --sperre` lief); sonst hält er an mit „erst `lauf.py --sperre --besetzung`“. Bau Perikles. Gegenargument: der Neustart eines Nachfolgers durch eine Sitzung selbst (Notfall, `LISTE-RELEASE-NEUSTART.md` Schritt 2) braucht dann auch eine Sperre; das Werkzeug kann sie schreiben.
- **B:** nur die Uhr „Ford-Lauf“ schreibt „Schritte 1–10 aus `LISTE-BETRIEB.md`, Schritt 4 `lauf.py --sperre --besetzung`“ in ihren Text. Gegenargument: wieder Text ohne Sperre; genau so ging es heute schief.

Antwort: „750 A“ oder „750 B“.
