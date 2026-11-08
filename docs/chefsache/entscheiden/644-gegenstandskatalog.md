# 644 · Gegenstandskatalog: alle Gegenstände und Rezepte an einer Stelle · Sokrates · 08.11., 14:3x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/tools/gegenstaende.py

**Frage:**
- **A** Aufbau wie unten: Gegenstandskatalog mit Rezepten, Regelwerte nur Formeln, Beute im Figurenkatalog (649), **samt Ablösung** der Wege, aus denen das Spiel heute liest?
- **B** Seltenheit als eigene Achse ins BRS (heute nur Stufe, Güte, Zustand; Seltenheit stammt aus der SRD-Fassung; dein Wort 12:30 „Seltenheit, Farben, Zusatzwerte auf BRS“)?
- **C** Zwei Balancefragen, Vorschläge unten: Preis eines Fertigkeitsbonus, Seltenheitsdecke je Kapitel.

**Votum Sokrates: A ja, B ja, C wie vorgeschlagen.** Neu gefasst nach zwei Gegenprüfungen (12:55, 25 Punkte; 12:58, 11 Punkte; Wortlaut in Git, Commit `05a0d67ac`) und nach 649 (Figurenkatalog).
**Berührt:** 458, 478, 469, 481, 447, 649, Laden, Beute, Simulation 444, Regelwerk.

## Wo was steht (jede Angabe an genau einer Stelle)

| Stelle | Was dort steht | Was dort nicht steht |
|---|---|---|
| **Gegenstandskatalog** (`tools/gegenstaende/gegenstaende.json`, heute 458), Teil **Gegenstände** | jede **Grundform** mit allen Werten je Stück | Formeln, Figuren |
| ebenda, Teil **Rezepte** | je Rezept ein Datensatz (Regelwerk Abschnitt Handwerk): Zutaten mit Menge, Ergebnis mit Menge, Fertigkeit und Rang, Werkort, Güte und Gegenstandsstufe des Ergebnisses nach Rang und Material, welche Fertigkeit es übt, wer es gegen Gebühr herstellt (Handwerker, z. B. Morwen) und wie viel, wo man das Rezept bekommt (Lehrmeister, Buch, Belohnung, Händler); die drei Zustände der Rezeptliste (herstellbar, eine Zutat fehlt, gesperrt) leitet das Spiel aus Rang, Freischaltung und Tasche ab, nie gepflegt | Werte der Zutaten und Ergebnisse (stehen beim Gegenstand) |
| **Regelwerte** (`tools/sim444/werte.json`) | Formeln und Werte je **Gruppe**: Waffenart, Rüstungsart, Faktor je Güte, Zustand, Stufe, Seltenheit, Verkaufsanteil, Preisformel, Ausbeute beim Zerlegen, Seltenheitsdecke je Kapitel (heute fest in `beute.gd:12`), erlaubte Zusatzeigenschaften je Platz, Deckel der Zusatzeigenschaften, Mindeststufe je Seltenheit | Werte je Stück (heute: 17 Preise, Heilung der Tränke, Kampftränke mit Preisen, Beute, Zerlegeteile unter deutschen Namen statt Kennungen, Startausrüstung, Braukosten) |
| **Figurenkatalog** (649, Bestiarium geht darin auf) | je Art, was sie fallen lässt (Chance, Menge) und was Zerlegen bringt, nur als Kennung aus dem Gegenstandskatalog | Preis, Wirkung, Name des Dings |

**Wie man Rezepte findet** (Chef 14:24: „Ist ein Rezept ein Gegenstand? … Wie finde ich denn dann Rezepte?“): ein Rezept ist kein Gegenstand, es hat andere Spalten (Zutaten, Werkort, Rang). Darum steht es nicht als „Art: Rezept“ in der Gegenstandstabelle (dort blieben die meisten Spalten leer), sondern als eigenes Kapitel **Rezepte** auf derselben Seite, geordnet nach Fertigkeit (Schmieden, Lederarbeit, Alchemie, Kochen …), darin nach Rang. Am Gegenstand steht zusätzlich „hergestellt aus“ und „gebraucht für“ mit Link zum Rezept. Nur das **Rezeptbuch** (schaltet ein Rezept frei) ist ein Gegenstand, Art „Rezeptbuch“.

