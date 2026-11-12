# Gegenstände (erzeugt, nicht von Hand ändern)

Aus `tools/gegenstaende/gegenstaende.json` mit `python3 tools/gegenstaende.py` (458). Ändern nur in der Datendatei, dann das Werkzeug laufen lassen und beides committen. Werte „alt“ stammen aus der alten Fassung (SRD) und gelten nicht für das Bornimer Rollenspielsystem; „–“ heißt noch offen. Wer füllt: Jerry Stufe, Preis, Zustand, Beute (458.2); Tom Netz, Modell, Läden (458.3); Homer Namen und Texte (458.4).

**Stand:** 95 Gegenstände, davon 66 vollständig; Waffen 21, Schilde 3, Rüstung 25, Schmuck 4, Zauberfokus 3, Licht 1, Einzelstücke 15, Tränke 6, Wurfgeschosse 2, Nahrung 1, Rohstoffe 7, Handlungsgegenstände 7.

## Nach Art

### Waffen (21)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `dagger` | Dolch | haupthand | 1 | 2 | unser Netz (waffen.py, Jerry) | Laden Thessa; Beute | – |
| `shortsword` | Kurzschwert | haupthand | 1 | 10 | unser Netz (waffen.py, Jerry) | Laden Thessa; Beute | – |
| `scimitar` | Krummsäbel | haupthand | 1 | 25 | unser Netz (waffen.py, Jerry) | Laden Thessa; Beute | – |
| `handaxe` | Handbeil | haupthand | 1 | 5 | unser Netz (waffen.py, Jerry) | Laden Thessa; Beute | – |
| `mace` | Streitkolben | haupthand | 1 | 5 | – | Laden Thessa; Beute | netz, modell |
| `spear` | Speer | haupthand | 1 | 1 | – | Laden Thessa; Beute | netz, modell |
| `quarterstaff` | Kampfstab | haupthand | 1 | 1 | unser Netz (waffen.py, Jerry) | Laden Thessa; Beute | – |
| `rapier` | Rapier | haupthand | 2 | 25 | – | Laden Thessa; Beute | netz, modell |
| `longsword` | Langschwert | haupthand | 1 | 15 | unser Netz (waffen.py, Jerry) | Laden Thessa; Beute | – |
| `battleaxe` | Streitaxt | haupthand | 1 | 10 | – | Laden Thessa; Beute | netz, modell |
| `morningstar` | Morgenstern | haupthand | 3 | 15 | – | Laden Thessa; Beute | netz, modell |
| `warhammer` | Kriegshammer | haupthand | 2 | 15 | – | Laden Thessa; Beute | netz, modell |
| `wand` | Zauberstab | haupthand | 2 | 30 | – | Laden Thessa; Beute | netz, modell |
| `greatsword` | Zweihänder | beide_haende | 3 | 50 | – | Laden Thessa; Beute | netz, modell |
| `greataxe` | Großaxt | beide_haende | 3 | 30 | – | Laden Thessa; Beute | netz, modell |
| `maul` | Zweihandhammer | beide_haende | 4 | 10 | – | Laden Thessa; Beute | netz, modell |
| `halberd` | Hellebarde | beide_haende | 2 | 20 | – | Laden Thessa; Beute | netz, modell |
| `staff` | Magierstab | beide_haende | 2 | 40 | – | Laden Thessa; Beute | netz, modell |
| `shortbow` | Kurzbogen | beide_haende | 1 | 25 | unser Netz (waffen.py, Jerry) | Laden Thessa; Beute | – |
| `longbow` | Langbogen | beide_haende | 3 | 50 | – | Laden Thessa; Beute | netz, modell |
| `light_crossbow` | Armbrust | beide_haende | 2 | 25 | – | Laden Thessa; Beute | netz, modell |

### Schilde (3)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `shield` | Schild | nebenhand | 1 | 10 | unser Netz (waffen.py, Jerry) | Laden Thessa; Beute | – |
| `round_shield` | Rundschild | nebenhand | 1 | 10 | unser Netz (waffen.py, Jerry) | Laden Thessa; Beute | – |
| `tower_shield` | Turmschild | nebenhand | 5 | 60 | – | Laden Thessa; Beute | netz, modell |

