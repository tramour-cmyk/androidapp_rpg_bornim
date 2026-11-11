# Effekte im Spiel (Zuordnungsseite)

Vorgang 623, Sokrates, angelegt 07.11. (Chef 07.11., 17:2x). Hier steht **je Anlass**, welcher Effekt ihn zeigt und woher er kommt, damit niemand selbst baut, was wir haben, und jeder Held, jedes Monster, jeder Ort jedes Mal gleich aussieht. Paketnummern R1–R11: `LISTE-QUELLEN.md`. **Gekauft (09.11.):** R1–R4, R7–R11 und Status Effects; Namen der Effekte unten gegen die Pakete geprüft (21:08); R5, R6 zurückgestellt, Ersatz eingetragen. **Stand je Zeile: Vorschlag**, bis die Probe am Handy bestanden ist; dann trägt der Einbauende die Datei des Effekts ein und setzt „gilt“.

**Regel (Vorschlag 623):** Vor jedem Eigenbau eines Effekts, Shaders oder Teilchens hier und in `LISTE-BESTAND.md` nachsehen. Was hier steht, steht auch in den Daten (Feld `fx` je Waffe, Zauber, Zustand, Monster in `regeln/tabellen.json` bzw. der Monsterliste), nicht verstreut im Code. Ein neuer Effekt bekommt zuerst eine Zeile hier.

**Reihenfolge (623.8 A, Chef 09.11., 22:23):** Szene für Szene, je eine Testbitte; Farben gedämpft (kein Leuchtbunt, Gold nur wo Licht ist), Bilder/s vor und nach messen, nie schlechter als heute, jeder Effekt an der Grafikstufe (698).
1. **Dorf am Abend** (Tom, 816): Kaminrauch (R7 chimney_smoke), Fackeln an Schlagbaum und Schenke (R7 torch_flame; Kaminfeuer eigen), Staubflocken in Schenke und Laden (R7 dust_motes), Fußstaub (R7 footstep_dust), Fahne (R11), Wind für Gras und Bäume, Gras weicht aus (R9, mit 804), Federn beim Huhn (R4 feather_burst); dazu (Chef 22:26): Bach und Fluss (R10 river, gegen `wasser.gdshader` vergleichen), Wiese (R9), Wege und Felsen mit Oberfläche (R11 Surface, Stylized Rock; Felsen aus dem Nature MegaKit), Schmetterlinge über der Wiese (Janpec Schmetterling `fly_cycle`, nur bei Tag; abends Glühwürmchen 514; Lizenz wie Wolf, 780 offen).
2. **Wolfskampf** (Jerry, 623.2): R3 steel_slash, R4 blood_hit, R7 parry_block, R3 dash_wind, R7 critical_hit, R7 dust_impact.
3. **Wald und Höhle** (Tom Wald, Jerry Höhle 623.2): Nebel (R8), Laub (R7 falling_leaves), Geisterlichter an Morwens Hütte (R4 spirit_wisps), Teich (R10), Kristalle (R4 crystal_growth). Regen und Sturm: eigene Vorlage. Nicht in dieser Runde: R5, R6, Wetter, Zauber über Stufe 1.

## Kampf: Treffer, Waffen, Bewegung

