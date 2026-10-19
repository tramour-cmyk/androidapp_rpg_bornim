# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (19.10., 18:14, „Tom – 213 Build 35 zusammenführen (19.10., 18:05)“):** Build 35 (PR #124) nach „freigegeben“ des Chefs (18:00) zusammengeführt, PR #121 geschlossen (in #124 enthalten); 213, 198, 84.1T.1, 216, 27, D29.3 erledigt. 68 offen (35.9–35.11). 214, 215, 220, 221 gebaut für den nächsten Sammelbuild. 218 gebaut (Zweig `claude/tom-218-testreiter`, App nur im nächsten CI-Build übersetzt). Nachfolger: Tom – 68 Tempelbilder.

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 227 | M? | **von Chef (19.10., 18:26):** Testmodus: Knopf „Kopieren“ gibt es, aber erst unter dem endlosen Stapel; nach oben neben „Absturzbericht schließen“, gleiche Zeilen zusammenfassen („… 1000× gleich“), damit der Ursprung unten sichtbar bleibt | offen | – |
| 218 | M | **von Chef (19.10., 13:52):** Unterüberschrift „Monster/Kampf beschwören“ im Testreiter vor der Monsterauswahl; Wortlaut Zu 218 | gebaut: kommt in den nächsten Sammelbuild (Prüfpunkt Zu 218) | `claude/tom-218-testreiter` |
| 220 | M? | **von Chef (19.10., 15:42):** „Wirkte im Dorf beim Emulator einfach sehr schnell das Rennen im Vergleich zum Gehen.“ Heute 2,6-fach | gebaut: kommt in den nächsten Sammelbuild nach Build 35 (Prüfpunkt Zu 220) | `claude/tom-220-renntempo` |
| 221 | K | **von Sokrates (Chef 19.10., Vorgangsarchiv 221):** Wasser lebendiger: Glanz mit der Strömung, Regenringe, Lichtstreif nachts | gebaut: kommt in den nächsten Sammelbuild nach Build 35 (Prüfpunkt Zu 221) | `claude/tom-221-wasser` |
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | offen: Test 35.9, 35.10, 35.11 nicht bestanden (Zu 68 Test 35.x) | `claude/tom-68-bildfehler` |
| 224 | M? | **von Chef (FB B35):** „Holz sieht sehr zugeschnitten aus...“; „Regal sieht "gebrochen" in der Mitte aus...“ | offen | – |
| 214 | K | **von Chef (19.10., 13:20, über Sokrates):** Reiter Ausrüstung: Tippen auf einen Platz zeigt passende Teile aus dem Beutel zur Wahl; Vorgangsarchiv 214, Zu 214 | gebaut: kommt in den nächsten Sammelbuild nach Build 35 (Prüfpunkt Zu 214) | `claude/tom-214-ausruestung-wahl` |
| 215 | K | **von Chef (19.10., 13:37, über Sokrates):** Übergänge (Tür, Höhleneingang, Weg, Kartenrand) über den Aktionsknopf statt beim Betreten des Felds; Vorgangsarchiv 215, Zu 215 | gebaut: kommt in den nächsten Sammelbuild nach Build 35 (Prüfpunkt Zu 215) | `claude/tom-215-uebergang-taste` |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | ruht: Chef spielt von selbst durch (13.5, Zu 26) | – |
| 30 | K | Abstürze beim Testen (Technik) | ruht bis zum nächsten Absturzbericht (`adb logcat`) | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | ruht bis Karten Kapitel 2; Kapitel 1 fertig, [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn); Querlink: [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer) | claude/tom-145-kartenmappe |
| 133 | K | Umsetzung 133: Charisma-Wahlen Kapitel 2, Gespräche (`STORY-WAHLEN.md`, Vorgangsarchiv 133) | wartet auf 41 (Kapitel 2 ist nicht im Spiel: keine Rabenschanze, kein Kultlager, kein Vesk, Ansel, Rask) und 49 (Fertigkeiten, ruht); geprüft 19.10. | – |
| 41.2 | K | Umsetzung 41.2: Ansel fährt nach N3 auch nachts (Vorgangsarchiv 41.2) | wartet auf 41 (Kapitel 2 ist nicht im Spiel) | – |

