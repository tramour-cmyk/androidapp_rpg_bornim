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

…