Simulation, Laden, Beute, Tasche, Werkort lesen alle aus dem Katalog. Das Werkzeug erzeugt die Seite zum Ansehen (Bild je Stück, je Art nur ihre Spalten) und die Rückverweise „fällt bei“, „wird gebraucht für“, „wird hergestellt aus“.

**Grundform und Fundstück:** der Katalog beschreibt die Grundform („Langschwert“). Was beim einzelnen Fund gewürfelt oder beim Herstellen bestimmt wird (Gegenstandsstufe, Güte, Seltenheit, Zusatzeigenschaften, Zustand), steht nicht im Katalog, sondern entsteht nach den Regelwerten (Regelwerk 386: Stufe und Güte nach Fund, Händler, Material und Rang); nur Einzelstücke (feste Werte) stehen ganz im Katalog. Die heutige Art `einzelstueck` entfällt (Merkmal ja/nein), der Verweis `grundform` bleibt.

## Ablösung: heute fünf Wege im Spiel

| Weg | Was | wird |
|---|---|---|
| `godot/daten/held.json` (beim Bau aus Kotlin erzeugt) | Grundformen mit SRD-Werten; nur Preis und Stufe kommen schon aus dem Katalog (`heldwerte.gd`) | aus dem Katalog erzeugt, Kotlin-Export entfällt |
| `godot/regeln/tabellen.json` | `items` (Heilwürfel), `monsters.loot` mit Chancen | Werte in den Katalog, Beute in den Figurenkatalog |
| `texte.json` (Kotlin: `Recipes.kt`, `Story.kt` Laden) | Namen, Rezepte, Ladenbestand | Katalog (Texte bleiben bei Homer, nur die Stelle wechselt) |
| `beute.gd` | Seltenheitsgewichte, Kapitel-1-Decke, Zusatzeigenschaften, Preisformel 3/8/20/50/150 im Code | Formeln in die Regelwerte |
| `werte.json` | Stückwerte, Beute, Zerlegeteile | nur noch Formeln und Gruppenwerte |

Reihenfolge: erst die Prüfung im Werkzeug (zeigt jede Abweichung), dann je Weg umstellen, je Weg ein Vorgang.

## Spalten

**Für alle Arten**
- Kennung, Name (de, en), Genus (für zusammengesetzte Texte), Art, Text (ein Satz, Homer), Bild (aus dem Modell im Spielstil gerendert), Modell (Verweis `LISTE-BESTAND.md`), Netz, Material, Zeichen (wie Seltenheit sichtbar wird, 455, 458)
- Gegenstandsstufe der Grundform (gibt Stärke und Mindeststufe zum Tragen, Regelwerk 386; „erhältlich ab“ geht darin auf; das Fundstück kann abweichen), Einzelstück ja/nein, nutzt sich ab ja/nein (heutige Spalte `zustand`)
- Voraussetzungen über die Mindeststufe hinaus, **für alle Arten** (Chef 12:39: „betrifft ja alles … Tränke … Bomben“): Grundwert, Fertigkeit und Rang, Pfad, Quest, Ruf
- Grundpreis (verkäuflich ergibt sich: Preis 0 = nicht verkäuflich), ablegbar (Handlungsgegenstände nicht)
- Bezug: Laden (welcher), Beute (Rückverweis aus dem Figurenkatalog), Zerlegen, Sammeln (wo), Herstellen (Rückverweis aus den Rezepten), Fund (Ort), Handlung (Quest)
- Verwendung: wofür gut (Rezept, Quest, Händler), damit nichts sinnlos in der Tasche liegt
- benutzbar: im Kampf, außerhalb, beides; wirkt nur gegen (z. B. Weihwasser: Untote)
- Stapel (wie viele je Fach), **Gewicht** (Entscheidung 41: Tragkraft bleibt, mehr tragen macht langsamer)
- Werkstoff (Metall, Leder, Stoff, Holz, Glas …): daraus abgeleitet Reparatur (Metall Schmieden, Leder und Stoff Lederarbeit; Holz und Glas regelt das Regelwerk nicht: offen), Sperren, Klang, zerbrechlich
- Klänge (Aufheben, Anlegen, Benutzen): je Werkstoff und Anlass drei Varianten (`DESIGN-STIL.md`), nicht je Stück; ein Stück darf eigene Klänge haben, die dann vorgehen. Das Werkzeug meldet jeden Werkstoff und Anlass unter drei. (Die zweite Prüfung hielt Klänge für überflüssig; ich behalte sie, weil sie sonst im Code verstreut landen, aber billig über den Werkstoff.)

