# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Übergabe (09.11., 22:32, Ford `session_01Hmoj7684czZostW4Q5YTcw`, Selbstneustart):** Getan: Wechsel Tom 762, Jerry 562, Sokrates 620, Perikles 797, Diogenes 799 ausgeführt, alte Sitzungen archiviert und gebucht. Pacing (Chef 09.11., 07:15): `lauf.py --nur-muss`; Spike/Tuffy nur für Kampf-Muss oder Kleines, Oberfläche (Spike 683) ausgenommen. Laufend: Tom 762, Jerry 562, Homer 810, Spike 781, Tuffy 562 (wartet auf Messung, Jerry stimmt ab), Sokrates 620, Perikles 797, Diogenes 799. Offen: Tuffy 562 und Spike 781 archivieren, wenn idle. Sokrates-Sitzungen wachen auf Nachrichten des Chefs wieder auf: vor dem Archivieren `get_session` prüfen. Nachfolger: Ford – Betriebsleiter.

**Nächste freie Vorgangsnummer: 829** (zuletzt 828 Perikles 10.11. 07:10:26 5046) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (von Sokrates, Chef 07.11., 20:2x: „So, dann alle Sperren aufheben. Alle können arbeiten, aber von der Priorität her bitte erstmal wieder Fehlerbehebung.“):** Sparbetrieb (23.10.), 468a, „Weiter mit Wächter“, Stopp Durchläufe (29.10.) gestrichen; alle Rollen startbar. **Vorrang:** zuerst Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1), dann 478 und die Proben 623.5, 623.6, dann der Rest. Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **08.11., 20:42 (Ford, aus `rate_limit_info` der Sitzung):** Woche (`seven_day`) steht auf `allowed_warning`; ab jetzt `lauf.py --nur-muss` (D20.2, 287), Kür startet nicht · **Bild Chef 08.11., 08:44 (an Sokrates, von Sokrates eingetragen):** Woche 10 % nach etwa 12,7 h (Zurücksetzung Sa 07.11., 20:00; nächste Sa 14.11., 19:59), Sitzung 1 %, App: „Bei diesem Tempo wird dein Limit Donnerstagnacht aufgebraucht sein“; Tempo ≈ 0,8 %/h, tragbar wären ≈ 0,58 %/h (etwa ein Viertel weniger); Nutzungsguthaben an, 0 Credits · **Bild Chef 06.11., 06:59 (an Ford):** Woche 95 %, „heute Nachmittag aufgebraucht“, Zurücksetzung Sa 20:00, Nutzungsguthaben an, 0 Credits; damit 287 Stufe 95 %: nur Rückläufer des Chefs, die Entwicklersitzung aus 468e startet nur auf Zuruf · **Bild Chef 05.11., 07:07 (an Sokrates):** Woche 90 %, „heute Abend aufgebraucht“, Nutzungsguthaben an, 0 Credits; **468e B (Chef 08:28, von Sokrates):** bis Sa 07.11., 19:59 eine Entwicklersitzung am Tag, höchstens etwa 3 Stunden, nur Gegner und Höhle (579: 494, dann 506, 492); Ford startet sonst nichts außer auf Zuruf des Chefs; Sitzung endet mit Übergabe nach 3 Stunden · **Bild Chef 04.11., 14:33 (an Sokrates):** Woche 82 % (+3 % seit 07:11, ≈ 0,4 %/h; so am Fr 06.11. gegen 10:45 leer), Sitzung 4 %; **468d ja (Chef 14:43, von Sokrates):** bis Sa 07.11., 19:59 von 23 bis 7 Uhr keine Entwicklersitzung (Tom, Jerry, Spike); Ford startet nach 22:30 keine neue, laufende übergeben bis 23 Uhr; Chefrunden kurz; zusätzlich zu 468c. Bleibt das Tempo beim Ablesen 18 Uhr deutlich unter 0,3 %/h, hebt Perikles die Pause auf · **Bild Chef 04.11., 07:11 (über Sokrates 07:12, `chefsache/bilder/468c-nutzung.webp`):** Woche 79 %, Zurücksetzung Sa 07.11., 19:59; +26 % in 24 h; 468a und 287 gelten (ab 80 % `--nur-muss`); **468c ja (Chef 04.11., 13:38, von Sokrates):** bis Sa 07.11., 19:59 nie mehr als eine Entwicklersitzung (Tom, Jerry, Spike) zugleich, nur Wochenziel und Rückläufer aus Chef-Tests; Vorrang 475, dann Rückläufer Build 257 (532, 548, 557 mit 524.1), dann Wochenziel; Bild- und Filmläufe nur nach Freigabe; dazu Ford und eine Chefrunde am Tag · Bild Chef 03.11., 07:16 (an Perikles): Woche 53 %, Hinweis „bei diesem Tempo am Donnerstagmorgen aufgebraucht“; 17 % in 24 h, über 10 % → heute eine Sitzung weniger (468a); Rest 47 % bis Sa 20:00 ≈ 10 % je Tag · Bild 02.11., 07:33: 36 % (Zurücksetzung Sa 07.11., 20:00); Ziel etwa 11 % je Tag, Ford liest täglich 18 Uhr ab (468) · Bild 01.11., 11:25: 13 % · Bild 27.10.: Git · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder: Git

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Ford lebt in einer Sitzung** „Ford – Betriebsleiter (09.11., 22:46)“ `session_01Hmoj78xzFvBQ6it6HDfWph` (Tiefe 0, vom Chef von Hand gestartet 22:40); Stundenuhr „Ford-Lauf“ `trig_01J1xccV843eQd4EDvMZG3zJ` (:03). Alte Fords `session_01Hmoj7684czZostW4Q5YTcw` (läuft noch, 8,18 $) und `session_01Hmoj76SozRN2uPdhbiLM21` (0,52 $, wartet auf Erlaubnis): zu archivieren, sobald der Chef den Archiv-Satz sagt (820), Kosten dann buchen; deren Uhr gelöscht.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).

