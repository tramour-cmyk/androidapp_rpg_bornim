# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (19.10., 01:2x, „Tom – D29.3 Wald Kleinleben (19.10., 01:04)“):** Auf `claude/tom-d29-3-kleinleben` (2 Commits, Kerntests grün, selbst gesehen: Blatt `ISODINGE=wald`, `FLORA=forest…`, `deep_forest…`, `village…`): D29.3 Pilze, Zapfen, Äste je drei Varianten am Waldboden (unter Bäumen dichter, nie am Weg), Baumstümpfe mit Wurzeln (drei) statt manchem zweiten Baum, nie neben dem Weg; D29.4 Sonnenschatten für Bank, Fass, Felsen im Wald. Kein Build: fährt im nächsten Sammelbuild nach Build 32 mit (Zweig lebt bis 21.10.). Prüfpunkt: Wald mittags, Boden unter den Bäumen: Pilze, Zapfen, Äste, Stümpfe erkennbar, keiner auf dem Weg; Dorfplatz morgens: Bank mit Schatten. Nachfolger: Tom – D29.3 Rest Dorf-Kleinleben (Kür; nur wenn kein Muss startbar).

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | wartet auf Test: Build 32 (0.1.870, PR #121), Bild 3 nachgebessert | `claude/tom-build-68-d3-14` |
| 27 | K | Wald „Ort fertig“ | wartet auf Test: Build 32 (0.1.870, PR #121), D3.14 Mondlicht; Höhlenschacht nachts 27o bei Jerry | `claude/tom-build-68-d3-14` |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | ruht: Chef spielt von selbst durch (13.5, Zu 26) | – |
| 30 | K | Abstürze beim Testen (Technik) | ruht bis zum nächsten Absturzbericht (`adb logcat`) | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | ruht bis Karten Kapitel 2; Kapitel 1 fertig, [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn); Querlink: [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer) | claude/tom-145-kartenmappe |
| D29.3 | K | **von Diogenes (Lauf 30):** Kleinleben und Schatten in Wald und Dorf (D29.3, D29.4, Prüfbericht Lauf 30); Arbeit der Leute im Dorf zu D29.2 | offen: Rest (Zu D29.3); Wald-Boden und Schatten gebaut auf Zweig | `claude/tom-d29-3-kleinleben` |

## Einzelheiten

- **Zu D29.3 (19.10., 01:2x):** gebaut: Pilze, Zapfen, Äste, Stümpfe (Wald, Tiefer Wald), Sonnenschatten Bank, Fass, Felsen. Offen: (1) Dorf: Eimer, Holzstapel, Karren, Hund, Netz am Ufer; (2) Wind an Büschen und Farn: braucht die Uhr wie beim Heilkraut, also `WorldScreen.kt` (Absprache mit Jerry über dessen Vorrat); (3) D29.4 unter drei Looks: Schlagbaum, Brückengeländer, Brückenlaterne, Wegweiser im Dorf; (4) Arbeit der Leute (Bewegung, Klang bei Jerry D29.1). Beet, Mais, Busch, Farn, Schilf, Hühner behalten den kleinen Schatten im eigenen Bild (niedrig, so gewollt in `MapSun`).

- **Zu 68, Messung Homer (18.10., 23:07, `tools/bildmass.py`, Zweig 1297fd2e):** Bilder 1–5 neu, Intro 1–4 in Klammern. (1) Dunkel mit Insel: fast schwarz 8–16 % (4–26 %), passt. (2) Warm gegen kalt: kühle Fläche 6–22 % (14–54 %), Morgengrau in Bild 1, 2, 5 da; **Bild 3 zu warm**: kühl nur 6 %, 90 % des Hellen warm, Schleier R−B +0,30 (höchstens +0,26). (3) Struktur: glatt 40–59 % (40–68 %), passt. (4) Tiefe: Blick 36°, −20°, 28° statt 6°, 8°, frontal; Bank oder Kerze vorn, passt. (5) Figuren: Menge abwechselnd aus sieben Formen, Haarfarben, Hauben; Stirnreif, Stab, Sonne und Kerze im Code; Ansicht beim Chef. (6) Licht mit Abfall: Schleier +0,09 bis +0,25 außer Bild 3 (vorher +0,34 bis +0,39), passt. (7) Leben: Flammen, Lichtatmen, Staub in Bild 4, passt. **Bild 3:** Kerzenschein enger, Morgengrau aus dem Fenster dazu; dann direkt zum Chef.
- **Zu 27:** Wald „Ort fertig“ (`DESIGN-ABNAHME.md`). D3.14 (18.10.): Heldenlaterne draußen weg, Nachtgrund kühles Mondlicht (Wald, Tiefer Wald, Dorf), Tiefer Wald mittags etwas heller (Lückenliste 26). Prüfpunkt im Build: Wald und Tiefer Wald um 23 Uhr ohne Fackel: kein Lichtkreis um den Helden, Weg und Bäume lesbar; mit Fackel warmer Kreis. 27n auf `main` (#71).
- **Zu 68:** 112 entschieden (Chef 17.10., 10:4x): fünf Bilder neu malen nach den sieben Punkten (Vorgangsarchiv 112), erst nach dem Meilenstein; Vorlage zuerst an Homer messen, dann an den Chef. Auf `main` mit #67 (0.1.753 „passt“); Durchsicht der Szene mit Knopf 100 durch den Chef offen. Chef 17.10., 01:17: „T13, 13.4 habe ich ganz angesehen und es lief fehlerfrei durch.“ (keine Stichworte für 112).
- **Zu 26** (`LISTE-ABNAHME-KAPITEL1.md`): Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch (0.1.828 ist überholt); sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`), Querlink zum roten Faden 144, Beginn Kapitel 1 und 2 (161). Kapitel 2 hat noch keine Karten; Querlink zu 144 steht. Zweig `claude/tom-145-kartenmappe` (nur `tools/preview`, Schalter `KARTENMAPPE=1`) wartet auf Kapitel 2.
