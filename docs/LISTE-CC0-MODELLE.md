# Freie Modelle und Bewegungen (CC0)

Vorgang 348.12, Sokrates, angelegt am 26.10. Hier steht, was wir von fremder Hand übernehmen, was es kostet und was offen ist. Entschiedenes steht im Vorgangsarchiv, Stand und Zeilen im Vorrat (`ARBEIT-BERATUNG.md`, `ARBEIT-TEAM-JERRY.md`, `ARBEIT-TEAM-TOM.md`).

**Lizenzregel** (`CLAUDE.md` „Technik und Sicherheit“):
- Nur CC0 oder eine Lizenz, die kommerzielle Nutzung und Bearbeitung ohne Pflichten erlaubt.
- Die Lizenz wird je Paket auf der Quellseite geprüft; bei Bearbeitungen auch die des Originals.
- Je Datei werden Quelle, Urheber und Lizenz festgehalten.
- Nie: Quaternius Asset License (QAL), CC-BY-NC, CC-BY-ND, „nur privat“.

## Stand

| Was | Stand | Quelle |
|---|---|---|
| Skelett Menschen (alle Völker) | übernommen: Gerüst der Universal Animation Library, 65 Knochen; Zwerg, Halbling, Elf, Halbork über Knochenlängen | Archiv 348.12 (25.10., 23:33); `LISTE-UMZUG-348.md` Punkt 4 |
| Körper und Kleidung | bleiben unsere eigenen (`held3.py`); der fremde Grundkörper ist rundlich, großer Kopf, passt nicht zu „düster, erwachsen“ | Chefsache 34812-cc0 in Git |
| Bewegungen Menschen | Freifassung im Einsatz (Stehen, Gehen, Rennen, Fackel); Stich, Ausweichen, Abwehr bauen wir selbst | `LISTE-UMZUG-348.md` Punkt 5 |
| Goblin, Grak, Zombie | noch auf eigenem Skelett (`rig.py`); Probe: ein Goblin aufs CC0-Gerüst, wenn Schamane, Kobold und Späher fertig sind; ist er besser, folgen Grak und Zombie | Archiv 348.12 (26.10., 11:33), an Jerry |
| Tiere, Monster | eigenes Skelett je Bauart (Vierbeiner, Vogel, Insekt, Spinne); Suche nach CC0-Modellen läuft (unten) | Archiv 348.12a (26.10., 11:40) |
| Pro-Fassung der Bewegungen | gekauft vom Chef (Vorgangsarchiv 348.12c) | – |

## Bewegungen: Universal Animation Library (Quaternius)

Quellseite: <https://quaternius.itch.io/universal-animation-library>. Lizenz laut Seite: „Creative Commons Zero v1.0 Universal“; die Lizenzdatei im Paket prüft `tools/blender348/v3/cc0_laden.sh`.

| Fassung | Preis | Inhalt |
|---|---|---|
| Standard | frei | 43 Bewegungen im Paket (die Seite nennt 45), etwa 15 MB |
| Pro | ab 9,99 $ | „120+“ Bewegungen, FBX und GLB, auch für Godot; welche genau, sieht man erst nach dem Kauf |
| Source | ab 14,99 $ | dazu die Blender-Datei; brauchen wir nicht |

**Freifassung, ausgelesen 26.10.:**
- **Stehen:** Idle, Idle_Talking, Idle_Torch, Sword_Idle; dazu Sitzen (Ansatz, Halten, Reden, Aufstehen), Hocken (Stand, vorwärts), Tanzen.
- **Fortbewegung:** Walk, Walk_Formal, Jog, Sprint, Sprung (Ansatz, Flug, Landung), Rolle, Schwimmen, Schieben.
- **Kampf:**
  - Sword_Attack, Punch_Jab, Punch_Cross
  - Zauber in vier Teilen (Ansatz, Halten, Wurf, Ende)
  - Hit_Head, Hit_Chest, Death01
