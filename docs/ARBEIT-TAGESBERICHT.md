# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 12.11., 08:16** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 2 von 4 abgenommen, 2 gebaut, 0 in Arbeit | 41 Punkte in 6 Stufen: 2 abgenommen, 2 gebaut, 7 in Arbeit, 30 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 108 / 493, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 59 / 281; neu 175 / 577 |
| 3 | Rest geschätzt | Wochenziel 09.–15.11. „Der Kampf funktioniert“; der Umzug aufs Bornimer Rollenspielsystem (870) ist zum großen Teil auf `main`: Build 277 hast du freigegeben (11.11., 20:54), seit 12.11., 05:30 mit Held (870.4), Kampf (870.5) und Beute (870.6) auf `main`. Build 278 (Sammelbuild mit 47 … (ganz unter „Eingaben“) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **2 entscheiden**, **1 Build** | ältestes: 644a seit 11.11., 22:02; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **66** (Tom 25, Jerry 41); rote Läufe 24 h **18 von 27** (Tom 7, Jerry 7, Build 4), 7 Tage 54 von 122 | bei dir zum Testen: Build 278; ein Build nimmt alle fertigen Zweige (317) |
| 6 | Fehler | **11** offen, davon 8 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche **0 %** (dein Bild 11.11., 07:11); gestern 1090 $ Rechenwert, Spiel 82 %; **Bitte Bild der Nutzung** (Woche %; ruht die Niederlassung: nur Max; 783 W7) | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | seit dem letzten Bericht (11.11., 07:43) neu in t276 944 Würfeltexte, 946 Ansage unter der Zugleiste, 947 Söldner im Probekampf, 948 Herumtreiber ohne Dolch; in t277 990 Staub im Laden, 991 Testmenü ohne Zustand, 993 Arkanpfeil, 994 Klangzeile „hand scratch“, dazu 277.5 Fußstaub, 277.7 Bildrate mit Nebel, … (ganz unter „Eingaben“) | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | Build 278 bringt 47 neue Vorgänge auf einmal, sechs rote Tests sind als bekannt markiert; seine Funde und die aus Build 277 stauen sich vor Build 279, während Jerry mit 36 ungetesteten Muss gesperrt ist (620.1 B). Der Wolfsbiss (709.1, 1018), Herzstück von „Kampf passt“, hängt an dieser Sperre; „Kampf passt“ bis Sonntag ist ohne Umhang und Wolfsbiss unwahrscheinlich |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 127 | 108 | 3 | 11 | 123 |
| Jerry | 134 | 121 | 4 | 22 | 97 |
| Homer | 3 | 1 | 0 | 20 | 47 |
| Sokrates | 53 | 39 | 26 | 9 | 53 |
| Perikles | 13 | 12 | 0 | 46 | 163 |
| Diogenes | 9 | 8 | 1 | 0 | 12 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 12.11., 08:16)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | 1.1 und 1.4 abgenommen (720, 09.11., 14:49); 1.2 Fertigkeiten gebaut (471 in t274 bestanden); 1.3 gebaut |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 17 | in Arbeit; erst der Umzug aufs BRS (870), dann der Kampf (Wochenziel 09.11.); Builds 276 und 277 getestet, 277 freigegeben und auf `main`, 278 bei dir |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog angelegt (458); Fertigkeiten ohne Kampf entschieden (807 A); Güte in vier Stufen und Schneidern statt Lederarbeit entschieden (976a, 975a, 11.11.); Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | in Arbeit (unten); 4.8 keine SRD-Namen neu in Arbeit (870) |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | Vorlauf: D-U-N-S beantragt, wartet auf die Bearbeitung bis etwa 08.12. (142.4); AAB des Godot-Builds ruht bis „Kampf passt“ (622) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

- **Stufe 1:** 1.2 und 1.3 sind gebaut; der Held nach dem BRS (870.4) ist seit Build 277 auf `main`; abhaken, wenn du beide im Spiel mit diesem Helden gesehen hast.
- **Stufe 2:** Build 277 hast du freigegeben (11.11., 20:54, nach 277.18), seit 12.11., 05:30 auf `main`; darin der Umzug aufs BRS mit Held (870.4), Kampf (870.5), Beute (870.6). Build 278 (seit 07:52 bei dir) bringt Laden nach BRS (870.7, Bild passte 11.11., 19:57) und Godot ganz ohne Kotlin (870.9). Höhle (492) nur bis zum Lager, Nebel (505) wartet auf die Höhle; Durchspiel-Build (496) und Kampforte Höhle (507) ruhen bis „Kampf passt“.
- **Stufe 4:** der Umhang ruht nach deinem Stopp (12.11., 07:10, 862); Kampfort mit Ruhebewegungen passte (744, 11.11., 20:58), neue Bäume im Wald passten (831, 12.11., 08:07); die Wurfflasche fliegt im richtigen Bogen, ist aber zu groß, Jerry bessert nach (935, 08:07).

## Wer hinkt (12.11., 08:16)

