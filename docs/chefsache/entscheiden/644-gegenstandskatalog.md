# 644 · Gegenstandskatalog: Aufbau, eine Stelle für alle Gegenstände · Sokrates · 08.11., 12:5x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/tools/gegenstaende.py

**Frage:** (A) Grundsatz „jede Angabe an einer Stelle“ wie unten, **samt Ablösung** der Wege, aus denen das Spiel heute liest (`held.json`, `texte.json`, `tabellen.json`, `beute.gd`, Stückwerte in `werte.json`)? (B) Seltenheit als eigene Achse ins BRS (heute nur Stufe, Güte, Zustand; Seltenheit stammt aus der SRD-Fassung; dein Wort 12:30 „Seltenheit, Farben, Zusatzwerte auf BRS“)? (C) Die Spalten arbeite ich nach beiden Gegenprüfungen unten um und lege sie dir erneut vor; Balancefragen darin (Preis des Fertigkeitsbonus, Seltenheitsdecke je Kapitel) einzeln.
**Votum Sokrates: A ja, B ja, C so.** Zwei Gegenprüfungen (12:55, 12:58) fanden 25 und 11 Punkte; die Spalten unten sind daher nicht entscheidungsreif, der Grundsatz schon. Ohne Ablösung (zweite Prüfung, Punkt 4) wäre mein Votum zu A nein: der Katalog würde nur eine weitere Kopie.
**Berührt:** 458, 478, 469, 481, 447, Bestiarium, Laden, Beute, Simulation 444.

## Grundsatz: jede Angabe an genau einer Stelle

| Stelle | Was dort steht | Was dort nicht steht |
|---|---|---|
| **Gegenstandskatalog** (`tools/gegenstaende/gegenstaende.json`, heute 458) | jedes Ding im Spiel, je Stück alle Werte: Waffen, Schilde, Rüstungsteile, Schmuck, Fokus, Licht, Tränke, Bomben und Wurfgeschosse, Nahrung, Rohstoffe und Zerlegeteile, Werkzeug, Handlungsgegenstände, Einzelstücke | Formeln, Monster |
| **Regelwerte** (`tools/sim444/werte.json`) | nur Formeln und Faktoren: Schaden = …, Abzug = …, Faktor je Güte, Zustand, Gegenstandsstufe, Seltenheit → Zahl der Zusatzeigenschaften, Verkaufsanteil | keine Werte je Stück (heute doppelt: Waffengruppen, Rüstungen, Kampftränke mit Preisen) |
| **Bestiarium** (`LISTE-BESTIARIUM.md`) | je Monster, was es fallen lässt und was Zerlegen bringt, nur als Kennung aus dem Katalog | Preis, Wirkung, Name des Dings |
| **Rezepte** (heute verstreut: Morwen, Lehrmeister, 447) | Zutaten → Ergebnis, nur Kennungen | Werte |

Simulation, Laden, Beute, Tasche lesen alle aus dem Katalog. Das Werkzeug erzeugt daraus die Seite zum Ansehen (mit Bild je Stück, je Art nur die Spalten, die dort gelten).

## Spalten

**Für alle Arten**
- Kennung, Name (de, en), Art, Text (ein Satz, Homer), Bild (aus dem Modell im Spielstil gerendert), Modell mit Quelle und Lizenz
- Gegenstandsstufe, Seltenheit (gewöhnlich bis göttlich, Farbe), Einzelstück ja/nein (Grundform)
- Preis (Grundpreis; Verkauf über den Anteil in den Regelwerten), verkäuflich, ablegbar (Handlungsgegenstände nicht)
- Bezug: Laden (welcher), Beute (welches Monster), Zerlegen, Sammeln (wo), Herstellen (Rezept), Fund (Ort), Handlung (Quest)
- Verwendung: wofür gut (Rezept, Quest, Händler, der es kauft), damit nichts sinnlos in der Tasche liegt
- Stapel (wie viele je Fach); Gewicht nur, falls Traglast kommt (heute keine)
- Klang beim Aufheben, Anlegen, Benutzen (Verweis Klangliste)

