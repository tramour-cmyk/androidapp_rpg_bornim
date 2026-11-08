# 649 · Bestiarium: Steckbrief je Monster, mehr als eine Angriffsart · Sokrates · 08.11., 13:2x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/godot/regeln/tabellen.json

**Anlass (Chef 13:19):** „dass die Tiere jeweils nur eine Angriffsart haben … Wo ist denn geregelt, wie groß und wie klein die sind, wie die ausschauen, was ihre Eigenheiten sind? … das erklärt immer noch nicht, wie die Tiere ausschauen und was sie auszeichnet“.

**Befund**
- Jede Art hat im Spiel genau einen Angriff (`tabellen.json`: `atk`, `dmg`, `type`) und höchstens ein Merkmal (`special`: Umreißen, Ansturm, Gift, Ausweichen, Rudel, Blutsaugen, Säure). Riesenratte, Goblin, Goblin-Späher, Skelett haben gar kein Merkmal. Nur die Bosse (Krogg, Grimmzahn, Grak) haben angekündigte Sonderangriffe (z. B. Graks schwerer Hieb). Herkunft: alte SRD-Fassung (`Monsters.kt`), nie nach BRS überarbeitet.
- Ein Monster steht heute an drei Stellen: **Aussehen** (Größe, Umriss, Merkmal, Farbe, Haltung) in `LISTE-FIGUREN.md`, **Wesen und Herkunft** (Homer, 428) und **Werte** in `LISTE-BESTIARIUM.md` in getrennten Abschnitten, **Spielwerte** in `tabellen.json`. In der Tabelle der Kapitel-1-Arten fehlt sogar der Verweis aufs Aussehen.

**Frage:** (A) Bestiarium als **Steckbrief je Art**: eine Seite je Monster mit Bild, Größe, Aussehen, Wesen, Werten, Angriffen, Beute, Zerlegen; `LISTE-FIGUREN.md` behält nur die Abnahmeliste fürs Modell und verweist. (B) Jede gewöhnliche Art bekommt **zwei bis drei Handlungen** statt einer (z. B. Wolf: Biss, Umreißen, Heulen ruft das Rudel; Spinne: Biss, Netz hält fest; Ratte: Biss, Flucht bei wenig Leben; Skelett: Hieb, Deckung), Bosse dazu ihre Ansage. Vorschlag mit Zahlen von Jerry (Simulation 444), Texte Homer.
**Votum Sokrates: A ja, B ja.**

## Auswertung
- **Stärkstes Gegenargument zu B:** mehr Handlungen machen Kämpfe länger und brauchen je Art neue Bewegungen (Kaufmodelle haben nicht für alles eine), Kampf in Kapitel 1 ist gemessen (427) und müsste neu gemessen werden. **Antwort:** Leitbild „Kampf nie langweilig, echte Wahl“: mit einer Handlung sind gewöhnliche Gegner nach dem ersten Kampf berechenbar, die Wahl des Spielers hängt dann nur an Leben und Schaden. Zweite Handlung nur, wo eine Bewegung da ist; sonst bleibt es bei einer.
- **Gegenargument zu A:** „jeder Text an einem Ort“; ein Steckbrief zieht Aussehen aus `LISTE-FIGUREN.md`. **Antwort:** Es bleibt an einem Ort, nur an dem, wo man es sucht; die Figurenliste verweist.

## Folgerungen
„649 A“: ich baue das Bestiarium als Steckbriefe um (Aussehen aus `LISTE-FIGUREN.md` verschoben, nichts neu erfunden). „649 B“: Vorgang an Jerry (Handlungen je Art vorschlagen, messen), Texte an Homer; danach zu dir.
