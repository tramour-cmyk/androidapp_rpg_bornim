# 587a · Gegner auf der Gebietskarte auch 1,3-fach (Bosse 1,5-fach), wie im Kampfort?
Team Jerry · 05.11., 12:1x · A Aussehen · berührt 587, 494, 490, 491, 492

Kurz: Auf der Gebietskarte so groß wie im Kampfort (eine Größe je Tier) oder echte Größe?

**Frage:** Sollen die Gegner auf der Gebietskarte genauso groß stehen wie im Kampfort, also 1,3-fach und die Bosse 1,5-fach?

**Votum:** Ja, eine Größe je Tier auf Karte und im Kampfort; Krogg und Grak in der Höhle vorher an Gang und Decke prüfen.

**Berührt:** 587 A (Chef 12:0x; dort stand nach meinem Vorschlag „Gebietskarte echte Größe“), 494, Karten 490, 491, Höhle 492 (Tom).

**Sachverhalt:** Im Code holt sich das Monster auf der Karte seine Größe aus demselben Maß wie im Kampfort (`streuner.gd` 100–128, `kampfort.gd foe_scale`). Darum sind die Wölfe heute schon auf der Karte 1,32-fach. Mein Vorschlag in 587 „Gebietskarte echte Größe“ hätte also eine eigene Größe für die Karte gebraucht.

**Dafür:** Karte und Kampfort gehören zusammen (`DESIGN-STIL.md`): Was man auf der Karte sieht, steht im Kampf genauso da. Die Wölfe sind schon so. Es braucht keinen zweiten Maßstab im Code. Auf dem kleinen Schirm erkennt man größere Gegner auf der Karte leichter.

**Dagegen, stärkstes Argument:** Auf der Karte stehen die Gegner neben Dingen in echter Größe: neben Leuten, Bäumen, Türen, Garricks Feuer und in der Höhle neben Gängen und Decke. Ein Keiler wird so groß wie ein Pony, Krogg 1,5-fach ist etwa 3,2 m hoch und kann in der Höhle an Decke oder Wand stoßen. Die Spinne ist dann gut 2,2 m breit, breiter als eine Kachel des Wegs.

**Folgerungen:**
- **Ja:** Ich lasse beide Größen gleich und prüfe Krogg und Grak in der Höhle mit Toms 492 auf Durchdringung, bevor der Build kommt.
- **Nein:** Ich trenne den Maßstab: Auf der Karte stehen alle in echter Größe, auch die Wölfe, im Kampfort 1,3 und 1,5.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/claude/build-494/godot/skripte/streuner.gd

Antwort: „587a ja“ oder „587a nein“.