### Rüstung (25)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `hood` | Kapuze | kopf | 1 | 2 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `circlet` | Stirnreif | kopf | 2 | 15 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `leather_cap` | Lederkappe | kopf | 1 | 5 | Eigenbau, fehlt (LISTE-NETZE.md) | Laden Thessa; Beute | – |
| `helmet` | Helm | kopf | 2 | 15 | Eigenbau, fehlt (LISTE-NETZE.md) | Laden Thessa; Beute | – |
| `great_helm` | Topfhelm | kopf | 4 | 40 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `robe` | Robe | oberkoerper | 1 | 5 | unser Netz auf dem Kaufkörper (held3.py, kauf_kleid.py; 376.1) | Laden Thessa; Beute | – |
| `leather` | Lederrüstung | oberkoerper | 1 | 10 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `studded_leather` | Nietenleder | oberkoerper | 2 | 45 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `chain_shirt` | Kettenhemd | oberkoerper | 1 | 50 | unser Netz auf dem Kaufkörper (held3.py, kauf_kleid.py; 376.1) | Laden Thessa; Beute | – |
| `scale_mail` | Schuppenpanzer | oberkoerper | 2 | 50 | unser Netz auf dem Kaufkörper (held3.py, kauf_kleid.py; 376.1) | Laden Thessa; Beute | – |
| `breastplate` | Brustplatte | oberkoerper | 4 | 400 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `half_plate` | Halbplatte | oberkoerper | 6 | 750 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `chain_mail` | Kettenpanzer | oberkoerper | 2 | 75 | unser Netz auf dem Kaufkörper (held3.py, kauf_kleid.py; 376.1) | Laden Thessa; Beute | – |
| `splint` | Schienenpanzer | oberkoerper | 4 | 200 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `plate` | Plattenpanzer | oberkoerper | 7 | 1500 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `wraps` | Armwickel | arme | 1 | 2 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `gloves` | Lederhandschuhe | arme | 1 | 5 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `bracers` | Armschienen | arme | 2 | 20 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `gauntlets` | Panzerhandschuhe | arme | 3 | 40 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `leggings` | Beinkleider | beine | 1 | 2 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `boots` | Lederstiefel | beine | 1 | 5 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `chain_leggings` | Kettenbeinlinge | beine | 2 | 20 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren); Eigenbau, falls Kette dort nicht trägt (455.1) | Laden Thessa; Beute | – |
| `greaves` | Beinschienen | beine | 3 | 40 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Laden Thessa; Beute | – |
| `cloak` | Umhang | umhang | 1 | 5 | unser Netz auf dem Kaufkörper (held3.py, kauf_kleid.py; 376.1) | Laden Thessa; Beute | – |
| `mantle` | Mantel | umhang | 3 | 30 | Eigenbau, fehlt (LISTE-NETZE.md) | Laden Thessa; Beute | – |

### Schmuck (4)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `amulet` | Amulett | hals | 1 | 25 | keins: nur Bild im Inventar (455) | Laden Thessa; Beute | – |
| `talisman` | Talisman | hals | 3 | 60 | keins: nur Bild im Inventar (455) | Laden Thessa; Beute | – |
| `ring` | Ring | finger | 1 | 25 | keins: nur Bild im Inventar (455) | Laden Thessa; Beute | – |
| `signet` | Siegelring | finger | 3 | 60 | keins: nur Bild im Inventar (455) | Laden Thessa; Beute | – |

### Zauberfokus (3)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `orb` | Zauberkugel | nebenhand | 1 | 20 | – | Laden Thessa; Beute | netz, modell |
| `tome` | Foliant | nebenhand | 2 | 25 | – | Laden Thessa; Beute | netz, modell |
| `holy_symbol` | Heiligensymbol | nebenhand | 1 | 5 | – | Laden Thessa; Beute | netz, modell |

### Licht (1)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `torch` | Fackel | nebenhand | 1 | 2 | – | Laden Thessa; Beute | netz, modell |

