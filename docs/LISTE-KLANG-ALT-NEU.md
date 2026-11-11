# Klangliste alt gegen neu: je Anlass alt, neu, fehlt (786)

Vorgang 786 (654 A, Chef 09.11., 17:46: Querschnitt Klang nach Kampf-Sollbild 784). Gelesen von Tom am 11.11., 13:12 aus `origin/main` `f1c09885e` (die offenen Zweige 870.4, 870.6, 870.8 ändern daran nichts). **Alt** = Aufrufe von `Sound.<Name>` in `app/` und `core/` (Kotlin), **neu** = Godot unter `godot/` ohne Tests. Kürzel: **G** `core/…/Game.kt`, **AU/** `core/…/audio/`, **BS** `app/…/BattleScreen.kt`, **SK** `app/…/SkirmishScreen.kt`, **WS** `app/…/WorldScreen.kt`; neu **kl** `godot/klang/klang.gd`, **sp** `godot/skripte/spiel.gd`.

Neue Einzelfunde zum Klang kommen hierher (eine Zeile), nicht als neuer Vorgang; ein „fehlt“ bekommt den Vorgang, der es behebt.

## Fehlt (mit Vorgang)

| Anlass | alt | neu | Vorgang |
|---|---|---|---|
| Kaufen, Verkaufen, Zurückkaufen, Ausrüstung kaufen und verkaufen: Münzen | G 1588, 1616, 1655, 1666, 1689 `COINS` | `ladenschirm.gd` still | 938 |
| Brauen: Trankklang | G 1632, 1636 `POTION` | `ladenschirm.gd` 300 still | 938 |
| Rast: Zimmerpreis Münzen, dann Heilen | G 207, 208 `COINS`, `HEAL` | `rast.gd` 55–56 gibt `klang` zurück, keiner spielt ihn | 938 |
| Met an der Theke: Münzen | G 254 `COINS` | still (Trinkgeräusch: 681) | 938 |
| Szene gibt Gold, Gegenstand, Rast, Heilung | G 1184 `LOOT`, 1191 `COINS`, 1208, 1216 `HEAL` | sp 925–941 still | 938 |
| Ring öffnet: schwerer Schwung | SK 713 `SWING_HEAVY` 0,6 | `kampfort.gd` still | 939 |
| Ring gut oder perfekt: Block | SK 726 `BLOCK` (gut 0,5) | `kampfort.gd` 990 still | 939 |
| Wölfe erscheinen: Geheul, halb so oft | SK 548 `HOWL` | nur beim Umkreisen (kl 364) | 939 |
| Siegfenster: Beute, epische Beute, Münzen | BS 587 `LOOT`, `LOOT_EPIC`, `COINS` | still | 939 |
| Stufenaufstieg im Siegfenster | BS 523 `LEVEL_UP` | still | 939 |
| Nahe einem Monster: Musik leiser, dunkle Unterlage; bemerkt: still | AU/Music.kt `shade`, G 600 `threat` | fehlt (kl Kopf: „Bemerkgrenze“ offen) | 936 |
| Monster auf der Karte, solange es nicht jagt: Ruhelaut, nur nah (13 Arten) | G 910–925, AU/MonsterIdle.kt `IDLE_*` | nur Wolf im Kampf (`figur.gd` 1190) | 937 |

## Fehlt mit Ort oder Ding (Vorgang dort)

| Anlass | alt | neu | Vorgang |
|---|---|---|---|
| Schenke: Rowena wischt, gießt, Becher, Stuhl | `art/MapFolk.kt` 975–983 `WIPE`, `POUR`, `CUP`, `CHAIR` | fehlt | 634 |
| Teich: Frosch, Froschchor, Libelle | AU/PondSound.kt, WS 338 `FROG`, `FROG_CHORUS`, `DRAGONFLY` | kein Teich gefunden (Suche „teich“, „pond“) | 598 |
| Regen, Donner (Wald, Dorf) | WS 354 `RAIN`, G 171 `THUNDER` | kein Wetter (`gluehwuermchen.gd` 10) | 598 |
| Vögel auf der Wiese fliegen auf, scharren | AU/WildSound.kt 110, 117 `BIRD_FLAP`, `BIRD_SCRATCH` | keine Vögel auf der Wiese | 638 |

## Gleich

| Anlass | alt | neu |
|---|---|---|
| Knopf, Regler im Menü | `CLICK` (App.kt 105, SoundSettings.kt 44) | `zeichenknopf.gd` 67, `menue.gd` 1642 |
| Klanglogo im Vorspann | `BRAND` (App.kt 174) | `hauptmenue.gd` 119 |
| Musik je Ort, Kampf, Boss, Sieg, Kapitelende, Tempel, Titel; Höhlenteppich | AU/Music.kt | kl 41–48, 135–265, sp 584, 635, 1081, 1229 |
| Schwarzblende: Effekte still, danach 400 ms | AU/Music.kt VeilGate | kl 277–296 |
| Kampf: Hiebe nach Waffe, kritisch, daneben, Pfeil, Zauber nach Art, Heilen, Gift, Netz, Sturz, Schwung, Stimmen | AU/MarsSound.kt, AU/FxSound.kt | kl 353–445 (`kampfklang.json` aus KlangExport.kt) |
| Begegnung, Hinterhalt, starker Herzschlag unter der Blende | G 1277 `ENCOUNTER`, `AMBUSH`; `HEARTBEAT_STRONG` | `kampfblende.gd` 105, 151 |
| Monster bemerkt den Helden | G 890 `ALERT` | `herde.gd` 160 |
| Tür, Schlagbaum, Klopfen, Truhe | G 1085, 1162 `DOOR`; 1024 `KNOCK`; 1100 `CHEST` | sp 514, 919 (636); 407; 759, 766 |
| Kräuter pflücken | G 758 `LOOT` | sp 817 |
| Trank, Essen außerhalb des Kampfs | G 1539–1567 `POTION`, `HEAL` | `menue.gd` 771 |
| Schritte je Boden, Keuchen | AU/Footsteps.kt, AU/Panting.kt | kl 458–470, 504–550 |
| Ortsklang: Wind, Halle, Feuer, Fluss, Tropfen, Knarren, Husten; Raumhall | AU/PlaceSound.kt, Ambience.kt, RiverSound.kt, Room.kt | kl 553–660, 948–950 |
| Kleines Leben und Fernes: Vögel, Grillen, Eule, fernes Wolfsheulen, Grollen | AU/WildSound.kt | kl 663–760 (517) |
| Hühner, Ziegen, Kaninchen | AU/HenSound.kt, Recorded.kt | kl 761–830 |
| Ruf mit dem goldenen Zeichen | AU/Recorded.kt `HAIL_*` | `ruf.gd` 56–57 |
| Intro: Glocke, Rufe, Schrei, Wind, Fluss, Grillen | AU/IntroSound.kt | `zwischenbild.gd` 20, 377–412 |

Nicht als Anlass gezählt: `HEARTBEAT` (alt nur in Room.kt aufgeführt, nirgends gespielt).
