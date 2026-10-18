# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (18.10., 19:3x, „Tom – 180 Fackel im Laden (18.10., 18:52)“) – Nachfolger: keiner; Muss leer, Kür 27 startet Ford nach `startbar.py`:** Build 30 freigegeben (Chef 19:3x), PR #119 auf `main`, t30 gelöscht, CHANGELOG; erledigte Einzelheiten 175, 176, 176a, 180 gestrichen (Verlauf in Git).

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | **jetzt (Chef 18.10., 20:3x, Vorgangsarchiv 68):** fünf Bilder nach Muster Intro (112, sieben Punkte), Vorlage zuerst an Homer; Durchsicht Chef offen | – |
| 27 | K | Wald „Ort fertig“ | auf `main` bis 27m, D3.13a (#67); D3.14 erst mit 84.1 | – |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | Teil erledigt; Rest wartet auf Chef (13.5 Durchspielen) | – |
| 62c | K | Karte: Lücken, Bekannte/Dienste, Beschriftung | bis 62r auf `main`; 62l später | – |
| 30 | K | Abstürze beim Testen (Technik) | beobachten | – |
| 150 | K | Spielzeit im Menü | beantwortet; Änderung nur auf Wunsch | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | Kapitel 1 fertig, [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn); Querlink: [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer) | claude/tom-145-kartenmappe |

## Einzelheiten


- **Zu 68, Messung Homer (18.10.):** die heutigen fünf Bilder (`assets/tempel`) gegen Intro 1–4, Werte Intro in Klammern. (1) Dunkel mit Insel: fast schwarz B2 2 %, B3 0 % (Intro 10–39 %); B1, B4, B5 um 20 % gut. (2) Warm gegen kalt: B1–B4 ohne kaltes Licht (kalt unter 1 %, Intro 2–36 %), B5 nur kalt, ohne warme Quelle; jedes Bild braucht beides (Morgengrau in Fenster und Tür gegen Kerzen). (3) Struktur: glatte helle Fläche B2–B5 61–76 % (Intro 24–49 %), B1 46 %: Stein, Bänke, Tuch, Putz brauchen Fugen, Maserung, Falten. (4) Tiefe: B2, B3 blicken fast frontal auf den Altar (6°, 8°), B5 frontal auf die Tür: schräg stellen, Bank oder Kerze groß vorn. (5) Figuren: Menge aus sieben Grundformen mit Farbton; am Bild prüfen, dass keine zwei gleichen nebeneinander sitzen und Lyra, Aldric, Osric ihr Merkmal aus `LISTE-FIGUREN.md` zeigen. (6) Licht mit Quelle und Abfall: B1–B4 warmer Schleier über dem ganzen Bild (Rot minus Blau in Mitteltönen +0,23 bis +0,31, Intro −0,10 bis +0,08); Kerzenlicht als Kegel mit Abfall, Rest kühl. (7) Leben: `TempleSceneScreen` hat `onPicture = {}`, nichts bewegt sich; Kerzen flackern, Staub im Sonnenstrahl (B4) treibt, wie `IntroLife`. Vorrang: 6, 1, 2 (Licht) vor 3, 4, dann 7.
- **Zu 27:** Wald „Ort fertig“ (`DESIGN-ABNAHME.md`). D3.14: Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1. 27n auf `main` (#71).
- **Zu 68:** 112 entschieden (Chef 17.10., 10:4x): fünf Bilder neu malen nach den sieben Punkten (Vorgangsarchiv 112), erst nach dem Meilenstein; Vorlage zuerst an Homer messen, dann an den Chef. Auf `main` mit #67 (0.1.753 „passt“); Durchsicht der Szene mit Knopf 100 durch den Chef offen. Chef 17.10., 01:17: „T13, 13.4 habe ich ganz angesehen und es lief fehlerfrei durch.“ (keine Stichworte für 112).
- **Zu 26** (`LISTE-ABNAHME-KAPITEL1.md`): Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch (0.1.828 ist überholt); sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 62c:** Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p). 62i–62k mit 64; 62l später (62m bei Jerry mit 39).
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 150** (Chef 17.10., 16:1x): „wenn der Spieler im Menü ist und irgendwas einstellt, das zählt nicht zur Spielzeit, oder?“ Antwort: zählt heute mit (nur App im Vordergrund mit geladenem Helden).
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`), Querlink zum roten Faden 144, Beginn Kapitel 1 und 2 (161). Kapitel 2 hat noch keine Karten; Link zu 144 nachtragen, sobald Homers Seite steht.
