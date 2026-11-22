# 1727 · Falltest Lauf 4 · Leitung (Sokrates)

Geladen: `sockel.md` (1.178 B), `kern-leitung.md` (2.926 B), `gedaechtnis.md` (2.904 B). Kein weiteres Profil geladen (der Kern lädt nur „Chefrunde“ und „Markt/Recherche“ auf Zuruf; in keinem Fall gerufen). Repo nur lesend: Umschalt-Kopie `kopie/` (`8e3f182b1`). Alle Schreibschritte sind beschrieben, nicht ausgeführt. `HH:MM` = Uhrzeit des Falls, `<K>` = Kennung der Zeile aus `vorgang.py offen Sokrates`.

Gemeinsam für alle Fälle, weil der Kern es verlangt: Was an die Leitung geht, lese ich zuerst (Kern: „Was an die Leitung geht, liest du zuerst.“). Jedes Chefwort und jeden Entscheid, auch meinen, trage ich in derselben Antwort ein (Kern „Chefworte“). Notizen schreibe ich mit Edit/Write in `docs/…`, Commit und Push auf `main`.

## L1

(a) Was ich tue
1. Kern = Ladetext und legt etwas fest. Vor der Vorlage prüfe ich, ob die Lehren erfüllt sind:
   - „Nie im Umbau 1727 Eingearbeitetes ungeprüft vorlegen; stattdessen Nachprüfung, bis eine Runde nichts Neues findet“: die letzte Runde fand zwei Befunde, also ist sie nicht leer. Ich lege **noch nicht** vor.
   - „Nie einen Prompt vorlegen, der nur gelesen wurde; stattdessen erst nach festen Fällen aus echten Vorkommnissen“: Ein Kern ist ein Prompt. Ich prüfe, ob es für diesen Kern einen Falltest gibt; wenn nicht, gehört er vor die Vorlage.
   - „Nie eine Regelzeile neu schreiben; stattdessen nur die genannte Stelle ändern“: ich sehe nach, dass die beiden Befunde nur an ihren Stellen eingearbeitet sind: `git diff <Commit vor Einarbeitung>..HEAD -- <Entwurf>`.
   - „Nie einen Befund eines Helfers … ungeprüft“: beide Befunde habe ich an der Quelle nachgesehen (Zitat und Fundstelle im Repo); falls nicht, jetzt.
2. Byte und Ladesumme vorher und nachher: `python3 tools/ladesumme.py` (Kern Leitung heute 2.926 von 3.000 B) und `wc -c <Entwurf>`.
3. Frischer Helfer für die nächste Runde (Hilfssitzung, nicht gestartet). Auftrag: „Prüfe `<Entwurf Kern>` gegen das Repo (`docs/VORGANGSARCHIV.md`, Werkzeuge mit `--help`, Sockel) und gegen den ganzen Entwurf, ohne frühere Befunde und ohne Begründung des Verfassers. Erst je Zeile die Art (Regel, Ablauf, Wert, Werkzeug, Verweis), dann den Inhalt. Raster Einheit × Auslöser bis Empfänger über den ganzen Entwurf, Vollständigkeit per grep. Prüfe gegen den gültigen Text, nie gegen alte Rollendateien oder `CLAUDE.md`. Je Befund: Zitat, Quelle, Vorschlag.“ Ergebnis: jeden Befund an der Quelle nachsehen, je Befund „stimmt/Einwand/Frage“; Stimmiges nur an der Stelle einbauen; neue Runde, bis eine Runde nichts findet.
4. Falltest, falls keiner: feste Fälle aus echten Vorkommnissen (Archiv, Vorgangsdateien), eine Spielsitzung je Profil mit nur dem Ladetext, Auswertung gegen Soll.
5. Dann Vorlage als Chefsache (Kerne sind Vorbehalt des Chefs): `docs/chefsache/billigen/` oder `entscheiden/` nach `docs/chefsache/MUSTER.md`, Votum, stärkstes Gegenargument, Weg, der es entkräftet; `python3 tools/vorlage_pruefen.py <Datei>`.

(b) Chat
Solange die Runde läuft: nichts (Kern „Form“: „Im Chat nur, was der Chef entscheiden, tun, prüfen oder billigen soll“). Bei der Vorlage:
„**Kern <Name> zum Billigen:** `<Datei>`. Byte vorher 2.926, nachher <n>; Ladesumme vorher <x>, nachher <y>. Gegengeprüft: `<Entwurf>` (3 Runden, letzte ohne Befund); Runde 1: Befund 1 stimmt, Befund 2 stimmt. Falltest: <n> Fälle, <m> wie Soll. Votum: so billigen. Stärkstes Gegenargument: <…>; entkräftet durch <…>.“