- **Sonst:** Interact (Benutzen), PickUp_Table, Fixing_Kneeling.
- **Unbrauchbar:** 7 von 43, nämlich sechs Pistolenbewegungen und das Fahren.
- **Im Spiel heute:**
  - Jede Person hat eine Stehbewegung (5 von 13 Idle_Talking, sonst Idle) und eine Gehbewegung (3 förmlich, sonst normal).
  - Dazu kommen eigene Armhaltungen über der Bewegung: Hände vorn gefaltet, Hände auf dem Rücken, Stab, Last auf der Schulter, Daumen am Gürtel.

**Was fehlt:** Abwechslung, nämlich mehrere Stehvarianten, Gesten (Hände in die Hüfte, Arme verschränken), mehrere Angriffe je Waffe und eigene Treffer und Tode (Chef 26.10., 11:42).

## Eigene Bewegungen: drei Wege

Das Gerüst gehört uns. Jede selbstgebaute Bewegung läuft darauf wie eine gekaufte (Chef 26.10., 11:47: „können wir die Bewegungen nicht selbst bauen … Garrick am Feuer …?“).

1. **Eigene Haltung über eine fremde Bewegung legen.**
   - Das ist billig und läuft schon. Die Bewegung liefert Atmen, Gewicht und Kopf, unser Skript setzt die Arme darüber (`leute.json` „arme“, `geruest.py`).
   - Beispiele: gefaltete Hände, Stab, Speer, Gürtel. Neue Haltungen wie „Hände in die Hüfte“ kosten eine Zeile je Person.
2. **Fremde Bewegung abwandeln.**
   - Garrick am Feuer: Sitzen oder Hocken, dazu Hände zum Feuer (Weg 1).
   - Rowena wischt: „Interact“ wiederholt.
   - Borin hebt den Becher: Sitzen, dazu ein eigener Arm.
3. **Ganz eigene Bewegung im Skript.**
   - So entstand vor dem CC0-Gerüst alles (`rig.py`: Gehen, Stehen, Rennen). Das kostet viele Runden.
   - Der Chef bemängelte: Das Rennen sei „nur beschleunigtes Gehen“, und im Stand zuckten die Figuren alle 3 bis 4 Sekunden.
   - Darum nur für das, was es nirgends gibt; schon festgelegt sind Stich, Ausweichen und Abwehr.

## Wirtschaftlich (Schätzung 26.10.)

**Grundlage:**
- Commits der Zweige `claude/tom-348-fundament` und `claude/jerry-348-kampf` seit 24.10., nach Bewegungswörtern gefiltert: Gehen, Rennen, Zucken, Schritt, Haltung, Hieb, Biss, Sprung, Tod und Ähnliches.
- Die Kosten je Sitzung aus `KOSTEN-GEBUCHT.tsv` sind nach dem Anteil der Bewegungs-Commits verteilt.
- Das ist eine Schätzung, keine Buchung.

| | Sitzungen | Kosten gesamt | davon Bewegung | Sitzungen überwiegend Bewegung |
|---|---|---|---|---|
| Tom | 79 | 685 $ | 160–190 $ | 24 (191 $) |
| Jerry | 82 | 644 $ | 80–90 $ | 11 (89 $) |
| **zusammen** | | | **240–280 $** | rund 35 |

**Gegenrechnung:**
- Pro kostet 9,99 $, das ist etwa eine Sitzung (rund 8 $).
- Ersetzt sie zwei selbstgebaute Bewegungen, hat sie sich bezahlt gemacht.
- Bei 120 Bewegungen, davon geschätzt 60–80 für uns brauchbar, ist der Hebel groß.

**Stärkstes Gegenargument:** Auch gekaufte Bewegungen kosten Anpassung. Ein guter Teil von Toms Kosten nach dem CC0-Wechsel war genau das:
- den Schritt unter langen Röcken dämpfen
- die gehaltenen Arme mitschwingen lassen
- die Füße am Boden halten

Diese Werkzeuge stehen jetzt, darum fällt die Anpassung kleiner aus. Pro spart also den teuersten Teil, die Natürlichkeit, aber nicht alles.

**Folgerung:** Das gesparte Guthaben geht in das, was nur wir können: Gesichter, Kleidung, Welt, Geschichte.

## Tiere und Monster: Suche (348.12a)

Auftrag des Chefs (26.10., 11:40): Hund, Katze, andere kleinere Tiere, die nicht kämpfen, vielleicht ein kleiner Drache, dazu alle Monster; nur CC0, „am Schluss kein Lizenzproblem“.

