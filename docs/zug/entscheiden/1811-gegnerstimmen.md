# 18.11 · Welche Stimmen sollen die übrigen Gegner haben?

Jerry · 16.10., 13:38 · Thema 18 (Klänge aus echten Aufnahmen). Wolf, Goblin und Skelett haben schon Stimmen; die zwölf übrigen Gegner sind im Kampf stumm. Hörproben von allen zwölf gingen per Telegram, je Gegner eine Datei (Großbild: Telegram 16.10., 13:38).

Kurz: Stimmen für 12 Gegner (Angriff, Schmerz, Tod, je drei Fassungen): welche Fassungen kommen ins Spiel? (Empfehlung: alle, die dir nicht missfallen)

**Frage:** Welche Fassungen sollen ins Spiel? Jede Probe spielt Angriff 1–3, Schmerz 1–3, Tod 1–3 mit kurzen Pausen dazwischen (etwa 20 s).

| Gegner | Grundlage (CC0) |
|---|---|
| Krogg | Troll- und Brüllaufnahmen, tief gestimmt; im Tod ein Körperfall |
| Grak | Männerschreie, etwas tiefer, kehlig |
| Keiler | Grunzen (ein Mensch, der ein Schwein nachahmt), tiefes Katzenknurren, Quieken |
| Riesenspinne | Fauchen, Klicken, nasses Zusammensacken |
| Riesenfledermaus | echte Fledermausrufe, eine Oktave tiefer |
| Kobold | Igelruf, kläffend und zischend |
| Riesenratte | Maus und Siebenschläfer, fast eine Oktave tiefer |
| Stirge | Fliegensurren, sehr tief, schrilles Fiepen, Saugen |
| Riesenhundertfüßer | Klicken vieler Glieder, Zischen |
| Zombie | Zombie-Stöhnen (BigSoundBank) |
| Ghul | kehliges Lachen, Fauchen, heiseres Kreischen |
| Ockergallerte | keine Stimme: Schmatzen, Gluckern, Zerfließen |

**Empfehlung:** Alles nehmen, was dir nicht missfällt; nenne die Ausfälle („Keiler Schmerz 3 raus“). Fehlt danach einer Art eine Fassung, suche ich Ersatz. Erst nach deiner Wahl baue ich die Stimmen ins Spiel.

**Stärkstes Gegenargument:** Ich konnte die Proben nicht selbst anhören, nur messen (Länge, Pegel, Tonhöhe). Einzelne Fassungen können künstlich klingen, vor allem wo eine Tieraufnahme stark umgestimmt ist (Fledermaus, Ratte, Stirge) und beim Keiler, dessen Grunzen von einem Menschen stammt.

<details><summary>Abgleich Stil</summary>

- DESIGN-STIL „Klang“: echte Aufnahmen statt Synthese, drei Fassungen mit eigenem Charakter, nicht nur andere Tonhöhe; „Monster düster und gefährlich“: nichts Niedliches (keine „cute“-Laute verwendet).
- Gleicher Pegel wie die übrigen Kampfklänge (−17 dB RMS), leichter Höhlenhall; Angriffe höchstens 1,8 s, Tod bis 3 s mit Körperfall.
- Geprüft: Länge, Spitze, Schwerpunkt der Tonhöhe je Datei; Fledermaus und Ratte waren zu schrill und sind tiefer gestimmt. Werkzeug: `tools/klang/stimmen.py` (Zweig `claude/jerry-18-gegnerstimmen`), Quellen in `tools/klang/QUELLEN.md`.
</details>