(c) Lücken
- Der Kern sagt nicht, ob ich dem wartenden Chef einen Zwischenstand gebe; „Im Chat nur, was der Chef entscheiden … soll“ verbietet ihn praktisch. Ob „Der Chef wartet“ eine Ausnahme ist, steht nirgends.
- „Nachprüfung, bis eine Runde nichts Neues findet“ gilt laut Gedächtnis „nur 1727, Chef 22.11., 10:39“; ob ein Kern nach der Umstellung noch „Umbau 1727“ ist, bleibt offen.
- Wo Kerne zum Billigen liegen (`billigen/` oder `entscheiden/`) und ob sie vorher als Datei unter `docs/profile/` stehen, sagt mein Text nicht.

## L2

(a) Was ich tue
1. Lehre: „Nie einen Befund eines Helfers … ungeprüft als eigenen weitergeben“. Ich prüfe das Gegenargument an der Quelle.
2. „Oberste Direktive“ und „Kapitel 1“ stehen nicht in meinem Sockel. Dort steht das **Oberste Ziel** („den Spieler begeistern …“), im Kern „Qualität vor Eile“. Der Begriff stammt aus der alten `CLAUDE.md` (in der Kopie: `grep -n "Oberste Direktive" CLAUDE.md`, nur zum Beleg, nicht als Maßstab). Lehren: „Nie gegen alte Rollen prüfen lassen; stattdessen gegen den gültigen Text (1933)“ und „Nie Vorrang aus `CLAUDE.md` oder Helfertext; stattdessen nur aus dem Archiv“.
3. Ich sehe den Auftrag nach, den der Helfer bekam: hatte er `CLAUDE.md` oder alte Rollen im Text, ist sein ganzes Ergebnis verdächtig. Dann neuer frischer Helfer mit Sockel und Kern als Maßstab, Auftrag: „Nenne das stärkste Gegenargument gegen <Votum>, gemessen am Obersten Ziel im Sockel und an Entscheiden im Archiv; mit Zahl (Tage, Läufe, $) und Quelle.“
4. Das Argument „verzögert“ ist nach meinem Text kein Gegenargument an sich („Qualität vor Eile“). Als echtes Gegenargument formuliere ich es nur mit belegter Größe: Kosten bisher (`python3 tools/vorgang.py <Nr>`, Kostenspalte), Läufe, was dafür liegen bleibt; Vorrang nur aus dem Archiv.
5. Erst dann Vorlage: Votum, neu belegtes stärkstes Gegenargument, Weg, der es entkräftet.

(b) Chat
Kein Satz zum Helfer an den Chef. In der Vorlage steht nur mein geprüftes Gegenargument, z. B.: „Stärkstes Gegenargument: kostet <n> $ und <m> Fachkraft-Läufe, Vorgang <Nr> „<Titel>“ wartet so lange (Vorrang Archiv <Datum>). Entkräftet durch: <Weg>.“ War der Helferauftrag mit altem Text gebaut: Rückmeldung an den, der den Helfer gebaut hat (wenn nicht ich selbst), als Fund außerhalb (Sockel 5).

(c) Lücken
- Mein Text kennt „Oberste Direktive“ und „Kapitel 1“ nicht; ob Kapitel 1 als Ziel noch gilt, sagt er nicht (nur das Oberste Ziel im Sockel).
- Wie ein Helferauftrag aussehen muss (welche Dateien er bekommt), sagt der Kern nur für Festlegungen („gegen Repo und ganzen Entwurf, ohne deine Begründung“), nicht für Gegenargumente zu Voten.

## L3

(a) Was ich tue
1. `python3 tools/vorgang.py offen Sokrates` → Kennung `<K>`; `python3 tools/vorgang.py annehmen <K>`.
2. Nachsehen statt raten: `python3 tools/vorgang.py 760` → Liste: „ruht, nach Arena (1714), t300.11 Fail“, wartet auf 1589.4. Archiv: „**760, Läufe frei** (18.11., 21:03 …): genau ein Filmlauf `kampf=760` …“ (dieselbe Bitte, derselbe Commit `be2c0d8f0`, schon einmal frei), danach „**760, t300.11 Fail** (18.11., 22:12): … Widerspruch zur Messung (5 von 5 am Körper) erst nachstellen, Kamera seitlich je Angriff; mit 1708“. `python3 tools/probelauf.py --stand 760` → „0 von 1 Probeläufen seit Urteil 2026-11-19 07:24“.
3. Laufbremse (Archiv 19.11., 13:02; `tools/probelauf.py`): den nächsten Lauf gibt der **Prüfer** frei, Sokrates erst nach dem zweiten Nein. Die Bitte geht an den Falschen, und der Vorgang ruht.
4. Entscheid (meiner): kein Filmlauf. Der Fall widerspricht dem Archiv; die Messung „5 von 5“ ist durch den Chef-Film widerlegt.
5. Antwort als Übergabezeile an die Fachkraft: `python3 tools/vorgang.py uebergabe 760 <Fachkraft Kampf> "Antwort Sokrates: nein, kein Filmlauf. 760 ruht nach Arena (1714). Messung 5 von 5 widerspricht t300.11 Fail (Chef 18.11., 22:12): erst Ursache nachstellen, Kamera seitlich je Angriff, mit 1708. Lauf gibt nach der Laufbremse der Prüfer frei."`, Wecker per `send_message`; dann `python3 tools/vorgang.py erledigt <K>`.
6. Entscheid oben ins `docs/VORGANGSARCHIV.md`: „- **760, kein Filmlauf** (21.11., HH:MM, Sokrates auf Frage der Werkstatt) → **ruht nach 1714; erst Widerspruch Messung gegen t300.11 nachstellen; Lauf gibt der Prüfer frei (Sokrates)**“.
7. Fund außerhalb: die Werkstatt arbeitet an einem ruhenden Vorgang → Übergabezeile an den Disponenten (Vorrang): `vorgang.py uebergabe 760 Disponent "Hinweis: Werkstatt arbeitet an 760, Stand ruht nach 1714"`.

