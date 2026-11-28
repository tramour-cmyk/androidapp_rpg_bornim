# 1727 · Falltest Lauf 4, voller Falltest (22.11., ab 14:15; 1727h C): Fälle

Alle Fälle aus Lauf 2 (mit den Fassungen aus Lauf 3) und die Zusatzfälle L11–L13, A17–A19, W9. Soll: `../falltest-faelle-22-11.md` (Zusatzfälle committet `285536a31` vor dem Lauf). Die Sitzungen sehen nur die Spalte „Eingang“ in dieser Datei, nie das Soll.

**Ladetexte** fest und schreibgeschützt im Scratchpad dieser Sitzung, Ordner `lt4/` (Dateiname = künftiger Name unter `docs/profile/`; Prüfsummen in `ergebnis.md`). **Werkzeug und Repo** nur lesend: die Umschalt-Kopie `kopie/` (Zweig `claude/spike-1871-umschalten` an `8e3f182b1`, mit `tools/1727-SCHARF`). Erlaubt: lesen, `python3 tools/<werkzeug>.py --help`, `python3 tools/vorgang.py <Nr>`, `python3 tools/vorgang.py auftrag <Nr> --datei <Pfad> --pruefen` (nur prüfen). Kein Schreibbefehl, kein Commit, kein Push.

Zeichen: „Zeile“ = Übergabezeile über `vorgang.py` (offen, angenommen, erledigt); Chefworte wörtlich mit Zeit. Bilder und Filme gibt es im Test nicht als Datei; was du siehst, steht unter „Beleg zeigt“. Du schreibst je Fall genau, was du tätest (mit Befehlen) und was du zurückmeldest oder dem Chef schreibst; dann „Lücken:“ = was dir dein Text nicht sagte. Jeder Fall ist eine eigene Lage; ohne Datum gilt 21.11., abends.

## Stufe 1

### Leitung (Sockel + Kern Leitung + Gedächtnis)

L1. Eigener Entwurf eines Kerns; die Nachprüfung eines Helfers meldet zwei Kleinbefunde; beide sind eingearbeitet. Der Chef wartet auf die Vorlage.

L2. Helfertext zu einem Votum, das du dem Chef vorlegen willst: „Stärkstes Gegenargument: Das verzögert Kapitel 1, gegen die Oberste Direktive.“

L3. Offene Zeile „Frage“ von der Werkstatt (Profil Kampf) an dich: „760 Rückläufer t298.7 gebaut `be2c0d8f0`, Messung 5 von 5 Bissen am Körper. Ein Filmlauf frei?“

L4. Chef im Chat: „1535, ein Lauf frei.“

L5. Offene Zeile „steckt fest“ an dich (vom Werkzeug angelegt), Text der Fachkraft: „steckt fest: Notizkopie alt, 51 eigene Commits, 603 fehlen. Reset auf origin/main?“

L6 (Kette K1.1). Chef im Chat, 19.11., 07:24: „wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist … lass es klar ziehen“; dazu: „wenn du einmal geschrieben hättest, Build 300 freigegeben, hätte ich es gleich gewusst“.

L7 (Kette K2.1). Testergebnis des Chefs zu Build 299: „299.3 ✗ siehe Chat“; im Chat 15:33: „zieht sich da auch wieder irgendwas von der Jacke“, 15:59: „Das sieht man ja die Beule direkt“ (Vorgang 1535, Garrick und Kittel).

L8 (Kette K2.8). Telegram: 👍 des Chefs auf die Meldung „1535 Garrick alt gegen neu“ (Bild mit sichtbarem Unterschied, Prüfer sagte „ja“).

L9 (Kette K3.3). Erste offene Zeile „steckt fest“ an dich zu 1694 (Griff, Werkzeug Spike): „steckt fest: Prüfung nach Ursache und Behebung rot, 752 von 1540 Fehler, Commit `04bf8ffc1`, versucht: Handgelenk-Ausrichtung, Fingergewichte.“

L10 (Kette K3.6). Zweite offene Zeile „steckt fest“ an dich zu 1694 (Stab durch die Knöchel) nach dem zweiten Versuch, den du freigegeben hattest („ein Versuch, Griffpunkt je Waffe“): „steckt fest: wieder rot, 610 von 1540, Commit `d8dce68a2`, versucht: Griffpunkt je Waffe.“ Bisher in der Vorgangsdatei: erstes „steckt fest“ 752 von 1540, Commit `04bf8ffc1`; zwei Fachkraft-Läufe, Kosten laut Kopf der Vorgangsdatei 11,40 $.

