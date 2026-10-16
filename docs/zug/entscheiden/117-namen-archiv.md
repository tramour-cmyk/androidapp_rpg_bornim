# 117 · Namen in docs/ und Archiv

Sokrates Projekt · 16.10., 13:0x · Anlass Chef 13:0x: „wofür brauchen wir das Arbeitarchiv? … Können wir da nicht was einsparen?“

Kurz: `ARBEIT-ARCHIV.md` einfrieren (Verlauf steht in Git), drei Nachschlage-Dateien von ARBEIT- nach LISTE-, STORY-K1-W → STORY-K1-WELT (Empfehlung)

**Frage:** (1) `ARBEIT-ARCHIV.md` einfrieren: nichts mehr eintragen, alte Übergaben einfach überschreiben? (2) Die Umbenennungen unten?

**Empfehlung:** Ja zu beiden, umgesetzt mit dem Rest von 99g und 102 nach Sa 21:00.

**Abgrenzung**
| Datei | Inhalt | Wer schaut nach |
|---|---|---|
| Vorgangsarchiv (99g.1) | was entschieden ist und gilt | alle vor Bau oder Empfehlung, Chef |
| Vorrat `ARBEIT-<Rolle>.md` | was offen ist | die Rolle beim Start, Ford die Kopfzeilen |
| Dein Zug | was der Chef entscheidet oder ansieht | Chef |
| `CHANGELOG.md` | was gebaut ist | Chef, Tester |
| `ARBEIT-ARCHIV.md` | alte Übergaben, alte Protokollzeilen, Volltext alter Dateien (477 KB) | fast niemand, „nur gezielt durchsuchen“ |

**Warum einsparen geht:** Alles im Archiv steht schon in der Git-Geschichte. Jede Arbeitskopie hat die volle Geschichte (3.080 Commits); `git log -S"<Text>"` findet jede alte Übergabe. Das Archiv kostet dagegen jede Sitzung einen Schreibschritt (89 Commits in zwei Tagen), Zusammenstöße oben in der Datei und eine Regel. Wegfall der Regel zählt für 90a.

**Umbenennungen** (Vorsilbe sagt den Zweck, `CLAUDE.md`): `ARBEIT-ABLAEUFE` → `LISTE-ABLAEUFE`, `ARBEIT-UMGEBUNG` → `LISTE-UMGEBUNG` (beides Nachschlagen, kein Vorrat); `STORY-K1-W` → `STORY-K1-WELT`; `LISTE-THEMEN` → `LISTE-VORGAENGE` (113); `DESIGN-ZWISCHENBILD` → `DESIGN-BLENDE` (116). Der Rest passt: ROLLE-, ARBEIT- (Vorräte, Besetzung), DESIGN-, STORY-, LISTE- sind zuordenbar.

**Stärkstes Gegenargument:** In einer Datei sucht man bequemer als in Git, und die Rollendateien verweisen auf ältere Lehren „im Archiv“. Deshalb bleibt die Datei eingefroren stehen statt gelöscht; Neues kommt nur noch in Git.