(b) Rückmeldung (in der Zeile, wie oben). Chat: nichts.

(c) Lücken
- Wie ich eine „Frage“ beantworte (Rückzeile mit `uebergabe`, `rueckmeldung` oder nur Text in der Vorgangsdatei), sagt mein Text nicht.
- Dass die Laufbremse den Prüfer freigeben lässt und nicht mich, steht nicht in meinem Text, nur im Archiv und im Werkzeug.
- Wer die Fachkraft ist (Profil Kampf heißt welche Sitzung), sagt mein Text nicht.

## L4

(a) Was ich tue
1. Chefwort = Entscheid. Bestand: `python3 tools/vorgang.py 1535` (Stand, letzter Lauf, mein Votum, auf das er antwortet), `python3 tools/probelauf.py --stand 1535`. „Ein Lauf“: ich lese im eigenen Votum, welcher (Bild- oder Filmlauf, an welchem Commit).
2. Oben ins `docs/VORGANGSARCHIV.md`, fette Kopfzeile mit Nummer (danach gibt der Haken frei, `probelauf.py` „Urteil des Chefs im Vorgangsarchiv (407), dessen fette Kopfzeile die Nummer nennt“):
   „- **1535, ein Lauf frei** (21.11., HH:MM, Chef an Sokrates auf Votum HH:MM: „1535, ein Lauf frei.“) → **genau ein weiterer Bildlauf für die Werkstatt nach <Votum>, selbst ansehen, dann an den Prüfer (Nutzer; Votum Sokrates)**“. Commit, Push.
3. Weitergabe an die Werkstatt: `python3 tools/vorgang.py chefwort 1535 "1535, ein Lauf frei." --zeit "21.11., HH:MM"` (Wortlaut in `docs/vorgang/1535.md`, Zeile an den Arbeitsplaner).

(b) Chat
„1535 „Kleidung hängt bei NPCs in der Ruhebewegung an einer Hand“: ein Lauf frei, eingetragen.“

(c) Lücken
- Der Kern nennt für einen Auftrag `vorgang.py neu`, für einen Entscheid das Archiv; für ein Chefwort zu einem **bestehenden** Vorgang nennt er kein Werkzeug. `vorgang.py chefwort` kenne ich nur aus `--help`.
- Ob eine Freigabe durch den Chef die Laufbremse des Prüfers ersetzt, sagt mein Text nicht (nur das Werkzeug).

## L5

(a) Was ich tue
1. `python3 tools/vorgang.py offen Sokrates` → `<K>`, `annehmen <K>`; Vorgangsdatei lesen (`python3 tools/vorgang.py <Nr>`).
2. Erstes „steckt fest“ → entscheide ich (Archiv 21.11., 14:37 B: „einmal an Sokrates, danach an den Chef“).
3. Nicht raten: was sind die 51 Commits? In der Notizkopie (lesend): `git fetch origin`, `git log --oneline origin/main..HEAD | wc -l`, `git cherry -v origin/main | grep -c '^+'` (Commits, deren Inhalt nicht auf `main` ist), `git status`. Lehre: „Nie eine Sperre oder Werkzeugausgabe ungeprüft befolgen“; das Werkzeug selbst rät (Ausgabe `lauf.py`): „erst git … pull --no-rebase“.
4. Entscheid:
   - Reset nein, solange ein Commit mit „+“ da ist: das löscht Arbeit (Sockel 8: Verlauf nicht umschreiben; nichts geht verloren).
   - Weg: Sicherung `git branch sicherung-<Nr>-2111 HEAD`, dann `git pull --no-rebase origin main`, Konflikte lösen, Kerntests, Push.
   - Sind alle 51 schon auf `main` („-“ bei `git cherry`): Sicherungszweig anlegen, dann ist `git reset --hard origin/main` erlaubt (kein geteilter Verlauf).
