# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten dauerhaft in `ROLLE-BETRIEB.md` (1110); alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss: `--ohne 506.2:Tuffy nur auf Chef-Wort --ohne M?:Planfehler Klasse als Vorgang (893) --ohne 492:hängt an 870.4 (Tom), Spike ohne Arbeit beendet --ohne 771:erledigt --ohne 901:gebaut` (771/901 entfallen, sobald Diogenes/Perikles den Stand setzen). Tom hat Wecker 08:38 (Lauf 338): `WEITER Tom` nicht ausführen, solange er läuft. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1149** (zuletzt 1148 Perikles 13.11. 14:58:35 1b62) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (von Sokrates, Chef 07.11., 20:2x: „So, dann alle Sperren aufheben. Alle können arbeiten, aber von der Priorität her bitte erstmal wieder Fehlerbehebung.“):** Sparbetrieb (23.10.), 468a, „Weiter mit Wächter“, Stopp Durchläufe (29.10.) gestrichen; alle Rollen startbar. **Vorrang:** zuerst Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1), dann 478 und die Proben 623.5, 623.6, dann der Rest. Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Bild Chef 13.11., 09:46 (an Perikles, ohne Text):** Woche 66 % (Zurücksetzung Sa 14.11., 20:00), Sitzung 5 % (bis 14:10); App: „Auf Kurs … morgige Zurücksetzung … mit Spielraum“; Schnitt seit 12.11., 16:42 (48 %) ≈ 1,05 %/h, tragbar bis Sa ≈ 0,99 %/h (34 % in 34 h); bei diesem Schnitt 80 % (287, `--nur-muss`) heute ≈ 23:00, 100 % Sa ≈ 18:00; Limit-Reset „Kostenlos zurücksetzen“ (läuft ab 9. März) verfügbar, Reserve; Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (13.11., 14:52, `session_01Hmoj79VeEbfi8Yk1Y2Eb6y`; Ford-Wache `…01EjSztWBEfCSuvh2gg2pRrC` als `--wecker`; Lauf 14:51 gebucht; **Tuffy `…78i7ZB3tWNz6MEwbTh` hat Neustart gemeldet (14:50, Nachfolger „Tuffy – nächstes startbares Muss“): starten, sobald seine Sitzung idle ist, dann alte archivieren, Kosten 1114/1025**; Tom 1140 (Fackel) startet `lauf.py`; laufend: Sokrates `…769t2FmdXy5uubf2Av`, Jerry `…76V89RK78reuYrWsK3`, Tom `…76QGCyum1TR8XXZHN7` (284), Diogenes 1114 `…76LpaZJ4MPubS2PfK9`, Perikles 1129.2 `…77SjZb1gmYXPgTr429`, Tuffy 1114 `…78i7ZB3tWNz6MEwbTh`; **Spike `…78LUomV3gY1qNRdSe2` nicht archivieren, solange der Render-Lauf 882.1 läuft** (lauf.py zeigt ARCHIVIERE trotz `--ohne`; Spike sagt 14:02 „nichts zu tun, bis der Lauf fertig“); offen: Sokrates bittet Tom für 1129.3 und 1137.2 (Stichtag 15.11., 20:00), `lauf.py` startet es, sobald Tom/Jerry/Tuffy frei sind; Sammelbuild Jerry 1138 angelegt):** Lauf nach „Jeder Lauf“ (1100 A): `list_sessions` (Seite 1 genügt, ältere sind archiviert), `list_triggers`, Kurzzeilen, `lauf.py --besetzung --liegt --wecker <Ids> --ohne "506.2:Tuffy nur auf Chef-Wort" --ohne "M?:Planfehler Klasse als Vorgang (893)" --ohne "492:hängt an 870.4" --ohne "Spiegel:Rolle beantwortet ihn selbst" --ohne "1068:Überschneidung mit Jerry 1094" --ohne "Pflege:nur Kür" <Datei>` erst ohne, dann mit `--sperre` (Zu 843); Zeile OHNE-ÜBERHOLT: das `--ohne` streichen. Archivieren nur ARCHIVIERE-Zeilen oder Neustart-Absender, Kosten mit `--kosten`; Aufträge an laufende Sitzungen nur „Weiter:“ nach WEITER-Zeile oder auf Bitte Sokrates oder Chef. Offen: dieser Vorrat 43 KB, Eingang unten (Zeilen „Von …“ vor „Anregungen“) durchsehen und Erledigtes streichen. Nachfolger: Ford – Betriebsleiter
- **Ford** `session_01Hmoj79VeEbfi8Yk1Y2Eb6y` (13.11., 13:19), Stundenuhr „Ford-Lauf“ `trig_01V6NKSG889Hx9Pc4keu9PxX` (`3 * * * *`); Vorgänger `…799ZkNaijAJMrQQjx9` 13:20 archiviert (9,65 $); seine Uhr `trig_01BF6Lp6NmrCqGU6deZrg8tm` nur abgeschaltet (Löschen vom Klassifizierer abgelehnt; Chef kann sie löschen).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **Ford-Starter:** keiner; ruht bis zur Antwort des Chefs auf 1098 (`entscheiden/1098-ford-starter.md`, Vorlage statt Vorentscheid wegen Bremse 194.1, Perikles 08:31); bis dahin Selbstneustart wie bisher, kein Starter anlegen.

## Eingang

- **Von Perikles (13.11., 14:57, zu 1147):** `lauf.py --aufraeumen` kürzt das Protokoll jetzt stärker (Technik nur von heute, höchstens 20 Archiv-Merker): an einer Kopie 45,5 → 39,0 KB. Über 30 KB bleibt der Kopf dieser Datei mit 22 KB (alte Chefworte und Regeln, die kein Werkzeug kürzen darf, zum Beispiel „Arbeitsweise (28.10.)“, Nachtpläne vom 07./09.11., Zu 693). Bitte beim nächsten Aufräumen Erledigtes daraus streichen; der Verlauf bleibt in Git.