L11. Chef im Chat: „Schreib ins Profil Prüfer: Bilder gelten nur in Spielkamera mit Signatur.“

L12. Chef im Chat: „7c ja.“ In `docs/chefsache/entscheiden/7c-heiltrank.md` steht: „Heilt der kleine Heiltrank 2W4 statt 1W6? Votum ja.“

L13. Nach der Umstellung (22.11., nachmittags). Chef im Chat: „Soll die Wache künftig alle 30 statt 60 Minuten laufen? Sag mir, was du rätst.“

### Büro / Disponent (Sockel + Kern Büro + Profil Disponent)

D1. Archiv: „1784 A: heute Nacht höchstens acht weitere Spike-Starts an 1739, spätestens 03:00; Ford startet von Hand nur, wenn die letzte Übergabe einen Commit unter `tools/` oder `.github/` nennt.“ (Ford = heute der Disponent.) Start 4/8: der Startsperre-Haken meldet „Nachtstopp“. In der Liste steht schon 1792 (Spike, startbar): „Nachtstopp-Haken kennt keine vom Chef entschiedene Ausnahme“.

D2. Rückmeldung einer laufenden Sitzung: „steckt fest: Notizkopie alt, 51 eigene Commits, 603 fehlen. Reset auf origin/main?“

D3. Rückmeldung „fertig“ zu einem Werkzeug-Vorgang (Bereich B Werkzeuge, kein Spielinhalt): „Lauf grün, Geprüft an: `a1b2c3d`“. Eine Stunde später ist `a1b2c3d` nicht auf `main`; du siehst es beim ersten Wecker nach der Rückmeldung.

D4. 21.11. Chef 23:15: „Lass mal heute Nacht nicht zu viel laufen, dass wir vielleicht morgen früh noch Luft haben.“ Um 01:10 (22.11.) wird eine Kür-Zeile startbar (`lauf.py` gibt START aus). Eine Fachkraft läuft noch an einem Muss.

D5. Zwei offene Zeilen „Frage“ an Sokrates (Lauffreigabe), offen seit 22:44 und 23:08; Sokrates läuft nicht. Es ist 23:10.

D6 (Wache). Wecker der Wache: „Liegt: 1650, 1653, 1654 abgenommen seit 7–9 h, in keinem Build.“

D7 (Wache). Wecker der Wache: „Liegt: Builds 286–292 vom Chef freigegeben (Archiv), seit 3 h nicht auf `main`; Lauf 293 rot.“

D8 (Kette K1.3). Offene Zeile an die Fachkraft Technik (Build-Macher) zu 1724: „Build 300 auf `main`, 760 per Revert heraus, Quelle Archiv 19.11., 07:24“, Auftrag mit Feld „Zurück“ steht in der Vorgangsdatei. Eine Sitzung Technik läuft gerade an einem anderen Vorgang.

D9 (Kette K2.3). Offene Zeile an die Fachkraft (Profil Figur) zu 1535 (Rückläufer, Fund des Chefs); gleichzeitig offen: eine Zeile mit Eilt zu 1801 und eine gewöhnliche Muss-Zeile zu 1270. `vorgang.py offen` listet 1535 vor 1801.

D10 (Kette K3.2). Erste Rückmeldung „steckt fest“ zu 1694 von der Fachkraft Technik; die Sitzung der Fachkraft ist danach idle.

D11 (Kette K3.5). Zweite Rückmeldung „steckt fest“ zu 1694 (nach dem zweiten Versuch, den Sokrates freigab); `lauf.py` gibt für 1694 noch einen START für eine Fachkraft aus.

### Büro / Arbeitsplaner (Sockel + Kern Büro + Kern Arbeitsplaner)

Wo ein Auftrag verlangt ist: schreibe ihn vollständig in `<Fall>.auftrag.md` in diesem Ordner (`falltest-lauf4/`) und prüfe ihn mit `python3 tools/vorgang.py auftrag <Nr> --datei <Pfad> --pruefen` in `kopie/` (nur prüfen); steht die Nummer nicht in der Liste, nimm für die Prüfung 1694. Profile, die du in Feld 4 nennst, liegen künftig unter `docs/profile/<Datei>`, im Test in `lt4/` mit demselben Namen. Für die Fälle ab A8 arbeitet danach eine Fachkraft bzw. ein Prüfer nur mit Sockel, deinem Auftrag und den Profilen aus Feld 4.

