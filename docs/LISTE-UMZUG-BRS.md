# Umzug auf das BRS (870): Master-Plan

Sokrates, 10.11.2026 (Auftrag Chef 14:03, 14:08: „federführend … Master-Umzugsplan … soll jetzt schon Hand und Fuß haben. Und dann muss dein Plan irgendwer gegenlesen“). Geprüft an `origin/main` dcc60878f (10.11., 14:31), drei Bestandsaufnahmen im Code (Regeln und Kampf, Skripte, Tests/Texte/Kotlin). Regelwerk: [`DESIGN-BRS.md`](DESIGN-BRS.md). Regelfragen: 870a 1–8, entschieden 10.11. (Archiv), in `DESIGN-BRS.md` nachgetragen. Gegenlesen: Diogenes (870.1).

**Ziel:** Im Godot-Spiel gibt es nur noch das BRS. Kein SRD-Wert, kein SRD-Begriff, kein Umschalter, keine Brücke.
**Fertig, wenn** (1) die Suche (Wächter, Schritt 9) im Godot-Code und in allen Spieltexten nichts mehr findet, (2) der Chef ein neues Spiel von der Erschaffung über das Dorf bis zum Wolfskampf und zur Höhle nur mit BRS spielt und dabei nichts Altes sieht, (3) der Hinweis „SRD 5.1 · CC BY 4.0“ aus dem Godot-Spiel heraus ist.

## 1. Befund: wie weit wir wirklich sind

Ehrlich gesagt: weniger weit, als meine Vorlage 870 (14:05) behauptete. Dort stand „schon BRS: Erschaffung, Fertigkeiten, Treffer und Schaden im Kampf“. Das stimmt nur für Regeln und Testmenü, nicht für das Spiel:

- **„Neues Spiel“ öffnet die alte Erschaffung** (`hauptmenue.gd` 297, 359–364 → `erschaffung.gd`): Volk, Klasse, Punktkauf 8–15. Die BRS-Erschaffung (`erschaffung_brs.gd`) erreicht man nur über das Testmenü, und ihr Ergebnis wird verworfen (`spiel.gd` 1143–1157). Umschalten ist mit 470 vorbereitet (Zweige `spike-470-erschaffung`, `tom-brs-held`), aber nicht auf `main`.
- **Der Kampf rechnet nach SRD.** BRS nur mit der Umgebungsvariable `BRS478=1` oder dem Testmenü-Schalter (`brs_kampf.gd` 16). Auch dann laufen Initiative, Flucht, Rettungswürfe, alle Zauber außer Funkenpfeil und alle Klassenfähigkeiten weiter mit W20 und SRD-Würfeln, nur umgerechnet (`mars.gd` 366, 1095–1143, 1001–1040, 1544–1566).
- **Der Held ist ein Doppelwesen:** `spiel.gd` 24 `werte: Heldwerte` (Klasse, STR–CHA, RK, Übungsbonus, Zauberpunkte, Trefferwürfel) wird von allem gelesen: Menü, Vergleich, Beute, Laden, Leiste, Rast, Ausdauer, Herde, Ruf, Kampfblatt. Der BRS-Held (`zustand.brs`) wird gespeichert, aber nur im Kampf hinter dem Schalter gelesen; bei jedem Spielstand aus dem Hauptmenü ist er leer.
- **Erfahrung und Stufenaufstieg nach SRD** (`lohn.gd`: xpForLevel, Attributspunkte, neue Klassenfähigkeit). Die BRS-Erfahrung (`brs.gd` 98–185) ruft nur ein Test auf.
- **Gegenstände nach SRD** (`beute.gd`): „+1…+3“, Zusatzwerte RK, ZP, STR–CHA, Filter nach Klasse; Güte und Zustand fehlen.
- **Daten und Texte kommen zum Teil aus der Kotlin-Fassung:** `daten/held.json` (Klassen, Völker, Punktkauf) und `daten/texte.json` (RK, ZP, Übungsbonus, „Wähle deine Klasse“, Kurze/Lange Rast, Handbuch `Guide.kt`, SRD-Lizenztext) erzeugt der Godot-Bau aus `core/` (`godot.yml` 52–65). `regeln/tabellen.json` ist ganz SRD (15 Monster mit RK/CR/Würfeln, 21 Klassenfähigkeiten, Probehelden).
- **Spielstände:** Feld `version` wird geschrieben, nie gelesen; keine Umrechnung; `Heldwerte.aus_daten` liest `klasse`, `zp`, `offen` ohne Vorgabe. Jeder heutige Spielstand enthält nur den SRD-Helden.
- **Klassischer Kampfmodus (212 A) gibt es in Godot nicht.** `regeln/klassisch.gd` ruft nur ein Test auf; „klassisch“ in `bedienung.gd` ist die Steuerung (663).
- **Umfang:** etwa 40 Spielskripte mit SRD-Stellen, davon tragend `heldwerte.gd`, `mars.gd`, `aufruf.gd` (`blatt()` 169–189), `beute.gd`, `menue.gd`, `lohn.gd`, `tabellen.json`; etwa 70 Tests bauen auf `Heldwerte`, 6 Goldtests prüfen SRD gegen Kotlin.
- **Gut:** Die BRS-Bausteine stehen und sind getestet: `brs_held.gd` (Erschaffung, Fertigkeiten), `brs.gd` (Erfahrung, Heldenstufe, Monster), `brs_kampf.gd` (Treffer, Schaden, Abwehr, Leben nach Modell D), Regelwerte `tools/sim444/werte.json` (alle 18 Monster von Kapitel 1 samt Krogg, Grimmzahn, Grak; Waffen, Rüstungen, Herkünfte, Wirtschaft, Kampftränke). Es fehlt nicht das System, sondern der Anschluss.

