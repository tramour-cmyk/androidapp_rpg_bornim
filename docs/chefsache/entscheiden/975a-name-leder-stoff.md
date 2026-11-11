# 975a · Wie heißt das Handwerk für Leder und Stoff, seit die Roben dazugehören?
Homer · 11.11., 16:49 · E Welt · aus deinem Wort 16:31 („können wir das dann vielleicht Handarbeit nennen? … Was wäre denn ein guter Oberbegriff?“)
Kurz: Lederarbeit wird Schneidern (Meisterschaft und Titel Schneider); Oberbegriff aller sechs bleibt Handwerk; Schmuck steht im Ideenspeicher.

Geprüft an: [main f564e94e1](https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/f564e94e1): `DESIGN-BRS.md` 2 (Fertigkeiten), 6 (Meisterschaften), 145 (Namen 466), 10 (Herstellen); `STORY-HANDBUCH-1.md` `[423.fert.liste]`, `STORY-HANDBUCH-2.md` `[423.meister]`, `STORY-HANDBUCH-3.md` `[423.namen]`; `STORY-RUF-K1.md` (Garrick); Code `tools/sim444/werte.json` 323, 374, `tools/sim444/sim.py` 1189, `godot/skripte/erschaffung_brs.gd` 70 (main `f564e94e1`); Gegenlesung durch einen Helfer 16:47

**Frage:** Seit 16:31 stellt das Handwerk, das heute „Lederarbeit“ heißt, auch Roben und Stoffkleidung her (Stoff vom Händler). Der Name passt nicht mehr: Stoff ist kein Leder. Du hast „Handarbeit“ vorgeschlagen und nach einem Oberbegriff gefragt. Ich lese das auf zwei Arten und beantworte beide: (1) ein Name, der Leder und Stoff zusammenfasst; (2) der Oberbegriff aller sechs Handwerke (Schmieden, Lederarbeit, Alchemie, Kochen, Runenkunde, Heilkunde), heute „Handwerk“. Der Name unter (1) gilt dreifach: für die Fertigkeit (Wert 0 bis 100), für die Meisterschaft und für den Titel (heute „Lederer“, hoch „Hoher Lederer“).

**Votum:** „975a A“: Fertigkeit Schneidern, Meisterschaft und Titel Schneider (englisch Tailoring, Tailor, High Tailor); Oberbegriff bleibt Handwerk.

**Berührt:** 976 Tom (Rezeptbuch, Reiter je Handwerk); 870 Umzug (vier Codestellen); Texte von Homer: `[423.fert.liste]`, `[423.meister]`, `[423.namen]`, `[423.reparatur]`, `STORY-RUF-K1.md` (Überschrift Garrick, `[447.4.garrick.leder.frage]`), `STORY-LEHRMEISTER-K1.md`, `STORY-BRS-ERSCHAFFUNG.md`; Lehrmeister bleibt Garrick.

**Begründung:** Dein Wort 16:31: „Was wäre denn ein guter Oberbegriff? Kunst, Handkunst, Kunsthandwerk …“. Schneidern deckt Leder und Stoff (zuschneiden, nähen) und steht heute schon als Teil der Lederarbeit im Regelwerk („Lederarbeit (Gerben, Schneidern, Reparieren)“). Die übrigen Meisterschaften heißen nach der Person (Schmied, Alchemist, Runenmeister, Feldkoch); „Schneider“ passt in die Reihe, „Lederarbeit“ fällt heraus.

