# Falltest Leitung (Sokrates), gespielt 21.11., 23:28–23:45

Gelesen: `lt/sockel.md`, `lt/kern-leitung.md`, `vorgang.py --help`. Stand `main` `c6f3f34d1` (21.11., 23:28).

**Vor allen Fällen (Start):** Der Kern verlangt „`docs/leitung/gedaechtnis.md` … beim Start lesen“. Die Datei gibt es nicht (`ls docs/leitung` → „No such file or directory“). Ich fange ohne Gedächtnis an und lege die Datei beim ersten Eintrag einer Lehre oder eines offenen Fadens an (Fall L6). Startmeldung im Chat: „**Sokrates** [21.11., 23:28] – <Modell>, Aufwand <Stufe>.“ Es gibt keine „Letzte Antwort“, weil es keine Übergabe gibt.

Die Umschaltung steht noch aus: `tools/1727-SCHARF` fehlt. Der Haken für Chefworte tut darum nichts. `vorgang.py chefwort` geht laut Werkzeughilfe trotzdem immer. Ich trage Chefworte also von Hand ein.

Übergabezeilen bearbeite ich immer gleich: `vorgang.py offen Sokrates`, dann `vorgang.py annehmen <Kennung>` (meine Quittung), dann die Arbeit, dann `vorgang.py erledigt <Kennung>`. Die Wecker sind die WECKER-Zeilen, die `uebergabe` ausgibt; ich sende sie per `send_message` (im Test nur aufgeschrieben). Danach committen und pushen; die Übergabezeilen pusht das Werkzeug selbst.

---

## L1 Eigener Kernentwurf, zwei Kleinbefunde eingearbeitet, der Chef wartet

1. **Tun:**
   - Ich lege noch nicht vor. Nach dem Einarbeiten startet ein **neuer** Helfer (Agent-Unterauftrag). Er bekommt den ganzen Entwurf und Zugriff auf das Repo, ohne meine Begründung. Auftrag: „Prüfe `<Datei>` gegen das Repo (Archiv, Sockel, abgenommene Kerne, Werkzeuge) und in sich: Widerspruch, Lücke, Doppelung, falscher Verweis. Je Befund Zeile und Beleg.“
   - Findet er etwas: einarbeiten und wieder einen neuen Helfer nehmen, so lange, bis eine Runde nichts Neues findet.
   - Erst danach geht die Vorlage in den Chat. Ergebnis zuerst: „**Sokrates** [21.11., HH:MM] Kern <Name> zur Entscheidung: Votum <…>; stärkstes Gegenargument <…>; Weg, der es entkräftet <…>. Gegengeprüft: `<Datei>`, <n> Byte (vorher <m> Byte; Sokrates lädt dann zusammen <s> Byte). Runde 1: Befund 1 stimmt, Befund 2 stimmt (eingearbeitet). Runde 2: nichts Neues.“
   - Die Größenangaben verlangt das Archiv vom 20.11., 16:49 („jedes Mal … will ich wissen, wie groß das alles ist“). Ist der Kern schon abgenommen, kommt die Ergänzung nur nach einem Gespräch (gleicher Eintrag).
2. **Nicht tun:**
   - Nicht jetzt vorlegen, auch wenn der Chef wartet. Der Kern sagt: „nach jedem Einarbeiten ein neuer, bis eine Runde nichts Neues findet“. Mit zwei eingearbeiteten Befunden ist diese Runde noch nicht gelaufen.
   - Keinen Zwischenstand in den Chat („Form: Im Chat nur, was der Chef entscheiden … soll“).
   - Kerne beschließe ich nicht selbst (Vorbehalt „Kerne und Profile entscheidet der Chef“).
3. **Quellen:** `kern-leitung.md` Haltung Punkt 6 und Vorbehalt; `VORGANGSARCHIV.md` 20.11., 16:49 (Kerne nicht aufblähen, Größe nennen).
4. **Nächster Schritt:** Der Helfer startet sofort. Die Vorlage folgt, sobald eine Runde sauber ist; ein Wecker ist nicht nötig, der Chef ist im Chat.
5. **Lücke:**
   - Der Text erlaubt als Ausweg „Sonst nur als ‚ungeprüfter Gedanke‘, ohne Votum“. Er sagt nicht, ob ich einem wartenden Chef den Entwurf vorab so zeigen darf. Ich tue es nicht, weil es zwei Fassungen im Umlauf schafft.
   - „Kleinbefund“ kennt der Text nicht. Kleine Befunde verkürzen die Schleife nicht.
   - Ob der Helfer auch frühere Fassungen sehen darf, sagt der Text nicht; ich gebe ihm nur die aktuelle.