## 2. Grundsätze für den Umbau

1. **Ein Held:** `BrsHeld` ist die einzige Quelle für Werte des Helden. `Heldwerte` verschwindet ganz; was es an Ausrüstung und Spielstand hält, wandert zu `BrsHeld` bzw. `Zustand`.
2. **Ein Kampfweg:** der BRS-Weg in `mars.gd` wird der einzige; Schalter, `_srd`, `massstab`, W20 und SRD-Zweige fallen weg.
3. **Zahlen nur in den Regelwerten** (`werte.json`), nie als Konstante im Code (Regel aus 649a). Neue Zahlen kommen aus der Simulation 444 und gehen zum Chef, bevor sie gelten.
4. **Namen nur nach `DESIGN-BRS.md` 12**, Spieltexte nur von Homer, wortgetreu.
5. **Erst Laufendes fertig, dann umbauen, dann nichts Neues dazwischen** (870 A): kein Zweig außer dem Umzug ändert während des Umbaus die Dateien aus Abschnitt 4.
6. **Spielbar bleiben:** jede Stufe des Umzugs endet mit einem spielbaren Build; nie zwei halbe Systeme auf `main`.
7. **Kapitel 1 zuerst:** gebaut wird, was Kapitel 1 braucht (Stufe bis 6, keine Gefährten, Pfade erst als Anwärter); Kapitel-2-Regeln (Weihe, Gefährten ohne Klassen) bleiben offen, ohne den Umzug aufzuhalten.

## 3. Reihenfolge auf einen Blick

| Schritt | Was | Wer | wartet auf | Prüfung | Schätzung |
|---|---|---|---|---|---|
| 0 | Laufendes fertig und auf `main`: 709, 854 (Jerry), 470 Erschaffung, 663, 653, 506 (Tom/Spike) | Tom, Jerry | – | wie je Vorgang | läuft schon |
| 1 | Regelfragen 870a entschieden, `DESIGN-BRS.md` nachgezogen | Chef, Sokrates | – | Archiv | – |
| 2 | Schnittstelle Held ↔ Kampf festlegen (eine Datei, ein Test) | Jerry mit Tom | 0, 1 | Test `brs_blatt` | 1 Sitzung |
| 3 | Daten: Regelwerte vollständig, `tabellen.json` abgelöst, Fähigkeitentabelle (649a Schritt 1–2) | Jerry | 1 | Tests `brs_473`, neue Tabellenprüfung | 1–2 Sitzungen |
| 4 | Held: `Heldwerte` → `BrsHeld`, alte Erschaffung weg, alle Leser umgestellt | Tom | 2 | Tests, Bild Heldenreiter | 4–6 Sitzungen |
| 5 | Kampf: nur noch BRS, Fähigkeiten und Zauber, Erfahrung, Anzeigen (868, 534, 467, 469) | Jerry | 2, 3 | Tests, Film Wolfskampf | 5–7 Sitzungen |
| 6 | Gegenstände und Beute nach BRS (644.1, 644.2, 644.4) | Jerry (Werte), Tom (Laden, Menü) | 3, 4 | Tests, Bild Gegenstandsfenster | 2–3 Sitzungen |
| 7 | Spielstände: Version 2, Umgang mit alten nach 870a | Tom | 4 | Test alter Spielstand | 1 Sitzung |
| 8 | Ganz aus Kotlin (870a 7 B): Karten, Texte, Intro, Kartenblätter, Bilder, Klang als Godot-Quelle; Handbuch und Lizenztext neu; Kotlin-Bau aus, `core/`, `app/`, `tools/preview` ins Zweit-Repo | Tom, Homer, Perikles (`android.yml`) | 4 | Godot-Bau ohne Gradle, Kartenregeln als Godot-Tests | 4–6 Sitzungen |
| 9 | Aufräumen, Wächter, Hinweis raus, Abnahme | Tom, Jerry, Perikles | 4–8 | Wächter grün, Chef spielt | 1–2 Sitzungen |

