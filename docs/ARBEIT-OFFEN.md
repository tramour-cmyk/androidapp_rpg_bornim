# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARBEIT-ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 85**

**Ford: Co-Pilot** (Nutzer 14.10., 16:02; 81g; Stellung aus / Co-Pilot / Pilot, Startlektüre `ROLLE-FORD.md`)

**Seite „Dein Zug“ (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- **Tom Sammelbuild 0.1.734** (ersetzt 0.1.732; 5.5, 27m.1–27m.5, Waldrand West; PR #60, Zweig `claude/tom-5-5-dorf-luecken`): [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38589813704/artifacts/11908081091), Prüfliste `e/t732.html` auf „Dein Zug“ (nur Punkt 6 nachtesten). Nach „passt“: PR #60 zusammenführen, `CHANGELOG.md`, t732 und `e/5-5.html` von „Dein Zug“, hier leeren.

- **Tom Sammelbuild 0.1.733** (82, 52, 80a, D1.5/D1.10/D1.11; PR #61, Zweig `claude/tom-d1-schatten`, nach t732 testen): [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38576807017/artifacts/11902500727), Prüfliste `e/t733.html`. Nach „passt“: PR #61 zusammenführen, `CHANGELOG.md`, t733 von „Dein Zug“, hier leeren.

Rückfragen und Testfragen an den Nutzer stehen nur auf der Seite „Dein Zug“ (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](LISTE-IDEEN.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](DESIGN-STIL.md) · [Umgebung](ARBEIT-UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](ARBEIT-SELBST.md) · [Themen](LISTE-THEMEN.md): eine Zeile je Nummer · [Archiv](ARBEIT-ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 82 | Verschlossene Tür: Held verschwand beim Anklopfen hinter der Hauswand (Nutzer 14.10., 15:5x, Pims Haus); alle Zugänge | Tom | `claude/tom-d1-schatten` | Behoben (f088ebd0): Tür mit Bedingung zählt beim Laufen als Wand, Dagegenlaufen klopft an; gilt für alle bedingten Zugänge außer Umkehr am Kartenrand; Kerntest. Kommt in den nächsten Sammelbuild |
| 81 | Teamleiter „Ford“ (Nutzer 14.10., 13:09) | Berater mit Nutzer | `main` (Notizen) | Beschlossen 81a–c, 81g–n (`ROLLE-FORD.md`). Co-Pilot seit 16:02; Ursache 18:0x: Routine läuft in einer Cowork-Umgebung ohne Schlüssel, nicht in „Voll“/„Telegram“; Test aus Sitzung „Voll“ gesendet; Routine 18:10 neu in „Voll“ (`trig_013heqXJ1KkkxTYVzmTcpzaf`, :28), alte abgeschaltet; Probelauf 18:12: Klonen und Schlüssel ok; Telegram-Test 17:59 kam an (Nutzer). Telegram-Weg steht. Pilot und Bewährung (81i) auf Zuruf; Jerry-Ford ab Fr. |
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2:** Jerry pausiert seine acht Weck-Routinen „Jerry Selbstarbeit HH:MM“ (`enabled: false`, nicht löschen). **65.8** Rückfragen als Holschuld (Nutzer 14.10., 17:2x): nur auf „Dein Zug“, im Chat nur einmal bei Entstehung und ein Satz beim Start, aufzählen auf „Hast du Rückfragen?“; Aufträge anderer Agenten einmal mit Stellungnahme, „Kritisch“ nur bei Stillstand (Nutzer 17:3x); in `CLAUDE.md`. **65.9** Startmeldung höchstens drei Zeilen, Berater-Ritual verschlankt (Nutzer 17:3x); Weiter-Haken schweigt bei Sokrates/Diogenes (Nutzer 17:3x ja); „Vorrat leer, auf Dein Zug n offen von mir“ (Nutzer 17:4x) |
| 13e | Höhle „Ort fertig“ (Vertretung Jerry, Nutzer 14.10., 16:0x) | Tom | `claude/tom-13e-hoehle-fertig` | D1.9, D1.5, D1.6 fertig (Kerntests); 13e.5 passt (Beschlüsse); **13e.6 = B** (Nutzer 14.10., 17:5x): kein Heldenlicht, Höhle nur aus eigenen Quellen; umgesetzt (Entwurf zurückgenommen, Höhle ohne Heldenlicht, Standbilder lesbar); Fackel als Gegenstand → 84.1. Sammelbuild PR #62 (Build läuft, Prüfliste t735 folgt); danach D1.7 Leben (Vorschlag mit Standbild) |
| 13 | Diagonale Sicht | Tom | `claude/tom-73-laeden` | 13t auf `main` (PR #54). Verlauf im Archiv |
| 83 | Dorf Süd: weder die eingezäunten Beete im Westen noch die Weizenfelder im Osten zu sehen; Bäume wegnehmen oder andere Lösung? (Nutzer 14.10., 17:3x, Test t732) | Tom | – | Neu. Erst Standbild der Stelle, dann Vorschlag (Bäume lichten, Durchsicht, Kamera) auf „Dein Zug“ |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | `claude/tom-5-5-dorf-luecken` | Auf `main` bis 5la. **5.5** Marktstand und Fahrspuren auf dem Zweig (`e/5-5.html`); Lichtfleck Ost kein Fehler |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`. **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`LISTE-KAPITEL1.md`](LISTE-KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | **26c:** (1) 24.8.6/30.8, (2) 42, (3) Diagonalsicht erledigt (auf `main`), ebenso 55.2 und 17; Toms Teil von 26c fertig |
| 27 | Wald „Ort fertig“ (Liste in `DESIGN-ABNAHME.md`) | Tom | `claude/tom-5-5-dorf-luecken` | 27l/27m auf `main` (PR #59). **27m.1–27m.5** in PR #60; Rückläufer Waldrand West behoben (f6b5d224), Build 0.1.734 beim Nutzer (t732 Punkt 6). **Rückläufer Nord** (Nutzer 14.10., 17:45, Standbild vorher/nachher): Westrand besser, Nordrand (Nordwestecke beim Höhleneingang) noch schwarz: der Boden davor war nie gesehen; behoben 5ca7c655 (hinter dem Rand nie dunkler als „gesehen“), Build läuft. **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise) |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1/30.2/30b/30.8 auf `main`. Offen: Abstürze beobachten (bei neuem Absturz `adb logcat` mit Anleitung von Tom); 30.7 bewusst gelassen (Merkliste) |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x mit Bildschirmfoto (Wiese, alte Kampfansicht). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `DESIGN-BALANCE.md`. Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (38e/38f); Spieldauer zählt Diogenes (38g, Zeile unten); 38h Eichung durch Nutzer später |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m). Beschlüsse |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan; Texte Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d) Kapitel 2 fertig (ohne 5b). [Textentwurf](https://claude.ai/code/artifact/3dfb1fb7-3230-41aa-8c9e-a1ae94c5c413) beim Nutzer; offen 4.4, 5.3, 6.3 |
| 72 | Profil und Marktvergleich | Berater mit Nutzer | `main` (Notizen) | [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b) fertig. **72b Kampfsystem neu** ([Dokument](https://claude.ai/code/artifact/af5851da-790c-46ce-a6da-98dbcf5f10b4)): Rückfragen 72k–72o beim Nutzer; Nutzer 16:55: zu kämpferlastig, Attribute sollen wirken, Gedanken folgen; Vorschlag Abstand nah/fern und Attribute im Dokument (17:2x). 72.5 ja. Offen 72a, 72c–72j |
| 84 | Licht und Laut (Nutzer 14.10., 17:5x; baut auf Idee 4 in `LISTE-IDEEN.md` und `Perks.kt` auf) | Berater mit Nutzer | `main` (Notizen) | **84.1** Fackel als Gegenstand (Laden, nimmt die Nebenhand); **84.2** Schnellwechsel zweier Handbelegungen; **84.3** Schleichen; **84.4** Lauschen beim Stehen: Welle am Helden zur Quelle hin, Stärke = Deutlichkeit (Nutzer 18:0x), Wort nur bei deutlichem Hören; nicht für Sichtbares; Stufen Stehen > Schleichen > Gehen > Rennen (Nutzer 18:1x: „sehr gut“). Empfehlung im Gespräch 14.10.; Kampfteile mit 72b |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | Entschieden 13.10. (Beschlüsse): „Alle“ beim Kaufen weg, beim Verkaufen mit Abfrage (in 0.1.660). Vorrat je Laden erst mit 38/39, nie nach Zeit/Rast, Menge nach Schwierigkeitsgrad |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | `claude/tom-73-laeden` | Bis 62r auf `main` (PR #53, #55). 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Beschlüsse). 45b zurückgestellt bis nach 38 |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | 68a–68m ja: Texte in `STORY-K1.md` (`[68.…]`), Wegweiser `[67.schild]` in `STORY-K1-W.md`; Form `DESIGN-STIL.md` „Zwischensequenzen“. Bildentwurf gemalt mit 69 auf `claude/tom-69-intro` (Figuren Platzhalter), hängt an **69e** |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | `claude/tom-69e-musterbild` | 69a–69d ja (`STORY-K1.md` `[69.intro.…]`). **69e vierte Runde** (`e/69e-4.html`, Vorschau `BRUECKE69E=1`): Sokrates ja als Musterbild für Blick, Stoffe, Licht ; die drei Korrekturen sind eingebaut (Tom 14:33: Laterne auf dem Pfosten am Ufer, Mond frei, beide Geländer ab Ufer); Nutzer entscheidet. Danach 70.3 |
| 70 | Zwischensequenzen: Bildsprache für alle Kapitel (Nutzer 14.10., 08:00) | Berater mit Nutzer; Tom (69e) | `main` (Notizen) | Entschieden (Beschlüsse, `DESIGN-STIL.md`): 70.1 Musterbild nach 69e; 70.2, 70.4, 70.5 ja; 70.3 nach Stilwahl im Test-Build |
| 79 | Kampfhintergründe an die Diagonalwelt angleichen (Nutzer 14.10., 08:34) | Berater mit Nutzer; Jerry (Bilder) | – | Nur Aussehen (Nutzer 09:08), Aufbau des Kampfbildes gehört zu 72b. Erst Standbild (Jerry ab Fr.), dann Entwurf nach Musterbild 70.1 |
| 80 | Kaels angesengte Laterne neben seiner Haustür im Dorf (Aussehen `LISTE-FIGUREN.md`) | Tom | `claude/tom-80a-sockel` | 80a gebaut (Sockel mit Zeichen A, nachts Bernsteinlicht), **passt** (Nutzer 14.10., 15:5x, Beschlüsse); kommt in Toms nächsten Sammelbuild |
| 74 | Schrittgeräusche fehlen an allen Orten („Ort fertig“ 8; Befund Diogenes D1.1) | Tom (Vertretung für Jerry, Nutzer 14.10., 13:3x) | `claude/tom-74-schritte` | Punkt 74 von „Dein Zug“ genommen (Nutzer 18:0x). Hörprobe (Nutzer 17:3x): Gras, Holz, Stein passen; **Erde** klingt wie Pflaster, **Pflaster** sehr stumpf → beide neu wählen, zweite Hörprobe. **74a** (Rückfrage Nutzer): bei schnellen Bewegungen immer ein Schritt? Antwort geben: ein Klang je Aufsetzen des Fußes, beim Rennen dichter und etwas leiser, keine Überlappung. Dann einbauen (nur Held). Danach Vorrat 7, 5; Jerry ab Fr. |
| 55 | Mehr Leerlauf für alle Leute (Waffe, Armhaltung), Szenen wie Sitzen am Tisch | Tom | – | 55.1a/b und 55.2 (Borin sitzt am Tisch) auf `main`. Kampf geprüft 14.10.: Held 2 m (Dress, wächst mit der Größe), Skelett ebenso; Kobold (80 cm) ~0,9 m; **55d** so lassen (Nutzer 14.10., 07:0x, Beschlüsse). Verlauf im Archiv |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry; Rudelwölfe Tom (Vertretung) | `claude/tom-52-rudel` | Krogg so lassen, später alle gesamt (Jerry). **Rudelwölfe beißen ins Leere** behoben, **passt** (Nutzer 14.10., 15:5x, Beschlüsse); kommt in Toms nächsten Sammelbuild |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Angelegt 13.10. (Link oben), Regel in `CLAUDE.md`. Offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (14.10., 17:5x)
- Folgt (Sitzung läuft): Sammelbuild 13e, dann 74a/Erde/Pflaster, dann 83.
### Jerry (12.10., 16:59; gekürzt 77e) – Pause bis Freitag, 03:00

- **Startauftrag Berater (76–78, 13.10., 22:0x), vor allem anderen:** (1) Notizen umbenannt, `CLAUDE.md` neu; deine Startlektüre steht jetzt in `docs/ROLLE-ENTWICKLER.md` („Vor jeder Arbeit lesen“), bitte ganz lesen. (2) Im Zweig `claude/jerry-13e-hoehle-diagonal` (und jedem anderen) zuerst `git merge origin/main`. (3) Ab jetzt Sammelbuilds (höchstens 4 Punkte, Zweig höchstens 1 Tag, nie mit Tom gemischt) und „(Rückläufer: n)“ im `CHANGELOG.md`. Sonst nichts zu tun.
- Pause bis Fr., 03:00 (Guthaben); Selbstarbeit beendet. Tom vertritt nicht von sich aus, nur wenn eigene Arbeit an Jerrys Themen hängt. Ab Fr. weiter mit 24.6, 36.6, 38–40, 51–53; 13e liegt seit 13y bei Tom; Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Einzelheiten im Archiv).
## Zu testen

- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5/D1.6/D1.9/D1.15 Höhle bei Tom (13e); D1.7 Leben Höhle, D1.8 stumme Quellen, D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (`grund_fs_609422`, `grund_fs_540836`, Hörner/Kreaturen ohne Quelle): Berater empfiehlt herausnehmen, **Nutzer entscheidet nach Hörprobe** (Höhle mit und ohne auf „Dein Zug“), erst danach ändern.

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/ROLLE-TESTER.md`).

- **71 Bestandsprüfung Stil und Klang** (Nutzer 13.10., 18:16): Liste „Bestandsprüfung (71)“ in `ROLLE-TESTER.md`. **B** und **C** erledigt (Lauf 1 und 2, 13.10.); **A** erst, wenn Toms Wald- und Dorfzweige auf `main` sind (Nutzer 18:24).
- **38g Spieldauer Kapitel 1** (Berater 13.10., Nutzer 16:06 ja): beim Durchspielen je Abschnitt (Dorf, Wald, Tiefer Wald, Höhle, Rückkehr) zählen statt stoppen: gelaufene Felder, Kämpfe mit Runden, gelesene Dialogzeilen, Rasten, Menüaufrufe; Tabelle im Bericht. Berater rechnet daraus menschliche Spielzeit (38h Eichung durch Nutzer später).

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.
- **26 Ausgleich Magier** (Tom für Jerry, 14.10.; Simulation: Magier 45 % gegen Grak, mit Zauber Schild 78–87 %; Entwurf `claude/tom-26-magier-schild`, im Spiel aus; Bosse auf Stufe 5–6 über Ziel 50–65 %). Zurückgestellt (Nutzer 16:02): wird mit 72b entschieden (Schild als Reaktion des Magiers).


