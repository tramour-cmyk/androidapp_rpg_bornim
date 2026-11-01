# Prüfbericht Diogenes

Befunde von Diogenes (`ROLLE-PRUEFUNG.md`, Aufbau in `LISTE-PRUEFUNG.md` „Prüfbericht“). Jeder Befund ist ein **Verdacht**, bis der Zuständige ihn bestätigt; Vermerke („bestätigt“, „behoben“, „verworfen“ mit Grund) schreibt er unter den Befund. Neuester Lauf oben. Nur Läufe mit offenen Befunden; abgeschlossene Läufe ins [Prüfbericht-Archiv](PRUEFBERICHT-ARCHIV.md) (Lauf 22–39, 41; 274).

## Wochenzählung (QM, 106.1; nur Zahlen, Bewertung Perikles)

| Kennzahl | 18.–24.10. (gezählt 26.10., 00:5x) | Quelle |
|---|---|---|
| Kosten je Bereich (Liste) | 1703,90 $: B 789,02 (davon Zeile „Betrieb“ 564,16) · E 607,59 · G 171,54 · Q 92,36 · M 21,45; ohne Bereichsbuchstaben der Liste: D 10,33, A 5,50, O 4,85, F 1,26 | `LISTE-VORGAENGE.md` + `-ARCHIV.md`, `62ca83ee8` → `b17da0aea`; ein Teil kann vom 17.10. stammen |
| Anteil Muss | 43 % (735,66 $); ohne „Betrieb“ 65 %; M? 114,67, K 125,71, „–“ 727,86 | Spalte „Kl.“ |
| Kosten je Rolle, Anteil Spiel | 1813,92 $ (370 Sitzungen, 20 ohne Kosten): Jerry 543 (30 %), Sokrates 489 (27 %), Tom 383 (21 %), Ford 156 (9 %), Perikles 118 (7 %), Homer 102 (6 %), Diogenes 23 (1 %); **Anteil Spiel 57 %** (Stufe 50 %) | `kosten.py`, Starttag der Sitzung |
| Guthaben Max | Woche 5 % (18.10.) → 41 % (20.10.) → 77 % (22.10., 12:45) → 94 % (23.10., 07:16) → 100 % 23.10., 10:1x; danach Credits 79,38 → 54,03 $ (24.10., 17:21); 80/95 % genau: fehlt | „Guthaben:“ in `ARBEIT-BETRIEB.md` (Git); Monatsangabe 4,31 → 248,62 $ passt nicht zum Rückgang 41,66 $ (Nachkauf nicht eingetragen) |
| Wochenziel / Meilenstein | Wochenziel nein (38 offen, 39 wartet; erledigt 13e, 112/68, 26); Pflicht Block (a) 3 von 4 offen; marktreif 5 von 6 Blöcken gelb | `LISTE-ABNAHME-KAPITEL1.md` |
| Testrunden Chef, Rückläufer | 63 Builds (19–87) im CHANGELOG; Rückläufer laut Feld „Rückläufer:“ 6 (Build 81: 1, 82: 3, 83: 1, 84: 1; Feld erst ab 81); über alle Builds der Woche aus den Einträgen gezählt 66 (Tom 23, Jerry 43, Lauf 45) | `CHANGELOG.md`; 101 Löschungen in `ansehen/` |
| Ersparte Fragen (Vorentscheid) | 3 (59e.1, 84.1T.1, 261.5), alle gebilligt | `VORGANGSARCHIV.md` |
| Stillstand | Fehler: Homer 8,4 h (bis 18.10., 08:24); Guthaben: 0 Zeilen (ab 23.10. über Credits) | Protokoll `ARBEIT-BETRIEB.md` |
| „von Team“ an Homer > 1 Tag | 0 | `ARBEIT-KREATIV.md` |
| Empfehlungen Sokrates (17./18.10.) noch gültig | 11 von 13, 2 teilweise abgelöst (167 durch 192.4; 99h.6 durch 261.5) | `VORGANGSARCHIV.md` |
| Verwerfquote Diogenes | 0 von 49 (D26.1–D41.5), 2 teilweise (D29.1, D29.4) | Prüfbericht, Archiv |
| Erst der Chef am Gerät | 6 laut Feld, 66 über alle Builds (Rückläufer) | `CHANGELOG.md` |
| Perikles Z3 / Z4 / Z6 | Z3 1 (23.10., 13e); Z4 14 neue Chefsache-Dateien: 11 ja, 1 ja, aber (186), 1 anders (287), 1 unklar (234); Z6 nein, Muss 43 % | `ARBEIT-PROJEKT.md`, `git log --diff-filter=A`; Zielvereinbarung erst seit 23.10. |
| Z5 Anteil Tom, Jerry, Homer | 57 % | wie Kosten je Rolle |

## Offen für den Chef

**149 Probewoche Ford (Lauf 45):** Entscheidung über Ford: Aufwand „Niedrig“ oder stärkeres Modell. Grundlage sind die Zahlen von Lauf 45. Dort steht auch, dass am Sa 24.10. die Morgenmeldung ausfiel (Grund: Guthaben). (D4.1 am 26.10. ins Archiv, Lauf 23.)

## Lauf 57 · Auftrag 462 Doppelpack zum Zeitstempel (`main` nach `b851fb635`; 01.11., 20:4x; `name()` aus `neustart-haken.py` mit 14 gebauten Protokollen aufgerufen, Haken mit leerem Protokoll aufgerufen, `zug-haken.py` und eigene Zählzeile gelesen)

**Ergebnis:** Für jede Sitzung, die Ford startet, ist der Kopf richtig. `lauf.py` beginnt jede erste Nachricht mit der Rolle (Z. 471, 491, 526, 597). Erkannt werden „Tom“, „Tom 2“, „Tom 2, weiter“, „Tom, mach …“, „**Jerry** …“, „Spike“ als Textliste und „Perikles – 338.1: …“. Bei „Tom 12 Uhr“ bleibt es richtig bei „Tom“, „Tomaten“ wird nicht erkannt. In dieser Sitzung stand „**Diogenes**“ ab dem ersten Haken.

**Befunde**

- **D59.1 Zwischenmeldungen bleiben ohne Kopf, und keiner zählt sie:** Der Kopf wird nur vorgegeben, wenn eine Nachricht eingeht (UserPromptSubmit). Der Stop-Haken prüft und zählt nur die letzte Nachricht eines Zuges. In langen Zügen kommen Zwischentexte, etwa auf den Systemhinweis „user hasn't heard from you“. Diese Texte stehen ohne Kopf im Chat, und genau sie sieht der Chef ohne Zeit. Beleg ist diese Sitzung: Nach dem Haken um 20:44 kam „Ein ‚Nachfolger‘ steht doppelt …“ ohne Kopf. Die Zählung ab 02.11. (374) erfasst solche Texte nicht.
- **D59.2 Die Spalte `stempel` zählt auch einen Kopf ohne Namen:** `STEMPEL` in `zug-haken.py` lässt den Namen weg (`(?:\*\*…\*\*)?`). „[01.11., 20:44]“ allein zählt also als 1. Der „Anteil ohne Kopf“ misst damit nur die Zeit, nicht den Namen.
- **D59.3 Ohne erkannte Rolle steht wörtlich „**<Name>**“ im Kopf (gering):** Das passiert, wenn die erste Nachricht nicht mit der Rolle beginnt, z. B. „Hallo Homer“, „tom“ oder ein Systemtext bzw. Befehl davor. Das betrifft nur Starts durch den Chef von Hand.

**Nicht geprüft:** Sitzungen auf Arbeitszweigen (`knapp.md` gilt dort erst nach dem Merge, wie vermerkt); laufende Sitzungen, die vor 20:39 gestartet sind.

## Lauf 56 · Auftrag 461 Doppelpack zum Grundstand (`main` `9574bb019`; 01.11., 20:4x; jede Zeile von `LISTE-GRUNDSTAND-461.md` gegen ihr „Woher“ im Vorgangsarchiv, wo es fehlt gegen die „Zu“-Absätze der Vorräte; Prüftreppe 4 und `ROLLE-ENTWICKLUNG.md` gegen 373, 389, 396)

**Ergebnis:** 31 der 39 Punkte stehen so im Archiv, wie das Archiv sie nennt: A2–A6, B1–B7, C1, C3, C4, D1–D3, D5, D6, E2, E4–E7, F1, F2, F4, F5, G1, G3. Nichts davon ist umformuliert. B4 und C3 fassen mehrere Urteile zusammen; das ist gedeckt durch 376.1, 406 (20:2x) und 453. Zu 389 gibt es keinen Widerspruch: Bei verbrauchten Läufen geht eine Zeile statt des Films an den Chef, und sein Urteil gibt die Läufe frei wie in 407.

**Befunde**

