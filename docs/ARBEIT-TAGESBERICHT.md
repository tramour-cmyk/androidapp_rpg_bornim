# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 13.11., 08:15** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 2 von 4 abgenommen, 2 gebaut, 0 in Arbeit | 41 Punkte in 6 Stufen: 2 abgenommen, 2 gebaut, 7 in Arbeit, 30 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 101 / 575, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 83 / 347; neu 89 / 642 |
| 3 | Rest geschätzt | Wochenziel 09.–15.11. „Der Kampf funktioniert“, Stand Freitag: Schritt 1 ist erledigt (Build 280 seit 12.11., 20:48 auf `main`); Schritt 2, Build 281 mit dem Kampf, testest du seit 07:23 (Funde 1093, 1094; entschieden 1095, 1096). (ganz unter „Eingaben“) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **8 billigen**, **2 Build** | ältestes: 1085 seit 12.11., 22:33; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **68** (Tom 24, Jerry 44); rote Läufe 24 h **24 von 40** (Tom 13, Jerry 6, Build 5), 7 Tage 77 von 159 | bei dir zum Testen: Build 281, Build 282; ein Build nimmt alle fertigen Zweige (317) |
| 6 | Fehler | **23** offen, davon 8 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche **48 %** (dein Bild 12.11., 16:42); gestern 860 $ Rechenwert, Spiel 80 %; **Bitte Bild der Nutzung** (Woche %; ruht die Niederlassung: nur Max; 783 W7) | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | seit dem letzten Bericht (12.11., 08:16) in Build 278 1023 Hühner (zurückgestellt), 1024 Ansage verdeckt die Bildrate, 1025 zwei Kämpfe zugleich; in Build 279 1027 Reiter „Test“ passt nicht auf den Schirm; in Build 280 1030 Reiter „Test“ springt, 1031 Bericht ohne Farben, 1032 Angriff ohne Bewegung, 1035 … (ganz unter „Eingaben“) | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | Build 281 und Build 282 liegen gleichzeitig bei dir (68 Änderungen), beide Teams sind gesperrt (620.1 B: Jerry 34, Tom 23 ungetestete Muss), und Jerry bleibt es auch nach beiden Tests (17 Muss ohne Build-Nummer). Wolfsbiss (709.1), Ausweichen (1043) und Platztausch (1072) liegen so lange; „Kampf passt“ bis Sonntag ist damit unwahrscheinlich |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 117 | 92 | 7 | 29 | 145 |
| Jerry | 136 | 122 | 1 | 32 | 118 |
| Homer | 2 | 0 | 0 | 10 | 57 |
| Sokrates | 50 | 36 | 27 | 21 | 73 |
| Perikles | 16 | 15 | 1 | 7 | 170 |
| Diogenes | 8 | 7 | 1 | 1 | 13 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 13.11., 08:10)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | 1.1 und 1.4 abgenommen (720, 09.11., 14:49); 1.2 Fertigkeiten gebaut (471 in t274 bestanden); 1.3 gebaut |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 17 | in Arbeit; Build 280 seit 12.11. auf `main` (Laden nach BRS, Godot ohne Kotlin); Build 281 (Kampf) und Build 282 (Dorf, Blutzahnhöhle, Hauptmenü) bei dir |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog angelegt (458); entschieden: 807 A, 976a, 975a, 1051 A, 1038 A (unten); Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | in Arbeit (unten); 4.8 keine SRD-Namen in Arbeit (870) |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | Vorlauf: D-U-N-S beantragt, wartet auf die Bearbeitung bis etwa 08.12. (142.4); AAB des Godot-Builds ruht bis „Kampf passt“ (622) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

