# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 77**

**Seite „Dein Zug“ (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- **Tom 0.1.712** (Zweig `claude/tom-73-laeden`, Build läuft): 73 Läden zu, 62r Knopf „↑ Gebietskarte/Landkarte“, 3b Garrick; Prüfliste `e/t712.html`. 0.1.709 getestet und auf `main` (PR #54).

Rückfragen und Testfragen an den Nutzer stehen nur auf der Seite „Dein Zug“ (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](SELBST.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2** Weck-Routinen (Jerry, Zeile unten). Regeln in `CLAUDE.md` (65.4 ein Ort, 65.7/65.8 kein „Erledigt“); Verlauf im Archiv |
| 13 | Diagonale Sicht | Tom | `claude/tom-73-laeden` | 13t auf `main` (PR #54). Tempelboden Steinplatten fertig (kommt mit dem nächsten Build). Offen: Tempel-Altar vor dem Fenster (Meldung 08:43, ansehen), 42; danach 6l. Verlauf im Archiv |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | – | Großteil auf `main` (PR #52: 27.4, 5.6, 5.3, 5n, 5la Tagesablauf). Offen nach **5m:** 5.4 Pflaster, 5l/5.5, dann 27.5/27.6, je erst Standbilder. Verlauf im Archiv |
| 13e | Höhle diagonal | Tom | – | Auf `main` (getestet 0.1.702). Offen nur Diogenes-Befunde der Höhle (Jerry) |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`. 24.8.6 (Türen 0,5 s) auf `claude/tender-goodall-a8zuny`. **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`KAPITEL1.md`](KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | **26c ja:** (1) 24.8.6 und 30.8 vom Zweig `tender-goodall-a8zuny` in den nächsten Build, (2) 42, (3) Diagonalsicht fertig (27.5, Tiefer Wald, Tempel-Altar, 27.6); dann 5l, 55.2, 17 |
| 27 | Wald „Ort fertig“ (Liste in `ENTWICKLUNG.md`) | Tom | – | Wald und Tiefer Wald fest diagonal auf `main` (13v/27.6, PR #52). Offen: Lückenliste „Ort fertig“ mit Standbildern; **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise). Verlauf im Archiv |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1/30.2/30b auf `main` (PR #40, getestet 0.1.559). 30.8 „App aktualisiert“ auf `claude/tender-goodall-a8zuny` (kommt mit 26c in den nächsten Build). Offen: Abstürze beobachten (Nutzer 13.10.: seit Langem keine mehr; kein Android Studio, bei neuem Absturz `adb logcat` mit Anleitung von Tom); 30.7 (Klang 22 kHz) mit Jerry. Verlauf im Archiv |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x mit Bildschirmfoto (Wiese, alte Kampfansicht). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `BALANCE.md` fertig (38a–38d ja). **38e/38f ja (11:23):** Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (Reserve der Selbstarbeit). **38g ja (16:06):** Spieldauer zählt Diogenes (Zeile unten); 38h Eichung mit Uhr durch Nutzer später. Verlauf im Archiv |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nutzer 12.10., 09:52. Nach 38 („Normal“ erst festlegen). **39a ja (10:10):** Leicht/Normal/Schwer über Gegner-TP und -Schaden, jederzeit umstellbar. **62m ja:** auf Leicht Questziele gold ab Annahme; bei der Wahl jeden Unterschied genau erklären |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan; Plot Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | Rahmen Kapitel 2 (41a–p), **2a–2d und Station 1 (3a–3e: Kael, Südstraße, Fuhrmann Jorrit, Schilfrode mit/ohne Jorrit) ja (13.10.)**, **Station 2 Rabenschanze (4a–4d: Mauerbruch, Silber aus Aschfurt, Liste „Ring fehlt“, Hauptmann Vesk) ja (19:25)**; Figurenliste um Kapitel 2 mit Bauideen ergänzt (19:4x; Namen N1–N4 ja 19:50: Tobin, Fährmann Ansel, Merle, Händler Wendel) im [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d), Texte in `docs/STORY.md`. Weiter: Kultlager |
| 72 | Profil und Marktvergleich: Mittelweg Rollenspiel/Kampf prüfen, Profil schärfen | Berater mit Nutzer | `main` (Notizen) | Auftrag Nutzer 13.10. (Sprachmodus); [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b) fertig (18:5x); mit Wirtschaft, SWOT, Porter, Positionierungskarte; offen 72a–72j (Profil, Kampf, Wunden, zweiter Weg, Schmied, Gruppenkämpfe, Preis, Unterstützerpaket, Beschleuniger, iOS) |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | Entschieden 13.10. (Beschlüsse): „Alle“ beim Kaufen weg, beim Verkaufen mit Abfrage (in 0.1.660). Vorrat je Laden erst mit 38/39, nie nach Zeit/Rast, Menge nach Schwierigkeitsgrad |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | `claude/tom-73-laeden` | Bis 62p auf `main` (PR #53). **62r A (Nutzer 20:4x):** „Orte“ weg, Reiter Karte öffnet Karte des Ortes, Hineintippen tiefer, Knopf oben rechts nennt das Ziel mit Pfeil nach oben; Tom baut jetzt. 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Kapitel 1 frei, Vollversion, nie Werbung/Beutekisten/Wartezeiten). **45b zurückgestellt** bis nach Messung 38. Verlauf im Archiv |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | **68a–68m ja (Nutzer 17:16–18:02):** Ablauf, Texte, Einstieg Kapitel 2 alles in `docs/STORY1.md` (`[68.…]`, auch `[67.schild]`, `[67.nach.…]` entfällt); Form `STIL.md` „Zwischensequenzen“ |
| 70 | Zwischensequenzen einheitlich (Intro 69, Tempel 68, spätere Wendepunkte) | Berater mit Nutzer | `main` (Notizen) | Nutzer 17:08: alle Zwischensequenzen ähnlich gebaut; Muster in `STIL.md` „Zwischensequenzen“ |
| 62q | Begriffe: Landkarte → Gebietskarte → Grundriss → **Ebene** (übereinander im Grundriss; „Stockwerk“ entfällt) | alle | – | **Ja (Nutzer 17:33)**, Regel in `CLAUDE.md` „Begriffe“; Tom/Jerry/Diogenes bitte so in Spiel, Prüflisten und Notizen |
| 3b | Garrick links vom Feuer, Gesicht zur Kamera | Tom | `claude/tom-73-laeden` | Nutzer 17:10; fertig, kommt mit dem nächsten Build |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | – | **69a–69d ja (Nutzer 13.10., 16:31):** Texte, Ablauf und Klang in `docs/STORY1.md` (`[69.intro.…]`), wortgetreu übernehmen |
| 73 | Versperrte Hütten: nachts Läden zu, Rauch | Tom (Dorf) | `claude/tom-73-laeden` | 73a ja; Kaminrauch auf `main` (PR #54). Läden mit Ritzenlicht in 0.1.712. **73b A (Nutzer 20:5x):** Rauch heißt bewohnt, Verschlossene rauchen weiter; Antwort von drinnen beim Anklopfen braucht Texte (Zeile „Für den Berater“) |
| 75 | Diogenes: Kosten und Nutzen des Testens (Nutzer 13.10., 20:43: „so viel testen wie nötig, so wenig wie möglich“) | Berater mit Nutzer | `main` (Notizen) | Rolle fertig (`DIOGENES.md`); Entwurf im Archiv „Entwurf Berater 75h“; offen 75h–75l |
| 76 | Tom und Jerry schärfen, `CLAUDE.md` durch Auslagern entschlacken (Nutzer 13.10., 20:37) | Berater mit Nutzer | `main` (Notizen) | Entwurf im Archiv „Entwurf Berater 76“; offen 76a–76d |
| 74 | Schrittgeräusche fehlen an allen Orten („Ort fertig“ 8; Befund Diogenes D1.1) | Jerry (Klang); Tom für Dorf und Räume | – | Berater 13.10., 19:4x: Mangel gegen bestehende Regel, kein Beschluss nötig. **Verdacht** erst bestätigen; Böden je Untergrund (Gras, Erde, Holz, Stein) |
| 48 | Zufallsgenerierte Dungeons | Berater mit Nutzer; Jerry baut | – | 48a–48c ja (Einzelheiten im Archiv). **48d–48f ja (16:51):** je Spielstand nur Startwert plus **Version des Erzeugers** speichern (Updates verändern keine bestehende Höhle, alte Erzeuger bleiben im Code); Besiegtes und Geplündertes bleibt weg, neuer Auftrag darf dieselbe Höhle neu besetzen. Nach Kapitel 1 |
| 49 | Lehrer, Fertigkeiten, Talente | Berater mit Nutzer | – | 49d–49t ja ([Heldenbau](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)); **Dokument vom Nutzer freigegeben** (13.10., Namen fett markiert); abgelegt als `docs/HELDENBAU.md` (17:1x). Nach Kapitel 1 |
| 50 | Weitere Klassen (Klassenpaket, Werwolf als Fluch) | Berater mit Nutzer | – | 50a–50j ja (Matrix im Heldenbau, Verlauf im Archiv). Nach Kapitel 1 |
| 55 | Mehr Leerlauf für alle Leute (Waffe, Armhaltung), Szenen wie Sitzen am Tisch | Tom | – | 55.1a/b auf `main` (PR #52). **55c ja:** 55.2 Borin sitzt am Tisch (`SITDRAFT2`) ins Spiel; Speer überall etwa 2 m (Kampf mitprüfen). Verlauf im Archiv |
| 43 | Sichtbarkeit in der diagonalen Sicht (Leute, Ziele, Eingänge frei zur Kamera) | Tom (Wald, Dorf), Jerry (Höhle) | – | **43a ja:** Grundsatz in `STIL.md` („Ort fertig“ Punkt 9); Kisten dürfen versteckt sein. Morwen sichtbar, wenn Tiefer Wald diagonal (Tom); Höhle 13e (Jerry). Verlauf im Archiv |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry | – | Nutzer 12.10., 15:4x nach Test 0.1.587: Krogg fürs Erste so lassen, später alle Kampfanimationen gesamt überarbeiten. Nach Kapitel-1-Wichtigem |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 56 | Alte Objekte auf den neuen Karten | Tom | – | Auf `main` (PR #52); nur noch prüfen, ob etwas fehlt |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Angelegt 13.10. (Link oben), Regel in `CLAUDE.md`. Offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (13.10., 20:0x) – an Nachfolger
- 0.1.709 getestet und zusammengeführt (PR #54), Schalter in `UMGEBUNG.md` gestrichen. 0.1.712 auf `claude/tom-73-laeden` (73 Läden, 62r, 3b), Prüfliste `e/t712.html`; Tempelboden (13) dort schon committet, kommt mit dem nächsten Build.
- Zweig `claude/tom-73-laeden` (= 13t + 3b + 73 Läden): dort 62r (A) bauen, dann nächster Build; danach 6l, 68.
### Jerry (12.10., 16:59) – Pause bis Freitag

- **Nutzer 17:0x:** Nutzungsguthaben fast aufgebraucht, Jerry arbeitet erst ab Freitag weiter; Selbstarbeit beendet (`SELBST.md`: fertig, Weck-Routinen beenden sich von selbst). Tom arbeitet allein weiter; Jerrys Themen (13e, 24.6, 30.7, 36.6, 38, 39, 40, 51–53) ruhen, nichts davon ist dringend.
- Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Einzelheiten im Archiv, 13e jetzt bei Tom).
- **Nutzer 12.10., 18:0x:** Jerry ohne Guthaben bis Fr., 03:00; Tom vertritt nicht von sich aus (genug eigene Arbeit); nur wenn eigene Arbeit an etwas von Jerry hängt, darf Tom das übernehmen (Übergabe hier).
- **13e liegt seit 13.10., 11:2x bei Tom (13y ja);** Jerry macht am Freitag mit 24.6, 30.7, 36.6, 38–40, 51–53 weiter.
## Zu testen

- **Tom, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen; Prüfbericht oben): D1.2 Tempel nachts zu hell, D1.3 Licht/Flamme ohne Gegenstück, D1.4 Wandkram flach, D1.5 Schatten Räume, D1.11 Varianten/Mehrfeld-Möbel, D1.12 Lesepult zu hoch, D1.13 Aldric vor dem Herd, D1.16 Entwurfsschalter.
- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5 Schatten Höhle, D1.6 Höhleneingang flach, D1.7 Leben Höhle, D1.8 stumme Quellen, D1.9 Feuer durch Wände, D1.10 Klang ohne Bewegung (mit Tom), D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (zwei Stücke mit Hörnern/Kreaturenrufen ohne sichtbare Quelle, `grund_fs_609422`, `grund_fs_540836`): Berater empfiehlt herausnehmen, **Nutzer entscheidet nach Hörprobe** (19:44): Höhle mit und ohne die zwei Stücke auf die Seite „Dein Zug“, erst danach ändern; D1.15 Laterne.
- **Tom, Diogenes-Befunde Lauf 2** (Klasse 1, Verdachte, Vermerk im Prüfbericht): D2.1 Kapitelende alt (hoch), D2.2 Anschlagbrett hell, D2.3 Englisch im Vergleich, D2.4 englische Begriffe (Oberfläche), D2.6 Farben außerhalb der Palette, D2.7 Untertitel kursiv, D2.8 Überlauf ohne „…“, D2.9 Gitter im Höhlengrundriss, D2.10 Bach treppig, D2.11 Vorschau `MENUE`, D2.12 Laden.
- **Jerry, Weck-Routinen pausieren** (Berater 13.10., Nutzer freigegeben): deine acht Routinen „Jerry Selbstarbeit HH:MM“ mit `update_trigger` (`enabled: false`) pausieren, nicht löschen; Regel in `SELBST.md` „Feste Weck-Routinen“. Danach Zeile streichen.

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/DIOGENES.md`).

- **71 Bestandsprüfung Stil und Klang** (Nutzer 13.10., 18:16): Liste „Bestandsprüfung (71)“ in `DIOGENES.md`. **B** und **C** erledigt (Lauf 1 und 2, 13.10.); **A** erst, wenn Toms Wald- und Dorfzweige auf `main` sind (Nutzer 18:24).
- **38g Spieldauer Kapitel 1** (Berater 13.10., Nutzer 16:06 ja): beim Durchspielen je Abschnitt (Dorf, Wald, Tiefer Wald, Höhle, Rückkehr) zählen statt stoppen: gelaufene Felder, Kämpfe mit Runden, gelesene Dialogzeilen, Rasten, Menüaufrufe; Tabelle im Bericht. Berater rechnet daraus menschliche Spielzeit (38h Eichung durch Nutzer später).

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.
- **41/73b Texte** (Tom 13.10., 20:5x): Nach 73b A antwortet beim Anklopfen an verschlossenen bewohnten Häusern (Bäcker Edrik, Kael, Gwenna, Schmied Dorran, Pim) jemand von drinnen; heute steht dort z. B. bei Kael „Niemand öffnet.“ (`Story.kt` `lockedDoor`). Bitte Antworten je Haus, ggf. nach Tageszeit, in `STORY1.md` festlegen; Tom baut sie dann ein.

- **41 Story-Texte (Diogenes D2.13, D2.4 Chronik-Teil):** „Bugbear“ im deutschen Text und fehlendes Verb in der Chronik; englische Namen uneinheitlich (Morning Light/Dawnlight, herbwoman/Herbalist). Steht so in `STORY1.md`; Nutzer und Berater entscheiden.