**Nach dem Gegenlesen (Diogenes 870.1, `PRUEFBERICHT.md` Lauf 134; gilt vor den Zeilen unten):** Schritt 4 und 5 laufen auf einem gemeinsamen Umzugszweig und kommen nur zusammen als B1 auf `main` (Schritt 4 allein ist nicht spielbar, Grundsatz 6; Leser von `Heldwerte` in `beute.gd`, `spielstand.gd`, `aufruf.gd`, `spiel.gd` laut Lauf 134). Dateigrenzen nach Lauf 134 (8): `brs_held.gd`, `talente.gd` Tom; `beute.gd`, `spiel.gd` 620–657, `streuner.gd`, `testmodus.gd` Jerry; `figur.gd` 438–441 mit Schritt 4 abstimmen. Zweige für Schritt 0: Liste Lauf 134 (9); die vier ruhenden aufgegeben (870.16), offene mit Commits außerhalb `build-275` an Tom und Jerry (884, 11.11.). Fehlende Stellen und Zeilenfehler: Lauf 134, je Schritt mitnehmen. Pechsträhne (Projektplan 2.3) bleibt, als Prozent im BRS-Weg (Jerry, Zahlen 444). Wanderer: Startvorrat, Tracht, Kapitelschirm, Probeheld bekommen eine eigene Zeile „Wanderer“ in der Herkunftstabelle (Tom, Texte Homer). Kosten: Diogenes rechnet nach Vergleichsvorgängen 350–500 $ (Lauf 134); mit 7 B schätzt Sokrates 400–600 $; diese Zahl gilt überall im Plan.

**Vorgänge (10.11., 15:32):** Schritt 0 Zweige 870.16 (Ford); 2 870.2, 3 870.3, 5 870.5, 6 870.6 (Jerry); 4 870.4, 6 870.7, 7 870.8, 8 870.9, 9 870.13 (Tom); 8 870.10, Wächter 870.11, Projektplan und Abschluss 870.12 (Perikles); Texte 870.14 (vor 4/5), 870.15 (Schritt 8) (Homer). Reihenfolge über „wartet auf“.

**Zwei Testbuilds beim Chef:** (B1 und B2 sind Umzugspakete, keine Builds: in Prüflisten, Meldungen und Chefsache nur die Build-Nummer, etwa „Build 277 (Umzugspaket B1)“; Chef 11.11., 15:51.) **B1** nach Schritt 4 und 5 (neues Spiel mit BRS-Erschaffung, Dorf, Wolfskampf nur BRS), dazu Schritt 7 Spielstände (870.8; 11.11., 07:41: „Weiter“ lud sonst einen Mischhelden aus Build 275); **B2** nach Schritt 6, 8, 9 (Beute, Laden, Höhle, Handbuch, Wächter). Zusammen etwa 19–29 Entwicklersitzungen (Summe der Tabelle); zum Maß: 478 (Rechenkern) 6,50 $, 470 (Erschaffung) bisher 43 $, 709 bisher 38 $. Kosten 400–600 $ (oben).
**Guthaben:** Tom und Jerry arbeiten zugleich (Chef 10.11., 16:04, 826 „eine zugleich“ zurück). Pause für 870.x: Chefsache 870b.

## 4. Schritte im Einzelnen

### Schritt 0: Laufendes fertig (Tom, Jerry; läuft)

- Auf `main` vor dem Umbau, weil sie dieselben Dateien ändern: `jerry-709-treffen` (figur, kampf_ui, kampfort), 854, `tom-506-untote` und `tom-506-skelett` (mars.gd, tabellen.json, aufruf.gd), `spike-470-erschaffung` und `tom-brs-held` (menue, erschaffung_brs, aufruf, brs_fertigkeit), `tom-663-touch` (menue), 653.
- Alte Zweige, die dieselben Dateien berühren und ruhen (`jerry-494-gegner`, `jerry-403-held-kampfort`, `jerry-6235-effektprobe`, `tom-6236-probeapk`): Ford klärt mit dem Besitzer „aufgeben oder vorher zusammenführen“; nach dem Umzug passen sie nicht mehr.
- **Prüfung:** `git diff main...<Zweig>` der offenen Zweige berührt keine Datei aus Schritt 4–6.