### Einzelstücke (15)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `ring_protection` | Ring des Ältesten (ring) | finger | 6 | 0 | keins: nur Bild im Inventar (455) | Handlung | – |
| `gauntlets_ogre` | Kroggs Pranken (gloves) | arme | 4 | 0 | Quaternius Modular Character Outfits – Fantasy (gekauft, CC0; LISTE-BESTAND.md Figuren) | Beute Krogg | – |
| `greataxe_grak` | Graks Kriegsaxt (greataxe) | beide_haende | 6 | 0 | unser Netz (waffen.py, Jerry) | Beute Grak | – |
| `longsword_oakford` | Klinge von Bornim (longsword) | haupthand | 4 | 0 | – | Fund | netz, modell |
| `staff_of_embers` | Glutstab (staff) | beide_haende | 4 | 0 | – | Fund | netz, modell |
| `rapier_whisper` | Flüsterklinge (dagger) | haupthand | 4 | 0 | unser Netz (waffen.py, Jerry) | Fund | – |
| `mace_of_dawn` | Morgenröte (mace) | haupthand | 4 | 0 | – | Fund | netz, modell |
| `greatsword_nameless` | Die Namenlose (greatsword) | beide_haende | 4 | 0 | – | Fund Truhe in der Blutzahnhöhle (cave_3, 870.14) | netz, modell |
| `spear_wolf` | Wolfsspieß (spear) | haupthand | 4 | 0 | – | Fund Truhe in der Blutzahnhöhle (cave_3, 870.14) | netz, modell |
| `longbow_blackyew` | Schwarzeibe (longbow) | beide_haende | 4 | 0 | – | Fund Truhe in der Blutzahnhöhle (cave_3, 870.14) | netz, modell |
| `crossbow_nightwatch` | Nachtwache (light_crossbow) | beide_haende | 4 | 0 | – | Fund Truhe in der Blutzahnhöhle (cave_3, 870.14) | netz, modell |
| `amulet_grimfang` | Grimmzahns Fang (amulet) | hals | 5 | 0 | keins: nur Bild im Inventar (455) | Beute Grimmzahn | – |
| `cloak_protection` | Wehrmantel (cloak) | umhang | 4 | 0 | unser Netz auf dem Kaufkörper (held3.py, kauf_kleid.py; 376.1) | Beute Riesenspinne | – |
| `cloak_thessa` | Thessas Pelzumhang (cloak) | umhang | 1 | 0 | unser Netz auf dem Kaufkörper (held3.py, kauf_kleid.py; 376.1) | Handlung Thessa, Auftrag Felle für den Winter (356.2) | text |
| `dagger_borin` | Borins Hauerdolch (dagger) | haupthand | 1 | 0 | unser Netz (waffen.py, Jerry) | Handlung Borin, Auftrag Hauer für den Schmied (356.2) | text |

### Tränke (6)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `potion` | Heiltrank | – | 1 | 25 | – | Laden Thessa; Laden Morwen; Herstellen Morwen (2× Heilkräuter, 5 Gold); Beute Riesenratte; Beute Wolf; Beute Wildschwein; Beute Riesen-Hundertfüßer; Beute Riesenfledermaus; Beute Blutflügler; Beute Goblin; Beute Goblin-Späher; Beute Goblin-Schamane; Beute Kobold; Beute Skelett; Beute Zombie | – |
| `greater_potion` | Großer Heiltrank | – | 1 | 75 | – | Laden Thessa; Laden Morwen; Herstellen Morwen (3× Heilkräuter, 1× Fledermausflügel, 15 Gold); Beute Riesenspinne; Beute Goblin-Schamane; Beute Ghul; Beute Ockerschleim; Beute Grimmzahn | – |
| `superior_potion` | Überragender Heiltrank | – | 1 | 200 | – | Laden Thessa | – |
| `remedy` | Kräutertrank | – | 1 | 20 | – | Laden Thessa; Laden Morwen; Herstellen Morwen (2× Heilkräuter, 2 Gold) | – |
| `stamina_potion` | Ausdauertrank | – | 1 | 25 | – | Laden Thessa; Laden Morwen | – |
| `spark_potion` | Leuchtfunke | – | 1 | 25 | – | Laden Thessa | – |

### Wurfgeschosse (2)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `alchemist_fire` | Alchemistenfeuer | – | 1 | 30 | – | Laden Thessa; Herstellen Morwen (1× Giftdrüse, 5 Gold); Beute Goblin; Beute Goblin-Späher; Beute Kobold | – |
| `holy_water` | Weihwasser | – | 1 | 25 | – | Laden Thessa; Laden Morwen; Beute Skelett; Beute Zombie; Beute Ghul | – |

