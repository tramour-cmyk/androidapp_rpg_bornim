# Falltest Lauf 4, Disponent (Büro): D1 bis D11

Geladen: Sockel, Kern Büro, Profil Disponent. Werkzeug nur lesend in `kopie/` nachgesehen (`--help`, `vorgang.py <Nr>`, `nachtstarts.py`, `uebergabe.py`-Kopf, `lauf.py`-Kopf). Schreibbefehle sind unten als „würde ich tun“ angegeben, nicht ausgeführt. Allgemein vorab: Jeder Lauf beginnt mit `git -C <Notizkopie> pull --no-rebase` und `python3 tools/lauf.py --ohne-pull <Seiten>`; jede Schreibtat wird sofort gepusht (das Werkzeug tut es selbst, „gepusht wie der Zähler“).

Allgemeine Lücken (gelten für mehrere Fälle, einmal hier):
- `python3 tools/lauf.py --help` gibt keine Hilfe, sondern bricht mit `WARNUNG-LAUT Notizen … 9 Commits hinter origin/main und nicht vorspulbar (eigene Commits?): erst git pull --no-rebase, dann lauf.py erneut (380)` ab. Der Hilfetext steht nur im Kopf der Datei. Mein Text sagt nicht, wie ich lauf.py in einer veralteten Kopie aufrufe (`--ohne-pull` steht nur im Werkzeug-Kopf).
- Mein Text nennt die Rollen „Arbeitsplaner“, „Prüfer“, „Fachkraft (Werkstatt)“, „Technik“, „Figur“, „Spike“, „Sokrates“, aber keine Liste der gültigen Empfängernamen für `vorgang.py uebergabe NR AN`. Im Werkzeug stehen nur ALT-Namen (Prüfer→Diogenes, Disponent/Arbeitsplaner→Ford); ob „Technik“ oder „Spike“ als AN gilt, sagt der Text nicht.
- Kern Büro: „Chefworte wörtlich mit Zeit in die Vorgangsdatei … nie umformuliert“, aber ein Chefwort ohne Vorgangsnummer (D4) hat keine Datei. Das Werkzeug `vorgang.py chefwort NR` verlangt eine Nummer. Mein Text sagt nicht, was ich dann tue.
- „Protokoll“ (Profil: „wörtlich mit Zeit ins Protokoll“): wo es steht und wie ich schreibe (von Hand in `docs/ARBEIT-BETRIEB.md`, oder Werkzeug?), steht in meinen Texten nicht; Sockel/Kern nennen es nur.
- `meldung.sh --laut` ist laut Kopf „nicht 22–7 Uhr“; mein Kern sagt „laut“ ohne Nachtregel.

---

## D1

**(a) Tun**
1. Lage lesen, nicht raten: `python3 tools/nachtstarts.py Spike 1739` (Zahl der Starts dieser Nacht, geltende Grenze) und das Archiv: Eintrag „1784, Nachtstopp Spike (21.11., 21:54, Chef an Sokrates: „1784 A“)“. Er trägt „Chef“ in der Klammer, also gilt er als Chefentscheid (ohne „Chef“ gäbe es nach dem Werkzeug keine Ausnahme). Deckel: höchstens 8 weitere Starts, spätestens 03:00. Stand 4/8, Uhrzeit vor 03:00: der Haken „Nachtstopp“ ist hier ein Fehler des Werkzeugs, nicht des Chefworts.
2. Eingang: gibt es ihn schon? Ja, 1792 (Spike, Muss, startbar, „Nachtstopp-Haken kennt keine vom Chef entschiedene Ausnahme“). Also kein neuer Vorgang, sondern Hinweis an den bestehenden: `python3 tools/vorgang.py uebergabe 1792 Spike "Hinweis: Nachtstopp bei Start 4/8 trotz Ausnahme 1784 A (Archiv 21.11., 21:54, Chef, höchstens 8 weitere, bis 03:00); Zähler nachtstarts.py Spike 1739 zeigt: <Ausgabe>"`. Das Werkzeug legt die Zeile an und gibt WECKER-Zeilen aus; ich schicke sie per `send_message` „sieh in 1792 (<Kennung>)“. Den Haken umgehe ich nicht (Kern: „Werkzeugfehler: … nicht umgehen“).
3. Der Entscheid des Chefs erlaubt aber ausdrücklich den Handstart. Bedingung prüfen: letzte Übergabe an 1739: `python3 tools/vorgang.py 1739` und `docs/vorgang/1739.md` (letzte Spike-Zeile / Absatz „Zu 1739 (Spike, …)“). Nennt sie einen Commit unter `tools/` oder `.github/`: Spike von Hand starten (`create_session` mit den Feldern einer START-Zeile: Rolle Spike, model, environment_id, source_url, source_revision main, Titel „Spike – 1739: <Thema> (TT.MM., HH:MM)“, erste Nachricht mit Verweis auf die Übergabe), danach Protokollzeile „Startsperre HH:MM Start Spike (Neustart <Commit>, 1739)“, damit `nachtstarts.py` weiterzählt (Form laut Werkzeugkopf). Nennt sie keinen: kein Start, Nachtstopp bleibt (steht für den Morgen).
4. Ist Spike für 1792 selbst startbar (Muss), kommt der Start aus `lauf.py`; eine Rolle, eine Sitzung. Die Reihenfolge 1792 gegen 1739 steht nicht in meinem Text (siehe Lücken).

