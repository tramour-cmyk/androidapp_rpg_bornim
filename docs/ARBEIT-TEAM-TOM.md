# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).

**offen 13, Muss 4, A 0, Chefsache 1**

**Übergabe (17.10., 11:5x, „Tom – 132 Spieldauer, vierter Spielstand“) – Nachfolger: Tom – 132 zusammenführen (nach „passt“ zu t14: PR #102 mergen, CHANGELOG, t14 löschen):** 132, 134.1 und 117 gebaut, PR #102 = Build 14 (0.1.821), Prüfliste t14.

## Zeilen

| Nr. | Kl. | Thema | Stand | Zweig |
|---|---|---|---|---|
| 132 | M | **von Chef (17.10., 01:06):** Spieldauer im Spielstand („Gespielt: 2 Std. 14 Min.“ auf der Karte „Spielstände“) und vierter Spielstand, Fenster „Alle Plätze belegt“ rollt mit (Vorgangsarchiv 132) | **gebaut mit 117 und 134.1** (17.10., 11:1x, Kerntests grün, `PlayClockTest`): PR #102 = Build 14, mit 134.1 = **0.1.821 grün**, [Prüfliste t14](chefsache/ansehen/t14-spieldauer.md); wartet auf Test, vor 13.5, [Prüfliste t14](chefsache/ansehen/t14-spieldauer.md); wartet auf Test, vor 13.5 | `claude/tom-132-spieldauer` |
| 134.1 | M | **von Chef (17.10., 10:4x):** kurzes goldenes Zeichen über Leuten mit Neuem, nur wenn (a) schon gesprochen, (b) Neues zu sagen oder Auftrag abzugeben, (c) sie den Helden wahrnehmen (Vorgangsarchiv 134) | **gebaut** (17.10., 11:5x, `HailTest`, Vorschau `ZEICHEN=1`): mit 132 in PR #102 = Build 14; Vermerk `WorldScreen.kt` bei Jerry | `claude/tom-132-spieldauer` |
| D23 | M? | **von Diogenes** (Lauf 23; Prüfbericht): **D23.2** Garricks Warnung unter Stufe 3 und Hinweis auf Morwen (`KROGG_HINT`, Chronik „Rauch gegen Krogg“) erst im zweiten Gespräch; wer einmal spricht, hört beides nie (Beschluss D4.1) | **bestätigt** (17.10., 09:3x; `Story.kt` Garrick: erstes Gespräch nur Begrüßung und Tränke, Krogg-Teil samt Hinweis nur im Zweig nach `HUNTER_MET`). Text ist Story → Zeile an Homer (D23.2); bauen nach Homers Wortlaut und Perikles’ M · **von Homer (17.10., 10:06):** kein neuer Text; erstes Gespräch = Begrüßung, Gras, Lagerfeuer, Tränke, dann gleich `[41.garrick.krogg]`, „Ostflügel …“, `[D4.1.garrick.morwen]`, ggf. `[D4.1.garrick.warnung]`, `KROGG_HINT` setzen. Spätere Gespräche bis Kroggs Fall wiederholen den Krogg-Teil wie bisher (ohne Begrüßung) | – |
| 27 | K | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Auf `main` bis 27m und D3.13a (#67). **D3.14:** Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1. 27n auf `main` (#71) | – |
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | **112 entschieden (Chef 17.10., 10:4x):** fünf Bilder neu malen nach den sieben Punkten (Vorgangsarchiv 112), **erst nach dem Meilenstein**; Vorlage zuerst an Homer messen, dann an den Chef · auf `main` mit #67 (0.1.753 „passt“); Durchsicht der Szene mit Knopf 100 durch den Chef offen: **Chef 17.10., 01:17: „T13, 13.4 habe ich ganz angesehen und es lief fehlerfrei durch.“** (keine Stichworte für 112) | – |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem (`LISTE-ABNAHME-KAPITEL1.md`) | Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen: **13.5** Durchspielen durch den Chef, **nicht auf 0.1.816** (t13 zurückgezogen, Chef 17.10., 13:5x) und nicht auf 0.1.821, sondern auf einem **frischen Build nach t14** mit dessen Fehlern behoben; Testbitte dann mit diesem Build | – |
| 62c | K | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | bis 62r auf `main`; 62i–62k mit 64; 62l später (62m bei Jerry mit 39) | – |
| 30 | K | Abstürze beim Testen (Technik) | beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste | – |
| 134.2 | K | **von Chef (17.10., 10:4x):** Gesten zum Zeichen 134.1 (Hand heben, herwinken, nicken; je Person Vorschlag Homer) | nach 134.1 | – |
| 138 | K | **von Perikles (Ideenspeicher, 137):** Kräuter wachsen am Morgen nach statt um Mitternacht (Spielzeit, passt zu 5la) | offen; klein | – |
| 139 | K | **von Perikles (Ideenspeicher, 137):** Fleisch an die Wirtin (Rowena) verkaufen, heute nur Thessa und Morwen | wartet auf zwei Sätze von Homer (Zeile 139 dort) | – |
| 145 | K | **von Chef (17.10., 11:5x, über Sokrates):** „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt auf der Zentrale (Bilder aus `tools/preview`) | offen | – |