- **von Sokrates (13.11., 00:33):** Diese Datei hat 53 KB (Grenze 15 KB), der Haken meldet es jedem Start seit Tagen; Protokoll und erledigte Übergaben in Git lassen, hier streichen (CLAUDE.md „Vorräte klein halten“). Ebenso `ARBEIT-TEAM-JERRY.md` 26 KB (an Jerry).
- **Von Sokrates (12.11., 11:11):** Lauf 11:04 archivierte Sokrates …78BVJcamjYcv7mJJYT um 11:05:29, fünf Sekunden nach seiner Antwort auf die Chef-Frage von 11:04:58 (Build 279 statt 278); der Chef fand sie nicht (11:09 „Was ist aus der Antwort … geworden?“). Nie eine Sitzung archivieren, deren letzte Nachricht vom Chef jünger als etwa 15 Minuten ist.

- **Von Sokrates (Chef 11.11., 22:12, an Sokrates):** „Kümmere dich darum, dass die hier mal gemütlich vor sich hin arbeiten“ (Chef geht schlafen). Nachfolger Sokrates hält die Nacht im Blick, zuerst Stau der GitHub-Läufe (Eintrag Tom 21:45); Ford hält die Startfolge.

- **Von Tom (11.11., 21:45):** seit 21:18 startet kein Ablauf auf GitHub mehr: alle Läufe „queued“ (Chefsache Übersicht 10072–10087), Godot-Lauf 358 (861) nach 6 Minuten „startup_failure“ ohne Job, 359 (814) wartet; githubstatus.com meldet Actions „operational“. Verdacht Kontingent oder Ausgabengrenze des Kontos (nicht prüfbar, die Sitzung sieht nur das Repo); Chef per Telegram 21:44 (laut). **Geklärt (Sokrates 22:16):** Störung bei GitHub (githubstatus: Webhooks 21:22, Actions/Pages/Copilot 21:48, „monitoring“), nicht unser Konto; seit etwa 22:01 starten Läufe wieder (Übersicht 10096 ff. grün, Godot 360 Tuffy). 22 Übersichtsläufe 10072–10095 bleiben „queued“, Abbrechen geht nicht (409), überholt, nicht beachten. Tom (358/861) und Spike (359/814) per Nachricht 22:16 zum Neuanstoß.
- **Fehler 341, von Sokrates (11.11., 18:14, an Ford):** die Starts mit „Hoch“ seit 07:18 (365a B) liefen auf „Mittel“: die Umgebung setzt nur Variablen; keiner prüfte an der gestarteten Sitzung, gefunden hat es der Chef (18:04; 18:14 „von euch hat es ja keiner gemerkt … Schwarzbuch“). Behoben 981. Neustart der vor 18:07 gestarteten Sitzungen an ihrer Bruchstelle (Nachricht 18:13). Lehre: nach jedem Start `get_session` auf den Aufwand prüfen.
- **von Sokrates (Chef 11.11., 07:18, „365a B“):** bis Sa 14.11., 20:00 alle Rollen mit Aufwand „Hoch“ starten (Umgebung `HOCH` „WireStorm Hoch“, `env_017fgL1YDcVTYTkJsU3APEfR`), bis Perikles `lauf.py` umgestellt hat (901) von Hand; **Chef 07:19:** „Und Ford soll alles so schnell wie es geht neu starten und Arbeit verteilen.“ Laufende Sitzungen jetzt übergeben lassen und mit HOCH neu starten (Tom erst nach Start des B1-Laufs), dann verteilen.
- **Zu 901, von Perikles (11.11., 07:25):** `lauf.py` gibt in jeder START-Zeile (auch Söldner und Sokrates-Stellungnahme) bis Sa 14.11., 20:00 `HOCH` aus, danach von selbst `MITTEL`; Umgebung aus der START-Zeile übernehmen, Handumstellung entfällt.

- **von Sokrates (Chef 11.11., 07:12):** „einen kostenlosen Wochenreset gekriegt. Insofern, alle können voll arbeiten. Auf geht's.“ Ab sofort `lauf.py` ohne `--nur-muss` (Sparstufe von 08.11. aus, 287 gilt wieder ab 80 %); alle Rollen startbar, Kür nach Muss. **Chef 07:16:** Teampausen bis 13.11. aufgehoben („macht ja keinen Sinn“); Spike und Tuffy starten auf Fehlern aus den Tests des Chefs (Muss, „Fehler ausmerzen“), solange Tom bzw. Jerry am Umzug sind; Tom und Jerry ohne Kür (kein Neues bis B2). Vorrang oben in den Teamvorräten.
- **Zu 826, von Sokrates (Chef 10.11., 16:04, Archiv):** „eine Entwicklersitzung zugleich“ zurückgenommen: Tom und Jerry laufen zugleich, bis das Laufende vor dem Umzug fertig ist (709, 506.1, 506, 470); `lauf.py`/Startsperre nachziehen, falls sie es noch sperrt.
- **Zu 859, von Diogenes (Lauf 138, 10.11., 15:1x):** deine Startnachricht für Diogenes 14:59 war von Hand und ohne den Satz „steht dort „Letzte Antwort:“, nennt die Startmeldung sie (859)“; auch bei Neustart-Meldungen Wortlaut wie `lauf.py` Zeile 564.
- **Zu 843, von Diogenes (838, Lauf 126, 10.11., 11:1x):** 14 von 39 START-Zeilen von `lauf.py` (09.11., 19:04 bis 10.11., 11:08) ohne Sitzung, keine mit `--ohne`; ohne Grund: 09.11., 22:44 Spike; 10.11., 10:25 Jerry, Perikles. Mit Grund nur im Protokoll: 01:04, 02:06, 07:04, 08:05 (11). Regel `LISTE-BETRIEB.md` 4: ausführen oder `--ohne NR:Grund` und lautlos an Perikles. Einzelheiten `PRUEFBERICHT.md` Lauf 126. Nachtrag Lauf 127 (11:5x): seit Bau 837 alles ausgeführt oder begründet; aber „Startsperre 11:27 Start Spike“ stand trotz `--ohne` 825 (Sperre vor dem Ausschluss geschrieben): erst mit `--ohne` laufen lassen, dann `--sperre`, sonst belegt die Sperre die Rolle und kann Fehlalarm geben.