**Anlegbares** (Waffe, Schild, Rüstungsteil, Schmuck, Fokus, Licht)
- Platz (Kopf, Oberkörper, Arme, Beine, Umhang, Hals, Finger, Haupthand, Nebenhand, beide Hände)
- Voraussetzungen: Mindeststufe; bei Besonderem zusätzlich Grundwert, Fertigkeit, Pfad, Quest, Ruf
- Güte (Normal, Gut, Meisterhaft; Faktor in den Regelwerten), Zustand (nutzt sich ab), Reparatur mit (Schmieden, Lederarbeit, Runenkunde) und Rang
- Zusatzeigenschaften (nach Seltenheit 0–5; fest bei Einzelstücken, zufällig bei Beute); Fertigkeitsbonus nur ab episch, nur solange getragen, mit Preis (Malus, Fluch, Verschleiß; Chef 12:36)
- Tragart unterwegs (417), innen ausgeblendet; sichtbarer Effekt ab episch (458.3, 415)

**Waffe:** Waffenart (gibt Grundschaden und Grundwert aus den Regelwerten), Fertigkeit, die zählt; Schaden (Abweichung von der Art), Tempo, Parieren, Durchschlag, Reichweite (nah, Stange, fern), Schadensart (Klinge, stumpf, Stich, Feuer …), ein- oder zweihändig, Munition
**Schild:** Schildwert (Abzug), Blockgüte (406.1), Wirkung auf Ausweichen
**Rüstungsteil:** Rüstungswert (Abzug), Klasse (leicht, mittel, schwer: welche Fertigkeit zählt), Malus (Schleichen, Zauber, Ausweichen)
**Schmuck, Fokus:** Zusatzeigenschaften; Fokus: Schule, Zauberkraft
**Licht:** Brenndauer, Leuchtweite (344)
**Trank, Bombe, Wurf:** Wirkung (Heilung, Schaden, Zustand), Stärke nach Fertigkeit (Kräuterkunde, Alchemie; Formel in den Regelwerten), Dauer in Runden, Ziel (selbst, einer, Fläche), Kosten im Zug, Nebenwirkung (für andere giftig, 481)
**Nahrung:** Wirkung (Rast, Ausdauer, Vorteil vor dem Kampf), roh/gekocht, Verderb nur als Vorteil (frisch gibt mehr)
**Rohstoff, Zerlegeteil:** von welchen Monstern (Rückverweis aus dem Bestiarium erzeugt), Güte des Teils (nach Rang im Zerlegen)

## Was das Werkzeug prüft
- jede Kennung aus Bestiarium, Rezepten, Läden und Code steht im Katalog (heute fehlen u. a. Wolfszähne, Spinnendrüse, kleines Fell, Schutzumhang)
- kein Stück ohne Bild, Text, Preis, Stufe, wenn es in Kapitel 1 erhältlich ist
- jeder Rohstoff hat eine Verwendung; jedes Rezept aus Kapitel 1 ist mit Zutaten aus Kapitel 1 herstellbar
- Preise passen zum Gold aus Kapitel 1 ohne Grinden (Simulation 444)
- keine Werte je Stück in den Regelwerten

## Auswertung
- **Stärkstes Gegenargument:** Umfang; mit Kapitel 2–7 hunderte Stücke und viele Spalten. **Entkräftet:** Spalten gelten für alle, gefüllt wird nur, was Kapitel 1 braucht; die Seite zeigt je Art nur ihre Spalten; Prüfungen macht das Werkzeug.
- „Verbesserung +1“ der alten Fassung (`Gear.plus`): Vorschlag, in Güte und Runenkunde (Verzaubern) aufgehen lassen, sonst vier Achsen (Stufe, Güte, Seltenheit, Verbesserung).
- Zusatzeigenschaften alt (`Gear.kt` Affix) sind SRD-Werte und werden auf BRS übertragen.

## Folgerungen
„644 ja“: Aufbau gilt; Jerry rechnet die Zahlen (Tempo, Parieren, Durchschlag, Güte, Stufe) nach 469 in 444, das Werkzeug (`gegenstaende.py`) bekommt die Spalten und Prüfungen, Werte je Stück wandern aus `werte.json` in den Katalog. „nein“ oder Änderungen: Entwurf wird angepasst.

## Befund der Gegenprüfung (Helfer, 08.11., 12:55; noch nicht eingearbeitet, urteilen tust du)

Wichtigste zuerst; „E“ = Entwurf oben.

