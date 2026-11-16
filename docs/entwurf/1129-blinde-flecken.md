# 1129 · Entwurf: Systemprüfung blinde Flecken (Sokrates und Perikles)

Entwurf für die Vorlage `chefsache/entscheiden/1129-…`. Sokrates, 13.11., 13:05. Messung am 13.11., 12:56–13:02 über die letzten 7 Tage (Git `main`, `VORGANGSARCHIV.md`, `startbar.py --stand`, Quelltext der Werkzeuge). Perikles ergänzt seinen Teil (1129.1, Abläufe) unten; danach schreibt Sokrates die Vorlage.

Auftrag (Chef 13.11., 12:53): „Prüft nochmal unseren ganzen Shit durch, wo wir auch blinde Flecken … haben und Dinge tun, die anders, einfacher, schneller, effizienter … zu lösen sind, dass wir ohne Qualitätsverlust schneller entwickeln können.“

## Messzahlen (7 Tage)

- **Beim Chef:** 112 Vorlagen in `entscheiden/` (ohne Neufassungen; mit Neufassungen 126, dazu 810 Commits an Chefsache-Dateien; 867 hatte 17 Fassungen, 644a und 783 je 13), etwa 70 in `ansehen/`, 14 Testbitten (t269–t282). Rund 350 Archivzeilen, also etwa 50 Entscheidungen am Tag. Davon waren 27 Vorentscheide (8 %).
- **Absender der Vorlagen:** Sokrates 31, Jerry 13, Tom 11, Homer 7, Tuffy 7, Perikles 4, Ford 2, Diogenes 2, Rest ohne Absenderzeile.
- **Teams:** Tom 112 offene Zeilen, 4 startbar; Jerry 132, 2 startbar. Alle Rollen: 327 offen, 266 davon Muss, 41 startbar. Von den 30 startbaren Muss gehören 23 Sokrates. Für die Rollen, die `lauf.py` startet, bleiben 6.
- **Worauf die Zeilen warten:** „ruht“ 112 (78 Muss; 39 „Kampf zuerst (338.1)“, 51 ohne Zusatz, kein Werkzeug löst sie), anderer Vorgang 69, Test oder Build 65, Sperre 620.1 B 19 direkt und 9 über Ketten, Termin 12, Chefsache-Datei 1.
- **Fertig ohne Build:** 45 von 70 Zeilen mit „gebaut“ oder „zu testen“ stecken in keinem Build (Jerry 31). Der Chef hat 280, 281 und 282 innerhalb von 24 Stunden getestet.
- **Arbeit an Abläufen:** 8.823 Commits auf `main`, davon 1.895 Merges, 1.887 „Chefsache: Übersicht“ (Werkzeug), 315 Startsperren. Spielcode in etwa 8 % der Commits ohne Merges. Kosten nach Hauptthema seit Beginn: B (Abläufe) 3.463 $ von 12.575 $ (28 %).

## Befunde Sokrates

**S1 · Fragen landen beim Chef, die ein anderer entscheiden darf.** Nach Titel eingeordnet waren von den 112 Vorlagen etwa 15 Fragen zur eigenen Arbeitsweise („zweiter Probefilm?“, „Film zeigen, obwohl die Probe gezählt ist?“, „darf ich die Kaufmodelle in die Sitzung holen?“, „Streifen als Fehler beheben oder erst ein Bild?“; 595, 506a, 863a, 1092, 1043a, 814, 645, 646, 613, 264.1). Etwa 12 betrafen den Sitzungsbetrieb (Ford neu starten, Aufwand, Modell, Sitzungslänge; 1016, 110, 1098, 1100, 365a, 365.1, 821, 826, 827, 383, 750, 264), etwa 21 Abläufe und das Regelwerk (275.2, 620.1, 626, 650, 650.1, 650.2, 654, 657, 718–721, 724, 743, 745, 779, 783, 903, 1109, 1128, 1020) und etwa 5 den Vorrang (922, 471, 870b, 688, 756). Zusammen sind das etwa 50 (45 %). CLAUDE.md „Wer entscheidet“ gibt die Arbeitsweise dem Ausführenden, Abläufe jeder Größe Sokrates als Vorentscheid (`ROLLE-BERATUNG.md` „Entscheidet selbst“) und den Vorrang Perikles. Der blinde Fleck: Die Regel erlaubt es, aber keiner prüft vor dem Anlegen, ob die Frage überhaupt zum Chef gehört. Am häufigsten legt Sokrates selbst Abläufe vor, statt sie vorzuentscheiden.
- Vorschlag: `vorlage_pruefen.py` (läuft schon über `probelauf.py`) fragt bei jeder neuen Datei in `entscheiden/` nach einer Zeile „Beim Chef, weil: <Punkt aus der Liste ‚Beim Chef bleiben‘>“. Fehlt sie oder nennt sie keinen Punkt der Liste (Code auf `main`, Geld, Story, Aussehen, Spielgefühl neu, Release, Rollen und Accounts, Lizenz), hält der Haken an und sagt, wer stattdessen entscheidet: Arbeitsweise das Team selbst, Vorrang Perikles, Abläufe Sokrates per Vorentscheid in `billigen/`.
- Gewinn: etwa 40 % weniger Vorlagen, also etwa 7 am Tag.
- Stärkstes Gegenargument: Sokrates hat heute dreimal ein Chefwort falsch gelesen (Fehler 341 um 09:11, 12:06, 12:12). Mehr Vorentscheide heißen mehr Rückbau, wenn ich falsch liege. Dagegen: Ein Vorentscheid gilt sofort, und „zurück“ wird ein Muss. Die Bremse (mehr als zwei „zurück“ in der Woche) bleibt.
- Risiko für die Qualität: gering bei Abläufen und Arbeitsweise, weil beides umkehrbar ist. Aussehen, Story und Spielgefühl bleiben beim Chef.