### Schritt 1: Regelfragen (Chef, Sokrates)

Erledigt: 870a mit acht Fragen (Spielstände, klassischer Kampf, Fähigkeiten ohne Klassen, Grundwerte wachsen, Proben ohne W20, Gegenstände, Kotlin-Fassung, Schwächen) entschieden 10.11., 15:08 und 15:25 (Archiv), `DESIGN-BRS.md` nachgetragen, Chefsache gelöscht.

### Schritt 2: Schnittstelle Held ↔ Kampf (Jerry mit Tom, 1 Sitzung)

- Heute baut `aufruf.gd` `blatt()` (169–189) das Kampfblatt aus `Heldwerte` (cls, ac, spellDc, prof, saves, sp, cha). Neu: `BrsHeld.kampfblatt()` liefert Grundwerte, Fertigkeiten, Heldenstufe, Leben, Mana, Ausdauer, Waffe (Gruppe, Grundschaden, Güte), Rüstung (Schutzwert, Art), Schild, Fähigkeiten. Jerry schreibt den Test zuerst, Tom liefert die Werte.
- Damit können Schritt 4 und 5 nebeneinander laufen, ohne in dieselbe Datei zu schreiben: Tom besitzt `skripte/`, Jerry `regeln/` und `kampf/`; `aufruf.gd` gehört Jerry.

### Schritt 3: Daten (Jerry, 1–2 Sitzungen; 649a Schritt 1–2)

- `werte.json` wird die einzige Quelle der Monsterwerte: `brs_kampf.gd` 103–114 liest keine SRD-Abweichungen (atk, dmg) aus `tabellen.json` mehr; Jungwolf und Leibwache (`aufruf.gd` 121, 126, SRD-Würfel) bekommen Zeilen in den Regelwerten (Werte über 444, dann Chef).
- Kennungstabelle je Art (649a Schritt 1): Kennung, Name nach `DESIGN-BRS.md` 12 und Bestiarium, Modell, Gruppe; interne Kennungen `stirge`, `ochre_jelly`, `bugbear`, `hobgoblin_captain` dürfen bleiben, Anzeigenamen nicht.
- Fähigkeiten und Zauber als Tabelle in den Regelwerten (Name, Voraussetzung nach 870a Frage 3, Manakosten, Grundschaden, Wirkung) statt `tabellen.json` „skills“.
- `tabellen.json` wird gelöscht; Leser: `spiel.gd` 625, `streuner.gd` 80, `testmodus.gd` 85/409, `aufruf.gd` 213/243, `probe.gd` 27, `mars.gd` 326, `zustaende.gd` 19, `brs_kampf.gd` 102.
- **Prüfung:** `brs_473` (Werte wie 444), neuer Test „jede Kennung hat Werte, Modell, Namen“.

### Schritt 4: Held (Tom, 4–6 Sitzungen)