| Anlass | Effekt (Vorschlag) | Quelle | Stand |
|---|---|---|---|
| Hieb mit Klinge (Schwert, Dolch, Axt) | Klingenspur + Hiebbogen | R3 Steel Slash, R1 Slashes | Vorschlag |
| Wucht (Keule, Morgenstern, Hammer) | Aufprall mit Staub | R1 Impacts | Vorschlag |
| Treffer am Körper | Blut-Treffer, Trefferblitz am Getroffenen | R4 blood_hit; Trefferblitz eigen (Material kurz aufhellen) | Vorschlag |
| Kritischer Treffer | großer Aufprall, kurzer Halt | R1, R7 critical_hit | Vorschlag |
| Parade, Block mit Schild | Funken am Schild | R7 parry_block, R1 | Vorschlag |
| Fehlschlag, Ausweichen | Luftzug | R3 Dash Wind | Vorschlag |
| Pfeil (Späher, Garrick, Held mit Bogen) | Pfeilspur, auch beim Fehlschuss | R3 Arrow Streak | Vorschlag (601) |
| Sterben | Todesstoß bei Untoten, Auflösen bei Geistern; Tiere ohne Effekt (Bewegung, 596) | R4 death_burst; Geister verwehen mit R4 spirit_wisps | Vorschlag |
| Ansage eines harten Schlags | Fläche am Boden | AoE Telegraphs (ungeprüft) oder R1 AoE | Frage |

## Zauber (Liste 2.17) und Zustände

| Anlass | Effekt (Vorschlag) | Quelle | Stand |
|---|---|---|---|
| Feuerpfeil, Feuerball | Feuer: Wirken an der Stabspitze, Flug, Einschlag | R2 fire | Vorschlag (385.2) |
| Magisches Geschoss | Arkan | R2 arcane | Vorschlag |
| Heilige Flamme, Untote vertreiben | Heilig, heiliger Strahl | R2 holy, R7 holy_light | Vorschlag |
| Heilung, Heiltrank | Heilband, Heilschein | R4 heal_beam, R7 heal | Vorschlag |
| Kältestrahl, Frost | Eis, Frostnova | R2 ice, R7 frost_nova | Vorschlag |
| Gift, Säure | Säure | R2 acid | Vorschlag |
| Vergiftet, Betäubt, Verlangsamt, Gestärkt | Zustand am Körper | Status Effects (415d.1), R7 stun_stars | Vorschlag |
| Im Schatten (Späher) | blass, Schatten | R7 shadow_burst beim Verschwinden, blass eigen (Material) | Vorschlag (566) |
| Gefroren, versteinert | Körper vereist oder grau | R7 ice_burst; versteinert eigen (Material grau) | Vorschlag |
| Wiederkehr im Tempel | Licht | R7 resurrect | Vorschlag |

## Monster von Kapitel 1

| Monster | Angriff | Besonderes | Quelle | Stand |
|---|---|---|---|---|
| Wolf, Jungwolf, Grimmzahn | Biss: Aufprall klein | Anspringen: Staub beim Aufprall | R1 | Vorschlag |
| Riesenratte, Riesenfledermaus | Biss klein | – | R1 | Vorschlag |
| Wildschwein | Hauer | Ansturm: Staubspur | R3 Dash Wind, R7 footstep_dust | Vorschlag |
| Riesenegel | Biss | **Blutsaugen**: Strahl zum Egel | R4 Drain Beam | Vorschlag |
| Säureschnecke, Ockergallerte | Säure | Schleim am Boden | R2 acid, R11 Toxic Ooze | Vorschlag |
| Riesenspinne | Biss | Netzwurf: Flug, Einschlag | R2 nature | Vorschlag |
| Goblin-Späher | Pfeil | Schatten | R3 arrow_streak, R7 shadow_burst | Vorschlag |
| Goblin-Schamane | Zauber | Wirken | R2 void oder nature | Frage (Homer: Art seiner Magie) |
| Krogg | Morgenstern | schwerer erster Schlag: Bodenstoß; Rauchbündel (Morwen) | R1 AoE, R7 | Vorschlag |
| Grak | Axt | – | R3, R1 | Vorschlag |
| Skelett, Zombie, Ghul (506) | – | Todesstoß, Geisterlichter | R4 | Vorschlag |

## Orte und Welt