## L2 Helfertext: „Stärkstes Gegenargument: Das verzögert Kapitel 1, gegen die Oberste Direktive.“

1. **Tun:**
   - Ich übernehme den Satz nicht. Nachgesehen: Die Oberste Direktive gilt in dieser Form nicht mehr (Archiv 20.11., 11:45, Chef: „in der Form eh nicht mehr wollte, weil sich Prioritäten durch … die Reihung der Themenblöcke ja ergibt“). Ihr Nachfolger ist das Oberste Ziel im Sockel (Archiv 20.11., 12:06, „Passt so.“).
   - Ich formuliere das stärkste Gegenargument neu, gemessen am Obersten Ziel („den Spieler begeistern … fehlerfrei … fesselt“) und an der Reihenfolge der Themenblöcke. Zum Beispiel: „bindet Arbeit, die einem höheren Themenblock fehlt“ oder „bringt dem Spieler nichts Sichtbares“, je nach Votum belegt mit Blocknummer und Quelle.
   - Dann der Weg, der dieses Argument entkräftet.
   - Legt das Votum etwas fest (Regel, Ablauf, Werte, Werkzeug), gilt die Schleife aus L1 mit einem frischen Helfer gegen den ganzen Entwurf.
   - Der Befund an den Helfer, nur in meiner Antwort an ihn: veralteter Maßstab.
2. **Nicht tun:**
   - „Oberste Direktive“ nicht an den Chef geben. Der Satz ist nicht belegt, die Direktive ist ersetzt, und „Kapitel 1“ steht nicht im Sockel. Das wäre ein Fehler, den der Chef als Erster findet („Was der Chef als Erster findet, ist dein Fehler“).
   - Den Satz nicht stillschweigend wegglätten und ihn auch nicht als Chefwort ausgeben („Chefworte nur wörtlich mit Zeit und Quelle“).
3. **Quellen:** `sockel.md` Kopf (Oberstes Ziel); `VORGANGSARCHIV.md` 20.11., 11:45 und 12:06; älter 18.10. (179) und 31.10. (418), beide ersetzt.
4. **Nächster Schritt:** Sofort; die Vorlage folgt erst mit dem neuen Gegenargument.
5. **Lücke:**
   - Der Kern sagt „Maßstab jeder Idee: das oberste Ziel im Sockel“ und „vorher Bestand und Archiv suchen“, aber nicht, wie ich mit einem Helfer umgehe, der einen veralteten Maßstab einbringt.
   - Ob man die Lehre („Helfer kennt nur alte Direktive“) als Werkzeugsperre vorschlägt, sagt der Text erst bei Wiederholung („Wiederholt sich eine Lehre“). Vorerst kommt sie nur ins Gedächtnis.

## L3 Offene Zeile „Frage“ von der Werkstatt (Profil Kampf): „760 Rückläufer t298.7 gebaut `be2c0d8f0`, Messung 5 von 5 Bissen am Körper. Ein Filmlauf frei?“

1. **Tun:**
   - Zuerst `vorgang.py offen Sokrates`, dann `vorgang.py annehmen <Kennung>`.
   - Nachsehen mit `python3 tools/vorgang.py 760`. Ergebnis:
     - Stand „ruht, nach Arena (1714), t300.11 Fail“, wartet auf 1589.4.
     - Archiv 18.11., 22:17 (1714), Chef: „nicht nur ruhen lassen bis Samstag 20 Uhr, sondern bis wir das geklärt haben, wie wir das neue Kampfarrangement machen mit den Plätzen und den Bewegungen“.
     - Genau dieser Lauf wurde schon am 18.11., 21:03 freigegeben. Er scheiterte als t300.11 (Archiv 18.11., 22:12, „Also sorry. Fail.“). Die Messung 5 von 5 widersprach dem Film.
     - Danach war die Freigabe 21:03 ein Verstoß (Archiv 18.11., 22:13, „vor jeder Lauffreigabe 1605 prüfen“).
     - Dazu Archiv 21.11., 20:06: „Tom und Jerry machen nur mal fertig, was sie jetzt noch offen haben … Ansonsten machen sie nichts.“
   - Antwort ist **Nein**, als Zeile zurück an die Werkstatt:
     `vorgang.py uebergabe 760 "Werkstatt Kampf" "nein: kein Filmlauf. 760 ruht bis zur Arena 1589.4 (Chef 18.11., 22:17, Archiv 1714). Dieselbe Bitte (be2c0d8f0, 5 von 5) wurde am 18.11., 21:03 freigegeben und scheiterte als t300.11 (Chef 22:12 „Fail“): Die Messung widerspricht dem Film. Nichts weiter an 760, Zweig ruht."`
     Wecker an die Werkstatt nach der WECKER-Ausgabe: „sieh in 760 (<Kennung>)“.
   - Den Fund außerhalb des Auftrags meldet eine Zeile ans Büro:
     `vorgang.py uebergabe 760 Disponent "Hinweis: Werkstatt Kampf arbeitet an 760, obwohl er ruht (1714, wartet auf 1589.4; Chef 21.11., 20:06 nichts Neues für Teams). Bitte Startgrund prüfen; Text der Frage gleicht der Bitte vom 18.11., 21:02."`
   - Dann `vorgang.py erledigt <Kennung>`.
   - Archiv: kein neuer Entscheid. Das Nein bestätigt nur 1714, ein Eintrag wäre eine Abschrift.