**(b) Meldung / Protokoll**
- Protokoll: `Handstart Spike 1739 HH:MM (Nachtstopp-Ausnahme 1784 A, Start 5/8, Übergabe nennt tools/<Datei> <Commit>); Hinweis an 1792` bzw. bei keinem Commit: `Kein Handstart Spike 1739 HH:MM: letzte Übergabe nennt keinen Commit unter tools/ oder .github/ (1784 A)`.
- An den Chef nichts (nichts, was er entscheiden, tun oder prüfen kann).

**Lücken:**
- Mein Text sagt nichts zu Archiv-Entscheiden, die einen Handstart erlauben; „Sitzungen startest nur du“ trägt ihn, „Werkzeugfehler … nicht umgehen“ widerspricht ihm scheinbar. Ich las den Archiv-Entscheid als gewollte Ausnahme, weil ein Chefwort „Widerspricht ein START einem Chefwort … nicht starten“ umgekehrt auch das Starten deckt. Das steht so nicht da.
- „Ford startet von Hand“: wie (Felder, Titel, erste Nachricht) steht nicht im Text; ich muss die START-Zeile von `lauf.py` nachbauen, die der Haken gerade unterdrückt. Eine Ausgabe, die die gesperrte START-Zeile trotzdem zeigt, fehlt.
- Was „die letzte Übergabe“ ist und wo ich sie lese (Vorgangsdatei-Zeile, Vorrat, Besetzung), sagt der Text nicht.
- Konflikt: 1792 (Muss, Spike) und 1739 (Spike) konkurrieren um eine Sitzung; der Text gibt keine Vorrangregel.
- Die gestellte Lage sagt, 1792 stehe „startbar“; in der Kopie ist 1792 schon „erledigt, greift Lauf 335“: der Fall zeigt eine andere Stufe als die Kopie.

---

## D2

**(a) Tun**
1. Die Rückmeldung nennt keinen Vorgang. Zuerst klären: aus welcher Sitzung, an welchem Vorgang (Besetzung / Titel der Sitzung). Nicht raten.
2. Prüfen, ob die Zeile schon steht (die Sitzung meldet sonst über das Werkzeug): `python3 tools/vorgang.py offen Sokrates`. Steht sie nicht: `python3 tools/vorgang.py rueckmeldung <Nr> "steckt fest: Notizkopie alt, 51 eigene Commits, 603 fehlen. Reset auf origin/main?" --sitzung <Rolle>`. Das Werkzeug trägt wörtlich mit Zeit in `docs/vorgang/<Nr>.md` ein und legt die offene Zeile an Sokrates an („steckt fest“ → Sokrates, C).
3. Die Reset-Frage entscheide ich nicht: ein Reset verwirft 51 eigene Commits (womöglich ungepusht). Ich schicke der Sitzung per `send_message`: „Kein Reset. Zeile liegt bei Sokrates (Kennung <K>). Eigene Commits nicht anfassen.“
4. Sokrates läuft nicht: ihn starten, wie `lauf.py` es ausgibt (START Sokrates mit „Offene Zeilen an dich … Je Zeile `vorgang.py annehmen <Kennung>`“); die Sitzung des Meldenden bleibt, bis Sokrates urteilt.
5. Eingang: ist der Zustand der Notizkopie (603 hinter origin, 51 eigene) ein Werkzeugfehler? Das urteilt Sokrates mit; nur wenn die Ursache ein Hakenfehler ist, lege ich Eingang an (erst `grep -i Notizkopie docs/LISTE-VORGAENGE.md`, ob es ihn gibt).