5. Antwort: `python3 tools/vorgang.py uebergabe <Nr> <Fachkraft> "Antwort Sokrates: kein Reset ohne Prüfung. git cherry -v origin/main: Commits mit + erst sichern (Zweig sicherung-<Nr>-2111), dann pull --no-rebase, Konflikte lösen, Tests, Push. Nur wenn alle 51 schon auf main sind: Sicherungszweig, dann Reset."`, Wecker, `erledigt <K>`.
6. Entscheid oben ins Archiv: „- **<Nr>, Notizkopie: kein Reset** (21.11., HH:MM, Sokrates auf „steckt fest“) → **erst sichern, pull --no-rebase; Reset nur, wenn alle eigenen Commits auf main (Sokrates)**“.

(b) Rückmeldung wie 5. Chat: nichts.

(c) Lücken
- Die Vorgangsnummer und die Fachkraft nennt der Fall nicht; mein Text sagt nicht, wo die Notizkopie in der neuen Ordnung liegt.
- Wie ich auf „steckt fest“ antworte (Zeile zurück, Werkzeug), sagt mein Text nicht; dass das erste „steckt fest“ bei mir liegt, steht nur im Archiv.
- Ob ich Git-Befehle in fremden Kopien selbst ausführen darf („Du schreibst Notizen, keinen Spielcode“), sagt mein Text nicht.

## L6

(a) Was ich tue
1. Nicht raten, welcher Build „gestern getestet“ ist: `grep -n "t300 getestet\|t299 getestet" docs/VORGANGSARCHIV.md` → „**t300 getestet** (18.11., 23:11 …)“; Prüfliste `docs/chefsache/ansehen/t300-sammelbuild.md` bzw. Git. Also Build 300. 760 ist darin (t300.11 Fail).
2. Release und `main` entscheidet der Chef; er hat entschieden. Oben ins Archiv:
   „- **Build 300 freigegeben ohne 760** (19.11., 07:24, Chef an Sokrates: „wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist … lass es klar ziehen“; dazu: „wenn du einmal geschrieben hättest, Build 300 freigegeben, hätte ich es gleich gewusst“) → **Build 300 auf `main` ohne 760 (Revert sichtbar); Worte an den Chef in seiner Sprache, nie Kürzel (Nutzer)**“.
3. Auftrag: `python3 tools/vorgang.py neu "Von Chef (19.11., 07:24): Build 300 freigeben, ohne 760" "B Technik" M "<Build-Macher>" --oben`, dazu `python3 tools/vorgang.py chefwort <neue Nr> "wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist … lass es klar ziehen" --zeit "19.11., 07:24"`; Push; Disponent wecken (`send_message` an die Sitzung aus der Besetzung, „sieh in <Nr>“).
4. Zweiter Satz = Lehre an mich. Gedächtnis `docs/leitung/gedaechtnis.md` (Ladefassung 2.904 B, Grenze 3 KB): neue Lehre „Nie Kürzel oder Zustandswort an den Chef; stattdessen sein Wort: „Build 300 freigegeben“ (19.11., 07:24)“. Passt nicht mehr unter 3 KB → mit verwandter Lehre zusammenlegen oder eine erledigte streichen; Byte vorher/nachher.

(b) Chat
„Build 300 freigegeben, ohne 760. Vorgang <Nr> „Build 300 freigeben, ohne 760“ liegt beim Build-Macher.“

(c) Lücken
- „lass es klar ziehen“ ist mir unklar (sauber zusammenführen? Spracherkennung für einen Namen?). Sockel 3 sagt „anhalten, Frage zurückmelden“, aber der Kern der Weisung ist klar; ich trage wörtlich ein und frage nicht. Die Regel, ab wann teilweise Unklares anhält, fehlt.
- Wer „freigeben“ ausführt (Build-Macher, Spike, Disponent) und welcher Bereich, sagt mein Text nicht.
- Gedächtnis ist bei 2.904 von 3.000 B; mein Text sagt nicht, was beim Überlauf weicht.

## L7

