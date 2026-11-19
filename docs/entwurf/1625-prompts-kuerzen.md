# 1625 · Prompts kürzen, Rollen schärfen (Entwurf Sokrates, 19.11.)

Auftrag Chef 19.11., 07:18: recherchieren, wie man vernünftige Prompts schreibt; Rollen kurz und scharf; Verfahren bei einer eigenen Rolle; Rollenprofile je Arbeit (3D-Modell, Leveldesign, Film).

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