### Nahrung (1)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `roast_meat` | Gebratenes Fleisch | – | 1 | 16 | – | Herstellen Lagerfeuer (1× Rohes Fleisch) | – |

### Rohstoffe (7)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `raw_meat` | Rohes Fleisch | – | 1 | 6 | – | Beute Riesenratte; Beute Wolf; Beute Wildschwein; Beute Grimmzahn | – |
| `herbs` | Heilkräuter | – | 1 | 8 | – | Sammeln | – |
| `wolf_pelt` | Wolfsfell | – | 1 | 24 | – | Beute Wolf; Beute Grimmzahn | – |
| `boar_tusk` | Keilerhauer | – | 1 | 20 | – | Beute Wildschwein | – |
| `spider_gland` | Giftdrüse | – | 1 | 30 | – | Beute Riesenspinne | – |
| `spider_silk` | Spinnseide | – | 1 | 20 | – | Beute Riesenspinne (870.6; Feuer verbrennt sie, LISTE-BESTIARIUM.md) | text |
| `bat_wing` | Fledermausflügel | – | 1 | 16 | – | Beute Riesenfledermaus | – |

### Handlungsgegenstände (7)

| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |
|---|---|---|---|---|---|---|---|
| `gwenna_ring` | Gwennas Ring | – | 1 | 0 | – | Handlung | – |
| `grey_rag` | Grauer Fetzen | – | 1 | 0 | – | Handlung | – |
| `smoke_bundle` | Rauchbündel | – | 1 | 0 | – | Handlung | – |
| `rusty_key` | Rostiger Schlüssel | – | 1 | 0 | – | Beute Krogg | – |
| `grak_key` | Graks Schlüssel | – | 1 | 0 | – | Beute Grak | – |
| `sun_amulet` | Sonnenamulett | – | 1 | 0 | – | Beute Grak | – |
| `prophet_letter` | Versiegelter Brief | – | 1 | 0 | – | Beute Grak | – |

## Nach Bezugsweg

### Laden

- **Thessa:** Kapuze, Stirnreif, Lederkappe, Helm, Topfhelm, Robe, Lederrüstung, Nietenleder, Kettenhemd, Schuppenpanzer, Brustplatte, Halbplatte, Kettenpanzer, Schienenpanzer, Plattenpanzer, Armwickel, Lederhandschuhe, Armschienen, Panzerhandschuhe, Beinkleider, Lederstiefel, Kettenbeinlinge, Beinschienen, Umhang, Mantel, Dolch, Kurzschwert, Krummsäbel, Handbeil, Streitkolben, Speer, Kampfstab, Rapier, Langschwert, Streitaxt, Morgenstern, Kriegshammer, Zauberstab, Zweihänder, Großaxt, Zweihandhammer, Hellebarde, Magierstab, Kurzbogen, Langbogen, Armbrust, Amulett, Talisman, Ring, Siegelring, Schild, Rundschild, Turmschild, Fackel, Zauberkugel, Foliant, Heiligensymbol, Heiltrank, Großer Heiltrank, Überragender Heiltrank, Kräutertrank, Ausdauertrank, Leuchtfunke, Alchemistenfeuer, Weihwasser
- **Morwen:** Heiltrank, Großer Heiltrank, Kräutertrank, Ausdauertrank, Weihwasser

### Beute