- **D58.1 E1 widerspricht dem Archiv 410:** E1 lautet „Waffe in der Hand, nicht auf dem Rücken“. Das stützt sich auf den Prüfauftrag des Chefs um 21:1x. Im selben Archiveintrag hat der Chef danach aber entschieden (31.10., 21:17/21:27, „Ja, so machen“): Die Tragart richtet sich nach der Waffenklasse. Kurze Waffen kommen an den Gürtel, der Stab in die Hand, lange Waffen und der Bogen an den Rücken mit Halter, gewechselt wird in der Kampfblende. So steht es auch in Toms Zeile 417. Ein späteres Chefwort, das das aufhebt, fehlt; 417 vom 01.11. regelt nur Gehen und Rennen aus den Paketen. Folge: Eine Axt am Rücken unterwegs würde den Film anhalten, obwohl der Chef sie so entschieden hat.
- **D58.2 F6 nimmt das Magische Geschoss mit hinein, das der Chef ausgenommen hat:** F6 lautet „Kegel und Geschoss kommen nicht aus dem Körper des Helden“. Das Archiv sagt etwas anderes. 348.7b vom 27.10., 19:49, Punkt (5): „Magisches Geschoss ohne Schritt“. Am 28.10., 15:27/15:28 wurde das Magische Geschoss durch den Helden ohne Seitenschritt abgenommen: „auch die Prüferbefunde bleiben so, kein Feintuning“. Den Seitenschritt gibt es nur für den Kegel und für Schüsse aus der zweiten Reihe (19:49, 10:43).
- **D58.3 Drei Punkte haben kein Chefwort, sind aber Tor:** G2 („keine fremden Bilder an den Schnitten“) stammt nicht vom Chef, sondern aus dem Prüferbefund (d) in Zu 406 bei Jerry. Die Zahl in C2 („kein Abschnitt über 1 s ohne Bewegung“) ist von Sokrates; der Chef sagte „Stillstand für mehrere Sekunden geht eigentlich nicht“. Ebenso stammt E3 („höchstens 2 cm“) von Sokrates aus Zu 438a; der Chef sagte nur „geht das Schild durch“. Weil ein Verstoß den Film anhält, werden diese Punkte zum Tor ohne Chefwort. Gering: Für A1 (457, 457.1), D4 (438, 31.10.), F3 (439) und F4 (440, 31.10.) gibt es keinen Archiveintrag mit dem Chefwort. Es steht nur in den Vorräten bzw. in `LISTE-VORGAENGE.md`; der Inhalt deckt sich.
- **D58.4 „Gehen aufrecht“ wurde gestrichen, ist aber belegt:** Der Chef sagte am 01.11., 13:4x: „Des Weiteren scheint der Oberkörper beim normalen Gehen zum Teil zu weit vorgeneigt zu sein.“ Das steht in Zu 417 (4) in `ARBEIT-TEAM-TOM.md`, im Archiv 417 fehlt der Satz. Die Liste nennt die Streichung „im Archiv nicht belegt“; D3 fehlt damit ein Chefwort. *Behoben 20:4x von Sokrates (`d866e311d`): D3 „Oberkörper aufrecht“, Archiv 417 nachgetragen.*
- **D58.5 Das Tor vor dem Versand hat kein Chefwort und widerspricht 373 und 396:** Das Archiv 461 sagt nur, die Vorlage „wird vom Prüfer dagegen geprüft“. „Film geht nicht raus“ kommt erst von Sokrates (Commit `c212c648a`). Damit wird 396 umgekehrt (Chef 28.10., 11:01: „schickt's mir doch dann einfach“), und zwar für fast alle Vorlagen, denn fast alle betreffen Figuren, Bewegung oder Kampfort. Dazu kommen vier Widersprüche:
  - (a) A5, A6, B1, B6, C4, D1 und D3 („mindestens Stand 403“, „Tiefe“, „nicht klinisch tot“, „unterscheidbar“, „Gesten“, „weich“, „kein Staksen, Hoppeln“) sind Urteile über die Wirkung. Die soll der Prüfer laut Zeile 9 der Liste und laut 373 gerade nicht fällen.
  - (b) 373 erlaubt „höchstens eine Fehlerprüfung … keine zweite Runde“. Jetzt gibt es eine Prüfung vor dem Versand, eine danach und nach einer Behebung eine weitere.
  - (c) `ROLLE-ENTWICKLUNG.md`, Abschnitt „Dein typischer Fehler“, sagt im selben Absatz „Verstoß hält den Film an“ und „ein fremder Helfer hält sie nicht auf“.
  - (d) In `ROLLE-PRUEFUNG.md`, Stichprobe 373, zähle ich „keine [Prüferrunde] vor dem Versand“ als Maß. Das ist nicht angepasst: Jede Grundstandprüfung zählte als Abweichung.
  - Stärkstes Gegenargument: Der Chef will das 100-mal Entschiedene nicht mehr sehen, und genau dafür ist das Tor da. Dann braucht es aber sein Wort zum Tor; außerdem gehören nur die Punkte mit ja/nein oder einer Messung hinein, die Wirkungspunkte bleiben Selbstprüfung dessen, der vorlegt.

**Weitere (gering):** Die neue Pflegeregel („im selben Commit hier ändern“) und die Ausnahme in Prüftreppe 4 streichen keine alte Regel (Haltung 6). Die Archiveinträge von 20:3x zu 431 („Körper passt“) und 416.4 sind eingearbeitet (B2 inhaltlich, D1).

**Nicht geprüft:** ob `claude/grundstand-461` die Punkte erfüllt (461.1 in Arbeit); Chefworte, die weder im Archiv noch in einem „Zu“-Absatz stehen (Telegram, Gespräche); ob ein Punkt fehlt, den der Chef früher als 27.10. entschieden hat.

## Lauf 55 · Auftrag 459 Doppelpack zu 458.1, 451.1, 447.1, 457 (`main` `9d8e6fef5`; 01.11., 13:4x; Wächter 457 in einer Probe-Arbeitskopie und mit `meldung.sh --probe` nachgestellt, Tagesbericht mit `--probe` und gesetzten Haken nachgerechnet, Katalog gegen `Gear.kt`, `Items.kt`, `Story.kt`, `Recipes.kt`)

**Ergebnis:** 451.1 ist an allen genannten Stellen umgesetzt (CLAUDE.md, Leitbild, Inhalt, Werkzeugtexte; in den Rollendateien stand der alte Name nicht). 447.1 ordnet alle 27 alten Punkte genau so den Stufen zu wie die Tabelle in Chefsache 447; Stufe 3 enthält die sieben Teile aus „K2b“, dazu 3.8 Gegenstandskatalog (458); zusammen 36 Punkte. `tagesbericht.py` zählt je Stufe richtig (Probe: 1.2 abgehakt, 1.3 „gebaut“ ergibt „1 von 4 abgenommen, 1 gebaut“, „seit gestern“ 1 und 1). 458.1: Der Katalog hat 88 Einträge, alle 57 Grundgegenstände aus `Gear.kt` und alle 31 aus `Items.kt`; Namen, alte Preise und Stufen stimmen in der Stichprobe; die Läden (Thessa, Morwen) entsprechen `Story.kt`, die Rezepte `Recipes.kt`; `gegenstaende.py --pruefen` läuft ohne Fehler. 457 hält an, wo „ohne Toon“, „ohne Tusche“ oder „ohne Spielshader“ steht.

**Befunde**

- **D56.1 Der Wächter 457 erkennt nur das Wort, nicht die fehlende Signatur:** Er hält an bei „ohne Toon-Licht“, „ohne Tusche“, „OHNE TUSCHE“ und „noch ohne Toonlicht“. Durch kommen dagegen „Tusche fehlt noch“, „kein Toon-Licht“ und „ungeschattet“. Das gilt für `commit-pruefung.py` und für `meldung.sh --probe`. Eine Probe ohne Signatur kommt also durch, wenn sie es nicht dazuschreibt. Angehalten wird nur, wer es ehrlich angibt; der Anreiz geht dahin, die Angabe wegzulassen. Für den Chef war die Angabe bei 431 der Hinweis, auf den er reagierte (11:45). Was die Signatur tatsächlich in die Proben bringt, sind 457.1 und 457.2 (Probeskripte zeichnen standardmäßig mit Spielshadern). Beide sind startbar, aber nicht gebaut.
- **D56.2 Der Wächter 457 greift in ganz `docs/chefsache/`, nicht nur bei Vorlagen in `ansehen/`:** Laut Auftrag in `ARBEIT-PROJEKT.md` sollte er nur Vorlagen in `ansehen/` prüfen. Er greift aber bei jeder neuen Zeile, auch in `README.md` und `entscheiden/`. Ein Vergleich hält ebenfalls an, z. B. „links ohne Tusche, rechts mit“; nachgestellt in `ansehen/999-probe.md` und `README.md`, jeweils Exit 1. Ein Blatt alt/neu, auf dem das alte Spiel ohne Tusche gezeichnet war, braucht also „Chef erlaubt ohne Signatur“, obwohl der Chef dazu nichts gesagt hat.
- **D56.3 Die Teile, die der Chef liest, sind noch auf dem alten Plan (447.1, 451.1):** `ARBEIT-TAGESBERICHT.md` führt noch die „Roadmap (Vorschlag 447)“ mit K1–K4 und „W1–W3 danach … auf dein Wort“. Seit 447 („mit K2b“) liegen Ruf, Handwerk und Tiere beruhigen aber in Stufe 3 vor dem Markt. Unter „Prioritäten“ steht noch „447 entscheiden“. Die Eingabe „Größtes Risiko“ nennt „Regeln 2.0 (K1)“; sie geht so in Zeile 9 und ins Telegram. Unter „Wie das Projekt aufgebaut ist“ steht „Spielsystem 2.0“. In `LISTE-ABNAHME-KAPITEL1.md` steht der ausführliche Stand (Zeile 10 des Berichts) noch in den Blöcken T–S mit „G Spielsystem 2.0“. Wochenziel 2 nennt „Umfang A seit 01.11., 09:43“, den 447 aufgehoben hat.
- **D56.4 Gegenstandskatalog: kein Haken hält eine veraltete Übersicht an, Rezepte ohne Gold (458.1):** `LISTE-GEGENSTAENDE.md` heißt „erzeugt, nicht von Hand ändern“. `gegenstaende.py --pruefen` ruft aber kein Haken und kein Werkzeug auf, obwohl drei Besitzer (Jerry 458.2, Tom 458.3, Homer 458.4) dieselbe Datei füllen. Bleibt die Übersicht veraltet, merkt es keiner. Die Rezepte nennen nur die Zutaten; der Goldanteil aus `Recipes.kt` fehlt (Heiltrank 5, Kräutertrank 2, Großer Heiltrank 15, Alchemistenfeuer 5 Gold).

**Nachprüfung 456.1 (Lauf 54, `9d8e6fef5`):** D55.1 behoben (Zeile 4 „1 ansehen, 1 Build, 1 tun“). D55.2 behoben: Das Telegram hat zehn Zeilen, damit auch die Stufenzahl statt „von 27“. D55.3 zum Teil: Zeile 6 zählt alle Bereiche (5 statt 2), Zeile 5 nennt den Build beim Chef; „Sitzungen letzte Woche“ in Zeile 3 fehlt noch, wie Perikles selbst vermerkt. D55.4 behoben: Der Haken nimmt die Fassung aus der Notizkopie; das gilt ab dem nächsten `notiz.sh` je Kopie. D55.5 behoben im Wortlaut; ob Ford Perikles dann tatsächlich erinnert, steht nicht im Werkzeug.

**Nachprüfung 459.1 (01.11., 13:5x, `82d530b86`):** D56.1 zum Teil behoben: „kein Toon-Licht“ und „Tusche fehlt noch“ halten jetzt an, „ungeschattet“ geht weiter durch, wie bei jeder Wortliste. D56.2 behoben: Der Wächter prüft nur noch `ansehen/`, ein Vergleich geht durch. D56.3 behoben: Roadmap im Tagesbericht mit Stufen 1–6 und BRS. D56.4 behoben: Der Haken hält einen Katalog mit veralteter Übersicht an (nachgestellt, Exit 1), die Rezepte tragen `gold` wie `Recipes.kt`. **D57.1 neu:** Steht in der Zeile irgendwo „mit Toon“ oder „mit Tusche“, gibt der Wächter sie frei. Auch eine halbe Signatur kommt also durch: „Probe mit Toon-Licht, aber ohne Tusche“ geht durch (`commit-pruefung.py` Exit 0); in `meldung.sh` gilt dieselbe Ausnahme. Behoben 13:5x (nachgestellt mit `meldung.sh --probe`): Die halbe Signatur und „ungeschattet“ halten an, der Vergleich „links ohne Tusche, rechts mit Tusche“ geht durch.

**Weitere (gering):** Sokrates nannte in Chefsache 458 „46 Gegenstände“; `Gear.kt` hat 57 Grundgegenstände, der Katalog nimmt richtig alle. `startbar.py` gibt mit „BRS“ eine Zeile von der Sperre des alten Systems frei, so wie bisher mit „2.0“ (424). Der Katalog liegt unter `tools/`, laut 458.2 kopiert der Bau ihn nach `godot/daten/`: zwei Stände, solange das nicht automatisch geht.

**Nicht geprüft:** 457.1 und 457.2 (nicht gebaut); ob das Spiel die Datei liest (458.2 offen); der Wächter im echten pre-commit-Haken (nur das Werkzeug direkt aufgerufen).

## Lauf 54 · Auftrag 456 Doppelpack zu 448.2, 449, 450 (`main` `d6274420c`; 01.11., 11:4x; 449 und 450 in Probe-Repos nachgestellt, Tagesbericht mit `--probe` nachgerechnet)

**Ergebnis:** 450 tut, was der Chef verlangt hat (10:55): `meldung.sh --bild` trug den Link im Probe-Repo unter Zeile 1 ins Blatt ein, `zug-index.py` meldet Blätter ohne Link. 449 hält einen Commit mit `.fbx`, `.TGA` oder Ordner `kauf/` an, `.glb` geht durch, `BORNIM_EIGEN=1` lässt nur die Endung durch. Der Tagesbericht rechnet ohne Fehler; die Zahlen „erledigt 24 h“ stimmen (Vergleichsstand 29.10., 11:58, weil vom 29.10., 12:00 bis 31.10., 19:00 kein Commit kam).

**Befunde**

- **D55.1 Zeile 4 und Telegram zählen den Build nicht, der auf den Chef wartet (448.2):** `chefsache()` liest nur Tabellenzeilen, die mit „| [“ beginnen. Build-Zeilen in der Übersicht beginnen mit der Folge („| 1 | [0.348.146]“). Bericht 11:36: „5 entscheiden, 2 ansehen, 1 tun“; Build 146 wartet seit 01.11., 02:56 und fehlt, ebenso im Telegram-Text.
- **D55.2 Telegram vier Zeilen statt zehn (448.2):** In Chefsache 448 lautet die Frage „zehn Zeilen per Telegram, jede mit einer Zahl“; der Chef antwortete „448 mach es so“ (11:09). `tagesbericht.py --telegram` schickt einen Link und drei Zeilen (Abnahmeliste, bei dir, Risiko); Builds, Fehler, Geld, Rest geschätzt, von dir zuerst gefunden fehlen.
- **D55.3 Zeilen 3, 5, 6 messen weniger als vorgeschlagen (448.2):** Zeile 6 „Fehler offen aus deinen Tests“ zählt nur Bereich E mit „Fehler“, „Befund“ oder „Build n“ im Titel: 2 (257 und 358, dieses „fertig“). 416.1 „Tasten reagieren schlecht (… Build 143, Chef)“ ist Bereich B und fehlt, ebenso die Befunde aus Build 143 (t146). Zeile 5 ohne „letzter Build, getestet ja/nein“; Zeile 3 ohne „wie viele Sitzungen die letzte Woche geschafft hat“.
- **D55.4 Kaufsperre greift in den Arbeitszweigen nicht (449):** Der pre-commit-Haken (`notiz.sh`) startet `tools/commit-pruefung.py` aus dem ausgecheckten Zweig. Keiner der zehn jüngsten Code-Zweige (z. B. `tom-348-406-schild`, `jerry-438-wolf-kampf`, `tom-431-voelker`, `spike-416-4-rennen`) hat die neue Fassung; dort, wo Kaufmodelle verarbeitet werden, prüft der Haken also nicht, bis `main` hineingemischt ist. Der Inhaltsvergleich wirkt nur, wenn das Kaufrepo neben der Kopie liegt (hier nicht); eine gekaufte Textur als `.png` außerhalb von `kauf/` geht sonst durch.
- **D55.5 Ford meldet „Perikles neu gestartet“, auch wenn er nicht neu startet (448.2, `lauf.py` Z. 574–578):** Läuft Perikles um 10 Uhr noch (`per_belegt`), gibt `lauf.py` `TAGESBERICHT-FEHLT` mit diesem Wortlaut aus, aber keine Startzeile.

**Weitere (gering):** Ein Film von 20 bis 50 MB kommt nicht in den Zweig `bilder` und bekommt keinen Link; `zug-index` rät dann zu einem `bilder:`-Link von Hand, den es nicht geben kann (bisher größter Film 23 MB, Mitte 1,6 MB, 88 Filme). `meldung.sh` trägt den Link auch ein, wenn Telegram scheitert (Probe: 404, Link stand im Blatt). `CLAUDE.md` ist mit der Ausnahme 450 über 15 KB (15463).

**Nicht geprüft:** `lauf.py` in einem echten Lauf um 10 Uhr; `meldung.sh --film` (nur `--bild` nachgestellt); ob die Teams `main` in ihre Zweige mischen.

## Lauf 53 · Auftrag 441 Nachschlagewerk 2.0 querlesen (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md` und `LISTE-BESTIARIUM.md` „Werte 2.0“, `main` `8c5bf9877`; gegen E 1–76; 01.11., 08:1x; Text fremd geprüft)

**Ergebnis:** Das Nachschlagewerk gibt die Entscheidungen 1–76 meist richtig wieder. Die Rechnungen stimmen: Startpunkte (18 Punkte: 6 frei, 21 Punkte: 9 frei), Völker je +1 unterm Strich, 13 Pfade, alle Kernfertigkeiten aus der Liste der 37. Die drei Beispiele zu Modell D ergeben die Zahlen der Tabelle. Im Bestiarium stimmen Angriff, Abwehr und Wachsamkeit bei allen 18 Arten mit der Formel und den Werten aus `Monsters.kt` überein, Rüstung bei 18 (unter 0 auf 0 gesetzt), Leben bei 16. Fünf Befunde tragen.

**Die fünf wichtigsten**

- **D54.1 Erster Titel: Kapitel 2 oder 4 (Abschnitt 5):** Laut Satz unter der Takt-Tabelle „kommt der erste Titel in Kapitel 2“. Laut Prüfungstabelle bringt aber erst die Gesellenprüfung den Titel („Titelträger, z. B. Paladin“), und die gibt es ab Kapitel 4; in Kapitel 2 wird man Eingeweihter. E 51 sagt „Berufungen ab Kapitel 2“. Dazu: Die Spalte „höchster Rang ohne Prüfung beim Lehrmeister“ nennt für Kapitel 2–5 Ränge, die gerade eine Prüfung beim Lehrmeister brauchen. Die Zeile für Kapitel 6–7 ist bis auf „Meisterprüfung“ leer.
- **D54.2 Modell D reicht noch nicht für die Simulation (Abschnitt 2, 4, 7; D49.3 halb behoben):** Die Monsterwerte stehen jetzt im Bestiarium. Es fehlen aber Zahlen, ohne die „Zeit bis Stufe“ nicht rechenbar ist: die Erfahrung je Monsterstufe (Modell D gibt nur Faktoren), die Erfahrung je Heldenstufe, das Leben des Helden („aus Zähigkeit und Stufe“, ohne Formel) und Waffenwerte. Dazu kommen Wirkungen aus Abschnitt 2 ohne Regel in Modell D: Gewandtheit (Ausweichen, kritische Treffer), Wahrnehmung (Treffgenauigkeit im Fernkampf), Zauber (Schaden, Mana, Wille) und die Ätherdichte (E 76). Welcher Grundwert in „Waffe + Grundwert“ zählt, steht nur für den Nahkampf da (Kraft).
- **D54.3 Magie und Rüstung in zwei Fassungen (Abschnitt 5 gegen Abschnitt 7; D48.3 offen):** Laut Vorschlag in Abschnitt 5 hängt die Sperre an der Schule (Evokation, Illusion, Beschwörung), gilt also für jeden, der so zaubert. Laut Abschnitt 7 trifft sie den Magier ab der Gesellenprüfung, also den Pfad; Abschnitt 7 verweist für die Schulen zwar auf Abschnitt 5, sagt aber nicht, ob die Sperre auch ohne Pfad gilt. Ein Held ohne Pfad zaubert nach Abschnitt 7 Evokation in Plattenrüstung, nach Abschnitt 5 nicht. Ebenso offen ist, ob Leder als Rüstung zählt, denn als Grund nennt der Text Metall.
- **D54.4 Meisterschaften ohne Einladungsregel; Heilkunde ohne Chefwort (Abschnitt 6, Entwurf B):** Der Lehrmeister kommt, wenn „zwei Kernfertigkeiten Geselle“ sind. Jede Meisterschaft hat in Abschnitt 6 aber nur eine Fertigkeit; nach der Regel käme ihr Lehrmeister nie, gleiches Problem wie beim Beschwörer. Auch der Kapitel-Takt nennt Meister und Großmeister „nur im Pfad“, Abschnitt 3 dagegen „im eigenen Pfad oder in der eigenen Meisterschaft“; wann ein Lehrmeister der Meisterschaft prüft, steht nirgends. Entwurf B nennt dagegen Kräuterkunde „Kernfertigkeit der Meisterschaft Alchemist“. Heilkunde ist im Nachschlagewerk die sechste Meisterschaft; E 56 sagt „damit fünf Meisterschaften“, E 59 zählt nur sechs Fertigkeiten in der Gruppe. In Abschnitt 13 steht nur ihr Name als offen, nicht ob es sie gibt.
- **D54.5 Ruf gegen Prüfungen (Abschnitt 9 gegen Abschnitt 5, E 67):** „Günstigere Lehrer, frühere Prüfungen“ als Wirkung des Rufs: Die Lehrstunde hat der Chef verworfen („kann ich mir aufstecken“, Entwurf F), Prüfungen hängen am Kapitel (Takt). Was „früher“ heißt, ist offen. Auch Entwurf B (Ruf → „Lehrstunden“) und Entwurf F („Lehrstunden außerhalb der Berufung sind kurz“) führen die Lehrstunde weiter.

**Weitere (gering)**
- „Auf einen Blick“ „Pfad … genau einer“ gegen Abschnitt 5 und 7 „höchstens einen“. Die Auflagen „nicht Beschwörer“ (Paladin) und „nicht Paladin, nicht Heiler“ (Beschwörer) wirken nicht, weil es nur einen Pfad gibt. Gemeint ist vielleicht: keine Nekromantie bzw. keine Heilmagie üben.
- Namen: Die Gesellenprüfung öffnet Großmeister, die Meisterprüfung kommt bei 100. „Meister“ ist zugleich Rang, Stufe im Pfad und Wortteil von „Meisterschaft“. Für eine Anleitung schwer lesbar (Wortlaut Chef, E 63; nur Hinweis).
- Modell D, Beispiele: Der Abzug wird mit der bloßen Rüstung gerechnet, ohne den Faktor (1 + Fertigkeit / 100) aus E 74. Monster haben kein Feld für die Rüstungsfertigkeit. In Beispiel 1 und 3 zählt als Abwehr die volle Waffenfertigkeit (90 %, 80 % und 60 % gehen nur mit Abwehr 10, 20 und 40), nach E 75 gilt die halbe, falls kein Schild und kein Ausweichen angegeben ist. Der Angriffswert des Monsters hebt in Beispiel 1 auch den Schaden (× 1,5); dass er zugleich Schadensfertigkeit ist, sagen weder „Monster braucht“ noch das Bestiarium. In Beispiel 2 steht „Erfahrung × 0,1“, richtig ist nach E 73 null (der Satz darunter berichtigt es).
- Was entschieden ist, steht nur im Anhang: das Profil (E 76: Taten, Chronik, Ätherdichte, Ruf mit Gedächtnis) fehlt in Abschnitt 1–12. Die Anhänge sind zum Teil entschieden oder überholt: Entwurf A mit Modell D (E 73), C (E 76), F (E 67), D (E 68). Entwurf D nennt oben noch „Späher“ und „Werdegang“, gültig sind Herumtreiber und Herkunft (E 68, 69). Entwurf F kündigt an, die Abschnitte 2, 3, 5 umzuschreiben; das ist schon geschehen. Gegen Satz 3 des Kopfs: „Hier steht nur, was gilt“.
- Entwurf E, Wortlaut für das Leitbild: „Wege kommen von selbst, eine Berufung verdient man“. Den Weg als eigene Ebene gibt es nicht mehr (E 67), „Pfad“ ist vorgeschlagen.
- Startfertigkeiten (Herkunft, Mensch): mit welchem Wert man beginnt, steht nirgends; der Wanderer wählt „selbst“, aber ohne Zahl.

**Bestiarium „Werte 2.0“ (gegen `core/.../Monsters.kt`)**
- Leben nach der Formel falsch bei zwei Arten: Blutflügler 8 statt 9 (2W4+1, Mittel 6 × 1,5; wohl der Zuschlag +1 vergessen), Goblin-Späher 13 statt 12 (2W6+1, Mittel 8).
- Stufe gegen Gebietsband: Blutzahnhöhle 2–5, Tiefer Flüsterwald 2–4, aber Riesenratte (Stufe 1) in der Höhle, Kobold und Blutflügler (Stufe 1) im Tiefen Wald.
- Rundung nicht genannt: halbe Werte gehen auf die gerade Zahl (Schaden 4,5 → 4, 5,5 → 6, 7,5 → 8, 8,5 → 8; Leben Grak 58,5 → 58). Rüstung und Wachsamkeit werden still auf 0 gesetzt (Zombie, Ockerschleim −1; Kobold −10). Nur bei der Abwehr steht „nie unter 0“.
- „Erfahrung folgt aus der Stufe“: eine Grundzahl je Stufe fehlt (D54.2).

**Abgleich Lauf 48 und 49 (nur Spielsystem)**
- D48.1 offen, jetzt richtig gerechnet und in Abschnitt 13 (18 oder 21, Volk über 8).
- D48.2 behoben durch den Kapitel-Takt (E 67), Grenze Kapitel 1 = 6. Neu dazu D54.1.
- D48.3 offen (Vorschlag Abschnitt 5), dazu D54.3.
- D48.4 (a), (b), (c), (f) behoben (Herkunft, Kernfertigkeiten, Reparieren, Titel); (d) und (e) offen in Abschnitt 13.
- D48.5 behoben (Modell D, E 73). Die Lücken stehen in Abschnitt 13, die Übersicht als Entwurf B; über Entwurf B ist noch nicht entschieden.
- Liste „veraltet“: im Nachschlagewerk behoben bis auf „fünf Meisterschaften“ (D54.4) und „Lehrer“ (D54.5).
- D49.1, D49.2 offen in Abschnitt 13; D49.3 halb (D54.2).
- D49.4 offen in `LISTE-ABNAHME-KAPITEL1.md` (Perikles): Zeilen „18 Punkte“, „Werdegänge“ (E 28, 29, 45), „Niveau je Kapitel begrenzt“ (E 20), „Wege sichtbar, Berufungen erst ab Kapitel 2“ (E 51, 52), „Kräuterkundiger, Heiler, Schmiedegeselle“. Seit E 67–69 heißt es Herkunft, Kapitel-Takt, Lehrmeister.

**Nicht geprüft:** Verlauf `DESIGN-SPIELSYSTEM-2-0.md` außer der Liste der Entscheidungen, Code der Godot-Fassung, Spielgefühl und Balance (nur Rechnung), Hintergrundtexte des Bestiariums (428), Merkmale und Beute.

## Lauf 52 · Auftrag 443 Doppelpack zu 436 (`main` `88415f87b`; 01.11., 00:1x; `lauf.py` mit 16 Titeln nachgestellt)

**Ergebnis:** Die Namensform steht in `CLAUDE.md` Start 2 und in allen Rollendateien außer Ford. `lauf.py` liest „416.3:“ als 416.3 und „403, 406:“ als 403,406. Uhrzeiten zählt es weiter nicht mit („12:30“, „um 9:30“).

**Befunde**

- **D52.1 Wochenziel bucht ins Leere:** `ROLLE-PROJEKT.md` schreibt „Perikles – Wochenziel: TT.MM. (…)“ vor. `nummer_aus_titel` macht aus „Wochenziel: 02.11.“ den Vorgang „02.11“. Diese Zeile gibt es nicht, also druckt `_buchen` nur „WARNUNG Kosten“. `KOSTEN-GEBUCHT.tsv` führt die Sitzung trotzdem als gebucht, die Kosten fehlen also in jeder Vorgangszeile. Den Fehler gab es schon vor 436 („Wochenziel 02.11.“ ergibt ebenfalls 02.11), 436 hat ihn übernommen. „338.1: Stand zum Marktstart“ ist dagegen behoben (vorher „01.11.“ → 01.11).
- **D52.2 eine alte Form übrig:** `ROLLE-BERATUNG.md` Zeile 36 „Sokrates – BornWire (TT.MM., HH:MM)“, ohne Vorgang.
- **D52.3 Ausnahme Ford ohne Chefwort:** Chef 31.10., 22:58: „Gilt für alle Beschäftigten!“. Perikles nimmt Ford aus („Ford – Betriebsleiter“, Eingang Betrieb), ebenso die „Ford-Wache“. Fürs Werkzeug gleich (Ford bucht auf Betrieb); ob die Ausnahme gilt, entscheidet der Chef. Im Vorgangsarchiv fehlt ein Eintrag zu 436; der Wortlaut steht nur in `ARBEIT-PROJEKT.md` „Zu 436“.

**Nicht geprüft:** ob Ford die laufenden Sitzungen umbenannt hat; `lauf.py --sperre` im echten Lauf.

**Nachprüfung 443.1 (`main` `13ad5b26b`; 01.11., 00:1x; 14 Titel nachgestellt):** D52.1 ist behoben: Ein Datum zählt nicht mehr als Vorgang („Wochenziel: 02.11.“ ergibt jetzt keinen Vorgang, also „Betrieb“; „338.1: Wochenziel 02.11.“ ergibt 338.1). D52.2 ist behoben (`ROLLE-BERATUNG.md` „Sokrates – 253: BornWire“). Zu 436 gibt es einen Eintrag im Vorgangsarchiv, die Ausnahme Ford steht dort als offen (443a). 416.3, 403/406, 348.12f, 13e und 216.3 werden weiter richtig gelesen.
- **D53.1 `lauf.py` gibt selbst noch Titel in alter Form aus:** Z. 570 „Perikles – Stand zum Marktstart TT.MM.“, Z. 574 „Perikles – Wochenziel TT.MM.“, Z. 575 „Diogenes – Wochenzählung TT.MM.“, Z. 595 „Sokrates – Stellungnahme (…)“. Ford legt die Sitzungen mit diesen Titeln an, also ohne Vorgang und ohne „:“ (gegen 436 und `ROLLE-PROJEKT.md` „338.1: …“). Folge seit dem Datumsfilter: Diese Sitzungen buchen auf „Betrieb“ statt auf 338.1. Vorher gingen ihre Kosten ganz verloren („01.11“).
- **D53.2 (klein):** Ein Vorgang mit zwei Zahlen und Punkt am Ende wird jetzt für ein Datum gehalten: „Tom – Nachtrag zu 72.10.“ ergibt keinen Vorgang. In der Form 436 („72.10: …“) kommt das nicht vor.

## Lauf 51 · Auftrag 435 Doppelpack zu 433 (`main` `68de4970f`; 31.10., 22:2x; an einer Kopie nachgestellt)

**Ergebnis:** Die Startsperre mit mehreren Namen („Start Tom, Jerry, …“) sperrt jetzt jeden Namen; vorher nur den ersten (Protokoll 21:27 hatte fünf). Spike läuft auf seiner Zeile „in Arbeit bei Spike“ weiter, Tom nimmt sie nicht, ein zweiter Spike startet nicht. Kopf `ROLLE-ENTWICKLUNG.md` trifft den Code.

**Befunde**

- **D51.1 Doppelarbeit bei Titel ohne Nummer:** Tom arbeitet an 417 unter „Tom – Tragart Stab Axt Bogen“ → `lauf.py` startet Spike auf 417, dieselbe Zeile. Ursache: `besetzt == {"Nachfolger"} or not besetzt and not team_s` greift nur ohne laufende Sitzung; mit laufender Sitzung ohne Nummer nimmt Spike die erste Muss-Zeile. Ebenso Perikles' Probe „Tom – Leichen“ → Spike 417. Gemeint ist wohl `not besetzt` allein.
- **D51.2 hängende Zeile (aus dem Code, nicht nachgestellt):** Endet Spike ohne neuen Stand und hat Tom sonst nichts Startbares, gilt „Tom frei, macht es selbst“, aber `startbar.py` sperrt die Zeile für Tom („in Arbeit bei Spike“): keiner nimmt sie.
- **D51.3 „notfalls“:** Chef 22:1x: „Leiharbeiter, die wir notfalls starten können. Oder halt intern Arbeit umschichten“. Gebaut ist: in jedem Lauf, sobald Tom (Jerry) belegt ist oder startet und ein zweites Muss mit anderem Zweig da ist. Nachgestellt mit Tom auf 417 und Jerry auf 402: Spike 417, Tuffy 403; heute also fast immer vier Entwicklersitzungen. Ob das „notfalls“ ist, entscheidet der Chef. **Chef 31.10., 22:53: „So lassen“.**

**Nicht geprüft:** `lauf.py --sperre` im echten Lauf; Fords Start einer Spike-Sitzung (`ROLLE-BETRIEB.md`); Zusammenführen zweier Zweige eines Teams auf `main`.

## Lauf 50 · Auftrag 429 Doppelpack zu 424 und 412 (`main` `a005a27f3`; 31.10., 21:4x; Text fremd geprüft)

**Ergebnis:** 412 in `CLAUDE.md` „Nummern“ trifft den Wortlaut im Archiv 412. 408 in `ROLLE-ENTWICKLUNG.md` „Bestand zuerst“ (Commit `281753354`) trifft das Archiv 408 und die Reihenfolge 11:22–11:26 (Bestand, frei, Kauf, Eigenbau; mehrere Stücke drehend im Film, Chef wählt); das frühere „es muss nichts mehr gekauft werden“ (11:20) ist durch 11:2x überholt. Der Wächter 424 arbeitet wie beschrieben, hält heute aber kaum eine Zeile von selbst an: Von 17 Treffern in den Vorräten treffen 14 nur, weil ihr Stand schon „ruht: altes SRD-System“ lautet (nachgestellt mit `ALTES_SYSTEM` über alle Tabellenzeilen).

**Befunde**

- **D50.1 Wortliste zu eng:** Nicht erkannt (nachgestellt mit `altes_system()`): „Klasse“, „Kleriker“, „Kämpfer“, „Schurke“, „Rüstungsklasse“/„RK“, „Übungsbonus“, „Zauberplatz“ (nur die Mehrzahl trifft), „d20“, „Talente“ (nur `talente.gd`). Startbar sind so Jerry 403 „Held je Klasse“, Jerry 406 „Rundschild des Klerikers“, Tom 376.1 „Klassen abgenommen“. Ob das Figuren- statt Regelarbeit ist, entscheidet der Besitzer; der Wächter sieht es nicht.
- **D50.2 Freigabe zu weit:** `ALT_FREI` gibt jede Zeile mit „2.0“ frei, auch in „142.0“ („Build 142.0 SRD-Hinweis“ → frei), ebenso „ersetz“ in jedem Sinn („ersetzt den alten Kampf SRD“ → frei). Vorschlag: `Spielsystem 2\.0|\b2\.0\b`.
- **D50.3 Abnahmeliste gegen ruhende Muss:** Block M verlangt 212, 249, 38, 39; in Jerrys Vorrat ruhen alle vier („altes SRD-System“). Für den Bau der Regeln 2.0 (Block G, Kampf ohne W20) gibt es keinen Vorgang bei Tom oder Jerry (`LISTE-VORGAENGE.md` „2.0“: nur 413, 418–420, 422, 427). Die Teams haben für G und M nichts Startbares, bis Perikles Zeilen anlegt.
- **D50.4 Archiv fehlt:** 424 hat keinen Eintrag mit dem Chefwortlaut („keine Energie mehr in das alte SRD-System stecken“) im Vorgangsarchiv; er steht nur im Vorrat, in `startbar.py` und in der Umzugsliste.

- **D50.5 407 `urteil()` (Nachtrag, `17b7725bc`), nachgestellt am Archiv:** (a) zu eng: Urteile in Unterpunkten einer Chefrunde (eingerückt, ohne eigene Zeit, z. B. „348.6, Netz“, „142.1, Zielversion 36“; 6 Stück) erkennt die Kopfzeilen-Regel nicht, sie geben keine Läufe frei; 16 von 568 Köpfen haben keine Zeit in der Form „(TT.MM., HH:MM“. (b) zu weit: jeder Archiveintrag mit der Nummer gibt frei, auch ein Vorentscheid von Perikles, Homer oder Sokrates (18 Köpfe mit „Vorentscheid“, z. B. 383.1, 19:29), der kein Urteil des Chefs ist. (c) „21:1x“ zählt als 21:10: Läufe zwischen 21:10 und dem echten Urteil gelten als danach. Richtig erkannt: 348.12f gegen 348.12, D1.14 gegen 1.14.

**Nicht geprüft:** jede Zeile der Umzugsliste einzeln; `lauf.py` im Lauf (nur, dass es `startbar` einbindet); `probelauf.py` als Haken im echten Lauf.

## Lauf 49 · Auftrag 419 Prüfung 418 und 421 (`main` `6185da179`; 31.10., 21:4x; Text fremd geprüft)

**Ergebnis:** Die Direktive in `CLAUDE.md` stimmt Zeichen für Zeichen mit dem Wortlaut im Vorgangsarchiv „418“ überein, ebenso die Abschrift oben in `LISTE-ABNAHME-KAPITEL1.md`. Jedes Wort der Direktive hat einen Block in der Abnahmeliste (T, A, K, M, G, W; S für „marktreif“). Die Abnahmeliste erbt aber drei Fehler aus Spielsystem 2.0 (Lauf 48), und zwei Teile fehlen.

**Die fünf wichtigsten**

- **D49.1 Werdegänge ohne Handlung im Kern (G gegen Chefsache 418, Votum A):** G verlangt die Werdegänge (E 28, 29, 45), dazu gehören Kräuterkundiger (Kräuterkunde, Alchemie) und Schmiedegeselle (Schmieden, Bergbau). Votum A lässt Sammeln und Alchemie aus Kapitel 1 heraus (erst B), Schmieden steht in keiner Option. Auch der Heiler startet mit Kräuterkunde. Mit A starten drei von sechs Werdegängen mit Fertigkeiten, die es in Kapitel 1 nicht zu tun gibt. M verlangt außerdem: „jeder Werdegang schafft die Bosse in vergleichbarem Maß“.
- **D49.2 Truhen und Fallen ohne Entdecken (G gegen Option C):** Kern A enthält „Fallen und Truhen“ (E 55). Fallen entdeckt man nach Abschnitt 10 (zu E 57) über Spähen, das Option C erst später bringt. Ohne Spähen fehlt im Kern das Entdecken, oder es gilt eine ältere Fassung (Grundwert Wahrnehmung, Abschnitt 10; „Fallen entschärfen erkennt und entschärft“, Truhen-Abschnitt); entschieden ist das nicht (Lauf 48, Liste „veraltet“).
- **D49.3 Monsterwerte und Messung fehlen (M, W gegen Spielsystem 2.0 Abschnitt 5 und 6 „M1“, Abschnitt 11):** Sokrates' M1 nennt „neue Monsterwerte Kapitel 1“ und die Prüfung „Simulation Zeit bis Stufe“. „Messen statt raten“ (Abschnitt 11) ist der Weg, den Preis der SRD-Abkehr zu zahlen. Beides steht nicht in der Abnahmeliste. M nennt „Kampf ohne W20 nach Stufen (E 7)“, der Stufenfaktor ist aber offen (Frage 3, S1).
- **D49.4 G übernimmt Ungeklärtes aus 2.0:** „ab 1, 18 Punkte, jeder Wert 3 bis 8“ (E 64) ist rechnerisch gleich „Start 3, 6 Punkte frei“, das Beispiel braucht 21 Punkte (D48.1). „Niveau je Kapitel begrenzt“ (E 20) hat keine gültige Regel, und mit den Entwurfszahlen gibt es in Kapitel 1 keinen Weg (D48.2), G verlangt aber „Wege sichtbar“. Die Liste der 37 ist nicht auf Werdegänge und Wege umgeschrieben (D48.4).
- **D49.5 421 ohne Archiv, Rest der Liste veraltet:** Die Regel „im Doppelpack“ steht in `ROLLE-PROJEKT.md` und `ROLLE-PRUEFUNG.md` (Chefzitat nur dort), im Vorgangsarchiv gibt es keinen Eintrag 421 („Entschiedenes im Vorgangsarchiv“). In `ROLLE-PRUEFUNG.md` ersetzt der Zusatz „nicht mehr jeden Ablaufentwurf“ (Regelbilanz erfüllt), in `ROLLE-PROJEKT.md` kommt er dazu, ohne etwas zu streichen. In `LISTE-ABNAHME-KAPITEL1.md` stehen unter der neuen Liste weiter „Stand 29.10., 01:05“ (Stillstand bis 31.10., 20:00, Jerry steht seit 00:27), das Wochenziel 2 mit festen Tagen (02.11. „gebaut“, 03.11. gemessen) gegen „es gibt keinen Termin“, und „Reihenfolge“ Schritt 1–2 (Umzug Woche 1).

**Dazu (Helfer):** Chefsache 418 will nach der Wahl Termine setzen und Wochenziel 2 auf den 02.11. rechnen; der Satz „es gibt keinen Termin“ der Direktive verlangt eine Klärung, ob Wochenziele mit Tagen weiter gelten.

**Außerhalb von 418, offen nach 61:** `CLAUDE.md` Kopf „Kotlin, Jetpack Compose, Regeln nach SRD 5.1“ und `DESIGN-LEITBILD.md` Punkt 4 („Das Regelwerk wird nicht gewechselt … Stufe 20“) widersprechen der neuen Direktive; nach E 61 kommt erst ein Entwurf an den Chef. Alte Direktive noch in `tools/regeltreue/stufe2/CLAUDE.md` (Testvorlage?).

**Nicht geprüft:** ob die Blöcke T, A, K, W alle Pflichten der alten Liste abdecken (nicht abgeglichen), Code, Schätzbarkeit der Blöcke.

## Lauf 48 · Auftrag 420 Spielsystem 2.0 (`DESIGN-SPIELSYSTEM-2-0.md`, Stand `3d64e00`, Entscheidungen 1–65, Abschnitte 1–12; 31.10., 21:3x; Text fremd geprüft)

**Ergebnis:** Die Entscheidungen sind fortlaufend 1–65, die Liste der 37 Fertigkeiten zählt richtig (10+4+4+5+1+3+4+6), 13 Berufungen und die alten Summen (69 Fertigkeiten, 19+4=23, Werdegänge je 6 Punkte) stimmen. Fünf Befunde tragen, dazu veraltete Stellen.

**Die fünf wichtigsten**

- **D48.1 Rechenfehler Startwerte (64, Abschnitt 12):** Start 1 je Wert (6) plus 18 Punkte = 24. Das Beispiel Magier 8/6/4/3/3/3 ergibt 27, braucht also 21 Punkte. Mit 18 Punkten und Untergrenze 3 sind 18 von 24 fest verteilt, frei bleiben nur 6: ein Wert höchstens 8, die übrigen fast alle 3 (etwa 8/4/3/3/3/3). Das entspricht „Start 3, 6 Punkte frei“. Volksbonus +1 auf zwei Werte (Werdegang-Abschnitt) kann die Obergrenze 8 überschreiten; ungeregelt.
- **D48.2 Fertigkeitsgrenze je Kapitel ohne gültige Regel (20, 35, 44, 51, 65 gegen Block 5):** Die Formel in Block 5 (Grenze = 100 × Stufengrenze ÷ Höchststufe) braucht eine Höchststufe, die es nach 35 nicht gibt; die Skala 0–100 mit Großmeister in Kapitel 7 widerspricht 65 (Ränge offen). Frage 19 steht als beantwortet (Stand-Zeile unter den Fragen), 35 beantwortet aber nur die Heldenstufe. Folge mit den Entwurfszahlen: Weg verlangt zwei Fertigkeiten auf Geselle (über 25), Kapitel 1 hat Grenze 15 (Entwurf) – dann gibt es in Kapitel 1 keinen Weg, gegen 51 („Kapitel 1 zeigt die Wege“). Berufung verlangt Meisterrang (über 50), Kapitel 2 hat Grenze 30 (Entwurf) oder 40 (Formel Block 5) – mit beiden Tabellen keine Berufung in Kapitel 2, gegen 51 („Berufungen ab Kapitel 2“). Für die Grenzen stehen drei verschiedene Tabellen im Text (Fertigkeitsniveau 15/30/40/…, Block 5 30/40/50/…, Frage 19). Die Stufengrenze von Kapitel 1 als Zahl fehlt ebenfalls (Code heute 6).
- **D48.3 Magie in Rüstung (10, 33 gegen Abschnitt 9):** Grund laut 10: Metall stört die Magiepartikel; 33: harter Ausschluss, Ausnahme nur Kriegsmagier mit leichter Rüstung. Abschnitt 9 lässt den Paladin (Heilmagie, Weg Schutz mit Schwerer Rüstung) und den Heiler (höchstens leichte Rüstung) in Rüstung zaubern. Entweder sind Paladin und Heiler weitere Ausnahmen, oder Heilmagie fällt nicht unter die Sperre; beides steht nirgends.
- **D48.4 Liste der 37 (59) nicht durchgezogen:** (a) Werdegänge nennen gestrichene Fertigkeiten: Abhärtung (Schildträger), Aufmerksamkeit (Schütze, Kräuterkundiger), Zauberwirken und Konzentration (Zauberer behält nur Evokation), Reparieren (Schmiedegeselle). (b) Abschnitt 9: Schatzjäger braucht Klettern, das 55 streicht; Weg Magie braucht zwei Kernfertigkeiten aus Zauberwirken, Konzentration und einer Schule, nach 59 bleibt nur die Schule; Assassine braucht Gifte mischen, das jetzt in Alchemie (Meisterschaft) steckt; Waldläufer braucht Tiere zähmen und Fallen stellen (beide weg); ebenso fehlen Athletik, Parieren, Zweiwaffenkampf, Akrobatik, Ausdauer, Lager und Feuer, Rituale, Nekromantie, sodass die Wege Kampf, Wildnis und Magie nach der Liste nicht erfüllbar sind (Abschnitt 10 kündigt das Umschreiben an, es fehlt noch). (c) Reparieren ist nach 15 und 43 eine Fertigkeit mit vier Rängen, nach 59 nur Teil von Schmieden (Metall); wer Leder und Stoff repariert, ist offen. (d) Spähen, Tiere beruhigen und Lederarbeit haben keinen Haupt- und Nebenwert (die „bestätigte“ Zuordnung gilt den 69). (e) M1 enthält „sechs Werdegänge“, Schmiedegeselle (Schmieden) und Kräuterkundiger (Alchemie) starten aber mit Handwerk, das erst M3 bringt. (f) „Möglicher Titel später“ der Werdegänge nennt Hauptmann (gestrichen, 49), Pfadfinder (aufgeteilt) und Schmiedemeister (jetzt Meisterschaft Schmied, 50).
- **D48.5 Kernfrage und Offenes ohne Liste:** Der Widerspruch aus Abschnitt 2 (2 und 48 „aufsteigen durch Tun“ gegen 7 „die Heldenstufe entscheidet den Kampf“) ist mit S1 und Frage 3 (Stufenfaktor) weiter offen; M1 braucht beides. Die Zeile „Stand 31.10.2026, abends“ unter den Fragen ist veraltet. Ohne Nummer und Frage stehen: Gefährten, Monsterwerte, Niederlage, Spielstände (Abschnitt 5), die Übersicht der Stufen und Ränge (65), die Abnutzungsrate (Frage 11, Rest). Tatsächlich offen sind nach meiner Zählung: 3, 11a, S1, S3, T5, G2, Umfang des Lehrmeister-Wegs (63), Rest von T1, dazu diese sechs Lücken.

**Veraltet oder widersprüchlich im Text (für das Eindampfen, 422)**
- Glossar Regelbegriffe: „Zauberpunkte (ZP) … Bleiben“ gegen zweite Runde „ZP → Mana“ (27).
- Vorlage zu Frage 18: „Entscheidung: offen“ (entschieden 44). Entscheidung 22: „offen (Frage 20)“ (35). 34 „alle 22 Titel“ ohne Vermerk „ersetzt durch 49“. Abschnitt 8 „gestrichen oder verschoben“ (49: gestrichen, nicht verschoben). Abschnitt 10 „jede der 34“, F1 „etwa 34“ (gültig 37).
- 56 „fünf Meisterschaften“ gegen Gruppe „Meisterschaften (6)“ mit Heilkunde und Kochen (Meisterschaft heißt Feldkoch); Heilkunde ist zugleich Kern von Weg Heilung und Berufung Heiler.
- Heimtücke und Ausschlüsse: „schwere Rüstung senkt Schleichen“ gegen 33 (gesperrt).
- Fallen entdecken: Abschnitt 10 über Grundwert Wahrnehmung, Abschnitt 10 F3 und 57 über Spähen.
- Startwerte 5 plus 6 Punkte (Grundwerte-Steigerung, Werdegang) gegen 64.
- Lehrer „neun Angebote, nicht 72“ (69, jetzt 37 in acht Gruppen); Frage 8 „10 bis 15“ gegen Block 8 (23) und 59 (37).
- Glossar: Kämpfer, Schurke, Kleriker „werden Titel“, es gibt keine solche Berufung.
- Name Heiler zweimal: Werdegang und Berufung.
- Vorschlag Erfahrung: Story soll „ohne Nebenwege an die Grenze“ bringen, hat in der Beispielverteilung aber nur 10–15 %.
- Abschnitt 9 Magier „keine Rüstung (Entscheidung 33)“: steht in 10, nicht in 33. M0 nennt noch R1–R4, 69 Fertigkeiten, 22 Titel.

**Nicht geprüft:** Code und Godot-Fassung (Fundstellen wie `Story.levelCap`, `Resting.kt`), Quellen im Netz, die Chefsache 413a, Spielgefühl und Balance der Zahlen (nur Rechnung).

## Lauf 47 · Auftrag 275 Nachprüfung D46.1, D46.2, D46.4 (`main` `e5b790d3`, an einer Kopie; 27.10., 17:0x)

**Ergebnis:** D46.1, D46.2 und D46.4 sind behoben. `LEICHEN_START` darf eingeschaltet werden, sobald die falsche Leiche Sokrates 26 geklärt ist. Ist der Schalter an, solange 26 ungeklärt ist, startet Ford Sokrates, um einen Stand zu berichtigen, der stimmt.

- **D46.1 behoben.** Geprüft an einer Kopie mit 10 Aufrufen. `stand 348.9` und `fertig 374` ohne `--rolle` brechen ab, nennen die Vorräte und schreiben nichts (Exit 1). Eine unbekannte Rolle, eine Rolle ohne Zeile und `--rolle` ohne Wert brechen ebenfalls mit Meldung ab. `stand 348.9 … --rolle diogenes` schreibt nur in die Zeile von Diogenes; Groß- und Kleinschreibung ist egal. `--rolle` vor dem Befehl wirkt auch. `fertig 374 --rolle Diogenes` setzt die Liste auf „wartet“, das Wort aus der Zeile von Sokrates, und meldet „weiter bei Sokrates“. Erst `fertig 374 --rolle Sokrates` setzt „erledigt“. Nummern mit nur einer Vorratszeile gehen weiter ohne `--rolle` (348.12i).
- **D46.2 behoben.** Ist der Schalter aus, rechnen `startbar.py` und `lauf.stand()` dasselbe: Muss Tom 376.2, Diogenes 275, Sokrates 366, sonst keiner. Die Zeile meldet „11 Leichen, Schalter aus, zählen nicht“. Ist der Schalter an, machen beide Tom und Sokrates startbar. Es gibt nur noch einen Schalter; `lauf.py` liest `startbar.LEICHEN_START`, sonst nichts.
- **D46.4 behoben.** 347 und 72u.1 sind keine Leichen mehr. Es bleiben 11 Leichen: Tom 348.6, 267, 302.3, 302.2, 302.1, 292.2, 292.4, 357 sowie Sokrates 26, 142, 45.
- `regelcheck.py` (voller Lauf) endet vor und nach dem Commit mit Exit 1, wegen der Wortliste 4a. Das kommt nicht von dieser Änderung.
- **D47.1 (mittel) Die Liste führt ein Wort für mehrere Besitzer.** `stand` des einen überschreibt das Wort, das für alle gilt. An der Kopie setzte Diogenes für 348.9 „wartet“, obwohl die Zeile von Perikles eine laufende Dauerzeile ist. `fertig` übernimmt das Wort der ersten Zeile, die übrig bleibt. Das ergibt keine falsche Leiche, weil nur „erledigt“ oder „fertig“ als Leiche zählt. Die Liste zeigt aber den Stand dessen, der zuletzt geschrieben hat. Vorschlag für Stufe 2: Bei mehreren Besitzern gilt das „offenste“ Wort (in Arbeit vor wartet vor ruht).
- **D47.2 (gering) Ist der Schalter an, zeigen die Werkzeuge Leichen verschieden.** `startbar.py` zeigt eine Leiche in ihrer eigenen Klasse (Tom: Kür 302.2 neben Muss 348.6). `lauf.py` fasst alle Leichen zu einer Muss-Zeile „Leichen“ zusammen. Welche Rolle startbar ist, ist bei beiden gleich; nur Ford liest zwei Darstellungen.

## Lauf 46 · Auftrag 275 (Stufe 1 vor dem Einsatz; `main` `4fec9890`, an einer Kopie; 27.10., 15:4x)

**Ergebnis:** `LEICHEN_START` erst nach D46.1 und D46.2 einschalten. D46.1 trifft `vorgang.py`, das schon jetzt die einzige Schreibweise ist: vor dem nächsten Gebrauch beheben. Regelcheck 4a, „Zu tun“ und die Fehlerprüfungen von `vorgang.py` arbeiten richtig.

**Leichen (`startbar.py --leichen`, 19, je gegen die Quelle):** 14 echt, 2 halb, 3 falsch.
- echt, „Urteil 348“ gefallen (Archiv 348 Umstieg 25.10., 00:30; „altes Spiel ruht ganz“ 01:04), Grund im Stand veraltet, Zeile ruht weiter: Tom 302.3, 302.2, 302.1, 292.2, 292.4, 357; Jerry 296.3, 19.
- echt, „wartet auf Chef“ ohne Datei: Tom 267 (Gefühl am Tablet, altes Spiel ruht); Jerry 348.3 (Tabelle der geschlossenen Chefsache 348, durch den Umstieg überholt); Sokrates 142 (12 Bekannte) und 45 (Gewerbeschein) sind Chef-Aufgaben → Datei in `tun/`.
- echt, nur der Nebensatz „beim Chef“ ohne Datei, die Zeile selbst läuft: Tom 348.6 (Dorf r13b), Jerry 348.7 (Fledermaus r4d, Wildschwein r3).
- halb: Jerry 217 (zweite Bedingung „Bildschirmfoto des Chefs“ offen), Jerry 211.14 (nur der Kür-Teil hängt an 348, der Muss-Teil wartet auf 249).
- falsch: Sokrates 347 (Liste „entschieden“, die Auswertung frühestens 31.10. ist offen), Jerry 72u.1 (Liste „freigegeben“ = Bau nach dem Meilenstein erlaubt, Archiv 72u.1 19.10.), Sokrates 26 (Archivzeile 26 „Durchspielen“, Perikles, erledigt; die Vorratszeile 26 ist die neue Auswertung nach 348.7: Nummer doppelt belegt, Streichen wäre falsch).

**Befunde (Verdacht, bis Perikles bestätigt):**
- **D46.1 (hoch) `vorgang.py stand|fertig` trifft bei Nummern in mehreren Vorräten den ersten Vorrat in `ROLLEN`, nicht den des Aufrufers.** An der Kopie schrieb `stand 348.9 "wartet …"` von Diogenes in die Zeile von Perikles. `fertig 374` strich die Zeile von Diogenes und setzte die Liste auf „erledigt“, obwohl Sokrates 374 weiter führt. Heute stehen 7 Nummern doppelt: 133, 275, 348.12, 348.12c, 348.3, 348.9, 374. Vorschlag: bei mehreren Treffern die Rolle als Angabe verlangen; `fertig` setzt die Liste nur dann auf „erledigt“, wenn keine andere Vorratszeile bleibt.
- **D46.2 (hoch) Der Schalter `LEICHEN_START` wirkt nur in `lauf.py`.** `startbar.py` zählt Leichen schon jetzt als startbar (`sperr[nr] = None`). Heute zeigt es „Sokrates: Muss 26 Stand berichtigen“ (26 ist eine falsche Leiche, siehe oben) sowie Kür 302.2 bei Tom und 296.3 bei Jerry. Wer `startbar.py` liest (Ford stündlich), sieht also vor der Freigabe eine andere Startbarkeit als `lauf.py`.
- **D46.3 (mittel) `entschieden()` ist zu weit gefasst.** Jeder Archiveintrag `**X` zählt als Urteil, auch die Einträge von Unternummern (`**X.1`, weil `.` in `[ ,.*:]` steht) und Baufreigaben. Dazu zählt „gebaut“ in der Liste (`FERTIG`). Gegenprobe: 348.13 (Liste „startbar“, im Bau) gilt als entschieden; 296 gilt als entschieden, obwohl nur Einträge zu 296.x im Archiv stehen; 340.2 und 347.2 („gebaut“, warten auf den Test des Chefs) gelten ebenfalls als entschieden. Eine Zeile „wartet auf Urteil 348.13“ würde also zur Leiche. Heute gibt es noch keinen Fehlalarm, weil alle 12 Fälle 348 betreffen und 348 tatsächlich entschieden ist.
- **D46.4 (mittel) `LISTE_FERTIG` zählt „entschieden“ und „freigegeben“ als fertig.** Daraus entstehen die zwei falschen Leichen 347 und 72u.1. Beide Wörter stehen nicht in der Wortliste von 4a; nach der Bereinigung von 4a verschwindet der Fehlalarm, bis dahin bleibt er.
- **D46.5 (gering) Wortliste nicht gleich:** `vorgang.py` lehnt „offen“, „aufgeteilt“ und „Idee“ ab, `regelcheck.py` 4a erlaubt sie. In `ARBEIT-PROJEKT.md` sind 12 Zeilen länger als 400 Zeichen; für sie verweigert `vorgang.py stand` jeden Stand, bis die Zeile gekürzt ist. Das ist richtig, aber vorher zu wissen.

**Geprüft und in Ordnung:** 4a meldet 17 Zeilen außerhalb der Wortliste; die Gegenzählung über alle Listenzeilen findet dieselben 17. Für „Zu tun“ erschien die Probedatei `tun/45-…` in der Übersicht (Spalte „Seit“ nur mit Datum, Uhrzeit fehlt laut Chef 15:21 noch), die Leiche 45 verschwand und das Dashboard zeigt den Abschnitt. In `vorgang.py` greifen die Prüfungen auf ein Wort außerhalb der Liste, auf über 400 Zeichen (539) und auf eine unbekannte Nummer; `stand` und `fertig` arbeiten bei einfach belegter Nummer richtig (302.2, 357).

**Nicht geprüft:** Frist-Leichen (heute keine), die Startnachricht von `lauf.py` mit Leichen (nur den Code gelesen), Token je Start, „Ford sichert bei Sitzungsende“ (noch nicht gebaut).

## Lauf 45 · Auftrag 149/156 (Probewoche Ford; Tom gegen Jerry; Woche 18.–24.10., gezählt 26.10., 01:0x, fremder Helfer, nur Zahlen)

**Ford (149):**
- **Unterbliebene Starts nach 149.1 (ab 20.10., 10:04):** 0 bei 31 geprüften Zeilen „nichts zu starten“.
  - 5 Abweichungen mit Grund: 3 wegen Sparbetrieb, 1 wegen Logo-Wahl Homer über 25 Läufe.
  - 2 davon unsicher: 23.10., 18:06 Tom 345, ein Rückläufer, obwohl der Sparbetrieb Rückläufer erlaubt; 21.10., 00:03 Perikles 165.
  - Vorher (Lauf 37/38) 1 unterbliebener Start (D37.1, 17.10.).
  - Von Ford selbst gemeldet: 18.10., 08:24 Homer 72.10a.T übersehen; 19.10., 08:16 Diogenes nicht gestartet.
- **Doppelte Sitzungen einer Rolle, Überschneidung über 15 Minuten:** 19 Paare.
  - Nicht erlaubt: 3, Homer 22.10., 17:05; 23.10., 04:04 und 09:07. Grund: der Titel „Homer, 279“ wurde als „ohne Rolle“ gelesen (Mechanik, behoben 360).
  - Unsicher: 4 Jerry-Starts am 19.10.
  - Die übrigen sind Ablösungen nach der 60-Minuten-Regel oder Sitzungen des Chefs.
- **Fehlende Kosten:** 19 Sitzungen ohne `cost_usd`; 8 Protokollzeilen „Kosten fehlen“.
  - 5 Sitzungen mit Kosten nicht gebucht (19,13 $; Ford 2, Perikles 1, Tom 2).
- **Verpasste Meldung:** 1 belegt, Sa 24.10., 9 Uhr.
  - Von 23.10., 19:03 bis 24.10., 16:31 fielen 21 Läufe aus (Wochenlimit, Credits leer); die Wache lief in dieselbe Grenze.
  - Übrige Tage: ohne Telegram-Verlauf nicht belegbar.
- **Abweichungen und nicht ausgeführte Plan-Schritte (276):** 56 Zeilen, etwa 22 Fälle, fast alle in Schritt 4 von `LISTE-BETRIEB.md`.
  - Urteil: 12, darunter Homer 251.1 über 26 Zeilen, Sokrates `01FBJT` nicht archiviert, Jerry „derselbe“ 22.10.
  - Mechanik: 8, darunter Perikles „M?“ ohne Nummer über 13 Zeilen, `startbar.py`-Fehler „gebaut“, gleicher Titel besteht, Archivieren verweigert, Seitenliste abgeschnitten.
  - Dazu 1 Fall regelgerecht und der Ausfall durch Guthaben.

**Tom gegen Jerry (156):**
- **Rückläufer:** Tom 23, Jerry 43, aus 22 und 32 eigenen Builds plus 9 gemeinsamen Builds (79–87).
- **Regelverstöße, soweit belegt:** je 2.
- **Befunde Diogenes:** Tom 2, Jerry 3.
- **Kosten der Woche:** Tom 383 $, Jerry 543 $.
- **Kosten je Rückläufer:** Tom 16,65 $, Jerry 12,62 $.
- **Kosten je Build:** Tom 17,41 $, Jerry 16,96 $.
- **Schwelle Archiv 156:**
  - Rückläufer: **überschritten**, 43 gegen 1,5 × 23 = 34,5.
  - Regelverstöße: nicht überschritten, 2 gegen „mehr als 2“.
- Ursache je Rückläufer (Modell oder Auftrag): fehlt, das CHANGELOG nennt nur den Befund. Auswertung Perikles.

**Nicht geprüft:**
- Morgenmeldungen außer 24.10. (Telegram nicht lesbar).
- Ruhende Sitzungen außerhalb der Besetzung.
- Builds 88/89.
- Sitzungen vor 17.10., 17:05.

Teamzuordnung über PR-Zweig bzw. Besitzer des Vorgangs.

## Lauf 44 · Auftrag 270 (Perikles und Diogenes auf dem großen Modell, Probe 21.10., 06:26 bis 26.10.; gezählt 26.10., 00:3x)

Nur Zahlen, Bewertung Perikles (Archiv 270). Vorher = 18.–20.10. (kleines Modell, laut `configured_model`), nachher = 21.–25.10. (großes Modell; 21.10. vor 06:26 enthalten, wo vermerkt).
- **Kosten** (`kosten.py` über `list_sessions` bis 17.10. zurück; Tag = Starttag der Sitzung): Perikles vorher 14,72 / 7,20 / 7,25 $ (Schnitt 9,7 $/Tag, 32 Sitzungen), nachher 36,37 (darin 261.4/261.5 noch klein) / 14,04 / 22,39 / 16,18 / 13,31 $ (Schnitt 20,5 $/Tag, ohne 21.10. 16,5 $; 27 Sitzungen). Diogenes vorher 5,03 / 2,85 / 3,61 $ (3,8 $/Tag), nachher 7,63 / 0 / 1,74 / 1,77 / 29,57 $; 25.10. ist 348.9 Blätter messen (neuer Auftrag, Chef 12:24), ohne diesen Tag 2,8 $/Tag. Zum Vergleich alle Rollen: vorher 239 $/Tag, nachher 367 $/Tag (25.10.: 737 $).
- **Umbauten am Ablauf je Tag** (Commits an `CLAUDE.md`, `ROLLE-*`, `LISTE-BETRIEB/-RELEASE-NEUSTART/-PRUEFUNG`, `tools/*.py|sh`, `.claude/`, ohne Chefsache-Verzeichnis; Rolle aus der Sitzungskennung im Commit): Perikles 29 / 22 / 8 → 21 (4 vor 06:26) / 8 / 7 / 5 / 5; Sokrates 4 / 7 / 9 → 9 / 5 / 0 / 1 / 4; Diogenes, Ford, Homer zusammen 6 → 0.
- **Nachträglich gefundene Fehler in Regeln und Werkzeugen:** vorher 26 Befunde Diogenes (D27 5, D28 6, D31 5, D33 4, D35 1, D36 5; Läufe 27–36), vom Chef zuerst gefunden nicht gezählt (Z3 erst seit 341, 23.10.). Nachher 10 Befunde Diogenes (D40.1–5 auf 261.5, gebaut 05:5x noch klein; D41.1–5 auf 274) und Lauf 42 A–C (Plan 347, vor dem Bau), dazu **4 vom Chef zuerst gefunden:** Höhle 13e als offen geführt (23.10., 10:14), Kürzel im Stand zum Marktstart (25.10., 00:36), Chefsache 361 trotz 287 (25.10., 07:55), Stempelprüfung ließ Antworten doppelt erscheinen (24.10., 21:16, `zug-haken.py`). Beim Vergleich beachten: seit 167.3 (18.10.) prüft Diogenes Abläufe nur auf Anlass.
- **Nicht gezählt:** vor 18.10. gestartete Sitzungen (Kosten am Starttag); 33 Sitzungen ohne `cost_usd` (meist laufende); Niederlassung nicht lesbar; Regelfehler ohne Spur in Commits oder Befunden.

## Lauf 43 · Auftrag 366 (Prüfbogen für Tester, `tools/pruefbogen/`, gegen `main` `face0b5c` = AAB 142.1; 25.10., 19:01)

**Nutzbar nach vier Änderungen, sonst nicht** (fremder Helfer bestätigt alle Befunde am Code):
- **D43.1 Geräteangaben:** „Menü → System → Test → Gerät zeigen …“ gibt es für Fremde nicht: „Test“ ist ein eigener Reiter, nur im Testmodus (7× aufs Logo im Hauptmenü, `App.kt` 258, `MenuScreen.kt` 117), und ein Schummelmenü (Teleport, Beute). Ersetzen durch „Handymodell und Android-Version (Einstellungen → Über das Telefon)“.
- **D43.2 Schwierigkeit:** „Gewählte Klasse und Schwierigkeit“; eine Schwierigkeitswahl gibt es nicht (nur Klasse, `CreateScreen.kt`). „Schwierigkeit“ streichen.
- **D43.3 Rückweg fehlt:** nirgends, wohin der ausgefüllte Bogen geht (z. B. kontakt@bornwire.de), und dass das PDF am Gerät ausfüllbar ist (106 Felder, geprüft) oder gedruckt werden kann.
- **D43.4 „bisheriger Kampf“** (Teil M, M7): ein Neuling kennt keinen; „der normale Kampf in der Welt“.
- Klein: Spiel sagt „Auftrag“, Bogen „Quest“ (A4, D); Bogen nur Deutsch, Webseite DE/EN.

Stimmt: Version/Build (Menü → System oben), MARS-Weg (System → „MARS“ → Regelseite → Probekampf), Ring, Ansagen, Kampfbericht; PDF entspricht `bogen.md`, 4 Seiten. Für den Godot-Stand gelten alle Menüwege neu. Ändern: Besitzer des Bogens, PDF mit `bogen_pdf.py` neu bauen. Nicht geprüft: Bogen am Handy im PDF-Programm ausgefüllt.

## Lauf 42 · Auftrag 347.1 (Gegenprüfung `tools/regeltreue/PLAN-347.md`, 24.10., 16:4x)

Umsetzbar, aber **vor dem Einschalten ändern:**
- **A Messweg (Punkt 1):** `list_events` liefert Zeit, Text und `usage` (Kontextgröße), ist aber teuer: Probe 15 Ereignisse ≈ 9 Tsd. Token (Signaturen, doppelte Werkzeugeingaben) für 7 Antwortteile. Stündlich alle Sitzungen in Fords Kontext frisst mehr, als das Paket spart. Besser: Zähler-Haken (Paket 3.4) schreibt lokal; vor Übergabe oder Neustart schreibt die Sitzung eine Summenzeile nach `main` (ein Schritt im Neustart-Ablauf, `LISTE-RELEASE-NEUSTART.md`); Kontextgröße zusätzlich aus `list_sessions` (`used_tokens`, hat `lauf.py` schon); `list_events` nur als Stichprobe. Basis (Punkt 7) rückwirkend aus Stichproben 21.–24.10., dann gilt „ab sofort alles“ (Chef 16:30) ohne Wartezeit.
- **B Stempelprüfung (5a) in `zug-haken.py`:** (1) Der Haken hält nur einmal an (`stop_hook_active`): Stempel- und Chefsache-Prüfung in einem Block mit gemeinsamem Grund, sonst hebt eine die andere auf. (2) Bezugszeit: `neustart-haken.py` sagt „so stempeln“ mit der Zeit beim Prompt, der Stop-Haken vergleicht mit Zugende; jeder Zug über 2 Minuten (Builds, Prüfungen) würde fälschlich angehalten. Gelten lassen: Stempel zwischen Prompt-Uhr (im Zustand unter `/tmp` mitschreiben) und Zugende plus 2 Minuten. (3) Geprüft wird nur der letzte Text (`last_assistant_message`); steht der Stempel in einem früheren Zwischentext, fehlt er dort: Fehlen nicht anhalten, nur falsche Zeit. (4) Mitternacht und Datum mitrechnen. (5) `zug-haken.py` läuft aus `bornim-main`, ein Fehler trifft sofort alle Sitzungen: vorher an einem echten Verlauf testen. Beleg, dass die Prüfung nötig ist: Diogenes stempelte heute 16:38 bei Uhr 16:34.
- **C Pause (Punkt 6):** widerspricht `CLAUDE.md` („Pause bis … Ford startet dann nicht“) und `lauf.py` Z. 386 (NICHTS bei Pause vor dem Nachfolger). Alle drei zugleich ändern; Neustart trotz Pause nur als Ablösung einer Sitzung, die ohnehin arbeitet, nie neue Arbeit (Pausen wegen Guthaben).
- **Beim Bau beachten:** (D) `neustart-haken.py`, `notiz.sh` und `settings.json` laufen aus dem Arbeitszweig (`$CLAUDE_PROJECT_DIR`), nicht aus `main`: Punkte 2 und 3 wirken erst in Sitzungen, deren Zweig `main` danach enthält; Messbeginn je Sitzung festhalten. (E) Kernregel-Zeile nur ein Wortlaut an einem Ort (beide Werkzeuge lesen ihn), nicht `hook-prompt.sh` zusätzlich; „kein Zwischenstand“ auf den Chat begrenzen, sonst Widerspruch zu `CLAUDE.md` 9 (Standzeile etwa alle 5 Minuten in Telegram). (F) 5b: Paket sagt „Diogenes trägt montags ein“, Diogenes ändert nichts: Perikles trägt ein, Diogenes schlägt in der Wochenzählung vor. Regelbilanz: 7 neue Zeilen (5 aus 5b, 2 aus dem Paket), gestrichen nur der Zeitstempel-Satz; die Paketzeile „Entschuldigung“ doppelt Haltung 5 und den Antwortstil, streichen. (G) Telegram länger: `CLAUDE.md` 9 „je Thema eine Zeile“ mitändern; über 4096 Zeichen (bei `--bild` 1024) sendet `meldung.sh` nicht, meldet nur Fehler. (H) Punkt 4: Befehle laufen am heutigen Stand (Vorrat Tom 4,1 statt 10,9 KB, Jerry 5,6 statt 11,2; Stil 2,1 KB; Änderungshistorie 1,9 KB; Ford-Zeile da). Risiken: „Zu <Nr>“ ist Platzhalter; drei Einträge der Änderungshistorie decken nur Build 82–84; Abschnittsnamen („## Einzelheiten“, „## Auf einen Blick“, „## Signatur“) werden Anker, Umbenennen lädt still alles oder nichts → `regelcheck.py` prüft die Anker; Stil nur kurz ist wieder eine Textregel: Stil-Rückläufer je Woche mitzählen.
- **Messbarkeit:** „Dauergelaber“ vorab festlegen: Wörter der letzten Antwort je Zug, je Rolle, Sokrates getrennt; Ziel als Zahl (z. B. Median −30 %), sonst Eindruck. „Kennt die Uhr“: Anteil Stempel über 2 Minuten daneben, je Rolle.

## Lauf 40 · Auftrag 261.5 (Archivregel, Prüfung des Ergebnisses; Stand `98ba4b9b`, Chef 21.10., 06:15)

Geprüft: Diff `b9ad0757..98ba4b9b` (`lauf.py`, `kosten.py`, `ROLLE-BETRIEB.md`, `LISTE-BETRIEB.md`, Fords Übergabe) gegen Vorgangsarchiv 261.4, 261.4 Regel, 261.5. **Verfahren:** (a) Wegwerf-Kopie von `tools/` und `docs/` (nichts auf `main` geändert), Kurzzeilen-Szenarien: zwei Homer (alte mit Frage), zwei Sokrates, Sitzung ohne Rolle, zwei Tom, Diogenes mit Muss und 50 / 150 Tsd. Token oder Frage offen; Marken „Archiv“ und „Mehrfach“ von Hand 60 Minuten alt gesetzt; (b) Lauf gegen die **echten** 40 neuesten Sitzungen von 06:25 (`list_sessions`, Kurzzeilen mit created_at und used_tokens).
**Besteht:** ÜBERTRAGE vor ARCHIVIERE bei offener Frage; Frage hält nichts mehr; eine Sitzung je Bereich bleibt stehen; Sitzung ohne Rolle: eine Warnung, Marke nur mit `--sperre`; Mehrfach- und „nicht ausgeführt“-Prüfung schlagen mit 60 Minuten alter Marke an; WEITER unter 100 Tsd. Token und 60 Minuten, sonst START (auch bei Frage); Fords Übergabe und `ROLLE-BETRIEB.md` stimmen mit dem Code überein (`lauf.py` archiviert nie). Echte Liste: 5 offene Jerry-Sitzungen → 4 ARCHIVIERE (2 mit ÜBERTRAGE), dazu Homer 1, Perikles 1, Sokrates 1; Tom (eine Sitzung) bleibt.
**Befunde:**
1. **D40.1 (hoch): Satz 3 greift praktisch nie.** Von 40 echten Sitzungen liegt **eine** unter 100 Tsd. Token (Tom, 92.825); frisch gestartet steht Sokrates nach 6 Minuten bei 100.161, kurze Arbeiten enden bei 102 bis 127 Tsd. WEITER trifft damit fast nie, es wird weiter gestartet und archiviert: die Absicht des Chefs („kann ich in die alte noch was reinarbeiten, weil es günstiger ist“) wird nicht umgesetzt. Schwelle messen und anheben (bei 150 Tsd. wären es 16 von 40, davon 10 noch offen) oder als Zuwachs seit dem Start rechnen; **Kosten gegen kalte Zwischenablage abwägen: Perikles, Zahl in `LISTE-BETRIEB.md`.**
2. **D40.2 (mittel): „nicht ausgeführt“ meldet jeden Lauf laut, ohne Ende.** `alt` nimmt jede Marke ab 30 Minuten Alter, nichts begrenzt die Wiederholung. Real: Sokrates `017M3n…` (Sitzung des Chefs am Rechner) hat Ford am 20.10., 23:10 und 21.10., 06:20 nicht archivieren dürfen (Berechtigungsprüfer verweigert); der Plan von 06:25 setzt sie wieder auf ARCHIVIERE → ab dem nächsten Lauf stündlich WARNUNG-LAUT, unlösbar. Vorschlag: einmal je Sitzung warnen (eigene Marke „Archiv-Warnung <id>“); Sitzungen, die Ford nicht archivieren darf, als allgemeine Ausnahme benennen (Chef entscheidet: Archivieren am Rechner selbst oder Berechtigung).
3. **D40.3 (gering):** Sokrates ohne „Kosten auf:“ in der Übergabe wird jetzt stumm als „Betrieb“ gebucht und archiviert; vorher WARNUNG und kein Archivieren (197). Satz 4 sagt „bleibt eigene Regel“: Warnung wieder einbauen.
4. **D40.4 (gering): PR-Abo nur in Prosa.** `lauf.py` kennt keine Abos, Ford hat keine Datenquelle; Titel wie „Jerry – PR #137 …“, „259 … PR #140 abonniert“ zeigen, dass es vorkommt. Billig: steht „PR #“ im Titel, vor ARCHIVIERE eine Zeile „PR-Abo prüfen, an die neuere Sitzung übergeben“.
5. **D40.5 (gering): Alt-Reste.** `ARBEIT-PROJEKT.md` Zeile 261.3 samt „Zu 261.3“ („eine ruhende Sitzung bleibt offen, Probe bis 27.10.“) widerspricht 261.5 und fällt; `docs/chefsache/README.md` führt 261.3 noch so; in Fords Übergabe steht „Tom ‚Build 48 Rückmeldung‘ hält PR #136“, die Sitzung ist archiviert.
**Nicht geprüft:** ob Ford `WEITER` per `send_message` in der Praxis zugestellt bekommt (die Plattform lehnte Aufgaben an gestartete Sitzungen früher ab; Rückfall START ist eingebaut); Fords Ausführung der Zeilen (das ist die Beobachtung nach der Umsetzung).
**Vermerk Perikles (21.10.):** D40.1–D40.5 umgesetzt (Übergabe 261.5 in `ARBEIT-PROJEKT.md`); offen bleibt die Beobachtung, ob Ford ARCHIVIERE ausführt (261.5 bis 24.10.).

## Kosten

Je Lauf eine Zeile, neueste oben; ältere im Archiv.