**S2 · Regeln, die den Chef nur formal binden.** 41 Regeln binden den Chef oder lassen auf ihn warten. Bei diesen kann er nichts prüfen, und sie schützen nichts Schweres:
- Kleinigkeit ohne Spiellogik nur nach seinem Ja auf `main` (CLAUDE.md Feste Regeln). Geht in 1128 auf.
- Build unter 4 Punkten nur auf Ja oder „jetzt“, nach 2 Tagen eine Frage per Telegram mit Ton (`LISTE-CHECK-BUILD-TEST.md` 3 und 10). Das widerspricht der Holschuld (CLAUDE.md 8). Vorschlag: Nach 2 Tagen baut das Team ohne Frage.
- Zweiter Probelauf je Vorgang nur nach Urteil des Chefs oder „Läufe frei“ von Sokrates (`probelauf.py`, `GRENZE = 1`, 621 A). Heute stehen 10 offene Vorgänge an der Grenze, 2 davon mitten in der Arbeit. Vorschlag: Die Grenze gilt nur für Bild und Film an den Chef; Läufe für eigene Messungen und für Tests sind frei, gezählt in den Kosten des Vorgangs.
- Auswahl unter eigenem Bestand per Drehfilm, erst nach seiner Wahl anpassen (`ROLLE-ENTWICKLUNG.md`, Bestand zuerst, 408). Das ist Aussehen und bleibt deshalb beim Chef. Vorschlag: nur die Reihenfolge ändern. Das Team passt das beste Stück an und zeigt es fertig, die anderen im selben Film daneben.
- Ideen verwerfen nur der Chef, dazu wöchentlich eine Datei „Verwerfen?“ (CLAUDE.md, `ROLLE-PROJEKT.md`). Vorschlag: Homer verwirft am Sonntag selbst, der Chef sieht die Liste in Telegram und kann eine Idee zurückholen.
- Eingang ohne Besitzer dem Chef vorlegen (`ROLLE-BETRIEB.md`). Vorschlag: Perikles teilt zu.
- Bremse „mehr als fünf ungebilligt, keine Vorentscheide“ (`ROLLE-BERATUNG.md`). Laut `chefsache/README.md` hält Billigen aber keine Arbeit an. Vorschlag: Die Bremse zählt nur „zurück“, nicht ungelesene Billigungen.
- Gegenargument zum Ganzen: Jede dieser Regeln kam aus einem Fehler (Nummern in Klammern). Fällt sie weg, kann der Fehler wiederkommen. Dagegen: Hier fällt nur die Wartestelle beim Chef weg, der Schutz bleibt beim Team oder beim Werkzeug.