| Stelle heute (SRD) | wird (BRS) |
|---|---|
| `hauptmenue.gd` 297, 360, 372: alte Erschaffung | `ErschaffungBrs`; Ergebnis startet das Spiel (`spiel.gd` 121–127 ohne `srd`-Überschreiben) |
| `erschaffung.gd` | gelöscht; gemeinsame Helfer (`txt`, `luecke`, `knopf`, `vorzeichen`, `kurz`; etwa 10 Leser) vorher nach `stil.gd` |
| `heldwerte.gd` (STR–CHA, `mod`, `uebung`, `rk`, `zauber_sg`, `krit_ab`, `max_tp` aus Trefferwürfel, `zp`, `offen`, `kann_tragen` nach Klasse, Punktkauf) | gelöscht; Leben, Mana, Ausdauer, Schutzwert aus `BrsHeld` nach `DESIGN-BRS.md` 2 und 4; Tragen ohne Klasse (jeder darf alles; Magie und Metall nach 7, Schleichen und schwere Rüstung) |
| `brs_held.gd` 14, 158–173 Brücke `alt()` (Hügelvolk→HALFLING, Herkunft→FIGHTER, Wille→CHA, `srd_wert`) | gelöscht |
| `spiel.gd` 122, 1265–1274 Startvorrat nach Klasse; 739 und `geschichte.gd` 27–30 Klassenwaffe (Truhe cave_3, 632) | nach Herkunft aus den Regelwerten (`herkuenfte`); Truhe gibt die Waffe der stärksten Waffenfertigkeit (Homer prüft den Text) |
| `heldfigur.gd` 19–28, 97, 111–130 Aussehen und Tracht über die Klasse | über die Herkunft (`held-klassen.json` → Herkunftstabelle) |
| `menue.gd` Heldenreiter: Klasse, RK, Übungsbonus, Zauberangriff, Zauber-SG, Attributspunkte, Modifikator „(+2)“, „Kritisch ab 19“, „Deine Klasse kann das nicht tragen“, „Ungeübt“, Würfel „1W8+1“ | Grundwerte mit Erklärtext (839, Homer 817), Fertigkeiten (762), Schutzwert, Leben, Mana, Ausdauer, Schaden als Zahl, kritisch in Prozent; Tragen-Hinweise nach BRS |
| `menue.gd` 595–625 Heilen mit Würfeln, `TALENTE.meal_bonus` (CON) | feste Werte aus den Regelwerten (Heiltrank, Mahlzeit), Bonus nach Kochen |
| `leiste.gd` 20, 102–106, 171–185 „ZP“ | Mana |
| `rast.gd`, `zustand.gd` 22: Kurze Rast 1 h, Lange Rast 8 h, `lange_rast_tag` | Kurze Erholung 2 h, Langes Ausruhen 9 h (`DESIGN-BRS.md` 12); Wirkung nach 870a |
| `skripte/ausdauer.gd` 13–19: 6 + 2 × Mod(KON), schwere Rüstung ab STÄ 13 | Ausdauer aus Zähigkeit und Wille (467), Zahlen aus 444 |
| `herde.gd` 109, 292, `ruf.gd` 47: Mod(GES), Mod(WEI) | Gewandtheit, Wahrnehmung (und Spähen) |
| `spiel.gd` 783 Kräuterchance Mod(WEI) | Kräutersammeln (857a) und Wahrnehmung |
| `laden.gd` 54–56, 103–104, 181 und `regeln/talente.gd` (Preis nach CHA, Brauen nach INT) | Preis nach Handeln und Ruf, Brauen nach Alchemie (481); `talente.gd` gelöscht |
| `vergleich.gd` 17–22, 62–64 (rk, Angriff, Zauberangriff, zp, STR–CHA) | Vergleich nach Schaden, Schutzwert, Zusatzeigenschaften in BRS-Werten |
| `kapitelschirm.gd` 63, 127, `spielstaende.gd` 113–124, 322–325: Klasse | Herkunft (oder Pfad, sobald es einen gibt) |
| `ladenschirm.gd` 141–142, 193–195 `kann_tragen` | wie oben |
| `testmodus.gd` 45, 102–107, 123, 347, 355: Probehelden nach Klasse | Probehelden nach Herkunft |
| Proben `figurenprobe.gd`, `voelkerprobe.gd`, `tragprobe.gd`, `trachtprobe.gd` (Klassen, HALFLING) | auf Herkunft und neue Volksnamen umstellen oder löschen, wenn kein Bau sie mehr braucht |

**Prüfung:** alle Tests auf `Heldwerte` umgestellt (etwa 70; `held_golden`, `held_klassen_376` entfallen); Bild Heldenreiter und Ladenvergleich an den Chef vor B1.

### Schritt 5: Kampf (Jerry, 5–7 Sitzungen; 868, 534, 467-Kampfteil, 469)