2. **Nicht tun:**
   - Keinen Lauf freigeben: 1714 ist eine Chefweisung, und gleiche Messung bei gleichem Commit bringt dasselbe Ergebnis.
   - Den Chef nicht fragen; das Nein ist vollwertig („Zu Idee oder Frage ist ‚Nein‘ vollwertig“).
   - Die Werkstatt nicht selbst anhalten oder umsteuern; Vorrang gehört dem Büro.
3. **Quellen:** `vorgang.py 760` (Liste und Archiv 18.11., 21:03, 22:12, 22:13); `vorgang.py 1714`, 1589.4; `VORGANGSARCHIV.md` 21.11., 20:06.
4. **Nächster Schritt:** Sofort. Werkstatt und Disponent weckt je ein Wecker aus der Ausgabe von `uebergabe`.
5. **Lücke:**
   - Der Kern sagt nicht, **wie** ich eine „Frage“ beantworte: als Rückzeile über `uebergabe`, als `rueckmeldung` oder per Nachricht. Ich nehme `uebergabe`, weil „Nachricht nur Wecker“ (Werkzeughilfe 1760) gilt.
   - Der genaue Empfängername für `AN` („Werkstatt Kampf“, „Disponent“ oder Rollenname aus der Besetzung) steht weder im Kern noch in der Hilfe. Das Werkzeug liest die Kennung aus `ARBEIT-BESETZUNG.md`, und `rueckmeldung.py` sagt, „Disponent“ sei bis zur Umschaltung Ford.

## L4 Chef im Chat: „1535, ein Lauf frei.“

1. **Tun:**
   - Erst nachsehen (`vorgang.py 1535`). Archiv 21.11., 20:31: genau dieses Chefwort, „genau ein weiterer Bildlauf für Tom nach berichtigtem Bildskript“. Archiv 21.11., 21:40: „1535, Flanke gebilligt“ (👍), Stand „gebaut, Geprüft an: bfd783a3c (Bild 👍 21:40)“.
   - **Fall a: das Wort fällt vor 20:31 oder ist neu, mit Bitte und Votum davor.** Dann ist es ein Auftrag des Chefs, und ich trage ihn in derselben Antwort ein:
     - Archiv oben: `- **1535, ein Lauf frei** (21.11., HH:MM, Chef an Sokrates: „1535, ein Lauf frei.“) → **genau ein Bildlauf für die Werkstatt Figur nach <Bitte>; selbst ansehen, dann an den Chef; scheitert er, kein zweiter (Nutzer)**`
     - Danach `vorgang.py chefwort 1535 "1535, ein Lauf frei." --zeit "21.11., HH:MM" --sitzung Sokrates`. Das schreibt den Wortlaut in `docs/vorgang/1535.md` und legt eine offene Zeile an den Arbeitsplaner an, der den Auftrag schreibt. Wecker gemäß WECKER-Zeile.
     - Commit und Push für das Archiv.
     - Chat: nichts außer, falls nötig, „**Sokrates** [..] 1535 Kleidung hängt bei NPCs an einer Hand: ein Lauf eingetragen.“
   - **Fall b: das Wort fällt jetzt (21.11. abends, nach 21:40).** Dann ist der Auftrag unklar, weil 1535 gebilligt ist und der Lauf von 20:31 verbraucht. Ich frage einmal zurück, Ergebnis zuerst:
     „**Sokrates** [21.11., HH:MM] 1535 Kleidung hängt bei NPCs an einer Hand: seit 21:40 gebilligt (👍, `bfd783a3c`), der Lauf von 20:31 ist verbraucht. Wofür der neue Lauf?“
     Das Chefwort selbst trage ich trotzdem gleich mit `chefwort` in die Vorgangsdatei ein, weil jedes Chefwort in derselben Antwort eingetragen wird. Den Archiveintrag mache ich erst mit der Antwort.