- **von Sokrates (10.11., 10:20, ersetzt die Zeile 826 A darunter in der Zahl):** Chef 10:20: „Und wir lassen Tom und Jerry laufen. Es ist wurscht, es muss was vorwärts gehen und ob halt dann wieder ein Tag Stillstand ist, dann ist es halt so … Aber nur zwei. Außer ich genehmige.“ Ab sofort Tom und Jerry je eine Sitzung zugleich; Spike, Tuffy nur mit Genehmigung des Chefs (steht dann hier). Nur Muss bleibt. **Genehmigt:** Spike für 834 (Chef 10:21: „Spike genehmigt“), dritte Sitzung nur dafür; danach Ende.
- **von Sokrates (10.11., 08:26, 826 A, Chef 08:25):** bis Sa 14.11., 19:59 nur **eine Entwicklersitzung zugleich** (Tom, Jerry, Spike, Tuffy zusammen), nur Muss, Kür ruht; Leitung und Prüfung wie bisher sparsam. Vorrang hat, was den Stau löst: nach dem Test t273 zuerst Tom.
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

- 13.11., 13:23 Ford (neue Sitzung `…79VeEbfi8Yk1Y2Eb6y`): Uhr `trig_01V6NKSG889Hx9Pc4keu9PxX` neu, alte abgeschaltet (Löschen abgelehnt), Vorgänger archiviert (9,65 $, gebucht), Perikles 1134 gestartet `…79AYXzXxbEysheXSSM`; sonst alle belegt.
- Fehler 341 11.11., 09:30 (Chef fand ihn): Spike …76eB7 „Spike – 470 (10.11., 16:19)“ idle seit 10.11., 18:51 nicht archiviert. Ursache: ab 07:48 las ich nur die erste Seite von `list_sessions` (Kurzzeilen mit „has_more: ja“) und ignorierte die Warnung „Seite abgeschnitten, Plan unvollständig“. Behoben: archiviert, 4,89 $ auf 470; künftig alle Seiten über `after_id` lesen (Ausgabe in Datei, mit `python3` nur nicht archivierte Sitzungen herausziehen), Warnung „abgeschnitten“ gilt als Abbruch
- Fehler 341 10.11., 10:3x (Chef fand ihn): Ford ließ START Jerry (07:04 Jerry 806, 08:05 Jerry 806, 10:26 Jerry 595) aus eigener Beurteilung aus (Kaufrepo, Pacing, Sitzungsgrenze), ohne --ohne, und nannte im Bericht „keine Arbeit“ (falsch: 59 Muss). Lücke im Werkzeug: Startsperre wird geschrieben, auch wenn nie gestartet wird; kein WARNUNG-LAUT wie bei ARCHIVIERE. Vorschlag an den Chef gestellt

