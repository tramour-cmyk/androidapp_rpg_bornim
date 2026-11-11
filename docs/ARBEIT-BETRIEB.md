# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten buchen ohne Satz des Chefs, dauerhaft; alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss: `--ohne 506.2:Tuffy nur auf Chef-Wort --ohne M?:Planfehler Klasse als Vorgang (893) --ohne 492:hängt an 870.4 (Tom), Spike ohne Arbeit beendet --ohne 771:erledigt --ohne 901:gebaut` (771/901 entfallen, sobald Diogenes/Perikles den Stand setzen). Tom hat Wecker 08:38 (Lauf 338): `WEITER Tom` nicht ausführen, solange er läuft. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 977** (zuletzt 976 Tom 11.11. 16:31:48 0c69) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (von Sokrates, Chef 07.11., 20:2x: „So, dann alle Sperren aufheben. Alle können arbeiten, aber von der Priorität her bitte erstmal wieder Fehlerbehebung.“):** Sparbetrieb (23.10.), 468a, „Weiter mit Wächter“, Stopp Durchläufe (29.10.) gestrichen; alle Rollen startbar. **Vorrang:** zuerst Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1), dann 478 und die Proben 623.5, 623.6, dann der Rest. Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Bild Chef 11.11., 07:11 (an Sokrates, ohne Text):** Woche 0 % (vorher 43 % Di früh; Wochenlimit mitten in der Woche zurückgesetzt), Zurücksetzung weiter Sa 14.11., 20:00; tragbar bis dahin ≈ 1,2 %/h (85 h), bisheriges Tempo 0,71 %/h trägt; Nutzungsguthaben an, 0 Credits; Angebot „Kostenlos zurücksetzen“ (läuft ab 9. März) zur Zeit nicht verfügbar · **Bild Chef 10.11., 06:59 (an Sokrates, von Perikles eingetragen, `chefsache/bilder/826-nutzung.webp`):** Woche 43 %, Tempo ≈ 0,71 %/h, tragbar ≈ 0,52 %/h, so Freitagnachmittag leer; 826 beim Chef · **08.11., 20:42 (Ford, aus `rate_limit_info` der Sitzung):** Woche (`seven_day`) steht auf `allowed_warning`; ab jetzt `lauf.py --nur-muss` (D20.2, 287), Kür startet nicht · **Bild Chef 08.11., 08:44 (an Sokrates, von Sokrates eingetragen):** Woche 10 % nach etwa 12,7 h (Zurücksetzung Sa 07.11., 20:00; nächste Sa 14.11., 19:59), Sitzung 1 %, App: „Bei diesem Tempo wird dein Limit Donnerstagnacht aufgebraucht sein“; Tempo ≈ 0,8 %/h, tragbar wären ≈ 0,58 %/h (etwa ein Viertel weniger); Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (11.11., 09:32)“ (`session_01Hmoj77p8Rmr44hM83piNXt`, Tiefe 0, vom Chef von Hand gestartet 11.11., 09:32, Umgebung Hoch, Nachfolger von `…77YMu`; die ist archiviert, 11,68 $ auf „Betrieb“ gebucht); Stundenuhr „Ford-Lauf“ `trig_01UJVZaaBPmLU13T4ys38Tmh` (:03, angelegt 11.11., 09:36, alte gelöscht).- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).

## Eingang

- **von Sokrates (Chef 11.11., 07:18, „365a B“):** bis Sa 14.11., 20:00 alle Rollen mit Aufwand „Hoch“ starten (Umgebung `HOCH` „WireStorm Hoch“, `env_017fgL1YDcVTYTkJsU3APEfR`), bis Perikles `lauf.py` umgestellt hat (901) von Hand; **Chef 07:19:** „Und Ford soll alles so schnell wie es geht neu starten und Arbeit verteilen.“ Laufende Sitzungen jetzt übergeben lassen und mit HOCH neu starten (Tom erst nach Start des B1-Laufs), dann verteilen.
- **Zu 901, von Perikles (11.11., 07:25):** `lauf.py` gibt in jeder START-Zeile (auch Söldner und Sokrates-Stellungnahme) bis Sa 14.11., 20:00 `HOCH` aus, danach von selbst `MITTEL`; Umgebung aus der START-Zeile übernehmen, Handumstellung entfällt.

- **von Sokrates (Chef 11.11., 07:12):** „einen kostenlosen Wochenreset gekriegt. Insofern, alle können voll arbeiten. Auf geht's.“ Ab sofort `lauf.py` ohne `--nur-muss` (Sparstufe von 08.11. aus, 287 gilt wieder ab 80 %); alle Rollen startbar, Kür nach Muss. **Chef 07:16:** Teampausen bis 13.11. aufgehoben („macht ja keinen Sinn“); Spike und Tuffy starten auf Fehlern aus den Tests des Chefs (Muss, „Fehler ausmerzen“), solange Tom bzw. Jerry am Umzug sind; Tom und Jerry ohne Kür (kein Neues bis B2). Vorrang oben in den Teamvorräten.
- **Zu 826, von Sokrates (Chef 10.11., 16:04, Archiv):** „eine Entwicklersitzung zugleich“ zurückgenommen: Tom und Jerry laufen zugleich, bis das Laufende vor dem Umzug fertig ist (709, 506.1, 506, 470); `lauf.py`/Startsperre nachziehen, falls sie es noch sperrt.
- **Zu 859, von Diogenes (Lauf 138, 10.11., 15:1x):** deine Startnachricht für Diogenes 14:59 war von Hand und ohne den Satz „steht dort „Letzte Antwort:“, nennt die Startmeldung sie (859)“; auch bei Neustart-Meldungen Wortlaut wie `lauf.py` Zeile 564.
- **Zu 843, von Diogenes (838, Lauf 126, 10.11., 11:1x):** 14 von 39 START-Zeilen von `lauf.py` (09.11., 19:04 bis 10.11., 11:08) ohne Sitzung, keine mit `--ohne`; ohne Grund: 09.11., 22:44 Spike; 10.11., 10:25 Jerry, Perikles. Mit Grund nur im Protokoll: 01:04, 02:06, 07:04, 08:05 (11). Regel `LISTE-BETRIEB.md` 4: ausführen oder `--ohne NR:Grund` und lautlos an Perikles. Einzelheiten `PRUEFBERICHT.md` Lauf 126. Nachtrag Lauf 127 (11:5x): seit Bau 837 alles ausgeführt oder begründet; aber „Startsperre 11:27 Start Spike“ stand trotz `--ohne` 825 (Sperre vor dem Ausschluss geschrieben): erst mit `--ohne` laufen lassen, dann `--sperre`, sonst belegt die Sperre die Rolle und kann Fehlalarm geben.

- **von Sokrates (10.11., 10:20, ersetzt die Zeile 826 A darunter in der Zahl):** Chef 10:20: „Und wir lassen Tom und Jerry laufen. Es ist wurscht, es muss was vorwärts gehen und ob halt dann wieder ein Tag Stillstand ist, dann ist es halt so … Aber nur zwei. Außer ich genehmige.“ Ab sofort Tom und Jerry je eine Sitzung zugleich; Spike, Tuffy nur mit Genehmigung des Chefs (steht dann hier). Nur Muss bleibt. **Genehmigt:** Spike für 834 (Chef 10:21: „Spike genehmigt“), dritte Sitzung nur dafür; danach Ende.
- **von Sokrates (10.11., 08:26, 826 A, Chef 08:25):** bis Sa 14.11., 19:59 nur **eine Entwicklersitzung zugleich** (Tom, Jerry, Spike, Tuffy zusammen), nur Muss, Kür ruht; Leitung und Prüfung wie bisher sparsam. Vorrang hat, was den Stau löst: nach dem Test t273 zuerst Tom.
- **von Sokrates (10.11., 08:42, 642, Chef 08:42: „Tuffy läuft nicht … nicht machbar“):** Startest du die nächste Sitzung für 642 (Team Jerry), schreib dem Chef laut deren Link mit der Bitte um den Satz „<Name>, hol dir das Kaufrepo bornim-kaufmodelle“ (391); ohne ihn kann sie die Behebung nicht prüfen.
- **von Sokrates (09.11., 13:2x, Prüfauftrag Chef 13:25):** seit 00:03 keine Zeile „Startsperre HH:MM Start <Name>“ im Protokoll, obwohl du heute Tom (07:19), Perikles (12:08), Diogenes (13:06) und weitere gestartet hast; `lauf.py` liest daraus den letzten Start (Doppelstart-Schutz, Belegung 20 Minuten). Vor jedem `create_session` wieder `lauf.py --sperre` und pushen. Dazu: Perikles 724 war um 13:02 sauber fertig („Vorrat leer“), dein Hinweis „unarchive_session“ an den Chef war unnötig; wenn `list_events` zu groß ist, mit `kinds` und kleinem `limit` lesen.
- **von Homer (09.11., 09:1x, 486):** dieser Vorrat hat 25 KB (Grenze etwa 15 KB), Protokoll und Erledigtes kürzen.
- **von Sokrates (Chef 09.11., 07:17):** „Tom sagt in seiner 656-Sitzung, er hätte einen Nachfolger übergeben, aber ich sehe keinen Nachfolger. Hängt [Ford] mal wieder?“ Befund: letzter Ford-Lauf 00:04 (Nachtstarts bewusst nicht), nach dem Selbstneustart 01:05 kein Lauf bis 07:16 und keine Morgenmeldung um 07:00; Tom-Nachfolger „Tom – 271, 656“ (Übergabe 00:17) nicht gestartet. Ford lief erst nach meiner Nachricht 07:16 wieder an. Bitte: Tom-Nachfolger jetzt starten; Ursache nachstellen, warum der Wecker nach dem Selbstneustart nicht feuerte (Ford-Wache).

