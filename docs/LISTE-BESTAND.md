# Bestand (Inventur)

Vorgang 377.1, Stand 27.10., 14:36. Hier steht nur, was wir **besitzen**: gekauft oder heruntergeladen und abgelegt (privates Repo, Zweig) oder laut Prüfung heruntergeladen. Suchergebnisse und Kaufkandidaten stehen in `LISTE-CC0-MODELLE.md`, nicht hier.

- **Vor jedem Eigenbau hier nachsehen** (Regel „Bestand zuerst“, `ROLLE-ENTWICKLUNG.md`, 377).
- Wer hochlädt oder herunterlädt, trägt im selben Schritt hier ein (Teil, Datei, Ort, Lizenz, Format).
- **Privat** = privates Repo `tramour-cmyk/bornim-kaufmodelle`, Version `stufe1`, Anhänge (Zugang `add_repo`, Abruf `gh api …/releases/assets/<id>` mit `Accept: application/octet-stream`; alles auf einmal: `tools/blender348/kauf_laden.sh` im Zweig `claude/tom-348-fundament`). Rohdateien außer CC0 nie ins öffentliche Repo.
- **itch** = frei bei quaternius.itch.io, nicht abgelegt; Abruf wie `tools/blender348/v3/cc0_laden.sh`.
- Mit Skelett nur glTF/GLB verwenden, nie FBX (Herstellerhinweis Quaternius, Maßfehler).

## Bewegungen

### Menschen: Quaternius Universal Animation Library (UAL1, Gerüst 65 Knochen wie unsere Leute)

| Fassung | Datei (Asset-Id) | Ort | Lizenz | Format |
|---|---|---|---|---|
| Pro, 120 Bewegungen | `Universal.Animation.Library.Pro.zip` (678371987) → `Unreal-Godot/UAL1.glb`, `UAL1_RM.glb` (mit Wurzelweg) | privat | CC0 (`License.txt`) | GLB, FBX (Unity) |
| Standard, 43 (Teilmenge von Pro) | `…Standard.zip` (678372635) → `UAL1_Standard.glb`; auch itch | privat, itch | CC0 | GLB, FBX |
| Source | `…Source.zip` (678371339): `UAL1.blend`, `UAL1(_RM).glb`, `root_motion_toggle.py` | privat | CC0 | .blend, GLB |

Namen aus `UAL1.glb` (Pro); `_Loop` weggelassen; **fett** = auch in Standard.

| Gruppe | Bewegungen |
|---|---|
| Stehen | **Idle**, **Idle_Talking**, **Idle_Torch**, Idle_LookAround, Idle_Tired, Idle_Paper/Rock/Scissors, Turn90_L/R, **A_TPose** |
| Sitzen, Hocken | **Sitting_Enter/Exit/Idle/Talking**, Sitting_Idle02/03, Sitting_Nodding; GroundSit_Enter/Idle/Exit; **Crouch_Idle**, **Crouch_Fwd**, Crouch_Enter/Exit, Crouch_Bwd(_L/_R), Crouch_Fwd_L/R, Crouch_Left/Right |
| Fortbewegung | **Walk**, **Walk_Formal**, **Jog_Fwd**, Jog_Fwd_L/R/LeanL/LeanR, Jog_Bwd(_L/_R), Jog_Left/Right; **Sprint**, Sprint_Enter/Exit; **Jump_Start/Loop/Land**, BackFlip, **Roll** (Salto); Crawl_Enter/Idle/Fwd/Bwd/Left/Right/Exit; Climb_Enter/Idle/Up/Down/Left/Right/Exit, ClimbLedge; **Swim_Idle**, **Swim_Fwd**; **Push**, Push_Enter/Exit |
| Kampf | **Sword_Idle**, **Sword_Attack**, Sword_Attack_Standing, Sword_Enter/Exit; **Punch_Jab**, **Punch_Cross**, Kick, PunchKick_Enter/Exit; Dodge_Left/Right; **Spell_Simple_Enter/Idle/Shoot/Exit**, Spell_Double_Enter/Idle/Shoot/Exit |
| Treffer, Tod | **Hit_Chest**, **Hit_Head**, Hit_Stomach, Hit_Shoulder_L/R; **Death01**, Death02 |
| Alltag, Gesten | **Interact**, **PickUp_Table**, PickUp_Kneeling, **Fixing_Kneeling**, Drink, Counter_Enter/Idle/Show/Give/Angry/Exit (Theke), Celebration, Crying, **Dance** |
| Unbrauchbar | **Pistol_Idle/Aim_Up/Neutral/Down/Shoot/Reload**, **Driving** |