**(b) Meldung**
- Rückmeldung wörtlich wie oben (Werkzeug); Protokoll: `Rückmeldung steckt fest <Nr> HH:MM an Sokrates, Reset-Frage, Sokrates gestartet`. Chef: nichts.

**Lücken:**
- Mein Text sagt nicht, wer die Rückmeldung ins Werkzeug trägt, wenn die Sitzung sie mir (im Chat) statt per `vorgang.py rueckmeldung` gibt. Ich habe es selbst nachgetragen.
- Kern: „Du urteilst nur über … ‚steckt fest‘“ (Profil) gegen „Sokrates startest du bei jeder offenen Übergabezeile … ‚steckt fest‘“ (Kern): ob ich beim ersten „steckt fest“ selbst urteile oder nur starte, ist unklar. Ich urteilte nicht inhaltlich, startete Sokrates.
- Nichts über den Umgang mit veralteter Notizkopie; genau diese Lage hatte mein eigener `lauf.py`-Aufruf in `kopie/` (WARNUNG-LAUT, 9 Commits hinter origin).

---

## D3

**(a) Tun**
1. Vorgang prüfen: Bereich B Werkzeuge, kein Spielinhalt, also Ausnahme „Werkzeug ohne Spielinhalt meldet ‚fertig‘ mit Commit auf `main`“. Beleg vorhanden (Commit `a1b2c3d`, „Lauf grün“), also „Fertig“ mit Commit wird angenommen, aber nur wenn er auf `main` liegt.
2. Beim ersten Wecker: `git -C <Notizkopie> fetch origin` und `git merge-base --is-ancestor a1b2c3d origin/main` (oder `python3 tools/liegt.py`, das genau das mit `auf_main` prüft und die Zeile `LIEGT <Nr> | gebaut | … | an Fachkraft: …` gibt). Ergebnis: nicht auf `main`.
3. Kern: „liegt der Commit nicht auf `main`, Zeile an die Fachkraft ‚auf `main`, Vollzug mit Commit‘“: `python3 tools/vorgang.py uebergabe <Nr> Spike "auf main, Vollzug mit Commit: a1b2c3d steht nicht auf origin/main (Geprüft an a1b2c3d); bitte auf main bringen, dann fertig mit dem Vollzug-Commit"` und Wecker per `send_message` an die Sitzung aus der Besetzung (Kennung steht in der Werkzeug-Ausgabe).
4. Die vom Werkzeug schon angelegte Zeile „fertig mit Commit → Prüfer“ prüft einen Commit, der nicht auf `main` liegt: ich warne den Prüfer nicht selbst (nicht mein Auftrag), lasse die Zeile aber offen; Beleg: `git branch -r --contains a1b2c3d`.

**(b) Meldung**
- Zeile wie oben; Protokoll: `<Nr> fertig, a1b2c3d nicht auf main (HH:MM), Zeile an Spike „Vollzug mit Commit“`. Chef: nichts.

**Lücken:**
- Der Text nennt den Empfänger nur „die Fachkraft“; „Spike“ gegen „Werkzeug“ gegen „Technik“ (Profil Werkzeug im Kern) sind drei Namen. Unklar, welchen `uebergabe` annimmt.
- Nicht gesagt: ob die Prüferzeile zurückgehalten wird, solange der Commit nicht auf `main` ist; das Werkzeug legt sie sofort an.
- `a1b2c3d` kann dem Disponenten-Repo unbekannt sein (`liegt.py auf_main` gibt dann None); mein Text sagt nicht, ob ich dann zuerst `git fetch` mache oder die Zeile ohne Prüfung schicke.
- „Eine Stunde später … beim ersten Wecker“: der Takt liegt bei Stunde/Nachricht; `liegt.py` meldet erst ab Frist (Stand „gebaut“: 1 Tag; „freigegeben“: 1 Tag). Eine Stunde nach dem Fertig gibt `lauf.py` also noch keine LIEGT-Zeile; Kern „tu, was die Zeile nennt“ greift nicht, ich muss selbst prüfen. Der Text sagt nicht, dass ich bei „fertig“ sofort prüfe.

