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
| Pro-Fassung der Bewegungen | beim Chef: [348.12b](chefsache/entscheiden/34812b-ual-pro.md), Votum „ja“ | – |

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

**Suche 26.10.:** Ergebnis folgt hier (Tabellen je Gruppe: Dorf- und Kleintiere, Monster, Skelette je Bauart).