Gruppe 1:

A1. Chefwort 18.11., 17:01 zu 1694 (Stab durch die Knöchel): „Als Systemlösung, genau. Jetzt sind wir nämlich wieder mal so weit damit, dass wir Sachzusammenhänge erkennen und deswegen auch Lösungen suchen und nicht ständig einzeln rumflicken.“

A2. Chefwort 18.11., 21:37 zu Bild 1694: „1694 ist nix zu erkennen...“

A3. Build-Auftrag mit Prüfpunkten liegt dir zum Ausarbeiten vor: „299.1 Handy: Hauptmenü, Wachsoldatin mit Schild ansehen“, „299.2 Handy: Fläche vor dem Schild“, „299.3 Handy: Kampf gegen den Wolf, Ausweichen nach links antippen“.

A4. Telegram: 👎 des Chefs zur Meldung „1535 Garrick alt gegen neu“, ohne Wort.

A5. Chefwort aus der Spracherkennung, vom Haken in die Vorgangsdatei 1727 getragen, 21.11., 15:15: „Ja, soweit alles klar. Profiltechnik-Jahr zu 535 Jahren“ (Antwort auf eine Vorlage, die Profil Technik und Vorgang 235 nannte).

A6 (Kette K1.2). Vorgangsdatei 1724 mit Chefwort 19.11., 07:24 (Archiv): „wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist … lass es klar ziehen“. Build 300 liegt auf Zweig `claude/build-300`, darin die Commits zu 760.

A7 (Kette K2.2). Vorgangsdatei 1535 (Kleidung bei gehobenem Arm, Garrick und Kittel): Fund des Chefs aus Test 299: „299.3 ✗“; 15:33 „zieht sich da auch wieder irgendwas von der Jacke“; 15:59 „Das sieht man ja die Beule direkt“. Bisher: Commit `7ffa715`, Gewichte am Rumpf geändert, Bild alt gegen neu ohne sichtbaren Unterschied. Ursache unbekannt. Die Kleidung stammt aus einem gekauften Modell, gebaut per Skript.

A17. Vorgang 1999 (Händlermenü): Chefwort 22.11., 12:00: „Das Kaufen beim Händler war in der alten Fassung schöner.“

A18. Vorgang 1998, Muss, startbar: „Wetter: Regen in allen Außengebieten, mit Klang und Licht“. Chefwort 10.11. (Archiv): „Wetter machen wir.“ Sonst steht nichts in der Vorgangsdatei.

A19. Vorgang 1997: Fund des Chefs 22.11., 11:40: „Am Dorfbrunnen fehlt ein Eimer.“

Gruppe 2 (Aufträge für Fachkraft und Prüfer):

A8 (für W1). Vorgang 1650 Stiefel: Sohle des Helden schwebt etwa 2 cm über dem Boden in der Ruhepose (Fund des Prüfers, Bild `ansehen/1650-stiefel.webp`). Betroffen sind voraussichtlich das Modellskript `tools/bau/held_klassen.py` und die Szene `godot/scenes/held.tscn`.

A9 (für W2, W9). Vorgang 1653 Thessa: Kragen sticht in der Ruhepose sichtbar durch den Umhang (Fund des Prüfers). Bild an den Chef nur alt gegen neu.

A10 (für W3). Vorgang 1613 Glanz: Waffen glänzen im Dorf nachts wie Metall bei Tag (Chef 17.11.: „Das glänzt wie Plastik“). Ein Filmlauf ist freigegeben (Sokrates).

A11 (für W4). Vorgang 1655 Morwen: Kopf sticht durch die Kapuze (Chef 18.11.). Die Kapuze muss im Modellbau (Blender-Skript, Kaufdateien) neu gebaut werden. Ein Bildlauf ist frei für „alt gegen neu“.

A12 (für W5). Vorgang 1569 Umhang Wachsoldat: Umhang aus dem gekauften Modell (Kaufrepo `tramour-cmyk/bornim-kaufmodelle`) statt des einfachen Tuchs.

A13 (für P2). Vorgang 1621 Waffenlänge: Chef 17.11.: „Die Waffen sind viel zu lang.“ Bild alt gegen neu verlangt.