**A. Widerspricht Entschiedenem**
1. Netz, Material, Zeichen fehlen; nach 455, 458, E7 zeigt sich Seltenheit über Material und Zeichen (Katalog hat die Spalten heute). → übernehmen.
2. Gewicht „nur falls Traglast kommt“ widerspricht Entscheidung 41 (Tragkraft bleibt, Nimmersatt-Beutel, mehr tragen = langsamer). → Gewicht fest, Beutel als Gegenstand.
3. Voraussetzungen nur bei Anlegbarem; Chef 12:39 „betrifft ja alles … Tränke … Bomben“. → zu „Für alle Arten“.
4. „Malus Schleichen, Zauber, Ausweichen“: im BRS harte Sperren (Evokation, Illusion, Beschwörung nur ohne Metall; schwere Rüstung kein Schleichen); Ausweich-Malus ohne Quelle. → Spalte Werkstoff (Metall, Leder, Stoff, Holz), Sperren und Reparatur daraus ableiten.
5. Tragart je Gegenstand: nach 417a je Figur nach Aussehen, seit 417 Waffe unterwegs in der Hand. → streichen.
6. „Rüstungsklasse“ ist SRD-Begriff (ersetzt durch „Schutzwert“); Stufe Stoff fehlt. → „Rüstungsart“: Stoff, leicht, mittel, schwer.
7. „Fertigkeitsbonus“ heißt im BRS schon der Übungsbonus; der „Preis“ (Malus, Fluch) ist Balance, also deine Entscheidung. → „Fertigkeit +n“, Preis als Vorschlag.
8. Schild „Gewicht für Ausweichen“ ohne Quelle; Blockgüte nach 406.1 C offen bis 469. → streichen, „offen, 469“.
9. Nebenwirkung „für andere giftig“: 481 nicht entschieden, Simulation rechnet „halbe Wirkung“. → offen bis 481.
10. Licht „Brenndauer“: 344 kennt kein Abbrennen. → streichen, Kampfwerte der Fackel (1 Feuerschaden, Verscheuchen) aufnehmen.

**B. Werte je Stück außerhalb des Katalogs**
11. `werte.json` hat mehr Stückwerte als genannt: 17 Preise nach Namen, Beute je Monster, Zerlegeteile, Startausrüstung, Heilung, Kampftränke, Braukosten; Reichweite und Schadensart stünden doppelt (Gruppe und Stück). → nur an der Gruppe, je Stück höchstens Abweichung.
12. Namenskonflikt: `werte.json` Spinnendrüse 30 / Giftdrüse 20, Katalog `spider_gland` = Giftdrüse 30. → eine Kennung festlegen.
13. Godot liest aus dem Katalog nur Preis und Stufe; alles andere aus `held.json` und `texte.json` (aus der alten Fassung erzeugt), Zusatzeigenschaften fest in `beute.gd`. → „liest alle aus dem Katalog“ braucht: `held.json`, `texte.json` für Gegenstände abschalten.
14. Rezepte an drei Stellen (Katalog `bezug.rezept`, `texte.json`, `werte.json`); Gebühr des Herstellers fehlt im Entwurf.
15. Beute an drei Stellen (Katalog, `werte.json`, Bestiarium). → Chance und Menge nur im Bestiarium, Bezug im Katalog daraus erzeugt.

**C. Fehlende Arten und Stücke**
16. Zerlegeteile: Fell klein, Zähne, Schwarte, Panzerplatten, Spinnseide, Flügelhaut, Knochen, Säure.
17. Werkzeug ohne Stücke und Spalten: Dietriche in Güteklassen (brechen), Reparaturset, Angel, Hammer. → Güte, Bruchchance, Wiederherstellung.
18. Kapitel 1 fehlt: Gegengift (Belohnung), Steinhaut, Berserkertrank, Verband, Taschen und Köcher; Munition ohne Quelle → offen.
19. Rezept als Gegenstand (Bücher, Belohnung, Händler) mit Fertigkeit, Rang, Werkort, Stufe.
20. Spalten fehlen: wann benutzbar (Kampf, außerhalb, beides), wirkt nur gegen (Weihwasser: Untote), zerbrechlich (Aufbrechen), Genus für zusammengesetzte Namen.