**Fehlt** (Tom 27.10.): Stich, Schildabwehr, gehaltenes Ausholen; je Waffe nur ein Angriff.

### Menschen: Protofactor Animset Wizard (385, gekauft 27.10., 21:10)

| Datei (Asset-Id) | Ort | Lizenz | Format |
|---|---|---|---|
| `ANIMSET.WIZARD.unitypackage` (682733782, 170 MB) | privat | Unity Asset Store EULA | Unity-Paket (tar.gz, ohne Unity entpackbar); 105 FBX: `Humanoid@<Bewegung>Wizard.fbx`, dazu `SK_Protof-Actor.fbx` (Körper), `Protof-Actor@WizardAnimset.fbx` (alle in einer Datei), `SM_WizardStaffProp.fbx` (Zauberstab) |

Bewegungserfassung (Motion Capture), Unity „Mecanim Humanoid“. Gerüst `SK_Protof-Actor` nach 3ds-Max-Biped-Art (Pelvis, Spine/Spine1/Spine2, Neck, Head, Clavicle, UpperArm, Forearm, Hand, Finger0–42, Thigh, Calf, Foot, Toe0; aus den Knochennamen gelesen 27.10.): auf unsere Körper (UAL-Gerüst, 65 Knochen) nur über Zuordnung je Knochen in Godot übertragbar, ungeprüft (Tom, 385). Ausgelesen aus den Dateinamen 27.10., 21:1x; „(+RM)“ = zusätzlich mit Wurzelweg.

| Gruppe | Bewegungen |
|---|---|
| Stehen | Idle, IdleLookAround |
| Zaubern | CastSpell1 bis CastSpell14 (14 verschiedene) |
| Fortbewegung | Walk Forward/Backwards/Left/Right und schräg (8 Richtungen), Run ebenso, RunFast, Sprint (alle +RM) |
| Hocken | CrouchIdle, CrouchIdleLookAround, Crouch in 8 Richtungen (+RM) |
| Ausweichen | DodgeLeft, DodgeRight (+RM) |
| Treffer | GetHit Front/Back/Left/Right je Light und Heavy, dazu FrontLight2, BackLight2 (Heavy +RM) |
| Tod, Liegen, Aufstehen | Death Front/Back/Left/Right; Dead Front/Back/Left/Right (liegend); GetBackUp Front/Back/Left/Right |

### Was wir mit Bewegungen abdecken (Stand 27.10., 21:1x)

| Bedarf | Quelle im Bestand | Lücke |
|---|---|---|
| Leute im Dorf: Stehen, Gehen, Reden, Sitzen, Theke, Trinken, Arbeiten | UAL | Gesten (Hüfte, Arme verschränkt), Frauen-Gang |
| Rast, Lagerfeuer | UAL (GroundSit) | Feuer anzünden, Schlafen |
| Held Schwert | UAL (ein Angriff) | Stich, Schildabwehr, gehaltenes Ausholen, mehrere Angriffe |
| Held Zauber (Magier, Kleriker), Goblin-Schamane | Wizard (14 Zauber), UAL (Spell_Simple, Spell_Double) | – (Übertragung ungeprüft) |
| Bogen (Späher, Waldläufer) | – | ganz |
| Ausweichen, Treffer, Tod beim Menschen | Wizard (je Richtung), UAL (Hit, Death, Dodge) | – (Wizard ungeprüft) |
| Ratte | Protofactor Ratte (18) | – |
| Wolf, Wildschwein, Bär, Hirsch, Kaninchen u. a. | Janpec (je etwa 5–9) | Ausweichen, Treffer je Richtung |
| Hundertfüßer | MadeCG (6) | – |
| Goblins, Kobold | CC0-Gerüst mit UAL | – |

