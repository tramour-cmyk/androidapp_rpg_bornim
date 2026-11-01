# Netzliste je Platz (455.2)

Spike, 01.11. (Archiv 455, Chef 11:27 „455 ja, wie Sokrates“). Ein Gegenstand = **Netz × Material × Zeichen**: das Netz ist die Form, Material und Zeichen stehen im Farbbild (Probe 455.1, `baukasten455.py`). Sichtbar am Modell sind sieben Plätze (Kopf, Oberkörper, Arme, Beine, Umhang, Haupt- und Nebenhand), nicht Amulett und Ring. Quelle der Gegenstände: `tools/gegenstaende/gegenstaende.json` (458); 458.3 trägt Netz, Material, Zeichen und Modell daraus ein. Quellen der Netze: `LISTE-BESTAND.md` („Figuren“, „Waffen und Schilde“).

- **Bestand** heißt: fertig im Kaufrepo oder frei, nur Material und Zeichen ins Bild; Mann und Frau gibt es je Tracht.
- **Unser** heißt: von uns gebaut und auf den Kaufkörper gesetzt (376.1, `kauf_kleid.py`), Mann und Frau angepasst.
- **Eigenbau** heißt: fehlt; wird einmal und gleich für Mann und Frau gebaut (455, Punkt 3).
- Material: Stoff, Leder, Kette, Schuppe, Platte, Fell, Eisen; Zeichen: Farbe mit Borte, Runen (verzaubert), Glanz je Seltenheit (nur Gold glänzt).
- Aufwand geschätzt, nicht gemessen: **gering** = nur Bild (unter einer Sitzung, eine Probe für alle); **mittel** = Netz anpassen (eine Runde mit Probelauf); **hoch** = Eigenbau (zwei Runden, Mann und Frau, Durchdringung messen).

## Kopf

| Netz | Quelle | Gegenstände (Material, Zeichen) | Aufwand |
|---|---|---|---|
| Kapuze | Bestand: Ranger `Head_Hood` | Kapuze (Stoff) | gering |
| Reif | Bestand: Noble `Head_Crown` | Stirnreif (Eisen; Gold erst bei Seltenheit) | gering; ob die Krone als Reif liest, zeigt die Probe |
| Kappe | **Eigenbau** (fehlt: Topf- und Lederhelm, 455) | Lederkappe (Leder), Helm (Eisen) | hoch |
| Topfhelm | Bestand: Knight `Head_Armet` | Topfhelm (Platte) | gering |
| Hörnerhelm | Bestand: Knight `Head_Horns` | heute kein Gegenstand; für Seltenes oder Gegner | – |

## Oberkörper

| Netz | Quelle | Gegenstände (Material, Zeichen) | Aufwand |
|---|---|---|---|
| Lange Robe | unser (376.1, `trachten.json` held_wizard) | Robe (Stoff) | gering; Prüferbefund 376.1 (Knie durch die Robe) offen |
| Wams | Bestand: Ranger `Body` | Lederrüstung (Leder), Nietenleder (Leder, Nieten im Bild) | gering |
| Kettenhemd | unser (Wachsoldat: Kettenhemd und Wappenrock) | Kettenhemd (Kette), Kettenpanzer (Kette, schwerer Wappenrock), Schuppenpanzer (Schuppe) | gering bis mittel: Schuppe ist ein neues Bildmuster |
| Brustplatte | Bestand: Knight `Body_Armor` | Brustplatte (Platte), Schienenpanzer (Schiene: Streifen im Bild) | gering |
| Plattenrüstung | Bestand: Knight `Body_Armor` mit `Pauldron(s)_Round` und Noble `Gorget` | Halbplatte (ohne Halsberge), Plattenpanzer (alles) | mittel: Teile zusammensetzen |
| Bauernkittel, Adelsrock, Ritterstoff | Bestand: Peasant, Noble, Knight_Cloth `Body` | heute kein Gegenstand; Leute und Herkünfte (376.1) | – |

## Arme

