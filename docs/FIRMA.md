# BornWire TCS – Aufbau und Ablauf (Nachbau-Anleitung)

Zweck (1306, Chef 15.11., 17:20): „Claude, lies dir das Dokument durch und bau das nach, dann legen wir los.“ Beschreibt, **was** die Firma tut und **wie**, organisatorisch und technisch, so dass eine neue Sitzung sie in einem leeren Repo nachbauen kann. Regeln im Wortlaut stehen in `CLAUDE.md` (lesen alle) und den Rollendateien; hier steht das Gerüst und wo jedes Teil liegt. Bei Abweichung gilt die genannte Datei. Gepflegt von Perikles.

## 1. Das Prinzip in fünf Sätzen

1. Ein Mensch (der **Chef**) entscheidet und testet; alle anderen sind **Claude-Code-Sitzungen in der Cloud** (claude.ai/code) mit fester Rolle, jede Rolle genau einmal gleichzeitig.
2. **Gedächtnis ist das Repo**, nicht die Sitzung: jede Sitzung ist kurzlebig, liest beim Start Regeln, Rolle und Vorrat aus `main` und übergibt am Ende schriftlich.
3. Arbeit ist in **Vorgängen** mit fester Nummer organisiert, eine Zeile je Vorgang in einer Liste; Werkzeuge rechnen daraus, wer was als Nächstes tut.
4. **Ford** (Betriebsleiter) wird stündlich geweckt, ruft ein Werkzeug und startet, weckt und archiviert danach Sitzungen; er urteilt nicht.
5. Der Chef sieht **Telegram** (Meldungen, Bilder, Filme, 👍/👎) und den Ordner **Chefsache**; Code kommt erst nach seinem Test auf `main`, getestet in der APK über den Reiter „Test“.

## 2. Was man zum Nachbauen braucht

| Teil | Hier | Zweck |
|---|---|---|
| Spiel-Repo | `tramour-cmyk/androidapp_rpg_bornim` | Code (Godot 4.7.2 unter `godot/`), Notizen (`CLAUDE.md`, `CHANGELOG.md`, `docs/`), Werkzeuge (`tools/`), Bau (`.github/workflows/`) |
| Zweit-Repo, privat | `tramour-cmyk/bornim-kaufmodelle` | gekaufte Rohdateien (3D-Modelle), nie im Spiel-Repo; der Bau holt sie mit Secret `KAUF_TOKEN` |
| Claude-Account | Max („Zentrale“), alle Rollen | Sitzungen in claude.ai/code; Kosten als API-Preis je Sitzung (`usage.cost_usd`) |
| Cloud-Umgebung | in claude.ai/code angelegt | Netz (GitHub, Godot-Downloads, api.telegram.org), Variable `TELEGRAM_BOT_TOKEN`; Modell je Rolle in `tools/lauf.py` (`MODELL`, `MITTEL`) |
| Telegram-Bot | `@Bornim_Ford_Bot`, ein Chat mit dem Chef (Kennung fest in `meldung.sh`, `reaktionen.py`) | Protokoll an den Chef; Schlüssel nur als Umgebungsvariable |
| GitHub Actions | `.github/workflows/` | APK bauen, Filme und Bilder rechnen, Chefsache-Übersicht schreiben |
| GitHub-Secrets | `KAUF_TOKEN`, Signatur, Webseite (`FTP_*`, `BORNWIRE_*`) | nie im Repo |
| Handy des Chefs | Geräte in `LISTE-TESTGERAETE.md` | APK installieren, Reiter „Test“ abhaken |

Grundregel für Notizen: nur auf `main`, direkt committen und pushen; Code nur auf Arbeitszweigen `claude/<team>-<thema>`. Jede Sitzung hält dafür eine zweite Arbeitskopie `/home/user/bornim-main` (legt `tools/notiz.sh` an).

## 3. Rollen

