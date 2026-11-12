# 867 · Hauptmenü: passen die vier Helden in Vorlage 4?
Tom · 13.11., 00:20 · G Stil · aus Sokrates 12.11., 23:13 (Vorlage 3 nicht so, Nacht 1077)
Kurz: Vorlage 4: Schwert nicht mehr erhoben, Bart dunkel, Stab nah am Körper, die äußeren Figuren 35 Grad zur Mitte gedreht. Von vorn sind Schwert und Schild der Wachsoldatin aber nur als schmale Kanten zu sehen. Nachbessern?

Geprüft an: [Lauf 406](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43318364445), [Commit 1082696](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/1082696d4e00cb26a7df9e8186d81901df35af86) (Zweig `claude/tom-867-vorlage2`), Hauptmenü am Bauserver mit den gekauften Figuren wie im Spiel; oben von vorn (wie im Menü), unten um 270 Grad gedreht (Wachsoldatin und Zauberlehrling von der Seite, die anderen halb von hinten); 90 und 180 Grad im Lauf ebenfalls angesehen

![Oben die vier Helden von vorn: Wachsoldatin mit Kettenhemd, Schwert und Schild nur als schmale Kanten zu sehen; Zauberlehrling mit dem Stab schräg nah am Körper; Jägerkind mit Kapuze, dunklem Bart, Bogen gesenkt quer vor der Hüfte; Klosterschülerin mit aufrechtem Stab. Unten dieselben von der Seite: die Wachsoldatin hält das Schwert waagrecht nach vorn, der Rundschild steht quer vor ihr](../bilder/867-vorlage4.webp)

**Frage:** Die vier Punkte von Sokrates (12.11., 23:13: Schwert über dem Kopf, Bart rotbraun, Klosterschülerin frontal, Stab am ausgestreckten Arm) sind erledigt. Neu fällt auf: das Schwert der Wachsoldatin zeigt waagrecht zum Betrachter, der Schild steht quer vor ihr; von vorn sind beide nur schmale Kanten. Der Chef wollte am 12.11., 21:40 eine Haltung, „in der Waffe und Schild gesehen werden“. Nachbessern?

**Votum:** „867 B“: Schild seitlich am Arm, Fläche zum Spieler, Schwert gesenkt mit der Spitze zum Boden; die anderen drei bleiben. Neue Vorlage mit allen Blickrichtungen.

**Berührt:** Erschaffung (Haar und Bart des Jägerkinds dunkelbraun bis schwarz, gilt auch dort); 431 (Körperbau je Volk, nach dem Umzug); 870.13 (Fußzeile „SRD 5.1 · CC BY 4.0“, Umzug).

**Begründung:** Chef 12.11., 21:40: „pro Char eine andere Haltung, in der Waffe und Schild gesehen werden“; Sokrates 12.11., 23:13: Schwert gesenkt oder aufgestützt wie Muster 292.3.

**Sachverhalt:**
- Wachsoldatin: „Stehen“ aus dem 1-Hand-Satz (Protofactor); das Schwert ist nicht mehr erhoben, zeigt aber waagrecht nach vorn, der Schild steht quer vor dem Körper (Bild unten).
- Zauberlehrling: Arm 22 Grad an den Körper, der Stab steht schräg nah am Körper.
- Jägerkind: Bart dunkelbraun bis schwarz (Prüfschritt: in jedem Volk), Bogen gesenkt quer vor der Hüfte.
- Klosterschülerin: Stab aufrecht in der Hand, um 35 Grad zur Mitte gedreht; Kopf zum Spieler.
- Alle vier Blickrichtungen im Lauf angesehen (0, 90, 180, 270 Grad): nichts schwebt, kein Stab geht durch den Körper.
- **Mir ist aufgefallen:**
  - Der Prüfschritt `pruefliste_1020` ist im Lauf rot; das liegt am alten Stand des Zweigs (Spalte „Passt“, behoben in 1087 auf `claude/build-281`), nicht an 867.
  - Zwerg und Elfe haben noch den Körper der Menschen (431, nach dem Umzug).

**Auswertung:**
- **A:** passt so, Einbau im nächsten Sammelbuild. Gegen A: Chefs Maß 21:40 (Waffe und Schild sichtbar) ist bei der Wachsoldatin nicht erfüllt.
- **B (Empfehlung):** nur die Wachsoldatin nachbessern (Schild seitlich mit der Fläche nach vorn, Schwert gesenkt), neue Vorlage. Stärkstes Gegenargument: noch ein Lauf (etwa 50 Minuten) für eine Figur. Antwort: das Hauptmenü ist das erste Bild des Spiels.

**Folgerungen:** A: Tom baut ein, 867 wird im Build getestet. B: Tom baut die Wachsoldatin um und legt neu vor.

Antwort: …