- **Rote Läufe:** 18 von 27 in 24 Stunden (Tom 7, Jerry 7, Build 4), gestern 13 von 22; vor allem das Mischen der Sammelbuilds 277 und 278 (Läufe 365, 373; rote Tests an Jerry, 1018).
- **Jerry gesperrt:** 36 ungetestete Muss (620.1 B), startbar nur 2; der Wolfsbiss (709.1) und 1018 warten auf deinen Test von Build 278.
- **Umhang:** 58, 463, 656, 861 kosteten zusammen 130,84 $; 656 passte (09.11.), der Buckel aus 861 blieb; gestoppt (12.11., 07:10), Vorlage „irgendwann“ bei Sokrates.
- **Festgefahren** (über 30 $ oder zwei Rückläufer, 827 A): 494 (135 $), 492 (83 $), 505 (69 $), 709 (60 $), 415 (49 $), 806 (47 $), 814 (39 $), 595 (38 $), 635 (zwei Rückläufer); ab 14.11., 20:00 nimmt die nächste Sitzung dafür das stärkste Modell.
- **Ford:** heute früh von Hand gestartet (1016), weil er sich am Neustart-Haken alle drei Stunden neu startete und dabei tiefer wurde; seit 08:11 erinnert ihn der Haken erst bei 400 Tsd. (1019, Prüfung bei Diogenes).
- **Schätzungen in Sitzungen** für den Rest des Wochenziels fehlen weiter.

## Wo du Prioritäten setzen kannst (12.11., 08:16)

1. **Build 278 testen** ([t278](chefsache/ansehen/t278-sammelbuild.md), seit 07:52): löst die Sperre 620.1 B (Jerry 36, Tom 24 ungetestete Muss) und gibt den Wolfsbiss frei, das Herzstück von „Kampf passt“.
2. **644a entscheiden** (Mindeststufe zum Tragen, Votum A, D, F, seit 11.11., 22:02): ohne Antwort baut keiner Tragestufe und Zusatzeigenschaften der Beute nach BRS.
3. **264 entscheiden** (eigener Bauserver, seit 12.11., 01:12): Votum abschalten und bei GitHub abmelden, der Bauplan bleibt im Repo; wieder einschalten, wenn das Repo privat wird oder GitHub einen ganzen Arbeitstag nicht baut.

*Stärkstes Gegenargument zu 1:* Build 278 hat sechs rote Tests; Build 279 mit allen Behebungen wäre sauberer. *Wie es zu entkräften ist:* alle sechs stehen oben in der Prüfliste als „bekannt, nicht melden“ (Testbitte auch bei rot, 919, Chef 11.11., 09:53); vier davon sind Messfehler der Tests, der Wolfsbiss (1018) und die Fehlermeldung im Wald sind echt, aber bekannt; ohne deinen Test bleibt Jerry gesperrt.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-BRS.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: Wochenziel 09.–15.11. „Der Kampf funktioniert“; der Umzug aufs Bornimer Rollenspielsystem (870) ist zum großen Teil auf `main`: Build 277 hast du freigegeben (11.11., 20:54), seit 12.11., 05:30 mit Held (870.4), Kampf (870.5) und Beute (870.6) auf `main`. Build 278 (Sammelbuild mit 47 neuen Vorgängen, darin Laden 870.7 und Kotlin-Ausstieg 870.9) liegt seit 07:52 bei dir; danach Kotlin-Bau aus (870.10) und Aufräumen (870.13). Der Umhang ruht seit deinem Stopp (12.11., 07:10); „der Umhang sitzt“ aus dem Wochenziel ist damit diese Woche nicht erreichbar. Dein Testmenü (1020, „jetzt“ 08:09) bauen Tom und Jerry zuerst. Kampf offen: Wolfsbiss 709.1 und rote Tests 1018 (Jerry, gesperrt), Bildschirm springt 992 und Arkanpfeil 993 (in Build 278). Schätzungen in Sitzungen fehlen weiter.
- Von dir zuerst gefunden: seit dem letzten Bericht (11.11., 07:43) neu in t276 944 Würfeltexte, 946 Ansage unter der Zugleiste, 947 Söldner im Probekampf, 948 Herumtreiber ohne Dolch; in t277 990 Staub im Laden, 991 Testmenü ohne Zustand, 993 Arkanpfeil, 994 Klangzeile „hand scratch“, dazu 277.5 Fußstaub, 277.7 Bildrate mit Nebel, 277.10 Wurf ohne Bogen, 277.12 Fußstaub nachts und Fackel; Filme: 995 Grabhund, 935 Flasche zu groß; 1021 Neustart beim App-Wechsel; im Betrieb 981 Aufwand Hoch griff nie, Vorlage 644a fünfmal zurückgezogen. Wiederholt statt neu: 945 Knöpfe weg bei Auto (vierter Fund), 949 Text und Bild gegen Grak, 950 und 277.14 Platztausch gleitet, 951 Blende ohne Satz, 992 Bildschirm springt (709), 277.16 Lyra (635)
- Größtes Risiko: Build 278 bringt 47 neue Vorgänge auf einmal, sechs rote Tests sind als bekannt markiert; seine Funde und die aus Build 277 stauen sich vor Build 279, während Jerry mit 36 ungetesteten Muss gesperrt ist (620.1 B). Der Wolfsbiss (709.1, 1018), Herzstück von „Kampf passt“, hängt an dieser Sperre; „Kampf passt“ bis Sonntag ist ohne Umhang und Wolfsbiss unwahrscheinlich