| Rolle | Tut | Darf nicht | Rollendatei | Vorrat |
|---|---|---|---|---|
| Chef (Mensch) | entscheidet Grundsätzliches, Geld, Story, Aussehen, Release; testet | – | – | – |
| Sokrates | Stab: Strategie, Markt, Chefrunde, Vorentscheide zu Abläufen | Arbeit verteilen | `ROLLE-BERATUNG.md` | `ARBEIT-BERATUNG.md` |
| Homer | Story, Texte, Stil, Spielgefühl, Ideenliste | Code | `ROLLE-KREATIV.md` | `ARBEIT-KREATIV.md` |
| Perikles | Wochenziel, Vorrang, Klasse M/K, Abläufe, Werkzeuge der Abläufe | Story, Aussehen | `ROLLE-PROJEKT.md` | `ARBEIT-PROJEKT.md` |
| Diogenes | prüft `main` und gebaute Werkzeuge, zählt Kennzahlen | ändert nichts | `ROLLE-PRUEFUNG.md` | `ARBEIT-PRUEFUNG.md` |
| Ford | startet, weckt, archiviert nach `lauf.py`; Besetzung | beurteilen | `ROLLE-BETRIEB.md` | `ARBEIT-BETRIEB.md` |
| Team Tom | Entwicklung: Leute, Dorf, Innenräume, Technik | fremde Vorgänge | `ROLLE-ENTWICKLUNG.md` | `ARBEIT-TEAM-TOM.md` |
| Team Jerry | Entwicklung: Monster, Höhle, Kampf, Klang | fremde Vorgänge | `ROLLE-ENTWICKLUNG.md` | `ARBEIT-TEAM-JERRY.md` |

Spike ist eigene Rolle Technik (1328); Helfer Tuffy (bei Jerry) ist Leihsitzung des Teams, Kosten zählen dort. Die Rolle steht in der ersten Nachricht („Du bist Perikles …“, auch als Systemmeldung von Ford); `notiz.sh` meldet sie, „unbekannt“ heißt: Chef fragen.

**Aufbau jeder Rollendatei** (fest, bis „Start“ unter 4 KB): Kopf · Wer du bist · Gutes Ergebnis · Dein Maß · Dein typischer Fehler · Was du tust · Entscheidet selbst (nur Perikles, Homer, Sokrates) · Was du nicht tust · Wen du ansprichst · Start · Begründungen · Lehren (höchstens fünf).

## 4. Dateien (alle unter `docs/`, Inhaltsverzeichnis `README.md`)

| Datei | Inhalt | Schreibt |
|---|---|---|
| `CLAUDE.md` (Wurzel) | Firmenregeln, liest jede Sitzung zuerst; höchstens 15 KB | Perikles |
| `ROLLE-…` | wer ich bin, Start | Perikles, Rolle selbst |
| `ARBEIT-<Rolle>.md` | **Vorrat**: oben „Übergabe:“ (nur Getanes, Nachfolger), darunter „Zu <Nr.>:“-Absätze mit Wortlaut und Einzelheiten; bis etwa 30 KB | Besitzer, andere als „Zu <Nr>, von X“ |
| `LISTE-VORGAENGE.md` | **die eine Vorgangsliste**: je Vorgang eine Zeile `Nr · Titel · Besitzer · Kl. · Stand · wartet auf · Zweig · Build · Bereich · Kosten`; Reihenfolge je Besitzer = Vorrang | nur über `tools/vorgang.py` |
| `VORGANGSARCHIV.md` | Entschiedenes, eine Zeile je Entscheid, Wortlaut mit Zeit | wer den Entscheid hört |
| `chefsache/entscheiden/`, `billigen/`, `ansehen/`, `tun/` | je Punkt eine Datei, die auf den Chef wartet (`MUSTER.md`); beantwortet heißt gelöscht samt Folgeauftrag | Absender; die Übersicht `README.md` schreibt eine Action |
| `entwurf/t<n>-….md` | Prüfliste eines Builds vor dem Gegenlesen | Team |
| `PROJEKTPLAN.md` | Stufen, oben das Wochenziel | Perikles |
| `ARBEIT-BESETZUNG.md` | wer gerade woran | `lauf.py` |
| `ARBEIT-BETRIEB.md` | Vorgangszähler, Fords Stellung und Kennungen, Guthaben, Eingang, Protokoll | Ford, `vorgang.py` |
| `DESIGN-…`, `STORY-…`, `LISTE-…` | wie das Spiel sein soll, Spieltexte, Handwerk | Fachrolle |
| `LISTE-IDEEN.md` | Ideen ohne Zweig oder Termin; sonntags sichtet Homer | alle |
| `CHANGELOG.md` | Umgesetztes unter „Unveröffentlicht“ | wer es umsetzt |