**D. Unklare Achsen, Pflege**
21. Grundform und Exemplar vermischt: Seltenheit, Gegenstandsstufe, Verbesserung, Eigenschaften waren alt Werte des einzelnen Funds (gewürfelt). → Katalog = Grundform, eigener Teil „Exemplar“.
22. Drei Stufen (Gegenstandsstufe, Mindeststufe, heutige Spalte „erhältlich ab“). → festlegen; im Katalog wohl nur die Mindeststufe.
23. Einzelstück doppelt (Merkmal und Art). → eins.
24. Abgeleitetes nicht pflegen: verkäuflich (Preis 0), Farbe (aus Seltenheit), Reparatur (aus Werkstoff), Klang (je Art oder Werkstoff; eine Klangliste gibt es nicht).
25. In den Regelwerten fehlen: Seltenheitsdecke je Kapitel (Kapitel 1 höchstens ungewöhnlich, Bosse selten; „ab episch“ in Kapitel 1 nur Einzelstücke), Deckel der Eigenschaften, erlaubte Eigenschaften je Platz, Mindeststufe je Seltenheit, Preisformel.

Nebenbei: Die Fackel hat im Katalog den Bezug „Beute“, fällt laut alter Fassung und `beute.gd` aber nie als Beute.

## Zweite Gegenprüfung (Helfer, 08.11., 12:58; noch nicht eingearbeitet, urteilen tust du)

1. „Werte doppelt in `werte.json`“ nur zum Teil: `waffen` und `ruestungen` sind Gruppenwerte (gehören laut Entwurf selbst in die Regelwerte); je Stück sind `kampftraenke` (Preis 40), `wirtschaft.preise` (17 Preise), dazu doppeln `wirtschaft.beute` und `zerlegen.teile` das Bestiarium.
2. Spinnendrüse fehlt nicht, Namen vertauscht (`spider_gland` heißt im Katalog „Giftdrüse“, 30; `werte.json` Spinnendrüse 30, Giftdrüse 20).
3. Schutzumhang fehlt nicht: `cloak_protection` „Umhang des Schutzes“ steht im Katalog, nur der Name im Bestiarium (Zeile 30) weicht ab. Zähne, kleines Fell fehlen wirklich; dazu Schwarte, Panzerplatten, Spinnseide, Knochen, Säure, Flügelhaut/Fledermausflügel, Steinhaut, Berserkertrank.
4. **Stärkstes Gegenargument: Laufzeit statt Umfang.** Godot liest Grundformen mit SRD-Werten aus `godot/daten/held.json` (beim Bau aus Kotlin erzeugt, `godot.yml:52`; nur Preis und Stufe aus dem Katalog, `heldwerte.gd:30–36`), Texte, Rezepte, Laden aus `texte.json` (`Recipes.kt`, `Story.kt:109`), Heilwürfel und Beutechancen aus `godot/regeln/tabellen.json` (dritte Beuteliste), Seltenheitsgewichte und Preisformel 3/8/20/50/150 fest in `beute.gd:10, 263–271`. Ohne Ablöseplan dieser Wege wird der Katalog eine weitere Kopie.
5. Rezepte stehen schon im Katalog (`bezug.rezept`); eine eigene Rezeptstelle würde sie doppeln.
6. Seltenheit „gewöhnlich bis göttlich“ steht nicht im BRS (aus `Gear.kt:6–13`, SRD); das BRS kennt Stufe, Güte, Zustand (Regelwerk 386f.). Seltenheit braucht erst einen Beschluss.
7. Reparatur nur Schmieden und Lederarbeit; Runenkunde nur beim Großmeister für magische Stücke (Regelwerk 389).
8. Zerlegen gehört zur Fertigkeit **Jagd** (Regelwerk 83, 236), nicht zu einem „Rang im Zerlegen“; das Ergebnis heißt in `werte.json` „Ausbeute“.
9. Reichweite „Stange“ gibt es in `werte.json` nicht; Stangenwaffen gelten als „nah“.
10. Überflüssig für Kapitel 1: Gewicht, Klang je Handlung, Tragart.
11. Fehlt: Abgleich der Namen mit den Kennungen; Ablösung der Kotlin-Exporte; Beute nur an einer Stelle (heute Katalog, Bestiarium, `werte.json`, `tabellen.json`).

Abweichend: zweite Prüfung Punkt 10 (Gewicht überflüssig) gegen erste Prüfung Punkt 2 (Gewicht nach Entscheidung 41 fest); ich folge der ersten.
