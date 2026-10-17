# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).

**offen 12, Muss 4, A 0, Chefsache 1**

**Übergabe (17.10., 16:2x, „Tom – 131 Gehen und Rennen (17.10., 15:38)“) – Nachfolger: Tom – 138 Kräuter am Morgen (Kür; Muss 68 erst nach Meilenstein, 26 und 131 beim Chef):** 131 gebaut, PR #104 (mit D23.2) zusammengeführt, Release 0.1.827, Testaufgaben t16; t15 ersetzt.

## Zeilen

| Nr. | Kl. | Thema | Stand | Zweig |
|---|---|---|---|
| 131.1 | M | **Feedback Chef zu Build 16, 17.10., 17:0x, Wortlaut:** „Der Joystick muss in der Normaleinstellung wieder deutlich kleiner werden. Wenn vorher 2,5 war, dann jetzt 1,5. Das Gehen müssen wir wieder ein bisschen schneller machen. Und Rennen: ich werde jetzt Magierstufe 1 und der rennt wie ein Hase. Das Rennen muss ein Ticken langsamer sein. Und der Übergang zwischen Rennen und Gehen und Gehen und Rennen kann nicht von 0 auf 100 sein, kein digitales 0/1, sondern sich beschleunigen oder verzögern. Schon mal Feedback fürs Erste.“ (erstes Feedback, weitere folgen) | offen | – |
| 131 | M | **von Sokrates, jetzt (Chef 17.10., 15:3x: „Tom soll das jetzt mal einbauen, dann mit dem Stand ein Release machen, ein wirkliches Release, und das gebe ich dann meinen Testern auch schon mal. Dann können die einmal durchtesten und ich auch. Okay, Reihenfolge klar.“), Vorgangsarchiv 131; ganz (auch Jerrys Teil Tempo/Ausdauer):** Joystick: Gehen im ganzen inneren Kreis; Rennen über sichtbaren Ring hinaus (Normal etwa 2,5 cm, skaliert mit 86.4), Rütteln und goldener Ring beim Umschalten; Taste „Rennen“ wahlweise im Menü; `WorldScreen.kt` (`TouchLayer`, `StickFeel`); dazu Gehen halb so schnell (etwa 1,5 Felder/s), Volk/Rüstung nach SRD, Geschick ±5 % je Bonus, Rennen etwa 6 s bei Kon 10 (±2 s je Bonus, +1 s je zwei Stufen; `FreeWalk.kt`, `Stamina.kt`). Danach Testbitte; nach „passt“ auf `main` und **Release** nach `LISTE-RELEASE-NEUSTART.md` (Zuruf liegt vor) | **Release 0.1.827** (17.10., 16:18; PR #104 mit #103 zusammengeführt, ohne Test-Build auf Zuruf Chef 16:0x); Test des Chefs: [t16](chefsache/ansehen/t16-release-gehen-rennen.md); Befunde → Folge-Release | – |
| 27 | K | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Auf `main` bis 27m und D3.13a (#67). **D3.14:** Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1. 27n auf `main` (#71) | – |
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | **112 entschieden (Chef 17.10., 10:4x):** fünf Bilder neu malen nach den sieben Punkten (Vorgangsarchiv 112), **erst nach dem Meilenstein**; Vorlage zuerst an Homer messen, dann an den Chef · auf `main` mit #67 (0.1.753 „passt“); Durchsicht der Szene mit Knopf 100 durch den Chef offen: **Chef 17.10., 01:17: „T13, 13.4 habe ich ganz angesehen und es lief fehlerfrei durch.“** (keine Stichworte für 112) | – |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem (`LISTE-ABNAHME-KAPITEL1.md`) | Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen: **13.5** Durchspielen durch den Chef, **nicht auf 0.1.816** (t13 zurückgezogen, Chef 17.10., 13:5x) sondern im Release mit 131 ([t16](chefsache/ansehen/t16-release-gehen-rennen.md) 16.8) | – |
| 62c | K | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | bis 62r auf `main`; 62i–62k mit 64; 62l später (62m bei Jerry mit 39) | – |
| 30 | K | Abstürze beim Testen (Technik) | beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste | – |
| 134.2 | K | **von Chef (17.10., 10:4x):** Gesten zum Zeichen 134.1 (Hand heben, herwinken, nicken; je Person Vorschlag Homer) | nach 134.1 | – |
| 138 | K | **von Perikles (Ideenspeicher, 137):** Kräuter wachsen am Morgen nach statt um Mitternacht (Spielzeit, passt zu 5la) | offen; klein | – |
| 139 | K | **von Perikles (Ideenspeicher, 137):** Fleisch an die Wirtin (Rowena) verkaufen, heute nur Thessa und Morwen | wartet auf zwei Sätze von Homer (Zeile 139 dort) | – |
| 150 | K | **von Chef (17.10., 16:1x):** „wenn der Spieler im Menü ist und irgendwas einstellt, das zählt nicht zur Spielzeit, oder?“ | beantwortet: zählt heute mit (nur App im Vordergrund mit geladenem Helden); Änderung nur auf Wunsch | – |
| 145 | K | **von Chef (17.10., 11:5x, über Sokrates):** „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt auf der Zentrale (Bilder aus `tools/preview`) | offen | – |