(a) Was ich tue
1. Prüfliste `docs/chefsache/ansehen/t299-…md` lesen; `python3 tools/vorgang.py 1535` (Titel: „… alle Figuren mit Kaufkleid prüfen …“ → Garrick und Kittel gehören in 1535, kein neuer Vorgang).
2. Testergebnis oben ins Archiv: „- **t299 getestet** (18.11., HH:MM, Chef: „299.3 ✗ siehe Chat“; 15:33: „zieht sich da auch wieder irgendwas von der Jacke“, 15:59: „Das sieht man ja die Beule direkt“) → **1535 zurück an die Werkstatt (Garrick Jacke beult, Bewohner im Kittel); Freigabe Rest für main offen (Nutzer)**“.
3. Ergebnis in die Liste: `python3 tools/vorgang.py build 299` (Automatik B: 1535 → startbar mit Fund) und Chefworte wörtlich: `python3 tools/vorgang.py chefwort 1535 "zieht sich da auch wieder irgendwas von der Jacke" --zeit "18.11., 15:33"`, ebenso 15:59.
4. „Was der Chef als Erster findet, ist dein Fehler“: Lehre roh: `python3 tools/vorgang.py lehre roh 1535 "Fund Chef t299.3: Jacke beult" "<Ursache, warum Abnahme/Prüfbild das nicht zeigte>"`. Ursache kenne ich nicht → Frage an die Abnahme als Zeile: `vorgang.py uebergabe 1535 Prüfer "Frage Sokrates: warum zeigte das Prüfbild die Beule an der Jacke nicht?"`. Beule an Kleidung wiederholt sich (Archiv 861, 1515, 1535) → Kern „Wiederholt sich eine Lehre, schlag eine Werkzeugsperre vor“: Vorschlag Prüfung „Flanke bei gehobenem Arm“ im Prüfbild als Vorgang an den Werkzeugbesitzer.
5. Rest des Builds: Vorlage, ob Build 299 ohne 1535 auf `main` darf (Release/`main` = Chef).

(b) Chat
„299.3 eingetragen: 1535 zurück an die Werkstatt (Jacke beult bei Garrick, Bewohner im Kittel). **Build 299 ohne 1535 auf main freigeben?** Votum ja; stärkstes Gegenargument: 1535 hängt an derselben Kleidung wie <…>; entkräftet: Revert 1535 vor dem Zusammenführen.“

(c) Lücken
- Wer `vorgang.py build 299` ausführt (ich, Disponent, Build-Macher), sagt mein Text nicht.
- „siehe Chat“ verweist auf ein Bild, das ich nicht habe; Kern: „Aussehen nur an Bild oder Film“. Ob ich ohne Bild die Worte nur weitergebe, sagt er nicht.
- Kern „Auftrag als Vorgang mit `vorgang.py neu`“ passt nicht zu einem Fund an einem bestehenden Vorgang.

## L8

(a) Was ich tue
1. Bild der Meldung selbst öffnen (Lehre: „Nie ein Votum zum Aussehen ohne das Bild“); Nachrichtennummer und Meldung aus dem Zweig „meldungen“.
2. 👍 = Billigung Aussehen = Entscheid. Oben ins Archiv: „- **1535, Garrick alt gegen neu gebilligt** (21.11., HH:MM, Chef in Telegram: 👍 auf Meldung HH:MM, Nachricht <n>) → **Bild gebilligt; Gerätetest im nächsten Testbuild, Kittel offen (Nutzer; Vorlage Werkstatt, Prüfer ja)**“.
3. Gebilligt ist nur das Bild, nicht der Code auf `main` (Sockel 8: kein Spielcode ohne Test des Chefs). 1535 umfasst auch die Bewohner im Kittel → 1535 bleibt offen. Zeile an den Disponenten: `vorgang.py uebergabe 1535 Disponent "Chef 👍 auf Garrick alt gegen neu (HH:MM); Garrick in den nächsten Testbuild; Kittel offen"`.

(b) Chat: nichts (nichts zu entscheiden).

(c) Lücken
- Wie ein 👍 in die Vorgangsdatei kommt (selbst eintragen, `reaktionen.py`, Disponent), sagt mein Text nicht.
- Ob „Prüfer ja“ plus 👍 den Vorgang schließt oder erst der Testbuild, sagt mein Text nicht.

## L9

(a) Was ich tue
1. `vorgang.py offen Sokrates` → `<K>`, `annehmen <K>`. `python3 tools/vorgang.py 1694` (Titel „Griff einmal für alle gehaltenen Dinge …“, Kosten 33,37 $, Stand „ruht, bis Sa 21.11.“), `docs/vorgang/1694.md`, `git show --stat 04bf8ffc1`.
2. Erstes „steckt fest“ → ich entscheide. Beide Versuche waren Vermutungen (Handgelenk, Fingergewichte). Erst Ursache, dann ein Versuch.
3. Frischer Helfer (nicht gestartet), nur lesend: „Lies die Prüfausgabe von `04bf8ffc1` (Griffprüfung 1694). Gruppiere die 752 Fehler nach Gegenstand, Hand und Maß. Hängen sie an wenigen Waffen oder an allen gleich? Nenne je Gruppe Anzahl und ein Beispiel mit Wert.“ Ergebnis an der Quelle nachprüfen (eine Gruppe selbst nachzählen).
4. Entscheid nach Ergebnis: Hängen die Fehler an den Waffen (Griffpunkt je Modell verschieden): **ein Versuch, Griffpunkt je Waffe**; Messlauf frei (`MESS=1694`), kein Bildlauf; scheitert er, geht es an den Chef (zweites „steckt fest“). Sonst: Ursache weiter nachstellen, kein Bau.
5. Antwort: `vorgang.py uebergabe 1694 <Fachkraft Werkzeug> "Antwort Sokrates: ein Versuch, Griffpunkt je Waffe (Fehler hängen an <Gruppen>). Vorher je Waffe den Griffpunkt messen; Prüfung wie bisher; scheitert er: steckt fest, dann Chef."`, Wecker, `erledigt <K>`.
6. Oben ins Archiv: „- **1694, ein Versuch** (21.11., HH:MM, Sokrates auf „steckt fest“, 752 von 1540 an `04bf8ffc1`) → **ein Versuch Griffpunkt je Waffe; scheitert er, Chefsache (Sokrates)**“.