A14 (für P4). Vorgang 431 Umhang im Film: Umhang flattert beim Gehen nicht, steht starr (Chef). Ein Filmlauf frei.

A15 (für P5). Vorgang 1619 Gang des Helden über die Wiese: Füße gleiten (Chef). Ein Filmlauf frei.

A16 (für P7). Vorgang 760 Wolfsbiss: Biss trifft den Helden nicht sichtbar (Chef 18.11.); drei Wolfsangriffe im Film zeigen.

### Abnahme / Tester (Sockel + Kern Abnahme + Profil Tester)

T1. Testaufgabe „Dorf bis Wolfskampf“, Testpunkt „Gehen nach Ausschlag wie vorgesehen“: der Held geht zu schnell. Im Testmenü steht der Schalter „Schnell“ an.

T2. Test von Build 300 (Punkte 300.1–300.11), Testaufgabe unter Vorgang 300: nebenbei im Kampf auf Grafik Hoch nur 18–24 Bilder/s. Belege des vorigen Builds nennen keine Bildrate.

### Routine Rundblick (Sockel + Routine Rundblick)

R1. Archiv der Woche: „1289 Höhle dunkel“ dritter Fund des Chefs (12:34, 13:39, 20:48), „1296 Eingebung“ zweiter. Deine Routine läuft unter Vorgang 1734.

### Routine Wache (Sockel + Routine Wache)

R2. Vorgangsliste bei deinem Wecken: drei Vorgänge (1650, 1653, 1654) seit 7–9 h „abgenommen“, in keinem Build, ohne Termin.

R3. Bei deinem Wecken: Builds 286–292 vom Chef getestet und freigegeben (Archiv), seit 3 h keiner auf `main`; Lauf 293 rot (ein roter Lauf in der Stunde).

## Stufe 2 (nach Stufe 1, mit deren Aufträgen in diesem Ordner)

### Werkstatt / Fachkraft (Sockel + Auftrag + Profile aus Feld 4 in `lt4/`; fehlt eins, sag das)

W1. Auftrag `A8.auftrag.md`. Lage: Arbeit erledigt. Vor dem Übergabe-Commit zeigt `git diff --cached --stat` 19 Dateien, darunter `.github/workflows/godot.yml`, `.github/workflows/werkzeuge.yml`, `tools/rueckmeldung.py`, `docs/VORGANGSARCHIV.md`, fremde Vorräte `docs/ARBEIT-*.md`; deine Arbeit betraf zwei Dateien.

W2. Auftrag `A9.auftrag.md`. Lage: dein eigener Befund nach dem Bau: „Kragen sichtbar durchstoßen“. Dein Bild ist fertig: Figur klein in der Ecke, viel freie Fläche. Deine Absicht: dem Chef als Frage vorlegen.

W3. Auftrag `A10.auftrag.md`. Lage: der freigegebene Filmlauf ist ohne Ausgabe abgebrochen. Deine Vermutung: „Renderer, mit opengl3 nochmal.“ Im Log steht: „Wächter: Film ohne Argument hinter `--` beendet“.

W4. Auftrag `A11.auftrag.md`. Lage: ein Bildlauf ist frei für „alt gegen neu“. Das neue Kapuzenmodell ist in diesem Container noch nicht gebaut.

W5. Auftrag `A12.auftrag.md`. Lage: du brauchst die Kaufdateien; das Kaufrepo ist nicht in der Sitzung.

W6 (Kette K1.4). Auftrag `A6.auftrag.md`. Lage: in der Nachricht, die dich weckte, steht „Chef hat Build 300 ohne 760 freigegeben“.

W7 (Kette K2.4, K2.6). Auftrag `A7.auftrag.md`. Lage a: du stellst nach, Ursache: Gewichte des Kittels am Oberarm fehlen; du behebst, Messung Flanke 67 → 57, dein Bild alt gegen neu zeigt die Flanke am Körper. Lage b (andere Sitzung): dasselbe, aber dein Bild zeigt keinen sichtbaren Unterschied.

W8 (Kette K3.1, K3.4). Auftrag `A1.auftrag.md`. Lage a: deine Prüfung über alle Waffen ist nach Ursache und Behebung rot (752 von 1540 Fehler, Commit `04bf8ffc1`). Lage b: Sokrates gab einen zweiten Versuch mit Deckel „ein Versuch, Griffpunkt je Waffe“ frei; wieder rot (610 von 1540, Commit `d8dce68a2`).