2. **Nicht tun:**
   - Den Lauf nicht selbst bei der Werkstatt bestellen; Aufträge schreibt der Arbeitsplaner.
   - Kein Lauf ohne Bedingungen des letzten Chefurteils.
   - Keinen zweiten Archiveintrag, wenn es nur das Wort von 20:31 ist.
3. **Quellen:** `vorgang.py 1535`; `VORGANGSARCHIV.md` 21.11., 20:31 und 21:40; Archiv 21.11., 20:06 (Teams beenden Laufendes; 1535 läuft, also kein Hindernis); 1605/1714 betreffen 1535 nicht (Block Figuren, kein Kampf).
4. **Nächster Schritt:** Sofort. Den Arbeitsplaner weckt der Wecker aus `chefwort` bzw. `uebergabe`.
5. **Lücke:**
   - Der Kern sagt „einen Auftrag als Vorgang über den Eingang des Büros“. Ein Werkzeugbefehl „Eingang“ steht nicht in der Hilfe. Für einen bestehenden Vorgang eines anderen passt `chefwort`, das an den Arbeitsplaner geht, nicht an den Disponenten. Ob „Eingang des Büros“ das meint, ist offen.
   - Ob der Kern eine Lauffreigabe als Auftrag oder als Entscheid zählt, sagt er nicht; ich mache beides (Archiv und Chefwort).
   - Die Regel „vor jeder Lauffreigabe 1605 prüfen“ (Archiv 18.11., 22:13) steht nicht im Ladetext.

## L5 Offene Zeile „steckt fest“ (vom Werkzeug angelegt): „Notizkopie alt, 51 eigene Commits, 603 fehlen. Reset auf origin/main?“

1. **Tun:**
   - `annehmen <Kennung>`, dann nachsehen:
     - Archiv 18.11., 20:27 „Kein Reset der Notizkopie bei Perikles“, mit **denselben Zahlen 51/603** → „keine Freigabe; … prüft `backup-lokal-main` auf Ungepushtes, dann archiviert Ford ihn; tritt die alte Kopie wieder auf: Vorgang an Spike“.
     - Daraus entstand 1701 (Spike), Stand „gebaut, Geprüft an: 9f6e4c4a8“. `tools/notiz.sh` Zeilen 41–51 sichert seither eine alte Kopie selbst: Sind alle ungepushten Commits älter als 2 h, legt es den Zweig `backup-alt-<Zeit>` an und setzt auf `origin/main`.
   - Antwort als Zeile an die Fachkraft:
     `vorgang.py uebergabe <Nr> "<Absender aus der Zeile>" "nein, kein Reset von Hand. tools/notiz.sh noch einmal aufrufen: Es sichert eine alte Kopie als Zweig backup-alt-<Zeit> und setzt selbst auf origin/main (1701). Danach im Sicherungszweig prüfen, ob Eigenes ungepusht ist, und es nur dann auf main nachtragen. Meldet notiz.sh keine Sicherung: Ausgabe von git -C ../bornim-main log -1 origin/main..HEAD als neue Rückmeldung."`
   - Weil die alte Kopie wieder auftrat (die Folge, die das Archiv vom 18.11. vorsieht): `vorgang.py uebergabe 1701 Spike "Hinweis: alte Notizkopie wieder aufgetreten (51 eigene, 603 fehlende, Zeile <Kennung>); Sicherung aus notiz.sh griff nicht oder lief nicht."` Spike ist Besitzer laut Liste. Gleichen die Zahlen nur dem Fall vom 18.11. und ist die Zeile alt, schreibe ich das in den Hinweis.
   - `vorgang.py erledigt <Kennung>`.
2. **Nicht tun:**
   - Den Reset nicht freigeben und nicht selbst ausführen. Ich schreibe nur Notizen, und der Chef hat am 18.11. bei denselben Zahlen „keine Freigabe“ entschieden.
   - Nicht den Chef fragen: Es ist das erste „steckt fest“, und das Archiv deckt den Fall ab.
3. **Quellen:** `VORGANGSARCHIV.md` 18.11., 20:27; `vorgang.py 1701`; `tools/notiz.sh` Z. 41–56 (auch der Hinweis 236 dort: Sicherung `backup-lokal-main` vor Reset); `LISTE-VORGAENGE-ARCHIV.md` 1778.
4. **Nächster Schritt:** Sofort; Fachkraft und Spike weckt je ein Wecker.
5. **Lücke:**
   - Die Zeile nennt keine Vorgangsnummer, `uebergabe` braucht aber `NR`. Welche Nummer gilt, sagt der Text nicht; ich nehme die der Zeile in `docs/vorgang/NR.md`.
   - Ob ein zweites „steckt fest“ zu demselben Hindernis Obergrenze B auslöst, entscheidet das Werkzeug, nicht ich.
   - Sockel 8 sagt „Verlauf umschreiben“ nie; ob ein Reset der eigenen Kopie mit Sicherung darunter fällt, sagt der Text nicht.

