# 1328 · Soll Spike fest der Technik-Entwickler werden und unabhängig von Tom arbeiten?
Sokrates · 15.11., 21:00 · B Abläufe · aus deinem Wort 20:59
Kurz: Spike fest für Godot-Technik, Leistung und Werkzeuge, mit eigenen Zeilen und eigenem Start; GUI bleibt bei Tom.
Beim Chef, weil: Rollen und Accounts

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/c22fe6256/tools/lauf.py#L822-L828 (dazu Vorgangsliste und Sitzungsliste 15.11., 21:00)
Beim Chef, weil: Rollen und Accounts

**Frage:** Du hast vorgeschlagen, einen der beiden Zusatzentwickler (Spike oder Tuffy) fest als Entwickler für Grafik, Oberfläche und Programmcode zu benennen, damit der Themenblock „Godot besser nutzen“ (1268, 1270) nicht liegen bleibt und Tom und Jerry entlastet sind. Soll das so sein, und in welchem Zuschnitt?

**Votum:** „1328 A“

**Berührt:** Spike, Tom (Vorrat, Zeilen 1268.x, 1270.x), Perikles (Bau `lauf.py`, `startbar.py`), `ROLLE-ENTWICKLUNG.md`, Ford.

**Begründung:** Chef 15.11., 20:59: „wenn man jetzt einen unserer 4 Entwickler so als ja, Grafik, GUI, Programmcode-Entwickler designieren würde und am besten natürlich nicht Tom und Jerry, weil die haben genug … und der dann ein bisschen besser ausgelastet ist“. Bei Technik geht das ohne Nachteil; bei der Oberfläche nicht, weil sie in Toms Dateien liegt.

**Sachverhalt:**
- Heute arbeitet Spike praktisch schon so: Seit 10:56 lief er in sieben Sitzungen nur an 1270 und 1268 (1270.1, 1270.2, 1268.1–1268.3, 1268.5, 1270.3); 1270 A und 1268 A sagen schon „Bau Spike, nicht Tom und Jerry“. Tuffy lief seit gestern Nacht nicht.
- Woran es hakt, steht in `lauf.py` 822–828: Spike startet nur, wenn Tom gerade belegt ist, und nur auf **Muss**-Zeilen. 1270.4 (Glühen, Höhlenlicht, Vergleichsbild) ist Kür und startbar, aber Spike startet darauf nie.
- Dass 1270.3 heute sieben Stunden lag, war ein falscher Eintrag von mir (Stand nicht zurückgesetzt), keine fehlende Hand. Diesen Fehler behebt eine neue Rolle nicht.
- 27 Vorgänge stehen auf „zu testen, ohne Rückmeldung“ (Builds 277–289), 21 bei Jerry, 6 bei Tom. Sie warten nicht auf dich: keine Testbitte hat dich danach gefragt (`ansehen/` und `tun/` leer, Chef 21:03: „Leute, ich habe nichts zu testen“). Sie liegen bei uns; aufgelöst in 1329 (Tom) und 1330 (Jerry): selbst am Build prüfen und schließen oder als Test mit Schritten vorlegen.

**Auswertung:**
- **A (Empfehlung):** Spike wird fest **Technik-Entwickler**: Godot-Möglichkeiten (1270), Code robuster und schneller (1268), Ladezeit, Bildrate, Shader, Tests und Bauwerkzeuge. Seine Zeilen tragen den Besitzer „Spike“ statt Tom; `lauf.py` startet ihn darauf auch dann, wenn Tom frei ist, und auch auf Kür seines Blocks. Kosten bleiben bei Team Tom, Vorrat ein eigener Abschnitt in `ARBEIT-TEAM-TOM.md`. Die **Oberfläche (GUI) bleibt bei Tom**, Grafik nur, wo sie Technik ist (Licht, Shader, Leistung); Aussehen legst wie bisher du fest. Regelbilanz: das ersetzt für Spike die Regel „nur wenn Tom belegt, nur Muss“ (433). Tuffy bleibt Aushilfe für Jerry. Bau: Perikles, etwa eine Stunde.
- **B:** wie A, aber Spike bekommt auch die GUI. Dann ändern Tom und Spike dieselben Dateien der Blende gleichzeitig; mehr Zusammenstöße beim Mischen, mehr Wiederholfunde.
- **C:** alles bleibt; nur 1270.4 auf Muss setzen, damit Spike startet. Billig, hilft aber nur diesmal.
- **Stärkstes Gegenargument gegen A:** Ein Entwickler mehr, der baut, legt noch mehr Gebautes ohne Prüfung ab, wenn das Vorlegen nicht klappt (27 Zeilen oben). Antwort: Technikarbeit prüft Spike selbst am Lauf (Messung, Test grün; Werkzeug sofort nach grünem Lauf, 1311) und schließt sie; wo sie Aussehen ändert (1270.4 Glühen), legt er ein Vergleichsbild vor statt sie in einen Build zu packen.

**Folgerungen:** Bei A: Perikles baut `lauf.py`/`startbar.py` und `ROLLE-ENTWICKLUNG.md` um; ich setze Besitzer der Zeilen 1268.x und 1270.x auf Spike und melde Vollzug. Bei C: Perikles setzt 1270.4 auf Muss.

Antwort: …