**S3 · Sieben Widersprüche halten Sitzungen an.**
- „Nur ‚noch nicht‘ hält auf; Datei anlegen und weiterarbeiten“ (CLAUDE.md 1 und 4) steht gegen „Ein Zug endet, wenn eine Entscheidung des Chefs fehlt“ (`ROLLE-ENTWICKLUNG.md`) und gegen „Systemfrage: erst in `entscheiden/`, dann bauen“ (654).
- „Billigen hält nicht an“ steht gegen die Bremse.
- Die Frage per Telegram steht gegen die Holschuld.
- „Kein Neustart, solange der Chef testet“ steht gegen „ein ausstehender Test ist kein Hindernis“ (`LISTE-BETRIEB.md`, Archivieren).
- „Stellungnahme nur auf Zuruf“ steht gegen „`lauf.py` startet Sokrates für fremde Vorlagen“.
- „Balance entscheidet der Chef“ (`ROLLE-KREATIV.md`) steht gegen den Vorentscheid von Sokrates zu Einzelheiten der Balance (783 W5).
- „`WorldScreen.kt` nur nach Absprache“ nennt nicht, mit wem.
- Vorschlag: Perikles bereinigt alle sieben in einem Commit, je Widerspruch gilt die Seite, die weniger wartet, außer bei Code auf `main`, Geld, Story und Aussehen.
- Gegenargument: Ein Umbau an vielen Stellen bringt neue Fehler. Dagegen: Jede Stelle ist eine Zeile, und Diogenes prüft danach.

**S4 · Die Sperre 620.1 B zählt die Liste, nicht den Bau.** Sie zählt alle Muss mit „gebaut“ oder „zu testen“, auch wenn sie in keinem Build stecken (Tom 20, davon 6 ohne Build; Jerry 33, davon 24 ohne Build). Ein Test des Chefs löst sie deshalb nicht: Auch nach t283 bleiben beide Teams über 6. Bei Jerry sind ohne die Sperre 18 Muss startbar, mit ihr 2. Dazu ist die Sammelbuild-Automatik (774) seit dem 10.11. stumm, weil die alte Zeile 825 „Sammelbuild … t274“ noch auf „gebaut“ steht. An Tom gegeben als 1131. Zusammen mit 1128 (Muss-Stau) vorlegen.
- Vorschlag: Die Sperre zählt nur Zeilen, die in einem Build auf den Test warten. Was ohne Build älter als 2 Tage ist, fährt Pflicht im nächsten Sammelbuild.
- Gegenargument: Die Sperre soll gerade verhindern, dass ungeprüfte Arbeit sich anhäuft (Wiederholfunde, 620). Dagegen: Gerade die 30 Zeilen ohne Build häufen sich, weil kein Build sie mitnimmt. Die Abhilfe ist der Build, nicht die Sperre.

**S5 · „Muss“ hat seine Bedeutung verloren.** 266 von 327 offenen Zeilen sind Muss. Die Regel sagt: Muss heißt „im Wochenziel oder ‚jetzt‘“. 78 Muss ruhen, ohne dass ein Werkzeug sie je löst. Damit sagt die Klasse nichts mehr über den Vorrang, und `startbar.py` muss über Ketten und Sperren sortieren.
- Vorschlag: Perikles prüft einmal alle Muss gegen das Wochenziel. Was nicht darin steht und kein „jetzt“ hat, wird „M?“. Jedes „ruht“ bekommt einen Termin, an dem `startbar.py` es wieder vorlegt.
- Gegenargument: Damit kann ein Chefauftrag versinken (Haltung 4). Dagegen: Es wird nichts gelöscht, nur umgestuft, der Wortlaut bleibt im Vorrat.

## Was beim Chef bleibt (geprüft, nicht ändern)

Code auf `main` nach seinem Test, in der Form aus 1128. Ebenso Geld und Kauf, Lizenzen, Story und Spieltexte, Aussehen, eine neue Richtung im Spielgefühl, Release, Rollen und Accounts.

## Befunde Perikles (1129.1, Abläufe)

Perikles, 13.11., 13:08. Messung 12:59–13:06 über 7 Tage (Git `main`, `startbar.plan()`, `KOSTEN-GEBUCHT.tsv`, `kostenbericht.py` frisch, Zweig `probelaeufe`, Quelltext der Haken). Überschneidung mit S4 (Sperre) und S5 (Muss, ruht): dort nicht doppelt. Reihenfolge nach Gewinn.