## Eingang

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
- **Offen von mir beim Chef:** nichts. Dauerregeln: je Rolle nur eine Sitzung (Chef 04.11., 11:18); jede idle Sitzung (>60 s) archivieren und Kosten buchen, ohne zu fragen (516a, Chef 03.11., 20:19). Erledigtes (602, 110, 531a, 468b, 516a) in Git (Inventur Sokrates 07.11.).

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

- 02:08 10.11.: Spike 804 archiviert, gebucht. Nicht gestartet trotz lauf.py: Perikles auf Abruf (818 wartet auf Chef 822), Spike 825 (Sammelbuild wartet auf Tom 475 und Tests), Tuffy 806 (Jerry 595 hat 806 als Nächstes, braucht Kaufrepo)
- 01:14 10.11.: Tom 819 archiviert, gebucht; Nachfolger Tom 475 läuft; Build 273 zum Test beim Chef
- 01:08 10.11.: Sokrates 650.2 archiviert, gebucht. Nicht ausgeführt trotz lauf.py (Grund): START Tom 819 (alte Sitzung wartet auf laufenden Godot-Lauf), START Perikles "auf Abruf" (818 wartet auf Chef 822), START Tuffy 744 (Figuren, Pacing nur Kampf). Wächter 805/806 an Jerry 595 gesendet; 804 ist zu testen
- 01:03 10.11.: Jerry 562 archiviert, gebucht (562, 595); Nachfolger Jerry 595 läuft
- 00:14 10.11.: Jerry 438 archiviert, gebucht; Nachfolger Jerry 562 läuft
- 00:08 10.11.: Start Jerry 438, Diogenes 800, Sokrates Stellungnahme; Jerry 562 und Diogenes 796 archiviert, gebucht. Perikles 818 wartet auf Chef: "822 Haken abschalten" (docs/chefsache/tun/822-formhaken.md)
- 23:08 09.11.: Start Perikles 818, Spike 804 (Chef jetzt 21:12); Perikles 797 und Spike 781 archiviert, gebucht
- 22:58 09.11.: Tom-Browser 79Sz und Sokrates 7A3w archiviert und gebucht (Sokrates-Auftrag, Chef 22:48)
- 22:55 09.11.: Archiv-Satz des Chefs (22:50) erhalten, 820 erledigt; alte Fords, Jerry 2x, Diogenes 799, Tuffy 562 archiviert und gebucht; Start Diogenes 796 und Tuffy 642; ausgeschlossen: Homer 807 (wartet auf Chef A/B), Spike 475/795 (Pacing, Oberfläche); Sokrates zweimal (7A3w 22:30 und 78zp 22:42) im Blick
- 22:47 09.11.: Ford neu (Chef von Hand, Tiefe 0), Uhr erneuert; wartet auf Archiv-Satz des Chefs (820)
- 16:32 08.11.: Selbstneustart Ford (Kontext 400 Tsd.); neuer Ford legt Uhr an, löscht `trig_018KFM8p48SdbzgBWQ3TzWRR`, archiviert diese Sitzung nach Satz des Chefs.
- 10:05 08.11.: Gestartet Perikles (338.1), Diogenes (Woche), Tom (499, 09:23). Nicht gestartet: Jerry 562 (alter Jerry `77Qb` lief noch, Neustart-Meldung fehlt), Spike 531 (Tom hat 531), Tuffy 560 (Guthaben-Tempo). Archivieren abgelehnt (Auto-Modus-Prüfer, ohne Satz des Chefs): Tom `79X6` 10,76 $, Jerry `76Pu`, Sokrates `76sa`, Diogenes `79SG`, Perikles `78bd`, Ford alt `76HF` 10,17 $; Kosten ungebucht bis dahin.
- 09:07 08.11.: Selbstneustart (Tiefe 2), neue Uhr, alte gelöscht. Gestartet: Diogenes, Perikles (Tagesbericht 08.11.), Sokrates (Stellungnahme 4061, 6201). Spike (499) und Tuffy (562) nicht gestartet, Grund: Woche über tragbarem Tempo (Bild Chef 08:44, ≈ 0,8 statt 0,58 %/h); Startmarke steht, an Perikles melden. Wächter 499, 630 an Tom und Chef. Abgleich-Warnung 416.4 (Tom): „gebaut“ ohne Build, Zweig auf main.
- 13:07 06.11.: Tom `FrCC` (603) fertig: Build 268 zum Test (PR #186, ansehen/t268), archiviert, 21,72 $ auf 603. Keine Sitzung läuft; Tom und Jerry ohne Muss als Code, Rest ruht bis Sa 20:00. Heute gesamt Entwicklung 77,97 $.
- 09:23 06.11.: Tom `8kKy` fertig (591, 592, 582, 583, 557; Sparauftrag leer, Rest braucht Bild/Film), archiviert, 18,41 $ auf 591, 592, 582, 583, 557. Jerry `LgDT` fertig (548, 545, 562, 544, 547, 561, 536, 533, 532), archiviere nach Ruhe. Offen beim Chef: 602.
- 08:28 06.11.: Chef 08:27 „Allein sinnlose Sitzungsstarts kosten ja auch wieder Guthaben.“ Lehre Ford: Start im Sparbetrieb immer mit Zeitrahmen und „danach weiter mit startbarem Muss“, nie nur zwei Zeilen.
- 08:26 06.11.: Chef 08:26 „lass ihn doch noch sparsame Sachen erledigen, die er erledigen kann. Auch Jerry.“: Tom (591, 592 fertig) und Jerry per Nachricht weiter mit startbarem Muss, nur Code, bis etwa 10:30.
- 08:05 06.11.: Neustart Jerry 38d0a7018 (Rückläufer t266 durch, 07:19–07:46; Nachfolger „Jerry – 565: Wer am Zug ist“ nur auf Zuruf, 468e), archiviert, 17,29 $ auf 588, 594, 596, 597, 600, 601. Offen beim Chef: entscheiden/595, 598, 601; Frage, ob Tom 589–592 heute.
- 07:01 06.11.: Bild Chef 06:59: Woche 95 % (287: nur Rückläufer des Chefs). Kein Start: weder Entwicklersitzung (468e, nur auf Zuruf) noch Tagesbericht Perikles. Morgenmeldung gesendet.
- 21:15 05.11.: Ford neu auf Tiefe 0 (Chef von Hand; alter Ford 570 Tsd. Token), Uhr `trig_01XdFp…` angelegt, alte gelöscht, alter Ford `c3tx` archiviert, 22,39 $ auf Betrieb. Kein Start (468e: Entwicklersitzung des Tages gelaufen; 468d ab 22:30).
- 00:03 09.11.: Startsperre 00:03 Start Diogenes, Perikles (lauf.py)
- 00:03 09.11.: Marke Stellungnahme Sokrates 09.11. (lauf.py)
- 07:18 09.11.: Startsperre 07:18 Start Sokrates, Tom (von Hand, nachgetragen 13:28; Sokrates-Befund 13:28)
- 08:05 09.11.: Startsperre 08:05 Start Homer, Diogenes (von Hand, nachgetragen 13:28)
- 09:06 09.11.: Startsperre 09:06 Start Homer, Perikles (von Hand, nachgetragen 13:28)
- 09:15 09.11.: Startsperre 09:15 Start Diogenes (von Hand, nachgetragen 13:28)
- 10:05 09.11.: Startsperre 10:05 Start Perikles (von Hand, nachgetragen 13:28)
- 12:09 09.11.: Startsperre 12:09 Start Perikles (von Hand, nachgetragen 13:28)
- 13:06 09.11.: Startsperre 13:06 Start Diogenes (von Hand, nachgetragen 13:28)
- 14:07 09.11.: Startsperre 14:07 Start Perikles (Ford, vor dem Start)
- 14:25 09.11.: Startsperre 14:25 Start Sokrates (Ford, vor dem Start; Neustart 24717bbce)
- 15:06 09.11.: Startsperre 15:06 Start Homer (Ford, vor dem Start)
- 16:32 09.11.: Startsperre 16:32 Start Tom, Jerry (Ford, vor dem Start; Neustart Tom 861cf1d67; Jerry 778, alte Sitzung 717k Tokens)
- 17:05 09.11.: Startsperre 17:05 Start Perikles (Ford, vor dem Start)
- 18:07 09.11.: Startsperre 18:07 Start Sokrates (Ford, vor dem Start; Neustart 6a64a4709)
- 18:09 09.11.: Startsperre 18:09 Start Perikles (Ford, vor dem Start; Neustart 7dc5a0b28)
- 18:11 09.11.: Startsperre 18:11 Start Tom, Diogenes (Ford, vor dem Start; Neustart 9deabe876, d97fee819)
- 18:17 09.11.: Startsperre 18:17 Start Sokrates (Ford, vor dem Start; Neustart e86da5d96)
- 18:23 09.11.: Startsperre 18:23 Start Sokrates (Ford, vor dem Start; Neustart f029ff304)
- 18:24 09.11.: Startsperre 18:24 Start Ford (selbst)
- 18:39 09.11.: Startsperre 18:39 Start Tom (Ford, vor dem Start; Neustart e8c83f2c4)
- 18:48 09.11.: Startsperre 18:48 Start Jerry (Ford, vor dem Start; Neustart 7fe055e3b)
- 19:04 09.11.: Startsperre 19:04 Start Perikles, Tuffy (lauf.py)
- 19:04 09.11.: Marke Stellungnahme Sokrates 09.11. (lauf.py)
- 19:04 09.11.: Marke Wächter 682 08.11. 21:36 (lauf.py)
- 19:04 09.11.: Marke Archiv session_01Hmoj775ZqfUHKm8MuXT9PR (lauf.py)
- 19:04 09.11.: Marke Archiv session_01Hmoj76czgWbXfFzmZBBKgM (lauf.py)
- 20:05 09.11.: Startsperre 20:05 Start Diogenes, Spike, Tuffy (lauf.py)
- 20:05 09.11.: Marke Archiv session_01Hmoj761HLSADjwkXakYkXB (lauf.py)
- 20:18 09.11.: Startsperre 20:18 Start Sokrates (Ford, vor dem Start; Neustart 9c74655c9)
- 20:20 09.11.: Startsperre 20:20 Start Tom (Ford, vor dem Start; Neustart d13febb60)
- 20:43 09.11.: Startsperre 20:43 Start Sokrates (Ford, vor dem Start; Neustart bda66de43)
- 20:56 09.11.: Startsperre 20:56 Start Jerry, Perikles, Spike, Tuffy (lauf.py)
- 20:56 09.11.: Marke Wächter 778 09.11. 17:25 (lauf.py)
- 20:56 09.11.: Marke Abgleich Vorentscheid 783 ohne Datei in chefsache/billigen/ und ohne  (lauf.py)
- 20:56 09.11.: Marke Mehrfach Sokrates (lauf.py)
- 20:56 09.11.: Marke Archiv session_01Hmoj79rrwbnuixd9gYZZQD (lauf.py)
- 20:56 09.11.: Marke Archiv session_01Hmoj77vuigtSQhyrDrS7mS (lauf.py)
- 20:56 09.11.: Marke Archiv session_01Hmoj787Yg68KiY1QygZmiw (lauf.py)
- 20:59 09.11.: Startsperre 20:59 Start Tom (Ford, vor dem Start; Neustart 2a10d0cd7)
- 21:07 09.11.: Startsperre 21:07 Start Perikles (Ford, vor dem Start; Neustart 2955ca2e0)
- 21:14 09.11.: Startsperre 21:14 Start Sokrates (Ford, vor dem Start; Neustart 205802d60)
- 21:17 09.11.: Startsperre 21:17 Start Diogenes (Ford, vor dem Start; Auftrag Diogenes 799, 55d798cc8)
- 21:59 09.11.: Startsperre 21:59 Start Tom (Ford, vor dem Start; Neustart b53b04aae)
- 22:04 09.11.: Startsperre 22:04 Start Homer, Spike, Tuffy (lauf.py)
- 22:04 09.11.: Marke Archiv session_01Hmoj75joAsGNERE3d6sT3X (lauf.py)
- 22:04 09.11.: Marke Archiv session_01Hmoj75qz119EcWWbsbwBMA (lauf.py)
- 22:25 09.11.: Startsperre 22:25 Start Jerry (Ford, vor dem Start; Neustart 908dde268)
- 22:30 09.11.: Startsperre 22:30 Start Sokrates (Ford, vor dem Start; Neustart fc91cfe12)
- 22:32 09.11.: Startsperre 22:32 Start Ford (selbst)
- 22:36 09.11.: Startsperre 22:36 Start Jerry (Jerry selbst, Chef 22:35: neue Sitzung in WireStorm Mittel, beide Repos prüfen)
- 22:42 09.11.: Startsperre 22:42 Start Tom, Sokrates (alter Ford, weil der neue Ford archive_session nicht darf, 820; Neustart Tom 86e6bccae, Sokrates f83325547)
- 22:44 09.11.: Startsperre 22:44 Start Diogenes, Spike, Tuffy (lauf.py)
- 22:44 09.11.: Marke Archiv session_01Hmoj76oi6MckqboXAF3HM5 (lauf.py)
- 22:44 09.11.: Marke Archiv session_01Hmoj76wXu6kmMjJEMArzXt (lauf.py)
- 22:44 09.11.: Marke Mehrfach-Warnung Sokrates session_01Hmoj78zpeXrnYuxnJi5ZwC (lauf.py)
- 22:44 09.11.: Marke Mehrfach Sokrates (lauf.py)
- 22:44 09.11.: Marke Mehrfach Tom (lauf.py)
- 22:44 09.11.: Marke Archiv session_01Hmoj76ZS7WMbjDEvKqYS1U (lauf.py)
- 22:44 09.11.: Marke Archiv session_01Hmoj7A4xTrueWWUD7rvuhj (lauf.py)
- 22:44 09.11.: Marke Archiv session_01Hmoj75Ve8ZmwJDULqhLZy1 (lauf.py)
- 23:04 09.11.: Startsperre 23:04 Start Perikles, Spike (lauf.py)
- 23:04 09.11.: Marke Archiv session_01Hmoj78bjpypqj7DqHUXe7D (lauf.py)
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
- 07:06 10.11.: Weiter-Nachricht an Jerry 595 (Probelauf seit Stunden durch, Sitzung ruhte seit 02:48) statt Start Jerry 806; nicht gestartet: Perikles auf Abruf (818 wartet auf Chef 822), Tuffy 744 (Figuren, Pacing). Wartet auf Chef: Tom 475 (Urteil Gesichter Lauf 2, Test Build 273), 822, 807 A/B, Tuffy 642 Kaufrepo