---

## D4

**(a) Tun**
1. Chefwort wörtlich mit Zeit ins Protokoll: `21.11., 23:15 Chef: „Lass mal heute Nacht nicht zu viel laufen, dass wir vielleicht morgen früh noch Luft haben.“` (nicht umformuliert; Lesart in Klammern nur, wo die Vorlage sie eindeutig macht: hier keine).
2. Zeile an Sokrates (Umfang und Ende; das Wort nennt keinen Umfang): `python3 tools/vorgang.py uebergabe <Nr> Sokrates "Chef 21.11., 23:15: „Lass mal heute Nacht nicht zu viel laufen, …“. Umfang und Ende setzen."` (Nummer siehe Lücken). Sokrates starten, falls er nicht läuft.
3. Bis Sokrates Umfang gesetzt hat, starte ich nur Wache, Sokrates und Rückläufer des Chefs. „Weniger laufen“ hält Kür und neue Arbeit an: die Kür-Zeile von 01:10 starte ich nicht: `python3 tools/lauf.py --ohne-pull --ohne <Nr>:"Chefwort 21.11., 23:15 weniger laufen, Kür" <Seiten>` (die Zeile erscheint dann als `AUSGESCHLOSSEN`). Keine Marke „, auch Rückläufer“: der Chef sagte nicht „alles“.
4. Die Fachkraft am Muss: „übrige Sitzungen übergeben“. Ich schicke ihr per `send_message`: „Chef: weniger laufen. Schließe diesen Zug sauber, übergib (`vorgang.py freigeben`, Nachfolger: keiner/erst nach Sokrates), kein Neustart.“ Das Muss wird nicht abgebrochen.

**(b) Meldung / Protokoll**
- Protokollzeile wie in 1 plus: `01:10 Kür <Nr> nicht gestartet (Chefwort 23:15); Zeile an Sokrates`. Chef: nichts.

**Lücken:**
- „übrige Sitzungen übergeben“ lässt offen, ob eine Fachkraft an einem laufenden Muss sofort oder erst nach dem Muss übergibt; „Weniger laufen hält Kür und neue Arbeit an“ sagt „nicht das laufende Muss“. Ich las: Muss läuft zu Ende, danach Übergabe ohne Nachfolger. Zwei Sätze, die sich beißen.
- Nummer: ein Chefwort ohne Vorgang. `vorgang.py uebergabe NR` und `chefwort NR` brauchen eine Nummer in der Liste (Betriebs-Vorgang? `vorgang.py neu "…" "B Abläufe" K Sokrates`?). Mein Text sagt es nicht.
- „Berliner Zeit“: Chefwort 23:15 am 21.11., Start 01:10 am 22.11.: der Text sagt nicht, ob das Wort über Mitternacht gilt („heute Nacht“ → bis wann?). Das setzt Sokrates, ich halte bis dahin an.
- `--ohne` mit Nummer der Kür-Zeile: der Kern erlaubt es für Chefwort-Widerspruch; ob eine Rolle ganz („--ohne Spike:…“) oder nur die Zeile, steht nur im Werkzeugkopf.

---

## D5

**(a) Tun**
1. 23:10. Zeilen ansehen: `python3 tools/vorgang.py offen Sokrates` (zwei offene „Frage“, 22:44 und 23:08).
2. Kern: „Sokrates startest du bei jeder offenen Übergabezeile an ihn (… ‚Frage‘ …)“. Sokrates läuft nicht, also jetzt starten, nicht auf die Stundenuhr warten („Den nächsten Schritt startest du sofort“). Nachts ist Sokrates erlaubt (auch unter „weniger laufen“). Guthaben vorher ansehen: `python3 tools/guthaben.py` (ab 95 % nur Rückläufer, ab 100 % Stillstand; in der Kopie: „GUTHABEN unbekannt … Stufe wie unter 80 %“).
3. `python3 tools/lauf.py --ohne-pull <Seiten>`, die START-Zeile für Sokrates (mit den zwei Zeilen im Text „Offene Zeilen an dich (1763 C) …“) per `create_session` ausführen: ein Start trägt beide, ältere zuerst (22:44, dann 23:08, „eine nach der anderen“).
4. Die Frage zur Lauffreigabe beantworte ich nicht selbst und gebe keinen Lauf frei.

