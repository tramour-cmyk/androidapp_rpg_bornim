# Tom und Jerry · Build 298 · Sammelbuild: Neues Spiel nur BRS, Mana nach dem Sieg, Stäbe, Bodenschatten, Höhlenwasser, Wolfssprung
E Kampf · Jerry (Handy 1591, 1478, 1568, 1566, 760, 1587; ohne dich 1541, 1319) · 17.11., 21:10 · APK folgt nach dem Gegenlesen

Verglichen (alt gegen neu): Stäbe gegen `core/art/Dress.kt` 728–783, 1455–1460 (Schaft, Knoten, Klauen, Kristall, Messingring); Bodenschatten gegen `core/art` (weicher Fleck ohne Fläche); Höhlenwasser gegen `MapCave` POOL_S/POOL_D; Blut beim Biss gegen `BattleBlood.kt` 67–101 (Tropfen, Flug, Flecken je Stufe); Funde behoben. Umbau überall: der Bodenschatten ist einer für alle Figuren im Kampfort; das Wasser nur in der Höhle neu, im Wald unverändert.

Sammelbuild aus `main` (nach t297) und Jerrys Zweigen `claude/jerry-1478-mana`, `-1319-geheilt`, `-1568-schatten`, `-1587-stab`, `-1541-brechen`, `-760-sprung`, `-1566-hoehlenwasser`. Nicht dabei: 385.2 (Feuer aus der Stabspitze, Film beim Chef). Toms 1417, 1515, 1535, 1549 sind seit t297 auf `main` (Bild 297.11 bei Tom).

Ein Weg: über Build 297 installieren. 298.1 bis 298.3 in einem neuen Spiel (Zauberlehrling), danach 298.4 (Höhle), 298.5 bis 298.7 im Probekampf Wölfe.

Im Bau geprüft: Mana nach dem Sieg + Wille / 2, aufgerundet, höchstens voll; Wundsegen gestreut 0,8–1,2 (1478, `mana_1478`); Netz der Riesenspinne bricht durch Feuer (1541, `kerbe_930` Regel 19); Blut höchstens 0,05 Körperhöhen vom Treffpunkt der Zähne, Sprung landet an der Körperkante (760, `sprung_760`); Logiksatz 193 gut.

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 298.1 | Jerry | 1591 | Handy | Hauptmenü → Neues Spiel: Erschaffung mit Herkunft Zauberlehrling, dann durchs Dorf in den Wald bis zum ersten Wolfskampf und weiter zur Höhle; überall Texte, Werte und Menüs lesen | nur BRS-Begriffe: Herkunft, Fertigkeiten, Leben, Mana, Schutzwert; nichts Altes zu sehen | irgendwo steht ein Klassenname (Kämpfer, Kleriker, Magier …), RK, ZP, Rettungswurf oder W20 |
| 298.2 | Jerry | 1478 | Handy | im ersten Wolfskampf aus 298.1 einen Zauber wirken (Mana sinkt im Kasten des Helden), beim letzten Wolf den Wert merken; nach dem Sieg Menü → Held | Mana ist nach dem Sieg um die Hälfte des Willens höher (aufgerundet, beim Zauberlehrling 3), höchstens bis voll | Mana gleich wie am Ende des Kampfes, oder über dem Höchstwert |
| 298.3 | Jerry | 1568 | Handy | im selben Wolfskampf auf den Boden unter Wölfen und Held sehen | unter jeder Figur ein weicher, runder dunkler Fleck, der Boden daneben unverändert | ein rechteckiger dunkler Fleck unter den Figuren oder der ganze Kampfort abgedunkelt |
| 298.4 | Jerry | 1566 | Handy | Zeile 298.4 → „Lage herstellen“ (Höhle, Westflügel unten am Leuchtpilz, die hohe Wand zum Teich steht zwischen dir und dem Teich); drei Schritte nach rechts, dann an den Teich | hinter der Wand schimmert kein Wasser durch; am Teich ist das Wasser dunkel und nur im Licht der Pilze zu sehen | das Wasser leuchtet hinter der Wand oder im Dunkeln hell, ohne Licht in der Nähe |
| 298.5 | Jerry | 760 | Handy | Zeile 298.5 → „Lage herstellen“ (Probekampf Wölfe, ein Wolf springt dich sicher an); auf „Anspringen!“ warten | der Wolf duckt sich, springt, landet am Helden und beißt; das Blut spritzt an der Stelle, wo die Zähne den Helden treffen; dann geht er auf seinen Platz zurück | der Wolf beißt im Stand, landet zu kurz, oder das Blut beginnt neben dem Helden oder in seiner Mitte |
| 298.6 | Jerry | 1587 | Handy | Zeile 298.6 → „Lage herstellen“ (Probekampf Wölfe, Testheld Zauberlehrling mit Magierstab); den Helden ansehen und einen Zauber wirken | der Held hält einen knorrigen Stab mit beiden Händen, oben ein Kristall in drei Klauen, der blau glimmt; der Zauber geht von der Spitze aus | kein Stab zu sehen, der Stab steckt im Körper, oder der Zauber kommt aus der Hand oder der Mitte |
| 298.7 | Jerry | 1587 | Handy | Zeile 298.7 → „Lage herstellen“ (wie 298.6, mit Zauberstab); den Helden ansehen und einen Zauber wirken | in der Haupthand ein kurzer Stab mit Messingring und Kugel, die Kugel glimmt blau; der Zauber geht von der Kugel aus | kein Stab zu sehen, oder der Zauber kommt aus der Hand |
| 298.8 | Jerry | 1541 | ohne dich (Test, die Riesenspinne hat noch kein Modell) | `kerbe_930` Regel 19: Feuer auf die Riesenspinne mit angesagtem Netz lässt es ins Leere gehen, die Seide verbrennt | Test grün | Test rot |
| 298.9 | Jerry | 1319 | ohne dich (Text von Homer) | Kampfmeldung beim Heilen „… fühlt sich wieder gesund.“ wie draußen; der Rausch bleibt | – | – |

## Lagen

- 298.4: station=Krogg ort=cave:2:11:RIGHT ruhig
- 298.5: probe=WOLVES zug=pounce
- 298.6: probe=WOLVES herkunft=Zauberlehrling waffe=staff
- 298.7: probe=WOLVES herkunft=Zauberlehrling waffe=wand
