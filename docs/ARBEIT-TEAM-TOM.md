# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (18.10., 14:46, „Tom – 173 Met nach ‚zu viel geschlafen‘ (18.10., 14:40)“) – Nachfolger: keiner (Vorrat ohne startbare Zeile):** 173 auf `claude/tom-173-met` (enthält PR #111): betrunken kein Met-Knopf mehr, Rowena sagt nur „Genug für heute“ (`[86.rowena.genug]`, vorhandener Text), `drinkMead` nimmt dann kein Gold; Kerntest dazu, Kerntests grün. Kein eigener Build (nie ein Punkt allein): fährt im nächsten Tom-Build mit; wird PR #111 vorher zusammengeführt, Zweig auf `main` mergen. Build 23 freigegeben und zusammengeführt (15:0x); Builds 21, 24 warten auf den Chef.


## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 176 | M? | Fackel (84.1/84.5, Build 24) leuchtet nicht richtig aus, auch im Höhlengang | offen (Zu 176) | – |
| 175 | M? | Ruckeln beim Spielstart nach der Blende „Bornim“ | offen (Zu 175) | – |
| 84.5 | M? | Leuchtfunke (Fläschchen, endet bei Rast, Taste zum Löschen) mit der Fackel 84.1 in einem Bau (Vorgangsarchiv 84.5) | wartet auf Test: Build 24 (0.1.843, PR #114, mit 84.1) | claude/tom-84-lichttrank |
| 84.1 | M? | Fackel als Gegenstand: Laden, Nebenhand (kein Schild), Licht warm, heller als der Funke (13e.6, 84.5) | wartet auf Test: Build 24 (0.1.843, PR #114, mit 84.5) | claude/tom-84-lichttrank |
| 114 | K | Aufwachen am Bett im Gasthaus | wartet auf Test: Build 21 (PR #111, mit 139, 86) | claude/tom-139-fleisch |
| 27 | K | Wald „Ort fertig“ | auf `main` bis 27m, D3.13a (#67); D3.14 erst mit 84.1 | – |
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | erst nach dem Meilenstein (112); Durchsicht Chef offen | – |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | Teil erledigt; Rest wartet auf Chef (13.5 Durchspielen) | – |
| 173 | M? | Met: nach dem Hinweis „zu viel geschlafen“ kein Met mehr verkaufen (Feedback Build 21) | fertig im Zweig (auf PR #111), wartet auf Sammelbuild (nächster Tom-Build) | claude/tom-173-met |
| 139 | M | Fleisch an die Wirtin (Rowena) verkaufen | wartet auf Test: Build 21 (PR #111, mit 114, 86) | claude/tom-139-fleisch |
| 62c | K | Karte: Lücken, Bekannte/Dienste, Beschriftung | bis 62r auf `main`; 62l später | – |
| 30 | K | Abstürze beim Testen (Technik) | beobachten | – |
| 86 | K | Wortlaut Rast, Met, Zimmer, Rowenas Zeilen in `Resting.kt` | wartet auf Test: Build 21 (PR #111, mit 139, 114) | claude/tom-139-fleisch |
| 150 | K | Spielzeit im Menü | beantwortet; Änderung nur auf Wunsch | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | Kapitel 1 fertig, [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn); Querlink: [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer) | claude/tom-145-kartenmappe |

## Einzelheiten

- **Zu 84.1/84.5** (Zuschnitt Tom 18.10.): 84.1 ist durch 13e.6 und 84.5 („nicht ohne Fackel bauen“) gedeckt, darum eigene Zeile hier. Gebaut: Fackel im Laden (Nebenhand, nimmt den Schild), Sicht nachts/Höhle etwa 6,5; Leuchtfunke 25 Gold, Sicht etwa 5,5, jagende Monster bemerken 2 Felder früher, Taste „löschen“, endet bei jeder Rast. Nicht gebaut: Abbrennen, Tiere schrecken (Ideenspeicher „Licht als Mechanik“), D3.14 (27). Preis der Fackel vorläufig, Texte Platzhalter bis Homer (Zeile dort).

- **Zu 114** (Chef 18.10.: „114 ja“): Aufwachen am Bett im Gasthaus; 114.1 Aufstehsequenz zurückgestellt (`LISTE-IDEEN.md`).
- **Zu 27:** Wald „Ort fertig“ (`DESIGN-ABNAHME.md`). D3.14: Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1. 27n auf `main` (#71).
- **Zu 68:** 112 entschieden (Chef 17.10., 10:4x): fünf Bilder neu malen nach den sieben Punkten (Vorgangsarchiv 112), erst nach dem Meilenstein; Vorlage zuerst an Homer messen, dann an den Chef. Auf `main` mit #67 (0.1.753 „passt“); Durchsicht der Szene mit Knopf 100 durch den Chef offen. Chef 17.10., 01:17: „T13, 13.4 habe ich ganz angesehen und es lief fehlerfrei durch.“ (keine Stichworte für 112).
- **Zu 26** (`LISTE-ABNAHME-KAPITEL1.md`): Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch (0.1.828 ist überholt); sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 139** (Chef 17.10., 22:4x: Muss; von Perikles aus dem Ideenspeicher, 137): Fleisch an die Wirtin (Rowena) verkaufen, heute nur Thessa und Morwen.
- **Zu 62c:** Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p). 62i–62k mit 64; 62l später (62m bei Jerry mit 39).
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 173** (Chef 18.10., 13:5x, Feedback zu Bild 21, wörtlich): „Feedback zu Bild 21, alles läuft. Bitte nur berücksichtigen bei zu viel Met, dass kein Met mehr verkauft wird dann. Wenn der Hinweis kommt, du hast jetzt zu viel geschlafen, so ungefähr, dann kein Met mehr verkaufen.“ Sinn: Kommt in der Rast der Hinweis „zu viel geschlafen“, soll Rowena kein Met mehr verkaufen. Zeile gehört zu 86 (`Resting.kt`); Hinweistext wortgetreu aus `STORY-SPIEL.md` `[86.…]`, nichts erfinden.
- **Zu 86** (von Homer, 18.10.): Wortlaut Rast, Met, Zimmer und Rowenas Zeilen dazu wortgetreu in `Resting.kt` (`[86.…]` in `STORY-SPIEL.md`); „betrunken (Vergiftet)“ entfällt (86.9 bei Jerry).
- **Zu 150** (Chef 17.10., 16:1x): „wenn der Spieler im Menü ist und irgendwas einstellt, das zählt nicht zur Spielzeit, oder?“ Antwort: zählt heute mit (nur App im Vordergrund mit geladenem Helden).
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`), Querlink zum roten Faden 144, Beginn Kapitel 1 und 2 (161). Kapitel 2 hat noch keine Karten; Link zu 144 nachtragen, sobald Homers Seite steht.

**Zu 175** (Chef 18.10., 14:46, Wortlaut, mit Bild des Testmodus): „Ruckeln beim Spielstart nach Blende Bornim...“ Testmodus im Bild: Letztes Ende der App 18.10., 14:44:40 „App aktualisiert“ (also frisch installiert, Build 24 vermutet); Blende: bereit nach –; Held ganz gezeichnet nach 5,8 s; Kampf bereit: Eröffnung –, Held –, Gegner –. Hinweis: gleiche Technik wie Vorgang der Blende (Tom); Ursache prüfen (Held-Zeichnung 5,8 s, Vorwärmen), nach frischer Installation und bei erstem Start getrennt messen. Perikles entscheidet Muss.

**Zu 176** (Chef 18.10., 15:13, Wortlaut, mit Bild): „Fackel bei Build 24 leuchtet nicht richtig aus. Auch im Gang in der Höhle wirkt es nicht richtig.“ Bild: Nacht, Tag 6 00:14, Magier mit Fackel am Höhleneingang; der Lichtkegel um die Fackel ist kaum zu sehen, Umgebung bis auf einen schmalen Streifen schwarz. Zum Test von Build 24 (t24, 84.1/84.5): Ergebnis „nicht in Ordnung“, nicht freigeben, bis behoben. Perikles entscheidet Muss.
