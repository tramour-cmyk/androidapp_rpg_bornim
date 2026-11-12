# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten buchen ohne Satz des Chefs, dauerhaft; alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss: `--ohne 506.2:Tuffy nur auf Chef-Wort --ohne M?:Planfehler Klasse als Vorgang (893) --ohne 492:hängt an 870.4 (Tom), Spike ohne Arbeit beendet --ohne 771:erledigt --ohne 901:gebaut` (771/901 entfallen, sobald Diogenes/Perikles den Stand setzen). Tom hat Wecker 08:38 (Lauf 338): `WEITER Tom` nicht ausführen, solange er läuft. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1039** (zuletzt 1038 Sokrates 12.11. 14:58:14 efa7) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (von Sokrates, Chef 07.11., 20:2x: „So, dann alle Sperren aufheben. Alle können arbeiten, aber von der Priorität her bitte erstmal wieder Fehlerbehebung.“):** Sparbetrieb (23.10.), 468a, „Weiter mit Wächter“, Stopp Durchläufe (29.10.) gestrichen; alle Rollen startbar. **Vorrang:** zuerst Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1), dann 478 und die Proben 623.5, 623.6, dann der Rest. Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Bild Chef 11.11., 07:11 (an Sokrates, ohne Text):** Woche 0 % (vorher 43 % Di früh; Wochenlimit mitten in der Woche zurückgesetzt), Zurücksetzung weiter Sa 14.11., 20:00; tragbar bis dahin ≈ 1,2 %/h (85 h), bisheriges Tempo 0,71 %/h trägt; Nutzungsguthaben an, 0 Credits; Angebot „Kostenlos zurücksetzen“ (läuft ab 9. März) zur Zeit nicht verfügbar · **Bild Chef 10.11., 06:59 (an Sokrates, von Perikles eingetragen, `chefsache/bilder/826-nutzung.webp`):** Woche 43 %, Tempo ≈ 0,71 %/h, tragbar ≈ 0,52 %/h, so Freitagnachmittag leer; 826 beim Chef · **08.11., 20:42 (Ford, aus `rate_limit_info` der Sitzung):** Woche (`seven_day`) steht auf `allowed_warning`; ab jetzt `lauf.py --nur-muss` (D20.2, 287), Kür startet nicht · **Bild Chef 08.11., 08:44 (an Sokrates, von Sokrates eingetragen):** Woche 10 % nach etwa 12,7 h (Zurücksetzung Sa 07.11., 20:00; nächste Sa 14.11., 19:59), Sitzung 1 %, App: „Bei diesem Tempo wird dein Limit Donnerstagnacht aufgebraucht sein“; Tempo ≈ 0,8 %/h, tragbar wären ≈ 0,58 %/h (etwa ein Viertel weniger); Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (12.11., 06:10, `session_01Hmoj78nzFY1f9C4CFvo5q3`, Selbstneustart wegen Neustart-Haken 1, 208 Tsd. Token):** Alle Starts, Archivierungen und Kosten bis 06:09 erledigt. Laufen (effort high, je Rolle eine): Tom …78ovK2dE9B3u77pw3E (968/1012 Build 277/278, Lauf 370), Jerry …79CS9LVAhotYsqmwgb (999.1, Kür), Homer …77crGw2i1MbQ6VpK2F (1015), Perikles …75W8e6YMkpd4gxoni7 (1011 gebaut, ruht, ohne Arbeit), Diogenes …76MeSi8FRUmYKBjQmL (1010, ruht), Tuffy …7AAdH3XpmB1bRL6xNn (1007, ruht), Sokrates …79B6X93sR9q3p1JjCA (Nachtrunden, Weckruf Lagebild `trig_012yyTjZLeDjZ2VXg5iQ6voU` 06:50 auf dieser Sitzung). Stundenuhr „Ford-Lauf“ neu anlegen wie beim Start (`create_trigger`, `persistent_session_id` = eigene Kennung, `3 * * * *`, Nachricht „Ford-Lauf“; alte `trig_0197UJNZbUmhgLEbgB4rnW6B` löschen); den alten Ford …78nzFY1f9C4CFvo5q3 archivieren (frische Kosten aus `get_session` auf „Betrieb“ buchen). Der Prüfer lehnt `archive_session` für den Vorgänger-Ford …77yaxGquVhCGzNXGan zweimal ab (Auto-Modus), er steht idle: einmal neu versuchen, sonst lautlos in Laufbericht erwähnen. Nur offen: ARBEIT-BETRIEB.md 57 KB (Protokoll 34 KB, Kopf 24 KB), nie bereinigt, Perikles nach Pflege fragen. 1014 (Jerry, schild_406 ParryLow) wartet auf Chefsache 863a: keinen leeren Start. Kosten mehrerer Vorgänge nur auf einen buchen (Verzeichnis bucht nur Differenz je Sitzung). Kurzzeilen-Datei: `list_sessions` mit `limit` 9 genügt (sonst `has_more`), nicht archivierte Zeilen von Hand um Sokrates, Tuffy, Homer ergänzen, falls nicht in den Seiten; Lauf-Aufruf (Kurzzeilen-Datei aus `list_sessions` mit `limit` 12, nur nicht archivierte, `# has_more: nein`; `--wecker` = Kennungen aus `list_triggers` mit offenem Weckruf: Ford, Sokrates, ggf. Jerry) aus `/home/user/bornim-main/tools`: `python3 lauf.py --sperre --besetzung <Datei> --wecker <ids> --ohne "506.2:Tuffy nur auf Chef-Wort" --ohne "M?:Planfehler Klasse als Vorgang (893)" --ohne "492:hängt an 870.4 (Tom), Spike ohne Arbeit beendet" --ohne "771:erledigt" --ohne "901:gebaut" --ohne "861:Tom in Arbeit (Filmlauf 367)" --ohne "831:Tom in Arbeit (Ersatzlauf Wald)"`; Wächter und Abgleich-Warnungen nachts lautlos. Jede ARCHIVIERE-Zeile ausführen, aber nur bei `idle` (läuft die Sitzung noch: im nächsten Lauf; `sleep` ist gesperrt); Kosten mit `lauf.py --kosten <Nr,Nr> <USD> <Kennung>` (USD frisch aus `get_session` oder der Archiv-Ausgabe). Neustart-Meldungen (Tom, Jerry, Tuffy, Sokrates alle 25 bis 45 Minuten): Commit auf `origin/main` und „Nachfolger:“ prüfen, Startsperre als Protokollzeile, pushen, `create_session` mit Hoch/effort high, `outcome_branch`, `source_url`/`source_revision`, `append_system_prompt` (Du bist <Rolle>, Auftrag kommt von Ford, 853); ist der Nachfolger nicht startbar (wartet), keinen leeren Start, alte Sitzung nur archivieren; nicht wiederkehrende Weckrufe der alten Sitzung (`list_triggers`) auf die neue legen. Chef schläft, nachts (22–7 Uhr) keine Meldung mit Ton; Sokrates hält die Nacht und ein Lagebild 06:50. Offen beim Chef: 863a (Kaufmodelle freigeben oder Messlauf) und 264 (Sokrates), nichts von Ford. Nachfolger: Ford – Betriebsleiter
- **Ford lebt in einer Sitzung** (Stand 12.11., 07:30: Ford `session_01Hmoj765JvmMM81VAZ94ovn` ab 07:26, vom Chef von Hand gestartet, Tiefe 0; Vorgänger …7A2D1aaNLiWrXiyDk2 06:12 bis 07:29, archiviert, Kosten gebucht). Stundenuhr „Ford-Lauf“ `trig_01MeDTmrJuZixAwuEHKSx3yq` (:03) gehört dieser Sitzung; die alte ist gelöscht. Archivieren der Vorgänger …78nzFY1… (06:13, Kosten 3,08 $ gebucht) und …77yaxG… vom Berechtigungsprüfer abgelehnt („Interfere With Workloads“), beide stehen idle. Archivieren sonst ohne Einwand (Regel oben). Nachfolger laufen mit effort high (Kennungen in der Übergabe).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).

