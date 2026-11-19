# 1625 · Rollen, Prompts, Aufträge (Sammelakte Sokrates; mit 1725)

Ein Ort für alles zu 1625 (Startprompts, Kern, Kürzen, Aufträge) und 1725 (Ablauf als Flussdiagramm), Chef 19.11., 08:14: „Legen MD an, pack da alles rein, was wir bis jetzt dazu bequatscht haben, und halt dafür den Vorrat kürzer.“ Entschiedenes steht zusätzlich kurz im Vorgangsarchiv.

## Stand und Termine

- **Läuft heute:** Probe „Auftrag statt Startlektüre“ mit 1694 (Spike) nach Build 300 auf `main`, dann 1535 (Tom); Aufträge in `entwurf/auftraege-19-11.md`. Maß: Läufe bis Abnahme, Länge des Starts.
- **Sa 21.11., ab 20:00 (nach Rücksetzen des Guthabens):** Flussdiagramm (1725), Entwurf `CLAUDE.md` etwa 5 KB, Kern je Rolle, Baukasten.
- **25.11.:** Auswertung Probe Kern über `lauf.py`; Prüfung `.claude/rules/` und Skills (Chef 18.11., 22:59).

## Verlauf (Chefworte)

- **18.11., 08:17/08:22 (Idee):** feste Startprompts je Rolle statt Startlektüre; je Rolle mehrere Fassungen mit Schwerpunkt („Sokrates als Turbo-Spieledesigner“); Probe zuerst Sokrates.
- **18.11., 09:48:** „dass wir immer einen Kern haben, der gleich ist und dann eine spezielle Anpassung“ (Chefrunde, Spieledesigner, Markt und Strategie, Nachtvertretung).
- **18.11., 12:57 (1625 A):** „es muss einfach klar sein, was Ford macht. Aber wenn das klar ist, dann wähle ich A und es geht ab jetzt los damit.“
- **18.11., 16:54:** „Ja, Kern über lauf.py, genauso.“ (1683 Spike).
- **18.11., 20:22:** „halte deine Idee mal fest hier, dass [Ford] auch einen Kern kriegt … für die anderen Rollen ja auch machen, irgendwann.“ Schwerpunkte B–D von Sokrates (`ROLLE-BERATUNG-START.md`) nie gestartet.
- **18.11., 22:39 (Idee):** Memory-Doku von Claude Code „interessant. Hilft uns das …?“ Votum: Auto-Memory nein (im Container, für alle Rollen gleich); `.claude/rules/` mit `paths` und Skills ja zu prüfen. 22:59: „Rules-Prüfung 25.11. ja“.
- **19.11., 07:10:** „Müssen wir … so einen riesigen Prompt schreiben? … da ist doch dein Prompt deutlich zu groß … wenn man da spezifischer ist.“ Zu den Bildläufen: „dass die Hand halt nun mal um den Gegenstand muss, von der Innenseite … diese Erkenntnis, die muss doch schon vorher eigentlich da sein, du bist eine KI.“ „dass du auch mal recherchierst, ordentlich, wie man einen vernünftigen Prompt schreibt.“
- **19.11., 07:18:** „Ja, gerne das 50. Mal die Prompts kürzen … Vielleicht brauchen wir auch mehr Rollen … einen, der sich nur darum kümmert, dass … richtig einsortiert wird … die sagen einfach, ich bin fertig, hier hast du … Rollen … kurz machen und schärfen … jetzt habe ich 3D-Modellarbeit. Da brauche ich andere Prompts, als wenn ich das Level-Design mache … Ein Film erstellen.“
- **19.11., 07:24 (1725):** „so eine Art Flussdiagramm, einen Workflow … wer was machen muss … Regelwächter … die anderen arbeiten tatsächlich am Spiel … wenn Ideen da sind … wäre das dein Job abzugleichen … du musst auch ganz viel … was in deinen Regeldateien steht, gar nicht wissen, um mich beraten zu können.“
- **19.11., 07:27:** „wie oft haben wir jetzt schon deine Rolle versucht zu schärfen … wir beide inhaltlich nicht wirklich weiter … das 10. Mal jetzt versuchen, den Betrieb so aufzustellen, dass jeder effektiv und effizient … Ergebnisse halt nicht 5, 6, 7, 8 Mal nachkontrolliert werden müssen.“
- **19.11., 07:31:** gegen „kürzen mit harter Grenze“ als nächsten Schnellschuss: „bevor wir über radikal kürzen, muss einfach klar sein, wie er was macht, und das Essentielle für seine Tätigkeit muss da drin stehen … dann haben wir wieder ständig irgendeinen Haken, der rummosert.“ Stattdessen: Ford gibt beim Start „genau den Prompt so mit … das und das ist zu erledigen … Beachte dabei 1, 2, 3, 4, setze es so und so um und prüfe 1, 2, 3. Dazu muss ich doch nicht wissen, wie viele andere Aufgaben in meinem Vorrat stehen.“
- **19.11., 07:34:** „das darf keine Einzellösung sein … das Ergebnis muss so sein grundsätzlich, dass das Ergebnis übertragbar wird … Haltepunkte … mit zwei Händen … wir berechnen für alle Heldenarten … alle Klamotten vor … wäre auch eine Möglichkeit.“
- **19.11., 07:35:** „wer soll diese Prompts schreiben? … ein Modell, das ausreichend hoch eingestuft ist … eine Art Baukasten … vielleicht … eine komplett neue Rolle … die Struktur dieser Prompts … wiederholt sich ja.“
- **19.11., 08:01:** „bitte den Vorgang 1694 mit Versuch dieses Prompts zu lösen … ob das besser ist. Ohne 50.000 andere Rollendateien“; „das Ergebnis einsortieren und abgleichen … ob das nicht auch ein Ford-Job ist … Pericles und du, ihr könnt euch doch die Aufgabe der Prompterstellung … teilen … funktional uns anlassbezogen zusammenschließen.“
- **19.11., 08:13:** „lies dich auch mal ein, wie im Internet erfolgreich Prompts geschrieben werden … andere schlaue Leute … Lessons learned … Best Practice“; `CLAUDE.md` „knallhart kürzen …, weil die immer automatisch geladen wird.“

