# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARBEIT-ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 79**

**Seite „Dein Zug“ (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- Nichts von Tom (0.1.719 getestet und zusammengeführt, PR #56).

Rückfragen und Testfragen an den Nutzer stehen nur auf der Seite „Dein Zug“ (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](LISTE-IDEEN.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](DESIGN-STIL.md) · [Umgebung](ARBEIT-UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](ARBEIT-SELBST.md) · [Themen](LISTE-THEMEN.md): eine Zeile je Nummer · [Archiv](ARBEIT-ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2** Weck-Routinen (Jerry, Zeile unten). Regeln in `CLAUDE.md` (65.4 ein Ort, 65.7/65.8 kein „Erledigt“); Verlauf im Archiv |
| 13 | Diagonale Sicht | Tom | `claude/tom-73-laeden` | 13t auf `main` (PR #54); Tempelboden Steinplatten in 0.1.714. Verlauf im Archiv |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | – | Auf `main` (27.4, 5.3, 5.4, 5.6, 5n, 5la). Offen 5.5 (prüfen, ob noch etwas fehlt). Verlauf im Archiv |
| 13e | Höhle diagonal | Tom | – | Auf `main` (getestet 0.1.702). Offen nur Diogenes-Befunde der Höhle (Jerry) |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`, auch 24.8.6 (Türen 0,5 s). **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`LISTE-KAPITEL1.md`](LISTE-KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | **26c:** (1) 24.8.6/30.8, (2) 42, (3) Diagonalsicht erledigt (auf `main`), ebenso 55.2 und 17; Toms Teil von 26c fertig |
| 27 | Wald „Ort fertig“ (Liste in `DESIGN-ABNAHME.md`) | Tom | – | Wald und Tiefer Wald fest diagonal auf `main` (13v/27.6, PR #52). Offen: Lückenliste „Ort fertig“ mit Standbildern; **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise). Verlauf im Archiv |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1/30.2/30b/30.8 auf `main`. Offen: Abstürze beobachten (bei neuem Absturz `adb logcat` mit Anleitung von Tom); 30.7 (Klang 22 kHz) mit Jerry. Verlauf im Archiv |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x mit Bildschirmfoto (Wiese, alte Kampfansicht). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `DESIGN-BALANCE.md` fertig (38a–38d ja). **38e/38f ja (11:23):** Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (Reserve der Selbstarbeit). **38g ja (16:06):** Spieldauer zählt Diogenes (Zeile unten); 38h Eichung mit Uhr durch Nutzer später. Verlauf im Archiv |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nutzer 12.10., 09:52. Nach 38 („Normal“ erst festlegen). **39a ja (10:10):** Leicht/Normal/Schwer über Gegner-TP und -Schaden, jederzeit umstellbar. **62m ja:** auf Leicht Questziele gold ab Annahme; bei der Wahl jeden Unterschied genau erklären |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan; Plot Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | Rahmen Kapitel 2 (41a–p), **2a–2d und Station 1 (3a–3e: Kael, Südstraße, Fuhrmann Jorrit, Schilfrode mit/ohne Jorrit) ja (13.10.)**, **Station 2 Rabenschanze (4a–4d: Mauerbruch, Silber aus Aschfurt, Liste „Ring fehlt“, Hauptmann Vesk) ja (19:25)**; Figurenliste um Kapitel 2 mit Bauideen ergänzt (19:4x; Namen N1–N4 ja 19:50: Tobin, Fährmann Ansel, Merle, Händler Wendel) im [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d), Texte in `docs/STORY-REGELN.md`. Weiter: Kultlager |
| 72 | Profil und Marktvergleich: Mittelweg Rollenspiel/Kampf prüfen, Profil schärfen | Berater mit Nutzer | `main` (Notizen) | Auftrag Nutzer 13.10. (Sprachmodus); [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b) fertig (18:5x); mit Wirtschaft, SWOT, Porter, Positionierungskarte; offen 72a–72j (Profil, Kampf, Wunden, zweiter Weg, Schmied, Gruppenkämpfe, Preis, Unterstützerpaket, Beschleuniger, iOS) |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | Entschieden 13.10. (Beschlüsse): „Alle“ beim Kaufen weg, beim Verkaufen mit Abfrage (in 0.1.660). Vorrat je Laden erst mit 38/39, nie nach Zeit/Rast, Menge nach Schwierigkeitsgrad |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | `claude/tom-73-laeden` | Bis 62p auf `main` (PR #53). **62r A (Nutzer 20:4x):** „Orte“ weg, Reiter Karte öffnet Karte des Ortes, Hineintippen tiefer, Knopf oben rechts nennt das Ziel mit Pfeil nach oben; Tom baut jetzt. 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Kapitel 1 frei, Vollversion, nie Werbung/Beutekisten/Wartezeiten). **45b zurückgestellt** bis nach Messung 38. Verlauf im Archiv |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | **68a–68m ja (Nutzer 17:16–18:02):** Ablauf, Texte, Einstieg Kapitel 2 alles in `docs/STORY-K1.md` (`[68.…]`, auch `[67.schild]`, `[67.nach.…]` entfällt); Form `DESIGN-STIL.md` „Zwischensequenzen“ |
| 70 | Zwischensequenzen einheitlich (Intro 69, Tempel 68, spätere Wendepunkte) | Berater mit Nutzer | `main` (Notizen) | Nutzer 17:08: alle Zwischensequenzen ähnlich gebaut; Muster in `DESIGN-STIL.md` „Zwischensequenzen“ |
| 62q | Begriffe: Landkarte → Gebietskarte → Grundriss → **Ebene** (übereinander im Grundriss; „Stockwerk“ entfällt) | alle | – | **Ja (Nutzer 17:33)**, Regel in `CLAUDE.md` „Begriffe“; Tom/Jerry/Diogenes bitte so in Spiel, Prüflisten und Notizen |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | – | **69a–69d ja (Nutzer 13.10., 16:31):** Texte, Ablauf und Klang in `docs/STORY-K1.md` (`[69.intro.…]`), wortgetreu übernehmen |
| 76 | Tom und Jerry schärfen, `CLAUDE.md` entschlacken (Nutzer 13.10., 20:37) | Tom, Jerry | `main` (Notizen) | **Umgesetzt 13.10., 22:0x** nach [Entwurf](https://claude.ai/code/artifact/62e22141-83a5-40bc-8bde-80ba05a7db76) (Nutzer 21:52): `CLAUDE.md` gemeinsamer Kern, neu `ROLLE-ENTWICKLER.md`. Startaufträge in den Übergaben; danach streichen |
| 77 | Dokumentnamen ordnen, Story-Kennungen K1-H/N/Z/W (Nutzer 13.10., 21:10) | Tom (Code), Berater (77e) | `main` | **Umbenannt 13.10., 22:0x**, Wächter in `notiz.sh`. Codekommentare angepasst (Tom, Zweig `claude/festive-lovelace-3ujzqi`). **77e** [Entwurf](https://claude.ai/code/artifact/13e3b53a-e28d-40c1-9d94-30225272d38a): **77e.1–77e.6 ja (Nutzer 22:22)**, **Umbau läuft seit 13.10., 22:4x (Sokrates)**: bitte bis zur Fertigmeldung keine Notizdateien umstellen, nur eintragen; vor jedem Eintrag `git pull`. **Tom:** Vorgaben zu Leiste und Kartenrand (`LISTE-IDEEN.md` „Kapitel 2“) prüfen, ob sie nach 60 noch stimmen (77e.3) |
| 78 | Test-Builds bündeln (Nutzer 13.10., 21:35) | Tom | `main` (`.github`) | 78a/c/d ja, 78b nein (21:43); Regeln in `ROLLE-ENTWICKLER.md`. 78d umgestellt auf `claude/festive-lovelace-3ujzqi` (gilt auf `main` nach dem nächsten PR) |
| 74 | Schrittgeräusche fehlen an allen Orten („Ort fertig“ 8; Befund Diogenes D1.1) | Jerry (Klang); Tom für Dorf und Räume | – | Berater 13.10., 19:4x: Mangel gegen bestehende Regel, kein Beschluss nötig. **Verdacht** erst bestätigen; Böden je Untergrund (Gras, Erde, Holz, Stein) |
| 48 | Zufallsgenerierte Dungeons | Berater mit Nutzer; Jerry baut | – | 48a–48c ja (Einzelheiten im Archiv). **48d–48f ja (16:51):** je Spielstand nur Startwert plus **Version des Erzeugers** speichern (Updates verändern keine bestehende Höhle, alte Erzeuger bleiben im Code); Besiegtes und Geplündertes bleibt weg, neuer Auftrag darf dieselbe Höhle neu besetzen. Nach Kapitel 1 |
| 49 | Lehrer, Fertigkeiten, Talente | Berater mit Nutzer | – | 49d–49t ja ([Heldenbau](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)); **Dokument vom Nutzer freigegeben** (13.10., Namen fett markiert); abgelegt als `docs/DESIGN-HELDENBAU.md` (17:1x). Nach Kapitel 1 |
| 50 | Weitere Klassen (Klassenpaket, Werwolf als Fluch) | Berater mit Nutzer | – | 50a–50j ja (Matrix im Heldenbau, Verlauf im Archiv). Nach Kapitel 1 |
| 55 | Mehr Leerlauf für alle Leute (Waffe, Armhaltung), Szenen wie Sitzen am Tisch | Tom | – | 55.1a/b und 55.2 (Borin sitzt am Tisch) auf `main`. Offen: Speer überall etwa 2 m im Kampf mitprüfen. Verlauf im Archiv |
| 43 | Sichtbarkeit in der diagonalen Sicht (Leute, Ziele, Eingänge frei zur Kamera) | Tom (Wald, Dorf), Jerry (Höhle) | – | **43a ja:** Grundsatz in `DESIGN-STIL.md` („Ort fertig“ Punkt 9); Kisten dürfen versteckt sein. Morwen sichtbar, wenn Tiefer Wald diagonal (Tom); Höhle 13e (Jerry). Verlauf im Archiv |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry | – | Nutzer 12.10., 15:4x nach Test 0.1.587: Krogg fürs Erste so lassen, später alle Kampfanimationen gesamt überarbeiten. Nach Kapitel-1-Wichtigem. Dazu: Rudelwölfe beißen ins Leere (gemeldet 08.10., v0.1.210; Vorschlag im Archiv) |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 56 | Alte Objekte auf den neuen Karten | Tom | – | Auf `main` (PR #52); nur noch prüfen, ob etwas fehlt |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Angelegt 13.10. (Link oben), Regel in `CLAUDE.md`. Offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (13.10., 22:1x)
- Startauftrag 76–78 erledigt: Zweig `claude/festive-lovelace-3ujzqi` = `claude/tom-diogenes` + `main` + Kommentare (77) + Build-Auslöser (78d). Ab jetzt baut ein Zweig erst mit PR oder Knopfdruck.
- 0.1.719 (`claude/tom-diogenes`) grün, wartet auf Test (`e/t719.html`). Nach „passt“: PR vom neuen Zweig (enthält 719), zusammenführen.
- Weiter: D1.4 Wandkram flach, D1.5 Schatten Räume, D1.16 Entwurfsschalter; dann 6l, 68.
### Jerry (12.10., 16:59) – Pause bis Freitag

- **Startauftrag Berater (76–78, 13.10., 22:0x), vor allem anderen:** (1) Notizen umbenannt, `CLAUDE.md` neu; deine Startlektüre steht jetzt in `docs/ROLLE-ENTWICKLER.md` („Vor jeder Arbeit lesen“), bitte ganz lesen. (2) Im Zweig `claude/jerry-13e-hoehle-diagonal` (und jedem anderen) zuerst `git merge origin/main`. (3) Ab jetzt Sammelbuilds (höchstens 4 Punkte, Zweig höchstens 1 Tag, nie mit Tom gemischt) und „(Rückläufer: n)“ im `CHANGELOG.md`. Sonst nichts zu tun.
- **Nutzer 17:0x:** Nutzungsguthaben fast aufgebraucht, Jerry arbeitet erst ab Freitag weiter; Selbstarbeit beendet (`ARBEIT-SELBST.md`: fertig, Weck-Routinen beenden sich von selbst). Tom arbeitet allein weiter; Jerrys Themen (13e, 24.6, 30.7, 36.6, 38, 39, 40, 51–53) ruhen, nichts davon ist dringend.
- Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Einzelheiten im Archiv, 13e jetzt bei Tom).
- **Nutzer 12.10., 18:0x:** Jerry ohne Guthaben bis Fr., 03:00; Tom vertritt nicht von sich aus (genug eigene Arbeit); nur wenn eigene Arbeit an etwas von Jerry hängt, darf Tom das übernehmen (Übergabe hier).
- **13e liegt seit 13.10., 11:2x bei Tom (13y ja);** Jerry macht am Freitag mit 24.6, 30.7, 36.6, 38–40, 51–53 weiter.
## Zu testen

- **Tom, Diogenes-Befunde Lauf 1** (Prüfbericht oben): D1.4, D1.16 (Oberflächen) und D1.5 (Räume) auf `claude/festive-lovelace-3ujzqi`, im nächsten Sammelbuild; Rest von D1.16 (Schalter in `WorldScreen.kt` und Kerntests) offen.
- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5 Schatten Höhle, D1.6 Höhleneingang flach, D1.7 Leben Höhle, D1.8 stumme Quellen, D1.9 Feuer durch Wände, D1.10 Klang ohne Bewegung (mit Tom), D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (zwei Stücke mit Hörnern/Kreaturenrufen ohne sichtbare Quelle, `grund_fs_609422`, `grund_fs_540836`): Berater empfiehlt herausnehmen, **Nutzer entscheidet nach Hörprobe** (19:44): Höhle mit und ohne die zwei Stücke auf die Seite „Dein Zug“, erst danach ändern; D1.15 Laterne.
- **Jerry, Weck-Routinen pausieren** (Berater 13.10., Nutzer freigegeben): deine acht Routinen „Jerry Selbstarbeit HH:MM“ mit `update_trigger` (`enabled: false`) pausieren, nicht löschen; Regel in `ARBEIT-SELBST.md` „Feste Weck-Routinen“. Danach Zeile streichen.

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/ROLLE-TESTER.md`).

- **71 Bestandsprüfung Stil und Klang** (Nutzer 13.10., 18:16): Liste „Bestandsprüfung (71)“ in `ROLLE-TESTER.md`. **B** und **C** erledigt (Lauf 1 und 2, 13.10.); **A** erst, wenn Toms Wald- und Dorfzweige auf `main` sind (Nutzer 18:24).
- **38g Spieldauer Kapitel 1** (Berater 13.10., Nutzer 16:06 ja): beim Durchspielen je Abschnitt (Dorf, Wald, Tiefer Wald, Höhle, Rückkehr) zählen statt stoppen: gelaufene Felder, Kämpfe mit Runden, gelesene Dialogzeilen, Rasten, Menüaufrufe; Tabelle im Bericht. Berater rechnet daraus menschliche Spielzeit (38h Eichung durch Nutzer später).

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.