## Eingang

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

- 14:28 12.11.: Start-Meldung Tom 14:24 „Start Perikles 1033“ (f7278a318, auf main; 1033 Perikles-Muss „passt“ statt „richtig“ in den Prüflisten): geprüft, Perikles …78GqGrL8ULmt1No1zc mit echtem Auftrag 1033 gestartet (statt leerem Nachfolger „Ford ruft“); Tuffy …75jovTr8zStqpmnEsx (1031, Chef-Fund 14:08 ganzer Bericht ohne Farben). Archiviert und gebucht: Perikles 448 …7A2JDffJnrk5Dagztc (5,80 $), Tuffy 644a.1 …79xewvr4yXDaxRRApX (16,19 $).
- 14:08 12.11.: Lauf 14:04: nichts gestartet (Tom 1030, Jerry 995, Spike 756 laufen; Perikles-START „Perikles – (Ford ruft)“ ohne Auftrag, neunter Lauf; Homer, Tuffy, Sokrates, Diogenes ruhen ohne Vorrat). Keine roten Läufe.
- 13:58 12.11.: Start-Meldung Sokrates 13:54 „Start Tom 1030“ (c226fe4, auf main; Chef 13:53 im Test von Build 280, Rückläufer zu 1020.1, Sperre gilt nicht): geprüft; nach Chef-Test 870.7 fiel die Sperre 620.1 B auf 38. Gestartet: Tom …79GnLFqxJnZ3kPVf75 (1030 statt lauf.py-Zeile 764, Vorrang Chef-Fund), Jerry …76DJtggtnNPKMMxpU6 (995), Spike …784tSBD77EZUv1K4o1 (756). Spike 644a.2 …77hd1skjBoRKtk6Sz7 archiviert (7,59 $ gebucht). Perikles-START ohne Auftrag nicht ausgeführt.
- 13:35 12.11.: Meldung Sokrates 13:32 (Lauf 380 rot: schalter_1024 neu, wolf_mess_438 bekannt; Jerry-Vorgang und Start erbeten): Lauf 380 geprüft (failure, claude/build-280); Vorgang 1029 „schalter_1024 rot“ besteht schon (Tom), startbar bei Jerry, aber Sperre 620.1 B (41 ungetestete Muss) hält Jerry: kein Start, `lauf.py` gibt nur Kür „Pflege“ aus. Alte Tom-Warnung „Start Tom nicht angekommen“ ist Fehlalarm (Tom 814 archiviert). Sokrates-Arbeitskopie im Rebase: seine Sache, Chef entscheidet.
- 13:12 12.11.: Neustart-Meldung Tom (47e4505bb, auf main): Nachfolger „Tom – 644a.2: Weg zum Grundwert im Reiter Test“ wartet auf Test Build 280, nichts Startbares: kein Start; Tom …RSQPRph1aFEc31hY archiviert (25,06 $ auf 1027 gebucht). Tom startet wieder nach dem Test von Build 280.
- 13:08 12.11.: Lauf 13:04: nichts gestartet (Tom belegt: Wecker Build 280, Übergabe 12:21; Jerry nur Kür, Perikles ohne Auftrag). Keine Archivierung. Läufe: keine roten (build-280: Läufe 378/379 von Tom abgebrochen, Neustart von Hand 12:24).
- 12:20 12.11.: Start-Meldung Tom 12:18 „Start Sokrates 1028“ (f8ebd2a18, t280 gegenlesen): Commit geprüft, 1028 Sokrates-Muss startbar, aber Sokrates startet Ford nie aus dem Vorrat (Rollendatei, LISTE-BETRIEB 41): `lauf.py --liegt` gibt keinen START Sokrates; nicht gestartet, Chef lautlos informiert (Sokrates auf Zuruf).
- 12:08 12.11.: Lauf 12:04: nichts gestartet. Ausgeschlossen mit Grund: 1027 (Tom: „1027 in Arbeit“ 11:56, Spike-Start wäre doppelt); Jerry-START „Pflege“ (Kür, Nachfolger 1025 durch Sperre 620.1 B), Perikles-START ohne Auftrag (fünfter Lauf). Keine Archivierung: Spike 644a.2, Tuffy 644a.1, Homer 1026, Sokrates ruhen ohne Nachfolger.
- 11:30 12.11.: Start-Meldung Homer 1026 (a42645af9, von Spike 644a.2 gebaut auf claude/tom-644a-tragen): Homer-Muss geprüft, Homer …75wdp9JocYHDDCfdun „Homer – 1026“ gestartet; Homer 1015 …77crGw2i1MbQ6VpK2F archiviert (5,79 $ gebucht). Nicht ausgeführt: Jerry-START „Pflege“ (Kür, Tom/Jerry ohne Kür), Perikles-START ohne Auftrag.
- 11:13 12.11.: Neustart-Meldung Jerry (47f195ad2, auf main): Nachfolger „Jerry – 1025“ nicht startbar (Sperre 620.1 B, 41 ungetestete Muss), übrig nur Kür „Pflege“ (Tom/Jerry ohne Kür bis B2): kein Start; Jerry …79CS9LVAhotYsqmwgb archiviert (18,02 $ auf 999.1 gebucht). Freigabe-Abfrage 10:29 hat sich erledigt (Jerry übergab selbst). Jerry startet wieder nach Test Build 279.
- 11:10 12.11.: Lauf 11:04: gestartet Tom …76RSQPRph1aFEc31hY (814), Spike …77hd1skjBoRKtk6Sz7 (644a.2, nach 644a.1 von Tuffy), Sokrates …76oRjGDjaHKeRYBhmv (Stellungnahme 644b); archiviert und gebucht: Tom 1012 (40,08 $, Build 279 zum Test beim Chef, Ergebnis läuft über Automatik B), Spike 1022 (4,01 $, Bilder in Chefsache), Sokrates (22,30 $ auf Betrieb). Nicht ausgeführt: START Perikles ohne Auftrag (dritter Lauf). WARNUNG-LAUT: Jerry …79CS9LVAhotYsqmwgb blockiert seit 10:29 an einer Freigabeabfrage (git rebase --continue in bornim-main), 422 Tsd. Token. Keine drei roten Läufe in der Stunde.
- 10:27 12.11.: Neustart Spike (Meldung 55901b2ed): Nachfolger …79xdwrf62nTsP2VsKv „Spike – 1022: Kartenrand, Test und Bildpaar“ gestartet; Vorgänger …78uJWKigZFnt8v3NJj archiviert (6,09 $ auf 1022 gebucht)
- 10:09 12.11.: Lauf 10:04: Spike …78uJWKigZFnt8v3NJj (1022 Kartenrand) und Tuffy …79xewvr4yXDaxRRApX (644a.1 Rechnung Beutestufe) gestartet; Spike 612 (7,09 $) und Tuffy 1020.2 (9,97 $) archiviert, gebucht. Ausgeschlossen mit Grund: 814 (Tom arbeitet, Zu 814 08:55), 644a.2 (folgt auf 644a.1), 1020.1 (Tom), Perikles-START „Perikles – (Ford ruft)“ ohne Auftrag (zweiter Lauf, Nachricht an Perikles).
- 09:10 12.11.: Lauf 09:04: Spike …766LSe7nDcgDZoGn2r (612, Tom-Muss Dorf Süd) gestartet; Spike 1021 …79rReQeD9gdL8Prmpp archiviert (4,57 $ gebucht). Nicht ausgeführt mit Grund: START Perikles „Perikles – (Ford ruft)“ (Übergabe ohne Auftrag, Planfehler an Perikles in den Vorrat); START Spike 1020.1 (Tom baut daran auf claude/tom-1020-pruefliste, Build 279 ist Toms). Keine roten Läufe.
- 08:16 12.11.: Auftrag Perikles 08:13 (Diogenes 1019, Prüfzeile 57f798597) geprüft und ausgeführt: Diogenes …75ZfDj3Zzs82FM18nF; dazu Spike …79rReQeD9gdL8Prmpp (1021, Tom-Muss „jetzt“ 08:09), Tuffy …77GZt45MJ7mkLqnBfm (1020.2, Jerry-Muss „jetzt“ 08:09); alt archiviert: Diogenes 1010 (1,05 $ gebucht), Tuffy 1007 (3,52 $ schon gebucht)
- 08:07 12.11.: Lauf 08:04: Perikles Tagesbericht gestartet (…7A2JDffJnrk5Dagztc, Aufwand Hoch); Perikles 1016 …79nhucTfp4jACfXVtR archiviert (2,08 $ gebucht). Ausgeschlossen mit Grund: 863 (Jerry arbeitet, Stand „in Arbeit“, Tuffy-Start wäre doppelt), 1016 (erledigt, Nachfolger „1016 schließen“ hinfällig); Perikles-Kür 1019 nicht zusätzlich gestartet (eine Perikles-Sitzung). Nachhalten: Eingang mit Einträgen bis 09.11. unbeantwortet, Vorrat 59 KB, lautlos an Perikles. Keine roten Läufe, PR #197 (Build 278) offen.
- 07:30 12.11.: Ford-Start von Hand (Vorgang 1016): Uhr „Ford-Lauf“ neu auf Sitzung …765JvmMM81VAZ94ovn, alter Ford …7A2D1aaNLiWrXiyDk2 archiviert (Kosten 1,33 $ gebucht, lauf.py); Lauf: nichts startbar, Tom/Jerry/Perikles belegt
- 07:30 12.11.: Satz des Chefs erhalten (Archivieren in Fords Sitzung …765JvmMM81VAZ94ovn erlaubt, Chef im Chat)
- 03:34 12.11.: Neustart Jerry (d2ed1c7ed): Nachfolger …76Jm4cH6LxoNHpwumz "Jerry – 988: Messlauf auswerten" (Hoch, effort high); Jerry alt …76pv2KzamLon3bW7BJ (8,80 $ auf 988) und Tom alt …75vW6xAmcrgnBDZe1D (11,82 $ auf 968, 831, 861) archiviert und gebucht.
- 03:23 12.11.: Neustart-Meldung Tom (b836cc1a5, Nachfolger "Tom – 968: Build 277 nach 988 zusammenführen"): 968 wartet auf 988 (Jerry, Messlauf braucht Sokrates' "988, Läufe frei"), nicht startbar, Tom alt …75vW6xAmcrgnBDZe1D lief 03:21 noch (working, 8,48 $ aus get_session, auf 968, 831, 861). Kein leerer Nachfolger; im Lauf 04:03 Tom alt archivieren und buchen, Start per lauf.py, sobald 968 startbar.
- 22:51 11.11.: Startsperre 22:51 Start Tom (Neustart-Meldung 22:50, 7bcbfa5fd; Nachfolger „Tom – 861: Umhang Lauf 361 auswerten und an den Chef“; Hoch, effort high). Nachfolger …78ScPpEgC4rehT6joh (Hoch, effort high bestätigt). Tom alt …77TqYPPzSwWJnxFKxV im Lauf 23:03 archiviert, 5,35 $ auf 861 (4,30 $ gebucht, Rest unerheblich). Lauf 23:03 sonst ohne Start. Tuffy alt …75pArUXB 22:50 archiviert (idle seit 22:20, Übergabe trägt den Film Lauf 360), 16,21 $ auf 935, 806, 595 gebucht.
- 22:22 11.11.: Startsperre 22:22 Start Tom (Neustart-Meldung 22:20, 561c14760; Nachfolger „Tom – 861: Umhang Lauf 361 auswerten und an den Chef“; Hoch, effort high). Nachfolger …77TqYPPzSwWJnxFKxV in Hoch, effort high bestätigt. Tom alt …79GVxrKixe6uTkXCwC 22:21 archiviert, 13,18 $ auf 861, 814 gebucht.
- 22:20 11.11.: Startsperre 22:20 Start Tuffy (Neustart-Meldung 22:16, b0542ae5c, über Ford alt; Nachfolger …76BcT3Ctma47E7XfWo „Tuffy – 935: Wurffilm an den Chef, dann 620.2c: Abgleich alter Kampffunde“; Hoch, effort high bestätigt). Tuffy alt …75pArUXB bleibt bis Film Lauf 360 (22:58) draußen.
- 20:18 11.11.: Neustart Sokrates (1996764d9, Meldung 20:15): Nachfolger …77wAbZbpfR8HuHEyBs „Sokrates – 644“ in Hoch (effort high bestätigt) gestartet; Sokrates alt …784tB meldete 20:16 „zurückstellen, Chef testet Build 277“ (865), kam zu spät. Beide Sokrates-Sitzungen offen; `archive_session` vom Prüfer abgelehnt (20:18, auch für den neuen, ohne Arbeit). Alt …784tB (7,06 $ auf 952, 984, 976a, 644) bleibt bis nach dem Test, ungebucht. Startsperre 20:17 Start Sokrates (Neustart-Meldung 20:15, 1996764d9; Umgebung Hoch, effort high)
- 21:35 11.11.: Startsperre 21:35 Start Tuffy (Neustart-Meldung 21:33 über Ford alt, 485f7d9ec; Umgebung Hoch, effort high)
- 21:22 11.11.: Neustart Tom (41bfd709e): Nachfolger …79GVxrKixe6uTkXCwC „Tom – 861: Umhangbuckel im Filmlauf nachstellen“ in Hoch (effort high bestätigt) gestartet; Tom alt …79s2racTNcB2PH4azG lief 21:21 noch (nicht archivierbar, Kosten offen, Archivierung vom Prüfer ohnehin abgelehnt). Startsperre 21:21 Start Tom (Neustart-Meldung 21:20, 41bfd709e; Umgebung Hoch, effort high)
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
- 16:42 11.11.: Startsperre 16:42 Start Jerry (lauf.py)
- 16:42 11.11.: Nachfolger-Warnung Jerry (Übergabe 11.11., 16:37) (lauf.py)
- 16:54 11.11.: Startsperre 16:54 Start Tom, Spike (lauf.py)
- 16:54 11.11.: Nachfolger-Warnung Tom (Übergabe 11.11., 16:20) (lauf.py)
- 17:17 11.11.: Startsperre 17:17 Start Homer, Perikles (lauf.py)
- 17:17 11.11.: Marke Hängt session_01Hmoj77p8Rmr44hM83piNXt 2026-11-11T15:05 (lauf.py)
- 17:25 11.11.: Startsperre 17:25 Start Diogenes (lauf.py)
- 17:39 11.11.: Startsperre 17:39 Start Jerry (lauf.py)
- 17:39 11.11.: Marke Hängt session_01Hmoj76zbgeXCxcMyns2Ume 2026-11-11T15:35 (lauf.py)
- 18:04 11.11.: Startsperre 18:04 Start Tom (lauf.py; nicht ausgeführt: Tom …79Kfy wartet auf die APK von Build 277, Weckruf 18:30, Übergabe 968 liegt bei ihm; lauf.py wollte ihn archivieren und Tom 785 starten)
- 18:04 11.11.: Marke Archiv session_01Hmoj79KfyC4R5VU2zspRQS (lauf.py)
- 18:05 11.11.: Startsperre 18:05 Start Perikles (lauf.py)
- 18:46 11.11.: Startsperre 18:46 Start Spike (Ford, vor dem Start; Neustart-Meldung 56da65617, effort high, Vorgang 856 vor 785.19 nach Vorrang)
- 18:28 11.11.: Startsperre 18:28 Start Jerry (Ford, vor dem Start; Meldung Ford alt 18:28, Sokrates gab 595 frei, effort high)
- 18:24 11.11.: Startsperre 18:24 Start Tuffy (Ford, vor dem Start; Neustart-Meldung 058507b24, effort high)
- 20:07 11.11.: Startsperre 20:07 Start Ford (selbst; Neustart-Haken 295 Tsd. Token, Erinnerung 2)
- 18:25 11.11.: Startsperre 18:25 Start Ford (selbst; Aufwand Hoch, Meldung Perikles 18:19: meine Sitzung lief auf „medium“)
- 19:59 11.11.: Startsperre 19:59 Start Jerry (Ford, vor dem Start; Neustart-Meldung 7cbd100b3, effort high)
- 19:17 11.11.: Startsperre 19:17 Start Sokrates (Ford, vor dem Start; Neustart-Meldung 8717da33a, effort high)
- 19:11 11.11.: Startsperre 19:11 Start Tuffy (Ford, vor dem Start; Neustart-Meldung e9cf56384, effort high)
- 18:21 11.11.: Startsperre 18:21 Start Spike, Sokrates (Ford, vor dem Start; Neustart-Meldungen 18:14 und 18:17, effort high)
- 18:11 11.11.: Startsperre 18:11 Start Diogenes (Ford, vor dem Start; lauf.py wollte zusätzlich Tom und Spike austauschen, siehe Zeile 18:11 oben)
- 19:04 11.11.: Startsperre 19:04 Start Diogenes, Homer (lauf.py)
- 19:04 11.11.: Marke Archiv session_01Hmoj78zGtqqjx8wVLTcmkh (lauf.py)
- 19:04 11.11.: Marke Archiv session_01Hmoj75Px5DBbDEapgv3HxB (lauf.py)
- 19:04 11.11.: Marke Archiv session_01Hmoj76zbgeXCxcMyns2Ume (lauf.py)
- 19:04 11.11.: Marke Archiv session_01Hmoj79gy8P4Xmvf1C2kLEA (lauf.py)
- 20:05 11.11.: Startsperre 20:05 Start Spike (lauf.py)
- 20:05 11.11.: Marke Start-fehlt Spike 11.11.-18:46 (lauf.py)
- 20:58 11.11.: Startsperre 20:58 Start Tom, Spike (lauf.py)
- 20:58 11.11.: Marke Archiv session_01Hmoj77wAbZbpfR8HuHEyBs (lauf.py)
- 20:58 11.11.: Marke Archiv session_01Hmoj787nZJu6kb6YnsBt62 (lauf.py)
- 20:58 11.11.: Nachfolger-Warnung Tom (Übergabe 11.11., 19:13) (lauf.py)
- 22:04 11.11.: Startsperre 22:04 Start Jerry, Spike (lauf.py)
- 22:04 11.11.: Marke Hängt session_01Hmoj75z7Peb3nnb3Mn3EMZ 2026-11-11T19:17 (lauf.py)
- 22:04 11.11.: Marke Start-fehlt Spike 11.11.-20:58 (lauf.py)
- 22:04 11.11.: Marke Archiv session_01Hmoj75z7Peb3nnb3Mn3EMZ (lauf.py)
- 22:14 11.11.: Startsperre 22:14 Start Sokrates (Neustart-Meldung 22:13, b55a9a9a3, „Sokrates – Nacht: Betrieb im Blick, Bauläufe hängen“; Umgebung Hoch, effort high); Sokrates alt …77wAb archiviert (22:14), 13,60 $ auf 644 gebucht
- 22:17 11.11.: Startsperre 22:17 Start Ford (selbst)
- 23:04 11.11.: Marke Archiv session_01Hmoj77TqYPPzSwWJnxFKxV (lauf.py)
- 23:48 11.11.: Startsperre 23:48 Start Jerry (Neustart-Meldung 23:47, de6e95ea6; Nachfolger …7A3Uv1wQxh44QKmFGc „Jerry – 988: rote Prüftests (wolf_mess_438)“; Hoch, effort high bestätigt). Jerry alt …76NLMvq9jNtnLrmxom lief 23:48 noch: im Lauf 00:03 archivieren und auf 833 buchen. Tom alt …78ScPpEgC4rehT6joh 23:48 archiviert, 9,73 $ auf 861, 954.2 gebucht.
- 23:33 11.11.: Startsperre 23:33 Start Tom (Neustart-Meldung 23:33, efa09a9b4; Nachfolger …77m67VFcXPeA7kSXqt „Tom – 861: Modellstand 656 prüfen, Umhang beheben“; Hoch, effort high bestätigt). Tom alt …78ScPpEgC4rehT6joh lief 23:33 noch: im Lauf 00:03 archivieren und auf 861, 954.2 buchen.
- 23:30 11.11.: Startsperre 23:30 Start Homer, Spike (lauf.py). Lauf 23:30 (Tom-Meldung 23:29: Homer 954.2): Homer …7882hJCzdqb8SLvPZz „Homer – 954.2“ und Spike …77Z838grLETgmwhtMt „Spike – 963“ in Hoch, effort high bestätigt, gestartet; Homer alt …798PZ (986, 5,20 $) und Spike alt …78Chk52 (814, 9,61 $) archiviert und gebucht; GELÖST 861 an Tom.
- 23:30 11.11.: Marke Archiv session_01Hmoj798PZHPo2cEXLJVxaZ (lauf.py)
- 23:30 11.11.: Marke Archiv session_01Hmoj78Chk526NpZcAaA2PN (lauf.py)
- 00:22 12.11.: Startsperre 00:22 Start Ford (selbst). Neustart-Haken 2 bei 293 Tsd. Token, Übergabe in dieser Datei.
- 00:21 12.11.: Startsperre 00:21 Start Tuffy (Neustart-Meldung 00:20, cc516bf91; Nachfolger …76CayzJH3pKHwcqVjq „Tuffy – 935: Wurfprüfung rot im Lauf (1,8 m)“; Hoch, effort high bestätigt). Tuffy alt …76BcT3Ctma47E7XfWo archiviert, 28,28 $ auf 935, 620.2c, 952 gebucht.
- 00:14 12.11.: Startsperre 00:14 Start Jerry (Neustart-Meldung 00:13, 93609bbd6; Nachfolger …75hgRbHuDP5JyfDGz2 „Jerry – 993: Arkanpfeil und Ring hakelig“; Hoch, effort high bestätigt). Jerry alt …7A3Uv1wQxh44QKmFGc lief 00:14 noch: im Lauf 01:03 archivieren und auf 988 buchen. Spike …7667YeBDQoVo4PDtp2 auf 635 umgelenkt (976 wartet laut Tom auf 870.13, 966.2).
- 00:03 12.11.: Startsperre 00:03 Start Spike (lauf.py). Lauf 00:03: Spike …7667YeBDQoVo4PDtp2 „Spike – 976“ in Hoch, effort high bestätigt, gestartet; Spike alt …77Z838 (963, 2,54 $) und Jerry alt …76NLMvq (833, 15,02 $) archiviert und gebucht. Homer …7882hJ („Homer – 954.2“) ruht ohne offenen Vorgang (766 am 13.11., 08:00).
- 00:03 12.11.: Marke Mehrfach Jerry (lauf.py)
- 00:03 12.11.: Marke Archiv session_01Hmoj77Z838grLETgmwhtMt (lauf.py)
- 00:37 12.11.: Startsperre 00:37 Start Jerry (Neustart-Meldung 00:35, f2dddf776; Nachfolger "Jerry – 863: Platztausch der Ratten"; Hoch, effort high)
- 01:05 12.11.: Startsperre 01:05 Start Tom, Homer, Tuffy (lauf.py)
- 01:05 12.11.: Marke Wächter 264 10.11. 16:53 (lauf.py)
- 01:05 12.11.: Marke Archiv session_01Hmoj77m67VFcXPeA7kSXqt (lauf.py)
- 01:05 12.11.: Marke Archiv session_01Hmoj7882hJCzdqb8SLvPZz (lauf.py)
- 01:05 12.11.: Marke Archiv session_01Hmoj76CayzJH3pKHwcqVjq (lauf.py)
- 01:05 12.11.: Nachfolger-Warnung Tom (Übergabe 12.11., 00:13) (lauf.py)
- 01:09 12.11.: Startsperre 01:09 Start Jerry (Neustart-Meldung 01:08, dfcf43604; Nachfolger "Jerry – 986: Eingebungen nach BRS"; Hoch, effort high)
- 01:16 12.11.: Startsperre 01:16 Start Sokrates (Neustart-Meldung 01:15, 1fdd4068f; Nachfolger "Sokrates – Nacht: Betrieb im Blick, morgens Lagebild"; Hoch, effort high)
- 02:04 12.11.: Startsperre 02:04 Start Jerry, Perikles, Spike (lauf.py)
- 02:04 12.11.: Marke Archiv session_01Hmoj7934La69YC63snTQki (lauf.py)
- 02:04 12.11.: Marke Archiv session_01Hmoj77m8rD5TFGQoSj81gT (lauf.py)
- 02:04 12.11.: Marke Archiv session_01Hmoj7667YeBDQoVo4PDtp2 (lauf.py)
- 02:09 12.11.: Startsperre 02:09 Start Jerry, Spike (lauf.py)
- 02:09 12.11.: Marke Start-fehlt Jerry 12.11.-02:04 (lauf.py)
- 02:09 12.11.: Marke Start-fehlt Spike 12.11.-02:04 (lauf.py)
- 02:47 12.11.: Startsperre 02:47 Start Jerry (Neustart-Meldung 02:45, 82a851e25; Nachfolger "Jerry – 988: rote Tests PR #196"; Hoch, effort high)
- 03:03 12.11.: Startsperre 03:03 Start Diogenes, Spike (lauf.py)
- 03:03 12.11.: Marke Archiv session_01Hmoj77btUrnzTkmToicMe4 (lauf.py)
- 03:03 12.11.: Marke Archiv session_01Hmoj76whoiKwDXuCf5tevk (lauf.py)
- 03:34 12.11.: Startsperre 03:34 Start Jerry (Neustart-Meldung 03:32, d2ed1c7ed; Nachfolger "Jerry – 988: Messlauf auswerten"; Hoch, effort high)
- 03:34 12.11.: Startsperre 03:34 Start Ford (selbst). Neustart-Haken 2 bei 293 Tsd. Token, Übergabe in dieser Datei.
- 04:04 12.11.: Startsperre 04:04 Start Perikles (lauf.py)
- 04:04 12.11.: Marke Start-fehlt Spike 12.11.-03:03 (lauf.py)
- 04:04 12.11.: Marke Start-fehlt Tom 12.11.-01:05 (lauf.py)
- 04:04 12.11.: Marke Archiv session_01Hmoj77NXYkoR442bAjQC23 (lauf.py)
- 04:04 12.11.: Nachfolger-Warnung Tom (Übergabe 12.11., 03:21) (lauf.py)
- 04:07 12.11.: Startsperre 04:07 Start Diogenes (lauf.py)
- 04:07 12.11.: Marke Archiv session_01Hmoj76nm3tRwpGWich17Uw (lauf.py)
- 04:33 12.11.: Startsperre 04:33 Start Tom (lauf.py)
- 05:04 12.11.: Startsperre 05:04 Start Jerry (lauf.py)
- 05:04 12.11.: Marke Archiv session_01Hmoj76Jm4cH6LxoNHpwumz (lauf.py)
- 06:04 12.11.: Startsperre 06:04 Start Jerry (lauf.py)
- 06:04 12.11.: Marke Übergabe-Chef Jerry 12.11. 05:58 (lauf.py)
- 06:04 12.11.: Marke Start-fehlt Jerry 12.11.-05:04 (lauf.py)
- 06:04 12.11.: Nachfolger-Warnung Jerry (Übergabe 12.11., 05:58) (lauf.py)
- 06:08 12.11.: Startsperre 06:08 Start Homer (lauf.py)
- 06:08 12.11.: Marke Archiv session_01Hmoj77G2Nx26NbtbSEBGc8 (lauf.py)
- 06:11 12.11.: Startsperre 06:11 Start Ford (selbst). Neustart-Haken 1 bei 208 Tsd. Token, Übergabe in dieser Datei; Tiefe 6, Vorgang 1016 (Ford von Hand starten).
- 07:04 12.11.: Startsperre 07:04 Start Perikles (lauf.py)
- 07:04 12.11.: Marke Archiv session_01Hmoj75W8e6YMkpd4gxoni7 (lauf.py)
- 07:04 12.11.: Nachfolger-Warnung Jerry (Übergabe 12.11., 06:07) (lauf.py)
- 07:21 12.11.: Startsperre 07:21 Start Tom (Neustart-Meldung d21503672, Nachfolger „Tom – 1012: Build 278 rote Tests und Testbitte“)
- 07:20 12.11.: Marke Übergabe-Chef Perikles 12.11. 07:10 (lauf.py)
- 07:20 12.11.: Marke Stellungnahme Sokrates 12.11. (lauf.py)
- 07:20 12.11.: Marke Archiv session_01Hmoj78ovK2dE9B3u77pw3E (lauf.py)
- 07:20 12.11.: Marke Archiv session_01Hmoj79B6X93sR9q3p1JjCA (lauf.py)
- 07:22 12.11.: Startsperre 07:22 Start Sokrates (lauf.py, Zeile von Hand nachgetragen: --sperre schrieb sie nicht)
- 08:05 12.11.: Startsperre 08:05 Start Perikles (lauf.py)
- 08:05 12.11.: Marke Tagesbericht 12.11. (lauf.py)
- 08:05 12.11.: Marke Nachhalten 12.11. (lauf.py)
- 08:05 12.11.: Marke Archiv session_01Hmoj79nhucTfp4jACfXVtR (lauf.py)
- 08:13 12.11.: Startsperre 08:13 Start Diogenes, Spike, Tuffy (lauf.py)
- 08:13 12.11.: Marke Archiv session_01Hmoj76MeSi8FRUmYKBjQmL (lauf.py)
- 08:13 12.11.: Marke Archiv session_01Hmoj7AAdH3XpmB1bRL6xNn (lauf.py)
- 09:06 12.11.: Startsperre 09:06 Start Spike (lauf.py; Perikles-START „Perikles – (Ford ruft)“ nicht ausgeführt, kein Auftrag)
- 09:06 12.11.: Marke Archiv session_01Hmoj7A2JDffJnrk5Dagztc (lauf.py)
- 09:06 12.11.: Marke Archiv session_01Hmoj79rReQeD9gdL8Prmpp (lauf.py)
- 10:05 12.11.: Startsperre 10:05 Start Spike, Tuffy (lauf.py; Perikles-START ohne Auftrag nicht ausgeführt)
- 10:05 12.11.: Marke Archiv session_01Hmoj766LSe7nDcgDZoGn2r (lauf.py)
- 10:05 12.11.: Marke Archiv session_01Hmoj77GZt45MJ7mkLqnBfm (lauf.py)
- 10:25 12.11.: Startsperre 10:25 Start Spike (Neustart-Meldung 55901b2ed, Nachfolger „Spike – 1022: Kartenrand, Test und Bildpaar“)
- 11:04 12.11.: Startsperre 11:04 Start Tom, Spike (lauf.py; Perikles-START ohne Auftrag nicht ausgeführt)
- 11:04 12.11.: Marke Stellungnahme Sokrates 12.11. (lauf.py)
- 11:04 12.11.: Marke Archiv session_01Hmoj774RsgV5o7g1cGdXxh (lauf.py)
- 11:04 12.11.: Marke Archiv session_01Hmoj79xdwrf62nTsP2VsKv (lauf.py)
- 11:04 12.11.: Marke Archiv session_01Hmoj78BVJcamjYcv7mJJYT (lauf.py)
- 11:10 12.11.: Startsperre 11:10 (lauf.py; Jerry-START „Pflege“ Kür und Perikles-START ohne Auftrag nicht ausgeführt)
- 11:10 12.11.: Marke Archiv session_01Hmoj79CS9LVAhotYsqmwgb (lauf.py)
- 11:10 12.11.: Nachfolger-Warnung Jerry (Übergabe 12.11., 11:08) (lauf.py)
- 11:26 12.11.: Startsperre 11:26 Start Homer (lauf.py; Jerry-START „Pflege“ Kür und Perikles-START ohne Auftrag nicht ausgeführt)
- 11:26 12.11.: Marke Archiv session_01Hmoj77crGw2i1MbQ6VpK2F (lauf.py)
- 12:06 12.11.: Startsperre 12:06 (lauf.py; Jerry-START „Pflege“ Kür und Perikles-START ohne Auftrag nicht ausgeführt, nichts gestartet)
- 12:18 12.11.: Startsperre 12:18 (lauf.py; Jerry-START „Pflege“ Kür und Perikles-START ohne Auftrag nicht ausgeführt, nichts gestartet)
- 13:05 12.11.: Startsperre 13:05 (lauf.py; Jerry-START „Pflege“ Kür und Perikles-START ohne Auftrag nicht ausgeführt, nichts gestartet)
- 13:10 12.11.: Startsperre 13:10 (lauf.py; Jerry-START „Pflege“ Kür und Perikles-START ohne Auftrag nicht ausgeführt, nichts gestartet)
- 13:10 12.11.: Nachfolger-Warnung Tom (Übergabe 12.11., 12:21) (lauf.py)
- 13:32 12.11.: Startsperre 13:32 (lauf.py; Jerry-START „Pflege“ Kür und Perikles-START ohne Auftrag nicht ausgeführt, nichts gestartet)
- 13:32 12.11.: Marke Start-fehlt Tom 12.11.-11:04 (lauf.py)
- 13:54 12.11.: Startsperre 13:54 Start Tom, Jerry, Spike (lauf.py; Tom auf 1030 statt 764 laut Start-Meldung Sokrates, Perikles-START ohne Auftrag nicht ausgeführt)
- 13:54 12.11.: Marke Archiv session_01Hmoj77hd1skjBoRKtk6Sz7 (lauf.py)
- 14:05 12.11.: Startsperre 14:05 (lauf.py; Perikles-START ohne Auftrag nicht ausgeführt, nichts gestartet)
- 14:24 12.11.: Startsperre 14:24 Start Perikles, Tuffy (lauf.py)
- 14:24 12.11.: Marke Archiv session_01Hmoj79xewvr4yXDaxRRApX (lauf.py)
- 15:00 12.11.: Startsperre 15:00 Start Tom, Tuffy (lauf.py)
- 15:00 12.11.: Marke Archiv session_01Hmoj79GnLFqxJnZ3kPVf75 (lauf.py)
- 15:00 12.11.: Marke Archiv session_01Hmoj75jovTr8zStqpmnEsx (lauf.py)