**(b) Protokoll:** `23:10 Sokrates gestartet: Fragen 22:44, 23:08 (Lauffreigabe), offen.` Chef: nichts.

**Lücken:**
- Widerspruch: Profil „Du urteilst nur über Eingang, ‚Frage‘, ‚steckt fest‘ und Guthaben“ gegen Kern „Frage → Sokrates“. Ob ich eine „Frage“ zur Lauffreigabe selbst beantworten darf (die Antwort ist Guthaben/Takt, also meine Sache?), sagt der Text nicht. Ich startete Sokrates und urteilte nicht.
- Kein Wort dazu, ob ein Start um 23:10 für „Lauffreigabe“ nachts vom Chef bestätigt sein muss.

---

## D6 (Wache-Wecker)

**(a) Tun**
1. Wecker der Wache: „Liegt: 1650, 1653, 1654 abgenommen seit 7–9 h, in keinem Build.“ Nachsehen, nicht glauben: `python3 tools/vorgang.py 1650 1653 1654` (Stand „abgenommen“ = Prüfer sagte „ja“, Beleg in der Vorgangsdatei) und `python3 tools/liegt.py` (Zeile `LIEGT … | abgenommen | … | an Disponent: nächster Build, Tagesmeldung (Frist offen)`).
2. Zeile tun: „nächster Build“. Bauen darf ich nicht. Die Zeile geht an den Build-Macher: `python3 tools/vorgang.py uebergabe 1650 Technik "Build: 1650, 1653, 1654 abgenommen (Prüfer ja), in keinem Build, seit 7-9 h; nächster Build mit diesen drei (vorgang.py build N --mit 1650,1653,1654)"` (je Vorgang eine Zeile oder eine Sammelzeile unter 1650, siehe Lücken). Lauf starten, wenn Technik nicht läuft (START nur mit Auftrag und Feld „Zurück“; der Arbeitsplaner schreibt den Build-Auftrag).
3. „Tagesmeldung“: die Zeile ist ein Punkt im Tagesbericht der Routine (steht im Werkzeug „Tagesbericht“). Die Wache hat gemeldet; Tagesbericht nur starten, wenn die Wache „Tagesbericht fehlt“ meldet.
4. Nach dem Build und dem Ja des Prüfers: Testbitte an den Chef (lautlos, eine Zeile, zu einer neuen Chefsache-Datei).

**(b) Meldung:** Protokoll: `HH:MM Wache LIEGT 1650/1653/1654 abgenommen: Zeile an Technik „nächster Build“`. Chef: noch nichts.

**Lücken:**
- Kein Text sagt, wie ich einen Build auslöse: welche Vorgangsnummer (Sammelvorgang? der nächste Build hat noch keine), welcher Auftrag (Feld „Zurück“), welche Rolle (Technik).
- „Tagesmeldung“ in der Wächter-Zeile: mein Text sagt nicht, was ich dafür tue (Eintrag? Zeile an den Tagesbericht?).
- Wer die Testbitte-Datei in der Chefsache schreibt (Kern: „eine Zeile zu einer neuen Chefsache-Datei“), steht nicht da.
- Keine Frist: 7–9 h bei „Frist 1 Tag, offen“ (liegt.py): gibt `liegt.py` hier überhaupt eine Zeile, oder greift die Wache zu früh? Text schweigt.

---

## D7 (Wache-Wecker)