| Stelle heute (SRD) | wird (BRS) |
|---|---|
| `brs_kampf.gd` 16–19 Schalter, `testmodus.gd` 304–307; `mars.gd` 385, 410–441 `brs_einrichten`, `massstab`, `_srd` | weg; BRS immer |
| `brs_kampf.gd` 22, 56–86 Herkunft aus Klasse, Stufe aus SRD-Stufe, Schild aus `ac > acDrawn` | aus `BrsHeld.kampfblatt()` (Schritt 2) |
| `mars.gd` 222–226 RK; 1078–1092, 1177–1219, 1479–1540 SRD-Angriffe mit W20 | weg (BRS-Zweige `_brs_waffe`, `_brs_zauber`, `_brs_auf_held` bleiben) |
| Initiative `d20 + dex` (366, 1716) | nach 870a Frage 5 |
| Flucht `d20 + dex` (1131–1143) | nach 870a Frage 5 |
| Rettungswürfe (1095–1106 Zauber, 1249–1282 Zustände, 1328–1350 Wunden der Gegner); `aufruf.gd` 149 RETTUNG je Klasse | Abwehrprobe nach 870a Frage 5; Lücke heute: im BRS verwunden Gegner nie kritisch (`r` bleibt 0, 1482/1530) |
| Zauber mit SRD-Würfeln: Magisches Geschoss, Sengender Strahl, Feuerball, Brennende Hände, Heilige Flamme, Wunden heilen, Segnen (987–1040, 1069–1070) | Arkanpfeil, Glutkugel, Flammenfächer, Gleißstrahl, Wundsegen, Beistand nach `DESIGN-BRS.md` 4 (Zauber wie Waffe, Wille, Schule) und Fähigkeitentabelle (Schritt 3); Grak-Heilung 1385 mitnehmen |
| Klassenfähigkeiten: Zweiter Atem, Tatendrang, Finte, Hinterhältiger Angriff, Gerissene Aktion, Extra-Angriff, Zweiwaffenkampf, Decken nur Kämpfer (641–648), „perfekte Antwort“ je Klasse (1544–1566), Lebensraub, Unerbittlich (Halbork, 1738–1746), „Zwergische Zähigkeit“ (119) | nach 870a Frage 3; Volksmerkmale Letzter Atemzug, Steinblut (Namen 12, Wirkung neu) |
| Zauberpunkte `sp`, PER_REST/PER_BATTLE (192, 459–462, 593–614) | Mana nach `DESIGN-BRS.md` 4; „je Rast“ nach 870a |
| Schadensarten (Stich, Hieb, Wucht, Gift, Heilig), verwundbar/resistent/immun ×2/½/0 aus `Monsters.kt`, nur in `klassisch.gd` 1134–1170; MARS rechnet keine; `talente.gd` 39, 137 „ab INT 12 erkennst du Schwächen“ | nach 870a Frage 8 (Schwäche, Stärke, Gegenwirkung; Wissen); Spalte im Bestiarium (Sokrates) |
| Probekampf/leichter Gegner nach CR (126–127, 356–363, 444–446) | nach Stufenunterschied (Modell D) |
| Vorteil/Nachteil `_row_mode` (1044–1062), Segnen 1W4 | Gunst/Ungunst als Prozent (BRS-Weg hat ±25 % schon) |
| `lohn.gd` (xpForLevel, MAX_LEVEL 20, Attributspunkte, neue Klassenfähigkeit, „TP und ZP“) → `spiel.gd` 652–656 | `Brs.gib_erfahrung` (Heldenstufe 472, Deckel, Topf je Gebiet); keine Attributspunkte (870a Frage 4) |
| `aufruf.gd` 230 Magier/Kleriker hinten; 283–293 `leiden_nach` KON; 303–304 Leben zurück nach SRD | Reihe nach Waffe (Fernkampf, Zauber hinten); Zähigkeit; weg |
| `figur.gd` 438–441, 553, 621–624, 740, 869: Modell, Schildhand, Knickwinkel je Klasse | je Ausrüstung bzw. Herkunft |
| Texte: `mars_texte.gd` 23–39, `mars.gd` 76–96 Zustände („−2 auf Angriff und Rüstungsklasse“, „Nachteil“), `kampf_ui.gd` 526 „ZP“, 653, 695, 761–778, 868, 2043–2070 („gegen RK“, „RW … gegen SG“, „(Vorteil)“), ganz `marstips.gd` | BRS-Begriffe (868); neue Wortlaute von Homer (Vorgang an Homer zuerst) |
| `regeln/klassisch.gd`, `pechstraehne.gd`, `regeln/ausdauer.gd` (nur Tests), `wuerfel.gd` 43–53 `d20()` | gelöscht |
| `zauber.gd` Effektschlüssel FIRE_BOLT … | dürfen bleiben (keine Spieltexte); Umbenennen nur, wenn ohnehin angefasst |

**Prüfung:** `mars_golden`, `mars_regeln`, `klassisch_golden`, `regeln_390` (SRD-Teil) entfallen; neue Kampftests auf BRS (Zustände, Flucht, Initiative, jeder Zauber und jede Fähigkeit aus 2.17 einmal gewirkt); Simulation 444 neu: Rudel, Krogg, Grak je Herkunft (2.5, 481), Ergebnis zum Chef vor B1; Film Wolfskampf.

### Schritt 6: Gegenstände (Jerry Werte 644.1/644.2, Tom Laden und Menü 644.4)

- `beute.gd`: kein „plus“ (144–150); Zusatzeigenschaften in BRS-Werten (870a Frage 6) statt STR–CHA, AC, SP, ATTACK, SPELL, CRIT, RADIANT, ALL_STATS (13, 106–118, 158–165); kein Filter nach Klasse (66–96, 121–131, 190–193, 212–253): Beute nach Fertigkeiten des Helden gewichtet; Güte als Achse; Anzeige ohne Würfel (315–344).
- Gegenstände im Beutel und am Helden mit alten Feldern: nach 870a Frage 1.
- **Prüfung:** `beute_golden` entfällt; neuer Test „kein Gegenstand nennt Altwerte“; Bild Gegenstandsfenster vor B2.

