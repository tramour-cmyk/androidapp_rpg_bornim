# 259 · Kämpfe gegen deutlich schwächere Gegner zügig hinter sich bringen
Sokrates · 20.10., 18:12 · G Kampf · K (Chef 20.10., 17:56, an Jerry: „… wenn der Unterschied deutlich ist, also man selber ist, keine Ahnung, Stufe 8 und der Gegner wäre Stufe 3 oder so, dass dann automatisch schon geht, dass man die Kämpfe nicht unbedingt kämpfen muss, wenn man nicht will, sondern die relativ zügig hinter sich bringt mit der Automatik. Mal irgendjemanden vorlegen zum Entscheiden.“; Wortlaut ganz in `ARBEIT-BERATUNG.md` Zu 259)

## Befund (Code `Skirmish.kt`, `Story.kt`, `Monsters.kt` auf `main`)

- Die Automatik gibt es nur in MARS. Sie ist gesperrt gegen Bosse, unter einem Drittel der LP und bei einer starken Absicht (`autopilotBlocked`). Gerade die starke Absicht sperrt sie auch gegen schwache Gegner (Wolf „Anspringen“).
- Kapitel 1 deckelt die Stufe bei 6; die Gegner haben Herausforderungsgrad 1/8 bis 2. Wer grindet (darf er, 59e.3), steht also bald Stufe 5–6 gegen Wölfe (1/4) und Goblins: genau der Fall des Chefs.
- Erfahrung aus solchen Kämpfen ist klein (ein Wolf 50 EP, Stufe 6 → 7 braucht 9.000). Schneller Kampf verschiebt die Balance kaum.

## Vorschlag

**Ein Kampf gilt als „leicht“, wenn die Stufe des Helden mindestens 4 über dem höchsten Herausforderungsgrad der Gegner liegt** (Stufe 8 gegen 3 ja; Stufe 3 gegen Wolf 1/4 knapp ja; nie gegen Bosse). Dann:

1. **Automatik nie gesperrt** außer unter einem Drittel der LP; die starke Absicht sperrt nicht mehr.
2. **Knopf „Schnell“** neben der Automatik: derselbe Kampf läuft ohne Bilder in einem Rutsch durch (dieselben Würfe, dieselbe Automatik, keine neue Regel), danach eine Tafel: Sieg, verlorene LP, Beute, EP. Fällt die LP dabei unter ein Drittel, hält er an und der Spieler übernimmt.

Nicht: Kampf ganz überspringen oder „Sofortsieg“ ohne Würfe; das wäre eine neue Regel und kostet Gold und Tränke unsichtbar.

## Empfehlung

**Ja zu 1 und 2, gilt nur für MARS** (der klassische Kampf hat keine Automatik; ob er sie bekommt, ist eine eigene Frage zu 212). Kür bei Jerry, nach 249.

*Stärkstes Gegenargument:* „Kampf nie langweilig, echte Wahl“ (Leitbild): Wer schnell klickt, trifft keine Wahl; und ein schneller Weg macht Grinden bequemer. Dagegen: Ein Kampf Stufe 6 gegen Wölfe hat keine echte Wahl mehr, ihn auszuspielen ist genau das Langweilige; der Ertrag bleibt klein, und die Stufe ist gedeckelt. *Zweiter Einwand:* Die Grenze „4 Stufen“ ist geschätzt, nicht gemessen; Jerry prüft sie mit der Kampfsimulation (Sieg fast immer, Verlust unter einem Viertel der LP) und meldet, wenn sie nicht trägt.

**Widerspruch zu Entschiedenem:** 72p.1 (starke Absicht sperrt die Automatik) wird für leichte Kämpfe aufgehoben; Bosse und das Drittel bleiben. Kosten: klein bis mittel, ein Jerry-Build.

## Antwort

„259 ja“, „259 nur 1“ oder „nein“.

**Berührt:** 72p.1, 241.1, 59e.3, 212, 249.