**(a) Tun**
1. Nachsehen: für jedes der Builds 286–292 die Freigabe im Archiv (`grep -n "t286\|Build 286" docs/VORGANGSARCHIV.md` usw. bzw. `python3 tools/vorgang.py <Nr>` der Vorgänge je Build). Nur was belegt ist (Archiv oder Vorgangsdatei, Chefwort „gut/passt/freigegeben“), gilt. „Chef hat freigegeben“ ohne Beleg: nicht tun.
2. Commits der Builds prüfen: `git merge-base --is-ancestor <Commit> origin/main` je Build; `python3 tools/liegt.py`.
3. Belegte, nicht auf `main` liegende Builds: Zeile an die Fachkraft Technik (Build-Macher): `python3 tools/vorgang.py uebergabe <Nr> Technik "auf main, Vollzug mit Commit: Build 286 bis 292 vom Chef freigegeben (Archiv <Datum, Zeit>), seit 3 h nicht auf main"`, je Build eine Zeile oder eine unter dem ersten Vorgang; Wecker per `send_message`.
4. Lauf 293 rot: Stand „im Build“ über der Frist (3 h): „Build rot: zurück ans Büro; beim zweiten Mal Sokrates“. Zurück ans Büro heißt: ich schicke die Zeile erneut an Technik mit dem Grund (Roter Lauf: Link/Lauf-Nr. aus `gh run list`); das zweite rote Mal je Vorgang geht an Sokrates (Zeile „steckt fest“).
5. An den Chef: Kern „laut, wenn im Build ein fremder Commit oder ein fehlender früherer Build liegt (dann keine Testbitte)“. Ein roter 293 über sieben noch nicht auf `main` liegenden Vorgängerbuilds ist ein fehlender früherer Build: `/home/user/bornim-main/tools/meldung.sh --laut Disponent "<Nr>: Build 286–292 freigegeben, nicht auf main; Lauf 293 rot. Keine Testbitte."`, nur wenn nicht 22–7 Uhr (Kopf meldung.sh), sonst lautlos.

**(b) Meldung/Protokoll:** wie in 5; Protokoll: `HH:MM Wache LIEGT Build 286–292 nicht auf main, 293 rot: Zeile an Technik; Chef laut`.

**Lücken:**
- Unklar, ob „fehlender früherer Build“ (Kern, Chef laut) auf diese Lage passt, oder nur auf „Build N enthält Commit von Build M, den der Chef nie getestet hat“; ich las es weit und meldete laut. Der Text sagt nicht, wie ich einen fremden Commit im Build erkenne (Werkzeug?).
- Sieben Builds, sieben Vorgänge: das Werkzeug hat nur einen Stand „freigegeben, nicht auf main“ je Vorgang, Frist 1 Tag („Frist offen“); hier 3 h. Die Wache meldet früher als das Werkzeug; die Zeile `LIEGT` kommt dann nicht von `liegt.py`.
- „Rot“: wohin die Zeile geht, steht doppelt: Werkzeug „im Build → Disponent: zurück ans Büro“; Kern „Rückläufer … Zeile an den Arbeitsplaner“; was ich dem Arbeitsplaner gebe, ist nicht gesagt.
- Wer macht aus dem roten Lauf einen Auftrag (Ursache), steht nicht.

---

## D8

**(a) Tun**
1. Vorgang lesen: `python3 tools/vorgang.py 1724`. Beleg der Freigabe: Archiv 19.11., 07:24 („wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist“): wörtlich, nicht „Build 300 freigegeben“. Lesart in eckigen Klammern in der Vorgangsdatei neben das Chefwort, weil die Vorlage sie eindeutig macht (gestern getestet = Test t300 [Build 300]); `vorgang.py chefwort` nur, wenn das Wort noch nicht in der Datei steht (steht schon, A6).
2. Auftrag mit Feld „Zurück“ prüfen: `python3 tools/vorgang.py auftrag 1724 --datei docs/vorgang/1724.md --pruefen` bzw. Abschnitt „## Auftrag“ ansehen. Ohne ihn kein Start.
3. Die Technik-Sitzung läuft an einem anderen Vorgang: kein zweiter Start (je Rolle eine Sitzung; „jeden Mitarbeiter gibt es genau einmal“ gilt als Muster; lauf.py: „Laufend … belegt, kein zweiter Start“). Zeile liegt offen; ich wecke die laufende Sitzung: `send_message` „sieh in 1724 (<Kennung>)“, Kennung aus der Ausgabe von `vorgang.py uebergabe`/`offen Technik`. Die Sitzung nimmt nach ihrem Zug an (`vorgang.py annehmen <Kennung>`) oder übergibt; Frist läuft, abgelaufen → wieder offen (`vorgang.py offen Technik --sitzungen <Datei>`).
4. Ist die Technik-Zeile 1724 ein Rückläufer des Chefs/Muss mit „jetzt“: die laufende Muss-Sitzung bitte ich per Nachricht, danach zu übergeben, nicht abzubrechen.

