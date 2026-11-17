# 1525 · Sollen Tiere je Merkmal mehrere Namen bekommen, die von Kampf zu Kampf wechseln?
Homer · 17.11., 09:10 · G Story · 1525 (Merkmalsnamen), aus deinem Wort 08:11 (Idee)
Kurz: Drei Namen je Tiermerkmal, im Kampf gleich, von Kampf zu Kampf wechselnd; Wirkung bleibt.
Beim Chef, weil: Story (Spieltext, neue Namen)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/265cf1a21/docs/STORY-MERKMALE-TIERE.md

**Frage:** Am Gegner steht ab Lesestufe 2 hinter der Art ein Name für sein Merkmal, etwa „Wolf, angeschlagen“. Bisher hat jedes Merkmal genau einen Namen (`[1489.name.tier]`: jung, alt, kräftig, angeschlagen). Du hast am 17.11., 08:11 gesagt: „schwächlich klingt gut, aber angeschlagen passt eigentlich auch … 5 Alternativen … also gehen beide“. Die vier Beschreibungen je Art und Merkmal wechseln schon. Sollen auch die Namen wechseln, und wenn ja, mit welchen Wörtern?

**Votum:** „1525 A“: drei Namen je Merkmal (Liste unten), im selben Kampf ein Name je Merkmal, von Kampf zu Kampf gezogen wie die Beschreibungen; Pfeil ▲/▼ und Wirkung bleiben.

**Berührt:** Homer (Namen in `STORY-MERKMALE-TIERE.md`), Jerry (Einbau der Namen, ohnehin offen zu 1488/1489: im Build stehen noch Arbeitsnamen aus `werte.json`); 1533 (Gegner ohne Zahlen, Sokrates) nicht.

**Begründung:** Dein Wort vom 16.11., 18:41: „ich will nicht 50 Mal alter Wolf lesen oder klappriges Skelett“. Die vier Beschreibungen je Art und Merkmal wechseln schon; der Name steht aber bei jedem Exemplar und wiederholt sich am meisten. Drei statt fünf, weil es im Deutschen ungebeugt hinter dem Komma nur wenige Wörter gibt, die bei allen sieben Tieren (auch Spinne, Egel, Hundertfüßer) passen und kein anderes Merkmal meinen.

**Sachverhalt:**
- Namen: `STORY-MERKMALE-TIERE.md` `[1489.name.tier]`; Regel „Name hinter der Art, mit Komma, keine Beugung“; beim Wolf „jung“ = unerfahren (neben dem Jungwolf).
- Anzeige laut Regel: Stufe 1 nur ▲/▼, Stufe 2 Name und Beschreibung, Stufe 3 dazu die Wirkung ohne Zahlen. Build 296 zeigt noch Arbeitsstand (`merkmal_zusatz`: „Wolf · Name“, Stufe 3 mit Prozenten).
- Wirkung: jung weniger Leben, trifft schlechter, wehrt besser ab; alt weniger Leben, trifft schlechter; kräftig mehr Leben, härter; angeschlagen viel weniger Leben (`DESIGN-BRS.md` „Merkmale je Exemplar“).
- Die Beschreibungen zu „angeschlagen“ sind meist Verletzungen (Lauf zieht nach, Blut, Stummel), etwa ein Viertel Erschöpfung (hechelt, taumelt, rollt sich ein).

**Auswertung:**
- **A (Empfehlung):** je Merkmal drei Namen (DE / EN), der erste ist der bisherige:
  - jung: jung, halbwüchsig, unausgewachsen / young, half-grown, immature; **Wolf:** unerfahren, ungeübt, unerprobt / green, untried, unseasoned (beim Wolf keine Altersworte wegen des Jungwolfs)
  - alt: alt, betagt, altersschwach / old, aged, decrepit
  - kräftig: kräftig, stattlich, massig / strong, burly, massive
  - angeschlagen: angeschlagen, verwundet, schwächlich / battered, wounded, feeble (das bisherige EN „wounded“ für angeschlagen wird „battered“, das trifft es besser)
  Im selben Kampf trägt ein Merkmal einen Namen (zwei alte Wölfe heißen beide „alt“, sonst hält man sie für verschieden); nächster Kampf neu gezogen, nie derselbe zweimal hintereinander je Art und Merkmal. Kosten: Homer eine Tabelle; Jerry wenig, Ziehen und Merken wie bei den Beschreibungen.
- **B:** ein Name je Merkmal wie bisher; Abwechslung nur über die Beschreibungen. Kosten keine.
- **C:** A, aber „schwächlich“ weglassen (dafür „lädiert / bruised“).
- **Stärkstes Gegenargument gegen A:** Auf Stufe 2 sind Name und Beschreibung die einzige Auskunft; wer „schwächlich“ oder „altersschwach“ liest, kann alt und angeschlagen verwechseln, und drei Wörter je Merkmal muss man erst lernen. „Schwächlich“ heißt eigentlich „von Natur schwach“, die Beschreibungen zeigen meist Wunden (einige Erschöpfung, dazu passt es). Darum C als Ausweg; die Wirkung auf Stufe 3 und der gleiche Name im Kampf mildern es.

**Stellungnahme Sokrates (17.11., 09:18):** Bei Spieltexten bleibt Homers Empfehlung maßgeblich; ich prüfe nur die Regel dahinter. Sie passt zu 1533 (Gegner ohne Zahlen): wenn das Lesen später mit der Kenntnis je Art wächst, braucht Stufe 2 Wörter, die man auseinanderhält. Darum wiegt Homers eigenes Gegenargument schwerer als die Abwechslung: „altersschwach“ (alt) und „schwächlich“ (angeschlagen) sagen beide „schwach“; auf Stufe 2 ohne Wirkung ist das eine echte Verwechslung. Empfehlung: **C** (A ohne „schwächlich“, dafür „lädiert“); dein „angeschlagen passt eigentlich auch“ ist damit erfüllt.

**Folgerungen:** Nach A oder C: Homer trägt die Namen als `[1489.name.tier.<merkmal>.<1–3>]` ein (fremd geprüft), Vorgang an Jerry zum Einbau mit 1488s Texten. Nach B: 1525 erledigt. Untote, Goblins, Kobold (`STORY-MERKMALE-WAFFEN.md`) bleiben bei einem Namen, bis du es dort auch willst.

Antwort: …