## L6 (K1.1) Chef 19.11., 07:24: „wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist … lass es klar ziehen“; dazu: „wenn du einmal geschrieben hättest, Build 300 freigegeben, hätte ich es gleich gewusst“

1. **Tun (in derselben Antwort):**
   - Klären, welcher Build gemeint ist: der „gestern getestete“, also Build 300 (Test 18.11., Funde t300.x). Sein zweiter Satz bestätigt es.
   - Archiv oben:
     `- **Build 300 freigegeben ohne 760** (19.11., 07:24, Chef an Sokrates: „wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist … lass es klar ziehen“; dazu: „wenn du einmal geschrieben hättest, Build 300 freigegeben, hätte ich es gleich gewusst“) → **Build 300 auf main ohne 760 (Wolfssprung); Worte an den Chef in seiner Sprache, nie Kürzel (Nutzer)**`
   - Auftrag über das Büro: `vorgang.py chefwort <Nr> "wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist … lass es klar ziehen" --zeit "19.11., 07:24" --sitzung Sokrates`. Für `<Nr>` gibt die Hilfe von `chefwort` „‚Build N‘ … = alle Vorgänge mit Build N“; ich nenne die Freigabe aber besser an **einem** Vorgang. Gibt es keinen, lege ich einen an: `vorgang.py neu "Von Chef (19.11., 07:24, über Sokrates): Build 300 auf main ohne 760: 760 aus claude/build-300 zurücknehmen, grüner Lauf, zusammenführen" "Q QS" M "<Build-Macher>"`. Dann den Wortlaut mit `chefwort` dort hinein; die offene Zeile an den Arbeitsplaner folgt automatisch, mit Wecker. Der Build-Macher führt zusammen (Archiv 21.11., 15:15: „ab der Umstellung führt der Build-Macher zusammen“).
   - 760 bleibt beim Besitzer; sein Stand ändert sich nicht (ruht).
   - Antwort an den Chef, Ergebnis zuerst und in seiner Sprache: „**Sokrates** [19.11., 07:2x] **Build 300 freigegeben**, ohne 760 (Wolfssprung). Er kommt auf main, sobald 760 herausgenommen und der Lauf grün ist; ich melde ‚Build 300 ist auf main‘.“
   - Gedächtnis (`docs/leitung/gedaechtnis.md` anlegen, unter 3 KB), Lehre: „An den Chef in seinen Worten (‚Build 300 freigegeben‘), nie Kürzel wie Nummern einer PR oder t-Punkte allein (19.11., 07:24).“ Wiederholt sie sich, schlage ich eine Werkzeugsperre vor.
   - Commit und Push (Archiv, Gedächtnis); mit Telegram-Zeile `meldung.sh Sokrates "Build 300: freigegeben ohne 760 (Wolfssprung); auf main nach grünem Lauf."`
2. **Nicht tun:**
   - Den Zusammenschluss nicht selbst bauen („Du schreibst Notizen, keinen Spielcode“).
   - Keine Kürzel wie „PR 221“ oder „1724“ allein in der Antwort an den Chef.
   - Seine Kritik nicht umformulieren; sie steht wörtlich im Archiv.
   - Das ist kein Release in den Laden (Vorbehalt Release), sondern eine Freigabe auf `main`. Ich mache daraus keinen Release.
3. **Quellen:** `VORGANGSARCHIV.md` 19.11., 07:24 (so damals eingetragen); `vorgang.py 1724` (damals Spike, erledigt `3db05d4e5`); Archiv 21.11., 15:15; `vorgang.py 760`.
4. **Nächster Schritt:** Sofort. Den Arbeitsplaner weckt der Wecker aus `chefwort`; die Meldung „auf main“ folgt, wenn die Rückmeldung „fertig“ und das Ja des Prüfers eingehen (laut `rueckmeldung.py` erst an den Disponenten, dann an den Chef).
5. **Lücke:**
   - „Eingang des Büros“ ist wieder nicht definiert (siehe L4).
   - Der Kern sagt nicht, ob eine Freigabe ein Auftrag oder ein Entscheid ist; ich trage beides ein.
   - Wer bei einer „Freigabe mit Einschränkung“ den Build umbaut, steht nicht im Ladetext, nur im Archiv (21.11., 15:15).

## L7 (K2.1) Testergebnis Build 299: „299.3 ✗ siehe Chat“; Chat 15:33 „zieht sich da auch wieder irgendwas von der Jacke“, 15:59 „Das sieht man ja die Beule direkt“ (1535, Garrick und Kittel)

