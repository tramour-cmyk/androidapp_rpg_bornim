# Notizen von BornWire TCS

Inhaltsverzeichnis (122, 650.2). Wer eine Datei unter `docs/` umbenennt oder anlegt, ändert hier die Zeile mit; `python3 tools/inhalt.py` meldet jede Datei ohne Zeile und jeden toten Link (läuft in `notiz.sh`).

## Für den Chef

- [Chefsache](chefsache/): was du entscheiden, ansehen oder tun sollst; jeder Punkt eine Datei, beantwortet heißt weg.
- [Projektplan](PROJEKTPLAN.md): oben das Wochenziel, darunter Stufe für Stufe, wie weit Kapitel 1 ist.
- [Tagesbericht](ARBEIT-TAGESBERICHT.md): jeden Morgen zehn Zeilen, was sich getan hat, wer hinkt, was als Nächstes kommt.
- [Vorgangsarchiv](VORGANGSARCHIV.md): was du entschieden hast, neueste oben; zum Nachsehen, nicht zum Lesen von vorn.
- [Leitbild](DESIGN-LEITBILD.md): der rote Faden des Spiels; gilt bei Widerspruch.
- [Abnahme](DESIGN-ABNAHME.md): woran Kapitel 1 als fertig gilt (Abnahmeliste).
- [Regeln (BRS)](DESIGN-BRS.md): unser Rollenspielsystem, wie es gilt; [Spielerhandbuch](STORY-HANDBUCH-1.md) erklärt es für Spieler.
- [Kosten](LISTE-KOSTEN.md): wohin Guthaben je Bereich, Tag und Woche geht (erzeugt).

## Jetzt

- [Chefsache, Muster einer Vorlage](chefsache/MUSTER.md): Aufbau 364 zum Kopieren (799)
- [Wochenplan](LISTE-WOCHENPLAN.md): Termine und Routinen, wer meldet wann wohin
- [Besetzung](ARBEIT-BESETZUNG.md): wer gerade woran
- [Betrieb](ARBEIT-BETRIEB.md): Guthaben, Protokoll der Läufe
- [Prüfbericht](PRUEFBERICHT.md): offene Befunde von Diogenes und Kennzahlen der Woche; erledigte Läufe im [Archiv](PRUEFBERICHT-ARCHIV.md)
- [Vorgänge](LISTE-VORGAENGE.md): **die eine Vorgangsliste** (275.2, seit 07.11.): je Vorgang eine Zeile mit Besitzer, Klasse, Stand, „wartet auf“, Zweig, Build, Kosten; nie ganz lesen, sondern `python3 tools/vorgang.py --rolle <Rolle>`; abgeschlossene im [Archiv](LISTE-VORGAENGE-ARCHIV.md)
- [Checkliste MARS](LISTE-MARS.md): was im Kampfsystem steht, was fehlt, klassisch ↔ MARS (296)
- [Testgeräte](LISTE-TESTGERAETE.md): Geräteangaben und Messwerte der Tester (388)
- [Umzug nach Godot](LISTE-UMZUG-348.md): was aus der alten Fassung übernommen ist und was fehlt (348, 398)
- [Abgleich alt](LISTE-ABGLEICH-ALT.md): was die alte Fassung je Ort und Figur von Kapitel 1 hat, einmal gegen Godot geprüft (620.2)
- Was zu Figuren und Kampf entschieden ist (461): Kennungen in [Abnahme](DESIGN-ABNAHME.md) „Vor jeder Vorlage“; Text in Stil und Kampf; jede Vorlage wird dagegen geprüft
- [Netzliste](LISTE-NETZE.md): je sichtbarem Platz die Netze (Bestand, unser, Eigenbau) und welche Gegenstände sie tragen (455.2)

## Spiel

