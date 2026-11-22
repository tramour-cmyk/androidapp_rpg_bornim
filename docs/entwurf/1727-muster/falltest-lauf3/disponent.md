# Antworten Disponent (Falltest Lauf 3, 22.11., 07:14; Falldatum der Nachtfälle von Sokrates auf 21.11. gesetzt, Fall nannte keins; Anmerkung 22.11., 07:59: das Datum steht in der Antwort selbst (:42–48), das Datum der Sitzung ist nicht erhalten, die Antwort ist an diesen Stellen nicht mehr Wortlaut)

Ladetext: `lt3/sockel.md`, `lt3/kern-buero.md`, `lt3/profil-disponent.md`. Repo nur gelesen (Stand `4adc85374`). Was ich täte, steht als Befehl oder Wortlaut. `<Nr>` heißt: Nummer fehlt im Fall. „(Ladetext: …)“ nennt die Stelle, nach der ich handle.

## D1. Nachtstopp bei Start 4 von 8 an 1739 trotz 1784 A

**Wann:** sofort, wenn der Haken den Start 4 abweist.

1. Nicht umgehen (Kern Büro: „Werkzeugfehler: Vorgang mit Profil Werkzeug, nicht umgehen“). Ich schreibe keine Notfallzeile „Startsperre … (selbst)“ und starte nicht von Hand.
2. Prüfen, ob 1784 A für diesen Start überhaupt gilt (Sockel 3: belegen statt raten):
   - `python3 tools/vorgang.py 1784` → Archiv: „höchstens acht weitere Spike-Starts an 1739, spätestens 03:00; Ford startet von Hand nur, wenn die letzte Übergabe einen Commit unter `tools/` oder `.github/` nennt“.
   - Uhr: vor 03:00?
   - Letzte Übergabe Spike zu 1739: `git -C /home/user/bornim-main log -1 -p -- docs/ARBEIT-TEAM-Spike.md` bzw. `docs/vorgang/1739.md`, dann `git show --stat <Commit>`: liegt er unter `tools/` oder `.github/`?
   - `python3 tools/nachtstarts.py Spike 1739` → Zahl der Starts und Grenze („3 von 8 (Ausnahme 1784 …)“ oder „3 von 3“).
   - Nennt die Übergabe keinen solchen Commit oder ist es nach 03:00: der Haken hat recht, es gilt Nachtstopp nach 1784 A. Dann kein Werkzeugfehler, nur Schritt 3 mit Grund „1784 A: Bedingung nicht erfüllt“, sonst nichts.
   - Ist die Bedingung erfüllt und zeigt `nachtstarts.py` „3 von 3“: Werkzeugfehler. Dann weiter mit Schritt 3 bis 5.
3. Den Start ausschließen, damit `lauf.py` die nächste Zeile von Spike nimmt (Profil: „nicht starten, `lauf.py --ohne <Nr>:"<Grund>"`, Werkzeugfehler als Eingang“):
   `python3 tools/lauf.py --sperre --besetzung --ohne 1739:"Nachtstopp-Haken sperrt Start 4 trotz 1784 A (8 Starts bis 03:00); Werkzeugfehler in 1792" <Seiten>`
4. Eingang: Es gibt den Vorgang schon. 1792 (Spike, M): „Nachtstopp-Haken 1643 … kennt keine vom Chef entschiedene Ausnahme; 1784 A (8 Starts) hielt nach 3 an“. Das ist sicher dasselbe, also keine neue Nummer (Profil Eingang: „Sicher dasselbe: zum bestehenden Vorgang“). Den Befund trage ich als Rückmeldung bei 1792 ein:
   `python3 tools/vorgang.py rueckmeldung 1792 "Hinweis: Start 4 von 8 an 1739 (1784 A) am <Zeit> vom Startsperre-Haken abgewiesen: „<Hakentext wörtlich>“; nachtstarts.py Spike 1739: „<Ausgabe>“; letzte Übergabe nennt <Commit> unter tools/." --sitzung Disponent`
   Danach `git push`.
