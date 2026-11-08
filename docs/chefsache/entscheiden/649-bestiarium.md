# 649 · Figurenkatalog: alle Figuren an einer Stelle (Monster, Bewohner, Gefährten) · Sokrates · 08.11., 13:3x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/godot/regeln/tabellen.json

**Anlass (Chef 13:19, 13:24):** „dass die Tiere jeweils nur eine Angriffsart haben … wie groß … wie die ausschauen, was ihre Eigenheiten sind?“; „das Bestiarium ja auch sinnvoll zu gliedern … was uns da fehlt … Wo stehen denn dann die NPCs? … nicht 50 Dateien … alles was nicht Gegenstand ist … übersichtlich strukturiert nach Möglichkeit an einer Stelle“.

## Befund
- **Monster** stehen an drei Stellen: Aussehen in `LISTE-FIGUREN.md`, Wesen und Werte in `LISTE-BESTIARIUM.md` (getrennte Abschnitte), Spielwerte in `godot/regeln/tabellen.json`. In der Tabelle der Kapitel-1-Arten fehlt der Verweis aufs Aussehen.
- **Bewohner und Gefährten** (Morwen, Garrick, Jorin, Thessa, Pim …) haben keine eigene Stelle: Aussehen in `LISTE-FIGUREN.md`, Wesen und Rolle verstreut über `STORY-K1-WELT.md`, `STORY-K1-HANDLUNG.md`, `STORY-PLAN-K1.md`, `STORY-LEHRMEISTER-K1.md`, `STORY-RUF-K1.md`, Werte der Gefährten in `DESIGN-HELDENBAU.md`. Morwen kommt in 34 Dateien vor.
- **Angriffe:** jede Monsterart hat genau einen Angriff und höchstens ein Merkmal (Umreißen, Ansturm, Gift …); Ratte, Goblin, Skelett gar keins. Nur die drei Bosse haben angekündigte Sonderangriffe. Herkunft alte SRD-Fassung, nie nach BRS überarbeitet.

## Frage
**(A) Figurenkatalog** nach dem Muster des Gegenstandskatalogs (644): eine Datendatei `tools/figuren/figuren.json`, daraus erzeugt eine Seite `LISTE-FIGUREN.md` zum Lesen; `LISTE-BESTIARIUM.md` geht darin auf. Je Figur ein Steckbrief:

| Teil | Inhalt | für wen |
|---|---|---|
| Kopf | Kennung, Name (de, en), Art (Monster, Boss, Bewohner, Händler, Lehrmeister, Gefährte, Söldner, Tier), Bild | alle |
| Wo und wann | Ort, Kapitel, Tageszeit, Tagesablauf (wann im Haus) | Tom |
| Aussehen | Größe, Umriss, Merkmal, Farbe, Haltung (die Abnahmeliste, wie heute) | Modell, Prüfer |
| Wesen | Herkunft und Eigenart (Homer, nur als Marke `[428.ratte]`, Text bleibt in der STORY-Datei) | Homer |
| Rolle im Spiel | Laden, Quest, Lehrer, Gefährte ab wann, Ruf | Tom, Homer |
| Kampf | Werte BRS, Handlungen, Merkmal, Schwächen | Jerry |
| Beute, Zerlegen | nur Kennungen aus dem Gegenstandskatalog | Jerry |
| Modell, Klang | Quelle und Lizenz, Stimme | Tom, Jerry |

Das Werkzeug prüft: jede Figur im Spiel steht im Katalog, jede hat Bild, Aussehen, Ort; jede Beute-Kennung steht im Gegenstandskatalog. Godot liest Monsterwerte aus dem Katalog statt aus `tabellen.json` (Ablösung wie bei 644).

**(B) Mehr als eine Handlung:** jede gewöhnliche Art bekommt zwei bis drei Handlungen statt einer (z. B. Wolf: Biss, Umreißen, Heulen ruft das Rudel; Spinne: Biss, Netz hält fest; Ratte: Biss, Flucht bei wenig Leben; Skelett: Hieb, Deckung), Bosse dazu ihre Ansage. Vorschlag mit Zahlen von Jerry (Simulation 444), Texte Homer.

**Votum Sokrates: A ja, B ja.**

## Auswertung
- **Stärkstes Gegenargument zu A:** Spieltexte gehören zu Homer in die STORY-Dateien; ein Katalog, der sie aufnimmt, macht eine zweite Textstelle. **Antwort:** der Katalog nimmt keine Spieltexte auf, nur Marken mit Link; Texte bleiben, wo sie sind. Er sammelt, was heute niemand findet: wer wo wann ist, wie er aussieht, was er kann.
- Gegenargument zu A: Umbau über beide Teams (Tom: Leute, Jerry: Monster). **Antwort:** deshalb deine Entscheidung; Werkzeug baut eine Seite (Jerry, wie 644), Tom und Jerry füllen je ihren Teil, nichts neu erfunden, nur zusammengetragen; Fehlendes wird sichtbar und geht als Vorgang an Homer.
- **Stärkstes Gegenargument zu B:** Kämpfe werden länger, Kapitel 1 ist gemessen (427) und müsste neu gemessen werden, und den Kaufmodellen fehlt nicht für jede Handlung eine Bewegung. **Antwort:** Leitbild „Kampf nie langweilig, echte Wahl“: mit einer Handlung ist ein gewöhnlicher Gegner nach dem ersten Kampf berechenbar. Zweite Handlung nur, wo eine Bewegung da ist.

## Folgerungen
„649 A“: Werkzeug und Datendatei (Jerry, nach 644), Monster füllt Jerry, Bewohner und Gefährten Tom, Lücken an Homer; `LISTE-BESTIARIUM.md` und der Aussehensteil von `LISTE-FIGUREN.md` gehen im Katalog auf. „649 B“: Vorgang an Jerry (Handlungen je Art vorschlagen, messen), Texte Homer, danach zu dir.