- [Stil](DESIGN-STIL.md): Aussehen, Klang, Spielgefühl
- [Kampf](DESIGN-KAMPF.md), [Blende](DESIGN-BLENDE.md), [Entscheidungen und Verlauf zum Spielsystem](DESIGN-SPIELSYSTEM-2-0.md) (Liste „E <Nr.>“, Glossar alter und neuer Namen, Ideensammlung; 413)
- [Spielerhandbuch](STORY-HANDBUCH-1.md) (Entwurf 423, Teile [2](STORY-HANDBUCH-2.md), [3](STORY-HANDBUCH-3.md)): das Spielsystem für den Spieler erklärt
- [Storyplan](STORY-PLAN.md): Plot und Figuren je Kapitel; [Kapitel 1](STORY-PLAN-K1.md) (Ist-Stand Kotlin, 12.10.)
- [Story-Verzeichnis](STORY-REGELN.md): alle Spieltexte mit Marken; Kapitel 1 [Handlung](STORY-K1-HANDLUNG.md) und [Welt](STORY-K1-WELT.md), [Blende](STORY-BLENDE.md); Gesprächsvarianten [Dorf](STORY-VARIANTEN-K1.md) und [Wald, Höhle, Türen, Rast](STORY-VARIANTEN-K1-WALD.md)
- Spieltexte: [Kampf, Rast, Zustände](STORY-SPIEL.md), [Spielermenü](STORY-MENUE.md), [Lehrmeister und Pfade](STORY-LEHRMEISTER-K1.md), [Meisterschaften und Ruf](STORY-RUF-K1.md)
- Aus Artefakten übernommen (246.1): [Roter Faden](STORY-ROTER-FADEN.md), [Chronik-Texte Kapitel 1](STORY-CHRONIK-TEXTE-K1.md)
- [Figuren](LISTE-FIGUREN.md): festes Aussehen wiederkehrender Leute und Monster
- [Gegenstände](LISTE-GEGENSTAENDE.md): alles, was es gibt, nach Art und Bezugsweg; erzeugt aus `tools/gegenstaende/gegenstaende.json` mit `tools/gegenstaende.py` (458)
- [Bestiarium](LISTE-BESTIARIUM.md): Monsterarten mit Angriffen, Beute, Werten für das BRS (427)
- [Figurenkatalog, Bauplan](LISTE-FIGURENKATALOG-649.md): Aufbau und Gegenprüfung des Katalogs aller Figuren (649), bis zum Bau
- [Simulation 2.0](LISTE-SIMULATION-444.md): Rechensimulation Herkunft × Art × Stufe, Fortschritt bis Stufe 6, Befund (444)
- [Bestand](LISTE-BESTAND.md): Inventur aller gekauften und geladenen Bewegungen, Figuren, Tiere, Dinge, Bauteile; vor jedem Eigenbau lesen (377)
- [Quellen](LISTE-QUELLEN.md): Ressourcenseite, jede geprüfte fremde Quelle mit Link und Prüfschema F1–F8 (623); darin auch die Suche 26.–29.10. (CC0-Gerüst, Bewegungen, Tiere und Monster, Kaufkandidaten; 348.12)
- [Effekte](LISTE-EFFEKTE.md): Zuordnungsseite, welcher Effekt zu welchem Helden, Monster, Ort; vor jedem Eigenbau lesen (623)
- [Glossar](LISTE-GLOSSAR.md): unsere Begriffe mit Ober- und Unterbegriff, Abkürzungen, A–Z; Fundstellen mit `tools/glossar.py` (648)
- [Ideen](LISTE-IDEEN.md): lose Einfälle, noch nicht geprüft
- [Rollenspiegel](LISTE-ROLLENSPIEGEL.md): Ist-Soll-Abgleich je Rolle, freitags (340)
- [Änderungshistorie](../CHANGELOG.md): was gebaut ist
- **Kapitel 2** in [`kapitel2/`](kapitel2/) (650.2 B, gilt erst nach Kapitel 1): [Storyplan](kapitel2/STORY-PLAN-K2.md), [Textentwurf](kapitel2/STORY-K2-ENTWURF.md), [Landkarte](kapitel2/STORY-K2-LANDKARTE.md), [Wahlen](kapitel2/STORY-WAHLEN.md)

## Firma

- [Handbuch](FIRMA.md) und [Regeln für alle](../CLAUDE.md)
- [Logo und Geschäftspapiere](firma/README.md) (251.1)
- Rollen: [Entwickler](ROLLE-ENTWICKLUNG.md) · [Perikles](ROLLE-PROJEKT.md) · [Homer](ROLLE-KREATIV.md) · [Sokrates](ROLLE-BERATUNG.md) · [Diogenes](ROLLE-PRUEFUNG.md) · [Ford](ROLLE-BETRIEB.md)
- Vorräte (seit 275.2 nur Übergabe, Pause und Einzelheiten „Zu <Nr.>“, keine Tabelle): [Tom](ARBEIT-TEAM-TOM.md) · [Jerry](ARBEIT-TEAM-JERRY.md) · [Perikles](ARBEIT-PROJEKT.md) · [Homer](ARBEIT-KREATIV.md) · [Sokrates](ARBEIT-BERATUNG.md) · [Diogenes](ARBEIT-PRUEFUNG.md) · [Betrieb](ARBEIT-BETRIEB.md) · [Besetzung](ARBEIT-BESETZUNG.md)
- Handwerk: [Bauen und Testen](LISTE-BAUEN-TESTEN.md) · [Prüfliste Build und Test](LISTE-CHECK-BUILD-TEST.md) · [Betrieb](LISTE-BETRIEB.md) · [Prüfen](LISTE-PRUEFUNG.md) · [Auswertung Prüfbögen](LISTE-AUSWERTUNG-PRUEFBOGEN.md) · [Release und Neustart](LISTE-RELEASE-NEUSTART.md) · [Regeltreue](LISTE-REGELTREUE.md)
- Gelöscht 21.10. (274), in Git bis `f3ec7200`: Archiv bis 16.10., Niederlassung, Zwischenbild, Rollenkonzept 98, Morgenbericht 19.10.
- **Abgelegt** in [`alt/`](alt/) (650.1, Chef 08.11., 13:36; erledigt oder ruhend, beim Wiedereinschalten zurückholen): Ablauf und Dateien (274), Grundstand 461 (Inhalt in DESIGN-STIL/-KAMPF/-ABNAHME), Ford 2, Build-Rechner auf Proxmox und Arbeitsorte (264), Prüfbogen Tester (186.3), Spielanleitung MARS 72.10a, MARS-Aufstellung (Regel in `LISTE-MARS.md`), Grafikweg (348), Zentrale Vorgangsliste Pro und Contra (275, überholt durch 275.2; Umstellung selbst: `tools/umstellung2752/README.md`), [Englisch-Korrekturliste](alt/LISTE-ENGLISCH-338-1B.md) (338.1b); seit 650.2 A (09.11.): Balance-Zielkurve (Grundsatz jetzt im Leitbild 3), Heldenbau (überholt durch das BRS), Anleitung der Kotlin-Fassung (352), Durchspielbogen (26).