### Schritt 7: Spielstände (Tom, 1 Sitzung)

- `spielstand.gd` schreibt `version: 2` mit BRS-Held und liest die Version. Alte Spielstände (Version 1) nach 870a Frage 1.
- **Prüfung:** Test mit einem echten Spielstand der Version 1: kein Absturz, Verhalten wie entschieden.

### Schritt 8: Texte und Daten aus Kotlin lösen (Tom, Homer, Perikles; 4–6 Sitzungen)

- `daten/held.json` entfällt mit `Heldwerte`. Die Texte aus `texte.json`, die SRD nennen (RK, ZP, Übungsbonus, Trefferwürfel, Hauptattribut, „Wähle deine Klasse“, Rast, `aboutText`; TP bleibt, Trefferpunkte gibt es auch im BRS, DESIGN-BRS 12, 896), und das Handbuch (`Guide.kt`) bekommen eine eigene Godot-Quelle; Wortlaute Homer (Handbuch BRS 423.1 wird damit Muss für den Teil, der heute SRD erklärt).
- `geschichte.gd` 345, 385, 392 „Hobgoblin“, „Grottenschrat“ (aus `Chronicle.kt`): Homer setzt Goblin-Hauptmann, Bärenschrat.
- **Ganz aus Kotlin (870a 7 B, Chef 10.11., 15:25):** Einmal alles exportieren, was `godot.yml` 48–65 und 358 heute aus `core` holt (Karten, Texte, Held, Intro, Kartenblätter, Bilder der Dinge, Kampfklang), und als Godot-Quelle unter `godot/daten` einchecken; danach baut `godot.yml` ohne Gradle. Vorher legt Tom fest, wie Karten künftig bearbeitet werden (Werkzeug oder Datei; größtes Risiko), und nimmt die Kartenregeln der Kotlin-Tests (`VillageRoundTest` u. a.) als Godot-Tests mit. `android.yml` baut nicht mehr (Perikles); ebenso alle Werkzeuge, die an `core` hängen (Kerntests `tools/t logik`, `godot-kampf.yml`, `vorschau.yml`, `tools/preview`, `story.sh`, `probelauf.py`, `setup-session.sh`; Diogenes Lauf 140, 882). `core/`, `app/`, `tools/preview` gehen ins Zweit-Repo, lesbar für den Abgleich mit alt (620.2); offene Zweige, die `core/` ändern, vorher fertig (Schritt 0). Die Store-Kennung `de.bornim.game` (heute Kotlin-App) wechselt erst zur Veröffentlichung (622, ruht); Godot baut bis dahin als `de.bornim.game.godot` (`export_presets.cfg` 28).
- **Werkzeuge (882, Perikles 11.11., geprüft an `origin/main`):** Reihenfolge 870.9 → 882.1 → 882.2 → 870.10; bis 870.10 bleibt `core/` da, nichts bricht dazwischen. `bau_am_rechner.py` liest die Schritte aus `godot.yml` und folgt 870.9 von selbst.
  - **882.1 (Tom, nach 870.9):** `godot-kampf.yml` 41 (`exportIntro`) liest die eingecheckten Daten; `tools/godot/wald_daten.sh` 12, 37–38 ohne Gradle; `tools/godot/mars_texte.py` (liest `Skirmish.kt`) streichen, `mars_texte.gd` ist dann Quelle; Vergleichsbilder „alt“ aus `tools/preview` (348.9 `vgl348.py`, 512b `menues_512b_blatt.py`, `tools/pruef348/*`, 620.2) einmal rendern und im Zweig „bilder“ ablegen, die Werkzeuge lesen danach diese Bilder.
  - **882.2 (Perikles, nach 882.1):** Kerntest wird Godot-Logiksatz: `tools/t logik` startet die Godot-Tests ohne Modelle (Liste `godot/tests/logik.txt`, unter 2 Minuten; der Rest bleibt in `godot.yml` und 918), setzt bei Exit 0 die Marke `kerntest-ok`; `commit-pruefung.py` `kerntest_warn` prüft `godot/**.gd` statt `.kt`; `tools/t spieler`, `bild`, `film` entfallen. `check-env.sh` (Java, Gradle, Kerntests, Vorschau → Godot, Logiksatz), `setup-session.sh` 13 und `.claude/settings.json` ohne Gradle-Vorwärmen, `gradle-mirror.gradle` weg; `probelauf.py` 75 (`core/src/main/`), 292 (`vorschau.env`), 649 (Hinweis `app/`, `core/`); `story.sh` liest Spieltexte aus `godot/` (Homer und Diogenes nutzen es, `ROLLE-KREATIV.md` 49, `LISTE-PRUEFUNG.md` 59); `startbar.py` 396 Wortliste ohne `.kt`; Probe-Abläufe mit Java (`tom-probe*.yml`, `tom-mess-417.yml`, `spike-probe-3761.yml`) und `vorschau.yml` löschen. Regeltexte im selben Commit wie 870.10: CLAUDE.md erster Absatz (Module), „Jeder Schritt“ (Kerntests = Logiksatz; Regelbilanz: ersetzt, nicht neu), Grenzen 6 (`WorldScreen.kt`); `LISTE-BAUEN-TESTEN.md` 11, 18, 48, 56, 64, 96; `LISTE-CHECK-BUILD-TEST.md` 5; `tools/regeltreue/stufe2/`.
  - **Prüfung:** in einer Kopie ohne `core/`, `app/`, `tools/preview`: `tools/t logik` Exit 0, Code-Commit ohne Warnung, `godot.yml` und `godot-kampf.yml` grün, `grep -rn "gradlew\|core/src" tools .github` ohne Fund.