- **Stufe 1:** 1.2 und 1.3 sind gebaut; der Held nach dem BRS (870.4) ist seit Build 277 auf `main`; abhaken, wenn du beide im Spiel mit diesem Helden gesehen hast.
- **Stufe 2:** Build 280 hast du freigegeben (12.11., 15:55); seit 20:48 ist er auf `main`, mit Laden nach BRS (870.7) und Godot ganz ohne Kotlin (870.9). Build 281 (Kampf: Zielring, ein Probekampf für alles, fünf Zustände aus dem Paket, Grimmzahn tritt beim Wenden) testest du seit 07:23. Build 282 bringt die Blutzahnhöhle in Fassung B mit Nebel (492, 505; Vorentscheid 13.11., 03:33); hast du sie begangen, ist die Höhle in 2.14 abhakbar. Durchspiel-Build (496) und Kampforte Höhle (507) ruhen bis „Kampf passt“.
- **Stufe 3:** entschieden sind Fertigkeiten ohne Kampf (807 A), Güte in vier Stufen und Schneidern statt Lederarbeit (976a, 975a, 11.11.), Proben mit Fertigkeit ohne Grundwert (1051 A) und Verband stillt Blutung (1038 A, 12.11.).
- **Stufe 4:** der Umhang ruht nach deinem Stopp (12.11., 07:10, 862). In Build 282: Kartenrand weich ins Dunkel (1022), vier Helden im Hauptmenü (867), Frauen außer Rowena in ruhiger Standpose (1044), jeder Schenkentisch mit eigenem Gedeck (757), Startbildschirm mit eigenem Zeichen (1035).

## Wer hinkt (13.11., 08:10)

- **Rote Läufe:** 24 von 40 in 24 Stunden (Tom 13, Jerry 6, Build 5), gestern 18 von 27. Die Sammelbuilds waren fünfmal rot (279 einmal, 280 dreimal, 282 einmal); 280 und 282 liefen danach grün, 281 mit zwei bekannten roten Tests (tausch_1041, schirm_833). Die übrigen 19 sind Läufe einzelner Zweige, vor allem Bild- und Filmläufe für Vorlagen (867, 1044, 1022, 1090), deren Bilder teils trotz roter Tests verwendbar waren. Die Zählung trennt das noch nicht; das nehme ich in 464 auf (Termin 16.11.).
- **Beide Teams gesperrt:** Jerry 34, Tom 23 ungetestete Muss (620.1 B, Sperre ab 6); Jerry hat 2 startbare Zeilen bei 137 offenen. Nach deinem Test von 281 bleiben Jerry 20 und Tom 20, nach 281 und 282 Jerry 17 und Tom 6. Jerrys übrige 17 sind Vorgänge ohne Build-Nummer (darunter 1018, 993, 709), die keiner der beiden Tests löst. Wolfsbiss (709.1), Ausweichen (1043, wartet auf den Sprung 760) und Platztausch (1072) bleiben bis dahin liegen.
- **Festgefahren** (über 30 $ oder zwei Rückläufer, 827 A): 494 (135 $), 492 (104 $), 505 (69 $), 709 (60 $), 431 (50 $), 882.1 (50 $), 415 (49 $), 806 (47 $), 1022 (46 $), 814 (39 $), 757 (31 $), 1055 (30 $); ab 14.11., 20:00 nimmt die nächste Sitzung dafür das stärkste Modell. 492, 1022 und 757 passen inzwischen (Vorentscheide und dein Wort 12.11., 17:33).
- **Nacht 12./13.11.:** Sokrates hat mit deiner Vollmacht (1077, 22:30) 12 Vorentscheide und etwa 17 weitere Entscheide (Läufe frei, noch nicht) getroffen; acht Vorentscheide liegen zum Billigen bei dir (492, 867, 1044, 842, 1022, 1084, 1090, 1085) und halten keine Arbeit an.
- **Schätzungen in Sitzungen** für den Rest des Wochenziels fehlen weiter.

## Wo du Prioritäten setzen kannst (13.11., 08:10)