**Sachverhalt:**
- Fertigkeit heute „Lederarbeit“ (englisch Leatherwork), Gruppe Handwerk; Teile: Gerben, Schneidern, Reparieren (`DESIGN-BRS.md` 2, `[423.fert.liste]`).
- Meisterschaft „Lederarbeit“, Zulieferfertigkeit Jagd; Titel „Lederer“ (englisch Leatherworker) nach deiner Entscheidung 466 A (02.11., 22:03, `DESIGN-BRS.md` 145, dort auch: „Lederarbeit“ bleibt Name der Meisterschaft). Seit 16:31 stellt sie auch Roben und Stoffkleidung her und repariert Leder und Stoff (`DESIGN-BRS.md` 6).
- Lehrmeister ist der Jäger Garrick; sein Lehrtext sagt schon „Schneid mit dem Strich … Und näh doppelt, wo es scheuert“ (`[447.4.garrick.leder.hinweis]`).
- Im Code steht der Name an vier Stellen (`werte.json` 323, 374; `sim.py` 1189; `erschaffung_brs.gd` 70; in den Umzugszweigen verschoben); den Titel gibt es im Code noch nicht. Im Spiel sichtbar ist er bisher nur in der Erschaffung.
- Für Ringe und Amulette nennt keine der fünf Meisterschaften ein Erzeugnis (`DESIGN-BRS.md` 6).

**Auswertung:**
- **A (Empfehlung): Schneidern / Schneider** (englisch Tailoring / Tailor). Deckt Leder und Stoff, passt in die Reihe der Personennamen. Teile neu: Gerben, Nähen, Reparieren. Kosten: nur Text, vier Stellen Code beim Umzug.
- **B: Handarbeit** (englisch etwa Handiwork). Dein Wort, umfasst alles von Hand Genähte. Aber: neben dem Oberbegriff „Handwerk“ im selben Menü kaum zu unterscheiden; klingt nach Nadelarbeit, nicht nach Rüstung; es gibt keinen Titel („Handarbeiter“ ist ein Arbeiter) und kein gutes Englisch.
- **C: Lederarbeit bleibt**, Roben gehören einfach dazu. Kostet nichts, Garrick und die Kette Jagd → Leder bleiben stimmig, aber Stoff ist kein Leder; dein Einwand bleibt.
- Getrennte Namen nach dem Vorbild Runenkunde / Runenmeister / Runenwirker (etwa Fertigkeit Lederarbeit, Titel Schneider) habe ich geprüft: dann trägt der Spieler zwei Namen für ein Handwerk im Kopf, ohne dass einer Leder und Stoff deckt; darum nicht als eigener Weg.
- **Oberbegriff:** „Handwerk“ bleibt. „Kunsthandwerk“ meint Zierstücke und passt nicht zu Kochen und Alchemie; „Handkunst“ ist kein geläufiges Wort; „Kunst“ allein klingt nach Magie.
- **Schmuck:** dein Hinweis „Ringe schmieden und Amulette. Das haben wir ja auch nicht“ steht als Lücke in `LISTE-IDEEN.md` (Balance und Attribute; Vorschlag dort: Fassung vom Schmied, Rune vom Runenmeister, keine sechste Meisterschaft; nach Kapitel 1).
- **Stärkstes Gegenargument gegen A:** Im Genre ist „Tailoring“ nur Stoff und „Leatherworking“ ein eigener Beruf; englische Spieler lesen „Tailor“ also nicht als Lederrüstung und Köcher. Im Deutschen meint „Schneider“ zuerst Stoff und hat Nebentöne („tapferes Schneiderlein“), die zum düsteren Ton schlecht passen; dazu ist Gerben kein Schneidern. Dagegen: bei uns gibt es nur ein Handwerk für beides, und die Liste der Erzeugnisse steht im Spiel daneben; Gerben bleibt Teil wie Reparieren beim Schmieden; Garrick näht sein Leder selbst. Wiegt das Gegenargument für dich schwerer, ist C der ehrlichere Weg als B.

**Folgerungen:** Bei A oder B ändert Homer die Namen in `DESIGN-BRS.md`, den Handbuchtexten, den Lehrmeistertexten und der Erschaffung (Teile bei A: Gerben, Nähen, Reparieren) und schreibt Tom (976, 870) die vier Codestellen; bei C nur ein Satz „auch Roben und Stoffkleidung“ in `[423.meister]`. Schmuck bleibt in jedem Fall im Ideenspeicher.

Antwort: …