**Anlegbares** (Waffe, Schild, Rüstungsteil, Schmuck, Fokus, Licht)
- Platz (Kopf, Oberkörper, Arme, Beine, Umhang, Hals, Finger, Haupthand, Nebenhand, beide Hände)
- Zusatzeigenschaften nur bei Einzelstücken fest; sonst nach Seltenheit gewürfelt (Regelwerte). „Fertigkeit +n“ (nicht „Fertigkeitsbonus“, das ist im BRS der Übungsbonus) nur ab episch, nur solange getragen, mit Preis (C1)
- sichtbarer Effekt ab episch (458.3, 415)
- „Verbesserung +1“ der alten Fassung entfällt: geht in Güte und Runenkunde auf

**Waffe:** Waffenart (gibt Grundschaden, Reichweite nah/fern und Schadensart aus den Regelwerten; je Stück nur Abweichung), Fertigkeit, die zählt; Tempo, Parieren, Durchschlag (Zahlen nach 469); ein- oder zweihändig; Munition (offen: Quelle)
**Schild:** Schildwert; Blockgüte offen bis 469 (406.1 C)
**Rüstungsteil:** Schutzwert (nicht „Rüstungsklasse“), Rüstungsart (Stoff, leicht, mittel, schwer); Sperren nach Regelwerk aus Werkstoff und Art (Evokation, Illusion, Beschwörung nur ohne Metall; schwere Rüstung kein Schleichen), keine erfundenen Mali
**Schmuck, Fokus:** Fokus: Schule, Zauberkraft
**Licht:** Leuchtweite; Kampfwerte der Fackel (1 Feuerschaden, Verscheuchen; 344), kein Abbrennen
**Trank, Bombe, Wurf:** Wirkung, Stärke nach Fertigkeit (Kräuterkunde, Alchemie; Formel in den Regelwerten), Dauer in Runden, Ziel, Kosten im Zug; Nebenwirkung offen bis 481
**Nahrung:** Wirkung (Kurze Erholung, Langes Ausruhen, Ausdauer, Gunst vor dem Kampf), roh/gekocht
**Rohstoff, Zerlegeteil:** Ausbeute nach Rang der Sammelfertigkeit: Kräuterkunde, Bergbau, Angeln, **Jagd** (Zerlegen gehört zur Jagd; Regelwerk 233–236; Formel in den Regelwerten)
**Werkzeug, Behälter:** Güte, Bruchchance, Wiederherstellung (Dietriche, Reparaturset, Angel, Hammer); Taschen, Köcher, Nimmersatt-Beutel (Tragkraft, Entscheidung 41)
**Rezeptbuch:** ist ein Gegenstand, der ein Rezept freischaltet (Verweis in den Rezepten)