5. Lässt `lauf.py` in Schritt 3 START Spike auf 1792 aus (die Sperre zählt je Vorgang, 1792 ist ein anderer), führe ich die Zeile sofort aus: zuerst die Startsperre pushen (das tut `--sperre`), dann `create_session` mit allen Feldern der START-Zeile. Ist 1792 behoben und vor 03:00 noch Deckel frei, gibt der nächste Lauf ohne `--ohne 1739` den Start wieder aus.
6. An den Chef nichts. Es ist keiner der drei Fälle aus „An den Chef“, und der Betrieb steht nicht, denn andere Rollen laufen weiter.

## D3. Werkzeug „fertig“ mit Commit, der nicht auf `main` liegt

**Wann:** beim ersten Wecker nach der Rückmeldung, also eine Stunde danach, sofort beim Sehen.

1. Prüfen: `git -C /home/user/bornim-main fetch origin main && git -C /home/user/bornim-main merge-base --is-ancestor a1b2c3d origin/main; echo $?` → 1 (nicht auf `main`). Dazu `git branch -r --contains a1b2c3d`, damit ich weiß, auf welchem Zweig er liegt.
2. Nach Profil „Fertig“, Ausnahme Werkzeug („liegt der Commit nicht auf `main`, Zeile an die Fachkraft ‚auf `main`, Vollzug mit Commit‘“):
   `python3 tools/vorgang.py uebergabe <Nr> <Besitzer laut Liste, etwa Spike> "auf main, Vollzug mit Commit: a1b2c3d liegt nicht auf origin/main (merge-base, <Zeit>), Zweig <Zweig>"`
   Danach `git push`. Die Wecker-Zeilen, die das Werkzeug ausgibt, schicke ich per `send_message` „sieh in <Nr> (<Kennung>)“. Hat die Fachkraft keine Sitzung, nehme ich den START, den `lauf.py` im nächsten Lauf dafür ausgibt, und tue ihn sofort.
3. Keine Testbitte an den Chef. Das gilt bei Werkzeug ohnehin (Profil „An den Chef“: „nicht bei Werkzeug“).
4. Die Zeile an den Prüfer, die `rueckmeldung.py` beim „fertig“ mit Commit schon angelegt hat, kann ich nicht zurücknehmen. Ich lasse sie stehen. Der Prüfer prüft nach dem Ladetext ohnehin erst, wenn der Commit auf `main` liegt („der Prüfer prüft danach“). Siehe Lücke L3.
5. Werkzeugfehler als Eingang, weil das Werkzeug einen Werkzeug-Commit außerhalb von `main` an den Prüfer weitergibt (siehe L3):
   `python3 tools/vorgang.py neu "Von Disponent (<Nr>, <Zeit>): rueckmeldung.py gibt Werkzeug-„fertig“ mit Commit außerhalb main an den Prüfer statt Zeile an die Fachkraft" "B Werkzeuge" M "Spike"`. Vorher prüfe ich mit `python3 tools/vorgang.py --rolle Spike`, ob es den Vorgang schon gibt.

## D4. Chef 23:15 „weniger laufen“, 01:10 Kür startbar, eine Fachkraft am Muss läuft