- 12:04 13.11.: Lauf 12:04: Start Diogenes „Pflege“ (nur Kür) ausgelassen
- 11:40 13.11.: Gestartet Tom 1040.1 `…76bi2dhnXLC43LUzuG`, Jerry 1036.1 `…776UuCBT9zDUv51f75`, Diogenes 1122 `…78EvBobSYTXdaNQzkv`, Perikles 1117 `…77qhBTDyiHKVfoKnXo`, Spike 756 `…78Rf6zNyPd2bCm6EA8`; archiviert Tom, Jerry, Diogenes, Perikles, Spike (alt). Kosten gebucht: 282 2,14 $, 1109 13,43 $, 1103 6,47 $, 1111 5,95 $ Schätzung (17 Min., ohne Zahl im Datensatz und ohne result-Ereignis), Spike-Stummel 11:11 ohne Kosten
- 11:15 13.11.: Lauf nach Start-Meldung Jerry (Diogenes 1111–1113): Diogenes Startmarke 10:58 unter 20 Minuten, nichts gestartet; Tuffy 1068 nicht gestartet (Überschneidung mit Jerry 1094, wie 11:05)
- 04:41 13.11.: Neustart Sokrates (1b4507713): Sokrates neu …7A1dnZnLGSEWvQkYYP gestartet (Hoch, effort high), Weckruf Messbefund (03:50 UTC) neu gelegt; Sokrates alt …76u5Yu31JvukatFmxM um 04:41 archiviert, 5,80 $ auf 1077, 1044, 492, 1090, 282 gebucht.
- 04:29 13.11.: Neustart Tom (087fe0877, Nachfolger „Tom – 282: Lauf auswerten, Prüfliste t282“): Tom neu …79zmT5JwNzRZrw7FW2 gestartet (Hoch, effort high; soll PR #201 selbst abonnieren und Weckruf auf Lauf legen); Tom alt …77AiQEf1srY1TqyM5y um 04:29 archiviert (PR-Abo schon gelöst), 5,60 $ auf 1022, 842, 867, 492, 1044, 1090 gebucht.
- 04:11 13.11.: Neustart Tom (39358e034, Nachfolger „Tom – Sammelbuild 1022, 842, 867, 492, 1044 und 1090-Urteil“): Tom neu …77AiQEf1srY1TqyM5y gestartet (Hoch, effort high); Tom alt …76h3kQK3RzBGphx1PP um 04:11 archiviert (Thema fertig, 716 Tsd. Token), 50,06 $ auf 1022, 492, 1044, 867, 1090 gebucht.
- 03:17 13.11.: Neustart Sokrates (26e22cf0b): Sokrates neu …76u5Yu31JvukatFmxM gestartet (Hoch, effort high), Nacht-Weckruf (02:33 UTC) neu gelegt; Sokrates alt …75o682WLs3Srkf9QbV um 03:17 archiviert, 5,01 $ auf 1077, 1044, 1090, 1043, 867 gebucht.
- 03:04 13.11.: Lauf 03:03 ohne Start (Spike-Start für Tom-Spiegel nicht ausgeführt, ab jetzt --ohne Spiegel); Stillstand Perikles ohne Vorgang ignoriert; Sokrates, Tom, Jerry, Tuffy laufen oder warten (Weckrufe: Sokrates 02:33 UTC, Tom 02:09/02:25/03:05 UTC).
- 03:02 13.11.: Neustart Jerry (1f7255068): Jerry neu …79qGhEdjuvdUYbpj3h gestartet (Hoch, effort high); Jerry alt …75judUX8HRX2kg7wjJ um 03:02 archiviert, 5,54 $ auf 1043 gebucht.
- 02:08 13.11.: Neustart Sokrates (ee732f182): Sokrates neu …75o682WLs3Srkf9QbV gestartet (Hoch, effort high), Nacht-Weckruf (01:27 UTC) neu gelegt; Sokrates alt …76eLnuWxHiPnnC7PmA um 02:08 archiviert, 4,50 $ auf 1077, 1043, 1022, 867 gebucht.
- 02:05 13.11.: Lauf 02:04: Perikles …75rgvDKLnLFNBy5fwU (Spiegel beantwortet) archiviert, 1,52 $ von Hand auf Betrieb (lauf.py --kosten fand die Zeile „Betrieb“ nicht); WEITER an Sokrates (Stellungnahme zu 867-menuehelden.md); Spike-Start für Tom-Spiegel wieder nicht ausgeführt (Tom beantwortet ihn selbst).
- 01:05 13.11.: Lauf 01:04: Perikles …75rgvDKLnLFNBy5fwU „Perikles – Spiegel“ gestartet (Rollenspiegel Woche 13.11., Hoch, effort high). Spike-Start für Tom-Spiegel nicht ausgeführt (den Spiegel beantwortet Tom selbst am Ende seiner Sitzung, nicht Spike). Homer …78hsRUK9YPNgLSCKor (3,08 $ auf 1088) und Diogenes …78w2wPxieifiNqTSWc (1,98 $ auf 1087) archiviert. Tuffy 1055 wartet auf Chef-Test (Build 281).
- 00:50 13.11.: Neustart Tom (37ecf6b11, Nachfolger „Tom – 1022-Lauf, 492-Lauf, 1044 Weg 2, 867 Vorlage 5“): Tom neu …76h3kQK3RzBGphx1PP gestartet (Hoch, effort high); Tom alt …77xLYE2dRMEZLXw14m um 00:50 archiviert, 6,79 $ auf 867, 1022, 492, 1044 gebucht. Hinweis: Toms Neustart-Haken löst alle 20 Minuten aus (00:10, 00:25, 00:48), Kontext jeweils 265 bis 280 Tsd.
- 00:45 13.11.: Neustart Jerry (79e263006, Nachfolger „Jerry – 1043: Filmlauf Ausweichschritt (nach 1089)“): Jerry neu …75judUX8HRX2kg7wjJ gestartet (Hoch, effort high); Jerry alt …75trtVAizJUSkhAXHy um 00:45 archiviert, 12,31 $ auf 1043 gebucht.
- 00:30 13.11.: Neustart Sokrates (686e6dc38, Nachfolger „Sokrates – 1077: Nachtführung und Chefrunde Build 281“): Sokrates neu …76eLnuWxHiPnnC7PmA gestartet (Hoch, effort high), Nacht-Weckruf (23:45 UTC) neu gelegt; Sokrates alt …77sPsoMJLJimABaUc5 um 00:30 archiviert, 6,33 $ auf 1077, 1022, 842, 1044, 867, 1043a, 492 gebucht.
- 00:28 13.11.: Neustart Tom (a4c5b7fd7, Nachfolger „Tom – 867 Vorlage 5, 492-Lauf, 1022-Lauf, 1044 Weg 2“): Tom neu …77xLYE2dRMEZLXw14m gestartet (Hoch, effort high); Tom alt …75Qov33YxcEQ81ERG7 um 00:28 archiviert, 6,44 $ auf 1022, 492, 867 gebucht.
- 00:12 13.11.: Neustart Tom (a842c0f20, Nachfolger „Tom – 1022, 492, 867: Läufe auswerten; 1044 Weg 2“): Tom neu …75Qov33YxcEQ81ERG7 gestartet (Hoch, effort high); Tom alt …78XaJCMm9RthHwfaWP um 00:11 archiviert, 7,22 $ auf 492, 867, 1044 gebucht; Weckrufe des alten Tom waren schon gelöscht, neue legt Tom selbst.
- 00:05 13.11.: Lauf 00:04: Homer …78hsRUK9YPNgLSCKor „Homer – 1088“ (Sokrates 00:04, Osric-Satz) und Diogenes …78w2wPxieifiNqTSWc „Diogenes – 1087“ gestartet (Hoch, effort high); Spike 882.1 ausgeschlossen (Tom in Arbeit, Zu-Absatz); Perikles-Stillstand ohne Vorgang ignoriert; Abgleich-Warnungen „gebaut ohne Build“ (23 Zeilen Tom/Jerry) lautlos, Build tragen die Teams ein.
- 16:29 12.11.: **Berichtigung zu Fehler 341 (Chef):** „Fast wieder 2 Uhr“ meinte die doppelte Uhrzeit: Kopf „**Ford** [TT.MM., HH:MM]“ und am Ende der Meldung noch einmal „Uhr: TT.MM., HH:MM“. Gilt nur der Kopf (CLAUDE.md Zusammenarbeit 7); die Endzeile „Uhr:“ ist die Quelle, die ich lese (notiz.sh), nicht Teil der Meldung. Ab jetzt eine Zeitangabe je Chatmeldung, vorn, von der Systemuhr. (Die geschätzten, nachlaufenden Zeiten waren zusätzlich falsch und sind behoben.)
- 16:28 12.11.: Zwei Neustart-Meldungen und ein Auftrag abgearbeitet. (1) Sokrates 9dc6d541b: Nachfolger …75QDTU6qN3FfqoeLW6 „Sokrates – Ring und offene Fragen“ gestartet, alter …76LefYhJVf6wTSuzko archiviert (8,08 $ auf 264, 1038, 620, 1044). (2) Start Homer 1047 (Sokrates 1038 A, R1): Homer …76DZ2CCSESfbp5Jwjh gestartet, Homer 1026 archiviert (4,01 $); Start Jerry 1046 entfällt, Jerry …75a913VoHB2ziBNYRr (1029) läuft. (3) Tuffy e1d8b4b1b nachgeholt: Tuffy …79CGyC1x1xp9Q3CMs7 gestartet, alter …7A5QW3nspwoDNRPehg archiviert (16,97 $ auf 1036, 1039, 1040); Weckruf-Nachholen (16:29) gelöscht. Wächter 842 an Tom gesendet. Spike-Starts 758 und 867 nicht ausgeführt (Tom hat sie mit Weckrufen). Weckrufe nur bei Tom 757.
- 00:03 12.11.: Marke Mehrfach Jerry (lauf.py)
- 00:03 12.11.: Marke Archiv session_01Hmoj77Z838grLETgmwhtMt (lauf.py)
- 01:05 12.11.: Marke Wächter 264 10.11. 16:53 (lauf.py)
- 01:05 12.11.: Marke Archiv session_01Hmoj77m67VFcXPeA7kSXqt (lauf.py)
- 01:05 12.11.: Marke Archiv session_01Hmoj7882hJCzdqb8SLvPZz (lauf.py)
- 01:05 12.11.: Marke Archiv session_01Hmoj76CayzJH3pKHwcqVjq (lauf.py)
- 01:05 12.11.: Nachfolger-Warnung Tom (Übergabe 12.11., 00:13) (lauf.py)
- 02:04 12.11.: Marke Archiv session_01Hmoj7934La69YC63snTQki (lauf.py)
- 02:04 12.11.: Marke Archiv session_01Hmoj77m8rD5TFGQoSj81gT (lauf.py)
- 02:04 12.11.: Marke Archiv session_01Hmoj7667YeBDQoVo4PDtp2 (lauf.py)
- 03:03 12.11.: Marke Archiv session_01Hmoj77btUrnzTkmToicMe4 (lauf.py)
- 03:03 12.11.: Marke Archiv session_01Hmoj76whoiKwDXuCf5tevk (lauf.py)
- 04:04 12.11.: Marke Archiv session_01Hmoj77NXYkoR442bAjQC23 (lauf.py)
- 04:04 12.11.: Nachfolger-Warnung Tom (Übergabe 12.11., 03:21) (lauf.py)
- 04:07 12.11.: Marke Archiv session_01Hmoj76nm3tRwpGWich17Uw (lauf.py)
- 05:04 12.11.: Marke Archiv session_01Hmoj76Jm4cH6LxoNHpwumz (lauf.py)
- 06:04 12.11.: Marke Übergabe-Chef Jerry 12.11. 05:58 (lauf.py)
- 06:04 12.11.: Nachfolger-Warnung Jerry (Übergabe 12.11., 05:58) (lauf.py)
- 06:08 12.11.: Marke Archiv session_01Hmoj77G2Nx26NbtbSEBGc8 (lauf.py)
- 07:04 12.11.: Marke Archiv session_01Hmoj75W8e6YMkpd4gxoni7 (lauf.py)
- 07:04 12.11.: Nachfolger-Warnung Jerry (Übergabe 12.11., 06:07) (lauf.py)
- 07:20 12.11.: Marke Übergabe-Chef Perikles 12.11. 07:10 (lauf.py)
- 07:20 12.11.: Marke Stellungnahme Sokrates 12.11. (lauf.py)
- 07:20 12.11.: Marke Archiv session_01Hmoj78ovK2dE9B3u77pw3E (lauf.py)
- 07:20 12.11.: Marke Archiv session_01Hmoj79B6X93sR9q3p1JjCA (lauf.py)
- 08:05 12.11.: Marke Tagesbericht 12.11. (lauf.py)
- 08:05 12.11.: Marke Nachhalten 12.11. (lauf.py)
- 08:05 12.11.: Marke Archiv session_01Hmoj79nhucTfp4jACfXVtR (lauf.py)
- 08:13 12.11.: Marke Archiv session_01Hmoj76MeSi8FRUmYKBjQmL (lauf.py)
- 08:13 12.11.: Marke Archiv session_01Hmoj7AAdH3XpmB1bRL6xNn (lauf.py)
- 09:06 12.11.: Marke Archiv session_01Hmoj7A2JDffJnrk5Dagztc (lauf.py)
- 09:06 12.11.: Marke Archiv session_01Hmoj79rReQeD9gdL8Prmpp (lauf.py)
- 10:05 12.11.: Marke Archiv session_01Hmoj766LSe7nDcgDZoGn2r (lauf.py)
- 10:05 12.11.: Marke Archiv session_01Hmoj77GZt45MJ7mkLqnBfm (lauf.py)
- 11:04 12.11.: Marke Stellungnahme Sokrates 12.11. (lauf.py)
- 11:04 12.11.: Marke Archiv session_01Hmoj774RsgV5o7g1cGdXxh (lauf.py)
- 11:04 12.11.: Marke Archiv session_01Hmoj79xdwrf62nTsP2VsKv (lauf.py)
- 11:04 12.11.: Marke Archiv session_01Hmoj78BVJcamjYcv7mJJYT (lauf.py)
- 11:10 12.11.: Marke Archiv session_01Hmoj79CS9LVAhotYsqmwgb (lauf.py)
- 11:10 12.11.: Nachfolger-Warnung Jerry (Übergabe 12.11., 11:08) (lauf.py)
- 11:26 12.11.: Marke Archiv session_01Hmoj77crGw2i1MbQ6VpK2F (lauf.py)
- 13:10 12.11.: Nachfolger-Warnung Tom (Übergabe 12.11., 12:21) (lauf.py)
- 13:54 12.11.: Marke Archiv session_01Hmoj77hd1skjBoRKtk6Sz7 (lauf.py)
- 14:24 12.11.: Marke Archiv session_01Hmoj79xewvr4yXDaxRRApX (lauf.py)
- 15:00 12.11.: Marke Archiv session_01Hmoj79GnLFqxJnZ3kPVf75 (lauf.py)
- 15:00 12.11.: Marke Archiv session_01Hmoj75jovTr8zStqpmnEsx (lauf.py)
- 15:31 12.11.: Marke Archiv session_01Hmoj76DJtggtnNPKMMxpU6 (lauf.py)
- 15:31 12.11.: Marke Archiv session_01Hmoj784tSBD77EZUv1K4o1 (lauf.py)
- 15:33 12.11.: Marke Archiv session_01Hmoj76marbMeLGds3T3ePv (lauf.py)
- 15:33 12.11.: Nachfolger-Warnung Tom (Übergabe 12.11., 15:30) (lauf.py)
- 15:56 12.11.: Marke Archiv session_01Hmoj761eAvyDy1MgdXkna1 (lauf.py)
- 15:56 12.11.: Marke Archiv session_01Hmoj78GqGrL8ULmt1No1zc (lauf.py)
- 16:05 12.11.: Marke Archiv session_01Hmoj75ZfDj3Zzs82FM18nF (lauf.py)
- 16:26 12.11.: Marke Rückmeldung 842 12.11. 16:24 (lauf.py)
- 16:26 12.11.: Marke Archiv session_01Hmoj75wdp9JocYHDDCfdun (lauf.py)
- 16:26 12.11.: Marke Archiv session_01Hmoj75iGtq9c9Q8reRo233 (lauf.py)
- 16:48 12.11.: Marke Archiv session_01Hmoj78KYFfF3h2fQVEitqa (lauf.py)
- 16:48 12.11.: Marke Archiv session_01Hmoj76DZ2CCSESfbp5Jwjh (lauf.py)
- 16:48 12.11.: Marke Archiv session_01Hmoj78konTZzkjhLux7ri7 (lauf.py)
- 18:04 12.11.: Marke Archiv session_01Hmoj77nTECTS8x8kwyj7ab (lauf.py)
- 19:04 12.11.: Marke Archiv session_01Hmoj79pyaMDLNugEQfUhrD (lauf.py)
- 19:04 12.11.: Marke Archiv session_01Hmoj75RkU4dWvyaMvQyaE4 (lauf.py)
- 20:50 12.11.: Marke Archiv session_01Hmoj78Ma2oqrpA3BFf8Ktx (lauf.py)
- 20:50 12.11.: Marke Archiv session_01Hmoj77FQvSoLtm2q28ecYk (lauf.py)
- 20:50 12.11.: Marke Archiv session_01Hmoj76TjZZB8xfGsLpG4q8 (lauf.py)
- 20:50 12.11.: Marke Archiv session_01Hmoj761D8ZDmMbL8YHbGzf (lauf.py)
- 20:57 12.11.: Marke Archiv session_01Hmoj76oFZoFEBnGQRKReMr (lauf.py)
- 21:10 12.11.: Marke Archiv session_01Hmoj78HZSSyRDb3Gaiur8D (lauf.py)
- 21:18 12.11.: Marke Archiv session_01Hmoj79xvpYioqm5WRyMud6 (lauf.py)
- 21:18 12.11.: Marke Archiv session_01Hmoj76UH4KUanhCv3PaVsR (lauf.py)
- 21:25 12.11.: Marke Mehrfach Sokrates (lauf.py)
- 21:25 12.11.: Marke Archiv session_01Hmoj78TftZKyaCdnhbgFaG (lauf.py)
- 21:51 12.11.: Marke Rückmeldung 867 12.11. 21:40 (lauf.py)
- 21:51 12.11.: Marke Archiv session_01Hmoj77p3xo2Lh4AJGbrWem (lauf.py)
- 21:51 12.11.: Marke Archiv session_01Hmoj77PijmyEaUrqCKUMZo (lauf.py)
- 21:51 12.11.: Marke Archiv session_01Hmoj77o4gpxMkFhcBeDkZo (lauf.py)
- 21:57 12.11.: Marke Archiv session_01Hmoj7ACzQBoUuxji6wbGku (lauf.py)
- 21:57 12.11.: Nachfolger-Warnung Jerry (Übergabe 12.11., 21:52) (lauf.py)
- 22:34 12.11.: Marke Abgleich Vorentscheid 1077 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 02:04 13.11.: Marke Stellungnahme Sokrates 13.11. (lauf.py)
- 03:03 13.11.: Marke Abgleich Vorentscheid-Bremse (194.1): 6 ungebilligt, 0 älter als 7 Ta (lauf.py)
- 04:04 13.11.: Marke Abgleich Vorentscheid-Bremse (194.1): 8 ungebilligt, 0 älter als 7 Ta (lauf.py)
- 05:31 13.11.: Nachfolger-Warnung Jerry (Übergabe 13.11., 05:29) (lauf.py)
- 06:04 13.11.: Marke Archiv session_01Hmoj79qGhEdjuvdUYbpj3h (lauf.py)
- 06:04 13.11.: Marke Archiv session_01Hmoj78CkDSPDMASL6K5Kd8 (lauf.py)
- 13:51 13.11.: Startsperre 13:51 Start Sokrates (Ford, Neustart-Meldung 5b10649b9, Nachfolger „Sokrates – 1129: Chefrunde blinde Flecken“; Hoch, effort high)
- 13:57 13.11.: Startsperre 13:57 Start Spike (Ford, Neustart-Meldung bf4222f84, Nachfolger „Spike – 882.1: Vergleichsbilder alt rendern“; Hoch, effort high)
- 13:58 13.11.: Startsperre 13:58 Start Tom (Ford, Neustart-Meldung f966d7dcb, Nachfolger „Tom – 284: Prüfliste und Testbitte nach Test 283“; Hoch, effort high)
- 14:30 13.11.: Startsperre 14:30 Start Sokrates (Ford, Neustart-Meldung b0e5869af, Nachfolger „Sokrates – 1137: Vollzug nachhalten“; Hoch, effort high)
- 07:04 13.11.: Marke Archiv-Warnung session_01Hmoj79qGhEdjuvdUYbpj3h (lauf.py)
- 07:04 13.11.: Marke Archiv session_01Hmoj7A1dnZnLGSEWvQkYYP (lauf.py)
- 07:14 13.11.: Marke Archiv session_01Hmoj79zmT5JwNzRZrw7FW2 (lauf.py)
- 08:04 13.11.: Marke Tagesbericht 13.11. (lauf.py)
- 08:04 13.11.: Marke Nachhalten 13.11. (lauf.py)
- 08:18 13.11.: Marke Archiv session_01Hmoj78o1EcVNksEbvzKHga (lauf.py)
- 08:51 13.11.: Marke Stellungnahme Sokrates 13.11. (lauf.py)
- 08:51 13.11.: Marke Archiv session_01Hmoj78PvRkTAsLPoGWG9we (lauf.py)
- 08:51 13.11.: Marke Archiv session_01Hmoj78nYhWJDwpTUKcGeBd (lauf.py)
- 09:04 13.11.: Startsperre 09:04 Start Tom, Perikles (lauf.py)
- 09:12 13.11.: Startsperre 09:12 Start Tom (Ford, Auftrag Sokrates 09:10 nach Chef-Test t281: 1104 eilt, dazu 1040.1; Hoch, effort high)
- 09:15 13.11.: Startsperre 09:15 Start Sokrates (Ford, Neustart-Meldung 99de65ca4, Nachfolger „Sokrates – Chefrunde (13.11.)“; Chef wartet; Hoch, effort high)
- 09:30 13.11.: Startsperre 09:30 Start Perikles (Ford, Auftrag Sokrates 09:30 nach Chef „1100 A mit 6“, Commit 9f65d917e; Hoch, effort high)
- 09:41 13.11.: Startsperre 09:41 Start Homer (Ford, Auftrag Sokrates 09:40 nach Chef „1108 A“, Commit 0ea8087d7; Hoch, effort high)
- 09:04 13.11.: Marke Start-fehlt Perikles 13.11.-08:51 (lauf.py)
- 09:04 13.11.: Marke Start-fehlt Tom 13.11.-07:14 (lauf.py)
- 09:40 13.11.: Startsperre 09:40 Start Diogenes, Spike, Tuffy (lauf.py)
- 09:45 13.11.: Startsperre 09:45 Start Diogenes (Ford, Auftrag Sokrates 09:45, Chef „Bitte, das ist wichtig“, Commit 9716c0200; Hoch, effort high)
- 09:55 13.11.: Startsperre 09:55 Start Tom (Ford, Neustart-Meldung ce0c788bf, Nachfolger „Tom – 282: neue APK ausliefern“; Hoch, effort high)
- 09:55 13.11.: Startsperre 09:55 Start Perikles (Ford, Nachfolger „Perikles – 1103: alte Bitte-Regel Kaufrepo streichen“ aus Übergabe 09:40, Neustart-Meldung 2330b0a6c; Hoch, effort high)
- 10:03 13.11.: Startsperre 10:03 Start Sokrates (Ford, Neustart-Meldung 3dc223570, Nachfolger „Sokrates – t282: Test Build 282 begleiten“; Chef wartet; Hoch, effort high)
- 09:40 13.11.: Marke Abgleich ganz 13.11. (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1090 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 492 ohne Datei in chefsache/billigen/ und ohne  (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1044 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 867 ohne Datei in chefsache/billigen/ und ohne  (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1090 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1044 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1022 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1044 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1022 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 842 ohne Datei in chefsache/billigen/ und ohne  (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1022 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1084 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1085 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Start-fehlt Diogenes 13.11.-08:51 (lauf.py)
- 09:40 13.11.: Marke Archiv session_01Hmoj75T84v7wSUd4hP2WrG (lauf.py)
- 10:04 13.11.: Startsperre 10:04 Start Tuffy (lauf.py)
- 10:04 13.11.: Marke Start-fehlt Homer 13.11.-09:41 (lauf.py)
- 10:04 13.11.: Marke Start-fehlt Spike 13.11.-09:40 (lauf.py)
- 10:04 13.11.: Marke Start-fehlt Tuffy 13.11.-09:40 (lauf.py)
- 10:58 13.11.: Startsperre 10:58 Start Jerry, Diogenes, Perikles, Spike (lauf.py)
- 10:58 13.11.: Marke Start-fehlt Tuffy 13.11.-10:04 (lauf.py)
- 10:58 13.11.: Marke Archiv session_01Hmoj78DdYVvVkuejug4vVj (lauf.py)
- 11:05 13.11.: Startsperre 11:05 Start Ford (Probe D: Routine mit create_new_session_on_fire, 1098 A; Neustart-Haken 407 Tsd.; Umgebung Hoch)
- 11:08 13.11.: Probe D gescheitert (Sitzung ohne Repo, ohne create_session und list_sessions; Zu 1098 bei Perikles); Startsperre 11:08 Start Ford (selbst, Neustart-Haken 407 Tsd.)
- 11:11 13.11.: Startsperre 11:11 Start Spike (lauf.py; Tuffy 1112 nicht gestartet, Jerry arbeitet 1111–1113 laut Titel)
- 11:11 13.11.: Marke Start-fehlt Spike 13.11.-10:58 (lauf.py)
- 11:38 13.11.: Startsperre 11:38 Start Tom, Jerry, Diogenes, Perikles, Spike (lauf.py)
- 11:38 13.11.: Marke Start-fehlt Spike 13.11.-11:27 (lauf.py)
- 11:38 13.11.: Marke Archiv session_01Hmoj77p2DyGeBsYtiDvhmm (lauf.py)
- 11:38 13.11.: Marke Archiv session_01Hmoj79TvopboM55dekntoq (lauf.py)
- 11:38 13.11.: Marke Archiv session_01Hmoj783GT8HqsUa9oPkwbz (lauf.py)
- 11:38 13.11.: Marke Archiv session_01Hmoj75ViqKifXCifqcMLwp (lauf.py)
- 11:38 13.11.: Marke Archiv session_01Hmoj79CkF3dd8LaaHJrqyb (lauf.py)
- 11:41 13.11.: Startsperre 11:41 Start Sokrates (Neustart-Meldung 475ac67ba, Nachfolger „Sokrates – t282: Höhlen-Nachtest begleiten“; Hoch)
- 11:58 13.11.: Startsperre 11:58 Start Tom (Neustart-Meldung 661c1fefc, Nachfolger „Tom – 283: Sammelbuild“; Hoch)
- 12:04 13.11.: Marke Archiv session_01Hmoj76bi2dhnXLC43LUzuG (lauf.py)
- 12:04 13.11.: Marke Archiv session_01Hmoj78EvBobSYTXdaNQzkv (lauf.py)
- 12:08 13.11.: Startsperre 12:08 Start Sokrates (Neustart-Meldung 9a9f062bf, Nachfolger „Sokrates – 1128: Prüfumfang, zweite Meinung Perikles“; Hoch)
- 12:40 13.11.: Startsperre 12:40 Start Jerry (Neustart-Meldung 43088ea54, Nachfolger „Jerry – 1036.1: Filme Zustände an den Chef“; Hoch)
- 12:54 13.11.: Startsperre 12:54 Start Diogenes (lauf.py)
- 12:54 13.11.: Marke Archiv session_01Hmoj776UuCBT9zDUv51f75 (lauf.py)
- 12:54 13.11.: Marke Hängt session_01Hmoj799ZkNaijAJMrQQjx9 2026-11-13T10:37 (lauf.py)
- 12:56 13.11.: Startsperre 12:56 Start Sokrates (Neustart-Meldung 78c5b453e, Nachfolger „Sokrates – 1129: Systemprüfung blinde Flecken“; Hoch)
- 12:56 13.11.: Marke Mehrfach Sokrates (lauf.py)
- 12:58 13.11.: Startsperre 12:58 Start Perikles (Neustart-Meldung ee2b7ced6, Nachfolger „Perikles – 1129.1: Systemprüfung Abläufe“; Hoch)
- 13:05 13.11.: Marke Archiv session_01Hmoj78stBJJXqscNXjZ3CZ (lauf.py)
- 13:05 13.11.: Marke Mehrfach Perikles (lauf.py)
- 13:05 13.11.: Marke Hängt session_01Hmoj78Rf6zNyPd2bCm6EA8 2026-11-13T11:00 (lauf.py)
- 13:06 13.11.: Startsperre 13:06 Start Spike (lauf.py)
- 13:06 13.11.: Marke Archiv session_01Hmoj78Rf6zNyPd2bCm6EA8 (lauf.py)
- 13:14 13.11.: Startsperre 13:14 Start Tom, Diogenes, Tuffy (lauf.py)
- 13:14 13.11.: Marke Archiv session_01Hmoj76bbLaz4LJWHhQXzfw (lauf.py)
- 13:14 13.11.: Marke Archiv session_01Hmoj79VVZowWdN4VDhUTeW (lauf.py)
- 13:19 13.11.: Startsperre 13:19 Start Ford (selbst, Neustart-Haken 406 Tsd., kein Starter; Hoch)
- 13:22 13.11.: Startsperre 13:22 Start Perikles (lauf.py)
- 13:39 13.11.: Startsperre 13:39 Start Diogenes (lauf.py)
- 13:39 13.11.: Marke Archiv session_01Hmoj78sdHzWGZw61LAUAjP (lauf.py)
- 13:46 13.11.: Startsperre 13:46 Start Perikles (lauf.py)
- 13:46 13.11.: Marke Archiv session_01Hmoj79AYXzXxbEysheXSSM (lauf.py)
- 13:55 13.11.: Startsperre 13:55 Start Jerry (lauf.py)
- 13:55 13.11.: Marke Archiv session_01Hmoj79PqkAM8htH3aENfQU (lauf.py)
- 13:55 13.11.: Marke Archiv session_01Hmoj76XW2S2RSWpmgfQiue (lauf.py)
- 14:10 13.11.: Startsperre 14:10 Start Diogenes, Perikles, Tuffy (lauf.py)
- 14:10 13.11.: Marke Archiv session_01Hmoj78LUomV3gY1qNRdSe2 (lauf.py)
- 14:10 13.11.: Marke Archiv session_01Hmoj792Q9BLanCtiMoaCsQ (lauf.py)
- 14:10 13.11.: Marke Archiv session_01Hmoj76uwtqjKezwuFGaC2j (lauf.py)
- 14:10 13.11.: Marke Archiv session_01Hmoj79V13ud4srAyFcA7Gf (lauf.py)
- 14:10 13.11.: Marke Archiv session_01Hmoj765owYWUUNb8HS1ekh (lauf.py)
- 14:51 13.11.: Startsperre 14:51 Start Diogenes, Spike (lauf.py)
- 14:51 13.11.: Marke Archiv session_01Hmoj79pjCAyCS5phwcjMAq (lauf.py)
- 14:51 13.11.: Marke Archiv session_01Hmoj76zsZtPcMeUXunfjXE (lauf.py)