- Kapuze, Stirnreif, Lederkappe, Helm, Topfhelm, Robe, Lederrüstung, Nietenleder, Kettenhemd, Schuppenpanzer, Brustplatte, Halbplatte, Kettenpanzer, Schienenpanzer, Plattenpanzer, Armwickel, Lederhandschuhe, Armschienen, Panzerhandschuhe, Beinkleider, Lederstiefel, Kettenbeinlinge, Beinschienen, Umhang, Mantel, Dolch, Kurzschwert, Krummsäbel, Handbeil, Streitkolben, Speer, Kampfstab, Rapier, Langschwert, Streitaxt, Morgenstern, Kriegshammer, Zauberstab, Zweihänder, Großaxt, Zweihandhammer, Hellebarde, Magierstab, Kurzbogen, Langbogen, Armbrust, Amulett, Talisman, Ring, Siegelring, Schild, Rundschild, Turmschild, Fackel, Zauberkugel, Foliant, Heiligensymbol
- **Krogg:** Kroggs Pranken, Rostiger Schlüssel
- **Grak:** Graks Kriegsaxt, Graks Schlüssel, Sonnenamulett, Versiegelter Brief
- **Grimmzahn:** Grimmzahns Fang, Großer Heiltrank, Rohes Fleisch, Wolfsfell
- **Riesenspinne:** Wehrmantel, Großer Heiltrank, Giftdrüse
- **Riesenratte:** Heiltrank, Rohes Fleisch
- **Wolf:** Heiltrank, Rohes Fleisch, Wolfsfell
- **Wildschwein:** Heiltrank, Rohes Fleisch, Keilerhauer
- **Riesen-Hundertfüßer:** Heiltrank
- **Riesenfledermaus:** Heiltrank, Fledermausflügel
- **Blutflügler:** Heiltrank
- **Goblin:** Heiltrank, Alchemistenfeuer
- **Goblin-Späher:** Heiltrank, Alchemistenfeuer
- **Goblin-Schamane:** Heiltrank, Großer Heiltrank
- **Kobold:** Heiltrank, Alchemistenfeuer
- **Skelett:** Heiltrank, Weihwasser
- **Zombie:** Heiltrank, Weihwasser
- **Ghul:** Großer Heiltrank, Weihwasser
- **Ockerschleim:** Großer Heiltrank
- **Riesenspinne (870.6; Feuer verbrennt sie, LISTE-BESTIARIUM.md):** Spinnseide

### Herstellen

- **Morwen:** Heiltrank, Großer Heiltrank, Kräutertrank, Alchemistenfeuer
- **Lagerfeuer:** Gebratenes Fleisch

### Sammeln

- Heilkräuter

### Fund

- Klinge von Bornim, Glutstab, Flüsterklinge, Morgenröte
- **Truhe in der Blutzahnhöhle (cave_3, 870.14):** Die Namenlose, Wolfsspieß, Schwarzeibe, Nachtwache

### Handlung

- Ring des Ältesten, Gwennas Ring, Grauer Fetzen, Rauchbündel
- **Thessa, Auftrag Felle für den Winter (356.2):** Thessas Pelzumhang
- **Borin, Auftrag Hauer für den Schmied (356.2):** Borins Hauerdolch

## Spalten der Datendatei

| Spalte | Pflicht | Bedeutung |
|---|---|---|
| `id` | ja | feste Kennung, klein mit Unterstrich, nie aendern (Spielstaende) |
| `name` | ja | {de, en} |
| `art` | ja | eine aus ARTEN |
| `platz` | nein | eine aus PLAETZE oder null (nicht anlegbar) |
| `stufe` | nein | Heldenstufe ab der erhaeltlich (BRS); null = offen |
| `preis` | nein | Grundpreis in Gold (BRS, vor Ruf); 0 = unverkaeuflich; null = offen |
| `netz` | nein | Modellnetz (455), z. B. Datei im Kaufrepo |
| `material` | nein | Material des Netzes (455) |
| `zeichen` | nein | Zeichnung/Tusche des Netzes (455) |
| `modell` | nein | Quelle und Lizenz des Modells (LISTE-BESTAND.md) |
| `bezug` | ja | Liste von {weg, wo?, rezept?, gold?}; weg aus WEGE; gold = Lohn des Herstellers |
| `zustand` | nein | true = nutzt sich ab (Abnutzung, Reparatur); null = offen |
| `text` | nein | {de, en}, ein Satz (Homer) |
| `grundform` | nein | bei Einzelstuecken: id der Grundform |
| `alt` | nein | Werte der alten Fassung (SRD), gelten nicht; Hilfe beim Uebertragen, faellt mit Stufe 6 |

Arten: waffe, schild, ruestung, schmuck, fokus, licht, einzelstueck, trank, wurf, nahrung, rohstoff, werkzeug, handlung. Plätze: arme, beide_haende, beine, finger, hals, haupthand, kopf, nebenhand, oberkoerper, umhang. Bezugswege: laden, beute, herstellen, sammeln, fund, handlung.