## Einzelheiten


- **Zu 26**: Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch; sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`). Zweig `claude/tom-145-kartenmappe` (nur `tools/preview`, Schalter `KARTENMAPPE=1`) wartet auf Kapitel 2.

- **Zu 214** (Chef 19.10., 13:20: „214 MACHEN! Sehr spielerfreundlich, wen Luft ist, eilt nicht so sehr..“): leerer Platz → Liste passender Beutelteile (`GearRow`, Vergleich, „Anlegen“ über `equipFromBag`), nicht Tragbares gedämpft mit Grund, sonst „Nichts Passendes im Beutel“; Nebenhand: Schild, Fackel, Einhandwaffen (Fackeltext `Light.torchChange` wie in der Tasche); besetzter Platz: „Wechseln“ neben „Ablegen“. Ort: `MenuScreen.kt` `GearTab`. Kür, nach den Muss. Gebaut 19.10., 14:30. Prüfpunkt: Ausrüstung, leeren Platz tippen: Liste passender Beutelteile (Nebenhand auch Einhandwaffen, Fackel, Schild), nicht Tragbares blass mit Grund, leer „Nichts Passendes im Beutel.“; Teil tippen, „Anlegen“: sitzt am Platz; besetzter Platz: „Wechseln“ neben „Ablegen“.
- **Zu 68 Test 32** (Chef 19.10., Wortlaut): „Licht durch Fenster wirkt oben abgeschnitten.“
- **Zu 68 Test 32, Punkt 2** (Chef 19.10., Wortlaut): „Bank hintere Reihe sieht mit dem Rundbogen falsch aus. \"Person\" hintere Reihe wirkt abgeschnitten.“
- **Zu 68 Test 32, Punkt 3** (Chef 19.10., Wortlaut): „Das sieht einfach nur falsch aus mit dem Stab in dieser Pose...“
- **Zu 68 Test 32, Punkt 4** (Chef 19.10., Wortlaut): „Lichtstrahl auf Amulett wirkt künstlich und abgeschnitten.“
- **Zu 68 Test 32, Nachbesserung** (19.10., 14:15): Punkte 1–4 gebaut, in Build 35 (Commit 80ada95a).
- **Zu 68 Test 32, Gesamt** (Chef 19.10., 13:30): „Grds. zu Outro: Stimmung passt, Kerzen passen, "Staub" passt, Szenen an sich passen.“ → Test 32 bestanden bis auf Punkte 1–4.
- **Zu 68 Test 35.9** (Chef 19.10., 17:55): „Sorry, dass sieht immer noch falsch aus. Was ist denn da los? Kann genau das Gleiche sagen wie das letzte Mal: Halbrundung der "Bank" im Nirgendwo, halb abgeschnittene Männchen...“ Sokrates: Lehnen schulterhoch, Wange links frei im Gang; vor Build Standbild an Chef.
- **Zu 68 Test 35.10** (Chef 19.10., 17:57): „Was sind das für Arme? Was soll der Kreis auf dem Kopf? Stab okay, aber Hand/Arm dazu? Weißer Ärmel von ihr andersfarbig als ihre Robe?“ Sokrates: Aldrics Arme Striche ohne Schulter, keine Hand am Stab; Lyra mit Ring auf dem Kopf.
- **Zu 68 Test 35.11** (Chef 19.10., 17:58, Bild 3/4): „Männchen in dunkler Robe sieht auch unten abgeschnitten aus...“ 17:59: „Die anderen Bilder sind okay, aber keine Meisterleistung.“
- **Zu 215** (Chef 19.10., 13:37: „215 A wie jetzt empfohlen“): heute wechselt `Game.afterStep` den Ort, sobald der Held auf das Warp-Feld tritt. Neu: der Aktionsknopf (`WorldScreen.kt`, `ActionButton`, rechts unten, Linkshänder links) bietet den Übergang an, mit eigenem Zeichen und dem Ziel als Schrift; erst Tippen wechselt. Gesperrte Übergänge (`requires`, `knock`, `turnBack`) wie heute. `WorldScreen.kt` nur nach Absprache (CLAUDE.md 6); Höhleneingänge mit Jerry abstimmen. Kür, nach den Muss. Gebaut 19.10., 14:38 (Zweig auf 216): alle Übergänge, auch Höhle; `WorldScreen.kt` nur die Schrift über der Taste (Wischsteuerung; im Steuerkreuz nur das Türzeichen); Jerry beim nächsten Start Bescheid geben. Tippen auf einen Übergang geht hin und hindurch. Prüfpunkt: Dorf, auf die Gasthaustür gehen: kein Wechsel, Taste zeigt Türzeichen und „Gasthaus …“; Tippen: drinnen; ebenso Höhleneingang und Kartenrand; gesperrte Tür klopft wie bisher.
- **Zu 218** (Chef 19.10., 14:10, an Sokrates): „Wenn ihr schon dabei seid, dann schaut doch mal, ob es nicht andere Gliederungen auch noch sinnvoll macht oder die Reihenfolge, wie alles dasteht. Also hier mal kurz einmal drüber gehen, gucken, Reihenfolge, alles halbwegs so geklustert, dass es Sinn macht.“ `TestTab.kt`: Knöpfe nach Zweck gruppieren, je Gruppe Überschrift, nichts entfernen.

- **Zu 218** (Chef 19.10., 13:52, Wortlaut): „Unterüberschrift im Testreiter vor Monsterauswahl (sieht aus, als gehöre es zu MARS) Vorschlag Überschrift Monster/Kampf beschwören (man kann ja beides machen)“; dazu ganzen Testreiter gliedern (Zu 218); mit 213 bauen, `TestTab.kt` nach Jerrys Build 33 (201 ändert dort den MARS-Block)
- **Zu 220** (gebaut 19.10., 15:5x): Rennen 170 ms je Schritt statt 130, also 2,0-fach statt 2,6-fach (etwa 3,7 statt 4,8 Felder/s; Gehen 1,8; jagende Gegner 1,6). Prüfpunkt am Gerät: im Dorf gehen, dann über den Ring hinaus rennen; richtig: Rennen deutlich schneller, aber nicht hektisch; falsch: wirkt wie vorher sehr schnell oder kaum schneller als Gehen.
- **Zu 221** (gebaut 19.10.): `WaterLife.kt`, `WaterLifeUi.kt`; etwa 70 µs je Bild am Rechner. Prüfpunkt am Gerät: Dorf am Fluss bei Tag, Regen und Nacht (Testreiter Uhrzeit); richtig: ruhige Bewegung ohne Ruckeln, nichts auf dem Ufer; falsch: Glanz flackert, Streifen über Bäumen oder Häusern.
- **Zu 218** (gebaut 19.10.): `TestTab.kt` neu geordnet, nichts entfernt: Anzeigen und Messwerte (Blende, Kampf bereit, Bildrate, Standort) · Held (Stufe, Gold, Heilen, Vorräte, Waffe, Andere Hand) · Welt (Uhrzeit, Regen, Zoom, Monster beachten mich nicht, Sichtlinie, Bosse) · Teleport (Orte, Kapitel 1 bis kurz vor Ende) · Kampfhilfen (Rettungswürfe, kritisch) · Monster/Kampf beschwören (Variante, Eröffnung, Monsterliste) · MARS-Probekampf · Beute erzeugen. Prüfpunkt: Testreiter durchblättern; richtig: jede Gruppe unter ihrer Überschrift, alle Knöpfe von vorher da; falsch: ein Knopf fehlt oder steht unter fremder Überschrift.

Zu 227 (Chef 19.10., 18:26, zum Absturz 226): „Ein Kopieknopf für den Text des Berichts (Zwischenablage) wäre hilfreich.“ 18:26, zweites Bild („Zweiter Teil“): Knöpfe „Kopieren“ und „Vergessen“ stehen am Ende, nach etwa 100 gleichen Zeilen `t1.C2.a(Unknown Source:5)`; der Aufrufer der Rekursion fehlt im Bericht (Stapel abgeschnitten), „Abgefangen“ leer. 18:27: „Kopieren“ funktioniert (Text kam im Chat an), Stapel endet nach 80 Zeilen.
