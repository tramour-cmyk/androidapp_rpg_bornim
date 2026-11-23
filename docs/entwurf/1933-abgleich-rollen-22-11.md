# 1933 · Abgleich der Rollendateien gegen Sockel, Kerne, Profile, Routinen (22.11.)

Stand-Commit: `be26663e6` (origin/main, 22.11., 12:14) · geschrieben 22.11., 12:15–12:35 von einem Helfer Sokrates, nur lesend, nicht committet · Auftrag Chef 22.11., 12:14: „Ob denn unsere Rollen … halbwegs aufgehen in den Kernen und Profilen.“

**Gegen welchen Text geprüft (geladener Teil):** Sockel = Codeblock `1727-gesamtbild.md` 1 (1.109 Byte; `1727-sockel.md` sagt selbst „Gültiger Text … nur in `1727-gesamtbild.md` 1“) · Kern Leitung Fassung 2 (`1727-gesamtbild.md` 2.1, zweiter Codeblock) · `kern-buero.md`, `kern-arbeitsplaner.md`, `kern-abnahme.md` (Text bis zum ersten „##“) · alle `profil-*.md` (Codeblock Teil A, sonst Text bis „##“; `profil-technik.md` Teil A und Teil B, Teil B wird Checkliste) · `querprofil-signatur-und-leben.md`, `profil-fremde-inhalte.md` Teil A · `routine-*.md` Teil A · `uebergabekette.md`. Nicht gezählt: `kern-pruefer.md` (Verlauf), `profil-kosten.md` (kein Profiltext, Votum „fällt“). Werkzeuge nach `1727-muster/werkzeuge.md` (A ändern, B neu, C entfällt). Ein Verweis im geladenen Text auf eine Datei, die weiter gilt (etwa `LISTE-CHECK-BUILD-TEST.md`, `DESIGN-KAMPF.md` „Was gilt“), zählt als „im Text“.

Kurzzeichen je Zeile: **T** im geladenen Text (wo) · **W** durch Werkzeug getragen (welches; „geplant“ = Bauliste, noch nicht gebaut) · **FW** fehlt, wichtig (Beleg, Zielort in Abschnitt 2) · **FV** fehlt, verzichtbar (Grund). Maß: würde das Fehlen die Fehlerrate erhöhen.

## 1 Zählung

Gezählt je inhaltlicher Aussage (Abschnitt 3), nach dem ersten Kurzzeichen der Zeile.

| Rollendatei | Aussagen | im Text | Werkzeug | fehlt, wichtig | fehlt, verzichtbar |
|---|---|---|---|---|---|
| `ROLLE-TECHNIK.md` (Spike) | 35 | 23 | 3 | 1 | 8 |
| `ROLLE-ENTWICKLUNG.md` (Tom, Jerry) | 61 | 22 | 8 | 5 | 26 |
| `ROLLE-PROJEKT.md` (Perikles) | 55 | 25 | 5 | 7 | 18 |
| `ROLLE-BETRIEB.md` (Ford) | 40 | 14 | 19 | 0 | 7 |
| `ROLLE-PRUEFUNG.md` (Diogenes) | 31 | 18 | 3 | 1 | 9 |
| `ROLLE-KREATIV.md` (Homer) | 36 | 19 | 2 | 1 | 14 |
| `ROLLE-BERATUNG.md` (Sokrates) | 40 | 20 | 3 | 5 | 12 |
| `ROLLE-BERATUNG-START.md` | 31 | 23 | 1 | 2 | 5 |
| **Summe** | **329** | **164** | **44** | **22** | **99** |

Die 22 Zeilen „fehlt, wichtig“ sind 14 verschiedene Lücken (Abschnitt 2); `add_repo` allein steht in sechs Rollendateien. Bei 5 der 44 Werkzeug-Zeilen ist das Werkzeug nur geplant (Testbitte-Schreiber, Rufnamen; dazu als Nebenträger Laufbremse, Lehrenbuch, Stop-Haken 1732); bis es gebaut ist, fehlen sie praktisch.

**Urteil zur Frage des Chefs:** Ja, die Rollen gehen halbwegs auf, Technik fast ganz (eine Lücke: Alt und Bestand über den Verweis auf `ROLLE-ENTWICKLUNG.md`), Betrieb und Prüfung ganz bis auf `add_repo`. Was fehlt, liegt bei der Werkstatt (Alt zuerst, Bestand zuerst, großes Vorhaben, „Vor jeder Vorlage“) und bei den Lehren der Leitung, die ins noch nicht angelegte Gedächtnis Sokrates gehören.

Gegen den Abgleich vom 20.11. (90 im Text, 61 fehlt): Profil Technik, Werkzeug, Fremde Inhalte, Disponent, Release, Routinen sind seitdem geschrieben; fast alle damaligen „fehlt“ aus TECHNIK, BETRIEB und PRUEFUNG sind jetzt im Text oder im Werkzeug. Was bleibt, liegt bei den Fachkräften (Entwicklung) und bei der Leitung (Lehren Sokrates, Perikles).

## 2 Fehlt, wichtig (mit Beleg und Zielort)

Reihenfolge nach Wirkung. Byte = geschätzter Zuwachs am Zielort.

1. **Alt zuerst** (ENTWICKLUNG Z.31, TECHNIK Z.24 über Verweis). Beleg: 647 (Chef 08.11., 12:44: „die guten Sachen, die schon da sind, übernehmen und besser machen“), 499 („Messen oder Nachstellen ersetzt das Lesen nicht“), Schwäche 620 in `ROLLE-BERATUNG.md` Z.116 („Rückschritte gegen alt findet der Chef“). Heute trägt es der Haken in `probelauf.py` (Zeile „Alt:“ in der Commit-Nachricht); `probelauf.py` entfällt (`werkzeuge.md` C, Zeile `probelauf.py`), ein Ersatz für die „Alt:“-Prüfung steht nirgends. Im neuen Text nur je Ort (Profil Welt „Alte Fassung je Ort“, Oberfläche „Untergrenze“, Klang „Fehlendes aus der alten Fassung“); für Figur, Kampf, Technik, Werkzeug nichts. **Zielort:** Kern Arbeitsplaner Feld 3 „Bisher“: „… dazu die Fundstelle in der alten Fassung (`bornim-kaufmodelle/kotlin-alt/`, Datei:Zeilen) oder ‚Alt: keine (Grund)‘“ (etwa 110 Byte); Haken als Zeile in Bauliste 7.1. Gegenargument: der Arbeitsplaner müsste für jeden Auftrag das Kaufrepo lesen, das kostet; für ganz Neues ist es leer. Entkräftet: „oder keine (Grund)“ macht es zu einer Zeile, und genau die Fälle, wo es Altes gibt, sind die, die der Chef als Rückschritt findet.
2. **Großes Vorhaben erst nach Gespräch** (ENTWICKLUNG Z.31; `CLAUDE.md` Zusammenarbeit 3 „Nie selbst: … großes Vorhaben vor dem Gespräch (1236)“). Beleg: Archiv 1236 (Chef 13.11., 21:41: „bevor irgendeiner irgendwas Großes … anpackt, müssen wir uns darüber auf jeden Fall unterhalten … Okay, also das ist wichtig.“); 1384 (Werkzeug weckte trotz „vor dem Bau Gespräch“). Neu nur teilweise: Sockel „nicht darüber hinaus“, Kern Arbeitsplaner „Fehlt ein Chefwort zu seiner Frage: ‚Frage‘“, Profil Kampf zur Kamera 1402. Die Schwelle (neues System, mehrere Orte, über 30 $, auch Beschlossenes) steht nirgends; Gesamtbild 1a ordnet 1236 dem Kern Leitung zu, Fassung 2 trägt es nicht. **Zielort:** Kern Arbeitsplaner „Nicht deins“: „Großes Vorhaben (neues System, mehrere Orte): ‚Frage‘, bis der Chef im Gespräch bestätigt hat, auch bei Beschlossenem.“ (etwa 130 Byte). Gegenargument: der Arbeitsplaner kann „groß“ schlecht beurteilen und fragt zu oft. Entkräftet: die Schwelle ist benannt; eine Frage kostet weniger als ein Bau gegen einen veralteten Beschluss.
3. **Bestand zuerst** (ENTWICKLUNG Z.33). Beleg: 377 (Chef 27.10., 12:53: „allererstes geguckt …, ob wir dazu was gekauft haben“), 408 (Archiv: „erst müssen wir halt schauen, ob wir nicht selbst das Objekt schon haben“). Neu nur für Effekt und Shader (Profil Welt „Bestand“) und Klang (`tools/klang/QUELLEN.md`); für Modell, Bewegung, Ding, Textur nichts; Querprofil Fremde Inhalte regelt Lizenz, nicht die Reihenfolge Bestand → frei im Netz → Kaufvorschlag → Eigenbau. **Zielort:** Kern Arbeitsplaner Feld 3 „Bisher“ (gemeinsam mit 1): „Bestand geprüft: <Datei, Teil> oder fehlt (`docs/LISTE-BESTAND.md`)“ (etwa 70 Byte); die Reihenfolge als ein Satz vorn ins Querprofil Fremde Inhalte (etwa 120 Byte). Gegenargument: Fremde Inhalte lädt nur bei fremder Datei, also zu spät. Entkräftet: darum die Zeile im Auftrag selbst.
4. **„Vor jeder Vorlage“ (`DESIGN-ABNAHME.md`, 461)** (ENTWICKLUNG Z.25, Z.49, Start 2). Beleg: 461 (Chef 01.11.), Chef 09:17 in `ROLLE-ENTWICKLUNG.md` Z.25: „Schaut denn keiner mehr auf das, was er vorlegt?“. Die Kennungsliste A1 ff. (Spielshader, Tusche nach Licht, Signatur an Kaufmodellen, Schatten unter dem Körper …) wird in keinem 1727-Text genannt (Suche „461“ in `1727-gesamtbild.md` und `1727-muster/`: kein Treffer); Profil Figur und Prüfbild und Profil Prüfer tragen nur Teile (Halten, Kleidung, Treffer; Spiel-Shader, Tusche). **Zielort:** Profil Figur und Prüfbild, Absatz „Prüfbild und Film“: „Vor dem Senden jeden Punkt ‚Prüfer: ja‘ aus `docs/DESIGN-ABNAHME.md` ‚Vor jeder Vorlage‘, der im Bild vorkommt.“ (etwa 120 Byte) oder ein bewusstes „fällt“ mit Chefwort. Gegenargument: zwei Orte für Bildregeln (Profil und `DESIGN-ABNAHME.md`) laufen auseinander. Entkräftet: Verweis statt Abschrift; was im Profil steht, in 461 streichen (Regelbilanz).
5. **Kaufrepo selbst einbinden** (`add_repo`; Zeilen in sechs Rollendateien). Beleg: „Bekannte Fehler“ in `CLAUDE.md` („Nie zum Kaufrepo Wege vorschlagen …; stattdessen `add_repo` (… 1472)“), 1110, 708, 797, 1099. Neu nur im Profil Disponent und im Querprofil Fremde Inhalte („Zugang `add_repo`“); nicht im Sockel, nicht im Profil Technik, das für den Sammelbuild Kaufmodelle braucht; „lehnt das Werkzeug ab, nie darum bitten“ steht nirgends. **Zielort:** ein Satz im Profil Technik „Build“ (etwa 90 Byte: „Kaufmodelle: `add_repo` für `bornim-kaufmodelle`; lehnt es ab, Frage zurück, nie um Erlaubnis bitten.“); im Sockel nur, wenn auch Welt und Kampf Kaufdateien öffnen. Gegenargument: der Sockel ist auf 1,2 KB begrenzt und für alle. Entkräftet: Profil statt Sockel.
6. **Regelbilanz und „ein Text an einem Ort“** (PROJEKT Z.11, Z.30, Z.84; BERATUNG L9; `CLAUDE.md` Haltung 6). Beleg: 90a (Perikles „je Fehler eine neue Regel“), 461 (Lehre 9: „nie eine neue Sammelstelle daneben“), Chef 19.11., 07:18 („das 50. Mal die Prompts kürzen“, `1625-prompts-kuerzen.md`). Im neuen Text steht nur „Wiederholt sich eine Lehre, schlag eine Werkzeugsperre vor“ (Kern Leitung); dass eine neue Regel eine alte ersetzt, nirgends. Genau das hält Kerne und Profile künftig kurz, das Ziel des Chefs. **Zielort:** Kern Leitung Haltung, an die Zeile „Was etwas festlegt …“: „Eine neue Regel ersetzt oder streicht eine alte, an einem Ort.“ (etwa 70 Byte; Kern dann etwa 2.910 von 3.000). Gegenargument: Kern Leitung ist abgenommen und nahe an der Grenze. Entkräftet: ein Satz; sonst wächst jedes Profil wieder.
7. **`DESIGN-BRS.md` im selben Schritt nachziehen** (BERATUNG Z.102, START Z.172). Beleg: Chefauftrag 02.11., 19:19 (`ROLLE-BERATUNG.md` Z.102). Profil Regeln macht `DESIGN-BRS.md` zur einzigen Quelle („Was gilt, steht in …“) und lässt den Bau dort nur „Alle Stufen“ und Querschnitt pflegen; wer einen Regelentscheid einträgt, steht nirgends. Folge: Fachkräfte bauen gegen eine veraltete Regel. **Zielort:** Kern Leitung „Chefworte“: „… einen Entscheid oben ins Archiv, Regeln und Zahlen im selben Schritt in `docs/DESIGN-BRS.md`“ (etwa 60 Byte). Gegenargument: kein einzelner Vorfall belegt. Entkräftet: Folgefehler aus der Bauart des Profils Regeln, nicht aus einem Fall.
8. **Befund eines Helfers erst nach Blick in seine Quelle** (BERATUNG L1). Beleg: 20.11. viermal, je erst auf Frage des Chefs (1170 statt 1128 A; „45 Grad“ aus Kopfkommentar; „Wege laufen davor aus“ verkehrt; Größe geschätzt). Kern Leitung verlangt die Gegenprüfung, aber nicht, dass Sokrates deren Befunde an der Quelle nachsieht. **Zielort:** Gedächtnis Sokrates (`docs/leitung/gedaechtnis.md`, „geltende Lehren“), das es noch nicht gibt; ersatzweise an die Gegenprüfungszeile im Kern Leitung „… je Befund nach Blick in seine Quelle“ (etwa 30 Byte). Gegenargument: gehört als Lehre ins Gedächtnis, nicht in den Kern. Entkräftet: einverstanden, sofern das Gedächtnis mit der Umstellung entsteht und diese Lehre mitnimmt.
9. **Umbau von der alten Datei aus, jede Übernahme dreifach prüfen** (PROJEKT Z.107). Beleg: 98, D41.1 („beim Kürzen gingen drei Regeln verloren“). Gilt genau für die laufende Umstellung und jede künftige Änderung an Kern oder Profil. **Zielort:** Gedächtnis Sokrates (wer Kerne und Profile ändert). Gegenargument: dieser Abgleich erfüllt es für die Umstellung schon. Entkräftet: Profile werden weiter geändert.
10. **Regelzeile nur an der Stelle ändern, die der Vorgang nennt** (PROJEKT Z.95). Beleg: D205.3, D206.2 (13.11., zweimal an einem Tag ungenannt Wörter gestrichen). Profil Werkzeug „Grenzen“ regelt nur Edit/Write statt Bash. **Zielort:** Profil Werkzeug „Grenzen“ und Gedächtnis Sokrates: „Notizen nur an der genannten Stelle ändern, kurzer Ausschnitt, nie die ganze Zeile neu.“ (etwa 90 Byte). Gegenargument: Sockel 5 („Fund außerhalb des Auftrags: zurückmelden“) deckt es halb. Entkräftet: der Fehler war kein Fund, sondern Nebenwirkung beim Schreiben.
11. **Sperre und Werkzeug vor dem Befolgen prüfen** (BERATUNG L6, START Z.161). Beleg: 194.1, 865, 578. Profil Disponent hat das Gegenstück („Widerspricht ein START einem Chefwort …: nicht starten“), Kern Leitung nicht. **Zielort:** Gedächtnis Sokrates. Gegenargument: Sokrates befolgt kaum Werkzeugausgaben. Entkräftet: er bedient `vorgang.py` und Haken wie jeder; die Fälle waren seine.
12. **Vertrauliche Artefakt-Links ohne Ort** (BERATUNG Z.117). Profil Markt und Recherche verweist auf „`docs/ROLLE-BERATUNG.md` ‚Begründungen‘“; die Rollendateien fallen (Gesamtbild 4.4 letzte Zeile). Querbefund 3 vom 20.11. ist damit weiter offen. Beleg: Regel „Geschäftsmodell, Preise, Markt nie ins Repo“ (START Schwerpunkt C). **Zielort:** Gedächtnis Sokrates oder Kopf des Profils Markt; Verweis im Profil ändern (etwa 20 Byte). Gegenargument: keiner. 
13. **Abhängigkeit erst mit ihrem letzten Nutzer entfernen** (PROJEKT Z.93; Gewicht gering). Beleg: 1207 (Gradle-Spiegel vor 882.1 entfernt, fand Diogenes). **Zielort:** Profil Werkzeug „Nach `main`“ oder Profil Technik (etwa 70 Byte). Gegenargument: allgemeines Handwerk, ein Fall. Entkräftet: billig.
14. **Probe in `git clone`, nie in `cp -r` von `bornim-main`** (PROJEKT Z.99; Gewicht gering). Beleg: 774 (Commit in der Kopie landete auf `main`). **Zielort:** Profil Werkzeug „Grenzen“ (etwa 80 Byte). Gegenargument: Einzelfall, nur wer im Notizenbaum probiert. Entkräftet: Folge war ein ungeprüfter Commit auf `main`, genau was Sockel 8 verbietet.

**Querbefund:** 8, 9, 11, 12 gehören ins Gedächtnis Sokrates. Das Gedächtnis ist entschieden (Archiv 20.11., 21:10), aber noch nicht geschrieben; solange fehlen alle zwölf Lehren aus `ROLLE-BERATUNG.md` und die Lehren aus `ROLLE-PROJEKT.md` ohne Ort. Vorschlag: das Gedächtnis vor der Umstellung als Datei anlegen und je Lehre „übernehmen“ oder „fällt“ (wie hier).

### Grenzfälle (als „verzichtbar“ gezählt, mit Vorbehalt)

- **Kleines im Bereich selbst entscheiden** (ENTWICKLUNG Z.29): Sockel 3 sagt „Ist der Auftrag unklar … anhalten, Frage zurückmelden“; ohne Gegenstück kann das mehr Rückfragen bringen. Anthropic empfiehlt für das neueste Modell ausdrücklich „Make routine judgment calls yourself, and check in only when different readings of the request would lead to materially different work.“ (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5, „Task scope and over-verification“). Kein Fehlerbeleg bei uns; im Falltest beobachten (Anteil „Frage“ je Auftrag).
- **`LISTE-FIGUREN.md` vor jeder Figur** (ENTWICKLUNG Z.61): laut Kopf „die einzige Quelle fürs Aussehen“ wiederkehrender Figuren; nur Profil Story verweist darauf (für den Charakter), Profil Figur und Welt nicht. Kein Vorfall gefunden.
- **Leveldesign als Draufsicht mit Maßstab in `DESIGN-WELT.md`** (KREATIV Z.33, 1679 A) und **Bildvorschlag an der Karte nachrechnen** (KREATIV Z.56, 70.6): Profil Welt nennt `DESIGN-WELT.md` nicht. Chefentscheid, aber kein Fehlerbeleg nachgesehen.
- **Ideen sonntags aufbereiten** (KREATIV Z.31): Gesamtbild 4.3 gibt es Sokrates „einmal die Woche über `lauf.py`“; weder Kern Leitung noch eine Routine trägt es. Ablauf, kein Fehlerschutz.
- **21 bis 7 Uhr nur Technik** (ENTWICKLUNG Z.49): nirgends; `meldung.sh` (nachts nie laut) und die Nachtsperre in `startsperre-haken.py` tragen Teile.

## 3 Je Rolle

### ROLLE-TECHNIK.md (Spike)

- Z.3 Spike Prüfstelle jeder APK, vorberechnete Dateien: **T** Profil Technik „Build“
- Z.5 Kern vor jede START-Nachricht: **W** `lauf.py` (Startblock)
- Z.11 Firma, Spiel, Chef entscheidet und testet: **T** Sockel
- Z.13 Selbstbild „Technikguru“: **FV** gesondert, Abschnitt 4
- Z.13 prüft vor „fertig“: Art jedes Prüfpunkts, Bildrate vorher und nachher, vorberechnete Dateien, Ursache: **T** Profil Technik (Messung, Nachstellen, Cache), Kern Arbeitsplaner 6
- Z.13 Nein auch zu einem Team: **T** Kern Abnahme, Profil Prüfer (die Abnahme sagt Nein)
- Z.15 Oberste Direktive: **T** Sockel „Oberstes Ziel“
- Z.18 Sammelbuild, Prüfliste (1633): **T** Profil Technik „Build“; Testbitte-Schreiber **W** geplant
- Z.18 Aussehen nie als Handypunkt (1672): **T** Kern Arbeitsplaner 6 („Handy nur mit Satz ‚warum nicht Bild‘“), Profil Prüfer „Handy“
- Z.18 unter 4 Handypunkten keine APK (1524): **T** Checkliste 3 (Profil Technik: „Regeln ganz in `LISTE-CHECK-BUILD-TEST.md`“)
- Z.18 Commit-Prüfung als zweite Sicherung: **T** Profil Technik Teil B (Build-Kette)
- Z.19 Kaufmodelle und Cache vor dem Sammelbuild (854): **T** Profil Technik
- Z.19 Block nach Bauskript-Merge neu ablegen (1666): **T** Profil Technik
- Z.19 Laufzeit in die Testbitte: **T** Profil Technik
- Z.20 Godot-Technik, Licht, Shader, Leistung, Ladezeit: **T** Profil Technik
- Z.20 Grafik-Engine ausschöpfen (1270): **FV** bewusst draußen („Ziel, keine Regel“, `profil-technik.md` Gegenprüfung Nr. 2)
- Z.20 A56 Maß, Tablet Untergrenze: **T** Profil Technik
- Z.20 Firmenwerkzeuge als Kür: **FV** Vorrang liegt beim Disponenten nach Themenblock
- Z.23 Start mit `notiz.sh`, Vorrat, `vorgang.py --rolle`: **FV** Vorräte fallen; Auftrag in der ersten Nachricht (Sockel 1)
- Z.24 Checkliste ganz, `check-env.sh`: **T** Profil Technik „Build“; `check-env.sh` **W**
- Z.24 `ROLLE-ENTWICKLUNG.md` „Bestand zuerst, Alt zuerst“: **FW** (Abschnitt 2 Nr. 1, 3)
- Z.24 Leitbild vor Licht, Shader, Effekt: **T** Querprofil Signatur und Leben (lädt der Arbeitsplaner bei Bild zu)
- Z.25 Sitzung benennen: **W** `lauf.py`, Rufnamen (geplant)
- Z.28 erst nachsehen, wie andere es lösen; Messung vorher und nachher am A56: **T** Profil Technik
- Z.29 Fehler erst nachstellen (334): **T** Profil Technik
- Z.30 Aussehen urteilt der Chef; selbst ansehen: **T** Kern Abnahme (Geschmack beim Chef), Profil Figur und Prüfbild
- Z.31 Spielcode nur nach Test, Werkzeug sofort (1311): **T** Sockel 8, Profil Technik
- Z.31 eine Probe je Aussehen-Thema (621 A), Lauf gibt Sokrates frei: **FV** 621 A fällt (Archiv 19.11., 10:53); Laufbremse **W** geplant
- Z.32 Grenzen zu Tom, Jerry, Perikles, Sokrates: **FV** Rollen fallen
- Z.34 Nachrichtenkopf, Chat, `meldung.sh`, Nummer mit Titel: **T** Kern Arbeitsplaner 7 (Rückmeldung über `vorgang.py`), Kern Büro (nur das Büro meldet dem Chef)
- Z.36 Ende: Übergabe, pushen, Neustart über Ford: **T** Sockel 7, Feld „Zurück“
- Z.42–47 Zielvereinbarung Z1–Z3: **W** Routine Wochenzählung 1–3 je Profil
- Z.47 Skripte prüfen unter 25 min: **FV** Maß ohne Fehlerschutz
- Z.50 typischer Fehler t299 (Zeile übernommen statt Art geprüft): **T** Kern Arbeitsplaner 6, Profil Prüfer „Handy“
- Z.52 „Ersetzt“ (Regelbilanz der Rollendatei): **FV**

### ROLLE-ENTWICKLUNG.md (Tom, Jerry)

- Z.3 Startwort, Spike-Verweis: **FV**
- Z.3 Zusatzentwickler Tuffy: **FV** entfällt (`werkzeuge.md` C)
- Z.3 Vorrat, Handwerk `LISTE-BAUEN-TESTEN.md`: **FV**
- Z.7 Eigentümer, sieht selbst an, meldet erst dann: **T** Profil Figur und Prüfbild („Vor dem Senden selbst ansehen“), Kern Arbeitsplaner 6 („ein Nein: nicht senden“)
- Z.7 Bereiche Tom und Jerry: **FV** Themenblöcke und Fachprofile
- Z.11 Prüfzeile Schritt, passt, falsch: **W** Testbitte-Schreiber (geplant), Prüffragen im Auftrag
- Z.15–21 Zielvereinbarung: **W** Routine Wochenzählung
- Z.25 nicht ohne Hinsehen fertig; gegen „Ort fertig“, `DESIGN-STIL.md`: **T** Profil Welt, Querprofil, Profil Figur
- Z.25 gegen „Vor jeder Vorlage“ (461): **FW** (Nr. 4)
- Z.25 kein Helfer vor oder nach dem Versand (783 W1): **FV** überholt, die Abnahme prüft vor dem Chef
- Z.25 nicht mehr bauen als bestellt (114, 115): **T** Sockel „nicht darüber hinaus“, Sockel 5
- Z.29 Reihenfolge, Muss vor Kür: **W** `lauf.py`; Profil Disponent „Klasse“
- Z.29 Build und Test nach Checkliste: **T** Profil Technik
- Z.29 Befunde von Diogenes bestätigen oder verwerfen: **FV**
- Z.29 Kleines im Bereich selbst entscheiden: **FV** Grenzfall
- Z.29 Hintergrundlauf im Vorrat: **FV**
- Z.29 Warten ist nie Zugende (54): **W** Frist der Übergabezeile (Übergabekette 3, `uebergabe.py`)
- Z.29 fehlende Chefentscheidung hält nicht auf: **FV** Kern Arbeitsplaner „Frage“
- Z.31 Alt zuerst, Zeile „Alt:“, Haken; Messen ersetzt Lesen nicht (499): **FW** (Nr. 1)
- Z.31 Abgleich alt je Ort und Figur (Checkliste 8): **T** Profil Welt, Oberfläche, Klang; Profil Tester „Rückschritte“
- Z.31 Systemfrage (654): **T** Kern Arbeitsplaner 2
- Z.31 „Systemlösung?“ beantworten: **W** Wiederholungswächter `vorgang.py`; Profil Disponent
- Z.31 großes Vorhaben (1236): **FW** (Nr. 2)
- Z.33 Bestand zuerst, Reihenfolge, „Bestand geprüft:“ (377, 408): **FW** (Nr. 3)
- Z.33 Effekte zuerst in `LISTE-EFFEKTE.md`: **T** Profil Welt „Bestand“
- Z.33 Kaufrepo mit `add_repo`, nie darum bitten: **FW** (Nr. 5)
- Z.33 „ruht, wartet auf Kaufrepo“, Neustart ab 400 Tsd.: **FV** Vorgangsstand beim Disponenten; Größenbremse **W** `neustart-haken.py`
- Z.33 Teile beim Hochladen eintragen: **T** Querprofil Fremde Inhalte („je Datei Quelle, Urheber, Lizenz“)
- Z.33 mehrere Bestandsstücke drehend im selben Film: **FV**
- Z.35 Übernahme zwischen Teams: **FV** entfällt (Disponent teilt zu)
- Z.39 keine Texte erfinden: **T** Sockel 6
- Z.39 Ideen nicht gleich bauen: **T** Sockel „nicht darüber hinaus“
- Z.39 große Dateien nur beim Anfassen zerlegen: **FV** gedeckt durch Sockel 5
- Z.39 kein Spielcode ohne Test auf `main`: **T** Sockel 8
- Z.43 Wen du ansprichst, „Lehren für alle“: **FV**; Lehrenbuch **W** geplant
- Z.45 Testbitte nur mit Build, je Punkt mit Art: **W** Testbitte-Schreiber (geplant); Kern Arbeitsplaner 6
- Z.47 Aussehen erst als Bild, Build erst nach „passt“ (228): **T** Kern Arbeitsplaner 6 (erste Prüfart Bild), Profil Disponent „Fertig“
- Z.47 Bild nur mit Chefsache-Datei, `--bild`, 60 KB: **W** `meldung.sh` („Bild nur mit Chefsache-Datei“)
- Z.49 Aussehen urteilt nur der Chef (373): **T** Kern Abnahme, Kern Arbeitsplaner „Nicht deins“
- Z.49 zwei oder drei Fassungen in einem Bild: **T** Kern Arbeitsplaner („zwei bis drei Varianten“), Profil Figur („alt gegen neu“)
- Z.49 höchstens eine Vorlage je Modell und Runde: **FV** Laufbremse geplant
- Z.49 vor Versand selbst ansehen, Standbild aus dem Film: **T** Profil Figur und Prüfbild
- Z.49 Urteil im Wortlaut mit Zeit in den Vorgang: **T** Kern Büro; Haken D **W**
- Z.49 21 bis 7 Uhr nur Technik: **FV** Grenzfall
- Z.49 eine Probe je Aussehen-Thema (621 A): **FV** überholt
- Z.49 `PROBE=`, `probelauf.py`: **FV** entfällt
- Z.49 Zeigen statt messen (646): **T** Kern Abnahme, Profil Figur („das Bild gilt“)
- Z.49 Ergebnis auch mit offenen Punkten an den Chef: **FV**
- Z.49 eigener Fehler nie als Frage; Figur mittig, markiert, Spielkamera: **T** Profil Figur und Prüfbild
- Z.49 Titel in Worten des Spielers (1706): **T** Kern Arbeitsplaner 6 („beschriftet“), Kern Büro („Titel in Worten“)
- Z.49 Nachstellen am Rechner nur zur Ursache: **FV**
- Z.49 Headless-Test ist kein Probelauf (390a): **FV** entfällt mit `probelauf.py`
- Z.53 kleiner Start: **FV**
- Z.55 Startlektüre Vorrat: **FV**
- Z.56 `DESIGN-LEITBILD.md` ganz: **FV** entschieden (Gesamtbild 1a, Chef 20.11., 12:27)
- Z.56 `DESIGN-STIL.md` nach Bedarf, „Fenster und Schirme ohne Kasten“ (549a): **T** Profile Welt, Oberfläche, Klang
- Z.56 `DESIGN-ABNAHME.md` ganz: **T** Profil Welt („Ort fertig“); Rest siehe Nr. 4
- Z.57 drei neueste `CHANGELOG.md`-Einträge: **FV**
- Z.58 Checkliste vor dem ersten Build, `check-env.sh`: **T** Profil Technik
- Z.59 Ford muss laufen: **W** Routine Wache 2, `herzschlag.py`
- Z.61 `LISTE-FIGUREN.md` vor jeder Figur: **FV** Grenzfall

### ROLLE-PROJEKT.md (Perikles)

- Z.3 Startwort, Vorrat: **FV**
- Z.4 Sitzungsnamen: **W** Rufnamen (geplant)
- Z.8 Ziele und Vorrang setzen: **FV** Wochenziel fällt (Archiv 19.11., 17:44)
- Z.9 sieht, wohin Guthaben geht; Kippen zu Abläufen: **T** Routine Wochenzählung 6 (Spiel, Qualität, Verwaltung)
- Z.10 baut nicht: **FV**
- Z.11 Übergabe nur Getanes und Nachfolger: **T** Kern Leitung „Ende“
- Z.11, Z.30 ein Satz ersetzt, Werkzeug statt neuer Regel (90a): **FW** (Nr. 6); Werkzeugsperre vorschlagen **T** Kern Leitung
- Z.15–25 Zielvereinbarung Z1–Z6: **W** Routine Wochenzählung
- Z.26 zwei Wochen verfehlt → Vorlage Sokrates: **T** Routine Wochenzählung („zwei Wochen schlechter“)
- Z.31 Ziele, die keiner nachhält (106): **T** Routine Wochenzählung
- Z.35–39 Wochenziel, Muss und Kür, „M?“: **FV** fällt
- Z.38 Reifes aus `LISTE-IDEEN.md` holen: **FV** Ablauf
- Z.39 Kennzahlen bewerten, höchstens drei Empfehlungen: **T** Routine Rundblick
- Z.40 Vorrang der Vorräte: **T** Profil Disponent (Folge Eilt, Fund, Themenblock, Eingangszeit)
- Z.42–43 Kostenanteile: **W** `kosten.py`, `kostenbericht.py`, Routine Wochenzählung 6
- Z.44 Guthaben, Abos: **T** Profil Disponent „Guthaben“
- Z.45 Kostenauswertung mit Sparvorschlägen: **FV** (Votum `profil-kosten.md`: Sokrates aus den Zahlen; nicht im Kern Leitung)
- Z.46 Werkzeugfehler beheben lassen statt Zeile: **T** Kern Büro („Werkzeugfehler: Vorgang mit Profil Werkzeug, nicht umgehen“)
- Z.46 „Lehren für alle“: **FV**; Lehrenbuch **W** geplant
- Z.46 Werkzeug ist Kür, 100 Commits: **FV**
- Z.46 Doppelpack 421: **T** Kern Leitung (frischer Helfer prüft, was festlegt)
- Z.47–52 Tagesbericht: **T** Routine Tagesbericht
- Z.49 fehlt um 10 Uhr: **T** Routine Wache 6, Profil Disponent
- Z.50 Vorrat auf links (1425): **FV** fällt mit den Vorräten
- Z.51 Quellen, fremd prüfen (338.2): **T** Routine Tagesbericht („je mit Quelle“)
- Z.52 ganze Sätze, Nummer mit Sinn, belegt: **T** Sockel 3, Kern Büro
- Z.56 entscheidet Reihenfolge, „M?“: **FV**
- Z.57 Vorentscheid kleine Abläufe: **FV** fällt (Gesamtbild 4.4)
- Z.61 kein Spielcode, kein Werkzeug: **T** Kern Büro („baut nichts“)
- Z.62 Abgrenzungen zu Homer, Sokrates, Ford, Diogenes: **FV**
- Z.66–68 Wen du ansprichst: **FV**
- Z.72 Repos mit `add_repo`: **FW** (Nr. 5)
- Z.73 vor jeder Antwort Prüfbericht, `git log`: **T** Kern Arbeitsplaner „Lies zuerst … in Git“
- Z.74 Ford muss laufen: **W** Routine Wache 2
- Z.75 Entwürfe als Docs-Dokument: **FV**
- Z.76 Ende, pushen: **T** Sockel 7
- Z.80–83 Begründungen M?-Entscheide: **FV**
- Z.84 ein Text an einem Ort: **FW** (Nr. 6)
- Z.85 Rückfragen als Holschuld: **T** Kern Leitung (Chefsache), Profil Disponent „An den Chef“
- Z.86 Neustart über Ford, keine Doppelstarts: **W** `startsperre-haken.py`
- Z.87 Muss und Kür: **T** Profil Disponent „Klasse“, Guthabenstufen
- Z.91 Ruhetermine verlängern: **FV**
- Z.93 Abhängigkeit erst mit letztem Nutzer entfernen (1207): **FW** (Nr. 13)
- Z.95 Regelzeile nur an der genannten Stelle ändern (D205.3, D206.2): **FW** (Nr. 10)
- Z.97 Einstellung und Freigabe am Ergebnis prüfen (99g, 982): **T** Kern Leitung „Start“ (Modell und Aufwand), Routine Wochenzählung („greift“)
- Z.99 `git clone` statt `cp -r` (774): **FW** (Nr. 14)
- Z.101 „greift“ schließt (724 A): **T** Routine Wochenzählung
- Z.103 Regel im Wortlaut des Chefs bauen (261.5): **T** Kern Arbeitsplaner („Keine eigene Auslegung“), Kern Büro („nie umformuliert“)
- Z.104 Regeln ins Werkzeug (81r): **T** Kern Leitung „Gedächtnis“
- Z.105 Vorrat nur so kürzen, dass jeder Fund bleibt: **FV**
- Z.106 Befunde selbst abholen (65.11): **T** Kern Arbeitsplaner „Lies zuerst“
- Z.107 Umbau von der alten Datei, dreifach prüfen (D41.1): **FW** (Nr. 9)
- Z.108 je Schritt Prüfung (274): **T** Kern Arbeitsplaner 3 (Nachstellauftrag, kein Bau), Übergabekette
- Z.109 Last auf alle Entwickler verteilen (1600): **FV** überholt (frische Fachkraft je Auftrag)
- Z.110 nie „wartet auf dein Ja“ im Chat (715): **T** Kern Büro, Profil Disponent „An den Chef“

### ROLLE-BETRIEB.md (Ford)

- Z.3 Name, Uhr :03: **W** Routine Wache, `herzschlag.py`
- Z.3 Kennungen der Teams: **FV**
- Z.7 Arbeit läuft, nichts doppelt, nichts hängt, nichts liegt: **T** Profil Disponent „Takt“
- Z.7 Lauf unter einer Minute: **FV**
- Z.11 Gutes Ergebnis 16.10.: **FV**
- Z.19–21 Zielvereinbarung: **W** Routine Wochenzählung (Liegezeit, Bremsen)
- Z.25 typischer Fehler: Aufträge liegen lassen (107): **T** Profil Disponent („sofort, Anhalt 5 Minuten“), Routine Wache 3
- Z.25 Titel gegen Rollentabelle (101): **W** Rufnamen (geplant)
- Z.29 Starts rechnet `lauf.py`, Ford beurteilt nichts: **T** Profil Disponent „Takt“
- Z.29 Startregeln je Rolle, Muss vor Kür: **W** `lauf.py`, `startbar.py`
- Z.29 Kern voranstellen (1683): **W** `lauf.py`
- Z.29 „Pause bis“: **FV** fällt mit den Vorräten
- Z.30 Neustart-Meldungen sofort, Kosten des Vorgängers (124): **T** Profil Disponent „Neustarts“; `lauf.py --kosten` **W**
- Z.31 „wartet auf“ vererbt die Klasse: **W** `startbar.py`
- Z.32 Eingang zuteilen, Herrenloses nie liegen lassen: **T** Profil Disponent „Eingang“, „Sokrates startest du“
- Z.33 Anstöße täglich auf Alter: **W** Fristen der Übergabezeilen; Routine Wache 3
- Z.34 Besetzung, Stillstand mit Ursache: **W** `lauf.py`; Profil Disponent „Besetzung prüfen“
- Z.35 Telegram: du bist dran, Tagesbericht fehlt, Sitzung hängt, ab 3 roten Läufen: **T** Routine Wache 1–6
- Z.35 roter Lauf hält den nächsten Push bis „Rot:“ (748): **W** `rotbuch.py` (Teil; der Halt in `probelauf.py` entfällt)
- Z.39 nichts Inhaltliches, keine Freigaben: **T** Kern Büro
- Z.39 kein Code, Build, Spieltext: **T** Kern Büro
- Z.39 fremde Notizen nur in genannten Fällen, Umschichten: **FV**
- Z.39 nie zwei Sitzungen für dieselbe Zeile: **W** `startsperre-haken.py`, Quittung in `uebergabe.py`
- Z.39 nachts nie laut: **W** `meldung.sh`
- Z.43 Wen du ansprichst: **FV**
- Z.47 Startlektüre: **FV**
- Z.49 nur archivieren, was ARCHIVIERE nennt, nie laufend: **T** Profil Disponent („jede Zeile seiner Ausgabe und nicht mehr“); `lauf.py` **W**
- Z.49 „schließe …“ in anderer Sitzung (1441): **W** Haken D (`chefwort.py`)
- Z.51 Repos mit `add_repo`: **T** Profil Disponent „Takt“
- Z.51 eigene Uhr: **T** Profil Disponent („dich startet die Wache, sie läuft mit eigener Uhr“)
- Z.51 Notizen holen und pushen: **T** Sockel 7
- Z.51 eine Sitzung (1574): **T** Übergabekette 4
- Z.55 „wartet auf Ford“ leeren (1098): **W** Zustände der Übergabezeile (`uebergabe.py`)
- Z.56 RUNNING als `working` (693): **W** `lauf.py` schreibt die Besetzung
- Z.57 archivieren erst bei idle über 60 s; `total_cost_usd`; Schätzung: **W** `lauf.py --kosten` (nicht im Code nachgesehen)
- Z.58 Archivregel 261.5 im Einzelnen: **W** `lauf.py`
- Z.58 jede ARCHIVIERE selbst; dieselbe Zeile im nächsten Lauf = WARNUNG-LAUT: **T** Profil Disponent; `lauf.py` **W**
- Z.59 `create_session` mit `source_url`, `source_revision` `main` (382): **W** `lauf.py` (Kopf :10, :101)
- Z.60 nie archivieren unter 15 Minuten nach Chefnachricht: **W** `neustart-haken.py` (liest heute aus `ARBEIT-BETRIEB.md`, das fällt; Umbau in `werkzeuge.md` A vermerkt)
- Z.61 `lauf.py` erst ohne, dann mit `--sperre` (843): **W** `lauf.py` (Kopf :10; nicht nachgeprüft)

### ROLLE-PRUEFUNG.md (Diogenes)

- Z.64 Startwort; nie zulasten wartender Entwicklung (75l): **FV** Guthabenstufen beim Disponenten
- Z.64 Prüfbericht: **T** Routine Wochenzählung („neue Spalte in `docs/PRUEFBERICHT.md`“)
- Z.68 glaubt nichts, was er nicht selbst sah; hat nicht mitgebaut: **T** Kern Abnahme („Erst sehen, dann lesen“, „Du änderst nichts“)
- Z.72 Gutes Ergebnis D20.1: **FV**
- Z.76–82 Zielvereinbarung: **W** Routine Wochenzählung
- Z.86 typischer Fehler: Vermutungen statt Beleg: **T** Sockel 3, Profil Prüfer (je Prüffrage ein Satz Beleg)
- Z.90 Vergleichsbilder messen, Hinweis statt Halt: **FV** überholt (Prüfer entscheidet vor dem Chef)
- Z.90 Kontaktblatt statt Film (368): **FV**
- Z.91 Helligkeit gegen Stimmung, Schatten Sonne aus Süden: **FV** überholt (Profil Welt nimmt „Süden, Osten“ ausdrücklich aus)
- Z.91 Vollständigkeit gegen `LISTE-ABGLEICH-ALT.md`: **T** Profil Welt, Profil Tester „Rückschritte“
- Z.92 gedrehte Ansichten: **T** Querprofil („Haltung aus allen Blickrichtungen prüfen“), Profil Welt („Vordergrund deckt nie“); Rückseiten, Flimmern nicht genannt
- Z.93 „gemessen“ im Bestand: **FV**
- Z.94 Stichprobe 373: **T** Routine Wochenzählung
- Z.95 `main` vor Release prüfen: **T** Profil Release („ohne Ergebnis des Testers kein Release“), Profil Tester
- Z.95 Prüfung bei „Ort fertig“, nach großem Umbau: **T** Profil Tester
- Z.95 `regelcheck.py --anlass`: **W**
- Z.95 Regeländerungen gegen Wortlaut des Chefs (421): **T** Kern Leitung (Gegenprüfung durch frischen Helfer)
- Z.95 Prüfbericht mit den wichtigsten Befunden und Ungeprüftem: **T** Profil Tester „Meldung“ (zuletzt, was nicht prüfbar war)
- Z.95 behobene Befunde nachprüfen: **T** Profil Prüfer 3, Profil Tester 1
- Z.96 Wochenzählung, über 6 h Liegendes: **T** Routine Wochenzählung 4
- Z.100 nichts am Spiel ändern, auch keinen Tippfehler: **T** Kern Abnahme
- Z.100 Spielgefühl nicht beurteilen: **T** Kern Abnahme
- Z.100 Kennzahlen nicht bewerten: **T** Routine Wochenzählung
- Z.100 höchstens 10 Standbilder, kein Film: **FV** überholt
- Z.100 nur eigene Notizen: **T** Kern Abnahme
- Z.104 Befundvorgänge beim Besitzer: **T** Kern Abnahme („Vorgänge legt das Büro an“); `vorgang.py rueckmeldung` **W**
- Z.104 „greift“ prüfen: **T** Routine Wochenzählung
- Z.104 nie selbst starten: **W** `startsperre-haken.py`
- Z.108 Startlektüre: **FV**
- Z.109 nur Neues prüfen: **FV** Prüfer je Auftrag
- Z.112 Repos mit `add_repo`: **FW** (Nr. 5)

### ROLLE-KREATIV.md (Homer)

- Z.3 Startwort, `story.sh`: **FV**
- Z.7 Selbstbild „schräger Kreativdirektor“: **FV** gesondert, Abschnitt 4
- Z.7 denkt mit, nickt nicht ab: **T** Profil Story („je Auftrag eine eigene Idee“)
- Z.7 düster, erwachsen, lebendig, viele Kapitel: **T** Sockel „Oberstes Ziel“, Querprofil, Profil Story
- Z.7 Wahl des Spielers (49/50): **T** Profil Kampf „Wahl“
- Z.11 Gutes Ergebnis 72u: **FV**
- Z.19–21 Zielvereinbarung: **W** Routine Wochenzählung
- Z.25 Muster sofort festschreiben (112): **T** Profil Story („Abgenommene Szenen sind das Maß“); Ort siehe Nr. 6
- Z.29 Story mit dem Chef, Fäden halten: **T** Profil Story, Sockel 6
- Z.29 Storyfragen ohne Zuruf: **FV**
- Z.30 Stilfragen; Modell vor dem Bau beschreiben (373): **T** Kern Arbeitsplaner („Ziel“, „Fehlt ein Chefwort: Frage“)
- Z.31 Ideen prüfen: **T** Kern Leitung („Idee in `LISTE-IDEEN.md`“, „Nein vollwertig“)
- Z.31 sonntags Ideenspeicher: **FV** Grenzfall
- Z.32 Balance vorbereiten: **T** Profil Regeln „Rechnen vor Bauen“
- Z.33 Leveldesign als Draufsicht in `DESIGN-WELT.md` (1679 A): **FV** Grenzfall
- Z.37 Tippfehler selbst: **T** Querprofil Fremde Inhalte
- Z.37 Ideen verwerfen: **FV**
- Z.41 kein Spielcode, nichts entscheiden: **T** Sockel, Kern Arbeitsplaner
- Z.45 Wen du ansprichst: **FV**
- Z.49 Start, Ende: **FV**
- Z.51 Repos mit `add_repo`: **FW** (Nr. 5)
- Z.55 Storyplan, Marken, Entwürfe in `STORY-…`: **T** Profil Story, Querprofil Fremde Inhalte
- Z.56 vor Aussehensaussage Leitbild, vor Oberflächenempfehlung Code: **T** Querprofil, Profil Story („nur Knöpfe, die es im Spiel gibt“), Profil Kampf („erst im Code nachsehen“)
- Z.56 Bildvorschlag an der Karte nachrechnen (70.6): **FV** Grenzfall
- Z.57 jedes Chefsache-Bild auf Telegram (277): **W** `meldung.sh`
- Z.58 fremd prüfen vor „fertig“ (486): **T** Abnahme (Kern, Profil Prüfer), Kern Leitung Gegenprüfung
- Z.59 sonntags Vorratsgrenzen anderer: **FV**
- Z.60 Aussehensvorschläge nennen Kosten (24): **FV**
- Z.61 gegen den Code, nicht gegen den Plan (340.6 A): **T** Profil Story, Profil Kampf
- Z.61 keine Vorlage über zwei Runden: **T** Profil Prüfer („steckt fest“ beim zweiten Nein)
- Z.65 Storyplan: vier Augen, Kult, Hinweise doppelt, Anreiz statt Pfeil: **T** Profil Story, Sockel 6
- Z.66 Heldenbau (49, 50): **FV** Begründung; ob `DESIGN-BRS.md` es trägt, nicht nachgesehen
- Z.67 Absicht und Reaktion, Reihen statt Raster: **T** Profil Kampf (Verweis `DESIGN-KAMPF.md` „Was gilt“, `DESIGN-GEGNER.md`; „`mars.gd` rechnet mit Reihen“)
- Z.68 Licht nur aus sichtbaren Quellen: **T** Querprofil „Signatur“
- Z.68 Dunkel erlaubt Schleichen, Wahl je Höhle: **FV**
- Z.72 keine Wegweiser: **T** Profil Welt „Blick“, Profil Story

### ROLLE-BERATUNG.md (Sokrates)

- Z.75 Startwort, Vorrat: **FV**
- Z.76 Startprompt, Rückfall: **FV**
- Z.77 gekürzt 18.11.: **FV**
- Z.81 Stab des Chefs: **T** Kern Leitung; Systemrunde **FV** (entfällt, Archiv 22.11., 10:27)
- Z.82 Fachberater AD&D, DSA, Descent; weder Grind noch Pen and Paper: **FV** gesondert, Abschnitt 4
- Z.83 Gutes Ergebnis 109: **FV**
- Z.89–91 Zielvereinbarung: **W** Routine Wochenzählung 9 (Entscheide, zurückgedreht)
- Z.93 fast alles „ja“ heißt zu wenig geprüft: **T** Kern Leitung („Nein ist vollwertig“, Gegenargument je Vorlage)
- Z.95 zustimmen statt prüfen: **T** Kern Leitung Haltung 1
- Z.95 warten statt vorausdenken (644, 649, 653): **T** Kern Arbeitsplaner 2, Routine Rundblick; Wiederholungswächter **W**
- Z.99 Unsicherheit benennen, Fragen nicht zurückspielen: **FV** (nur Profil Markt: „wie sicher“)
- Z.100 Vorausdenken, Systemrunde: **T** Kern Arbeitsplaner 2, Routine Rundblick
- Z.101 Chefrunde: **T** Profil Chefrunde
- Z.101 Rollenspiegel: **FV** entfällt
- Z.102 `DESIGN-BRS.md` aktuell halten: **FW** (Nr. 7)
- Z.103 faire Schrauben: **T** Profil Markt und Recherche, Profil Oberfläche
- Z.104 eigene Kosten zählen mit: **FV**
- Z.108 Vorentscheid zu Abläufen, Abgleich, unsicher vorlegen: **T** Kern Leitung („im Zweifel legst du es ihm zum Billigen vor“)
- Z.108 Ablauffragen nicht vorlegen: **FV**
- Z.109 Läufe nach 621 A selbst freigeben: **FV** überholt
- Z.110 Vorbehalt, Aussehen nur mit Ermächtigung: **T** Kern Leitung „Vorbehalt“
- Z.111 Bremse „mehr als zwei zurück“: **W** `abgleich.py` (Bremse Vorentscheide)
- Z.112 nie Spielcode, Story, Vorrang: **T** Kern Leitung
- Z.116 Stärken, Schwächen 620; Referenzszene; Wiederholfunde vor Neuem: **T** Profil Tester („Dorf bis Wolfskampf“, Rückschritte), Profil Disponent (Fund des Chefs vor Themenblock)
- Z.117 vertrauliche Links: **FW** (Nr. 12)
- Z.118 ältere Begründungen in Git: **FV**
- L1 erst nachsehen, Chefworte aus dem Archiv: **T** Kern Leitung, Sockel 3
- L1 Helferbefund erst nach Blick in seine Quelle: **FW** (Nr. 8)
- L2 Technikfragen an die Technik, „wie andere es lösen“: **T** Profil Technik, Kern Arbeitsplaner 2
- L2 Grundtechnik gegen Alternativen bei Kapitelabschluss: **FV** (Routine Rundblick „Neues in Technik“ deckt halb)
- L3 Gegenargument mit Weg; wer nutzt es noch: **T** Kern Leitung, Kern Arbeitsplaner 2
- L4 Frage zuerst als Datei: **T** Kern Leitung („In `docs/chefsache/` gehört nur …“)
- L5 beim Start Chefsache gegen Archiv: **T** Kern Leitung („vorher Bestand und Archiv suchen“)
- L6 Sperre und Werkzeug vor dem Befolgen prüfen: **FW** (Nr. 11)
- L7 Empfehlung am Ergebnis prüfen: **T** Routine Wochenzählung („greift“)
- L8 Frage kein Auftrag, Auftrag kein Entscheid, Idee heißt prüfen: **T** Kern Leitung
- L9 Gültiges an einen Ort: **FW** (Nr. 6)
- L10 eigene Vorschläge fremd prüfen: **T** Kern Leitung; Stop-Haken 1732 **W** geplant
- L11 Nummer mit Titel: **T** Kern Leitung „Form“
- L12 Vorrat nach jeder Nachricht lesen: **W** Wecker und Übergabezeile

### ROLLE-BERATUNG-START.md (Startprompt Sokrates)

- Z.136 gilt seit, Probe: **FV**
- Z.138 `lauf.py` setzt Kern, Handstart: **W** `lauf.py`
- Z.140 Rückfall: **FV**
- Z.146 Stab, Firma, Spiel, Chef entscheidet: **T** Kern Leitung, Sockel
- Z.148 Oberste Direktive: **T** Sockel
- Z.151 Modell und Aufwand prüfen und nennen: **T** Kern Leitung „Start“
- Z.152 Übergabe lesen: **T** Kern Leitung „Gedächtnis“
- Z.153 Chefsache seit Übergabe gegen Archiv, Entschiedenes löschen: **T** Kern Leitung („gehört nur, was der Chef jetzt entscheiden … kann“), Profil Chefrunde
- Z.154 Lehren lesen; Leitbild vor Aussehensaussage: **T** Kern Leitung „Gedächtnis“; Leitbild **FV** (1a)
- Z.155 Sitzung benennen, Startmeldung: **T** Kern Leitung „Start“
- Z.158 kein Votum ohne Gegenprüfung: **T** Kern Leitung
- Z.159 prüfen statt zustimmen; Zahlen bei 0, 24, 49, 74, 100: **T** Kern Leitung, Profil Regeln
- Z.160 Technikfragen an Spike: **T** Profil Technik, Kern Arbeitsplaner
- Z.161 Sperre vor dem Befolgen prüfen: **FW** (Nr. 11)
- Z.162 Aussehen nur an Bild oder Film: **T** Kern Leitung „Vorbehalt“
- Z.163 Nein zu Idee, nie zu Auftrag: **T** Kern Leitung
- Z.164 Chefworte nur aus Archiv, Stand aus Quelle: **T** Kern Leitung
- Z.165 Grenzen: **T** Kern Leitung
- Z.166 Repos mit `add_repo`: **FW** (Nr. 5)
- Z.169 Nachrichtenkopf, Ergebnis zuerst: **T** Kern Leitung „Form“ (Ergebnis zuerst); Kopf mit Name und Zeit nicht im Text
- Z.170 Nummer mit Titel: **T** Kern Leitung
- Z.171 Rückfrage nur mit Datei in `entscheiden/`: **T** Kern Leitung „Chefworte“ (Chefsache)
- Z.172 Antwort des Chefs: Archiv, Datei löschen, Folgeauftrag, pushen: **T** Kern Leitung „Chefworte“; BRS siehe Nr. 7
- Z.173 `meldung.sh`, Chefsache-Bild mit `--bild`: **T** Kern Leitung „Form“; `meldung.sh` **W**
- Z.174 Entwürfe als `.md`, Artefakt nur ausnahmsweise: **FV**
- Z.176 Ende: Lehren, „Kosten auf“, Nachfolger: **T** Kern Leitung „Ende“, „Gedächtnis“; „Kosten auf“ entfällt
- A Chefrunde: **T** Profil Chefrunde
- B Spieledesigner: **FV** nie gestartet (`1625-prompts-kuerzen.md`:17)
- C Markt und Strategie: **T** Profil Markt und Recherche
- C BornWire 253 in eigener Sitzung: **FV**
- D Nachtvertretung: **T** Kern Leitung („Vertreten nur, wenn er es sagt … ‚Vertretung‘“); Morgenliste nicht im Text

## 4 Selbstbild („Wer du bist“)

### Was die Rollendateien sagen

- `ROLLE-TECHNIK.md` Z.13 (Chef 18.11., 16:28: „klarstellen, ja, was er drauf hat, was für ein Technikguru er ist“): „Du bist unser Technikguru. Du kennst Godot bis in den Renderer, liest ein Profil wie andere einen Text, weißt, was ein Handy-Grafikchip verzeiht und was nicht, und hast es bewiesen: Schattenfehler 1645, Grafikstufen 698, Kauf-Cache 854. … Ein Guru erkennt man daran, was er prüft, bevor er ‚fertig‘ sagt …“
- `ROLLE-ENTWICKLUNG.md` Z.7: „Eigentümer deines Bereichs, kein Auftragsempfänger: du baust, was bestellt ist, siehst es selbst an und meldest erst dann.“
- `ROLLE-KREATIV.md` Z.7: „Der schräge Kreativdirektor und Erzähler. … Du denkst mit, du nickst nicht ab.“
- `ROLLE-PRUEFUNG.md` Z.68: „Wie dein Namensgeber gehst du mit der Laterne: Du glaubst nichts, was du nicht selbst gesehen hast. Dein Wert ist, dass du nicht mitgebaut hast.“
- `ROLLE-BETRIEB.md` Z.7: „Betriebsleiter. Du sorgst dafür, dass die Arbeit läuft …“; `ROLLE-PROJEKT.md` Z.8–10 (Projektmanager, setzt Ziele); `ROLLE-BERATUNG.md` Z.82: „Fachberater für Rollenspiele (AD&D, Das Schwarze Auge, Descent) und den Markt für Handy und Tablet“; `ROLLE-BERATUNG-START.md` B: „Spieledesigner, ein Kreativbolzen“.

### Was die neuen Texte haben

- **Kerne:** ja, je ein Rollensatz: Kern Leitung „Du bist **Sokrates**, Berater, Vertrauter und Vertreter des Chefs“; Kern Arbeitsplaner „Du bist der **Arbeitsplaner** im Büro“; Kern Abnahme „Du arbeitest in der **Abnahme** … was du durchlässt …, ist dein Fehler“; Kern Büro „Du arbeitest im **Büro**“.
- **Profile Büro, Abnahme, Leitung:** Profil Disponent „Du läufst dauerhaft und hältst den Takt“; Profil Prüfer „Du prüfst **einen Auftrag**“; Profil Tester „Du testest **ein Ganzes**“; Profil Chefrunde „Du führst die Chefrunde“; Profil Markt und Recherche „Zusätzlich zu deiner Rolle bist du heute Marktkenner und Rechercheur …“ (das einzige Profil mit Fachrolle).
- **Fachprofile der Werkstatt** (Technik, Werkzeug, Welt, Kampf, Regeln, Kataloge, Klang, Oberfläche, Story, Figur und Prüfbild): **nein**. Sie beginnen mit dem Fach als fettem Wort („**Technik.** Godot-Technik, Licht, Shader …“). Die Werkstatt hat keinen Kern („kein Kern: der Auftrag“, Gesamtbild 0); eine Fachkraft liest also Sockel, Profil, Auftrag, und nirgends steht, wer sie ist. Der Satz „Ein Guru erkennt man daran, was er prüft …“ ist als Regel in Profil Technik aufgegangen (Messung, Nachstellen, Cache), der Anspruch selbst nicht.

### Was Anthropic dazu sagt

- „Setting a role in the system prompt focuses Claude’s behavior and tone for your use case. Even a single sentence makes a difference“ (Abschnitt „Give Claude a role“; Beispiel: „You are a helpful coding assistant specializing in Python.“). https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices (beide genannten Adressen `docs.claude.com/…/system-prompts` und `…/claude-4-best-practices` leiten über `platform.claude.com` auf diese eine Seite „Prompting best practices“ um.)
- „Providing context or motivation behind your instructions, such as explaining to Claude why such behavior is important, can give Claude more information about your goals and help it deliver more targeted responses.“ … „Claude can generalize from the explanation.“ (ebd., „Add context to improve performance“)
- „Think of Claude as a brilliant but new employee who lacks context on your norms and workflows. The more precisely you explain what you want, the better the result.“ (ebd., „Be clear and direct“)
- Gegen Übertreibung: „If your prompts were designed to reduce undertriggering … these models might now overtrigger. The fix is to soften any aggressive language.“ (ebd., „Tool usage“) und für das neueste Modell: „[das neueste Modell] can also expand the scope of a task, adding steps that weren’t requested or applying its own judgment about what the task should be. For narrow tasks, constrain scope explicitly“ (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5, „Task scope and over-verification“).
- `1625-prompts-kuerzen.md` hat zum Selbstbild nichts gesammelt; dort nur „Kern je Rolle höchstens 3 KB: wer, Ziel, fünf Regeln, wo nachsehen“ (Vorschlag 1, „wer“ also vorgesehen) und die Quellen gegen Länge („every line … takes a little of Claude's attention“, Context Rot, Widersprüche).

### Abwägung

Für einen kurzen Rollensatz im Fachprofil spricht: Anthropic nennt die Rolle ausdrücklich als Hebel, schon ein Satz wirke; die Werkstatt hat als einzige Gruppe keinen Kern und damit gar keinen Rollensatz; ein Satz zum Anspruch („bis in den Renderer“) setzt den Maßstab, an dem die Fachkraft ihr „fertig“ misst, und erklärt so das Warum der Regeln darunter (Anthropic: „generalize from the explanation“). Er kostet 100 bis 160 Byte.

Was nicht hineingehört: Lob und Geschichte („hast es bewiesen: 1645, 698, 854“, „unser Technikguru“) steuern nichts; „Du sagst Nein …, auch zu einem Team“ verleitet zu dem, was Anthropic für das neueste Modell als Schwäche nennt (eigenes Urteil über den Auftrag hinaus) und widerspricht dem Sockel („nicht darüber hinaus“, „Fund … zurückmelden, nicht beheben“). Der Satz soll Fach und Maßstab nennen, nicht die Person loben.

Stapeln: Profil Kampf lädt Figur und Prüfbild und Regeln, Profil Welt lädt Figur und Prüfbild. Darum keinen Rollensatz in Zusatzprofilen (Figur und Prüfbild, Querprofile), und die Sätze so, dass zwei nebeneinander nicht streiten („Du arbeitest wie …“ statt „Du bist ausschließlich …“).

### Empfehlung je Fachprofil

| Profil | ja/nein | Vorschlag Wortlaut (vor den ersten Absatz) | Byte |
|---|---|---|---|
| Technik | ja | „Du kennst Godot bis in den Renderer und weißt, was ein Handy-Grafikchip verzeiht; darum sagst du ‚fertig‘ erst mit Ursache, Messung am A56 und Beleg.“ | 154 |
| Werkzeug | ja | „Du baust Werkzeuge wie ein erfahrener Python- und Git-Entwickler: klein, getestet; ein Werkzeug, das still das Falsche tut, ist schlimmer als eines, das abbricht.“ (zweiter Teil ist Leitlinie im Archiv, Eintrag zu 228) | 162 |
| Welt | ja | „Du bist Leveldesigner und Umgebungskünstler für ein düsteres Rollenspiel in diagonaler Sicht: Orte wirken bewohnt und laden zum Erkunden ein.“ | etwa 142 |
| Kampf | ja | „Du denkst wie ein Designer taktischer Rundenkämpfe: jede Runde bietet eine echte Wahl, und du prüfst das an Zahlen und Bildern, nicht an Eindrücken.“ | 151 |
| Regeln | ja | „Du arbeitest wie ein Regelautor für Rollenspiele: jede Zahl gerechnet und aus der Quelle, nichts aus dem Gedächtnis.“ | 118 |
| Klang | ja | „Du bist Klanggestalter für Spiele: Raumklang aus echten Aufnahmen, Pegel als Zahl; man hört, was da ist oder glaubhaft wäre.“ | etwa 125 |
| Oberfläche | ja | „Du gestaltest Spieloberflächen fürs Handy: wenige Schritte, klare Zeichen, nichts drängt sich auf.“ | 101 |
| Story | ja | „Du schreibst wie ein Autor düsterer Fantasy für Erwachsene: knapp, glaubwürdig, Vorausdeutung statt Erklärung.“ | 114 |
| Kataloge | nein | Datenpflege; „eine Stelle“ steht schon als Ziel im ersten Satz | 0 |
| Figur und Prüfbild | nein | Zusatzprofil, wird von Welt und Kampf zugeladen (Stapeln) | 0 |
| Querprofile (Signatur und Leben, Fremde Inhalte) | nein | quer, ohne eigene Rolle | 0 |
| Prüfer, Tester, Disponent, Chefrunde, Markt, Release | nein | haben schon einen Rollensatz oder brauchen keinen; das „Laterne“-Bild von Diogenes ist als Regel im Kern Abnahme („Erst sehen, dann lesen“) | 0 |

Summe bei allen acht: etwa 1.070 Byte, je Sitzung aber nur 100 bis 300 (ein bis zwei Fachprofile).

**Stärkstes Gegenargument:** Anthropic belegt Wirkung auf „behavior and tone“, nicht auf Fehlerrate; bei uns gibt es keine Messung, dass ein Rollensatz einen der gezählten Fehler (Erstfunde des Chefs, Rückgaben je Profil) senkt, und jeder Satz kostet Aufmerksamkeit (`1625-prompts-kuerzen.md`, Quelle 1). Dazu: Profil Technik ist abgenommen (21.11., 15:15), die übrigen Werkstattprofile ebenso oder gegengeprüft; jeder neue Satz ist eine Änderung am Abgenommenen, die das Wort des Chefs braucht. **Weg, der es entkräftet:** zuerst nur Profil Technik (dort liegt der ausdrückliche Chefwunsch vom 18.11., 16:28) und ein zweites Profil mit vielen Aufträgen (Welt oder Kampf), zwei Wochen; die Routine Wochenzählung vergleicht Rückgaben je Profil (Zahl 3) mit und ohne Satz; trägt es nicht, wieder streichen (Regelbilanz).

## 5 Gegenargument je Empfehlung

| Empfehlung | stärkstes Gegenargument | Antwort |
|---|---|---|
| Nr. 1 Alt zuerst in „Bisher“ | Arbeitsplaner muss das Kaufrepo lesen; Kosten je Auftrag | „oder keine (Grund)“; Rückschritte gegen alt sind die teuersten Funde des Chefs (620) |
| Nr. 2 großes Vorhaben → Frage | mehr Fragen, Arbeitsplaner kann „groß“ schlecht schätzen | Schwelle benennen; Chef: „das ist wichtig“ (1236) |
| Nr. 3 Bestand zuerst | Fremde Inhalte lädt zu spät | Zeile im Auftrag, nicht nur im Querprofil |
| Nr. 4 „Vor jeder Vorlage“ | zwei Orte für Bildregeln | Verweis statt Abschrift, oder bewusst streichen mit Chefwort |
| Nr. 5 `add_repo` | Sockelgrenze | ins Profil Technik, nicht in den Sockel |
| Nr. 6 Regelbilanz | Kern Leitung abgenommen, nahe 3 KB | ein Satz; ohne ihn wachsen die Profile wieder, gegen das Ziel des Chefs |
| Nr. 7 BRS nachziehen | kein Einzelfall belegt | Profil Regeln macht BRS zur einzigen Quelle; Folgefehler sicher |
| Nr. 8–12 Lehren Sokrates | gehören ins Gedächtnis, nicht in den Kern | einverstanden; dann muss das Gedächtnis vor der Umstellung stehen |
| Nr. 13, 14 Handwerk Werkzeug | allgemeines Wissen, Einzelfälle | je ein Satz, Folge war ein ungeprüfter Commit auf `main` (774) |
| Selbstbild in acht Fachprofilen | keine Messung bei uns; Änderung am Abgenommenen | erst Technik und ein zweites, zwei Wochen messen |

## 6 Was ich nicht prüfen konnte

- **Werkzeugcode:** ob `lauf.py`, `neustart-haken.py`, `startsperre-haken.py` die mit **W** markierten Regeln heute wirklich tragen (archivieren erst bei idle über 60 s, `total_cost_usd`, „erst ohne, dann mit `--sperre`“, 15-Minuten-Schutz); geprüft nur die Kopfzeilen von `lauf.py` (:10, :101) und die Beschreibungen in `werkzeuge.md`.
- **Verweise auf weiter geltende Dateien:** ob `DESIGN-KAMPF.md` „Was gilt“, `DESIGN-GEGNER.md`, `DESIGN-BRS.md`, `DESIGN-STIL.md` die Inhalte tragen, die ich als „im Text über Verweis“ gezählt habe (Absicht und Reaktion, Heldenbau, Klangregeln); nicht geöffnet.
- **Inhalt von „Vor jeder Vorlage“ gegen Profil Figur und Prüfbild** Punkt für Punkt: nur Kopf und erste Kennungen gelesen; wie viel davon schon im Profil steht, ist ungezählt.
- **Vorfälle hinter einigen Nummern** (54, 70.6, 112, 228, 377, 499, 1207, 774, D41.1, D205.3): nur aus den Rollendateien zitiert; im Archiv gefunden nur 1236, 408, 1311, 1672, 854; 377, 774, 1207 stehen dort nicht (vermutlich in Git oder im Vorgangsarchiv der Liste).
- **Falltest:** keine Probe, ob eine Fachkraft mit den vorgeschlagenen Sätzen besser arbeitet; die Empfehlung Selbstbild ist begründet, nicht gemessen.
- **Modellseiten:** von Anthropic gelesen die allgemeine Seite und die zu das neueste Modell; die Seiten zu den Modellen, mit denen Sitzungen laufen, nicht im Einzelnen (`LISTE-BETRIEB.md` nicht geöffnet).
- **Zählweise:** eine Zeile der Rollendatei kann mehrere Regeln tragen; ich habe nach inhaltlichen Aussagen getrennt, nicht nach Zeilen. Der Abgleich vom 20.11. hat anders geschnitten, die Summen sind nicht eins zu eins vergleichbar.