### Schritt 9: Aufräumen, Wächter, Abnahme (Tom, Jerry, Perikles)

- **Wächter:** `tools/commit-pruefung.py` prüft vor Zeile 187 (dort endet die Prüfung heute für Code-Commits) jeden Code-Commit unter `godot/` auf neue SRD-Begriffe; Wortliste aus `regelcheck.py` 193–223 (`DESIGN-BRS.md` 12) plus RK, ZP, Übungsbonus, Rettungswurf, Zauberplatz, W20/d20, Klassennamen, STR/DEX/CON/INT/WIS/CHA in Spieltexten. Bauen: Perikles (Werkzeug). Ab Schritt 4 aktiv, zunächst nur für neue Zeilen.
- Hinweis „SRD 5.1 · CC BY 4.0“ raus: `hauptmenue.gd` 319, 534, `aboutText`; `README.md` 3, 23, 35, 68, 72; Testerseite `docs/firma/webseite/inhalt/tester.de.html`, `.en.html` und `webseite-texte-2521.md`; `CLAUDE.md` erster Absatz; `DESIGN-BRS.md` 12; Projektplan 6.1; Wächter `regelcheck.py` 217–219 anpassen. Erst wenn `core/` aus dem Repo ist (Schritt 8).
- Vorgänge, die im Umzug aufgehen und danach geschlossen werden: 868, 534, 467, 469, 644.1, 644.2, 644.4, 649.1, 811, 296, 344 (Fackel „nach SRD“), Idee 49, 50; Projektplan 2.3 und 2.17 neu formuliert (Perikles).
- **Abnahme:** Wächter über den ganzen Godot-Code ohne Fund; Chef spielt B2.

## 5. Risiken und Gegenmittel

- **Die Zahlen ändern sich spürbar** (Leben, Schaden, Heilung, Erfahrung). Gegenmittel: jede neue Zahl aus 444, vor B1 eine Messung je Herkunft gegen Rudel, Krogg, Grak (2.5), Ergebnis an den Chef.
- **Zwei Teams in einem Umbau** kreuzen sich. Gegenmittel: Schnittstelle zuerst (Schritt 2), feste Dateigrenzen, Jerry besitzt `aufruf.gd`.
- **Stille Wertänderung** beim Zusammenlegen der Monstertabellen (Jungwolf, Leibwache; Befund 649a). Gegenmittel: Test „Werte wie 444“ vor dem Löschen von `tabellen.json`.
- **Spielstände des Chefs gehen verloren**, je nach 870a Frage 1. Gegenmittel: Hinweis im Spiel, Testmenü erzeugt Helden jeder Herkunft auf Stufe 1–6.
- **Kosten:** 400–600 $ mit knappem Guthaben; Tom und Jerry arbeiten zugleich (Chef 10.11., 16:04). Gegenmittel: Spike und Tuffy bleiben aus; nach B1 Kosten gegen Plan prüfen.
- **Stärkstes Gegenargument gegen den ganzen Plan:** Er hält Kapitel 1 sichtbar zwei bis drei Wochen an, und am Ende sieht der Chef dieselben Orte mit anderen Zahlen. Antwort: Jeder Build bis dahin baut weiter auf Werten, die wegfallen (Menüs, Beute, Anzeigen), und die Oberste Direktive verlangt Kapitel 1 mit dem BRS; je später, desto teurer.

## 6. Pflege

Diese Liste gilt bis zur Abnahme; Stand je Schritt in der Vorgangsliste (870.x), nicht hier. Nach der Abnahme nach `docs/alt/`.