(b) Rückmeldung wie 5. Chat: nichts.

(c) Lücken
- Mein Text sagt nicht, nach welchem Maß ich bei „steckt fest“ entscheide (weiter, anders, stoppen) und wie viel Geld ein Versuch kosten darf.
- Dass ich bei Spielcode-Fragen Läufe freigeben darf, folgt nur aus „Mit dem Chef bildest du die Leitung: du entscheidest“, nicht ausdrücklich.

## L10

(a) Was ich tue
1. `vorgang.py offen Sokrates` → `<K>` (das Werkzeug setzt beim zweiten „steckt fest“ „ruht, beim Chef“ und schreibt „an den Chef: Chefsache anlegen, nicht selbst lösen“, `tools/rueckmeldung.py` B). `annehmen <K>`. Archiv 21.11., 20:59: „zweites „steckt fest“: Sokrates legt … an“ und trägt vor. Ich löse nicht selbst.
2. Belege: `docs/vorgang/1694.md` (752 → 610 von 1540, Commits `04bf8ffc1`, `d8dce68a2`, Kosten im Kopf 11,40 $), `python3 tools/vorgang.py 1694` (Liste 33,37 $: weicht vom Kopf ab, beide mit Quelle nennen).
3. Chefsache `docs/chefsache/entscheiden/1694a-griff.md` nach `MUSTER.md`:
   - Frage: „1694a · Wie weiter mit dem Griff (Stab durch die Knöchel), nach zwei gescheiterten Versuchen?“
   - Beim Chef, weil: zweites „steckt fest“ (Archiv 21.11., 20:59); Aussehen.
   - Sachverhalt: Versuch 1 Handgelenk/Finger 752 Fehler, Versuch 2 Griffpunkt je Waffe 610 Fehler (−19 %), Kosten 11,40 $ (Kopf) bzw. 33,37 $ (Liste).
   - Auswertung: A ruhen lassen bis nach Kapitel 1, Waffen bleiben wie heute; B ein dritter Versuch nur mit Ursache vorher (Fehlergruppen nach Waffe, Helfer), Kosten etwa wie bisher je Lauf; C anderer Weg (Waffe am Handknochen anheften statt Finger um den Schaft).
   - Votum mit stärkstem Gegenargument und Weg, der es entkräftet; `python3 tools/vorlage_pruefen.py <Datei>`.
4. Zeile `erledigt <K>`; Commit, Push. Telegram (`meldung.sh Sokrates "1694: …" --laut`, nicht gesendet).

(b) Chat
„**Chefsache 1694a: „Griff einmal für alle gehaltenen Dinge“ steckt zweimal fest** (752, dann 610 von 1540 Fehlern; 11,40 $ laut Vorgangsdatei, 33,37 $ laut Liste). Votum: „1694a <A/B/C>“. Stärkstes Gegenargument: <…>.“

(c) Lücken
- Mein Kern nennt das zweite „steckt fest“ nicht; nur Werkzeug und Archiv sagen, dass es an den Chef geht.
- Die Kosten widersprechen sich (Kopf 11,40 $, Liste 33,37 $); welche gilt, sagt mein Text nicht.
- Ob vor der Vorlage ein frischer Leser liest (Chef-Lesung, Archiv 22.11.), sagt mein Kern nicht; das Profil Chefrunde lädt nur der Zuruf „Chefrunde“.
- Ob ich bei „ruht, beim Chef“ Telegram laut sende, sagt mein Text nicht.

## L11