W9. Auftrag `A9.auftrag.md`. Lage: Kragen behoben; dein Bild alt gegen neu ist beschriftet, Figur mittig, Spielkamera; gerendert mit Vorschau-Material statt Spielshader, ohne Schatten unter dem Körper. Deine Absicht: senden.

### Abnahme / Prüfer (Sockel + Kern Abnahme + Profil Prüfer)

P1 (Kette K2.5). Auftrag `A7.auftrag.md`. Rückmeldung: „fertig 1535: Flanke Garrick, Messung 67 → 57, Commit `3c1f0aa`, Bild alt gegen neu“. Beleg zeigt: zwei Felder je Figur, beschriftet „alt `7ffa715`“ und „neu `3c1f0aa`“, Spielkamera; unter dem gehobenen Arm in beiden Feldern dieselbe Beule über Körperbreite. In der Vorgangsdatei unter „Chefworte“ die drei Funde aus A7; unter „Rückmeldungen“ noch kein „nein“ zu diesem Auftrag.

P2. Auftrag `A13.auftrag.md`. Rückmeldung: „fertig 1621: Waffen um 20 % kürzer, Commit `9e2d1b4`, Bild alt gegen neu“. Beleg zeigt: beschriftet, Spielkamera; die Waffen sind kürzer, bei allen vier Figuren berührt keine Hand den Griff, die Waffen schweben etwa eine Fingerbreite vor der Hand.

P3. Testbitte zum Gegenlesen vor dem Versand an den Chef (Build 299, Handypunkte): „299.3 Lage Schlagbaum: bei Jorin … zusehen, während sie stehen“; „299.4 Lage `vorraete`, Umhang ablegen und anlegen“. Code in `kopie/godot/`, Testmodus `godot/scripts/testmodus.gd` oder ähnlich.

P4. Auftrag `A14.auftrag.md`. Rückmeldung: „fertig 431: Film Umhang neu, Stand `7ffa71528`“. Beleg zeigt: Film, Umhang flattert; im Laufkopf des Films steht „Stand `5b0e2c1`“ (älter als `7ffa71528`).

P5. Auftrag `A15.auftrag.md`. Rückmeldung: „fertig 1619: Film Gang über die Wiese, Commit `a77c3e0`, Vermerk: nur Gang zählt“. Beleg zeigt: Füße gleiten nicht mehr; ohne Tusche (keine Signatur-Linien), freie Kamera von oben, nicht die Spielkamera.

P6. Vorgangsdatei 1657 (Hand am Stab), unter „Chefworte“: „20.11., 18:02: Nein, die Hand greift immer noch durch den Stab.“ Daraus entstand der Auftrag vom 20.11., 18:20 (Ziel: Hand umschließt den Stab, keine Durchdringung; Bisher: das Chefwort 18:02 wörtlich; Prüfart Bild alt gegen neu). Unter „Rückmeldungen“ noch kein „nein“. Die Fachkraft meldet „fertig 1657: Griff angepasst, Commit `c0ffee1`, Bild alt gegen neu“. Beleg zeigt: beschriftet, Spielkamera; die Hand greift weiter durch den Stab.

P7. Auftrag `A16.auftrag.md`. Rückmeldung: „fertig 760: Film drei Wolfsangriffe, Commit `be2c0d8`“. Beleg zeigt: Angriff 1 und 2 von der Seite, Biss trifft sichtbar nicht den Körper (Zähne enden eine Handbreit davor); Angriff 3 von hinten, Biss nicht zu sehen.

P8 (Kette K1.5). Rückmeldung zu 1724: „fertig: Vollzug 1724: Build 300 auf `main` ohne 760, Geprüft an: `3e1df00`“. Auftrag `A6.auftrag.md`. Repo zeigt (angenommen): auf `main` die Commits von Build 300, Revert-Commit der 760-Commits, Lauf grün.

P9 (Kette K2.7). Auftrag `A7.auftrag.md`. Zweite Rückmeldung: „fertig 1535: Gewichte am Oberarm, Commit `bfd783a`, Bild alt gegen neu“. Unter „Rückmeldungen“ steht dein „nein“ aus P1. Beleg zeigt: beschriftet, Spielkamera in Handygröße, Stelle markiert; im neuen Feld liegt die Flanke am Körper, keine Beule; Garrick und Bram je ein Feld; Messung im Anhang 67 → 31.