**(b) Meldung:** Protokoll: `HH:MM 1724 Build 300 ohne 760: Zeile an Technik offen, Wecker an <Kennung>, Sitzung arbeitet an <Nr>`. Chef: nichts (nur dreierlei).

**Lücken:**
- Der Chef beschwerte sich in L6 über das Fehlen des Wortes „Build 300 freigegeben“; mein Text sagt nicht, ob ich ihm einmal bestätige, dass die Freigabe erfasst ist (sein Chat-Wort deutet auf Bedarf). Der Kern sagt „nur dreierlei“.
- Wie ich „Technik“ und „Build-Macher“ als AN schreibe (Werkzeugname).
- Kein Wort darüber, ob ich die laufende Technik-Sitzung unterbrechen darf, wenn ein Chefwort („lass es klar ziehen“) drängt; Kern „Eilt setzt nur der Chef“: hier hat er kein Eilt gesagt.

---

## D9

**(a) Tun**
1. `python3 tools/vorgang.py offen` zeigt 1535 vor 1801. Ich prüfe zu 1801 die Datei: ist Eilt vom Chef gesetzt (Chefwort in `docs/vorgang/1801.md`)? „Eilt setzt nur der Chef.“ Beleg ja → Folge: Eilt (1801), Fund des Chefs (1535), Themenblock, Eingangszeit (1270). Das Werkzeug ordnet anders; „gilt diese Folge (Werkzeug 1796)“.
2. Ich tue die Zeilen in meiner Folge: zuerst 1801 (Wecker/Start), dann 1535, dann 1270. Sind die Besitzer verschiedene Rollen, starte ich alle sofort; ist es dieselbe Fachkraft (Profil Figur), nimmt sie 1801 zuerst und danach 1535 (Hinweis im Wecker: „zuerst 1801 (Eilt), dann 1535“).
3. Den von `lauf.py` ausgegebenen START für 1535, falls er vor 1801 kommt, führe ich erst nach dem von 1801 aus (nicht vorher) oder gebe 1535 mit `--ohne 1535:"Folge Eilt 1801 zuerst"` aus dem Lauf, bis die Fachkraft frei ist.
4. Rückläufer 1535 bekommt keine neue Nummer; er geht über die Zeile des Werkzeugs an den Arbeitsplaner/die Fachkraft („Nein, Auftrag“ und Fund des Chefs gehen als Zeile an den Arbeitsplaner; den Start, den `lauf.py` dafür ausgibt, tue ich sofort).

**(b) Protokoll:** `HH:MM Folge Eilt 1801, Fund 1535, Muss 1270 (Werkzeug-Reihenfolge anders, Kern)`. Chef: nichts.

**Lücken:**
- Wie ich die Folge gegen die Reihenfolge des Werkzeugs durchsetze (nur durch Ausführungsfolge; `--ohne` bedeutet Ausschluss), steht nicht da.
- Eilt-Beleg: Wie weise ich nach, dass der Chef Eilt setzte (`kl`-Feld heißt „Eilt“ laut 1739-Notiz, Liste: `M`)? Mein Text sagt es nicht.
- Offen: starte ich 1535 trotz laufender Fachkraft Figur (Eilt 1801 läuft) oder warte ich; „Rückläufer des Chefs“ starten laut Kern auch bei Weniger-Laufen, Eilt nicht ausdrücklich.

---

## D10

