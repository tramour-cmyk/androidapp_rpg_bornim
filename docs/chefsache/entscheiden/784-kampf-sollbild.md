# 784 · Soll dieses Sollbild „Wolfsrudel, eine Runde“ das Maß für jeden Kampffund sein?
Tuffy · 11.11., 10:38 · E Kampf · aus 654 A (Chef 09.11., 17:46: Kampf-Sollbild zuerst, danach Oberfläche und Klang)
Kurz: Eine Runde gegen das Rudel dauert heute etwa 30 s, der Held wartet davon 26 s; das Sollbild schafft sie in 14,6 s, ohne die Ansage zu kürzen.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42986312526 (Prüflauf 342; [Film](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/11-1040-784-Tuffy.mp4), Telegram 11.11., 10:40; Messung `tests/sollbild_784.gd`)

**Frage:** Soll diese Runde das Maß sein, an dem jeder Kampffund gemessen wird: im Film von dir und als Test bei jedem Lauf?

**Votum:** „784 A“, „784 B“ oder eine Zahl ändern („Wolf 3 s“).

**Berührt:** 654, 562, 662, 536, 751 A (Ansage nicht kürzen), 717 C und 717.1 A (F7, F8), 703 A (F5), 702 C, 863, 864, 785, 786

**Begründung:** Funde zum Kampf kamen immer wieder (562, 662, 536, 863, 864), obwohl die Messung am Rechner keine Fehler zeigte. Ein festes Bild einer Runde mit Höchstdauern macht jeden Fund messbar: ist er über dem Maß, ist er ein Fehler.

**Sachverhalt:** Probe Wolfsrudel: Ansgar (Kämpfer) vorn, Bertram (Kleriker, Söldner) hinten; Wolf 1 und Wolf 2 vorn, Wolf 3 hinten; Tempo „Normal“. Ist aus dem Film abgelesen (auf etwa eine halbe Sekunde genau). In dieser Runde griff ein Wolf von vorn an (Wolf 2) und zwei aus der hinteren Reihe (Wolf 1, Wolf 3), weil nach jedem Platztausch ein anderer hinten steht.

| # | Wer | Was und wohin (Soll) | Soll höchstens | Ist |
|---|---|---|---|---|
| 1 | Held | Wahl: Knöpfe sofort da, die Absicht jedes Wolfs steht über ihm | – | – |
| 2 | Held | rennt zum Ziel, schlägt, die Zeile kommt beim Aufschlag, geht rückwärts heim | 2,4 s | 4 s |
| 3 | Söldner | Schritt zur Seite, Zauber, Zeile beim Aufschlag, zurück | 2,0 s | 2 s |
| 4 | Wolf vorn | „Anspringen!“ steht, während er sich duckt (keine eigene Pause); Sprung bis zum Biss höchstens 0,6 s; der Held hebt den Schild vorher oder weicht aus (höchstens 0,5 s, bleibt dort stehen); Zeile beim Aufschlag; der Wolf setzt ein, zwei Schritte rückwärts ab, Gesicht zum Helden (höchstens 0,8 s); dabei schon die Ansage seines nächsten Zugs, zwei Zeilen zu je 1,1 s, ungekürzt | 3,4 s | 5,5 s |
| 5 | Wolf hinten | tauscht mit einem vorderen auf dem kürzesten Weg: springt durch die Lücke nach vorn, der vordere weicht nach dem Biss rückwärts auf den hinteren Platz (höchstens 1 s, darf in die nächste Handlung hineinlaufen); kein Bogen um die Gruppe | 3,4 s | 8,5 und 9 s |
| 6 | alle | wer ausgewichen ist, bleibt stehen und rückt erst im eigenen Zug zurecht | – | ja |
| | | **Runde von Wahl zu Wahl** (Held, Söldner, drei Wölfe) | **14,6 s** | **29–30 s** |
| | | davon wartet der Held ohne Knöpfe | 12,2 s | 26 s |

<details><summary>Was der Film zeigt</summary>

