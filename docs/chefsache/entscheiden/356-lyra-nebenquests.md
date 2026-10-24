# 356 · Lyras Befreiung als Erlebnis, Nebenquests mit spürbarem Lohn
Homer · 24.10., 21:08 · G Story · K (Chef 24.10. zu Chefsache 26: Lyra „nur ansprechen, die ist ja dann verschwunden“; zwei Nebenquests nicht beendet, „relativ egal“)

**Sag:** „356 a“, „356 b“, „356 beide“ oder „noch nicht“. Kür: gebaut wird erst, wenn kein Muss startbar ist.

## a · Lyra: befreien statt ansprechen

**Befund (Code, `Story.kt`):** Lyra steht in Graks Halle frei auf dem Boden. Nach Graks Tod: ein Gespräch, 2 Weihwasser, dann wird sie ausgeblendet; „Lyra eilt dem Ausgang entgegen“ steht nur als Text. Grak selbst wird nach dem Sieg ebenfalls nur ausgeblendet.

**Empfehlung:** drei Schritte:
1. Lyra ist an einen Pfeiler gekettet. Der Held öffnet die Kette mit einem Schlüssel aus Graks Beute (neu; Kroggs Schlüssel ist der zur Halle). Die Ketten fallen (Geräusch, kurzes Bild). Neu zu zeichnen: Pfeiler mit Kette.
2. Lyra heilt den Helden voll, zusätzlich zum Weihwasser; in der Höhle gibt es sonst keine Rast. Neuer Satz, Entwurf:
   `[356.lyra.segen]` *Lyra legt dir die Hand auf die Stirn. Warmes Licht fließt durch dich.* „Das Morgenlicht vergisst niemanden, der ihm dient.“
   EN: *Lyra lays her hand on your brow. Warm light flows through you.* "The Dawnlight forgets no one who serves it."
3. Sie geht sichtbar zum Ausgang der Halle und verschwindet erst dort. Neu: eine Figur, die zu einem Ziel geht (die Dorfbewohner bummeln nur um ihren Platz).

*Stärkstes Gegenargument:* Du hast das Gespräch „klar“ genannt, nicht schlecht. Jede Stunde dafür fehlt bei Fehlern, und die gehen laut oberster Direktive vor.
*Größere Lösung, nicht empfohlen:* Lyra kommt als Begleiter bis zum Ausgang mit und heilt im Kampf. Verlangt Begleiter im klassischen Kampf; das gehört zu den Gefährten ab Kapitel 2.

## b · Nebenquests: Lohn über dem Verkaufspreis

**Befund (Code, `Jobs.kt`, `Monsters.kt`, `Items.kt`):**

| Auftrag | Verlangt | Chance je Tier | Lohn | Verkaufswert (Charisma normal) | Mehr durch den Auftrag |
|---|---|---|---|---|---|
| Felle für den Winter (Thessa) | 5 Wolfsfelle | Wolf 45 %, Grimmzahn sicher | 60 Gold | 60 Gold | **nichts**; dafür etwa 9 Wölfe und Grimmzahn |
| Hauer für den Schmied (Borin) | 3 Keilerhauer | 50 % | 50 Gold | 30 Gold | 20 Gold |
| Gift gegen Gift (Morwen, nach Krogg) | 3 Giftdrüsen | 60 % | 50 Gold, 2 Kräutertränke | 45 Gold | 5 Gold, 2 Tränke |
| Gwennas Ring | Ring aus einer Kiste der Höhle | – | 40 Gold, Heiltrank | – | lohnt |
| Feuer am Steinkreis (Jorin, nach Krogg) | Fund am Steinkreis | – | Kopfschutz (ungewöhnlich) | – | lohnt |

Beim Aufbruch hingen nur Felle, Hauer und Ring; deine zwei offenen waren also sehr wahrscheinlich Felle und Hauer: genau die Sammelaufträge, die kaum mehr bringen als der Verkauf.

**Empfehlung:** Sammelaufträge zahlen in einem Ding, das es sonst nicht gibt, nicht in mehr Gold:
- Felle: 3 statt 5; Lohn 60 Gold und ein **Pelzumhang** von Thessa (neues Stück, ungewöhnlich, Umhangplatz; Werte wie andere ungewöhnliche Umhänge).
- Hauer: Lohn 50 Gold und ein **Hauerdolch** von Borin (neues Stück, ungewöhnlich, Werte wie ein ungewöhnlicher Dolch).
- Drüsen: bleibt; lohnt durch die Tränke knapp.

*Stärkstes Gegenargument:* Balance ist deine Sache; mehr Lohn macht Kapitel 1 noch leichter (du fandest es ab Stufe 3 zu leicht). Darum Stücke mit üblichen Werten statt mehr Gold oder stärkerer Waffen; sie zählen als Fund, nicht als Kraft.

**Berührt:** 349 (Händler), 38 (Ausgleich); Anschlagbrett aus 29 (erledigt). Bau: a Höhle, also Jerry; b Aufträge und neue Stücke, Zuständigkeit bestimmt Perikles.