**Bekannt aus der Sichtung vom 25.10.** (Chefsache 34812-cc0 in Git):
- **Quaternius:** „Ultimate Animated Animals“ und „Animal Pack Vol. 2“ (unter anderem Wolf, Hund, Katze, animiert).
- **KayKit:** Abenteurer und Skelette, sehr niedlich, keine Tiere; Lizenz je Paket prüfen.
- **Kenney:** CC0, Höhlen- und Dorfbausteine, Tiere nur als Würfel.
- Wolf und Ratte stehen bei uns schon, auf eigenem Skelett.

**Suche 26.10.** (Helfer von Sokrates):
- Die Lizenz ist auf jeder Quellseite geprüft. Bei Quaternius ist zusätzlich die License.txt gelesen (Ultimate Animals, Farm, Animated Monsters, Easy Enemy, Ultimate Monsters: alle „CC0 1.0 Universal“).
- „[Bild]“ heißt: Das Vorschaubild ist gesehen; sonst stammt das Stilurteil nur aus der Beschreibung.
- **Bei Übernahme wird die Lizenz je Datei erneut geprüft und festgehalten.** Dreiecke nach dem Import zählen, denn die meisten Quellen nennen keine.

### Dorf- und Kleintiere

| Figur | Fundstelle | Lizenz | animiert | Stil | Eignung |
|---|---|---|---|---|---|
| Hund | Quaternius Ultimate Animated Animals (Husky, ShibaInu), quaternius.com/packs/ultimateanimatedanimals.html | CC0 | über 12 Bewegungen je Tier (u. a. Angriff, Tod, Gehen, Galopp, Sprung), mit Skelett | Low-Poly, glaubwürdige Proportionen [Bild] | gut |
| Katze | Quaternius Animal Pack Vol. 2, opengameart.org/content/animated-animales-low-poly | CC0 | ja | Low-Poly, ungeprüft | mit Umbau |
| Huhn, Hahn | CDmir „Chicken (animated)“, „Rooster (animated)“, opengameart.org/content/chicken-animated | CC0 | ja, mit Skelett | realistisch [Bild] | gut |
| Pferd, Esel | Quaternius Ultimate Animated Animals | CC0 | ja | glaubwürdig [Bild] | gut; Kutsche: Lotnik „horse drawn carriage“, CC0, unbewegt |
| Kuh, Schaf, Ziege | Kuh: Quaternius Ultimate Animated Animals; Schaf: Quaternius Farm Animal Pack; Ziege: tomek „3D goat animation for game“ (OpenGameArt, CC0 zur Wahl) | CC0 | ja (Ziege: Stehen, Gehen, Laufen, Sprung, Fressen, Angriff, Tod) | Farm-Paket eher niedlich [Bild] | gut bis mit Umbau |
| Rabe | Teh_Bucket „Raven“, opengameart.org/content/raven-0 | CC0 | Skelett, Flug; etwa 2000 Dreiecke | schlicht, realistisch [Bild] | gut |
| Frosch | „Frog low poly animated“, opengameart.org/content/frog-low-poly-animated-3d-model | CC0 | ja; 600 Dreiecke | comichaft [Bild] | mit Umbau |
| Libelle | kein CC0-Modell; nur „styly dragonfly“ unter OGA-BY 3.0 (Namensnennung) | – | – | – | Eigenbau |
| Schmetterling | CDmir „Butterfly (animated)“ | CC0 | ja | Low-Poly | gut |
| Fisch | CDmir „Esox“ (Hecht), Quaternius Animated Fish | CC0 | Stehen, zwei Schwimmbewegungen; 1632 Dreiecke | realistisch | gut |
| Maus | „Mouse basemesh“ (noway), unbewegt; etwa 700 Dreiecke | CC0 | nein | Rohform | mit Umbau |
| Kleiner Drache | Drummyfish „Cethiel's Dragon 3D“, opengameart.org/content/cethiels-dragon-3d (Vorlage Cethiels 2D-Drache, ebenfalls CC0) | CC0 | ja, mit Skelett | düster, stachelig [Bild] | gut |

### Monster