**23:15, sofort:**
1. Das Chefwort wörtlich mit Zeit ins Protokoll von `docs/ARBEIT-BETRIEB.md` (Profil Guthaben: „wörtlich mit Zeit ins Protokoll“), mit Edit:
   `- 23:15 21.11.: Chef: „Lass mal heute Nacht nicht zu viel laufen, dass wir vielleicht morgen früh noch Luft haben.“ → nur Wache, Sokrates, Rückläufer des Chefs, bis Sokrates Umfang und Ende setzt`
   Danach commit und push. Zusätzlich gehört es nach Kern Büro in eine Vorgangsdatei („Chefworte wörtlich mit Zeit in die Vorgangsdatei“). Einen Vorgang dafür gibt es nicht. Eingang, nachdem ich mit `python3 tools/vorgang.py --rolle Sokrates` geprüft habe, dass es ihn noch nicht gibt:
   `python3 tools/vorgang.py neu "Von Chef (21.11., 23:15): heute Nacht weniger laufen, Umfang und Ende setzen" "B Abläufe" M "Sokrates"` → `<Nr>`, push.
   `python3 tools/vorgang.py chefwort <Nr> "Lass mal heute Nacht nicht zu viel laufen, dass wir vielleicht morgen früh noch Luft haben." --zeit "21.11., 23:15" --sitzung Disponent`
   Dieser Befehl legt aber eine Zeile an den Arbeitsplaner an, nicht an Sokrates (siehe L5).
2. Zeile an Sokrates: `python3 tools/vorgang.py uebergabe <Nr> Sokrates "Chef 23:15 weniger laufen: Umfang und Ende setzen (Profil Disponent, Guthaben)"`, push. Dann `python3 tools/lauf.py --sperre --besetzung <Seiten>` → START Sokrates (1763 C) sofort ausführen.
3. Laufende Fachkraft: `send_message` an ihre Sitzung: „**Disponent** [21.11., 23:15]: Chef 23:15 will heute Nacht weniger Laufen. Bitte jetzt übergeben: Stand committen und pushen, `vorgang.py freigeben`, Übergabe schreiben, enden. Dein Muss nimmt der nächste Start auf, wenn Sokrates Umfang gesetzt hat.“ (Profil: „laufende Fachkräfte übergeben“).

**01:10 (Wecker, START Kür):**
4. Hat Sokrates Umfang und Ende gesetzt (Protokoll oder `docs/vorgang/<Nr>.md`), handle ich danach. Wenn nicht, gilt weiter: nur Wache, Sokrates, Rückläufer des Chefs. Die Kür widerspricht dem Chefwort, also nicht starten:
   `python3 tools/lauf.py --sperre --besetzung --ohne <Kür-Nr>:"Chef 23:15 weniger laufen; bis Sokrates Umfang setzt nur Wache, Sokrates, Rückläufer" <Seiten>`
   Kommt danach ein START für eine andere Kür oder ein Muss, das kein Rückläufer des Chefs ist: ebenso `--ohne`.
5. Läuft die Fachkraft immer noch: ein zweites `send_message` „übergeben“. Ich unterbreche sie nicht, denn dafür habe ich keinen Auftrag.
6. Werkzeugfehler als Eingang, weil `lauf.py` das Chefwort nicht kennt und Kür ausgibt: `python3 tools/vorgang.py neu "Von Disponent (01:10): lauf.py kennt kein Chefwort ‚weniger laufen‘, gibt Kür-START aus" "B Werkzeuge" M "Spike"`, nachdem ich geprüft habe, ob es ihn schon gibt.

## D5. Zwei offene „Frage“ an Sokrates seit 22:44 und 23:08, Sokrates läuft nicht, 23:10

**Wann:** sofort (23:10). Der Start für 22:44 war schon um 22:49 fällig (Anhalt 5 Minuten je Übergabe). Ich hole ihn jetzt nach.
1. `python3 tools/vorgang.py offen Sokrates` → beide Zeilen mit Kennung.
2. Guthabenstufe aus der Ausgabe ablesen. Bei Stillstand (ab 100 %) starte ich nicht. Sonst geht es weiter, denn Sokrates ist bei jeder Stufe erlaubt.
3. `python3 tools/lauf.py --sperre --besetzung <Seiten>` → nach `sokrates_zeilen` (lauf.py:538) kommt eine einzige Zeile „START Sokrates | opus … | Sokrates – 1763 C: offene Zeilen (23:10) | … Offene Zeilen an dich (1763 C): <K1> Frage …; <K2> Frage …“ mit beiden Zeilen (nie zwei Sokrates). Startsperre pushen, dann `create_session` mit allen Feldern, sofort.
4. Prüfen, ob der Start angekommen ist: nächster Lauf oder `get_session`. Nehmen die Zeilen den Zustand „angenommen“ an (`vorgang.py offen Sokrates` leer), ist der Fall für mich erledigt.
5. An den Chef nichts. Eine „Frage“ beantwortet Sokrates, und an den Chef geht nur, was er als Chefsache anlegt.