**P1 · Ein Vorgang hält 40 Muss, und keiner merkt es.** Mit `startbar.plan()` die Wartegründe der Teams aufgelöst: an 882.1 (Tom, Werkzeuge ohne Kotlin) hängen über die Kette 882.2 → 870.10 → 870.13 → 785.x, 954a.x, 966.2, 976, 431 genau 40 Muss (Tom 20, Jerry 15, Perikles 3, Sokrates 2). 882.1 steht in der Liste „festgefahren“ (50,09 $). Ford schließt es seit mindestens 13.11., 05:08 mit `--ohne "882.1:Tom in Arbeit"` aus, die letzte Arbeit daran war 12.11., 23:48 („wartet aufs Rendern“, Hintergrundlauf einer archivierten Sitzung). Seither, also etwa 13 Stunden, lag die Wurzel von 40 Muss still. Von Fords 12 Ausschlüssen sind 8 überholt (831, 771, 901, 1055, 769, 1100.1 im Archiv; 861 ruht; 882.1 ohne Sitzung). Zweitens: Die Kette ist inhaltlich nicht überall nötig. 785.1 (Reiter Held), 785.9 (Probekampf) und 785.20 (Klick-Klang) warten auf 870.13 („Hinweis SRD raus, Aufräumen“).
- Vorschlag (Werkzeug, Perikles): `lauf.py` meldet einen Ausschluss als überholt, sobald die Nummer im Archiv steht, ruht oder 2 Stunden keine Sitzung laut Besetzung daran arbeitet (`OHNE-ÜBERHOLT`, Ford streicht). `startbar.py` rechnet je Zeile die Zahl der abhängigen Muss. Hängen 10 oder mehr daran, steht die Zeile beim Besitzer als „Engpass“ ganz oben, gleich nach „jetzt“. Die Teams prüfen ihre Zeilen an der Kette einmal mit einem Satz je Zeile: Überschneidet sich die Datei mit dem Umzug, ja oder nein? Bei „nein“ fällt das „wartet auf“ weg.
- Gewinn: Bis zu 40 Muss werden früher startbar. Der Fehler (Wurzel still, keiner sieht es) fällt künftig in der ersten Stunde auf.
- Stärkstes Gegenargument: Die Kette soll Doppelarbeit verhindern. Wer vor dem Umzug Menüs baut, baut sie nachher auf Godot-Dateien neu. Dagegen: Wo sich die Dateien überschneiden, bleibt die Kette. Neu ist nur, dass jede Kette einen Grund hat und die Wurzel zuerst drankommt.
- Risiko für die Qualität: keines. Es ändert nur die Reihenfolge.
- Getan 13:05: Hinweis an Ford (Eingang, `c837c5ccd`), 882.1 wieder startbar zu machen.

**P2 · Die Werkzeuge sorgen selbst für ein Fünftel der Push-Konflikte.** 8.822 Commits in 7 Tagen. Davon kamen 1.886 von der Übersicht „Chefsache: Übersicht“ (GitHub-Ablauf `zug-index.yml` nach jedem Push, der `LISTE-VORGAENGE.md` oder einen Vorrat berührt), 309 von „Werkzeug: Pflegehinweise“ (`pflegehinweis.py`, einmal je Sitzungsstart, auch wenn sich nur die Bytezahl einer ohnehin zu großen Datei ändert) und 315 Startsperren. Dazu kamen 1.967 Merges. In einer Stichprobe von 400 Merges brachten 87 (22 %) nur Commits dieser beiden Werkzeuge herein. Jeder dieser Merges ist ein abgelehnter Push mit Pull und neuem Push, bei etwa 0,07 $ je Aufruf (Lauf 113) grob 25 bis 50 $ in der Woche. Teurer ist die Unterbrechung. Der Abschnitt „Offen je Rolle“ macht 360 der 407 Zeilen der Übersicht aus, und `startbar.py --stand` zeigt dasselbe.
- Vorschlag: (a) `pflegehinweis.py` schreibt nur noch, wenn sich die Menge der zu großen Dateien ändert, nicht ihre Bytezahl (Werkzeug, Perikles, sofort). (b) Der Abschnitt „Offen je Rolle“ wandert aus der Übersicht in einen stündlichen Lauf. Die Übersicht wird nur noch bei Änderungen unter `docs/chefsache/` neu geschrieben.
- Gewinn: etwa 2.000 Commits und gut 400 Merges weniger in der Woche.
- Stärkstes Gegenargument zu (b): Der Chef sieht in der Übersicht auf einen Blick, wer woran arbeitet und was wartet. Dagegen: Ein Stand, der eine Stunde alt ist, reicht dafür, denn die Besetzung ist auch stündlich.
- Risiko für die Qualität: keines.