### Tiere und Monster (Bewegungen je Tier unten)

| Paket | Datei (Asset-Id) | Ort | Lizenz | Format |
|---|---|---|---|---|
| Protofactor Riesenratte | `GIANT.RAT.RAW.FILES.rar` (678372860), `GiantRat.4.14.rar` (678370352, Unreal), `GIANT_RAT_ASSET.rar` (678371040, enthält `GIANT_RAT_PACKAGE.unitypackage`) | privat | Protofactor EULA | FBX je Bewegung, Unreal, Unity; RAR (Entpacken: `unar`) |
| Janpec Animal Pack Deluxe | `Animal.pack.deluxe.unitypackage` (678515204, 324 MB) | privat | Unity Asset Store EULA | Unity-Paket (tar.gz, ohne Unity entpackbar, `kauf_laden.sh`); FBX: `Models/<Tier>_Rig.fbx`, je Bewegung `Animations/<Tier>_<Bew>.fbx` |
| MadeCG Hundertfüßer | `low.poly.animated.centipede.zip` (678369839) | privat | RenderHub Extended Use | innen je Zip: FBX, OBJ, .blend, Maya, 3ds Max, Unreal, Unity; je Bewegung eine Datei (`fbx/walk.FBX` …), Netz `skin` |
| Animated3D Leopard-Mischwesen (Leopard Hybrid A2, RenderHub) | `leopard.hybrid-a2.zip` (685443057, 768 MB) | privat | RenderHub Extended Use (Volltext prüfen) | innen je Zip: `Blender.zip` (.blend 3.6), `FbxBlender`/`FbxUnity`/`FbxUE5` (ein FBX, alle Bewegungen), `FbxC4D`/`Fbx3DSmax`/`FbxMaya` (je Bewegung eine Datei), `Iclone8_CC4`; `Textures_A2.zip` (PNG 4096: diffuse, normal, height, ao, opacity); Film `Leopard_Hybrid_A12.mp4` |

## Figuren (Menschen, Kleidung)

Alles Quaternius, CC0 (`License_Source.txt`/`License_Standard.txt` geprüft), Gerüst 65 Knochen, ohne Bewegungen (UAL dazu). Source-Fassung enthält alles der Standard-Fassung.

| Teil | Datei (Asset-Id), Pfad im Zip | Ort | Format |
|---|---|---|---|
| Grundkörper Regular, Teen, Superhero je Male/Female; `_FullBody`, `_UpperBody`, `_OnlyHead` (Superhero ohne OnlyHead) | `Universal.Base.Characters.Source.zip` (681384045) → `Base Characters/Exports/Godot - UE/` | privat | glTF; .blend je Körper |
| Haare: Balding, Beard, Bob, Buns, Buzzed(Female), Dreads, Long, LongDreads, Mohawk, Moustache, MuttonChops, Ponytail(_2), SimpleParted, SlickBack; Augenbrauen Regular, Female, Thick, Teen; je auch `_Teen` | dasselbe Zip → `Hairstyles/Rigged to Head Bone/glTF (Godot -Unreal)/Male|Female/` (auch `Origin at 0`) | privat | glTF; .blend |
| Standardfassung (nur Superhero-Körper, 6 Haare) | `Universal.Base.Characters.Standard.zip` (681382172) | privat, itch | glTF, FBX |
| Ganze Trachten: Knight, Knight_Cloth, Noble, Peasant, Ranger, Wizard je Male/Female; `All_Male`, `All_Female` | `Modular.Character.Outfits.-.Fantasy.Source.zip` (681373666) → `Exports/glTF (Godot-Unreal)/Outfits/` | privat | glTF; `All_Male/Female.blend` |
| Einzelteile je Tracht: Arms, Body, Legs, Feet; Knight: Body_Armor/Cloth, Head_Armet, Head_Horns, Pauldron(s)_Round/Spike, Scarf; Noble: Head_Crown, Gorget, Pauldron(_Lion); Ranger: Head_Hood, Pauldron(s), Feet_Boots | dasselbe Zip → `…/Modular Parts/` | privat | glTF |
| Standardfassung (nur Peasant, Ranger) | `Modular.Character.Outfits.-.Fantasy.Standard.zip` (681370524) | privat, itch | glTF, FBX |