## D9. Offene Zeilen an die Fachkraft: 1535 (Fund des Chefs), 1801 (Eilt), 1270 (Muss)

**Wann:** sofort beim Wecker.
1. `python3 tools/vorgang.py offen` → 1535 vor 1801 vor 1270, nach dem Rang in uebergabe.py:294.
2. Nach dem Profil gilt die Folge Eilt, Fund des Chefs, Themenblock, Eingangszeit, also 1801 vor 1535 vor 1270 („ordnet das Werkzeug anders, gilt diese Folge (Werkzeugfehler als Eingang)“). Eilt prüfe ich nach: Ist das Wort vom Chef belegt (`docs/vorgang/1801.md`, Chefworte)? Wenn nicht, ist es kein Eilt (Profil: „Eilt setzt nur der Chef“), und die Folge ist 1535, 1801, 1270.
3. Start der Fachkraft zu 1801 zuerst, eine Zeile nach der anderen. `python3 tools/lauf.py --sperre --besetzung --ohne 1535:"erst Eilt 1801 (Folge Disponent)" --ohne 1270:"erst Eilt 1801" <Seiten>`. Gibt `lauf.py` keinen START für 1801 aus, sondern „NACHRICHT Ford | - | keine Sitzung Fachkraft: starten oder zuteilen …“ (lauf.py:633, denn „Fachkraft“ steht nicht in START_REIHE), starte ich die zuständige Rolle laut Besitzer von 1801 so, wie `lauf.py` es für diese Rolle ausgibt. Kein Start ohne gültigen Auftrag mit „Zurück“ in `docs/vorgang/1801.md` (prüfen: `python3 tools/vorgang.py 1801`).
4. Nimmt die Fachkraft 1801 an oder meldet sie „fertig“, folgt der Start zu 1535 innerhalb von 5 Minuten, danach 1270.
5. Werkzeugfehler als Eingang: `python3 tools/vorgang.py neu "Von Disponent (<Zeit>): Folge offener Zeilen Fund vor Eilt (uebergabe.py:294) und nach Dateiname (lauf.py:621) statt Eilt, Fund, Themenblock, Eingangszeit" "B Werkzeuge" M "Spike"`, push, nachdem ich geprüft habe, ob es ihn schon gibt.

## Lücken