**P3 · Kein Haken zählt, wie oft er anhält.** `commit-pruefung.py` (über 20 Prüfungen), `probelauf.py` (läuft vor jedem Bash-Aufruf), `startsperre-haken.py` und `neustart-haken.py` schreiben nirgends auf, wann sie anhalten. Gezählt wird nur, was durchgeht (176 Probeläufe in 7 Tagen im Zweig `probelaeufe`). Die Kernfrage aus 1129, wie oft eine Regel griff und was sie fand, ist darum für keinen Haken beantwortbar. Darum wird auch nie eine Prüfung gestrichen, die nie anschlägt. Die Laufzeit ist kein Problem: gemessen 0,03 bis 0,07 s je Aufruf.
- Vorschlag (Werkzeug, Perikles): Jeder Haken hängt beim Anhalten eine Zeile an `haken.tsv` im eigenen Zweig an, nicht auf `main` (wie `probelaeufe`): Zeit, Haken, Prüfung, Rolle, Vorgang. Diogenes zählt montags. Eine Prüfung, die zwei Wochen lang nie anhält, schlägt Perikles zum Streichen vor (Regelbilanz).
- Gewinn: Zum ersten Mal lässt sich belegen, welche Regeln überflüssig sind. Das ist die Grundlage für jedes weitere Streichen.
- Stärkstes Gegenargument: noch ein Werkzeug, noch eine Datei (90a). Dagegen: Es ersetzt die Schätzung in jeder künftigen Systemprüfung und ist Teil der Haken, die es schon gibt.
- Risiko für die Qualität: keines.

**P4 · Warnungen, auf die keiner reagiert, und Kürzen, das mehr kostet, als es spart.** Jeder Start (etwa 100 am Tag) zeigt dieselben 4 Pflegefehler und 2 Warnungen. `ARBEIT-BETRIEB.md` ist 58 KB groß, die Grenze liegt bei 15 KB. Sokrates hat am 13.11. um 00:33 darauf hingewiesen, und laut Haken steht die Warnung schon seit Tagen. Die Datei ist von der Größenprüfung ausgenommen, weil die Startsperre dort stehen muss. Die zugehörige Zeile „Pflege“ ist Kür, und Ford startet Kür-Pflege bewusst nicht (Übergabe 11:05). Gleichzeitig kürzen die Rollen ihre Vorräte in 189 Commits in der Woche. Grob gerechnet kostet das 3 bis 5 Aufrufe je Commit, also 6 bis 9 $ am Tag. Ein doppelt so großer Vorrat (30 statt 15 KB) kostete beim Lesen dagegen etwa 4.000 Token mehr je Start, also bei 100 Starts etwa 2 $ am Tag (5 $ je Mio. Neuanlegen). Beides ist geschätzt.
- Vorschlag: (a) `lauf.py` kürzt das Protokoll selbst auf heute und gestern, denn mehr liest es ohnehin nicht (`lauf.py`:366). Älteres steht in Git (Werkzeug, Perikles). (b) Die Grenze für Vorräte steigt auf 30 KB. Gekürzt wird nur noch Erledigtes, und das beim Übergeben, nicht als eigener Commit. (c) Eine Warnung, deren Pflege-Zeile Ford nicht startet, wird nicht mehr bei jedem Start gezeigt, sondern einmal am Tag im Tagesbericht.
- Gewinn: etwa 25 Commits am Tag weniger. Die Startmeldung zeigt nur noch, was zu tun ist.
- Stärkstes Gegenargument zu (b): Größere Vorräte verdecken das Neue, und die Grenze kam aus einem Fehler (Vorräte über 50 KB, Startlektüre 274). Dagegen: Mit 30 KB bleibt eine Grenze. Und das Kürzen hat schon Funde verloren (Lehre 675: vier Funde des Chefs ohne Zeile).
- Risiko für die Qualität: gering, (b) mit Probe über eine Woche.