**In Gebrauch** (348.12 Grak, Jerry 28.10., `grak_gestalt.py`, Abruf `cc0_laden.sh`): Superhero_Male_FullBody (nur Kopf, Hals, Brustansatz), Male_Ranger ohne Kapuze (Pauldron gespiegelt), Texturen T_Superhero_Male_Dark, T_Regular_Male_Dark_BaseColor, T_Ranger_BaseColor, T_Eye_Brown (umgefärbt); UAL Standard Idle_Loop „Stehen“, Walk_Loop „Gehen“, Hit_Chest „Treffer“; UAL Pro Death02 „Tod“ (`UAL=`).

## Tiere und Monster

**Protofactor Riesenratte** (privat, siehe oben; im Einsatz Probe 348.12f, `kaufratte.py`): Idle, Walk, Run, Taunt, DodgeLeft/Right/Backwards, JumpBite, GetHitFront/Left/Right, Death; Walk, Run, Dodge*, JumpBite auch `_RM`; dazu `GIANT_RAT@AllAnimations.FBX`. Texturen Fell (tga, png).

**MadeCG Hundertfüßer** (privat): idle, walk, alert, attack, hit, die (6).

**Animated3D Leopard-Mischwesen** (privat, Chef 28.10., 16:38; Idee Gegner ab Kapitel 2, `LISTE-IDEEN.md`): Atk1, Atk2, Idle1, Idle2, Jump, Run, Walk, Walkback (8, 60 fps, laut Herstellerblatt); Treffer und Tod fehlen. 22.848 Punkte, 20.820 Flächen (Regel höchstens 6000, ausdünnen).

**Janpec Animal Pack Deluxe** (privat, 25 Tierarten, 36 Fertigteile mit Farbvarianten; FBX, Namen aus Dateinamen):

| Tier | Bewegungen |
|---|---|
| Wolf | IdleA/B/C, Walk, Run, Attack, Eat, Howl, Die |
| Wildschwein (WildBoar) | Idle, Walk, Run, Attack, Eat, Die |
| Braunbär (Bear) | Idle, Walk, Run, Attack, Eat, Die |
| Rind (Cattle; Kuh, Stier) | Idle, Walk, Run, Attack, Eat, Die |
| Ziege (Goat) | Idle, Idle02, Walk, Run, Attack, Eat, Die |
| Steinbock (Ibex) | Idle, Walk, Run, Attack, Eat, Die |
| Hirsch (Deer; Hirsch, Hirschkuh) | Idle, Walk, Run, Eat, Die |
| Huhn (Chicken, 3 Farben) | Idle, Walk, Run, Eat, Die |
| Gans (swan_goose) | idle, walk, run, eat, die |
| Hausschwein (iron_age_pig, 2) | idle, walk, eat, die |
| Wildkaninchen (WildRabbit, 2) | Idle, Walk, Run, Eat, Die |
| Ratte (rat) | idle, walk, die (kein Angriff) |
| Frosch (common_frog, 3) | idle, walk, run, die |
| Feuersalamander | Idle, Walk, Run, Die |
| Viper | Idle, Glide, FastGlide, Hissing, Attack, Sleep, Die |
| Skorpion (2 Arten) | Idle, Walk, Run, Attack, Die |
| Krokodil | Idle, Walk, Run, Bite, Die |
| Krabbe | idle, walk, run, die |
| Schnecke | idle, walk, die |
| Schmetterling | fly_cycle |
| Hecht, Barsch, Lachs (2) | swim, fastswim |
| Weißer Hai | swim, fastswim, attack |
| Krake (2) | walk, run, die |

Fehlt im Paket: Hund, Katze, Pferd, Schaf, Vögel außer Huhn und Gans.

## Dinge, Möbel, Waffen