## 5. Ein Vorgang von Anfang bis Ende

1. **Entsteht:** Chef sagt etwas (Chat, Telegram) oder eine Rolle findet etwas. Wer es hört, legt an: `python3 tools/vorgang.py neu "Von Chef (TT.MM., HH:MM): …" "E Kampf" M Jerry` (Nummer aus dem Zähler), schreibt den Wortlaut als „Zu <Nr>, von …“ in den Vorrat des Besitzers, pusht. „jetzt“ des Chefs kommt in den Titel.
2. **Klasse:** **M** (Muss: im Wochenziel oder „jetzt“), **K** (Kür), **M?** entscheidet Perikles (`vorgang.py klasse`).
3. **Startbar:** `tools/startbar.py` rechnet je Rolle, was nichts aufhält (Feld „wartet auf“: Nummer, Rolle, Datum, Build `t<n>`, Chef; Pause und Halt im Vorratskopf; Sperre bei zu viel Ungetestetem).
4. **Start:** Ford startet die Rolle (Abschnitt 6) mit „Weiter: <Nr>“; die Sitzung liest `CLAUDE.md`, Rolle, Vorrat, `vorgang.py <Nr>`.
5. **Arbeit:** Code auf `claude/<team>-<thema>`, je Vorgang ein Commit; vorher Kerntests (`tools/t`), Probelauf auf dem Bauserver höchstens einmal vor dem Urteil des Chefs (`probelauf.py`).
6. **Stand:** `vorgang.py stand <Nr> "gebaut, Geprüft an: <Commit>"`; Werkzeuge (Bereich B) prüft Diogenes („greift Lauf N“).
7. **Build und Test:** Abschnitt 8.
8. **Schluss:** Test passt → `vorgang.py build <n>` setzt „erledigt“, der PR wird zusammengeführt (Merge, nie Squash), `CHANGELOG.md`; fällt durch → Rückläufer an das Team, der Punkt per `git revert` aus dem Build.
9. **Übergabe:** fertig oder Neustart-Haken zum zweiten Mal → „Übergabe:“ oben im Vorrat mit „Nachfolger: <Rolle> – <Vorgang>“, pushen, Ford startet den Nachfolger.

Wer ein Urteil des Chefs braucht: Datei in `chefsache/<ordner>/<nr>-….md` mit Zeile „Beim Chef, weil:“, an anderem weiterarbeiten; ohne Datei wartet keiner.

## 6. Ford und die Uhr