## Was das Werkzeug prüft
- jede Kennung aus Figurenkatalog, Rezepten, Läden, `tabellen.json`, `held.json` und Code steht im Katalog, mit gleichem Namen; heute fehlen u. a. Zähne, kleines Fell, Schwarte, Panzerplatten, Spinnseide, Knochen, Säure, Flügelhaut, Steinhaut, Berserkertrank, Gegengift, Verband, Taschen, Köcher; vertauscht: `spider_gland` „Giftdrüse“ 30 gegen `werte.json` Spinnendrüse 30 / Giftdrüse 20; die Fackel steht als Beute, fällt aber nie
- kein Stück aus Kapitel 1 ohne Bild, Text, Preis, Mindeststufe
- jeder Rohstoff hat eine Verwendung; jedes Rezept aus Kapitel 1 ist mit Zutaten aus Kapitel 1 herstellbar
- Preise passen zum Gold aus Kapitel 1 ohne Grinden (Simulation 444)
- keine Werte je Stück in den Regelwerten, keine Beute außerhalb des Figurenkatalogs, kein Rezept außerhalb der Rezepte
- abgeleitete Spalten (verkäuflich, Farbe, Reparatur) werden nie von Hand gepflegt

## C: Balance (Vorschläge, deine Entscheidung)
- **C1 Preis eines „Fertigkeit +n“:** nur ab episch, +1 bis +2, dafür ein spürbarer Nachteil am selben Stück (z. B. −1 auf eine andere Fertigkeit oder schnellerer Verschleiß); Fluch nur bei Einzelstücken mit Geschichte (Homer). Chef 12:36: „ganz selten … nicht ausschließen … wow“.
- **C2 Seltenheitsdecke je Kapitel:** Kapitel 1 höchstens ungewöhnlich als Beute (so heute schon im Code, `beute.gd:12`), Bosse selten; „episch“ in Kapitel 1 nur als Einzelstück mit Geschichte.

## Auswertung
- **Stärkstes Gegenargument** (Prüfer 12:58): nicht der Umfang, sondern die Laufzeit; das Spiel rechnet mit fünf anderen Wegen, der Katalog würde eine weitere Kopie. **Antwort:** die Ablösung ist Teil von A; ohne sie wäre mein Votum nein.
- Umfang (hunderte Stücke bis Kapitel 7): Spalten gelten für alle, gefüllt wird nur, was Kapitel 1 braucht; Prüfungen macht das Werkzeug.
- Rezepte als eigener Teil statt Spalte am Gegenstand: ein Rezept hat Zutaten, Werkort, Rang, Gebühr und eine Herkunft; als Spalte am Ergebnis stünde das verstreut (heute dreifach: Katalog `bezug.rezept`, `texte.json`, `werte.json`).
- Eingearbeitet aus den Prüfungen: alles außer „Gewicht und Klang überflüssig“ (12:58, Punkt 10; Gewicht: Entscheidung 41 geht vor; Klang: über den Werkstoff, s. oben); „Tragart je Gegenstand“ gestrichen (417a).
- **Dritte Gegenprüfung** (Helfer, 14:24) an dieser Fassung: Gegenstandsstufe war fälschlich gestrichen (Regelwerk 386), Rezeptteil unvollständig (drei Zustände, Handwerker, Ergebnismenge, Güte, Übung), SRD-Wörter „Rast“, „Vorteil“, fehlend: Deckel und Mindeststufe je Seltenheit, Spalte `zustand`, Heilung als Stückwert, Kapitel-1-Decke in `beute.gd:12`, Zerlegeteile unter deutschen Namen, Nimmersatt-Beutel, Sammelfertigkeiten außer Jagd, Reparatur von Holz und Glas, Prüfung der drei Varianten. **Alles eingearbeitet** (14:2x). Beute steht im Einklang mit dem Figurenkatalog.

## Folgerungen
„644 A“: Werkzeug bekommt Spalten, Rezeptteil und Prüfungen (Jerry, zusammen mit 649.2), Jerry rechnet die Zahlen nach 469 in 444, je abzulösendem Weg ein Vorgang an das Team, dem er gehört. „644 B“: Seltenheit ins Regelwerk (Abschnitt Ausrüstung). „644 C“: Vorschläge C1, C2 in die Regelwerte.