| Netz | Quelle | Gegenstände (Material, Zeichen) | Aufwand |
|---|---|---|---|
| Ärmel | Bestand: Peasant `Arms` | Armwickel (Stoff) | gering |
| Handschuh | Bestand: Ranger `Arms` | Lederhandschuhe (Leder); Probe 455.1 auch Kette | gering |
| Armschiene | Bestand: Knight_Cloth `Arms` | Armschienen (Leder mit Eisen) | gering |
| Panzerhandschuh | Bestand: Knight `Arms` | Panzerhandschuhe (Platte); Handschuhe der Ogerkraft (Platte, Runen; Einzelstück) | gering |

## Beine

| Netz | Quelle | Gegenstände (Material, Zeichen) | Aufwand |
|---|---|---|---|
| Hose mit Schuh | Bestand: Peasant `Legs`, `Feet` | Beinkleider (Stoff) | gering |
| Hose mit Stiefel | Bestand: Ranger `Legs`, `Feet_Boots` | Lederstiefel (Leder); Kettenbeinlinge (Kette), wenn die Probe 455.1 trägt, sonst Eigenbau | gering; sonst hoch |
| Beinschiene | Bestand: Knight `Legs`, `Feet` | Beinschienen (Platte) | gering |

## Umhang

| Netz | Quelle | Gegenstände (Material, Zeichen) | Aufwand |
|---|---|---|---|
| Umhang | unser (Wachsoldat) | Umhang (Stoff); Umhang des Schutzes (Stoff, Runen; Einzelstück) | gering; Faltenwurf beim Rennen offen (455) |
| Mantel | **Eigenbau** (fehlt, 455) | Mantel (Wolle, Fell am Kragen) | hoch |
| Schal | Bestand: Knight `Scarf` | heute kein Gegenstand | – |

## Haupthand, Nebenhand, beide Hände

Waffen und Schilde sind fertige Netze, kein Baukasten nötig: je Waffe ein Netz, Material und Zeichen nur für Seltenes (Runen, Gold). In `waffen.py` (Jerry, Stand Zweig 417) gebaut: Dolch, Kurzschwert, Langschwert, Kampfstab, Schild, Rundschild, Krummsäbel, Handbeil, Kurzbogen, Speer, Graks Kriegsaxt; Tragart 417 nimmt die Kaufwaffen, Kaufschilde 406. Für die übrigen ein Netz aus dem Bestand wählen (`LISTE-BESTAND.md` „Waffen und Schilde“: Omie, Anker, Avramania, PolyMech): Streitkolben, Streitaxt, Morgenstern, Kriegshammer, Zauberstab, Zweihänder, Großaxt, Zweihandhammer, Hellebarde, Magierstab, Langbogen, Armbrust, Foliant (Anker Zauberbuch), Fackel (Props MegaKit `Torch_Metal`); Turmschild: Kite-Schild der Omie prüfen. Nicht im Bestand gefunden: Rapier, Zauberkugel, Heiligensymbol (Eigenbau, gering, weil starr). Einzelstücke (Klinge von Bornim, Flüsterklinge, Morgenröte, Glutstab): Netz der Grundwaffe mit eigenem Zeichen.

## Nicht am Modell

Amulett, Talisman, Ring, Siegelring, Einzelstücke dort: nur Bild im Inventar (455, Chef 11:24 „Ring sehe ich definitiv nicht“). Tränke, Wurfgeschosse, Rohstoffe, Nahrung, Handlungsgegenstände: kein Netz am Helden.

## Summe

Von 27 sichtbaren Rüstungsgegenständen (mit zwei Einzelstücken) kommen 24 mit Netzen aus dem Bestand oder von uns aus (nur Bild, ein neues Bildmuster Schuppe, Plattenrüstung zusammensetzen), drei brauchen Eigenbau: **Kappe** (Lederkappe, Helm) und **Mantel**, je für Mann und Frau; **Kettenbeinlinge** nur, falls Kette auf den Waldläuferbeinen nicht trägt (Probe 455.1). Größen der Völker (Ork, Hügelvolk) misst der Größenfilm 455.2; was dort reißt, kommt hier als Anpassung je Volk dazu.