| Ort | Effekt (Vorschlag) | Quelle | Stand |
|---|---|---|---|
| Dorf | Kaminrauch, Fackeln, Fahne im Wind, Hühner flattern (591) | R7 chimney_smoke, torch_flame, R11 Flag, R4 Feather Burst | Vorschlag; eingebaut `skripte/dorfeffekte.gd` (814, Zweig `claude/tom-814-dorfeffekte`), dazu R7 footstep_dust auf Erdwegen |
| Schenke, Häuser innen | Staub im Licht, Kerzen (eigene Flamme bleibt) | R7 dust_motes | Vorschlag (590); Schenke und Laden eingebaut `skripte/dorfeffekte.gd` (814) |
| Tempel | Glühende Runen, Licht der Wiederkehr | R11 Glowing Runes, R7 | Vorschlag |
| Flüsterwald | Blätter im Wind, Gras weicht aus, Glühwürmchen (eigen, 514) | R8, R9 | Vorschlag |
| Tiefer Wald, Morwens Hütte | Nebel, Geisterlichter, Rauch der Hütte | R8 fog, R4 Spirit Wisps, R7 | Vorschlag |
| Steinkreis (Jorins Auftrag) | Runen glimmen | R11 Glowing Runes | Vorschlag |
| Blutzahnhöhle | Teich, Tropfen, Kristalle, Fels | R10 pond, R4 Crystal Growth, R11 Stylized Rock | Vorschlag (507, 492) |
| Wetter je Ort | Regen, Sturm mit Blitz, Nebel; ein Wind für Gras, Bäume, Klang | R8, R9; Klang 598 | Frage (neues Spielgefühl) |
| Bach, Fluss | Fluss des Kits statt `wasser.gdshader`, wenn die Probe am Dorfbach besser ist (Chef 07.11.: „ernsthaft etwas besser“) | R10 river | Vorschlag (Probe) |
| Gras, Blumen | Gräser, Blumen, Windrichtungen, Ausweichen des Kits statt `halm.gdshader`, wenn die Probe im Flüsterwald besser ist (Chef 07.11.: „sah schon wirklich sehr gut aus“) | R9 | Vorschlag (Probe) |
| Lagerfeuer (Garrick), Kamin | eigene Flamme bleibt (Signatur), Funken und Rauch dazu | eigen + R7 campfire | Vorschlag |
| Leuchtfunke über dem Kopf (84.5, 677) | kühl weißer Kern mit Hof, treibt und wippt, Licht nur im Dunkeln, im Raum auf Schulterhöhe (wie alt `WorldScreen.kt` 1443) | eigen (`held.gd` baue_funke) | gebaut, Zweig `claude/tom-677-funke` |

## Zustände im Kampf gegen Status Effects (623.5, Jerry 08.11.)

Zustände des Spiels aus `godot/regeln/mars.gd` STATUS; volles Paket Status Effects (23 Effekte, Liste von der Händlerseite 08.11.), Gratisprobe nur Armor Up, Poisoned, Buff Gain. Bluten (Chef 13:09 „Visualisieren wir … Bluten?“): im vollen Paket als „Bleeding“; in der Probe 623.5 zeigt der kritische Treffer das Element Blut aus Combat VFX Mega (R1).

| Zustand im Spiel | Effekt im vollen Paket | in der Gratisprobe |
|---|---|---|
| Vergiftet (POISON) | Poisoned | ja |
| Blutend (BLEED) | Bleeding | nein (Treffer mit Element Blut, R1) |
| Brennend (BURN) | keiner; Feuer aus R1/R2 am Körper | nein |
| Betäubt (STUN) | Shocked oder Confused; R7 stun_stars | nein |
| Verlangsamt (SLOW) | Chilled | nein |
| Geschwächt (WEAK) | Weakened | nein |
| Geblendet (BLIND) | keiner (Cursed am nächsten) | nein |
| Betrunken (DRUNK) | keiner (Confused am nächsten) | nein |
| Gestärkt, Segen, Rüstung (Zauber) | Blessed, Armor Up, Buff Gain | Armor Up, Buff Gain |
| Im Schatten (566) | keiner; R7 shadow_burst beim Verschwinden, blass eigen (Material) | nein |