- **Ford-Sitzung** wird stündlich von einem geplanten Auftrag („Ford-Lauf“) geweckt. Je Lauf: `list_sessions` (alle Seiten) als Kurzzeilen in eine Datei, dann `python3 tools/lauf.py --sperre --besetzung <Datei>`; jede Ausgabezeile ausführen: `START` (`create_session` mit Rolle, Modell, Umgebung, `source_url`, erster Nachricht), `WEITER` (`send_message` an eine laufende Sitzung), `ARCHIVIERE`, `WARNUNG(-LAUT)` (Telegram), `LEERLAUF` (nichts). Danach pushen, eine Telegram-Zeile. Ablauf: `LISTE-BETRIEB.md`.
- **Stellung** oben in `ARBEIT-BETRIEB.md`: aus / Co-Pilot / Pilot.
- **Startsperre:** `startsperre-haken.py` lässt `create_session` nur durch, wenn `lauf.py --sperre` die Zeile „Startsperre HH:MM Start <Name>“ geschrieben hat; so startet keiner an `lauf.py` vorbei und es gibt keine Klone.
- **Tiefe:** jede gestartete Sitzung liegt eins tiefer (Grenze 8). Darum gibt es den **Ford-Starter** (Tiefe 1, startet nur Ford neu) und die **Ford-Wache** (geweckt 07:08 Mo–Fr, 09:08 Sa/So, meldet Stillstand). Ab Tiefe 6 bittet Ford den Chef per Telegram um einen Handstart.
- **Selbstneustart:** über etwa 400 Tsd. Token übergibt jede Sitzung; der Neustart-Haken erinnert.
- **Kosten:** beim Archivieren schreibt `lauf.py --kosten` den API-Preis an den Vorgang; `kostenbericht.py` → `LISTE-KOSTEN.md`.
- Geplante Aufträge, die selbst eine Sitzung erzeugen, können keine Sitzungen starten (Probe 13.11.); darum weckt die Uhr eine bestehende Ford-Sitzung.

## 7. Haken (`.claude/settings.json`) und Werkzeuge

Die Haken machen Regeln durchsetzbar, statt sie nur aufzuschreiben. Jeder Haken tut bei eigenem Fehler still nichts.

| Ereignis | Haken | Tut |
|---|---|---|
| Sitzungsstart | `setup-session.sh --warm` | Godot holen, Import im Hintergrund |
| Sitzungsstart | `neustart-haken.py start` | warnt bei zu großen Vorräten |
| jede Nachricht | `neustart-haken.py prompt` | Uhr-Zeile (Berliner Zeit), Namenskopf, Erinnerung an Neustart nach Größe |
| vor Bash, Actions-Start, Push über MCP | `probelauf.py` | höchstens ein Probelauf je Vorlage vor dem Urteil des Chefs; hält Bauten mit veraltetem Modellbau, rote Zweige, fehlenden Figurenstand an |
| vor `create_session` | `startsperre-haken.py` | Startsperre (Abschnitt 6) |
| Zugende | `weiter-haken.py` | hält einmal auf, wenn Startbares übrig ist |
| Zugende | `zug-haken.py` | zählt Fragen an den Chef |
| `git commit` in der Notizkopie | `commit-pruefung.py` (pre-commit, richtet `notiz.sh` ein) | Uhrzeit nicht in der Zukunft, Listenform, Chefsache gelöscht nur mit Archiveintrag, Form der Prüfliste, Telegram-Urteil nicht doppelt, 👎 nur mit Nachfrage |

Dazu: Ausgabestil „Knapp“ (`.claude/output-styles/knapp.md`), Zeitzone und Autor als `env`, Verbote (`git push --force`, `git rebase`), `autoMode.environment` mit erlaubten Routinen.

**Werkzeuge** (`tools/`, der Kopf jeder Datei ist ihre Anleitung):

| Werkzeug | Wer ruft es | Zweck |
|---|---|---|
| `notiz.sh` | jede Sitzung vor jeder Antwort | `main` holen, Rolle, neue Notizen, Pflegefehler, offene Telegram-Urteile, Uhr |
| `vorgang.py` | alle | Vorgangsliste lesen und schreiben (`neu`, `stand`, `warte`, `klasse`, `rang`, `fertig`, `build`) |
| `startbar.py` | Ford (über `lauf.py`), Perikles | Startbares, `--stand` Zahlen je Rolle |
| `lauf.py` | Ford | Plan je Stunde: Start, Weiter, Archiv, Warnungen, Stillstand |
| `meldung.sh` | alle | Telegram-Meldung, `--bild`, `--film`, `--datei`, `--laut`, `--frage`; protokolliert die Kennung je Vorgang (Zweig `meldungen`) |
| `reaktionen.py` | `notiz.sh`, `lauf.py` | 👍/👎/✅ und Antworten des Chefs holen (Zweig `reaktionen`), offene Urteile zeigen |
| `pruefliste.py` | Bau | Prüfliste → JSON für den Reiter „Test“ |
| `t` | Teams | Kerntests nach Anlass (`tools/t logik`, `tools/t pruef`) |
| `regelcheck.py`, `pflegehinweis.py` | `notiz.sh`, Ford | Größen und Form der Vorräte als Pflegezeile |
| `zug-index.py` | Action `zug-index.yml` | `chefsache/README.md` aus den Dateien |
| `tagesbericht.py`, `kostenbericht.py` | Perikles, Ford | Tageszahlen, Kosten je Bereich |