**RenderHub „Medieval Market Asset Pack“** (MagicCGIStudios), `medieval.market.asset.pack.zip` (681425039), privat, RenderHub Extended Use; nur `Medieval_Market_Asset_Pack.blend` (Blender 2.79, 233 MB, Texturen eingebettet), keine Einzeldateien. Objektnamen aus der Datei:

| Gruppe | Objekte |
|---|---|
| Brunnen | Well |
| Marktstände | Canopy_Black/Blue/Red/Yellow_White (4) |
| Wagen | Hay_Cart_1/2, Hay_Wagon_1, Barrel_Wagon_1 |
| Fässer | Wooden_Barrel (8), Metal_Barrel (10), Barrel_Stand_1–4 |
| Kisten mit Ware | Box_Of_Apples/Carrots/Oranges/Potatoes/Tomatoes (10) |
| Körbe | Wicker_Basket_1–10, _Barley/_Grain/_Oats/_Pulse, Bread_Wicker_Basket (2) |
| Tische | Meieval_Table_1–4; Table_Of_Bottles/Bread/Cheese/DinnerWare/Meat |
| Gefäße | Clay_Pot_1–6, Large_Jug_Copper/Gold/Silver |
| Sonst | Meat_Hanging_Frame_1/2, Log_Pile_1/2, Straw_Bails (9) |

Waffen: keine fremden im Bestand (nur Schwert-Bewegungen der UAL).

## Bauteile (Häuser, Natur, Dungeon)

Quaternius, itch, CC0 (`License_Standard.txt`), glTF/FBX/OBJ; laut 376 heruntergeladen und geprüft, nicht abgelegt. Teile aus der Dateiliste vom 27.10.

**Medieval Village MegaKit [Standard]** (Chef 12:42: nur Probehaus, Tom):

| Gruppe | Teile |
|---|---|
| Wände | Wall_Plaster_ und Wall_UnevenBrick_: Straight(_Base/_L/_R), Door_Flat/Round(/RoundInset), Window_Thin_Round, Window_Wide_Flat/Round; Wall_Plaster_WoodGrid (Fachwerk), Wall_Arch, Wall_BottomCover |
| Ecken | Corner_Exterior(Wide)_Brick/Wood, _TopDown/_TopOnly, Corner_Interior_Big/Small |
| Türen, Fenster | Door_1/2/4/8_Flat/Round, DoorFrame_Flat/Round_Brick/WoodDark; Window_Thin/Wide_Flat/Round, Window_Roof_Thin/Wide; WindowShutters_Thin/Wide_Flat/Round_Open/Closed |
| Böden | Floor_Brick/RedBrick/UnevenBrick/WoodDark/WoodLight, _Half, _OverhangCorner; HoleCover_* (5) |
| Dächer | Roof_RoundTiles_4x/6x/8x, Roof_RoundTile_2x(1_Long), Roof_Dormer_RoundTile, Roof_Tower_RoundTiles, Roof_Modular_RoundTiles, Roof_Wooden_2x/2x1_* (7), Roof_Front_Brick4/6/8(_Half_L/R), Roof_Log, Roof_Support, Roof_FrontSupports |
| Vorkragung | Overhang_Plaster_ und Overhang_UnevenBrick_: Corner(_Front), Long, Short, Side_Long/Short_L/R, Roof(Incline) |
| Treppen, Balkone | Stair_Interior_Rails/Simple/Solid/SolidExtended; Stairs_Exterior_* (13); Balcony_Cross/Simple_Corner/Straight |
| Kram | Prop_Chimney, Prop_Crate, Prop_Wagon, Prop_Vine (6), Prop_Brick (4), Prop_Support, Prop_WoodenFence_Single/Extension, Prop_MetalFence_Simple/Ornament, Prop_ExteriorBorder_Corner/Straight |

