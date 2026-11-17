# Tom und Jerry · Build 298 · Sammelbuild: Neues Spiel nur BRS, Wiesen, Dorftiere, Mana nach dem Sieg, Bodenschatten, Höhlenwasser, Stäbe, Siegtafel, Wolfssprung · [PR 219](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/219)
E Kampf · Jerry (Handy 1591, 1478, 1566, 760; ohne dich 1541, 1319; gebilligt 1568, 1587), Tom (Handy 1205, 1167), Spike (Handy 1567) · 17.11., 23:45 · [APK (Lauf 559, rot)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/44184072098/artifacts/14374753540)

**Rot im Lauf 559:** `rand_1022` (Kartenrand je Gebietskarte, ohne Bild); am Rechner auf demselben Stand grün, Ursache bei Tom (1606). Start- und Absturztest grün.

Gegengelesen: Sokrates, 17.11., 22:40 (21:16 Magier aus 298.1; 760 nach 1589.1 A wieder dabei, `DESIGN-GEGNER.md` 11: „760 … in den nächsten Build“)

Verglichen (alt gegen neu): Stäbe gegen `core/art/Dress.kt` 728–783, 1455–1460 (Schaft, Knoten, Klauen, Kristall, Messingring); Bodenschatten gegen `core/art` (weicher Fleck ohne Fläche); Höhlenwasser gegen `MapCave` POOL_S/POOL_D; Wiesen und Dorftiere ohne Vorbild (Kotlin malte Blumen als Tupfen, Tiere als Bilder ohne Atem); Funde behoben. Umbau überall: der Bodenschatten ist einer für alle Figuren im Kampfort; das Wasser nur in der Höhle neu, im Wald unverändert; die Blumen des Kits in Dorf und Wald.

Sammelbuild aus `main` (nach t297) und den Zweigen `claude/jerry-1478-mana`, `-1319-geheilt`, `-760-sprung`, `-1568-schatten`, `-1587-stab`, `-1541-brechen`, `-1566-hoehlenwasser`, `claude/tom-1167-tieratem`, `claude/tom-1205-wiese`, `claude/spike-1567-sieg-leben`. Nicht dabei: 1068 (Ring bei großen Schlägen, noch nicht gebaut), 385.2 (Feuer aus der Stabspitze, Film beim Chef), 1569 (Umhang, Bild 2 beim Chef). Schon gebilligt auf Telegram, im Build ohne Prüfpunkt (Chef 21:36/21:37, Sokrates 21:43): 1568 Bodenschatten, 1587 Stäbe. Toms 1417, 1515, 1535, 1549 sind seit t297 auf `main` (Bild 297.11 bei Tom).

Ein Weg: über Build 297 installieren. 298.1 bis 298.4 in einem neuen Spiel (Zauberlehrling) vom Dorf bis zum ersten Wolfskampf, danach 298.5 (Höhle), 298.6 im Probekampf Ratten, 298.7 im Probekampf Wölfe.

Im Bau geprüft: Mana nach dem Sieg + Wille / 2, aufgerundet, höchstens voll; Wundsegen gestreut 0,8–1,2 (1478, `mana_1478`); Netz der Riesenspinne bricht durch Feuer (1541, `kerbe_930` Regel 19); Siegtafel nach „Schnell“ (1567, `schnell_78510`); Blut höchstens 0,05 Körperhöhen vom Treffpunkt der Zähne, Sprung landet an der Körperkante (760, `sprung_760`); Logiksatz 193 gut.

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 298.1 | Jerry | 1591 | Handy | Hauptmenü → Neues Spiel: Erschaffung mit Herkunft Zauberlehrling, dann durchs Dorf in den Wald bis zum ersten Wolfskampf und weiter zur Höhle; überall Texte, Werte und Menüs ansehen | nur BRS-Begriffe: Herkunft, Fertigkeiten, Leben, Mana, Schutzwert; nichts Altes zu sehen | irgendwo steht ein Klassenname (Kämpfer, Schurke, Kleriker), RK, ZP, Rettungswurf oder W20; Magier als Pfad und Magierstab sind richtig |
| 298.2 | Tom | 1205 | Handy | im Dorf aus 298.1 über die Wiesen gehen, dann im Wald über eine Blumenwiese | Gras in mehreren Büschelarten, Blumen des Kits (Margerite, Tulpe, Lavendel …) je Stück verschieden groß, im Dorf etwas kleiner als draußen; keine runden Farbkleckse mehr; das Bild läuft auf den Wiesen flüssig, ohne Ruckeln | Kleckse statt Blumen, alle Blumen gleich groß, oder das Bild ruckelt auf den Wiesen |
| 298.3 | Tom | 1167 | Handy | im Dorf nah an Rind und Ziege stehen bleiben und ein paar Sekunden zusehen | der Rücken hebt und senkt sich langsam, jedes Tier im eigenen Takt; Kopf und Beine bleiben ruhig | die Tiere stehen starr, oder Kopf und Beine zucken mit |
| 298.4 | Jerry | 1478 | Handy | im ersten Wolfskampf aus 298.1 einen Zauber wirken (Mana sinkt im Kasten des Helden), beim letzten Wolf den Wert merken; nach dem Sieg Menü → Held | Mana ist nach dem Sieg um die Hälfte des Willens höher (aufgerundet, beim Zauberlehrling 3), höchstens bis voll | Mana gleich wie am Ende des Kampfes, oder über dem Höchstwert |
| 298.5 | Jerry | 1566 | Handy | Zeile 298.5 → „Lage herstellen“ (Höhle, Westflügel unten am Leuchtpilz, die hohe Wand zum Teich steht zwischen dir und dem Teich); drei Schritte nach rechts, dann an den Teich | hinter der Wand schimmert kein Wasser durch; am Teich ist das Wasser dunkel und nur im Licht der Pilze zu sehen | das Wasser leuchtet hinter der Wand oder im Dunkeln hell, ohne Licht in der Nähe |
| 298.6 | Spike | 1567 | Handy | Zeile 298.6 → „Lage herstellen“ (Probekampf Ratten); erst „Kämpfen“, einen Treffer nehmen, dann „Schnell ›“ unten links | Siegtafel „<Held> −n Leben“, n ist der ganze Verlust seit Kampfbeginn (Leiste vorher gegen nachher); wer nichts verlor, steht nicht da | „−0 Leben“, oder n kleiner als der Verlust |
| 298.7 | Jerry | 760 | Handy | Zeile 298.7 → „Lage herstellen“ (Probekampf Wölfe, ein Wolf springt dich sicher an); auf „Anspringen!“ warten | der Wolf duckt sich, springt, landet am Helden und beißt; das Blut spritzt an der Stelle, wo die Zähne den Helden treffen; dann geht er auf seinen Platz zurück | der Wolf beißt im Stand, landet zu kurz, oder das Blut beginnt neben dem Helden oder in seiner Mitte |
| 298.8 | Jerry | 1541 | ohne dich (Test, die Riesenspinne hat noch kein Modell) | `kerbe_930` Regel 19: Feuer auf die Riesenspinne mit angesagtem Netz lässt es ins Leere gehen, die Seide verbrennt | Test grün | Test rot |
| 298.9 | Jerry | 1319 | ohne dich (Text von Homer) | Kampfmeldung beim Heilen „… fühlt sich wieder gesund.“ wie draußen; der Rausch bleibt | – | – |

## Lagen

- 298.5: station=Krogg ort=cave:2:11:RIGHT ruhig
- 298.6: probe=RATS
- 298.7: probe=WOLVES zug=pounce