## 8. Bauen und Testen

1. **Bauserver:** `godot.yml` baut bei Push auf `claude/build-**` (und Team-Zweige `claude/<team>-348-**`) die APK, rechnet Kerntests, Bilder und Filme (`workflow_dispatch` mit Schaltern); `godot-kampf.yml`, `tom-probe.yml` für Probefilme; Kaufmodelle über `KAUF_TOKEN`. Nach jedem Push, der baut, ein Weckruf (`subscribe_pr_activity` oder `send_later`).
2. **Gemeinsamer Build:** ab 4 fertigen Punkten beider Teams (oder wenn ein Punkt 6 Stunden ohne Build und ohne Vorlage liegt, 1312) legt ein Team `claude/build-<n>` von `main` an, mischt alle fertigen Zweige, öffnet einen PR, `vorgang.py build <n> --mit …`. Nummern nur aufsteigend.
3. **Prüfliste** `t<n>-….md`: Entwurf in `docs/entwurf/`, das andere Team liest gegen („Gegengelesen: …“); Tabelle `| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |`, je Prüfgegenstand eine Art: **Handy** (Bedienung, Ablauf), **Bild**/**Film** (Aussehen, Bewegung), **Klang** (Hörprobe auf Telegram, nie in die APK), **Gespräch** (Balance), **ohne dich** (Bautest), **Kleinkram**. Danach `## Lagen` je Handyzeile. Regeln: `LISTE-CHECK-BUILD-TEST.md`.
4. **Reiter „Test“ in der APK** (`godot/skripte/testmodus.gd`, `pruefliste.gd`): der Bau packt nur die Handyzeilen der Prüfliste ins Spiel; Testmodus = 7× auf das Copyright im Hauptmenü. Je Zeile „Lage herstellen“ (Station, Uhr, Probekampf), dann „Passt“ oder „Falsch“ abhaken.
5. **Bild und Film** gehen je Prüfpunkt als eigene Telegram-Nachricht „t<n>.<Punkt>: …, 👍 passt: …, 👎 falsch: …“; der Chef antwortet mit dem Daumen.
6. **Testbitte:** wenn der APK-Link da ist und alle Bilder und Filme gesendet sind, Datei nach `chefsache/ansehen/`, Telegram-Nachricht.
7. **Auswertung:** `vorgang.py build <n>` liest die Ergebnisse der Liste und 👍/👎; durchgefallene Punkte werden Rückläufer, der Rest geht auf `main`.

## 9. Melden und Rückmeldungen

- Jede Sitzung meldet selbst über `meldung.sh <Name> "<Nr>: <Stand>"` (lautlos; `--laut` nur, wenn der Chef dran ist). Telegram ist das Protokoll; im Chat steht nur, was der Chef entscheiden, tun oder prüfen kann.
- 👍 = gebilligt/passt, 👎 = falsch, ✅ = erledigt. Wer ein offenes Urteil in `notiz.sh` sieht, trägt es ins Archiv ein („Nachricht <Kennung>“), löscht die Chefsache-Datei, setzt den Stand. Bei 👎 ohne Wort fragt er im selben Zug nach (`meldung.sh --frage`).
- Jede Nachricht beginnt mit Name und Zeit aus der Uhr-Zeile („**Tom** [10.10., 11:02]“).

## 10. Takt und Kennzahlen

| Wann | Wer | Was |
|---|---|---|
| stündlich | Ford | `lauf.py` |
| 7 Uhr (Sa, So 9) | Ford | Morgenlauf, `regelcheck.py` |
| täglich | Perikles | Tagesbericht (`tagesbericht.py`) |
| montags | Perikles | Wochenziel in `PROJEKTPLAN.md`, Reifes aus `LISTE-IDEEN.md` |
| montags | Diogenes | Wochenzählung: Kennzahlen, Fehler, die der Chef zuerst fand |
| freitags | alle | Rollenspiegel (`rollenspiegel.sh`) |
| sonntags | Homer | Ideenliste sichten, per Telegram |

**Bereiche** (feste Liste, `tools/bereiche.py`): **E** Entwicklung (Welt, Figuren, Kampf, Klang, Oberfläche, Technik) · **G** Gestaltung (Story, Stil, Balance) · **Q** Qualität (QS, QM) · **B** Betrieb (Steuerung, Abläufe, Werkzeuge) · **M** Markt. **Kennzahlen:** Kosten der Woche je Bereich und Anteil Spiel (E+G); Guthaben; Fortschritt Meilenstein; Testrunden und Rückläufer; Fehler, die der Chef zuerst fand.

## 11. Nachbauen in Schritten

1. Repo anlegen, `CLAUDE.md` (Firmenregeln, Rollentabelle, Begriffe) und die Rollendateien nach Abschnitt 3 schreiben; leere Vorräte mit Kopf „Übergabe:“.
2. `docs/LISTE-VORGAENGE.md` mit Kopfzeile und `ARBEIT-BETRIEB.md` mit Vorgangszähler; `tools/vorgang.py` und `tools/startbar.py` übernehmen.
3. `tools/notiz.sh` (zweite Arbeitskopie für `main`, pre-commit `commit-pruefung.py`), `.claude/settings.json` mit den Haken aus Abschnitt 7 und dem Ausgabestil.
4. Telegram-Bot anlegen, Chat-Kennung in `meldung.sh` und `reaktionen.py` eintragen, `TELEGRAM_BOT_TOKEN` in die Cloud-Umgebung; die Zweige `meldungen` und `reaktionen` entstehen von selbst.
5. Cloud-Umgebung in claude.ai/code (Netz, Variable, Setup über den Haken), Modelle je Rolle in `lauf.py`.
6. Bauserver: `godot.yml` (APK, Tests, Bilder, Prüfliste über `pruefliste.py`), `zug-index.yml`; Secrets (Signatur, `KAUF_TOKEN`); Zweit-Repo für Gekauftes.
7. Im Spiel: Testmodus mit Reiter „Test“, der die Prüfliste aus dem Bau zeigt und Lagen herstellt.
8. Ford von Hand starten (Tiefe 0): Uhr „Ford-Lauf“ stündlich auf seine Sitzung, Ford-Starter und Ford-Wache anlegen, Stellung „Pilot“.
9. Erstes Wochenziel durch Perikles; los.

## 12. Wo es hakt (Stand 15.11.)

- **Viel Regelwerk:** jeder Haken entstand aus einem Fehler; neue Regeln brauchen eine Streichung (Regelbilanz), sonst wächst `CLAUDE.md` über 15 KB.
- **Vorräte zu groß:** Tom, Jerry, Beratung liegen um 30 KB; jede Sitzung liest sie beim Start.
- **Warten aufeinander:** Muss, die auf eine Rolle warten, die `lauf.py` nicht startet (Sokrates), lösen erst den Stillstand-Lauf aus (1246).
- **Tiefe der Sitzungen:** Ford braucht etwa täglich einen Handstart oder den Ford-Starter.
- **Telegram ohne Wort:** ein 👎 ohne Begründung wurde still eingetragen (1301; seit 15.11. ist die Nachfrage Pflicht).