**Stylized Nature MegaKit [Standard]** (Chef: Felsen, Kiesel, Pilze, Farn ja; Bäume nein): Rock_Medium (3), Pebble_Round (5)/_Square (6), RockPath_Round/Square_Small/Thin/Wide; Mushroom_Common, Mushroom_Laetiporus; Fern, Clover (2), Plant (2), Plant_1_Big, Plant_7_Big, Bush_Common(_Flowers), Grass_Common/Wispy_Short/Tall, Flower_3/4_Single/Group, Petal (5); Bäume (nicht verwenden): CommonTree, DeadTree, Pine, TwistedTree je 5. Lizenzdatei oben im Paket. **In Gebrauch** (348.6, `dorf.py` `dinge_mehr`, Tom 28.10.): Rock_Medium 1–3, Mushroom_Common im Dorf; aus dem Dorfbausatz Prop_Crate neben den Fässern.

**Fantasy Props MegaKit [Standard]** (Quaternius, itch `fantasy-props-megakit`, CC0, `License_Standard.txt` geprüft 28.10.; `cc0_laden.sh`, im Bau `godot.yml`), glTF mit vier Bildern (Trim Furniture, Metal, Cloth, Props, 2048 px): Anvil(_Log), Axe_Bronze, Bag, Banner_1/2(_Cloth), Barrel(_Apples, _Holder), Bed_Twin1/2, Bench, BookGroup_Medium/Small 1–3, BookStand, Book_5/7, Book_Simplified_Single, Book_Stack_1/2, Bookcase_2, Bottle_1, Bucket_Metal/Wooden_1, Cabinet, Cage_Small, CandleStick(_Stand, _Triple), Candle_1/2, Carrot, Cauldron, Chain_Coil, Chair_1, Chalice, Chandelier, Chest_Wood, Coin(_Pile, _Pile_2), Crate_Metal/Wooden, Dummy, FarmCrate_Apple/Carrot/Empty, Key_Gold/Metal, Lantern_Wall, Mug, Nightstand_Shelf, Peg_Rack, Pickaxe_Bronze, Pot_1(_Lid), Potion_1/2/4, Pouch_Large, Rope_1–3, Scroll_1/2, Shelf_Arch/Simple/Small_Bottles, Shield_Wooden, SmallBottle(s_1), Stall_Cart_Empty, Stall_Empty, Stool, Sword_Bronze, Table_Fork/Knife/Large/Plate/Spoon, Torch_Metal, Vase_2/4, Vase_Rubble_Medium, WeaponStand, Whetstone, Workbench(_Drawers). **In Gebrauch** (399.5, `raum.py`, Tom 28.10.): Einrichtung der vier Grundrisse; dazu aus dem Dorfbausatz die Wand-, Fenster- und Türteile innen wie außen.

Ebenfalls geprüft, **nicht verwenden** (Chef 27.10., 12:42 „nein“): 150 Lowpoly Nature Models; Lowpoly Modular Dungeon Pack (höchstens Fackel, Gitter, Truhe als Rohform nach dem Meilenstein).

Dungeon: kein fremder Bausatz im Bestand.

## Eigenbau im Zweig (nicht fremd)

`godot/tiere/ratte.glb`, `wildschwein.glb`, `wolf.glb` (in `claude/tom-348-fundament` und Folgezweigen; Jerry, eigenes Skelett): Ratte Stehen, Gehen, Hocke, Biss, Sprung, Lefzen, Drohen, Ausweichen, Treffer, Tod; Wildschwein Stehen, Gehen, Ansturm, Hauer, Scharren(R), Schnauben, Drohen, Hocke, Ausweichen, Treffer, Tod; Wolf Stehen, Gehen, Biss, Sprung, Heulen, Lefzen, Scharren(R), Hocke, Ausweichen, Treffer, Tod. Sonst liegt in keinem Zweig ein GLB, glTF, FBX oder .blend.

## Unklar, ob vorhanden

| Teil | Befund |
|---|---|
| Kenney Survival Kit | Dreiecke laut `LISTE-CC0-MODELLE.md` „aus den OBJ gezählt“; nirgends abgelegt |
| RenderHub „Asset Pack Vol 10 – Modular Dungeon Interior“ (JuanChee, 7 $) | Chef „checken“, Votum offen; nicht im privaten Repo, Kauf nicht belegt |
| Universal Animation Library 2 | CC0 laut Seite, nicht geladen |