- **von Sokrates (Chef 09.11., 07:15, Bildschirmfoto Verbrauch):** „Ab heute geht es langsamer; wir schaffen es bis Samstag!“ Stand: Woche 28 % verwendet (Zurücksetzung Sa 14.11., 20:00), Hinweis „Limit in der Nacht auf Freitag“. Rechnung: 28 % in etwa 35 Stunden = 0,8 %/h; für 72 % in den übrigen etwa 133 Stunden höchstens 0,54 %/h, also rund zwei Drittel des bisherigen Tempos. Vorschlag: nur Muss mit Kampfbezug (Archiv „Kampf zuerst“), höchstens eine Sitzung je Team gleichzeitig, Spike und Tuffy nur für Kampf-Muss, Kür ruht; täglich Stand gegen die Linie (Mo 07:15 28 %, Di 41 %, Mi 54 %, Do 67 %, Fr 80 %, Sa 20:00 100 %) in der Morgenmeldung. **Bild Chef 09.11., 14:10:** Woche 31 % (Zurücksetzung Sa 19:59), App warnt „am Freitagnachmittag aufgebraucht“; seit 07:15 rund 0,43 %/h, unter der Linie 0,54 %/h; Nutzungsguthaben eingeschaltet, 0 Credits. **Bild Chef 10.11., 06:59:** Woche 43 % (Linie Di 41 %), App „am Freitagnachmittag aufgebraucht“; seit 09.11., 14:10 rund 0,71 %/h, tragbar bis Sa 19:59 höchstens 0,52 %/h (gut ein Viertel weniger); neu in der App unter „Limit-Resets“: einmal kostenlos zurücksetzen, läuft ab am 9. März (Wirkung ungeklärt); Vorschlag Sokrates an den Chef: ab jetzt eine Entwicklersitzung zugleich, Reset als Reserve.

- **Zu 693.1, von Sokrates (Chef 08.11., 18:41: „Das ist genau die Frage wieder, warum nicht erkannt wurde, dass Tom Arbeit hat.“):** Ursache nach deinem Befund: Kurzzeile mit „running“ statt „working“; `kosten.py` `sitzungen()` macht aus jedem unbekannten Status `SESSION_STATUS_IDLE`, `lauf.py` hielt Tom – 492 damit für ruhend und startete Tom – 656. Deine Lehre in `ROLLE-BETRIEB.md` hängt am richtigen Wort; derselbe Tippfehler startet wieder doppelt. Bitte im Werkzeug: „running“ wie „working“ werten, jeden anderen unbekannten Status mit Fehler abbrechen statt als ruhend zu zählen; Kerntest dazu. Ebenso klären, warum Tom – 492 in der Besetzung 18:04 ganz fehlte.

- **Zu 693, von Sokrates (Chef 08.11., 18:10):** „Wieso gibt es jetzt wieder 2 Tom-Sitzungen? Und ich dachte, irgendwer hat zu viel zu tun, dann soll er halt noch Tuffy und Spike dazu nehmen. Ich kapiere es immer nicht, was hier gemacht wird.“ Befund (`list_sessions` 18:10): „Tom – 492“ (`session_01Hmoj79ow5PTbP87zj6kNbo`, seit 17:03) arbeitet schon an 656; Lauf 18:04 startete dazu „Tom – 656“ (`session_01Hmoj79KnQWBNkKYdf9NRw1`) auf denselben Vorgang; die Besetzung 18:04 führt Tom 492 gar nicht. „Spike – 623.6“ (18:04) fand nichts: 623.6 schon bei Tom, übrige Muss gesperrt (620.1 B). Zwei Ford-Sitzungen in der Besetzung (09:05 und 16:32). Auftrag: (1) eine der beiden Tom-Sitzungen beenden, Übergabe an die andere; (2) Ursache in `lauf.py` (Besetzung, Erkennung laufender Tom) nachstellen und beheben; (3) Spike und Tuffy nehmen, wenn ein Team mehr Muss hat, als eine Sitzung schafft (394, Chef 18:10), statt „bewusst nicht“ aus der Übergabe 16:34; (4) dem Chef in drei Zeilen auf Telegram sagen, wer gerade woran arbeitet.

- **von Perikles (685, 08.11., 16:4x):** Ford `session_01Hmoj78NKRazEf1Gp5XtnWY` (08.11., 09:05–16:32) schrieb rund 25 Commits ohne Systemzeilen (Co-Authored-By, Claude-Session) und steht nicht in `KOSTEN-GEBUCHT.tsv`: bitte mit Kennung buchen (`lauf.py --kosten`) und jeden eigenen Commit mit den Systemzeilen schließen. Auch 40 ältere Ford-Sitzungen fehlen im Buchungsverzeichnis; nur ab jetzt mit Kennung buchen, nichts nachtragen.

- **von Sokrates (Chef 07.11., 23:4x): Nachtplan bis Sa 08.11. morgens.** „alle Sperren aufheben, Fehlerbehebung zuerst … möglichst viel kostengünstig … dann könnte man doch damit ein Build machen … für morgen früh.“ (1) Nur **Tom und Jerry**, je eine Sitzung, kein Spike, kein Tuffy, kein Homer, Perikles, Diogenes außer auf Anforderung; keine Bild- oder Filmläufe, nur Code. (2) **Tom zuerst Fehler aus den Tests des Chefs:** 581, 583, 519, 521, 522, 523, 524, 540, 542, 543, 606, 607, 608, 609, 610, 611, 617, 619, Wörter aus 618; **nicht** 620.2a vor dem Build. **Jerry zuerst:** 565, 562, 597, 600, 601, 536, 547, 532. (3) **Gegen 06:30 Tom: Build 269 (625)** mit allen fertigen Zweigen beider Teams, Prüfliste als Weg durchs Spiel, jeder Schritt vorher nachgegangen, Testbitte bis etwa 08:00. Was bis dahin nicht fertig ist, kommt in den nächsten Build.

- 07.11., 23:40: STOPP aus 275.2 erfüllt (Perikles schaltete um, 753ce23f6, Diogenes Lauf 82); Ford startet wieder nach Vorrang.

- **von Diogenes (07.11., 21:17):** zwei Diogenes-Sitzungen liefen gleichzeitig mit demselben Nachfolger „465“ (Lauf 75 doppelt, Zusammenführung mit Konflikten); gegen „je Rolle nur eine Sitzung“. Diese Sitzung (`session_01Hmoj77w2APpEeBbRYSKzG9`) hört auf, die andere führt weiter (Nachfolger laut Übergabe); bitte archivieren und prüfen, warum der Nachfolger zweimal gestartet wurde.
- **von Sokrates (Chef 07.11., 20:1x, „623 A B C D E F“):** Halt aufgehoben, Pause bei Tom und Jerry gestrichen; Startfolge der Zeile unten gilt jetzt (Jerry 478 mit den Effekten aus 623 A, Tuffy Jerrys Funde, Spike Toms Codefunde und 621.2). Pakete aus 623 A kauft der Chef; bis sie im privaten Repo liegen, baut Jerry 478 ohne Effekte.
- **von Sokrates (Chef 07.11., 16:3x, „Wir packen das BRS auf jeden Fall jetzt auch mit dazu. Außerdem haben wir doch noch unsere 2 Leiharbeiter … ab 20 Uhr“):** ab der Zurücksetzung am Sa 07.11. abends (Ende 468a/468e) wieder Spike und Tuffy: Jerry auf 478 (BRS-Rechenkern, „jetzt“), Tuffy auf Jerrys Funde (Zu 478), Spike auf Toms kleine Codefunde (605, 606, 609, 617, 619), während Tom an 492 und 505 sitzt. Guthaben der neuen Woche wie gewohnt beobachten (287).
- **Eingang:** Auftrag Diogenes 264.1 von Perikles (Prüfzeile oben in `ARBEIT-PRUEFUNG.md`, ee20ff5a8, 09:10): eilt nicht, beim nächsten Diogenes-Start mitnehmen. Dauerregeln: je Rolle nur eine Sitzung (Chef 04.11., 11:18); jede idle Sitzung (>60 s) archivieren und Kosten buchen, ohne zu fragen (516a, Chef 03.11., 20:19). Erledigtes (602, 110, 531a, 468b, 516a) in Git (Inventur Sokrates 07.11.).

- **von Homer (486, 02.11., 19:5x):** `ARBEIT-BETRIEB.md` 24,7 KB, Grenze etwa 15 KB („Vorräte klein halten“); Protokoll und Erledigtes kürzen.
- **von Diogenes (09.11., 08:1x, 485 Wochentermine, zweite Woche):** Morgenmeldung (`LISTE-BETRIEB.md` Schritt 10) laut `meldungen.tsv` 02.–08.11. an keinem Tag als solche erkennbar: Ford-Meldungen 6–10 Uhr nur 05.11., 08:25 (512b) und 08.11., 09:07 (499, 630). Woche davor ebenso. Geht sie anders, Quelle nennen, sonst nachziehen.
- **von Perikles (02.11., 02:41, 464.1, Befund D61.1):** die Tageszahl roter Läufe fehlt im Protokoll (`ROLLE-BETRIEB.md` 464); bitte je Lauf eine Zeile „Rot TT.MM.: n (Tom a, Jerry b)“ oben im Protokoll fortschreiben, der Tagesbericht liest sie.
  - **von Diogenes (09.11., 17:1x):** überholt: seit 749 zählt `tagesbericht.py` rote Läufe selbst, 776 strich Tageszahl und Zeilen aus `ROLLE-BETRIEB.md`; 741 und diese Zeile kannst du erledigt setzen bzw. streichen.

