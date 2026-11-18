# Notizen von BornWire TCS

Inhaltsverzeichnis: jede Zeile sagt in einem Satz, was in der Datei steht und wozu sie da ist. Wer eine Datei unter `docs/` umbenennt oder anlegt, ändert hier die Zeile mit; `python3 tools/inhalt.py` meldet jede Datei ohne Zeile und jeden toten Link (läuft in `notiz.sh`). Neue Zeilen in einfachen Worten, Fachwörter erklärt (835).

## Für den Chef

- [Chefsache](chefsache/): alles, was du entscheiden, ansehen oder testen sollst; jeder Punkt eine Datei, beantwortet heißt weg.
- [Überblick](chefsache/README.md#überblick): was gerade läuft, je Themenblock offen, Muss, in Arbeit, zum Testen und der nächste Vorgang (rechnet ein Werkzeug bei jedem Push).
- [Projektplan](PROJEKTPLAN.md): oben die Meilensteine des ganzen Projekts (Kapitel 1 bis 7, Marktstart) mit offenen Vorgängen und die Teilprojekte bis Kapitel 1 fertig; darunter die Abnahmeliste und das Ziel dieser Woche.
- [Abnahme](DESIGN-ABNAHME.md): die Liste zum Schluss, woran wir Kapitel 1 als fertig erkennen. Der Projektplan sagt, wie weit wir sind; die Abnahme sagt, wann es reicht.
- [Tagesbericht](ARBEIT-TAGESBERICHT.md): jeden Morgen zehn Zeilen, was sich getan hat, wer hinterherhinkt und was als Nächstes kommt.
- [Vorgangsarchiv](VORGANGSARCHIV.md): alles, was du entschieden hast, neueste oben; zum Nachschlagen, nicht zum Lesen von vorn.
- [Leitbild](DESIGN-LEITBILD.md): wie das Spiel im Ganzen sein soll; gilt, wenn sich zwei Dateien widersprechen.
- [Regeln (BRS)](DESIGN-BRS.md): unser eigenes Rollenspielsystem, wie es gilt (für uns; für Spieler erklärt es das Spielerhandbuch unter „Das Spiel“).
- [Alle Stufen auf einen Blick](DESIGN-BRS.md#alle-stufen-auf-einen-blick): jede Stufenleiter im Spiel (Heldenstufe, Ränge der Fertigkeiten, Ruf, Güte, Seltenheit, Zustand …) mit ihren Stufen, wovon sie abhängt und wo die Einzelheiten stehen.
- [Querschnitt je Kampfstil](DESIGN-BRS.md#querschnitt-jede-kampfregel-je-kampfstil): jede Kampfregel gegen Krieger, Kämpe, Schütze, Späher, Magier, Heiler (Ist im Code); wer eine Kampfregel, Waffe oder Schule einführt, trägt sie dort ein (984).
- [Kosten](LISTE-KOSTEN.md): wofür das Guthaben je Bereich, Tag und Woche ausgegeben wurde (rechnet ein Werkzeug aus).

## Das Spiel

- [Stil](DESIGN-STIL.md): wie das Spiel aussieht, klingt und sich anfühlt.
- [Kerbensystem](DESIGN-GLUT.md) (Datei heißt noch „Glut“): die Kampfregeln mit drei Kerben je Zug (Weg, Tun, Haltung), Bauplan und Prüfpunkte (930). Entschieden: bauen (930 A), Name Kerbe (1260 D), Kerben verstreichen (1288a), Lesen spürbar (1288b); gebaut ab Build 291, im Spiel noch ausgeschaltet (nur in den Proben an), noch nicht auf `main`; die übrigen Zahlen sind Entwurf.
- [Kampf (MARS)](DESIGN-KAMPF.md): Grundgedanken vom 14.10. (Absicht des Gegners zeigen, Reaktion im Gegnerzug, Kulisse) und was zu Waffe, Schild und Kampf im Bild gilt; der Abschnitt „Handgemenge und Abstand (930)“ dort ist durch das Kerbensystem ersetzt.
- [Gegnerverhalten](DESIGN-GEGNER.md): Regelblatt 1589.1, was Gegner wollen und wie sie sich auf dem Blatt bewegen (Denkweise, Ziel, Rolle, Flucht); Gerüst, im Gegenlesen.
- [Blende](DESIGN-BLENDE.md): die Übergangsbilder zwischen Orten, bei Rast und Tod.
- [Entscheidungen zum BRS](DESIGN-BRS-ENTSCHEIDUNGEN.md): die Regelfragen E 1–84 bis 11.11. als nummerierte Liste; spätere Regelentscheide stehen im Vorgangsarchiv, Verlauf und alte Ideen in `alt/DESIGN-SPIELSYSTEM-2-0.md`.
- [Spielerhandbuch](STORY-HANDBUCH-1.md), ein Buch in drei Dateien (Teil [2](STORY-HANDBUCH-2.md), Teil [3](STORY-HANDBUCH-3.md)): die Regeln aus dem BRS so erklärt, wie der Spieler sie liest (Entwurf vom 01.11.; der Kampf darin noch ohne Kerben).
- [Storyplan](STORY-PLAN.md): Handlung und Figuren je Kapitel; [Kapitel 1](STORY-PLAN-K1.md) zeigt den Stand der alten Handy-Fassung.
- [Story-Verzeichnis](STORY-REGELN.md): wo jeder Spieltext steht und wie wir ihn schreiben; Kapitel 1 [Handlung](STORY-K1-HANDLUNG.md) und [Welt](STORY-K1-WELT.md), [Texte der Blenden](STORY-BLENDE.md), Gespräche im [Dorf](STORY-VARIANTEN-K1.md) und in [Wald, Höhle, an Türen und bei der Rast](STORY-VARIANTEN-K1-WALD.md).
- Weitere Spieltexte: [Kampf, Rast, Zustände](STORY-SPIEL.md), [Menü des Helden](STORY-MENUE.md), [Lehrmeister und Pfade](STORY-LEHRMEISTER-K1.md), [Meisterschaften und Ruf](STORY-RUF-K1.md), [Fertigkeiten ohne Kampf](STORY-K1-FERTIGKEITEN.md).
- Spieltexte nach dem BRS (aus dem Umzug 870, Quelle für den Bau): [Kampf](STORY-BRS-KAMPF.md), [Kampfhandlungen und Zauber](STORY-BRS-KOENNEN.md), [Held, Truhe, Schwächen](STORY-BRS-HELD.md), [Handbuch im Spiel](STORY-BRS-ANLEITUNG.md), [Oberfläche und Namen](STORY-BRS-OBERFLAECHE.md), [Erklärungen in der Erschaffung](STORY-BRS-ERSCHAFFUNG.md).
- [Roter Faden](STORY-ROTER-FADEN.md) und [Chronik-Texte Kapitel 1](STORY-CHRONIK-TEXTE-K1.md): die Geschichte über alle Kapitel in Kürze und die Texte der Chronik im Spiel.
- [Figuren](LISTE-FIGUREN.md): nur das Aussehen wiederkehrender Leute und Monster, damit man sie überall wiedererkennt.
- [Gegenstände](LISTE-GEGENSTAENDE.md): alles, was man finden, kaufen oder tragen kann, nach Art und woher man es bekommt (rechnet ein Werkzeug aus; Werte teils noch aus der alten Fassung, BRS-Werte kommen mit dem Katalog 644).
- [Regelwerte](LISTE-REGELWERTE.md): jede Zahl der Spielregeln mit Regel, Formel, heutigem Wert und wo sie wirkt, etwa wie Fertigkeiten wachsen, auch die Werte jedes Monsters (rechnet ein Werkzeug aus).
- [Bestiarium](LISTE-BESTIARIUM.md): Angriffe, Beute und Hintergrund jeder Monsterart, gelesen aus der alten Fassung am 31.10.; die heutigen Kampfwerte stehen in den Regelwerten, das Aussehen unter Figuren. Beide gehen im Figurenkatalog auf (649).
- [Ideen](LISTE-IDEEN.md): lose Einfälle; sonntags urteilt Homer, montags holt Perikles Reifes.
- [Aktionspunkte](DESIGN-AKTIONSPUNKTE.md): Verlauf des Gesprächs Chef und Sokrates (13.–14.11.), wie wir zu den Kerben kamen; nur zum Nachlesen, es gilt das Kerbensystem.
- [Änderungshistorie](../CHANGELOG.md): was schon gebaut ist.
- **Kapitel 2** in [`kapitel2/`](kapitel2/), gilt erst nach Kapitel 1: [Storyplan](kapitel2/STORY-PLAN-K2.md), [Textentwurf](kapitel2/STORY-K2-ENTWURF.md), [Landkarte](kapitel2/STORY-K2-LANDKARTE.md), [Wahlen des Spielers](kapitel2/STORY-WAHLEN.md).

## Für die Teams

Arbeitslisten; du musst sie nicht lesen.

- [Vorgänge](LISTE-VORGAENGE.md): die eine Liste aller Aufgaben, je Aufgabe eine Zeile mit Besitzer, Stand und worauf sie wartet; erledigte im [Archiv](LISTE-VORGAENGE-ARCHIV.md). Nie ganz lesen, sondern `python3 tools/vorgang.py --rolle <Rolle>`.
- [Besetzung](ARBEIT-BESETZUNG.md): wer gerade woran arbeitet; [Betrieb](ARBEIT-BETRIEB.md): Guthaben und Protokoll von Fords Läufen; [Wochenplan](LISTE-WOCHENPLAN.md): feste Termine, wer wann was meldet.
- [Prüfbericht](PRUEFBERICHT.md): was Diogenes zuletzt beanstandet hat und die Zahlen der Woche; ältere im [Archiv](PRUEFBERICHT-ARCHIV.md).
- [Muster einer Vorlage](chefsache/MUSTER.md): so muss eine Datei in der Chefsache aufgebaut sein.
- [Checkliste MARS](LISTE-MARS.md): was im Kampfsystem (MARS) schon geht und was noch fehlt.
- [Umzug nach Godot](LISTE-UMZUG-348.md): Regeln für den Neubau des Spiels in Godot, dem neuen Spielbaukasten; die Fassung bis 10.11. liegt in [alt/](alt/LISTE-UMZUG-348.md).
- [Abgleich alt](LISTE-ABGLEICH-ALT.md): was die alte Handy-Fassung je Ort und Figur hatte, damit im Neubau nichts verloren geht.
- [Abgleich Oberfläche](LISTE-ABGLEICH-OBERFLAECHE.md): jeder Schirm und jede Bedienung alt gegen Godot, je Lücke ein Vorgang 785.n (785).
- [Klang alt gegen neu](LISTE-KLANG-ALT-NEU.md): jedes Geräusch der alten Fassung je Anlass, ob es in Godot klingt und wer das Fehlende baut.
- [3D-Modelle je Körperstelle](LISTE-NETZE.md) („Netzliste“; Netz heißt 3D-Modell): welche Kleidung und Rüstung es für Kopf, Körper, Arme, Beine und Umhang schon gibt, was wir anpassen und was noch fehlt.
- Was zu Figuren und Kampf entschieden ist, steht in der [Abnahme](DESIGN-ABNAHME.md) unter „Vor jeder Vorlage“; jede Vorlage wird dagegen geprüft.
- [Bestand](LISTE-BESTAND.md): alle gekauften und freien Bewegungen, Figuren, Tiere, Dinge und Bauteile; vor jedem Eigenbau lesen.
- [Quellen](LISTE-QUELLEN.md): jede geprüfte fremde Bezugsquelle mit Link und Lizenzprüfung.
- [Effekte](LISTE-EFFEKTE.md): welcher Lichteffekt zu welchem Helden, Monster und Ort gehört.
- [Umzug auf das BRS](LISTE-UMZUG-BRS.md): Master-Plan, wie das Spiel ganz auf das eigene Regelwerk umgestellt wird (870), bis zur Abnahme.
- [Figurenkatalog, Bauplan](LISTE-FIGURENKATALOG-649.md): Plan für einen Katalog aller Figuren, bis er gebaut ist.
- [Simulation](LISTE-SIMULATION-444.md): Rechenprobe, wie stark Helden je Herkunft und Stufe werden (Stand 12.11., vor dem Kerbensystem).
- [Testgeräte](LISTE-TESTGERAETE.md): welche Handys getestet werden und wie schnell das Spiel darauf läuft.
- [Technik gegen fremde Praxis](LISTE-TECHNIK-PRAXIS.md): wie andere Handyspiele rendern und Effekte bauen, was wir davon nutzen, Rangfolge der Vorschläge (1270.5).
- [Glossar](LISTE-GLOSSAR.md): unsere Begriffe und Abkürzungen von A bis Z.
- [Rollenspiegel](LISTE-ROLLENSPIEGEL.md): mittwochs je Rolle, was sie tun soll und was sie getan hat.
- Handwerk: [Bauen und Testen](LISTE-BAUEN-TESTEN.md) · [Checkliste Build und Test](LISTE-CHECK-BUILD-TEST.md) · [Betrieb](LISTE-BETRIEB.md) · [Prüfen](LISTE-PRUEFUNG.md) · [Auswertung Prüfbögen](LISTE-AUSWERTUNG-PRUEFBOGEN.md) · [Release und Neustart](LISTE-RELEASE-NEUSTART.md) · [Regeltreue](LISTE-REGELTREUE.md).

## Firma

- [Handbuch](FIRMA.md) und [Regeln für alle](../CLAUDE.md); [Logo und Geschäftspapiere](firma/README.md).
- Rollen, also wer was tut: [Entwickler](ROLLE-ENTWICKLUNG.md) ([Spike, Entwurf 1678](ROLLE-TECHNIK.md)) · [Perikles](ROLLE-PROJEKT.md) · [Homer](ROLLE-KREATIV.md) · [Sokrates](ROLLE-BERATUNG.md) ([Startprompt, Entwurf 1625](ROLLE-BERATUNG-START.md)) · [Diogenes](ROLLE-PRUEFUNG.md) · [Ford](ROLLE-BETRIEB.md).
- Vorräte, also Übergabe und Einzelheiten je Rolle: [Tom](ARBEIT-TEAM-TOM.md) · [Jerry](ARBEIT-TEAM-JERRY.md) · [Spike](ARBEIT-TEAM-SPIKE.md) · [Perikles](ARBEIT-PROJEKT.md) · [Homer](ARBEIT-KREATIV.md) · [Sokrates](ARBEIT-BERATUNG.md) · [Diogenes](ARBEIT-PRUEFUNG.md) · [Betrieb](ARBEIT-BETRIEB.md) · [Besetzung](ARBEIT-BESETZUNG.md).
- **Abgelegt** in [`alt/`](alt/): Erledigtes und Ruhendes, beim Wiedereinschalten zurückholen, darunter die [Englisch-Korrekturliste](alt/LISTE-ENGLISCH-338-1B.md); die Umstellung der Vorgangsliste beschreibt `tools/umstellung2752/README.md`. Am 21.10. Gelöschtes steht in Git bis `f3ec7200`.