- **L1 Startsperre fehlt im Ladetext.** Das Profil sagt „bei jedem Wecker `tools/lauf.py`, dann tust du jede Zeile“, aber nicht, dass ein START vorher `lauf.py --sperre --besetzung` und einen Push braucht. Ohne das weist der Haken jeden Start ab (startsperre-haken.py:71 „Startsperre fehlt (750 A) … erst `python3 tools/lauf.py --sperre --besetzung`, pushen“). Woher die Seiten für `lauf.py` kommen (list_sessions, Kurzform), sagt der Ladetext auch nicht.
- **L2 Hakentext gegen Ladetext (D1).** Der Haken verlangt „Ford: Zeile ‚… Morgen 1643: …‘ ins Protokoll, pushen“ (startsperre-haken.py:114 bis 117). Im Ladetext steht kein Protokoll außer beim Guthaben, und der Haken spricht „Ford“ statt „Disponent“ an. Unklar ist auch, ob „von Hand starten“ aus 1784 A dem Disponenten erlaubt ist, wenn der Haken sperrt. „Nicht umgehen“ (Kern Büro) und das Chefwort widersprechen sich hier. Ich habe „nicht umgehen“ gewählt.
- **L3 Werkzeug-„fertig“ außerhalb `main` (D3).** rueckmeldung.py:98 gibt jedes „fertig“ mit Commit an den Prüfer, ohne Bereich und ohne `main` zu prüfen. Das Profil verlangt bei Werkzeug, dass der Commit erst auf `main` liegt und der Prüfer danach prüft. Ein Wecker an den Disponenten entsteht dabei nicht. Ich sehe den Fall darum erst zufällig beim nächsten Wecker und nicht sofort. Wie ich die Prüfer-Zeile zurückstelle, sagt der Ladetext nicht.
- **L4 Empfängername „Fachkraft“.** Weder im Ladetext noch im Werkzeug steht, welcher Name bei `vorgang.py uebergabe <Nr> <AN>` die Fachkraft (Profil Figur, Werkzeug) meint. In lauf.py:192 enthält `START_REIHE` nur Tom, Jerry, Spike, Diogenes, Homer, Perikles. Für „Fachkraft“ kommt deshalb nur „NACHRICHT Ford … keine Sitzung Fachkraft: starten oder zuteilen“ (lauf.py:633), und der Ladetext sagt nicht, wie ich zuteile.
- **L5 Chefwort „weniger laufen“ (D4).** Das Profil sagt „ins Protokoll, Zeile an Sokrates“, der Kern sagt „in die Vorgangsdatei“. Das sind zwei Orte. Einen Vorgang gibt es nicht, und `vorgang.py chefwort` legt die Zeile an den Arbeitsplaner an, nicht an Sokrates (chefwort.py:24 `AN = … "Arbeitsplaner"`). `lauf.py` kennt das Chefwort nicht und gibt weiter Kür und Muss aus. Ich muss jede Zeile einzeln mit `--ohne` ausschließen. Für „nur Rückläufer“ gibt es keinen Schalter, nur `--nur-muss`, und das ist zu weit.
- **L6 Guthabenstufe.** Das Profil sagt „Das Werkzeug gibt die Stufe aus: ab 80 % … 95 % … 100 %“. `lauf.py` gibt keine solche Stufe aus. Es gibt nur `--nur-muss` „bei `allowed_warning`“ (lauf.py:45), und eine Stufe 95 % („nur Rückläufer des Chefs“) gibt es im Werkzeug gar nicht.
- **L7 Folge der offenen Zeilen (D9).** uebergabe.py:294 ordnet Fund des Chefs vor Eilt. lauf.py:621 ordnet nach Dateiname, also nach Vorgangsnummer, und bündelt alle Zeilen eines Empfängers in eine Nachricht (bis 6). So bestimmt nicht der Disponent die Folge „eine nach der anderen“. Einen Themenblock kennt keines der Werkzeuge. „Eilt“ erkennt das Werkzeug am Text der Zeile („eilt“ in `was`), nicht daran, dass der Chef es gesetzt hat.
- **L8 Verpasster Sofortstart (D5).** Der Ladetext sagt „Den nächsten Schritt startest du sofort“. Ein Wecker an den Disponenten bei einer neuen Zeile an Sokrates ist aber nicht beschrieben: `rueckmeldung.py` legt die Zeile an, der Start kommt erst mit dem nächsten Lauf von `lauf.py` (rueckmeldung.py:3 „den Start macht lauf.py“). Wer mich um 22:44 weckt, bleibt offen.
- **L9 „Zum bestehenden Vorgang“ (D1).** Wie ein Eingang an einen bestehenden Vorgang kommt, sagt der Ladetext nicht. Ich habe `rueckmeldung … "Hinweis: …"` gewählt. Nach rueckmeldung.py:14 geht ein „Hinweis“ aber an den Disponenten zurück („Hinweis → Disponent (wie ein Eingang)“), also an mich selbst.