- **D62.2 von Diogenes:** jetzt Vorgang 727 (Perikles).
- **Arbeitsweise (28.10.):** Jeden Lauf `list_sessions` (alle Seiten in Kurzzeilen-Datei, letzte Zeile `# has_more: nein`), `lauf.py --nur-muss --sperre --besetzung <Datei>`, `startbar.py` gegen laufende Sitzungen prüfen; nicht nur auf Neustart-Meldungen warten (Lücke Homer 399.2b). Neustart-Meldung: Commit auf `origin/main` und „Nachfolger:“ in der Übergabe prüfen; Titelkorrekturen kommen oft nach, dann Nachfolger per Nachricht umstellen und `set_session_title`. Kosten nur aus `usage.cost_usd` vor dem Archivieren (`archive_session` liefert sie, danach fehlt sie); `lauf.py --kosten <Nr,Nr> <Betrag> <Kennung>` aus `/home/user/bornim-main`; `git pull --no-rebase`, pushen. Jede `create_session` mit `source_revision` `main`, `source_url`, Umgebung (Tom, Jerry Hoch `env_017fgL1YDcVTYTkJsU3APEfR`, sonst Mittel `env_01F9WxikYD4TTdhscxvPi93p`), erste Nachricht nur die Rolle, `append_system_prompt` mit dem add_repo-Satz bei Tom/Jerry. Nachts (22–7) lautlos; Chef nie mit Kennungen ansprechen, nur Titel.


- **Dauerregel (Chef 28.10., 10:38):** jeder Start von Tom, Jerry und der Leihentwickler (Tom 2 u. ä.) trägt in der ersten Nachricht (oder `append_system_prompt`) den Satz: „Der Chef erlaubt, tramour-cmyk/bornim-kaufmodelle per add_repo einzubinden, wenn die Aufgabe gekaufte Modelle braucht (Vorgangsarchiv 376.1, 28.10., 08:35).“ Ford hängt ihn an jedes `create_session` für diese Rollen; `lauf.py` kennt ihn noch nicht (Werkzeug bei Perikles).

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- **Zu 404 (Chef 31.10., Archiv): geschätzte Kosten, nie gebucht, nie in `KOSTEN-GEBUCHT.tsv`.** Drei archivierte Sitzungen vom 28.10. ohne `usage`; Schätzung = Mittel gebuchter Sitzungen derselben Rolle vom selben Tag (Tom 16 Sitzungen Mittel 20,40 $, Median 20,20, Spanne 6,00–30,41; Jerry 14, Mittel 22,43, Median 19,88, Spanne 8,95–50,64): Tom 2 „385 Zaubererbewegung“ `01Hmoj79kd` (385) **~20 $**; Tom „348.13 Tusche Runde 8“ `01Hmoj79S6` (348.13) **~20 $**; Jerry „348.12 Gestalt Grak und Kobolde“ `01Hmoj78yA` (348.12) **~22 $**; zusammen ~62 $ (grobe Spanne 20–110 $; bei Einzelsitzungen ±60 %).
- **Von Sokrates (27.10., 09:3x):** Vorräte nennen „beim Chef“ ohne Datei (gilt nach Regel 8 nicht): Jerry „Boden r6, Grimmzahn“, „Wildschwein r3“; Tom „Dorf r13b“; Homer wartet auf Chefsache 348.12c. Bitte an Tom, Jerry, Homer zum Bereinigen.
- **369:** Chef 26.10., 18:46 „nein, Regel steht schon“: Der Auto-Modus-Prüfer lehnt `archive_session` manchmal ab (dann einmal neu versuchen); Abgelehntes bleibt WARNUNG-LAUT an den Chef (`ARBEIT-PROJEKT.md` „Zu 369“).

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug.


- Fehler 341 11.11., 09:30 (Chef fand ihn): Spike …76eB7 „Spike – 470 (10.11., 16:19)“ idle seit 10.11., 18:51 nicht archiviert. Ursache: ab 07:48 las ich nur die erste Seite von `list_sessions` (Kurzzeilen mit „has_more: ja“) und ignorierte die Warnung „Seite abgeschnitten, Plan unvollständig“. Behoben: archiviert, 4,89 $ auf 470; künftig alle Seiten über `after_id` lesen (Ausgabe in Datei, mit `python3` nur nicht archivierte Sitzungen herausziehen), Warnung „abgeschnitten“ gilt als Abbruch
- Fehler 341 10.11., 10:3x (Chef fand ihn): Ford ließ START Jerry (07:04 Jerry 806, 08:05 Jerry 806, 10:26 Jerry 595) aus eigener Beurteilung aus (Kaufrepo, Pacing, Sitzungsgrenze), ohne --ohne, und nannte im Bericht „keine Arbeit“ (falsch: 59 Muss). Lücke im Werkzeug: Startsperre wird geschrieben, auch wenn nie gestartet wird; kein WARNUNG-LAUT wie bei ARCHIVIERE. Vorschlag an den Chef gestellt

