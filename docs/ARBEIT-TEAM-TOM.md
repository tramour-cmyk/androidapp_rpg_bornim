# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (18.10., 16:40, „Tom – 176 Licht von Fackel und Funke (18.10., 15:44)“) – Nachfolger: Tom – 175 Ruckeln beim Spielstart:** 176 (Licht reicht so weit wie die Sicht, Schein wie Wandfackel; `MapLight.carriedSource`, `drawMapLight`) und 84.1T (Homers Texte) gebaut, mit 173 in Build 25 (PR #115, Zweig `claude/tom-173-met`, abonniert), Prüfliste t25. Rückfrage 176a (Schatten) im Chat gestellt. Nicht gebaut: Hinweis [84.5.rast] beim Aufwachen über `Cmd.Morning` (nur Rast über das Menü). Nach „passt“: PR #115 zusammenführen, t25 löschen, CHANGELOG.


## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 176 | M | Fackel und Leuchtfunke (84.1/84.5, Build 24) leuchten nicht richtig aus, auch im Höhlengang | Test: Build 25 (PR #115) mit 173, 84.1T, Prüfliste t25 | claude/tom-173-met |
| 176a | M? | Rückfrage an den Chef: „bis auf die Screenshots und den Schatten“ (Build 24), was ist gemeint? | wartet auf Chef (im Chat gefragt 18.10.) | – |
| 84.1T | M | von Homer: Texte Fackel und Leuchtfunke eingesetzt (Laden, an/aus, Funke, nach der Rast) | Test: Build 25 (PR #115), Prüfliste t25 | claude/tom-173-met |
| 175 | M | Ruckeln beim Spielstart nach der Blende „Bornim“ | offen (Zu 175) | – |
| 27 | K | Wald „Ort fertig“ | auf `main` bis 27m, D3.13a (#67); D3.14 erst mit 84.1 | – |
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | erst nach dem Meilenstein (112); Durchsicht Chef offen | – |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | Teil erledigt; Rest wartet auf Chef (13.5 Durchspielen) | – |
| 173 | M | Met: nach dem Hinweis „zu viel geschlafen“ kein Met mehr verkaufen (Feedback Build 21) | Test: Build 25 (PR #115), Prüfliste t25 | claude/tom-173-met |
| 62c | K | Karte: Lücken, Bekannte/Dienste, Beschriftung | bis 62r auf `main`; 62l später | – |
| 30 | K | Abstürze beim Testen (Technik) | beobachten | – |
| 150 | K | Spielzeit im Menü | beantwortet; Änderung nur auf Wunsch | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | Kapitel 1 fertig, [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn); Querlink: [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer) | claude/tom-145-kartenmappe |

## Einzelheiten


- **Zu 27:** Wald „Ort fertig“ (`DESIGN-ABNAHME.md`). D3.14: Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1. 27n auf `main` (#71).
- **Zu 68:** 112 entschieden (Chef 17.10., 10:4x): fünf Bilder neu malen nach den sieben Punkten (Vorgangsarchiv 112), erst nach dem Meilenstein; Vorlage zuerst an Homer messen, dann an den Chef. Auf `main` mit #67 (0.1.753 „passt“); Durchsicht der Szene mit Knopf 100 durch den Chef offen. Chef 17.10., 01:17: „T13, 13.4 habe ich ganz angesehen und es lief fehlerfrei durch.“ (keine Stichworte für 112).
- **Zu 26** (`LISTE-ABNAHME-KAPITEL1.md`): Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch (0.1.828 ist überholt); sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 62c:** Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p). 62i–62k mit 64; 62l später (62m bei Jerry mit 39).
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 173** (Chef 18.10., 13:5x, Feedback zu Bild 21, wörtlich): „Feedback zu Bild 21, alles läuft. Bitte nur berücksichtigen bei zu viel Met, dass kein Met mehr verkauft wird dann. Wenn der Hinweis kommt, du hast jetzt zu viel geschlafen, so ungefähr, dann kein Met mehr verkaufen.“ Sinn: Kommt in der Rast der Hinweis „zu viel geschlafen“, soll Rowena kein Met mehr verkaufen. Zeile gehört zu 86 (`Resting.kt`); Hinweistext wortgetreu aus `STORY-SPIEL.md` `[86.…]`, nichts erfinden.
- **Zu 150** (Chef 17.10., 16:1x): „wenn der Spieler im Menü ist und irgendwas einstellt, das zählt nicht zur Spielzeit, oder?“ Antwort: zählt heute mit (nur App im Vordergrund mit geladenem Helden).
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`), Querlink zum roten Faden 144, Beginn Kapitel 1 und 2 (161). Kapitel 2 hat noch keine Karten; Link zu 144 nachtragen, sobald Homers Seite steht.

**Zu 175** (Chef 18.10., 14:46, Wortlaut, mit Bild des Testmodus): „Ruckeln beim Spielstart nach Blende Bornim...“ Testmodus im Bild: Letztes Ende der App 18.10., 14:44:40 „App aktualisiert“ (also frisch installiert, Build 24 vermutet); Blende: bereit nach –; Held ganz gezeichnet nach 5,8 s; Kampf bereit: Eröffnung –, Held –, Gegner –. Hinweis: gleiche Technik wie Vorgang der Blende (Tom); Ursache prüfen (Held-Zeichnung 5,8 s, Vorwärmen), nach frischer Installation und bei erstem Start getrennt messen. Perikles entscheidet Muss.

**Zu 176** (Chef 18.10., 15:13, Wortlaut, mit Bild): „Fackel bei Build 24 leuchtet nicht richtig aus. Auch im Gang in der Höhle wirkt es nicht richtig.“ Bild: Nacht, Tag 6 00:14, Magier mit Fackel am Höhleneingang; der Lichtkegel um die Fackel ist kaum zu sehen, Umgebung bis auf einen schmalen Streifen schwarz. Zum Test von Build 24 (t24, 84.1/84.5): Ergebnis „nicht in Ordnung“, nicht freigeben, bis behoben. Perikles entscheidet Muss.

**Zu 176, Nachtrag** (Chef 18.10., 15:15, Wortlaut, mit Bild): „Gibt auch für Leuchtfunken“ (gemeint: dasselbe Problem beim Leuchtfunken, 84.5). Bild: Nacht, Tag 6 01:17, Magier mit Leuchtfunke über dem Kopf (heller Punkt mit kleinem Hof), Umgebung kaum aufgehellt, Lichtkegel nicht erkennbar. Vorgang 176 umfasst Fackel und Leuchtfunke.

**Zu 176, Nachtrag 2** (Chef 18.10., 15:16, Wortlaut, mit Bild): „Dunkel in h HÖHLE“ (gemeint: in der Höhle ist es zu dunkel). Bild: Höhle, Tag 6 01:42, Magier mit Leuchtfunke; Umgebung nur schwach sichtbar, Lagerfeuer unten rechts, Truhe und Kristalle oben kaum erkennbar. Gehört zu 176 (Licht in der Höhle mit Fackel und Funke).

**Testergebnis Chef zu Build 24** (18.10., 15:19, Wortlaut): „Build 24 freigegeben. Bis auf die Screenshots und den Schatten“. → PR #114 (0.1.843) auf main zusammenführen, t24 löschen, CHANGELOG. Ausgenommen sind „die Screenshots“ und „der Schatten“; was damit gemeint ist, steht nicht im Wortlaut (vermutlich Standbilder der Fehler 175/176 und der Schatten der Fackel oder des Helden): zuerst aus der Prüfliste t24 und den Bildern des Chefs (176) klären, bei Zweifel als eigene Zeile anlegen und beim Chef einmal nachfragen. Licht in Wald und Höhle bleibt Vorgang 176.