**(a) Tun**
1. Kern: „Sokrates startest du bei jeder offenen Übergabezeile an ihn (etwa ‚steckt fest‘ …)“. Zeile prüfen: `python3 tools/vorgang.py offen Sokrates` (das Werkzeug legte sie bei `rueckmeldung` an). Fehlt sie: `python3 tools/vorgang.py rueckmeldung 1694 "<Wortlaut der Fachkraft>" --sitzung Technik`.
2. Sokrates starten (START aus `lauf.py`, nicht die Fachkraft): er urteilt über das erste „steckt fest“; ich starte die Fachkraft nicht nochmal selbst (Kern: Widerspruch zu „offenem ‚steckt fest‘ → nicht starten“): `python3 tools/lauf.py --ohne-pull --ohne 1694:"steckt fest offen, Sokrates urteilt" <Seiten>`, falls lauf.py für 1694 einen Fachkraft-START ausgibt.
3. Die idle Fachkraft: nicht neu starten; sie bleibt, bis Sokrates entschieden hat (Werkzeug: „wartet, bis Sokrates löst“). Archivieren übernimmt `lauf.py` (ARCHIVIERE).
4. Stand in der Liste prüfen: `python3 tools/vorgang.py 1694` zeigt in der Kopie „ruht, bis Sa 21.11.“; ruht heißt kein Start der Fachkraft.

**(b) Meldung:** Protokoll: `HH:MM 1694 steckt fest (1. Mal, Technik, <Text>): Sokrates gestartet`. Chef: nichts (erst beim zweiten Mal, über die Chefsache).

**Lücken:**
- Kern: „das zweite desselben Vorgangs geht als Chefsache an den Chef“; hier ist es das erste. Ich weiß aber nicht, wie ich das Erste vom Zweiten unterscheide; das Werkzeug zählt (Obergrenze B), mein Text nennt die Zählregel nicht.
- „ruht, bis Sa 21.11.“ in der Liste gegen „ohne Datum gilt 21.11., abends“: Das Datum fällt auf heute; mein Text sagt nicht, wann „ruht“ endet.
- Kern sagt nichts über die Kosten (Kopf der Vorgangsdatei, 11,40 $), die bei Obergrenze B ins Spiel kommen.

---

## D11

**(a) Tun**
1. Obergrenze B (Werkzeug): zweites „steckt fest“ je Vorgang → die Vorgangsdatei zeigt „ruht, beim Chef“, Zeile an Sokrates „an den Chef: Chefsache anlegen, nicht selbst lösen“. Prüfen: `python3 tools/vorgang.py 1694` (Stand, Kosten „bisher“ im Kopf).
2. `lauf.py` gibt trotzdem START für 1694 (Fachkraft): das widerspricht einem offenen „steckt fest“ und „ruht“. Nicht starten: `python3 tools/lauf.py --ohne-pull --ohne 1694:"zweites steckt fest, ruht beim Chef (1763 B)" <Seiten>`.
3. Werkzeugfehler (START trotz „ruht“): Eingang. Erst prüfen, ob es ihn gibt (`grep -i "START.*ruht\|ruht.*START" docs/LISTE-VORGAENGE.md`); sonst `python3 tools/vorgang.py neu "lauf.py gibt START für Vorgang im Stand ruht/steckt fest zweimal (1694)" "B Werkzeuge" M "Spike"` mit Verweis auf den ähnlichen, nicht umgehen. (Kern: „Werkzeugfehler als Eingang“.)
4. Sokrates starten (offene Zeile an ihn); er legt die Chefsache-Datei an (Rückfrage mit Datei, „Beim Chef, weil: …“). Erst wenn sie steht: lautlos eine Zeile an den Chef: `/home/user/bornim-main/tools/meldung.sh Disponent "1694: zweimal steckt fest (752, 610 von 1540), Chefsache [<Nr>](cs:<Nr>)"`.

**(b) Meldung:** Protokoll: `HH:MM 1694 zweites steckt fest, ruht beim Chef, START Fachkraft mit --ohne gehalten; Sokrates gestartet`. Chef: eine lautlose Zeile nach Anlegen der Datei.

**Lücken:**
- Wer die Chefsache-Datei schreibt, sagt mein Text nicht (Kern: „eine Zeile zu einer neuen Chefsache-Datei“); ich las: Sokrates schreibt, ich melde.
- Ob der START für 1694 tatsächlich ein Werkzeugfehler ist, weiß ich nur vermutend (vielleicht ist „ruht“ noch nicht geschrieben, weil Obergrenze B das erst bei Eingang schreibt).
- Die Lage nennt „Sokrates gab den zweiten Versuch frei“; mein Text sagt nicht, ob Sokrates' Freigabe dem Disponenten als Beleg vorliegen muss.