- **19.11., 08:17:** „ob wir feste Themenbereiche zuweisen oder … 6 oder 7 Personen in der Firma … die kriegen halt jeweils den Prompt genau so hin vorgelegt, dass sie spezifische Aufgaben erfüllen können … nicht mehr festklammern an … das ist jetzt der Bereich von A … Was spricht denn da dafür oder dagegen?“ Votum im Chat 08:18: Pool mit Auftrag, Verantwortung je Vorgang statt je Bereich, Sperre je Dateibereich.
- **19.11., 08:18:** „ich habe sie gesagt, ich kann sie ja auch ändern … Frisch denken … Egal, ob es Weisungen gibt.“ (Leitlinie im Archiv)
- **19.11., 08:19:** „Und dann wäre es auch kein Problem mehr, wie wir Sammelbuilds erstellen … es gibt spezifisch die Aufgabe und die macht halt dann einer. Aber dann packen da nicht wieder 50 Sachen rein und kommen sich in die Quere.“ Folgerung: Build ist ein Auftrag an einen; Inhalt beim Start festgelegt (Liste fertiger Zweige), danach zu.

## Entschieden (Archiv)

- 1625 A Startprompt Sokrates (18.11., 12:57); Kern über `lauf.py` (18.11., 16:54); Rules-Prüfung 25.11. (18.11., 22:59).
- Recherche und Entwurf (19.11., 07:18); Flussdiagramm Sa (07:24); Auftragsprobe mit Pflichtpunkt Systemfrage (07:31/07:34); 1694 als Auftrag nach `main`, Einsortieren und Abgleich bei Ford, Aufträge schreiben Sokrates und Perikles je nach Anlass (08:01).

## Offen (für Samstag)

- Wer schreibt Aufträge (Votum: Perikles als Arbeitsvorbereitung, Sokrates bei Chefthemen); Baukasten: feste Gliederung (Ziel, Systemfrage, Stand, Beachte, Umsetzen, Prüfe vor dem Senden, Zurück) und Bausteine je Fach (erstes: `LISTE-HANDWERK-FIGUR-PRUEFBILD.md`).
- Rolle für Verfahren: Ford (Votum) statt neuer Rolle.
- Kein Haken als Längengrenze ohne Klarheit, was in jeden Kern gehört (Chef 07:31).

## Quellen (gelesen 18./19.11.)

- Claude Code, „Best practices“ (code.claude.com/docs/en/best-practices)
- Claude Code, „How Claude remembers your project“ (code.claude.com/docs/en/memory)

## Was die Quellen sagen

1. **Kurz:** „every line in it takes a little of Claude's attention on every task, whether it's relevant or not.“ Ziel unter 200 Zeilen; lange Dateien „reduce adherence“.
2. **Nur, was Claude nicht selbst sieht:** Prüfbefehle, irreführende Stellen, Entscheide, die nicht im Repo stehen, „anything you've had to correct twice already“.
3. **Ausnahmslose Regeln gehören in Haken, nicht in Text:** „If you keep adding emphasis to a CLAUDE.md line and Claude still misses it, that's a sign the line belongs in a hook.“ Aber wenige Haken: bei vierzig sind die meisten Vorlieben.
4. **Fachwissen und Abläufe als Skill:** sichtbar ist nur Name und Beschreibung, der Inhalt lädt erst, wenn die Aufgabe ihn braucht.
5. **Regeln je Ort:** `.claude/rules/` mit `paths` lädt nur beim Anfassen passender Dateien.
6. **Eine Prüfung geben, Beleg verlangen:** „ask Claude for evidence: the command it ran and its output, or the screenshot“; Prüfung durch einen, der den Code nicht schrieb.
7. **Spezialisten:** Unteragenten mit eigenem Prompt, Werkzeugen und Modell in `.claude/agents/*.md`.