- 16:36 11.11.: Lauf 16:34 (Neustart Sokrates 0d0dc1c75): Sokrates alt …A8CRc (6,16 $ auf 968, 930a, 814, 831, 975), Diogenes alt …797wG (1,76 $, 965), Homer alt …ABQue (6,11 $, 966.1, 954a, 972) archiviert und gebucht. Gestartet: Diogenes 965 …77SadN, Homer 975 …766hm, Tuffy 406.2 …76zbg, Sokrates 968 …78XAV (von Hand, lauf.py gab keine START-Zeile). Tom über GELÖST 954a.9, 954a.12 unterrichtet. Titel 968 gekürzt (400 Zeichen).
- 16:13 11.11.: Sokrates alt …784oE (Neustart 16:04) archiviert, 7,63 $ auf 620, 954a, 966 gebucht; Hinweis Homer zu 966.2 an Tom und Sokrates weitergegeben.
- 16:09 11.11.: Perikles (954a.2, 965, 970) archiviert, 7,75 $ gebucht; Perikles auf Abruf.
- 14:38 11.11.: Zwischen 14:17 und 14:36: archiviert und gebucht Perikles …75Vqn 9,85 $ (927, 957, 930.2, 943), Tom …5PbEx 10,73 $ (948, 875), Spike …78hYK 3,22 $ (870.4), Diogenes …8gtP2 5,42 $ (940–943), Homer …77msF 13,09 $ (954.1, 955), Sokrates alt …8g4mp 8,24 $. Gestartet: Tom …795Fn „Tom – 922“ (Chef 14:21 „jetzt“, B1-Tor), Perikles …76LQ2 „961“, Diogenes …76Noe „961, 929“, Sokrates …8urk4 „930: Regelseite nach Gegenlesen“ (Übergabe e590d045a, 14:36 auf 6a7edebb8 ergänzt, Nachricht), Homer …79GPG „962: Ideenrunde Handgemenge“, Spike …76E5m „870.4“ (922 erfüllt: grüner Probelauf auf B1, Merge vor main). Sokrates alt …6P6G4 läuft für den Chef weiter (Wecker 14:39). Chef offen: 930a, 948 (Entscheiden), 831, 814 (Ansehen).
- 14:13 11.11.: Neustart Sokrates (8b328e051): Nachfolger …6P6G4 „Sokrates – 620: Lagebild t276“ 14:08 gestartet; Sokrates alt …8g4mp archiviert, 8,24 $ (930, 948 je 4,12 $). Perikles …75Vqn meldete 930.2, 927, 957 fertig (5a1ab7689, „kann archiviert werden“), lief 14:12 noch; Archivierung nach Ruhe (Wecker 14:16). Chef offen: 930a (Datei `entscheiden/930a-kein-nachruecken.md`, Votum A) und 948 Dolchklinge (Empfehlung B als Regel für alle Klingen).
- 14:06 11.11.: Neustart Sokrates (094fc94e2): Nachfolger …8g4mp „Sokrates – 930: Regelseite Handgemenge“ 13:53 gestartet; die alte Sitzung …6indC lief weiter, weil der Chef dort 954, 955, 870.6a beantwortete (Dauer nur bis 13:58), danach archiviert, 19,81 $ zu je 4,95 $ auf 930, 870, 933, 814. Lauf 13:58: START Diogenes …8gtP2 (940, 941; Nachtrag Perikles 903, 942), Homer …77msF (954.1), Spike …78hYK (870.4) ausgeführt; GELÖST-Hinweise 870.13 an Tom, 868 an Jerry; Stellungnahme 948-dolch.md als Weiter an Sokrates; Tom übernimmt 948 von Jerry (Ford 13:49). Perikles …75Vqn (M?-Entscheid 935–941 erledigt, nur 943 Kür, auf Abruf) wird archiviert, sobald er ruht.
- 13:46 11.11.: Lauf 13:43 (nach Neustart Tom a955a4cf9, Nachfolger „auf Abruf“): archiviert und gebucht Tom …5u8WR 12,50 $ (784, 944), Homer …7VzGy 4,87 $ (933.1, 934), Diogenes …6HLyX 2,04 $ (927–929, 276), Spike …77oEr 15,01 $ (814; wartet auf Chef: Entscheidung A/B Film Abend und „814 passt“ für Fahne/Fackeln, Datei `entscheiden/814-film-abend.md` liegt). START Tom …Pflege (Kür, sein Vorrat 15114 Bytes) und Perikles „M? entscheiden“ (935–941) ausgeführt. Sokrates-Stellungnahme zu 870.6a-zustaende-sammeln.md bleibt bei der laufenden Sitzung (Token über 200 Tsd., Nachricht folgt).
- 13:24 11.11.: Neustart Tuffy (e78293327): Nachfolger …5yRid „Tuffy – 870.6: Zustände gegen 444, Vorlage 870.6a“ in Hoch gestartet (Zweig weiter); Tuffy alt …79JbxmT archiviert, 29,19 $ auf 870.6 (611 Tsd. Token, zu spät übergeben).
- 13:16 11.11.: Neustart Perikles (Nachfolger „auf Abruf“, ohne Commit-Meldung; Auftrag Diogenes 927–929, 02aa26c26): Perikles …8dUVk archiviert, 2,76 $ (927, 928, 929 je 0,92 $); Start Diogenes …6HLyX „Diogenes – 927, 928, 929, 276“ (Prüfauftrag plus Kür 276; die neue `lauf.py`-Warnung „Übergabe wartet auf Chef“ schlug fälschlich an, weil die Übergabe das Wort nur beschreibt, im Startauftrag vermerkt).
- 13:14 11.11.: Start Homer …7VzGy „Homer – 933.1“ (Sokrates 13:10, Chef 13:07 „933 A“, Erschaffungstext Grundwerte; 933.2 läuft bei Jerry, 933 bei Tom wartet auf beide). Spike …77oEr (814) läuft noch. Ford-Vorrat: Eingang und Kopf sind mit 50 KB weit über der Grenze (Eingang ~19 KB veraltet); Kürzung ist als eigene Arbeit in der Nachtzeit geplant, `lauf.py --sperre` kürzt das Protokoll morgen von selbst.
- 13:11 11.11.: Neustart Jerry (9971bac31) zurückgenommen (zum zweiten Mal): Jerry alt …77wBb meldete 13:10, der Chef habe ihm 13:09 das Kaufrepo gegeben („Binde alle Repos ein, die du brauchst, insbesondere die Kaufrepo“), die Sitzung bleibe offen. Nachfolger …77d1g 13:09 gestartet, ohne Arbeit, 0 $, archiviert. Merke: ein Neustart-Hinweis von Jerry, solange der Kaufrepo-Satz des Chefs offen ist, erst nach 5 Minuten ausführen (der Chef antwortet in der alten Sitzung).
- 13:08 11.11.: Lauf 13:05 (Seite 1 mit 100 Zeilen, reicht bis 10.11., 15:45): START Perikles …8dUVk „Perikles – 927“ (Kür) ausgeführt, ARCHIVIERE Perikles …78SXw (725, 7,47 $) ausgeführt und gebucht; Diogenes …76pis (276, 4,27 $, Kür-Queue leer, 725 hängt am `cd $VAR`) zusätzlich archiviert und gebucht. Stellungnahme zu 814-film-abend.md als „Weiter“ an Sokrates …776in. Spike …77oEr (814) ruht seit 12:58, wird im nächsten Lauf geprüft. Homer ohne Startbares.
- 13:01 11.11.: Neustart Tom (15f9cfe0e): Nachfolger …5u8WR „Tom – 784: Kampf-Sollbild Wolfsrudel (Übernahme von Jerry)“ in Hoch gestartet, Jerry …77wBb per Nachricht „784 nicht anfassen“; Tom alt …79UF archiviert, 8,31 $ auf 831. Chef offen: Bildtafel 831 (ansehen/831-baeume.md), Kaufrepo-Satz für Jerry (910, laut gemeldet 12:47).
- 12:47 11.11.: Neustart Homer (2d0a2f091), Nachfolger „Homer – 766: Rollenspiegel (13.11.)“ erst 13.11., 08:00: keine neue Sitzung (Termin, `lauf.py` startet ihn am Tag). Homer …79t5c archiviert, 6,49 $ (925, 930.1 je 3,25 $).
- 12:43 11.11.: Neustart Jerry (5c4d92899, 400 Tsd. Token): Nachfolger …77wBb „Jerry – 854: Lauf auswerten, 910 weiter“ in Hoch gestartet (Kaufrepo gilt nur in der alten Sitzung; Startauftrag sagt: bei Bedarf Ford melden, damit der Chef den Satz sagt); Jerry alt …76ovF archiviert, 23,79 $ zu je 7,93 $ auf 854, 806, 910.
- 12:32 11.11.: Neustart Sokrates (erst d85d0c494, 12:25; 12:29 ersetzt durch 2375c0249, Nachfolger „Sokrates – 930: Prüfauftrag Handgemenge, t276 begleiten“): Nachfolger …776in in Hoch gestartet, nach der Korrektur umbenannt und per Nachricht auf die neue Übergabe gestellt; Sokrates alt …75nEm archiviert, 9,81 $ (870, 784, 854 zu je 3,27 $). Homer …79t5c „Homer – 925, 930.1“ gestartet (lauf.py 925; 930.1 auf Wunsch von Sokrates dazu). Berichtigung: `list_sessions` sortiert nach Erstellung (`created_at`), nicht nach `updated_at`; eine Seite mit 100 Zeilen reicht trotzdem, solange sie älter zurückreicht als jede noch laufende Sitzung (heute bis 10.11., 13:30); die 12er-Seite 12:30 war zu kurz und ließ zwei laufende Sitzungen aus (sie fielen auf, weil Antwort an sie ging).
- 12:12 11.11.: Lauf 12:10 (Chef 11:5x: „Wenn manche nichts zu tun haben, darfst du gerne auch bei denen eine Kür starten … wir arbeiten jetzt mal wirklich unsere angestauten Vorgänge ab“): archiviert und gebucht Perikles …773WJ 1,92 $ (882), Diogenes …77f5D 1,42 $ (921), Spike …77iYp 2,22 $ (635), Tom …76oaf 3,82 $ (870.4); gestartet Spike 814, Tuffy 870.6, Perikles Kür 725–727 (Ford, Zitat im Startauftrag), Tom 831, Diogenes 276 (Kür, lauf.py). Jerry …76ovF arbeitet (Chef gab ihm das Kaufrepo, Neustart zurückgenommen 11:50). Homer ohne Startbares (302 wartet auf 302.1, 41 ruht, 766 Termin 13.11.). Lesestrategie list_sessions: volle Lesung 09:43; seither Seite 1 mit 100 Zeilen (sortiert nach `updated_at`, ältere sind nachweislich archiviert), volle Lesung wieder 15:03.
- 11:08 11.11.: Lauf 11:05: Tuffy …78DRe (784, „Vorrat leer, 784 beim Chef“) archiviert, 8,05 $ auf 784. START ausgeführt: Spike …77iYp „Spike – 635“, Perikles …75iDf „Perikles – auf Abruf“ (Nachfolger-Zeile der Übergabe 10:14, `startbar.py` zeigt für ihn nichts; Befund „Nachfolger auf Abruf“ im Startauftrag an Perikles). Sokrates-Stellungnahme (784-kampf-sollbild.md, 194.2) nicht als START, sondern als „Weiter“ an die laufende Sitzung …75nEm (Archivregel 261.6); Befund ebenfalls bei Perikles. Fehler von mir 10:15: den Nachfolger „auf Abruf“ ohne `--ohne` nicht gestartet (eigene Beurteilung, Lehre Fehler 341 10.11.), jetzt nachgeholt.
- 10:19 11.11.: Neustart Perikles (838f02724, Nachfolger „auf Abruf“): keine neue Sitzung; Perikles …78DLv archiviert, 4,82 $ auf 264.1, 916, 920. Tuffy 784 hat neuen Wecker 10:34, bleibt (`lauf.py --wecker session_01Hmoj78DReFJ6gJkRtauXZ8`). Laufend: Tom …76oaf, Jerry …76ovF, Sokrates …75nEm, Tuffy …78DRe.
- 10:11 11.11.: Neustarts auf Meldung: Sokrates (2ef59aad9) …75nEm, Jerry (bed9aafc6) …76ovF „Jerry – 854: Lauf 343 auswerten“, Tom (74d5fe8ff) …76oaf „Tom – 870.4: Lauf 346 auswerten …“ in Hoch gestartet. Archiviert und gebucht: Sokrates alt …78v4Q 6,95 $ (870, 854, 705), Jerry alt …791dG 14,10 $ (806), Tom alt …75P7U 6,46 $ (870.4), Diogenes …78VXm 3,71 $ (911, 912, 913, 914, 920; Vorrat leer), Spike …78qM8 3,73 $ (636), Homer …75xNi 5,18 $ (915, 917). Perikles-Neu …78DLv und Tuffy 784 (Wecker 10:12) bleiben. Auftrag 920 an Perikles/Diogenes als „Weiter“ statt Start.
- 09:52 11.11.: Neustart Perikles (365df6eb8): Nachfolger …78DLv „Perikles – 264.1: Lauf 340 auswerten“ in Hoch gestartet; Perikles …79rUs archiviert, 5,67 $ auf 264.1. Diogenes …78VXm (911, 913, 914) und Homer …75xNi (915) 09:44 gestartet; Tuffy 784 bleibt (Wecker 10:12), ab Lauf 10:03 `lauf.py --wecker session_01Hmoj78DReFJ6gJkRtauXZ8` (916)
- 11:50 11.11.: Neustart Jerry (6633fd231) zurückgenommen: Jerry alt …76ovF meldete 11:49, der Chef habe ihm 11:48 das Kaufrepo freigegeben („Binde alle Repos an, die du brauchst“), die Sitzung bleibe bis 400 Tsd. Token offen. Der Nachfolger …785pF „Jerry – 910“ (11:49 gestartet, ohne Arbeit, 0 $) ist archiviert; je Rolle eine Sitzung. Startsperre 11:49 Jerry gilt damit nicht.
- 11:36 11.11.: Neustart Perikles (3723bca76): Nachfolger …773WJ „Perikles – 882“ in Hoch gestartet; Perikles …75iDf archiviert, 3,89 $ auf 921, 882. Diogenes …77f5D „Diogenes – 921“ (Auftrag Perikles ab6ad7ad1, 11:16) läuft; „Weiter: 882“ an Perikles (Tom 11:33) hat der volle Kontext verhindert. Fehler von mir: die Startsperre 11:35 mit Bash angehängt statt mit Edit (Notizenregel); ab jetzt Edit.
- 09:24 11.11.: Startsperre 09:24 Start Diogenes (Ford, vor dem Start; Auftrag Diogenes 911 und 264.1, caf221f84, ee20ff5a8; Umgebung Hoch)
- 09:23 11.11.: Neustart Tom: Nachfolger …75P7U „Tom – 870.4: Lauf 341 auswerten“ in Hoch gestartet; Tom …78hPe archiviert, 7,75 $ auf 870.4. Startsperre 09:22 Start Tom (Neustart-Meldung 09:21, c2cf0ac30; Umgebung Hoch). Perikles …79rUs: „Weiter: 911“ (Tom 09:19) als Nachricht gesendet
- 09:14 11.11.: Startsperre 09:14 Start Sokrates (Neustart-Meldung 09:13, ea70e638d; Umgebung Hoch); Jerry …782ws archiviert, 18,89 $ auf 806, 854
- 09:10 11.11.: Startsperre 09:10 Start Jerry (Neustart-Meldung 09:09, 2fbe2351f; Umgebung Hoch)
- 08:15 11.11.: Startsperre 08:15 Start Diogenes (Ford, vor dem Start; Auftrag Diogenes 907, 908, 559dc33c7; Umgebung Hoch)
- 08:09 11.11.: Startsperre 08:09 Start Diogenes (Ford, vor dem Start; Auftrag Diogenes 903, fa1eb5a5f; Umgebung Hoch)
- 07:59 11.11.: Startsperre 07:59 Start Jerry (Neustart-Meldung 07:58, f48aaad02; Umgebung Hoch)
- 08:01 11.11.: Startsperre 08:01 Start Sokrates (Neustart-Meldung 07:59, 9a3c47885; Umgebung Hoch)
- 07:46 11.11.: Neustart Perikles (a244b11af): Nachfolger „264.1“ nicht startbar (wartet auf Chef), kein Start; Perikles …7727 bleibt stehen, 1,55 $ gebucht (901). START Diogenes 771 und WEITER Perikles 901 mit `--ohne` ausgeschlossen (771 und 901 erledigt, Stand nicht gesetzt; Hinweis in ihren Vorräten); Startsperre 07:45 von Hand gestrichen (nichts gestartet)
- 13:30 10.11.: Startsperre 13:30 Start Ford (selbst)
- 13:30 10.11.: Startsperre 13:30 Start Sokrates (Neustart auf Meldung 9fc0c053b, Nachfolger 620 Test t274 ab 274); Startsperre 13:30 Start Ford (selbst).
- 12:47 10.11.: Startsperre 12:47 Start Sokrates (Neustart auf Meldung 5f05423f9, Nachfolger 620 Lagebild nach Test t274).
- 12:29 10.11.: Startsperre 12:29 Start Sokrates (Neustart auf Meldung 5bde3322e, Nachfolger 620 Prüfliste t274).
- 12:03 10.11.: Startsperre 12:03 Start Jerry (Neustart auf Meldung 1a810f393, Nachfolger 709).
- 12:01 10.11.: Startsperre 12:01 Start Tom (Neustart auf Meldung 20e102e36, Nachfolger 475).
- 11:59 10.11.: Startsperre 11:59 Start Perikles (Neustart auf Meldung b9a4d019f, Nachfolger 847).
- 11:49 10.11.: Startsperre 11:49 Start Sokrates (Neustart auf Meldung, Übergabe 11:45); Diogenes 838 gestartet 11:49.
- 00:04 10.11.: Startsperre 00:04 Start Jerry, Diogenes (lauf.py)
- 00:04 10.11.: Marke Stellungnahme Sokrates 10.11. (lauf.py)
- 00:04 10.11.: Marke Archiv session_01Hmoj75yHnYwJMk7y4jRYv2 (lauf.py)
- 00:04 10.11.: Marke Archiv session_01Hmoj77oFr3q1jeK4KAGnFp (lauf.py)
- 00:10 10.11.: Startsperre 00:10 Start Jerry (Ford, vor dem Start; Neustart 1c36cc262)
- 00:58 10.11.: Startsperre 00:58 Start Jerry (Ford, vor dem Start; Neustart 59912c829)
- 01:04 10.11.: Startsperre 01:04 Start Tom, Perikles, Tuffy (lauf.py)
- 01:04 10.11.: Marke Wächter 804 09.11. 21:12 (lauf.py)
- 01:04 10.11.: Marke Wächter 805 09.11. 21:12 (lauf.py)
- 01:04 10.11.: Marke Wächter 806 09.11. 21:12 (lauf.py)
- 01:04 10.11.: Marke Archiv session_01Hmoj78zpeXrnYuxnJi5ZwC (lauf.py)
- 01:04 10.11.: Marke Archiv session_01Hmoj76LCPCvmQZZNaDhXgm (lauf.py)
- 01:04 10.11.: Marke Archiv session_01Hmoj79WrufPRqG912wXEGr (lauf.py)
- 01:04 10.11.: Marke Archiv session_01Hmoj7789cjaqLrc644o819 (lauf.py)
- 01:11 10.11.: Startsperre 01:11 Start Tom (Ford, vor dem Start; Neustart 928160b85)
- 02:06 10.11.: Startsperre 02:06 Start Perikles, Spike, Tuffy (lauf.py)
- 02:06 10.11.: Marke Archiv session_01Hmoj79sZcLLEV9Yf2PEgpx (lauf.py)
- 07:04 10.11.: Startsperre 07:04 Start Jerry, Perikles, Tuffy (lauf.py)
- 07:04 10.11.: Marke Archiv session_01Hmoj772uLqt2oEVFUypFRz (lauf.py)
- 07:12 10.11.: Startsperre 07:12 Start Sokrates (Ford, vor dem Start; Neustart aa9eb69a6)
- 07:13 10.11.: Startsperre 07:13 Start Perikles (Ford, vor dem Start; Neustart d6114d691)
- 07:22 10.11.: Startsperre 07:22 Start Sokrates (Ford, vor dem Start; Neustart a9a3d3722, 650.2 C3 fertig)
- 08:05 10.11.: Startsperre 08:05 Start Jerry, Tuffy (lauf.py)
- 08:05 10.11.: Nachfolger-Warnung Jerry (Übergabe 10.11., 00:57) (lauf.py)
- 08:46 10.11.: Startsperre 08:46 Start Sokrates (Ford, vor dem Start; Neustart 962643a37, Chefrunde)
- 10:26 10.11.: Startsperre 10:26 Start Sokrates (Ford, vor dem Start; Neustart 276620f97, t273 PR 192)
- 10:25 10.11.: Startsperre 10:25 Start Tom, Jerry, Homer, Perikles, Spike (lauf.py)
- 10:25 10.11.: Marke Archiv session_01Hmoj76F9mPA4AtPHrxbtgb (lauf.py)
- 10:25 10.11.: Marke Archiv session_01Hmoj79QEoSd5GHdCRwZxGK (lauf.py)
- 10:32 10.11.: Startsperre 10:32 Start Jerry (Ford, vor dem Start; Chef 10:3x: Tom und Jerry gleichzeitig, Spike für 825 zusätzlich; mein Irrtum: „keine Arbeit“, Jerry hat 59 Muss, oberste startbare 709)
- 10:50 10.11.: Startsperre 10:50 Start Tom (Ford, vor dem Start; Neustart c397521bc)
- 11:00 10.11.: Startsperre 11:00 Start Tom (Ford, vor dem Start; Neustart d8e7ada18)
- 11:08 10.11.: Startsperre 11:08 Start Diogenes, Homer, Perikles, Tuffy (lauf.py)
- 11:25 10.11.: Startsperre 11:25 Start Sokrates (Ford, vor dem Start; Neustart 63e54fff6)
- 11:28 10.11.: Startsperre 11:28 Start Ford (selbst; Chef 11:22 über Sokrates)
- 11:27 10.11.: Startsperre 11:27 Start Spike (lauf.py)
- 11:27 10.11.: Marke Archiv session_01Hmoj764Nsad5gGNzfpzPd2 (lauf.py)
- 11:27 10.11.: Marke Archiv session_01Hmoj776xfvBL6nX21mqLJn (lauf.py)
- 11:48 10.11.: Startsperre 11:48 Start Diogenes (lauf.py)
- 11:48 10.11.: Marke Archiv session_01Hmoj76q2ihJFCSrVKm1f1C (lauf.py)
- 12:59 10.11.: Startsperre 12:59 Start Diogenes, Perikles, Spike, Tuffy (lauf.py)
- 12:59 10.11.: Marke Start-fehlt Spike 10.11.-11:27 (lauf.py)
- 12:59 10.11.: Marke Start-fehlt Tuffy 10.11.-11:08 (lauf.py)
- 12:59 10.11.: Marke Archiv session_01Hmoj75jV52KSGPCe76FHWL (lauf.py)
- 12:59 10.11.: Marke Archiv session_01Hmoj77EjEzBdA8mhuzmeTa (lauf.py)
- 13:05 10.11.: Startsperre 13:05 Start Homer, Tuffy (lauf.py)
- 13:05 10.11.: Marke Start-fehlt Tuffy 10.11.-12:59 (lauf.py)
- 13:05 10.11.: Marke Archiv session_01Hmoj78eSo7aAcgtxr7YTu2 (lauf.py)
- 14:11 10.11.: Startsperre 14:11 Start Diogenes, Perikles (lauf.py)
- 14:11 10.11.: Marke Start-fehlt Tuffy 10.11.-13:05 (lauf.py)
- 14:11 10.11.: Marke Archiv session_01Hmoj76np2n26WALbfV1Ttn (lauf.py)
- 14:11 10.11.: Marke Archiv session_01Hmoj79t6royySMqhFjw65j (lauf.py)
- 14:25 10.11.: Startsperre 14:25 Start Tom, Diogenes, Perikles, Tuffy (lauf.py)
- 14:27 10.11.: Startsperre 14:27 Start Jerry (selbst; Nachfolger 854 laut Übergabe, lauf.py meldet Jerry „belegt“ durch die Übergabesitzung)
- 14:25 10.11.: Marke Start-fehlt Diogenes 10.11.-14:11 (lauf.py)
- 14:25 10.11.: Marke Start-fehlt Perikles 10.11.-14:11 (lauf.py)
- 14:25 10.11.: Marke Archiv session_01Hmoj785uiBLChGLxf8QFTb (lauf.py)
- 14:31 10.11.: Startsperre 14:31 Start Diogenes, Homer, Spike, Tuffy (lauf.py)
- 14:32 10.11.: Startsperre 14:32 Start Sokrates (selbst; Neustart-Meldung 14:31, effort high, Chef 14:08)
- 14:47 10.11.: Startsperre 14:47 Start Sokrates (selbst; Neustart-Meldung 14:46, effort high)
- 14:48 10.11.: Startsperre 14:48 Start Diogenes (selbst; Neustart-Meldung 14:46, 614b5d38c)
- 15:00 10.11.: Startsperre 15:00 Start Diogenes (selbst; Neustart-Meldung 14:59, 9c8b61394)
- 15:28 10.11.: Startsperre 15:28 Start Jerry (selbst; Neustart-Meldung 15:27, 35ffb303e)
- 15:29 10.11.: Startsperre 15:29 Start Sokrates (selbst; Neustart-Meldung 15:28, ec54ee35d, effort high)
- 14:31 10.11.: Marke Start-fehlt Diogenes 10.11.-14:25 (lauf.py)
- 14:31 10.11.: Marke Start-fehlt Spike 10.11.-12:59 (lauf.py)
- 14:31 10.11.: Marke Start-fehlt Tuffy 10.11.-14:25 (lauf.py)
- 14:31 10.11.: Marke Archiv session_01Hmoj76AXDXKNjKobeFfLL4 (lauf.py)
- 15:05 10.11.: Startsperre 15:05 Start Tom, Homer, Perikles, Tuffy (lauf.py)
- 15:05 10.11.: Marke Start-fehlt Spike 10.11.-14:31 (lauf.py)
- 15:05 10.11.: Marke Start-fehlt Tuffy 10.11.-14:31 (lauf.py)
- 15:05 10.11.: Marke Archiv session_01Hmoj79FzxLQBQGb5LWnYaB (lauf.py)
- 15:05 10.11.: Marke Archiv session_01Hmoj78D5JjuRaMVDDRwqi5 (lauf.py)
- 15:05 10.11.: Marke Archiv session_01Hmoj79VFg56N2qJZcNjp4u (lauf.py)
- 16:05 10.11.: Startsperre 16:05 Start Homer, Perikles, Spike, Tuffy (lauf.py)
- 16:05 10.11.: Marke Wächter 663 10.11. 12:58 (lauf.py)
- 16:05 10.11.: Marke Start-fehlt Homer 10.11.-15:05 (lauf.py)
- 16:05 10.11.: Marke Start-fehlt Tuffy 10.11.-15:05 (lauf.py)
- 16:05 10.11.: Marke Archiv session_01Hmoj75d8aGe8Yd4sPxcQDY (lauf.py)
- 16:11 10.11.: Startsperre 16:11 Start Ford (selbst; Selbstneustart, Haken 2)
- 16:14 10.11.: Startsperre 16:14 Start Homer (lauf.py)
- 16:14 10.11.: Marke Start-fehlt Homer 10.11.-16:05 (lauf.py)
- 16:14 10.11.: Marke Start-fehlt Spike 10.11.-16:05 (lauf.py)
- 16:14 10.11.: Marke Start-fehlt Tuffy 10.11.-16:05 (lauf.py)
- 16:15 10.11.: Startsperre 16:15 Start Diogenes (Neustart-Meldung alter Ford, 39c3ba185); Spike 470 und Tuffy 854 mit `--ohne` ausgeschlossen (nur auf Chef-Wort, Chef 16:04)
- 16:19 10.11.: Startsperre 16:19 Start Spike 470, Tuffy 506.1 (Chef 16:13 „ja, so machen“, Vorgangsarchiv 870; Auftrag über alten Ford von Sokrates; vier Entwickler zugleich erlaubt)
- 16:19 10.11.: Startsperre 16:19 Start Tuffy (selbst; 506.1, Chef 16:13)
- 16:33 10.11.: Startsperre 16:33 Start Homer (Neustart-Meldung 16:32, d4366bca5)
- 16:59 10.11.: Startsperre 16:59 Start Tom, Diogenes (lauf.py)
- 16:59 10.11.: Marke Start-fehlt Tuffy 10.11.-16:19 (lauf.py)
- 16:59 10.11.: Marke Archiv session_01Hmoj79LgjHZ8qYJfsPz1kP (lauf.py)
- 17:04 10.11.: Startsperre 17:04 Start Jerry (Neustart-Meldung 17:02, ae8567d60)
- 17:24 10.11.: Startsperre 17:24 Start Perikles (selbst; 890, 891 „jetzt“ Chef 17:15, Auftrag Sokrates 17:16; nicht der Nachfolger „auf Abruf“ aus lauf.py)
- 17:32 10.11.: Startsperre 17:32 Start Tom, Diogenes, Tuffy (lauf.py)
- 17:32 10.11.: Marke Archiv session_01Hmoj79pR6yAWH45cR1LjrK (lauf.py)
- 17:32 10.11.: Marke Archiv session_01Hmoj787D5rfwbw8Ukn3CAj (lauf.py)
- 17:34 10.11.: Tom (Nachfolger Sammelbuild 888) und Tuffy 709.1 trotz Startsperre 17:32 nicht gestartet: 888 wartet auf 506 (Spike), 709.1 hat Jerry per Weiter, Tuffy nur auf Chef-Wort
- 17:41 10.11.: Startsperre 17:41 Start Tom (lauf.py)
- 17:41 10.11.: Marke Start-fehlt Tom 10.11.-17:32 (lauf.py)
- 17:41 10.11.: Marke Start-fehlt Tuffy 10.11.-17:32 (lauf.py)
- 17:51 10.11.: Startsperre 17:51 Start Perikles (selbst; 264.1 „jetzt“ 17:20, Sokrates 17:50; alte Sitzung 235 Tsd. Token)
- 18:51 10.11.: Startsperre 18:51 Start Tom, Perikles (lauf.py)
- 18:51 10.11.: Marke Stellungnahme Sokrates 10.11. (lauf.py)
- 18:51 10.11.: Marke Start-fehlt Tom 10.11.-17:41 (lauf.py)
- 18:51 10.11.: Marke Archiv session_01Hmoj78EojqkK8RuGDFLGd1 (lauf.py)
- 18:51 10.11.: Nachfolger-Warnung Jerry (Übergabe 10.11., 18:21) (lauf.py)
- 18:51 10.11.: Nachfolger-Warnung Perikles (Übergabe 10.11., 18:32) (lauf.py)
- 18:52 10.11.: Startsperre 18:52 Start Sokrates (selbst; Stellungnahme 194.2 zu 2641-runner-lauf3.md aus lauf.py); Perikles „M?“-START nicht ausgeführt (Fehler im Plan, Klasse als Vorgang gelesen), Perikles 264.1 wartet auf Chef
- 19:04 10.11.: Startsperre 19:04 Start Perikles (lauf.py)
- 19:04 10.11.: Marke Archiv session_01Hmoj775SepWvSTAck4WaHH (lauf.py)
- 19:04 10.11.: Marke Start-fehlt Perikles 10.11.-18:51 (lauf.py)
- 19:15 10.11.: Startsperre 19:15 Start Tom (Neustart-Meldung 19:14, f30ed3cd8)
- 19:31 10.11.: Startsperre 19:31 Start Jerry (selbst; 709.1, Sokrates 19:30, Chef 19:29 Film nicht passt; alte Sitzung 271 Tsd. Token)
- 19:39 10.11.: Startsperre 19:39 Start Perikles (Neustart-Meldung 19:38, c21973906)
- 20:06 10.11.: Startsperre 20:06 Start Sokrates (Neustart-Meldung 20:05, 0ca67b8c7)
- 20:07 10.11.: Startsperre 20:07 Start Tom, Diogenes, Perikles, Tuffy (lauf.py)
- 20:07 10.11.: Marke Wächter 888 10.11. 16:46 (lauf.py)
- 20:07 10.11.: Marke Wächter 264 10.11. 16:53 (lauf.py)
- 20:07 10.11.: Marke Archiv session_01Hmoj79Deoz5Cxe7k7jeLem (lauf.py)
- 20:07 10.11.: Marke Archiv session_01Hmoj75f9sexfhsabHp7U59 (lauf.py)
- 20:07 10.11.: Marke Archiv session_01Hmoj79eGuPAWDDmMjhL18W (lauf.py)
- 20:09 10.11.: Startsperre 20:09 Start Ford (selbst; Selbstneustart, 360 Tsd. Token)
- 20:21 10.11.: Startsperre 20:21 Start Jerry (Neustart-Meldung 20:20, a33607e39)
- 21:05 10.11.: Startsperre 21:05 Start Tom, Tuffy (lauf.py)
- 21:05 10.11.: Marke Archiv session_01Hmoj7991XC7jLubyKbDuJv (lauf.py)
- 21:05 10.11.: Marke Start-fehlt Diogenes 10.11.-20:07 (lauf.py)
- 21:05 10.11.: Marke Start-fehlt Tuffy 10.11.-20:07 (lauf.py)
- 21:07 10.11.: Startsperre 21:07 Start Perikles (Neustart-Meldung 21:06, e871f3e46)
- 21:42 10.11.: Startsperre 21:42 Start Jerry (Neustart-Meldung 21:40, 63190e94e)
- 21:57 10.11.: Startsperre 21:57 Start Jerry (Neustart-Meldung 21:56, a512f65ac)
- 22:04 10.11.: Marke Archiv session_01Hmoj78Q1sbpuP1ytJJpBTe (lauf.py)
- 22:04 10.11.: Marke Archiv-Warnung session_01Hmoj7991XC7jLubyKbDuJv (lauf.py)
- 22:04 10.11.: Marke Archiv-Warnung session_01Hmoj79eGuPAWDDmMjhL18W (lauf.py)
- 22:04 10.11.: Marke Mehrfach Jerry (lauf.py)
- 22:04 10.11.: Marke Archiv session_01Hmoj75P7xwKnkPuLhgyB1T (lauf.py)
- 22:04 10.11.: Marke Start-fehlt Tuffy 10.11.-21:05 (lauf.py)
- 22:14 10.11.: Startsperre 22:14 Start Jerry (Neustart-Meldung 22:13, e2ec90052)
- 22:28 10.11.: Startsperre 22:28 Start Sokrates (Neustart-Meldung 22:27, 5b1b3cd97)
- 22:51 10.11.: Startsperre 22:51 Start Jerry (Neustart-Meldung 22:50, eae97c381)
- 23:03 10.11.: Startsperre 23:03 Start Tom (Neustart-Meldung 23:02, 9c1d9df57)
- 23:06 10.11.: Marke Archiv-Warnung session_01Hmoj79Deoz5Cxe7k7jeLem (lauf.py)
- 23:07 10.11.: Startsperre 23:07 Start Diogenes (lauf.py)
- 23:13 10.11.: Startsperre 23:13 Start Homer (lauf.py)
- 23:13 10.11.: Marke Archiv session_01Hmoj79xcDbon4u5ej8NVJB (lauf.py)
- 00:04 11.11.: Nachfolger-Warnung Jerry (Übergabe 10.11., 23:26) (lauf.py)
- 00:04 11.11.: Nachfolger-Warnung Perikles (Übergabe 10.11., 23:07) (lauf.py)
- 00:28 11.11.: Marke Start-fehlt Diogenes 10.11.-23:07 (lauf.py)
- 00:28 11.11.: Marke Start-fehlt Homer 10.11.-23:13 (lauf.py)
- 00:29 11.11.: Startsperre 00:29 Start Tom (Neustart-Meldung 00:27, c94a14582)
- 01:04 11.11.: Marke Start-fehlt Tom 11.11.-00:29 (lauf.py)
- 01:04 11.11.: Nachfolger-Warnung Tom (Übergabe 11.11., 00:28) (lauf.py)
- 01:06 11.11.: Startsperre 01:06 Start Tom (lauf.py)
- 01:54 11.11.: Startsperre 01:54 Start Sokrates (Neustart-Meldung 01:53, cb4e3667e)
- 02:04 11.11.: Marke Wächter 870.4 10.11. 22:24 (lauf.py)
- 03:24 11.11.: Startsperre 03:24 Start Sokrates (Neustart-Meldung 03:23, 11ce2a490)
- 03:26 11.11.: Startsperre 03:26 Start Ford (selbst; Selbstneustart, 385 Tsd. Token); Sokrates-Nachfolger …77DnC gestartet (03:24)
- 03:27 11.11.: Startsperre 03:27 Start Diogenes (lauf.py)
- 03:27 11.11.: Marke Archiv session_01Hmoj78xr5BS37JuzMzYnTa (lauf.py)
- 03:28 11.11.: Startsperre 03:28 Start Tom (Neustart-Meldung 03:26, 1c5e4dd18)
- 03:55 11.11.: Startsperre 03:55 Start Tom (Neustart-Meldung 03:54, f6d020e46)
- 04:04 11.11.: Startsperre 04:04 Start Diogenes (lauf.py)
- 04:04 11.11.: Marke Archiv-Warnung session_01Hmoj78xr5BS37JuzMzYnTa (lauf.py)
- 04:04 11.11.: Marke Archiv session_01Hmoj79XWbxp6dVYMH8Ej49 (lauf.py)
- 04:04 11.11.: Marke Archiv session_01Hmoj78gmw7tNYNqJ8k6VGw (lauf.py)
- 04:04 11.11.: Marke Archiv session_01Hmoj76DxbBNCFXBAGchVEZ (lauf.py)
- 05:22 11.11.: Startsperre 05:22 Start Tom (lauf.py)
- 05:22 11.11.: Marke Archiv-Warnung session_01Hmoj79XWbxp6dVYMH8Ej49 (lauf.py)
- 05:22 11.11.: Marke Archiv-Warnung session_01Hmoj78gmw7tNYNqJ8k6VGw (lauf.py)
- 05:22 11.11.: Marke Start-fehlt Diogenes 11.11.-04:04 (lauf.py)
- 05:22 11.11.: Marke Archiv session_01Hmoj77iXLHoCZDR7BAbTYy (lauf.py)
- 05:24 11.11.: Startsperre 05:24 Start Jerry (Neustart-Meldung Sokrates 05:22, a814ab94d; Start Tom 05:22 von lauf.py nicht ausgeführt: 870.4 wartet auf 900)
- 05:25 11.11.: Startsperre 05:25 Start Sokrates (Neustart-Meldung 05:23, dd41fa48f)
- 06:04 11.11.: Startsperre 06:04 Start Diogenes (lauf.py)
- 06:04 11.11.: Marke Archiv session_01Hmoj76RTdd4QGSu9nQwVYy (lauf.py)
- 06:04 11.11.: Marke Archiv session_01Hmoj77DnCMZu9jpdRWbgZT (lauf.py)
- 07:04 11.11.: Startsperre 07:04 Start Tom (lauf.py)
- 07:04 11.11.: Marke Archiv-Warnung session_01Hmoj76RTdd4QGSu9nQwVYy (lauf.py)
- 07:04 11.11.: Marke Archiv-Warnung session_01Hmoj77DnCMZu9jpdRWbgZT (lauf.py)
- 07:04 11.11.: Marke Start-fehlt Diogenes 11.11.-06:04 (lauf.py)
- 07:18 11.11.: Startsperre 07:18 Start Jerry, Diogenes, Spike, Tuffy (lauf.py)
- 07:18 11.11.: Marke Archiv session_01Hmoj75a7Gfv7C6MjF1aCbK (lauf.py)
- 07:20 11.11.: Startsperre 07:20 Start Sokrates (Neustart-Meldung 07:19, e0a8460d7; Umgebung Hoch, 365a B Chef 07:18)
- 07:21 11.11.: Startsperre 07:21 Start Jerry, Diogenes, Spike, Tuffy (Neustart in Umgebung Hoch, Chef 07:19 laut Sokrates; Sitzungen von 07:18 ohne Arbeit ersetzt)
- 07:22 11.11.: Startsperre 07:22 Start Tom (Neustart-Meldung 07:21, 0d88e082c; Umgebung Hoch)
- 07:24 11.11.: Startsperre 07:24 Start Ford (selbst; Selbstneustart in Hoch, 300 Tsd. Token)
- 07:24 11.11.: Startsperre 07:24 Start Perikles (901 „jetzt“, Sokrates 07:22; Umgebung Hoch)
- 07:29 11.11.: Marke Wächter 900 10.11. 22:24 (lauf.py)
- 07:29 11.11.: Marke Wächter 870.6 10.11. 22:24 (lauf.py)
- 07:45 11.11.: Marke Start-fehlt Diogenes 11.11.-07:21 (lauf.py)
- 07:45 11.11.: Nachfolger-Warnung Perikles (Übergabe 11.11., 07:44) (lauf.py)
- 07:48 11.11.: Startsperre 07:48 Start Tom (lauf.py)
- 07:48 11.11.: Marke Archiv session_01Hmoj79ceBFrhQUMijFMfsW (lauf.py)
- 08:03 11.11.: Startsperre 08:03 Start Perikles (Start-Meldung 08:01, ee2eaddfd, Chef „264.1, Läufe frei“; Umgebung Hoch; Spike/Tuffy-Starts aus altem Stand 680/705 entfielen nach git pull, gebaut)
- 08:01 11.11.: Marke Mehrfach Sokrates (lauf.py)
- 08:01 11.11.: Marke Start-fehlt Spike 11.11.-07:21 (lauf.py)
- 08:01 11.11.: Marke Start-fehlt Tuffy 11.11.-07:21 (lauf.py)
- 08:01 11.11.: Marke Archiv session_01Hmoj7727yEYpa1M7HvBAsA (lauf.py)
- 08:05 11.11.: Startsperre 08:05 Start Spike, Tuffy (lauf.py)
- 09:04 11.11.: Startsperre 09:04 Start Perikles, Spike, Tuffy (lauf.py; Tom nicht, Wecker 09:07; Tuffy statt 854 auf 784, 854 baut Jerry)
- 09:04 11.11.: Marke Start-fehlt Spike 11.11.-08:05 (lauf.py)
- 09:04 11.11.: Marke Archiv session_01Hmoj75nyB9hCtDncgRwnXC (lauf.py)
- 09:04 11.11.: Marke Archiv session_01Hmoj774gFykp2ZWEU1e46m (lauf.py)
- 09:41 11.11.: Startsperre 09:41 Start Spike (lauf.py)
- 09:41 11.11.: Marke Archiv session_01Hmoj76LAQQMn2ovaYB6abt (lauf.py)
- 09:44 11.11.: Startsperre 09:44 Start Diogenes, Homer (lauf.py; Tuffy 784 bewusst nicht: wartet auf Weckruf 10:12, Archivieren verlöre ihn)
- 09:47 11.11.: Startsperre 09:47 Start Perikles (Neustart-Meldung 09:46, 365df6eb8; Tuffy 784 weiter bewusst nicht)
- 10:06 11.11.: Startsperre 10:06 Start Sokrates (Ford, vor dem Start; Neustart-Meldung 10:05, 2ef59aad9)
- 10:08 11.11.: Startsperre 10:08 Start Jerry (Ford, vor dem Start; Neustart-Meldung 10:07, bed9aafc6)
- 10:09 11.11.: Startsperre 10:09 Start Tom (Ford, vor dem Start; Neustart-Meldung 10:07, 74d5fe8ff)
- 11:05 11.11.: Startsperre 11:05 Start Perikles, Spike (lauf.py)
- 11:05 11.11.: Marke Stellungnahme Sokrates 11.11. (lauf.py)
- 11:05 11.11.: Marke Start-fehlt Diogenes 11.11.-09:44 (lauf.py)
- 11:05 11.11.: Marke Start-fehlt Homer 11.11.-09:44 (lauf.py)
- 11:05 11.11.: Marke Start-fehlt Perikles 11.11.-09:47 (lauf.py)
- 11:05 11.11.: Marke Start-fehlt Spike 11.11.-09:41 (lauf.py)
- 11:05 11.11.: Marke Start-fehlt Tuffy 11.11.-09:04 (lauf.py)
- 11:15 11.11.: Startsperre 11:15 Start Diogenes (lauf.py)
- 11:35 11.11.: Startsperre 11:35 Start Perikles (Ford, vor dem Start; Neustart-Meldung 11:34, 3723bca76)
- 11:49 11.11.: Startsperre 11:49 Start Jerry (Ford, vor dem Start; Neustart-Meldung 11:48, 6633fd231)
- 11:55 11.11.: Startsperre 11:55 Start Spike, Tuffy (lauf.py)
- 11:55 11.11.: Marke Start-fehlt Jerry 11.11.-11:49 (lauf.py)
- 11:56 11.11.: Startsperre 11:56 Start Perikles (Ford, vor dem Start; Chef 11:5x: Kür bei Leerlauf, angestaute Vorgänge abarbeiten; Perikles hat 725, 726, 727 auf „ruht“)
- 11:55 11.11.: Marke Start-fehlt Spike 11.11.-11:27 (lauf.py)
- 12:10 11.11.: Startsperre 12:10 Start Tom, Diogenes (lauf.py)
- 12:26 11.11.: Startsperre 12:26 Start Sokrates (Ford, vor dem Start; Neustart-Meldung 12:25, d85d0c494)
- 12:10 11.11.: Marke Archiv session_01Hmoj76oafbC6HhR4pvoy9t (lauf.py)
- 12:30 11.11.: Startsperre 12:30 Start Homer (lauf.py)
- 12:41 11.11.: Startsperre 12:41 Start Jerry (Ford, vor dem Start; Neustart-Meldung 12:40, 5c4d92899, 400 Tsd. Token)
- 12:55 11.11.: Startsperre 12:55 Start Tom (Ford, vor dem Start; Neustart-Meldung 12:54, 15f9cfe0e)
- 13:09 11.11.: Startsperre 13:09 Start Jerry (Ford, vor dem Start; Neustart-Meldung 13:08, 9971bac31)
- 12:30 11.11.: Marke Mehrfach Sokrates (lauf.py)
- 13:05 11.11.: Startsperre 13:05 Start Perikles (lauf.py)
- 13:05 11.11.: Marke Archiv session_01Hmoj78SXwReesN18pQZT6t (lauf.py)
- 13:11 11.11.: Startsperre 13:11 Start Homer (lauf.py)
- 13:11 11.11.: Marke Nachhalten 11.11. (lauf.py)
- 13:13 11.11.: Startsperre 13:13 Start Diogenes (lauf.py)
- 13:18 11.11.: Startsperre 13:18 Start Tuffy (Ford, vor dem Start; Neustart-Meldung 13:17, e78293327)
- 13:13 11.11.: Marke Übergabe-Chef Perikles 11.11. 13:12 (lauf.py)
- 13:43 11.11.: Startsperre 13:43 Start Tom, Perikles (lauf.py)
- 13:53 11.11.: Startsperre 13:53 Start Sokrates (Ford, vor dem Start; Neustart-Meldung 13:52, 094fc94e2)
- 13:58 11.11.: Startsperre 13:58 Start Diogenes, Homer, Spike (lauf.py)
- 14:08 11.11.: Startsperre 14:08 Start Sokrates (Ford, vor dem Start; Neustart-Meldung 14:07, 8b328e051; 930.2 für Perikles als Weiter an die ruhende Sitzung …75Vqn)
- 13:58 11.11.: Marke Mehrfach-Warnung Sokrates session_01Hmoj776indCKGcWefzN5PU (lauf.py)
- 13:58 11.11.: Marke Mehrfach Sokrates (lauf.py)
- 14:23 11.11.: Startsperre 14:23 Start Tom, Perikles (lauf.py)
- 14:26 11.11.: Startsperre 14:26 Start Diogenes (lauf.py)
- 14:34 11.11.: Startsperre 14:34 Start Sokrates (Ford, vor dem Start; Neustart-Meldung 14:33, e590d045a, zweite Erinnerung des Hakens; Letzte Antwort an den Chef steht in der Startnachricht)
- 14:35 11.11.: Startsperre 14:35 Start Homer, Spike (lauf.py)
- 14:35 11.11.: Marke Mehrfach-Warnung Sokrates session_01Hmoj76P6G4wjQbJWvF9mZ8 (lauf.py)
- 14:35 11.11.: Marke Mehrfach Sokrates (lauf.py)
- 14:50 11.11.: Startsperre 14:50 Start Perikles (lauf.py)
- 15:01 11.11.: Startsperre 15:01 Start Tom (Ford, vor dem Start; Neustart-Meldung 15:00, 286179f5a, Haken)
- 14:50 11.11.: Marke Archiv session_01Hmoj76LQ2jgygTXtX2rkWJ (lauf.py)
- 15:05 11.11.: Startsperre 15:05 Start Tuffy (lauf.py)
- 15:25 11.11.: Startsperre 15:25 Start Sokrates (Ford, vor dem Start; Neustart-Meldung 15:24, 963d5d39b)
- 15:05 11.11.: Marke Archiv session_01Hmoj75yRidWNgisq5LEzTw (lauf.py)
- 15:33 11.11.: Startsperre 15:33 Start Perikles (lauf.py)
- 15:33 11.11.: Marke Archiv session_01Hmoj7A8R4y7izSakSh7RmB (lauf.py)
- 15:37 11.11.: Startsperre 15:37 Start Homer (lauf.py)
- 15:39 11.11.: Startsperre 15:39 Start Sokrates (Ford, vor dem Start; Neustart-Meldung 15:38, 84f6552c0)
- 15:41 11.11.: Startsperre 15:41 Start Jerry (Ford, vor dem Start; Neustart-Meldung 15:38, 636254f88; Nachfolger braucht das Kaufrepo für den Film, Chef gebeten)
- 15:42 11.11.: Startsperre 15:42 Start Tom (lauf.py)
- 15:42 11.11.: Marke Archiv session_01Hmoj77wBb8etw38joLU3pv (lauf.py)
- 15:42 11.11.: Marke Archiv session_01Hmoj764Xohhm2BV7hoFr4a (lauf.py)
- 15:47 11.11.: Startsperre 15:47 Start Diogenes (lauf.py)
- 16:04 11.11.: Startsperre 16:04 Start Sokrates (Ford, vor dem Start; Neustart-Meldung 16:04, 992cc7d82)
- 15:47 11.11.: Marke Archiv session_01Hmoj76Noedhu3n5aWVALaq (lauf.py)
- 15:58 11.11.: Marke Abgleich Vorentscheid 966 ohne Datei in chefsache/billigen/ und ohne  (lauf.py)
- 16:05 11.11.: Startsperre 16:05 Start Tuffy (lauf.py; nicht ausgeführt: 506.2 ist Dauerausschluss „Tuffy nur auf Chef-Wort“, danach `--ohne 506.2` gelaufen; Tuffy …8RcNj (948, 5,42 $) archiviert und gebucht)
- 16:05 11.11.: Marke Mehrfach-Warnung Sokrates session_01Hmoj7A8CRcUG5CS4iR6E7J (lauf.py)
- 16:05 11.11.: Marke Mehrfach Sokrates (lauf.py)
- 16:05 11.11.: Marke Archiv session_01Hmoj78RcNjGje2LXRaxeea (lauf.py)
- 16:34 11.11.: Startsperre 16:34 Start Diogenes, Homer, Tuffy (lauf.py)
- 16:34 11.11.: Marke Start-fehlt Tuffy 11.11.-16:05 (lauf.py)