(a) Was ich tue
1. Profile sind Vorbehalt des Chefs; er hat entschieden → ich führe aus. Vorher einmal Einwand mit Grund, falls einer da ist (Kern: „hast du einen Einwand, nennst du ihn mit Grund vorher einmal“). Bestand und Archiv: `grep -n "Spielkamera\|Signatur" docs/VORGANGSARCHIV.md`. Kern selbst sagt „Aussehen nur an Bild oder Film in Spielkamera und Handygröße“; Archiv 1694 (18.11.) ließ „Nahsicht plus Spielkamera“ zu (Ausschnitt für Griffe). Einwand: „Handygröße“ fehlt, und Nahsicht für kleine Teile fiele weg.
2. Chefwort oben ins Archiv: „- **Profil Prüfer: Bilder nur Spielkamera mit Signatur** (21.11., HH:MM, Chef an Sokrates: „Schreib ins Profil Prüfer: Bilder gelten nur in Spielkamera mit Signatur.“) → **Satz ins Profil Prüfer (Sokrates) (Nutzer)**“.
3. Die alte Datei öffnen (`docs/profile/profil-pruefer.md`, Lehre „Nie umbauen ohne die alte Datei“), schon da? präziser? Nur die genannte Stelle ändern („Nie eine Regelzeile neu schreiben“).
4. Byte und Ladesumme vorher/nachher: `python3 tools/ladesumme.py` (Profil Prüfer heute 2.935 B).
5. Festlegung → frischer Helfer prüft gegen Repo und ganzes Profil, ohne meine Begründung (Widerspruch zu Querprofil „Signatur und Leben“, Profil Figur und Prüfbild, Laufbremse).
6. Vorlage mit Byte, „Gegengeprüft“, dann Commit nach Chefwort.

(b) Chat
Erst Einwand, einmal: „Einwand zum Satz im Profil Prüfer: Mein Kern sagt „Spielkamera und Handygröße“, und für Griffe galt „Nahsicht plus Spielkamera“ (Archiv 18.11.). Vorschlag: „Bilder gelten nur in Spielkamera mit Signatur in Handygröße; ein Ausschnitt nur zusätzlich.“ Sonst trage ich deinen Satz wörtlich ein.“
Danach: „Profil Prüfer: Byte 2.935 → <n>, Ladesumme <x> → <y>. Gegengeprüft: `profil-pruefer.md`; Befund 1 <stimmt/Einwand/Frage>. **Zum Billigen.**“

(c) Lücken
- Mein Kern lädt das Profil Prüfer nicht; zum Ändern muss ich es lesen. Ob Lesen zum Bearbeiten erlaubt ist, sagt mein Text nicht (Testvorgabe: nur laden, wenn der Kern es lädt).
- Ob ein ausdrücklicher Chefauftrag zu einem Ladetext trotzdem die Gegenprüfung und eine zweite Billigung braucht, sagt mein Text nicht klar („Was etwas festlegt … prüft vor der Vorlage ein frischer Helfer“).
- Wo die Profile liegen (`docs/profile/` gibt es in der Kopie noch nicht), sagt mein Text nicht.

## L12

(a) Was ich tue
1. Lehre „Sammelwort gegen jede Frage und ihr Votum lesen“: eine Frage, Votum ja, „ja“ passt.
2. Bestand vorher (Lehre: „Befund, der den Auftrag gegenstandslos macht, vorher nennen“): `grep -n "\"potion\"" -A10 godot/daten/texte.json` → „Heiltrank“, `"kurz": {"de":"heilt 14"}`; es gibt „Heiltrank“ und „Großer Heiltrank“, keinen „kleinen Heiltrank“; alte Fassung „heilt 2W4+2“ (`godot/tests/laden_582.gd`). `grep -n -i heiltrank docs/DESIGN-BRS.md` → kein Wert. Die Frage („2W4 statt 1W6“) passt also nicht zum Bestand.
3. Chefwort trotzdem in derselben Antwort eintragen (nie gegen ein Chefwort ablehnen; raten, Regel nennen, fragen): oben ins Archiv „- **7c ja, Heiltrank** (21.11., HH:MM, Chef: „7c ja.“; `entscheiden/7c-heiltrank.md`: „Heilt der kleine Heiltrank 2W4 statt 1W6? Votum ja.“) → **kleiner Heiltrank 2W4; Bestand heilt 14 fest, Folge erst nach Klärung (Nutzer; Votum <Verfasser>)**“.
4. Chefsache-Datei bleibt bis zur Klärung (beantwortet heißt weg samt Folgeauftrag; der Folgeauftrag ist noch unklar). Nach Antwort: Datei löschen und im selben Commit `vorgang.py neu "Von Chef (21.11., HH:MM, 7c): Heiltrank heilt 2W4" "E Kampf" M "<Werkstatt>"`, Disponent wecken; Wert ins `docs/DESIGN-BRS.md`.

(b) Chat
„7c eingetragen. Vorher eine Frage: Im Spiel gibt es keinen „kleinen“ Heiltrank; der Heiltrank heilt heute fest 14 (`texte.json`), in der alten Fassung 2W4+2. Rat: der Heiltrank heilt 2W4+2 wie alt. **Meinst du den Heiltrank, und 2W4 oder 2W4+2?**“