| Figur | Fundstelle | Lizenz | animiert | Stil | Eignung |
|---|---|---|---|---|---|
| Wolf, Grimmzahn | Quaternius Ultimate Animated Animals; tomek „3D wolf animation for game“ (CC0 zur Wahl neben GPL) | CC0 | ja | glaubwürdig [Bild] | gut; steht bei uns schon |
| Keiler | Teh_Bucket „Boar“, opengameart.org/content/boar | CC0 | Gehen, Angriff; etwa 1000 Dreiecke | realistisch [Bild] | gut |
| Riesenratte | CDmir „Evil Giant Rat“, opengameart.org/content/evil-giant-rat | CC0 | ja | düster, realistisch [Bild] | **sehr gut**; steht bei uns schon |
| Riesenspinne | CDmir „Alien Bug Animated“ (Skorpionschwanz); br-n518 „Spider“ (222 Dreiecke) | CC0 | Stehen, Laufen, zwei Angriffe | [Bild] | mit Umbau |
| Riesenfledermaus | rubberduck „Vampire Bat (Animated)“, opengameart.org/content/vampire-bat-animated | CC0 | ja; 7732 Dreiecke | realistisch [Bild] | gut, vereinfachen |
| Ockergallerte | PINKCANNON „Slime“; Quaternius Animated Monster Pack | CC0 | ja | niedlich [Bild] | Eigenbau einfacher |
| Skelett | KevDev „Skeleton Outlaw“, opengameart.org/content/skeleton-outlaw-3d-character | CC0 (die Fassung im Unity-Store ist eine andere, bezahlte) | 13 Bewegungen (3 Stehen, 3 Angriffe, 2 Treffer, 2 Tode …); 6174 Flächen | handgemalt, Comic, Irokese [Bild] | mit Umbau |
| Zombie | Rikindle3D „Male City Zombie“; Quaternius Animated Zombie | CC0 | 2 Gehen, 3 Angriffe, Tod, Schrei … | realistisch, heutige Kleidung [Bild] | mit Umbau |
| Goblin | CDmir „Goblin“, opengameart.org/content/goblin-1 | CC0 | ja, mit Skelett | düster, realistisch [Bild] | gut (Vergleich mit unserem Goblin r6) |
| **Fehlt ganz** | Kobold, Grottenschrat (Krogg), Ghul, Stirge, Riesen-Hundertfüßer, Goblin-Schamane (Danimals Schamane ist CC-BY-SA, ausgeschlossen); Hobgoblin nur CC-BY | – | – | – | Eigenbau; Menschenartige auf dem CC0-Gerüst |

### Skelette je Bauart

| Bauart | Fundstelle | Lizenz | Bemerkung |
|---|---|---|---|
| Vierbeiner | Blender-Rigify, Vorlagen Vierbeiner, Katze, Wolf, Pferd | Rigify selbst ist GPL; das damit Erzeugte gehört uns, laut blender.org: „What you create with Blender is your sole property“ | Das Steuerskript `rig_ui.py` fällt wohl unter GPL, kommt aber nicht mit ins GLB. Nicht juristisch geprüft. |
| Vierbeiner (fertig) | crownjoshua „Wolf Low Poly (Rigged)“; „Rigged Horse“ (Pferd von Lyndon Daniels, CC0) | CC0 | – |
| Vogel | Teh_Bucket „Raven“; pistachio „Bird (Yellow-Billed Shrike)“ | CC0 | – |
| Insekt | MikeMoon „3D Hornet/Wasp“ | CC0 | auch Grundlage für die Stirge |
| Spinne | br-n518 „Spider“, CDmir „Alien Bug“ | CC0 | Skelett ohne Körper nicht gefunden |

### Lizenzfallen