## Andere Quellen (19.11., 08:14, Chef: „was ist denn hier mit anderen schlauen Leuten“)

Meist Erfahrungsberichte, Zahlen teils ungeprüft; der Kern ist überall gleich.

1. **Context Rot** (Chroma, 2025, 18 Modelle, auch Claude): Treffsicherheit sinkt mit der Länge der Eingabe, schon bei einfachen Aufgaben; unpassende Inhalte („Ablenker“) verschärfen es. research.trychroma.com/context-rot
2. **„Agent instruction bloat“** steht als Warnung im Thoughtworks Technology Radar. thoughtworks.com/de/radar/techniques/agent-instruction-bloat
3. **Grenze der Anweisungen:** Praktiker nennen etwa 150 Anweisungen, die ein Modell verlässlich befolgt (Quelle nicht belegt); Mitte langer Dateien wird eher übersehen (Positionseffekt). humanlayer.dev/blog/writing-a-good-claude-md, tianpan.co (14.02.2026)
4. **Widersprüche:** Bei zwei sich widersprechenden Regeln wählt das Modell beliebig (auch Anthropic).
5. **Schlanke Unteragenten:** Anthropics Rechercheverbund arbeitet mit einem Leiter, der knappe Aufträge an Unteragenten mit je eigenem schmalem Kontext gibt; „alles vorladen“ hat in Produktion nicht getragen. dev.to (Manus), zenml.io
6. **Feste Schritte in Code:** Ablauf in Knoten teilen, das Modell nur für Verstehen und Erzeugen, alles regelhaft Entscheidbare in Code und Regeln. besthub.dev
7. **Dateien als Gedächtnis:** Wissen in Dateien ablegen und gezielt nachladen statt im Prompt mitschleppen (Manus).

**Folgerung für uns:** Unsere 75 KB Ablauf sind für eine Figurenaufgabe genau die „Ablenker“ aus (1); unsere vielen Regeln mit Ausnahmen und Ersetzungen sind (4); Ford mit Werkzeugen ist (6); der Auftrag statt Startlektüre ist (5).

## Befund bei uns

- Start Tom etwa 75 KB: `CLAUDE.md` 15, Rollendatei 13, Vorrat 30, Checkliste Build 18. Fast alles Ablauf; Handwerk (Griff, Kleidung, Prüfbild) fehlt.
- Folge: Fehler, die jeder Zeichner kennt (Hand umschließt mit der Innenfläche), werden in Läufen gesucht statt vorher gewusst; die Messung prüft, was leicht zu messen ist, nicht was man sieht (1711).

## Vorschlag

1. **Kern je Rolle höchstens 3 KB:** wer, Ziel, fünf Regeln, wo nachsehen. `CLAUDE.md` auf Firma, Begriffe, Sicherheit (Ziel 5 KB).
2. **Rolle „Büro“ (Verfahren):** Entwickler und Kreative melden nur „fertig, hier“; Büro trägt ein, nummeriert, meldet, schiebt in den Build. Prüfen: neu oder Ford/Perikles zusammenlegen (Grenze Guthaben: eine Sitzung mehr kostet).
3. **Profile je Arbeit als Skill:** „Figur und 3D-Modell“, „Prüfbild und Film“, „Leveldesign“, „Kampf“; je Profil Handwerk, Prüfung, Abnahmebild. Erstes Blatt jetzt: Figur und Prüfbild (aus den Funden 1535, 1694, 1655, 760).
4. **Abläufe in Werkzeuge:** was ein Haken prüft, verschwindet aus dem Text (Regelbilanz).
5. **Messung am Sichtbaren** (1711) als Teil des Profils Prüfbild.

## Stärkstes Gegenargument

Umbau aller Startregeln kostet Guthaben (19.11.: 91 %, Rücksetzen Sa 19:59) und bricht eingespielte Abläufe. Entkräftet: bis Samstag nur Blatt „Figur und Prüfbild“ und Kern Sokrates als Probe; Umbau ab Samstagabend Rolle für Rolle, je Rolle eine Woche Probe mit Zählung (Fehler, die der Chef zuerst findet; Läufe je Abnahme).