**P5 · Seit 383 A gibt es viermal so viele Sitzungen, die Wirkung ist noch nicht gemessen.** Für die Zeit seit 09.11., 18:07 sind in 3,8 Tagen 402 Sitzungen gebucht, etwa 106 am Tag. In der Woche davor waren es 200 in 7 Tagen, etwa 29 am Tag. Übergabe-Commits gab es 61 bis 113 am Tag, vorher etwa 20. Eine Sitzung kostete im Schnitt 7,94 $ statt 14,93 $. Die Tage kosteten nach `kostenbericht.py` 411, 550, 1.040 und 877 $, im Schnitt also etwa 720 $ gegen 420 $ in der Woche davor. Das ist verzerrt, denn seit 11.11., 07:18 laufen alle Rollen auf Hoch, und es wurde mehr gebaut. Jeder Neustart heißt Übergabe, Startsperre, `create_session` und eine frische Startlektüre von etwa 50 bis 80 KB (`CLAUDE.md` 15 KB, Rolle 13, Vorrat 15, Liste Build und Test 9 …).
- Vorschlag: Diogenes wertet 790 („Kosten nachher“, am 16.11. fällig) schon jetzt einmal mit den Zahlen bis heute aus, und zwar mit „$ je 1000 Ausgabe-Token“ getrennt nach Rolle und Aufwand. Kostet ein Ausgabe-Token mehr als vorher, wird 383 A neu vorgelegt.
- Stärkstes Gegenargument: 3,8 Tage sind zu kurz, und der Aufwand „Hoch“ mischt sich in die Zahl. Dagegen: Bei 300 $ Unterschied am Tag lohnt eine frühe Zwischenzahl. Entschieden wird erst nach der ganzen Woche.
- Risiko für die Qualität: keines.

**P6 · Bei Sokrates landet Betriebsarbeit, und Team-Muss warten auf ihn.** Sokrates machte 762 Commits in 7 Tagen, mehr als Tom (502) und Jerry (399). 324 davon tragen einen Chef-Wortlaut, er ist also vor allem Umschlagplatz. 6 Team-Muss warten auf 623 (Effektpakete REEBOO Labs: Kauf). Dahinter steht ein Kauf, also der Chef, aber ohne Datei in der Chefsache, und damit verdeckt (Regel 8 Holschuld). 2 weitere warten auf 508 und 782. Sokrates hat 28 startbare Zeilen, die Teamzeilen stehen dort an Platz 4, 5 und 23. Das Gegenlesen jeder Prüfliste liegt meist bei ihm (Liste Build und Test 8, „meist Sokrates“).
- Vorschlag: Eine Zeile, an der Team-Muss hängen, rückt beim Besitzer nach oben (Engpass aus P1, gilt auch für Sokrates). Hängt sie an einem Kauf, braucht sie eine Datei `tun/` beim Chef, sonst gilt sie als Fehler der Liste (`startbar.pruefen_zeile`). Das Gegenlesen der Prüfliste übernimmt das andere Team (Tom liest Jerrys, Jerry Toms), Sokrates nur bei Liste mit beiden Teams.
- Stärkstes Gegenargument: Teams lesen betriebsblind. Sokrates kennt die Erwartung des Chefs und fand in t280 die nicht prüfbaren Zeilen. Dagegen: Das andere Team kennt den Weg durchs Spiel besser, und Fehler wie 282.3 (falsch gestellte Prüffrage) fand der Chef trotzdem.
- Risiko für die Qualität: mittel beim Gegenlesen, darum mit Probe über 3 Builds und Zählung der nicht prüfbaren Zeilen (Diogenes).

**P7 · Der Anteil der Abläufe an den Kosten steigt.** Nach `kostenbericht.py` (13.11., 12:59) kostete B Betrieb diese Woche bisher 738 $ von 3.186 $ (23 %), in der Woche davor 464 $ von 2.947 $ (16 %). Das ist gegen die Direktive („die meiste Zeit ins Spiel“). Gestiegen sind vor allem Steuerung und Abläufe, also Sitzungsbetrieb (P5), Konflikte (P2) und Vorlagen zu Abläufen (S1).
- Vorschlag: kein eigener. P1 bis P5 und S1 senken ihn. Als Maß dient B unter 15 % in der Woche ab 16.11. (Z5 Perikles).
- Gegenargument: Ein Teil von B ist Werkzeugbau, der später Spielzeit spart. Dagegen: Das soll man dann am sinkenden B sehen.

**Selbst gebaut, 13:09–13:13 (Werkzeug, Prüfzeile an Diogenes, `cd2cdc1cc`):** P1 `OHNE-ÜBERHOLT` (`e466b8d45`), P2 (a) (`279416a1f`), P3 `hakenzahl.py` (`c660c954e`), P4 (a) (Protokoll 58 → 44 KB nach Fords nächstem Lauf). Noch nicht gebaut: die Engpass-Zahl aus P1. Sie wirkt heute nur auf 882.1, und das steht bei Tom ohnehin oben. Beim Chef zu entscheiden: P2 (b), P4 (b) und (c), P6. An Diogenes geht P5.