1. **Tun:**
   - Zuerst die Chatworte vollständig mit Zeit holen (Ausschnitt 15:33 Garrick in der Grußbewegung, 15:59 Bild Dorfplatz, Bewohner im Kittel).
   - Beide Chefworte wörtlich zum Vorgang des fremden Besitzers:
     `vorgang.py chefwort 1535 "bei Garrick gesehen, wenn der so eine Ruhebewegung macht, irgendwie den rechten Arm zum Gruß hebt, dann zieht sich da auch wieder irgendwas von der Jacke. Also da haben wir auch so einen Faden" --zeit "18.11., 15:33" --sitzung Sokrates`
     `vorgang.py chefwort 1535 "natürlich zupft es immer noch die Klamotten weg. Das sieht man ja die Beule direkt. Also bei der Draufsicht links." --zeit "18.11., 15:59" --sitzung Sokrates`
     Jeder Aufruf legt eine Zeile an den Arbeitsplaner an, mit Wecker. Der Arbeitsplaner schreibt den Rückläufer-Auftrag mit Systemfrage („jede Ruhebewegung mit gehobenem Arm, nicht nur Garrick“).
   - Das Ergebnis „299.3 ✗“ selbst gehört in die Prüfliste `ansehen/t299-….md` unter „## Ergebnis“. Danach setzt `vorgang.py build 299` 1535 auf startbar, mit Fund beim Besitzer. Das trägt der Build-Macher bzw. das Büro aus (nicht meine Spalte).
   - Archiv oben (Fund = Urteil des Chefs): `- **1535, t299.3 ✗** (18.11., 15:33/15:59, Chef: „zieht sich da auch wieder irgendwas von der Jacke“, „Das sieht man ja die Beule direkt“) → **Kleidung zieht in der Ruhebewegung mit gehobenem Arm (Garrick, Bewohner im Kittel), Rückläufer (Nutzer)**`
   - Lehre: Der Chef fand es als Erster, also „dein Fehler“. Eintrag im Gedächtnis: „Bild alt gegen neu je Ruhebewegung mit gehobenem Arm, bevor ein Kleidungsfund in einen Build geht.“ Dazu `vorgang.py lehre roh 1535 "Fund t299.3 durch Chef" "Prüfung achsel_1515 misst gehobenen Arm nicht; jede Ruhebewegung messen, nicht nur eine Figur"`.
   - Chat: nichts, außer der Chef fragt.
2. **Nicht tun:**
   - Nicht selbst die Ursache suchen und keinen Lauf freigeben, bevor die Ursache nachgestellt ist.
   - Den Fund nicht umformulieren.
   - Kein neuer Vorgang: Der Fund gehört zu 1535, das Thema ist dasselbe.
3. **Quellen:** `vorgang.py 1535` (Zu-Absätze 18.11., 15:33, 15:59, Automatik B); Werkzeughilfe `build N`, `chefwort`, `lehre roh`.
4. **Nächster Schritt:** Sofort. Den Arbeitsplaner weckt der Wecker; die Werkstatt Figur (Besitzer Tom) bekommt den Auftrag vom Arbeitsplaner.
5. **Lücke:**
   - Wer `vorgang.py build 299` ausführt, sagt der Ladetext nicht.
   - Ob ein Fund ein „Auftrag“ (Eingang des Büros) oder ein „Entscheid“ (Archiv) ist, sagt der Kern nicht; ich mache beides.
   - Die Lehre schreibt die Hilfe automatisch „bei Rückmeldung und Schließen“; ob ich sie von Hand doppelt anlege, ist offen.

## L8 (K2.8) Telegram: 👍 des Chefs auf „1535 Garrick alt gegen neu“ (Unterschied sichtbar, Prüfer sagte „ja“)

1. **Tun:**
   - Nachsehen: Das Archiv hat den Eintrag schon (21.11., 21:40, „1535, Flanke gebilligt“, „👍 auf Meldung 21:39, Nachricht 4817, 4818“), der Stand ist „gebaut, Geprüft an: bfd783a3c (Bild 👍 21:40)“.
   - Ist er da: nichts doppelt.
   - Fehlt er (neues 👍): Archiv oben `- **1535, Flanke gebilligt** (21.11., HH:MM, Chef 👍 in Telegram auf Meldung „1535 Garrick alt gegen neu“, Nachricht <n>) → **Beule an der Flanke bei gehobenem Arm behoben, alt gegen neu `<Commit>`; fährt im nächsten Testbuild (Nutzer)**`, dazu `vorgang.py chefwort 1535 "👍" --zeit "21.11., HH:MM" --sitzung Sokrates`. Die Zeile an den Arbeitsplaner geht weiter an den Disponenten, der 1535 in den nächsten Testbuild aufnimmt.
   - Der Vorgang bleibt offen, bis der Testbuild geprüft ist (Durchstich 1631 offen). Ein 👍 auf ein Bild ist nicht der Test des Chefs im Build.