1. Build 281: getestet und freigegeben (09:09, 09:12; Archiv t281).
2. **Build 282 testen** ([t282](chefsache/ansehen/t282-dorf.md), 22 Zeilen, Testbitte seit 08:04): er bringt zum ersten Mal die Blutzahnhöhle (2.14), dazu Hauptmenü, Kartenrand und Frauen; danach ist Tom mit 6 ungetesteten Muss fast frei.
3. **Bild der Nutzung schicken** (Woche in Prozent; zuletzt 48 % am 12.11., 16:42; Zurücksetzung Sa 14.11., 19:59): gestern 861 $ Rechenwert, davon 80 % fürs Spiel; ohne Bild sehe ich nicht, ob die Woche bis Samstag reicht.

*Stärkstes Gegenargument zu 1:* Build 282 ist schneller durchgetestet, bringt die Höhle und löst Toms Sperre fast ganz. *Wie es zu entkräften ist:* 281 trägt das Wochenziel; außerdem muss 281 vor 282 installiert werden, weil Android nur höhere Versionen über niedrigere installiert.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-BRS.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: Wochenziel 09.–15.11. „Der Kampf funktioniert“, Stand Freitag: Schritt 1 ist erledigt (Build 280 seit 12.11., 20:48 auf `main`); Schritt 2, Build 281 mit dem Kampf, testest du seit 07:23 (Funde 1093, 1094; entschieden 1095, 1096). Aus Schritt 3 sind Ring (1039), Bericht in Farbe (1031) und fünf Zustände (1036) in 281, aus Schritt 5 der Probekampf für alles (1034); Ausweichen (1043) fehlt, weil der Wolf nicht sichtbar springt (760), Angriff mit Bewegung (1025, 1032) wartet auf die Sperre. Schritt 4 (Grimmzahn 1040, Lyra 1040.1) ist in 281; aus Schritt 6 von Tom ist 984.1 in 281, Kartenrand 1022 und Frauen 1044 sind mit Höhle 492 und Hauptmenü 867 in Build 282. Umzug: 882.1 bei Tom, danach Kotlin-Bau aus (882.2, 870.10). „Kampf passt“ bis Sonntag hängt an Wolfsbiss, Ausweichen und Platztausch; Jerry bleibt nach deinen Tests von 281 und 282 mit 17 ungetesteten Muss gesperrt. Schätzungen in Sitzungen fehlen weiter.
- Von dir zuerst gefunden: seit dem letzten Bericht (12.11., 08:16) in Build 278 1023 Hühner (zurückgestellt), 1024 Ansage verdeckt die Bildrate, 1025 zwei Kämpfe zugleich; in Build 279 1027 Reiter „Test“ passt nicht auf den Schirm; in Build 280 1030 Reiter „Test“ springt, 1031 Bericht ohne Farben, 1032 Angriff ohne Bewegung, 1035 Godot-Zeichen beim Start, 1036 Zustände unsichtbar, 1039 Ring kaum zu sehen, 1041 Platztausch ungleich; an Vorlagen 842 nur ein Knopf, 867 Helden wie Brüder und Zauberlehrling blond, 1036 Zustände zu klein, 1081 Zoom kostet Bildrate; im Betrieb 1076 Film fast eine Minute für sechs Sekunden Ring, 1070 getestete Prüfliste blieb stehen; heute in Build 281 1093 Siegschirm rechts abgeschnitten, 1094 Ring läuft beim Tippen durch, dazu deine Änderungen 1095 und 1096. Wiederholt statt neu: 990 Staub in Innenräumen (zweiter Fund), 1022 Kartenrand (wie t268), 1040 und 1040.1 Grimmzahn und Lyra drehen auf der Stelle (wie t268), 1043 kein Ausweichen zu sehen (wie 988), 1072 hinterer Wolf läuft außen herum (dritter Fund), 589 Marktstände
- Größtes Risiko: Build 281 und Build 282 liegen gleichzeitig bei dir (68 Änderungen), beide Teams sind gesperrt (620.1 B: Jerry 34, Tom 23 ungetestete Muss), und Jerry bleibt es auch nach beiden Tests (17 Muss ohne Build-Nummer). Wolfsbiss (709.1), Ausweichen (1043) und Platztausch (1072) liegen so lange; „Kampf passt“ bis Sonntag ist damit unwahrscheinlich