(c) Lücken
- Mein Text sagt nicht, was zu tun ist, wenn eine Chefsache-Frage auf falschem Bestand steht und der Chef schon „ja“ gesagt hat (eintragen und fragen? Datei behalten?).
- Balance steht nicht im Vorbehalt des Kerns; wer 7c angelegt hat und ob ich es selbst hätte entscheiden dürfen, sagt er nicht.
- Zu welchem Vorgang 7c gehört, sagt der Fall nicht; mein Text sagt nicht, wie ich das finde (Annahme: `python3 tools/vorgang.py 7`).

## L13

(a) Was ich tue
1. Frage des Chefs → Vorlage: Votum, stärkstes Gegenargument, Weg; vorher Bestand und Archiv.
2. Bestand: Archiv „**1727, Wache bleibt** (21.11., 20:50 …): Wache bleibt dauerhafte Sitzung mit Uhr; künftig startet sie das Büro (Disponent)“; „**1727k A**“ (22.11., 12:28): Wache darf einen Disponenten bei Ausfall starten. `tools/uebergabe.py`: Frist einer angenommenen Zeile 30 Minuten, abgelaufene Frist wird erst in der Stundenrunde wieder offen. Kosten je Wachlauf: `python3 tools/kosten.py --help`, dann Kosten der Wache-Sitzung der letzten Tage. Wirkung: wie oft lag eine Zeile mit abgelaufener Frist länger als 30 Minuten (`vorgang.py offen` gegen Zeitstempel in `docs/vorgang/*.md`), wie oft fiel der Disponent aus (Archiv, Wache-Meldungen).
3. Ablauf = Festlegung → frischer Helfer (nicht gestartet): „Prüfe den Vorschlag „Wache alle 30 statt 60 Minuten“ gegen Repo (Archiv ab 21.11., `tools/uebergabe.py`, `tools/lauf.py`, Wache-Routine): Wer wird wann geweckt, was ändert sich bei Frist, Ausfall, Kosten? Raster Auslöser bis Empfänger. Ohne meine Begründung.“ Befunde an der Quelle nachsehen, je Befund ein Wort.
4. Votum nach den Zahlen. Vorläufig (ungeprüft): **nein, bei 60 bleiben**, solange keine Zeile messbar zu lange lag; Kosten verdoppeln sich.
5. Frage ist keine Idee und kein Auftrag; nichts in `LISTE-IDEEN.md`. Antwortet der Chef mit Entscheid: oben ins Archiv; Auftrag „Wache alle 30 Minuten“ als Vorgang an den Besitzer der Wache.

(b) Chat
Ohne Gegenprüfung nur so: „Ungeprüfter Gedanke, ohne Votum: 60 Minuten reichen, solange keine Zeile nach Fristablauf länger liegt; 30 verdoppelt die Wachkosten. Ich messe Liegezeiten und Kosten und lasse es gegenprüfen.“
Nach Gegenprüfung: „**Wache 30 statt 60 Minuten: Votum nein.** Stärkstes Gegenargument: Frist 30 Minuten, die Stundenrunde öffnet abgelaufene Zeilen erst bis zu 90 Minuten später; <n> Fälle seit Umstellung. Entkräftet: <n> = 0 bzw. Wache nur bei offener Zeile mit abgelaufener Frist früher wecken. Kosten 60 Minuten: <x> $/Tag, 30 Minuten: etwa <2x> $/Tag. Gegengeprüft: <Datei>; Befund 1 stimmt …“

(c) Lücken
- Die Wache-Routine lädt mein Kern nicht; ihr Takt und Inhalt stehen nicht in meinem Text.
- Ob eine Frage des Chefs als Vorlage im Chat reicht oder als Chefsache-Datei angelegt werden muss, sagt mein Text nicht.
- Ob „Wiederholt sich eine Lehre, schlag eine Werkzeugsperre vor“ oder die Gegenprüfung auch für ein Votum gilt, das selbst nichts festlegt, sondern nur rät, ist unklar („Was etwas festlegt (Regel, Ablauf …)“).

## Übergreifende Lücken

- Gedächtnis: „Offene Fäden“ und „Übergabe“ stehen „bis zur Umstellung in `docs/ARBEIT-BERATUNG.md`“, das ich nicht lesen darf; für L1–L12 (vor der Umstellung) fehlen mir damit offene Fäden.
- Mein Text sagt nicht, wann Telegram gesendet wird; „Form“ nennt nur das Werkzeug.
- Das Werkzeug `vorgang.py chefwort` (Zeile an den Arbeitsplaner) steht nicht im Kern, der für Aufträge nur `vorgang.py neu` nennt.
- Commit und Push von Notizen erklärt mein Text nicht.