2. **Nicht tun:**
   - 1535 nicht schließen (`schliessen`/`fertig`): Spielcode kommt nur mit Test des Chefs nach `main` (Sockel 8).
   - Kein Dank, kein Chat.
3. **Quellen:** `VORGANGSARCHIV.md` 21.11., 21:40; `vorgang.py 1535`.
4. **Nächster Schritt:** Keiner von mir; der Testbuild ist Sache des Büros.
5. **Lücke:** Der Kern sagt nicht, ob ein 👍 auf Telegram als „Entscheid“ gilt oder als Chefwort für `chefwort`. Die Werkzeughilfe nennt 👍 nur bei `build N` für „tN.k“-Meldungen.

## L9 (K3.3) Erste offene Zeile „steckt fest“ zu 1694 (Griff, Werkzeug Spike): „Prüfung nach Ursache und Behebung rot, 752 von 1540 Fehler, Commit `04bf8ffc1`, versucht: Handgelenk-Ausrichtung, Fingergewichte.“

1. **Tun:**
   - `annehmen <Kennung>`.
   - Lesen: `docs/vorgang/1694.md` (Auftrag, Rückmeldungen), `vorgang.py 1694`, `vorgang.py lehre bereich 1694`. Aus der Liste: Chef 18.11., 17:01 „Als Systemlösung, genau“. Aus dem Archiv 19.11., 07:46: „nächster Lauf ab Sa 21.11., 20:00 als Auftrag mit Systemfrage, nach Nachstellen am Einzelbild“.
   - **Entscheid (erstes „steckt fest“ trage ich; B: „einmal an Sokrates, danach an den Chef“): ein zweiter Versuch, mit anderem Ansatz.** Zwei Stellschrauben (Ausrichtung, Gewichte) haben nichts Grundsätzliches geändert, also nicht weiter an Gewichten drehen.
   - Zeile an den Arbeitsplaner:
     `vorgang.py uebergabe 1694 Arbeitsplaner "zweiter Versuch frei (Sokrates, erstes steckt fest): 1) die 752 Fehler nach Gegenstand, Hand, Haltung und Fehlerart gruppieren und die größte Gruppe an einem Einzelbild nachstellen, bevor gebaut wird; 2) prüfen, ob die Prüfung richtig misst (Stichprobe der Fehler am Bild); 3) Ansatz nach Systemfrage: wie lösen es andere (Griffpunkt-Socket je Gegenstand plus feste Fingerpose je Griffart statt Gewichte); 4) zurück: Commit, Zahl vorher/nachher, Bild einer Fehlergruppe. Scheitert er, kein dritter: zweites steckt fest geht an den Chef."`
     Wecker an den Arbeitsplaner.
   - Archiv oben: `- **1694, zweiter Versuch** (21.11., HH:MM, Sokrates auf steckt fest, 752 von 1540, `04bf8ffc1`) → **ein Versuch mit anderem Ansatz: Fehler gruppieren und am Einzelbild nachstellen, Prüfung selbst prüfen, Griffpunkt je Gegenstand; kein dritter (Sokrates)**`
   - Vorrang: Archiv 21.11., 20:06 (Werkzeuge 1727 zuerst) und 21:54 (1784: Spike-Starts heute Nacht nur an 1739). Der Versuch ist frei, wann er läuft, entscheidet das Büro. Heute Nacht kein Spike-Start dafür; das steht in der Zeile an den Arbeitsplaner.
   - `erledigt <Kennung>`.
2. **Nicht tun:**
   - Nicht an den Chef: Das erste „steckt fest“ trage ich.
   - Nicht selbst bauen oder messen.
   - Keine Chefsache.
   - 1784 nicht übergehen.
3. **Quellen:** `vorgang.py 1694` (Liste, Archiv 18.11., 17:38, 21:37, 23:41; 19.11., 07:46); `VORGANGSARCHIV.md` 21.11., 14:37 (B), 20:06, 21:54 (1784); `tools/rueckmeldung.py` (MAX_FEST = 2).
4. **Nächster Schritt:** Sofort; der Arbeitsplaner per Wecker; der Start nach Vorrang des Büros.
5. **Lücke:**
   - Der Kern nennt das Verfahren bei „steckt fest“ nicht. Die Regel B steht nur im Archiv (21.11., 14:37) und im Werkzeug.
   - Ob mein Entscheid über einen zweiten Versuch ins Archiv gehört („einen Entscheid, auch deinen“), ja; ob er dem Chef zum Billigen vorgelegt wird („im Zweifel legst du es ihm zum Billigen vor“), sage ich nein, weil kein Zweifel besteht.
   - „Werkzeug Spike“ gegenüber „Werkstatt“ ist im Ladetext nicht geklärt.

