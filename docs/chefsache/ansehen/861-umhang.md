# 861 · Umhangbuckel im Kampf: Ursache gefunden, Behebung gebaut · Tom · 11.11., 23:48

[Film von 12.11., 03:19](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261112-031947-861/2026-11/12-0319-861-Tom.mp4) (eingetragen von meldung.sh, Tom)

[Film von 11.11., 23:30](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/11-2330-861-Tom.mp4) (Tom), Stand vorher: Kämpfer von hinten, hinten links, rechts, hinten rechts.

**Berichtigung zum Befund von 23:35:** Er war falsch. Die Messung in Lauf 361 hielt Arme und Hände des Körpers für Umhang: Die gekauften Körper und die Augen haben einen eigenen zweiten Satz Bildkoordinaten, und das Messwerkzeug las ihn als Umhangmarke. „Umhang hängt an den Fingern“ betraf also die Hände selbst. Der Magier, der Kleriker und der Schurke tragen in ihrem Modell gar keinen Umhang. Im Spiel wirkt diese Marke nicht (der Wert, der sie nutzt, steht auf null).

**Befund (gemessen am Rechner, mit denselben Kaufmodellen wie Lauf 361):**
- Die Behebung 656 ist in den Modellen enthalten (gleiche Prüfsumme des Bauskripts).
- 656 hat die Armgewichte des Umhangs aufs Schlüsselbein gelegt, aber auch bei Umhangecken 35 bis 40 cm unter der Schulter, an der Seite bis zur Hüfte. Hebt oder dreht der Kämpfer die Schulter (Schild, Hieb, Abwehr), schwenkt die Umhangseite dort mit, bis 54 cm vom Körper. Das ist der Buckel an der Seite.
- Behebung (gebaut, Zweig `claude/tom-861-umhang`): Unterhalb der Schulter hängen diese Ecken jetzt am Rücken, nur das oberste Stück (10 cm) am Schlüsselbein. Probe am Kaufmodell: größter Abstand in der Abwehr 54 → 15 cm, im Hieb 47 → 17 cm; Ecken über 6 cm vom Körper 144 → 32 in der Kampfhaltung, 224 → 87 im Hieb.
- Gilt für jeden Umhang aus diesem Bauskript: Kämpfer (Mann, Frau), Aldric, Garrick, Gwenna, Morwen, Thessa. Söldner Bertram ist damit noch nicht nachgestellt.

**Nachher (Film von 12.11., 03:19, Lauf 367):** Kämpfer mit der Behebung, von hinten, links, rechts und hinten rechts, in Kampfhaltung und mit Hieben. Gemessen größter Abstand des Umhangs vom Körper: Abwehr 21 cm (vorher 54), Kampfhaltung 8 cm, Gehen 15 cm, Rennen 30 cm (flattert hinten in Hüfthöhe). Magier, Kleriker und Schurke haben im Modell keinen Umhang; Söldner Bertram ist im Film nicht dabei.

**Was du sagen sollst:** „passt“ (dann fährt 861 im nächsten Sammelbuild) oder wo du noch einen Buckel siehst (Blickrichtung, Bewegung).

Geprüft an: Lauf 367, https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43126745027 (Film); Lauf 361, https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43101958763 (Kaufstand); Messung am Rechner auf Commit 69f81d519.
