# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).

**offen 10, Muss 4, A 0, Chefsache 1**

**Übergabe (17.10., 11:2x, „Tom – 132 Spieldauer, vierter Spielstand“) – Nachfolger: keiner (Sparmodus ab 11:00; nach Test „passt“: PR #102 zusammenführen, CHANGELOG):** 132 mit 117 gebaut, PR #102 = Build 14 (0.1.820), Prüfliste t14.

## Zeilen

| Nr. | Kl. | Thema | Stand | Zweig |
|---|---|---|---|---|
| 132 | M | **von Chef (17.10., 01:06):** Spieldauer im Spielstand („Gespielt: 2 Std. 14 Min.“ auf der Karte „Spielstände“) und vierter Spielstand, Fenster „Alle Plätze belegt“ rollt mit (Vorgangsarchiv 132) | **gebaut mit 117** (17.10., 11:1x, Kerntests grün, `PlayClockTest`): PR #102 = Build 14 (0.1.820, grün), [Prüfliste t14](chefsache/ansehen/t14-spieldauer.md); wartet auf Test, vor 13.5 | `claude/tom-132-spieldauer` |
| 134.1 | M | **von Chef (17.10., 10:4x):** kurzes goldenes Zeichen über Leuten mit Neuem, nur wenn (a) schon gesprochen, (b) Neues zu sagen oder Auftrag abzugeben, (c) sie den Helden wahrnehmen (Sicht, Entfernung, Nacht wie bei Monstern); kurz beim Herankommen, einmal wiederholt, dann erst bei Wiederkehr (Vorgangsarchiv 134) | startbar nach 132; `WorldScreen.kt` mit Jerry absprechen | – |
| D23 | M? | **von Diogenes** (Lauf 23; Prüfbericht): **D23.2** Garricks Warnung unter Stufe 3 und Hinweis auf Morwen (`KROGG_HINT`, Chronik „Rauch gegen Krogg“) erst im zweiten Gespräch; wer einmal spricht, hört beides nie (Beschluss D4.1) | **bestätigt** (17.10., 09:3x; `Story.kt` Garrick: erstes Gespräch nur Begrüßung und Tränke, Krogg-Teil samt Hinweis nur im Zweig nach `HUNTER_MET`). Text ist Story → Zeile an Homer (D23.2); bauen nach Homers Wortlaut und Perikles’ M · **von Homer (17.10., 10:06):** kein neuer Text; erstes Gespräch = Begrüßung, Gras, Lagerfeuer, Tränke, dann gleich `[41.garrick.krogg]`, „Ostflügel …“, `[D4.1.garrick.morwen]`, ggf. `[D4.1.garrick.warnung]`, `KROGG_HINT` setzen. Spätere Gespräche bis Kroggs Fall wiederholen den Krogg-Teil wie bisher (ohne Begrüßung) | – |
| 27 | K | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Auf `main` bis 27m und D3.13a (#67). **D3.14:** Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1. 27n auf `main` (#71) | – |
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | **112 entschieden (Chef 17.10., 10:4x):** fünf Bilder neu malen nach den sieben Punkten (Vorgangsarchiv 112), **erst nach dem Meilenstein**; Vorlage zuerst an Homer messen, dann an den Chef · auf `main` mit #67 (0.1.753 „passt“); Durchsicht der Szene mit Knopf 100 durch den Chef offen: **Chef 17.10., 01:17: „T13, 13.4 habe ich ganz angesehen und es lief fehlerfrei durch.“** (keine Stichworte für 112) | – |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem (`LISTE-ABNAHME-KAPITEL1.md`) | Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen: Durchspielen durch den Chef nach #67: **Testbitte 13.5** (`chefsache/ansehen/t13-huehner.md`) | – |
| 62c | K | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | bis 62r auf `main`; 62i–62k mit 64; 62l später (62m bei Jerry mit 39) | – |
| 30 | K | Abstürze beim Testen (Technik) | beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste | – |
| 134.2 | K | **von Chef (17.10., 10:4x):** Gesten zum Zeichen 134.1 (Hand heben, herwinken, nicken; je Person Vorschlag Homer) | nach 134.1 | – |