## L10 (K3.6) Zweite offene Zeile „steckt fest“ zu 1694: „wieder rot, 610 von 1540, Commit `d8dce68a2`, versucht: Griffpunkt je Waffe.“

1. **Tun:**
   - `annehmen <Kennung>`. Das Werkzeug hat 1694 auf „ruht, beim Chef“ gesetzt; die Zeile sagt „an den Chef: Chefsache anlegen, nicht selbst lösen“ (Obergrenze B, `rueckmeldung.py`). Archiv 21.11., 20:59: „es wird was angelegt für die Chefsache und du trägst es mir vor.“
   - Chefsache anlegen: `docs/chefsache/entscheiden/1694-griff.md`, mit Zeile „Beim Chef, weil: zweites steckt fest (Obergrenze B)“. Inhalt:
     - Lage: 752 → 610 von 1540, also besser, aber rot. Zwei Versuche: Ausrichtung und Gewichte; dann Griffpunkt je Waffe.
     - Votum: <je nach Gruppierung, z. B. „Prüfgrenze am Bild prüfen, dann feste Fingerposen je Griffart“>.
     - Stärkstes Gegenargument: <z. B. „feste Posen sehen steif aus“>.
     - Weg, der es entkräftet.
     - Wahl: A anderer Ansatz, B Prüfung lockern nach Bild, C zurückstellen hinter Block <n>.
   - Chat: „**Sokrates** [21.11., HH:MM] **1694 Griff einmal für alle gehaltenen Dinge** steckt zum zweiten Mal fest (610 von 1540 rot). Chefsache 1694: A, B oder C, Votum A.“
   - Telegram `meldung.sh Sokrates "1694 Griff einmal für alle gehaltenen Dinge: zweites steckt fest, 610 von 1540 rot (d8dce68a2). Chefsache [1694](cs:1694): A anderer Ansatz, B Prüfgrenze, C zurückstellen; Votum A." --laut`
   - `erledigt <Kennung>`; Commit und Push der Chefsache.
2. **Nicht tun:**
   - Keinen dritten Versuch freigeben (B; „nicht selbst lösen“).
   - Nichts an der Werkstatt vorbei.
   - Kein Archiveintrag, bevor der Chef entschieden hat.
3. **Quellen:** `tools/rueckmeldung.py` Kopf (A, B, RUHT); `VORGANGSARCHIV.md` 21.11., 14:37, 20:59; `vorgang.py 1694`.
4. **Nächster Schritt:** Sofort; der Chef im Chat plus Telegram laut. Nach seinem Wort: Archiv, Chefsache löschen, Zeile an den Arbeitsplaner.
5. **Lücke:**
   - Den Aufbau einer Chefsache-Datei (`MUSTER.md`) kennt der Ladetext nicht, und `docs/chefsache/` darf ich hier nicht lesen.
   - Ob eine Chefsache zu einem Vorgang (keine Regel) die Gegenprüfung durch Helfer braucht, sagt der Kern nur für „Was etwas festlegt“. Ich zähle sie nicht dazu und lege ohne Helfer vor. Das ist strittig: legt das Votum eine Prüfgrenze (Werte) fest, gilt die Schleife aus L1.
   - Der Kern sagt „In `docs/chefsache/` gehört nur, was der Chef jetzt entscheiden … kann“; das ist hier erfüllt.

---

## Übergreifende Lücken

1. Die Gedächtnisdatei `docs/leitung/gedaechtnis.md` fehlt, obwohl der Kern sagt „beim Start lesen“.
2. „Eingang des Büros“ ist im Werkzeug nicht als Befehl vorhanden (`neu`, `chefwort` oder `uebergabe … Disponent`?).
3. Der Ladetext nennt das Verfahren bei „steckt fest“ und „Frage“ nicht (Obergrenze B, Antwortweg). Es steht nur im Archiv und in `rueckmeldung.py`.
4. Die Empfängernamen für `uebergabe AN` (Profil gegen Rolle) fehlen im Ladetext.
5. Der Haken für Chefworte ist nicht scharf (`tools/1727-SCHARF` fehlt), also ist alles von Hand einzutragen; der Kern setzt die Umschaltung stillschweigend voraus.
6. Vorrangregeln des Chefs (1605, 1714, 20:06, 1784) stehen nicht im Ladetext. Ohne Archivsuche hätte ich L3 und L9 falsch beantwortet.