1. **Quaternius ist nicht alles CC0:** Das neue „Bestiary – Dungeon Monsters Kit“ (Lycan, Goblin, Skelett) steht unter der QAL (Fassung vom 28.08.2026). Die übrigen 20 geprüften Quaternius-Seiten verlinken CC0. In der Freifassung stecken nur 60–70 % des Inhalts, den Goblin des Monsterpakets gibt es nur über Patreon.
2. **Remixe:** „WarWolf“, „Hazmat zombie“ und „Skeleton with rig“ stammen von Blendswap-Vorlagen mit ungeprüfter Lizenz, darum nicht nutzen. Danimals Modelle sind CC-BY-SA, ausgeschlossen.
3. **Mehrfachlizenz:** Bei tomek ist CC0 eine von mehreren Wahlmöglichkeiten. Wir wählen CC0 und halten das fest.
4. **Ausgeschlossen:**
   - „free personal and commercial“ ohne Lizenzname (ManNeko „Low Poly Wolf“)
   - „Quadruped Metarig“ (ohne Lizenz)
   - Hobgoblin von VWolfdog (CC-BY 3.0)
5. **Ungeprüft:** Poly Pizza und die itch.io-Suche sperren den Abruf. Sketchfab mit dem Filter CC0 liefert fast nur Scans ohne Skelett. Universal Animation Library 2 (über 130 Bewegungen) ist ebenfalls CC0; was davon frei ist, ist noch nicht geprüft.

### Folgerung (Sokrates)

- **Gut abgedeckt:** Dorftiere (Quaternius), Wolf, Keiler, Ratte, Rabe, Huhn, Fisch, Fledermaus, kleiner Drache, Goblin.
- **Am glaubwürdigsten:** CDmir, Teh_Bucket, die Vampirfledermaus und Cethiels Drache. Die Monsterpakete von Quaternius, KayKit und Kenney sind zu niedlich.
- **Eigenbau bleibt:** Kobold, Krogg, Grak, Ghul, Stirge, Hundertfüßer, Schamane, Libelle, Gallerte. Menschenartige entstehen auf dem CC0-Gerüst.
- **Nächster Schritt** (nicht entschieden): Eine Probe mit CDmirs Goblin und Teh_Buckets Keiler in unserem Look, neben Jerrys Goblin r6 und Wildschwein r3. Erst nach dem Bild entscheidet der Chef, ob wir übernehmen. Vorschaubilder der Suche liegen nicht im Repo, sie gingen mit der Sitzung verloren; die Quellseiten zeigen sie.

## Gegen Geld (348.12c)

Auftrag des Chefs (26.10., 11:59): Pakete auch gegen Geld, wenn der Verkauf des Spiels erlaubt ist; Monster dürfen von D&D abweichen. Entschieden: Vorgangsarchiv 348.12c (Chefsache 34812c in Git). Suche durch vier Helfer am 26.10.; [G] = Quellseite selbst gelesen, [S] = gefolgert oder nur Suchtreffer.

**Lizenzen** (entscheidende Sätze im Wortlaut):
- **QAL v1.0** (quaternius.com/license.html, Stand 28.08.2026) [G]: Verkauf frei („sell … without owing us any fee, royalty, or credit“), keine Namensnennung, keine Engine-Bindung, unbefristet; verboten: Weitergabe der Dateien als Asset, „regardless of how much the Assets have been modified“. Es gilt die Fassung zum Zeitpunkt des Downloads.
- **Synty EULA** (Stand 09.07.2026) [G]: „not limited by game engine“, je Kauf 5 Plätze, Quelldateien nicht außerhalb des Teams. **SyntyPass (Abo):** nach Ende keine neue Arbeit mit den Assets („substantially developed … required to have an active Subscription“), also nur Einzelkauf.
- **Unity Asset Store** [G]: andere Engines erlaubt (Hilfeseite Unity), „Extension Asset“ = ein Platz, höchstens 2 Rechner; Ausnahme „Restricted Assets“.
- **Fab Standard** [S, EULA gesperrt]: nicht auf Unreal beschränkt, außer „UE-Only“.
- **Sketchfab Standard** [G]: Engine frei, Verkauf ja, nicht als Einzeldatei weitergeben; „Editorial“ verbietet Verkauf.
- **Protofactor EULA** [G]: verkaufte Echtzeitanwendungen frei, „single computer“; Lieferung als Unity-, UE4-Paket und Rohdateien.
- **RenderHub „Extended Use“** (MadeCG) [G]: Handyspiele ausdrücklich, Firma, unbegrenzt.
- **Mixamo** [S, Adobe-Seite gesperrt]: Spiele frei, nur Rohdateien nicht weitergeben; nur Zweibeiner.
- **Alle außer CC0 verbieten die Weitergabe der Rohdateien**; unser Repo ist öffentlich (109). Bezahlte Rohdateien nur in ein privates Repo.

