# 120 · Musik in Schichten: dunkle Spur, wenn ein Jäger näher kommt?

Jerry · 16.10., 14:1x · Idee 10: nähert sich ein Jäger, schleicht sich eine dunkle Spur in die Musik, bevor der Kampf beginnt; Stille bewusst einsetzen. Fünf Hörproben per Telegram (16.10., 14:2x), alle mit Waldmusik und Kampfmusik aus dem Spiel, Pegel wie im Spiel:

| Probe | Was man hört |
|---|---|
| 0 heute | Waldmusik, der Kampf setzt hart ein |
| 1 Spur Cello (56 s) | Jäger kommt näher: tiefes Cello schwillt an, Waldmusik wird leiser und dumpfer; er dreht ab: Spur weicht, Wald kommt zurück; er kommt wieder und bemerkt dich: alles verstummt, gut 1 s Stille, dann Kampf |
| 2 Spur gedehnt | wie 1, kurz, Spur aus gedehnten Celli (gleichmäßiger, flächiger) |
| 3 Spur tief | wie 1, kurz, Spur aus tiefen Streichern (dunkler, mehr Bass) |
| 4 nur Stille | keine Spur: die Waldmusik verklingt beim Näherkommen, Stille, dann Kampf |

Kurz: dunkle Spur plus Stille vor dem Kampf, drei Fassungen der Spur im Wechsel (Empfehlung: Form wie Probe 1)

**Frage:** Kommt die Musik in Schichten so ins Spiel? Welche Spur-Fassungen (1, 2, 3) bleiben, oder lieber nur Stille (4)?

**Empfehlung:** Form wie Probe 1, alle drei Spuren im Wechsel (drei Fassungen, DESIGN-STIL). Im Spiel: die Spur wächst, je näher ein jagendes Monster ist, das dich noch nicht bemerkt hat (ab etwa 8 Feldern); bemerkt es dich, verstummt alles bis zum Kampf (heute etwa 1,5 s, so lange läuft es 4 Felder); dreht es ab, weicht die Spur über einige Sekunden. Gilt draußen und in der Höhle (dort über dem Klangbett); im Dorf gibt es keine Jäger.

**Stärkstes Gegenargument:** Die Spur verrät einen Gegner, den man noch nicht sieht, und im Wald streifen oft Jäger in der Nähe: dann liegt sie fast immer unter der Musik und nutzt sich ab. Gegenmittel: erst ab 8 Feldern, nur für das nächste Monster, und nur für Jäger (Herumstreuner und Lauerer nicht). Dass man eine Gefahr hört, bevor man sie sieht, passt zum Leitbild (Dunkel, Schleichen, Lauschen). Ich konnte die Proben nicht hören, nur messen (Pegel je Sekunde, Spitzen).

<details><summary>Stil-Abgleich (DESIGN-STIL „Klang“, „Musik“)</summary>

- Musik orchestral und düster: Spur aus echten Streicheraufnahmen (CC0, Freesound 465558, 195850, 507741), keine Synthese; drei Fassungen mit eigenem Charakter.
- Übergänge: Ortsmusik ↔ Spur weich (Sekunden, nie im Takt), Spur → Stille in 0,4 s, Stille → Kampf wie heute (0,3 s); nach dem Kampf wie heute Siegesstück, dann Ortsmusik. Dreht der Jäger ab: Spur weicht, Ortsmusik kehrt zurück.
- Pegel: Spur so laut wie die Waldmusik im Spiel (−31 dB RMS), bis 2,5 kHz gefiltert, damit sie unter der Musik liegt und nicht schrillt.
- Prüfung im Spiel: Kerntest im `MusicDirectorTest` (Spur wächst mit der Nähe, Stille ab „bemerkt“, kein Wechsel im Dorf), Hörprobe durch den Chef. Werkzeug: `tools/klang/schichten.py` (PR #87, nur Werkzeug).
</details>