- Vor der Runde, bis zur ersten Wahl, vergehen 26 s: die drei Ansagen, dann greifen Wolf 1 und Wolf 3 zuerst an, Ansgar fällt und steht auf.
- Wolf 1 und Wolf 3 greifen aus der hinteren Reihe an: Wolf 1 läuft etwa 2 s im Bogen von hinten links um alle herum nach vorn, Wolf 2 trottet unterdessen nach hinten, danach laufen beide wieder auf ihre Plätze. Das ist derselbe Fehler wie bei den Ratten (863).
- Je Wolf stehen vier Zeilen zu je 1,1 s nacheinander: „Anspringen!“, der Biss, die Ansage, die Beschreibung, wie er sich duckt.
- Die Uhr oben links liegt über der Zugleiste (mein Fehler im Film, nicht im Spiel).
- Am Rechner ohne die gekauften Modelle sind es 17 s je Runde; der Unterschied kommt von den echten Laufwegen.
</details>

**Auswertung:**
- **A (Empfehlung):** Die Tabelle gilt als Maß. Die Höchstdauern kommen in `DESIGN-KAMPF.md` (neue Zeile F9), der Test misst jeden Lauf dagegen, zuerst nur messend; einen Build hält er erst an, wenn die drei Vorgänge unten fertig sind. Die Zahlen gelten bei Tempo „Normal“; „Ruhig“ (600) macht alles gleichmäßig langsamer. Gegenargument: Die Zahlen sind von uns, zu knapp wirkt der Kampf hektisch. Antwort: Die Ansage bleibt ungekürzt (751 A), es fallen nur Leerlauf und Umwege weg; eine Zahl, die dir zu knapp ist, änderst du mit einem Wort.
- **C:** wie A, mit einer anderen Zahl, die du nennst.
- **B:** Kein Zahlenmaß; du beurteilst jeden Kampf im Film nach Gefühl. Gegenargument: Genau so kamen dieselben Funde immer wieder.

**Folgerungen:** Bei A trage ich F9 ein und lege für Team Jerry drei Vorgänge an: Platztausch auf dem kürzesten Weg (mit 863), „Anspringen!“ während der Bewegung, Angriff des Helden in 2,4 s. Danach hält ein Verstoß gegen das Maß den Build an. 785 (Oberfläche) und 786 (Klang) sind dann frei. Bei B lege ich nur den Vorgang zum Platztausch an.

**Stellungnahme Sokrates (11.11., 11:08):** A, mit drei Ergänzungen. **Widerspruch:** In Zeile 5 weicht der vordere Wolf im Zug des hinteren auf dessen Platz zurück. Nach deinem 717 C (F7: „zurück in die Reihe nur mit eigenem Zug“) und 717.1 A (F8: Zurechtrücken beginnt im eigenen Zug) darf er das nicht. Bei A gilt deshalb der Platztausch als Teil des Angriffs dessen, der springt, und F7/F8 bekommen diese eine Ausnahme. Sonst bleibt nur der Bogen, den du abgelehnt hast. **Zu prüfen:** In Zeile 2 geht der Held „rückwärts heim“. Dein Wort zu 717 war „nicht ständig dieses Rückwärtsgelaufe“, F7 regelt aber nur die Gegner. Sag bei A in einem Wort „rückwärts“ oder „umdrehen“. **Lücke:** Anspringen nach 702 C (Held fällt, steht auf, handelt) kommt im Film vor, hat aber keine Höchstdauer. Tuffy trägt dafür eine Zeile nach. **Stärkstes Gegenargument:** Die Zahlen stammen aus einem einzigen Film mit einer einzigen Aufstellung, und Jerry baut dann auf den Test hin statt auf das Gefühl: grün, aber hektisch. Dagegen spricht: Der Test misst Spielzeit bei fester Bildrate (Bilder/30), schwankt also nicht. Er misst zuerst nur, und den ersten grünen Lauf siehst du als Film, bevor er einen Build anhält. **Kosten:** Die Messung liegt als Test vor. F9 kommt erst bei A. Die SOLL-Werte im Test (`sollbild_784.gd`: Held 2,6, Söldner 2,6, Wolf 3,2, Runde 12,0 s) weichen von der Tabelle ab und werden bei A auf die Tabelle gesetzt. Der Platztausch gehört in den bestehenden Vorgang 863 (gebaut, wartet auf den Build, kommt nach B1; je Thema ein Vorgang, 412), also bleiben zwei neue Vorgänge bei Jerry. Gemessen wird erst mit 863 im Build (864 ist schon in B1), sonst baut Jerry Gelöstes doppelt. **Empfehlung in einem Satz:** „784 A“; der Platztausch zählt als Zug des Springers, 863 nimmt ihn auf, und der Build hält erst an, wenn du den ersten grünen Film gesehen hast.

Antwort: …
