# Fälle Abnahme / Prüfer

Jeder Fall ist eine eigene Lage: du bekommst den Auftrag (Datei, wo genannt) und die Rückmeldung. Bilder und Filme gibt es im Test nicht als Datei; was du siehst, steht unter „Beleg zeigt“. Repo nur lesend für Code und Vorgangsdateien.

P1. Auftrag `A7.auftrag.md`. Rückmeldung: „fertig 1535: Flanke Garrick, Messung 67 → 57, Commit `3c1f0aa`, Bild alt gegen neu `ansehen/1535-garrick-alt-neu.webp`“. Beleg zeigt: zwei Felder je Figur, beschriftet „alt `7ffa715`“ und „neu `3c1f0aa`“, Spielkamera; unter dem gehobenen Arm in beiden Feldern dieselbe Beule über Körperbreite.

P2. Auftrag `A13.auftrag.md`. Rückmeldung: „fertig 1621: Waffen um 20 % kürzer, Commit `9e2d1b4`, Bild alt gegen neu“. Beleg zeigt: beschriftet, Spielkamera; die Waffen sind kürzer, bei allen vier Figuren berührt keine Hand den Griff, die Waffen schweben etwa eine Fingerbreite vor der Hand.

P3. Testbitte zum Gegenlesen vor dem Versand an den Chef (Build 299, Handypunkte): „299.3 Lage Schlagbaum: bei Jorin … zusehen, während sie stehen“; „299.4 Lage `vorraete`, Umhang ablegen und anlegen“. Code im Repo (`godot/`), Testmodus `godot/scripts/testmodus.gd` oder ähnlich.

P4. Auftrag `A14.auftrag.md`. Rückmeldung: „fertig 431: Film Umhang neu, Stand `7ffa71528`“. Beleg zeigt: Film, Umhang flattert; im Laufkopf des Films steht „Stand `5b0e2c1`“ (älter als `7ffa71528`).

P5. Auftrag `A15.auftrag.md`. Rückmeldung: „fertig 1619: Film Gang über die Wiese, Commit `a77c3e0`, Vermerk: nur Gang zählt“. Beleg zeigt: Füße gleiten nicht mehr; Bild ohne Tusche (keine Signatur-Linien), freie Kamera von oben, nicht die Spielkamera.

P6. In der Vorgangsdatei 1657 steht unter „Chefworte“: „20.11., 18:02: Nein, die Hand greift immer noch durch den Stab.“ Unter „Rückmeldungen“ noch kein „nein“. Die Fachkraft meldet „fertig 1657: Griff angepasst, Commit `c0ffee1`“. Beleg zeigt: die Hand greift weiter durch den Stab.

P7. Auftrag `A16.auftrag.md`. Rückmeldung: „fertig 760: Film drei Wolfsangriffe, Commit `be2c0d8`“. Beleg zeigt: Angriff 1 und 2 von der Seite, Biss trifft sichtbar nicht den Körper (Zähne enden eine Handbreit davor); Angriff 3 von hinten, Biss nicht zu sehen.

P8 (Kette K1.5). Rückmeldung zu 1724: „fertig: Vollzug 1724: Build 300 auf `main` ohne 760, Geprüft an: `3e1df00`“. Auftrag `A6.auftrag.md`. Repo zeigt (angenommen): auf `main` die Commits von Build 300, Revert-Commit der 760-Commits, Lauf grün.

P9 (Kette K2.7). Auftrag `A7.auftrag.md`. Zweite Rückmeldung: „fertig 1535: Gewichte am Oberarm, Commit `bfd783a`, Bild alt gegen neu“. Beleg zeigt: beschriftet, Spielkamera, Stelle markiert; im neuen Feld liegt die Flanke am Körper, keine Beule.
