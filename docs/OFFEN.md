# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 63** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](SELBST.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 13 | Diagonale Sicht | Tom | – | 13.4 auf `main` (PR #43). **13u/13w ja:** neue Orte nur diagonal, alte Ansicht eingefroren. **13v (später):** Testaufruf: Wald, Tiefer Wald, Höhle absichtlich noch gerade. **Meldung 08:43:** Tempel innen: Altar direkt vor dem Fenster, ansehen. **13s/13t ja:** 27, 13 Tempel, 42; Ziel „alte Ansicht ausgebaut“ (`KAPITEL1.md`), danach 6l. Verlauf im Archiv |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | `claude/tom-27-4-baeume` | 5.1/5.2/5g/5h.1 auf `main`. **5m ja:** 27.4, 5.6, 5.3, 5l/5.5, 5.4, dann 27.5/27.6, je erst Standbilder. 27.4, 5.6, 5.3 (alle zwölf), 5n in PR #48. 5.4 (Pflaster-Entwurf, Fensterlicht-Fix) auf dem Zweig. **5la** Tagesablauf (Pim, Bram, Gwenna, Liska) als Entwurf auf `claude/tom-5l-leben`, Build 0.1.640 |
| 17 | Nachschwingen: Umhang, Haare, Köcher, Riemen beim Stoppen und Drehen | Tom | – | **17a** auf `main` (PR #48, getestet 0.1.625); 58 auf `main` (PR #50). **17r** Haare/Köcher als Entwurf auf `claude/tom-17-nachschwingen` (Testreiter-Schalter), Build 0.1.639. Offen: Riemen |
| 13e | Höhle diagonal (Phase 2 von 13); mit 10 (Flammen feiner) und 11 (Lichtstrahl am Schacht) | Jerry | `claude/jerry-13e-hoehle-diagonal` | Grundsatz 43 (Leute, Ziele, Eingänge frei zur Kamera). **48b ja:** allgemein aus dem Kartenraster, ohne Handarbeit je Feld (für Zufallshöhlen 48). Eigene Datei `MapCaveIso.kt`, Toms Dateien nicht anfassen. Entwurf 2: Wände stehen (16:19); 13e.2–13e.4 in Selbstarbeit (`SELBST.md`). **Nutzer 16:3x:** Lichtstrahl weglassen, wenn schwierig; ein Versuch, sonst raus |
| 24 | Animationen fehlen nach Spielstart und Kartenwechsel; Zwischenbildschirm für Orte und Kämpfe | Tom (Technik); Jerry (Inhalt) | – | 24.1–24.4, 24.9–24.15 auf `main` (PR #30, #32, #34, #35); 24.8 Ortsklang auf `main` (PR #37). **Tom:** 24.5, 24.16–24.20 auf `main` (PR #40). 24.8.6 (Türen 0,5 s) auf `claude/tender-goodall-a8zuny`. **Jerry:** 24.8.5 auf `main` (PR #38, 12.10.), danach 24.6 Kampferöffnung wartet + Herzschlag (nach Toms 24.5), knapper Kampftext in `Battle.kt`. Entscheidungen 24f/24i/24j in [`ZWISCHENBILD.md`](ZWISCHENBILD.md) und im Archiv. |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`KAPITEL1.md`](KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | festgelegt 11.10., 16:50 (Berater); erledigte Punkte dort abhaken. **26c ja (Nutzer 18:3x), Toms Reihenfolge:** (1) 24.8.6 und 30.8 vom alten Zweig `tender-goodall-a8zuny` in den nächsten Build, (2) 42 Textkasten (erst Standbilder), (3) Diagonalsicht fertig: 27.5, Tiefer Wald diagonal (Morwen sichtbar, 43), Tempel-Altar, 27.6; dann 5l, 55.2, 17 |
| 27 | Wald „Ort fertig“ (Liste in `ENTWICKLUNG.md`): vor allem diagonale Zeichnung, Bäume rund | Tom | – | 27.1/27.2/27d, 27.4/27.5/27g, 27i, 27j auf `main` (getestet 0.1.625). **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise). Verlauf im Archiv |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1/30.2/30b auf `main` (PR #40, getestet 0.1.559). 30.8 „App aktualisiert“ auf `claude/tender-goodall-a8zuny` (kommt mit 26c in den nächsten Build). Offen: Abstürze beobachten; 30.7 (Klang 22 kHz) mit Jerry. Verlauf im Archiv |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x mit Bildschirmfoto (Wiese, alte Kampfansicht). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `BALANCE.md` fertig (38a–38d ja). **38e/38f ja (11:23):** Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (Reserve der Selbstarbeit). Verlauf im Archiv |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nutzer 12.10., 09:52. Nach 38 („Normal“ erst festlegen). **39a ja (10:10):** Leicht/Normal/Schwer über Gegner-TP und -Schaden, jederzeit umstellbar |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan: je Kapitel Zusammenfassung, Quests, Dialoge; dann Plot Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | 41a–41d ja: Entwurf Kapitel 1 steht ([Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)), fertige Kapitel als `docs/STORY.md`, Änderungen nur nach Abstimmung Nutzer und Berater; Regel „Story und Dialoge“ in `CLAUDE.md`, `tools/story.sh`. Kapitel 2 offen |
| 42 | Textkasten unten im Stil der Blenden: schwarzer Kasten, Sprecher in Gold, Text in gebrochenem Weiß (heute cremefarben mit dunkler Schrift, Sprecher rot) | Tom | – | Nutzer 12.10., 11:24 (über Berater). **42a ja:** erst nur Textkasten (Gespräch, Erzähltext, Aushänge), Menüs später. **42b ja:** ganz schwarz, dünner Goldrand, Sprecher Gold in Kapitälchen im Kasten, Text gebrochenes Weiß, Serife wie Blenden, Erzähltext kursiv, ▼ gold. **42c ja (11:39):** erst Standbilder. **42d:** Textkasten auf `main` (PR #48, getestet 0.1.625). Offen: Menüs später (42a) |
| 45 | Geschäftsmodell und Umsetzung (Play Store) | Berater mit Nutzer | `main` (Notizen) | **45a ja (12.10., 13:30):** Kapitel 1 kostenlos, dann einmal Vollversion, spätere Kapitel nachkaufbar. **45c ja:** nie Werbung, Beutekisten, Wartezeiten (Leitbild 13). **45b zurückgestellt:** Beschleuniger erst nach der Messung 38 (Berater denkt daran) |
| 48 | Zufallsgenerierte Dungeons (auch Questhöhlen?) | Berater mit Nutzer | – | Idee Nutzer 12.10., 14:0x. **48a–48c ja:** erst 48.3 Questhöhlen ganz zufällig (6–8 Kammern, verschlungen, Sackgassen, versteckter Rückweg), 48.2 später; Jerry baut 13e allgemein, prüft Beute gegen 38. Nach Kapitel 1 (Verlauf im Archiv) |
| 49 | Lehrer, Fertigkeiten, Talente | Berater mit Nutzer | – | Idee Nutzer 12.10., 14:1x. 49d–49s ja (Verlauf im Archiv, Liste im [Heldenbau](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)). **49t ja:** als `docs/HELDENBAU.md` ablegen, sobald der Nutzer die kursiven Namen durchgesehen hat. Nach Kapitel 1 |
| 50 | Weitere Klassen (Berserker, Kriegsmagier, Paladin, Werwolf …), ggf. zum Kauf | Berater mit Nutzer | – | Idee Nutzer 12.10., 14:2x, hängt an 45 und 49. 50a–50j ja: Klassenpaket, zwei Pfade je Klasse, Werwolf als Fluch, Merkmale und Herkunft (Verlauf im Archiv, Matrix im [Heldenbau](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)). Nach Kapitel 1 |
| 55 | Mehr Leerlauf für alle Leute (Waffe, Armhaltung) und Szenen wie Sitzen am Tisch in der Schänke | Tom | – | Nutzer 12.10., 15:5x. **55a ja:** 55.2 zuerst. **55.2 auf dem Zweig** (`SITDRAFT2`, Borin sitzt am Tisch, Sprungtest 0); **55c ja (20:1x):** ins Spiel. 55.1 offen (Verlauf im Archiv) |
| 43 | Sichtbarkeit in der diagonalen Sicht: was in der alten Karte gut zu sehen war (vor allem rechts), ist diagonal verdeckt (Garrick am Feuer, Feuerplatz, Kräuterhexe nicht sichtbar, Steinkreis) | Berater mit Nutzer (Grundsatz); Tom (Wald, Dorf), Jerry (Höhle) | `main` (Notizen) | Nutzer 12.10., 12:05: Karten je Ort umstellen, damit Leute und Wichtiges leicht sichtbar sind; Kisten dürfen versteckt sein und erst auftauchen, wenn der Held unter die Bäume geht. **43a ja (12:09):** Grundsatz in `STIL.md` (Karte und Räume, „Ort fertig“ Punkt 9). Kräuterhexe = Morwen im Tiefen Wald (Tom, wenn Tiefer Wald diagonal wird). Höhle 13e (Jerry) ebenso |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry | – | Nutzer 12.10., 15:4x nach Test 0.1.587: Krogg fürs Erste so lassen, später alle Kampfanimationen gesamt überarbeiten. Nach Kapitel-1-Wichtigem |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 56 | Alte Objekte auf den neuen Karten (Nutzer 12.10., 18:3x) | Tom | `claude/tom-27-4-baeume` | **56a–56c ja (19:4x):** Kräuter, Truhe, Steine, Steinkreis, Büsche im Wald ins Spiel (Schalter entfernt, c2b909f7). **56d ja (20:1x):** Dorf (`YARDDRAFT`, `FERNDRAFT`) ins Spiel; Innenräume ohne Altes |
| 57 | Entscheidungsseite nur mit Offenem; Entschiedenes ins gemeinsame Bildbuch | Tom | `main` (Notizen) | Ablauf in `CLAUDE.md`. Entscheidungsseite Tom: https://claude.ai/artifact/WRX6B7eYg8woV22pufbG3F · Bildbuch: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM (Nutzer gibt es für Jerry frei) |

| 59 | Händler: Kauf/Verkauf im Stil des Textkastens, Übersicht, Vergleich | Tom | `claude/tom-59-haendler` | 59a–59d ja (Verlauf im Archiv): schwarzer Laden, nicht Tragbares abgedunkelt, Streifen Angelegt, Vergleich, Rückkauf, Menge. Build 0.1.632, Test steht aus |
| 60 | Ein Aussehen für alle Oberflächen wie Textkasten/Blende (schwarz, Gold, Serife) | Tom | `claude/tom-60-aussehen` | 60a–60d ja (Verlauf im Archiv). Entwürfe Schrift, Titel, Menü, Heldenerstellung, Kampf im Testreiter „60 Aussehen“, Build 0.1.636; Rückfragen 60e–60i |
| 61 | Spuren, die bleiben: Blut, Fußspuren, Staub (Vorrat 7) | Tom | `claude/tom-7-spuren` | Entwurf, Build 0.1.646; Rückfrage 61a |
| 62 | Gezeichnete Karte im Menü (Vorrat 8) | Tom | `claude/tom-7-spuren` | Entwurf, Build 0.1.646; Rückfragen 62a/62b |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (13.10., 03:20) – Selbstarbeit läuft
- **Zu testen** (nach 59 und 60): 0.1.639 (17r), 0.1.640 (5la), 0.1.641 (6g), 0.1.643 (6f), 0.1.646 (61a/62a), je ein Testreiter-Schalter. Rückfragen auf der Entscheidungsseite (Empf. je ja).
- **61 Spuren** und **62 Kartenansicht** (Vorrat 7/8) fertig als Entwurf auf `claude/tom-7-spuren` (Build 0.1.646). Ursache „Fußspuren unsichtbar“: sie lagen in der Vorschau unter Busch und Bäumen; Gang verlegt, Abdrücke kräftiger, Schlamm in Räumen hell.
- **Weck-Kette am Ende** (03:15): diese Sitzung ist auf Stufe 8 von 8, `send_later` und `create_session` gehen nicht mehr. Weiter nur über die Routinen (06:24) oder eine neue Sitzung des Nutzers.
- Vorrat 9 (29) und 10 (5l) sind schon erledigt. **27.6c** Rauchfahne als Entwurf auf `claude/tom-27-6-tiefer-wald` (Bild auf der Entscheidungsseite). Weiter: 27.6b Schild, dann 17 Riemen.

### Jerry (12.10., 16:59) – Pause bis Freitag

- **Nutzer 17:0x:** Nutzungsguthaben fast aufgebraucht, Jerry arbeitet erst ab Freitag weiter; Selbstarbeit beendet (`SELBST.md`: fertig, Weck-Routinen beenden sich von selbst). Tom arbeitet allein weiter; Jerrys Themen (13e, 24.6, 30.7, 36.6, 38, 39, 40, 51–53) ruhen, nichts davon ist dringend.
- Zweig `claude/jerry-13e-hoehle-diagonal` (nur Vorschau hinter `MapCaveIso.draft`, kein Build, kein PR): **13e.3 fertig** (Lichtstrahl aufrecht `drawCaveShaft`, Fackeln an der Wand mit 32-Bild-Flamme `drawCaveTorches`; Bilder 16:41, 16:50 gezeigt). **13e.4 halb:** Stalagmiten/Geröll als Höhenfeld (`relief`), Weiher abgesenkt mit Ufer; Kerntest grün, Bilder noch nicht angesehen (`tools/t bild KARTENZOOM=1 DIAG=1 CAVEDRAFT=1 ONLY=zoom_nah_c`, Aufnahmen c5, c7–c9).
- **Nutzer 12.10., 18:0x:** Jerry ohne Guthaben bis Fr., 03:00; Tom vertritt nicht von sich aus (genug eigene Arbeit); nur wenn eigene Arbeit an etwas von Jerry hängt, darf Tom das übernehmen (Übergabe hier).
- **Weiter (Freitag):** Bilder 13e.4 prüfen (Geröll zu eiförmig? Weiher noch zu sehr Boden), Lückenliste „Ort fertig“, dann Rückfrage 54a erledigt.
## Zu testen

- **Tom, 0.1.632, Zweig `claude/tom-59-haendler`** (59, https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38309898552): bei Thessa und Morwen kaufen/verkaufen, Menge ×5/Alle, verkaufen und zurückkaufen, Ausrüstung vergleichen, Streifen „Angelegt“ und „Nicht tragbar“.
- **Tom, 0.1.636, Zweig `claude/tom-60-aussehen`** (60, enthält 59; erst 59 testen; https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38313842737): Testreiter „60 Aussehen“ an, Schrift, Titelschrift und Kampfzahlen durchschalten; Titelbild, Menü/Beutel, Heldenerstellung, Kampf ansehen.
- **Tom, 0.1.639, Zweig `claude/tom-17-nachschwingen`** (17r, https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38320963573; nach 59/60): Testreiter „17 Haare/Köcher schwingen nach“ an, als Heldin oder mit Bogen laufen und anhalten.
- **Tom, 0.1.640, Zweig `claude/tom-5l-leben`** (5la, https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38322497262; nach 59/60): Testreiter „5l Tagesablauf im Dorf“ an, im Dorf ein paar Minuten zusehen, Leute ansprechen, ob jemand im Weg steht.
- **Tom, 0.1.641, Zweig `claude/tom-katze`** (6g, https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38324348750; nach 59/60): Testreiter „Katze in der Schänke“ an, in der Schänke gut drei Minuten zusehen.
- **Tom, 0.1.643, Zweig `claude/tom-6-farbstimmung`** (6f, https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38326167073; nach 59/60): Testreiter „Farbstimmung je Ort“ an, Höhle, Schänke abends, Dorf in der Dämmerung ansehen.
- **Tom, 0.1.646, Zweig `claude/tom-7-spuren`** (61a/62a, https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38331553728; nach 59/60): Testreiter „Spuren“ an, Kampf gewinnen (Blut), im Regen gehen (Fußspuren), auf trockenem Weg rennen (Staub); Testreiter „8 Gezeichnete Karte im Menü“ an (Thema 62), Menü → Karte.

## Rückfragen an den Nutzer

- **60e–60i** (Tom, [Entscheidungsseite](https://claude.ai/artifact/WRX6B7eYg8woV22pufbG3F)): 60e Textschrift (Empf. Alegreya), 60f Titel (Empf. Cinzel), 60g Menü, 60h Heldenerstellung, 60i Kampf mit Pixelzahlen (Empf. je ja).
- **27.6a–c** (Tom, [Entscheidungsseite](https://claude.ai/artifact/WRX6B7eYg8woV22pufbG3F)): Tiefer Wald diagonal (Morwens Feuer frei) übernehmen, Schild auf die Südseite des Wegs, Rauchfahne am Kräuterfeuer als Entwurf (Empf. je ja).
- **13x** (Tom, Entscheidungsseite): Tempel: zwei Fenster links und rechts vom Altar statt einem dahinter (Empf. ja).
- **17r** (Tom, Entscheidungsseite): lange Haare und Köcher schwingen nach dem Anhalten nach wie der Umhang (Empf. ja).
- **5la** (Tom, Entscheidungsseite): Tagesablauf im Dorf, Bewohner wechseln stündlich den Platz (Empf. ja).
- **6g** (Tom, Entscheidungsseite): Katze in der Schänke (schläft am Herd, streckt sich, wechselt den Platz) ins Spiel (Empf. ja).
- **6f** (Tom, Entscheidungsseite): Farbstimmung je Ort und Tageszeit ins Spiel (Empf. ja).
- **61a, 62a, 62b** (Tom, Entscheidungsseite): Spuren ins Spiel (Empf. ja); gezeichnete Karte als Menüreiter (Empf. ja); 62b Auftragszeichen auf der Karte (Empf. erst ohne).


- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). **Zurückgestellt** (Nutzer 11.10., 13:00), bis die Umstellung auf die diagonale Sicht mit allen Facetten fertig ist.