**Kandidaten:**

| Modell | Anbieter, Preis | Dreiecke | Bewegungen | Stil | Eignung |
|---|---|---|---|---|---|
| Riesenratte | Protofactor 14,99 $ | 7.650 | 18 | düster, rote Augen | sehr gut |
| Riesenspinne | Protofactor „Darkness Spider“ 19,99 $ | 6.200 | 22 | düster | sehr gut |
| Ghul | Protofactor 24,99 $ | 19.200 | 33 | düster | gut, ausdünnen |
| Skelett | Protofactor Skelettritter 24,99 $ | 10.600 | 62 | düster | gut, ausdünnen |
| Zombie | Protofactor „Undead“ 34,99 $ | 24.600 | 55 | düster | gut, stark ausdünnen |
| Keiler | Protofactor 14,99 $ | 9.550 (Stufe 4.970) | 24 | realistisch | sehr gut |
| Wolf; „Fantasy Wolf“ als Grimmzahn | Protofactor 14,99 $ je | 10.100 (Stufe 5.300); 7.560 | 29 | realistisch | sehr gut |
| Goblin, Kobold, Hobgoblin | Protofactor 24,99 $ je | 13.000–29.200 | 30–82 | Warcraft-Comic | nein |
| Riesenfledermaus | Protofactor 24,99 $ | 13.100 | 28 | fast komisch | nein |
| Tiere (Wolf, Keiler, Kuh, Ziege, Huhn, Frosch, Fisch, Ratte u. a., 26) | Janpec Animal Pack Deluxe 5 $ (Unity) | Wolf etwa 5.600 [S] | Stehen, Gehen, Laufen, Fressen, Angriff, Tod | naturalistisch | gut |
| Hundertfüßer | MadeCG 14 $ (Rabatt bis etwa 27.10., sonst 20 $) | 660 Polygone | 6 | glaubwürdig, schlicht | einzige Quelle |
| Wolf, Keiler, Krähe, Hund, Katze, Huhn | MadeCG 5–13 $ | 160–2.450 Polygone | 5–10 | schlicht, ältere Handygrafik | Ersatz |
| Goblin, Ghul („Rake“) | HATOGAME, Sketchfab, je etwa 20 $ | 7.000; 4.400 | 9–10 | grimmig | Reserve |
| Bestiary: Imp, Puglin, Skelett, Lycan, Dämonenritter, Koloss | Quaternius, Source 20 $ (frei nur Imp, Puglin), QAL | ungenannt | keine (UAL nötig) | bunt, comichaft | nein |
| Skelette, Goblins, Geister | Synty Dungeon 149,99 $, Dark Fantasy 100 $ | ungenannt | keine | Spielzeug, Flachfarben | nein |
| Wald-Kit (Wolf, Keiler, Bär, Reh) | Silver Delivery, itch 4,99 $ | 1.000–1.600 | 36 | ernst | Lizenz fehlt auf der Seite |
| Skelette, Zombies | Hotstrike, itch je 9,99 $ | ungenannt | 5 | comicartig; Bewegungen passen laut Käufer in Godot nicht | nein |
| KayKit, Dungeon Mason, Overaction, Meshtint, Standout 7, SheepInTry, Infinity PBR | 0–70 $ | – | – | niedlich, bunt oder nur Unity-Paket ohne Lizenz | nein |

**Nicht gefunden:** Goblin-Schamane, Bugbear, Stirge, Ockergallerte, Libelle in passendem Stil. CGTrader, TurboSquid, Humble Bundle, Fab und Poly Pizza sperrten den Abruf.

**Folgerung (Sokrates):** Protofactor ist der einzige Anbieter mit durchgehend düsterem, glaubwürdigem Stil, aber für den PC gebaut. Erst eine Probe (Ratte, 7.650 Dreiecke, kaum Ausdünnen), dann der Rest. Ghul und Hundertfüßer im Abschnitt „Folgerung“ oben (Eigenbau) sind damit überholt, falls der Chef 348.12c b billigt.
