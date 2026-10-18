# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (18.10., 18:18, „Tom – 176a Zusammenführen (18.10., 18:04)“) – Nachfolger: Tom – 180 Fackel im Laden:** PR #116 (176a, 175) auf `main`, t27 gelöscht, CHANGELOG. 180-Fix auf `claude/tom-180-fackel-laden` (cf88c865): vor dem Build `main` einmischen; wartet auf Rückfrage 180a (einzeln als Build 29 oder Sammelbuild).

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 180 | M | Fackel im Laden nicht kaufbar (Chef, Build 25 und 27) | **jetzt (Chef 18.10.): einzeln bauen**, Fix und Kerntest fertig (Zu 180) | claude/tom-180-fackel-laden |
| 27 | K | Wald „Ort fertig“ | auf `main` bis 27m, D3.13a (#67); D3.14 erst mit 84.1 | – |
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | erst nach dem Meilenstein (112); Durchsicht Chef offen | – |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | Teil erledigt; Rest wartet auf Chef (13.5 Durchspielen) | – |
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
- **Zu 150** (Chef 17.10., 16:1x): „wenn der Spieler im Menü ist und irgendwas einstellt, das zählt nicht zur Spielzeit, oder?“ Antwort: zählt heute mit (nur App im Vordergrund mit geladenem Helden).
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`), Querlink zum roten Faden 144, Beginn Kapitel 1 und 2 (161). Kapitel 2 hat noch keine Karten; Link zu 144 nachtragen, sobald Homers Seite steht.

**Zu 175** (Chef 18.10., 14:46, Wortlaut, mit Bild des Testmodus): „Ruckeln beim Spielstart nach Blende Bornim...“ Testmodus im Bild: Letztes Ende der App 18.10., 14:44:40 „App aktualisiert“ (also frisch installiert, Build 24 vermutet); Blende: bereit nach –; Held ganz gezeichnet nach 5,8 s; Kampf bereit: Eröffnung –, Held –, Gegner –. Hinweis: gleiche Technik wie Vorgang der Blende (Tom); Ursache prüfen (Held-Zeichnung 5,8 s, Vorwärmen), nach frischer Installation und bei erstem Start getrennt messen. Perikles entscheidet Muss. Ursache (18.10., 16:4x): nach der Blende (Zeitgrenze 4 s, darum „bereit nach –“) zeichneten die Hintergrund-Threads ihre Zeilen auf allen Kernen mit normaler Priorität, trotz „niedriger“ Thread-Priorität; nach frischer Installation ist der gespeicherte Held weg (Ordner je Build), daher 5,8 s statt sofort. Messung am Rechner (4 Kerne): leise 1,7× langsamer, die fernen Gehbilder kommen also später (bis dahin Standbild der Richtung).

**Zu 176a/176** (Chef 18.10., 16:46, Wortlaut, mit Bild, Build 25): „Schattenproblem nur noch direkt vor Höhle, ansonsten klappt es überall.“ Bild: Tag 6 03:30, Magier mit Fackel vor dem Höhleneingang (Wald), vom Helden nach links oben ein scharf begrenzter dunkler Keil über Gras und Bäume, die Felswand rechts hell.

Chef 18.10., 16:55, Wortlaut: „Schattenproblem vor Höhle auch bei Leuchtfunken. Alles sonstige im Build 25 ging und ist freigegeben. Ergänzung: Wenn man schon eine Fackel hat, dann konnte ich im Laden keine zweite Fackel kaufen (oder war einfach nicht im Angebot).“

Chef 18.10., 17:11, Wortlaut: „Du kannst wegen des Schattenproblems auch einfach vor der Höhle von links nach rechts gehen, dann verändert sich der nicht da sein sollende Schattenwurf...“ (Prüfweg für t27).

Chef 18.10., 17:30, Wortlaut: „Build 27 getestet und freigegeben. Nur die Fackel kann ich nicht im Laden kaufen.“ (175, 176a freigegeben; 180 durchgefallen: Fix in `Game.buyGear` greift nicht, Laden-Oberfläche `ShopScreen.kt` prüfen, z. B. ob die Fackel im Angebot überhaupt erscheint oder der Kauf woanders gesperrt ist.)

**Zu 180** siehe Satz „Ergänzung“ oben: zweite Fackel im Laden nicht kaufbar, wenn eine getragen wird. Ursache (18.10., 18:1x): der Kauf in Build 25 steht im Spielstand als „verkauft“; der Fix in Build 27 verhinderte nur neue Einträge. Jetzt bleibt die Fackel immer im Angebot (`Game.shopGear`), Kerntest `anOldSaleDoesNotHideTheTorch` (scheitert ohne Fix). Rückfrage 180a (18.10., 18:1x): einzeln als Build bauen (Sammelbuild-Regel: nie ein Punkt allein) oder warten? **Chef (18.10.,, 18:5x, Wortlaut, aufgenommen von Sokrates):** „Witzig, dass 180a irgendwie für mich da sein soll. In meiner Chefvorlage gibt es kein 180a. Also wenn nichts vorgelegt ist, kann ich es nicht entscheiden.“ Sokrates: 180a beantwortet die Regel 99h.5 (nie ein Punkt allein, außer der Chef sagt „jetzt“) → 180 wartet auf den nächsten Sammelbuild, keine Frage an den Chef. **Chef (18.10., 18:5x, Wortlaut): „180 jetzt“** → 180 einzeln als Build bauen (Ausnahme „jetzt“ in 99h.5).

**Zu 176** (Chef 18.10., 15:13, Wortlaut, mit Bild): „Fackel bei Build 24 leuchtet nicht richtig aus. Auch im Gang in der Höhle wirkt es nicht richtig.“ Bild: Nacht, Tag 6 00:14, Magier mit Fackel am Höhleneingang; der Lichtkegel um die Fackel ist kaum zu sehen, Umgebung bis auf einen schmalen Streifen schwarz. Zum Test von Build 24 (t24, 84.1/84.5): Ergebnis „nicht in Ordnung“, nicht freigeben, bis behoben. Perikles entscheidet Muss.

**Zu 176, Nachtrag** (Chef 18.10., 15:15, Wortlaut, mit Bild): „Gibt auch für Leuchtfunken“ (gemeint: dasselbe Problem beim Leuchtfunken, 84.5). Bild: Nacht, Tag 6 01:17, Magier mit Leuchtfunke über dem Kopf (heller Punkt mit kleinem Hof), Umgebung kaum aufgehellt, Lichtkegel nicht erkennbar. Vorgang 176 umfasst Fackel und Leuchtfunke.

**Zu 176, Nachtrag 2** (Chef 18.10., 15:16, Wortlaut, mit Bild): „Dunkel in h HÖHLE“ (gemeint: in der Höhle ist es zu dunkel). Bild: Höhle, Tag 6 01:42, Magier mit Leuchtfunke; Umgebung nur schwach sichtbar, Lagerfeuer unten rechts, Truhe und Kristalle oben kaum erkennbar. Gehört zu 176 (Licht in der Höhle mit Fackel und Funke).

**Testergebnis Chef zu Build 24** (18.10., 15:19, Wortlaut): „Build 24 freigegeben. Bis auf die Screenshots und den Schatten“. → PR #114 (0.1.843) auf main zusammenführen, t24 löschen, CHANGELOG. Ausgenommen sind „die Screenshots“ und „der Schatten“; was damit gemeint ist, steht nicht im Wortlaut (vermutlich Standbilder der Fehler 175/176 und der Schatten der Fackel oder des Helden): zuerst aus der Prüfliste t24 und den Bildern des Chefs (176) klären, bei Zweifel als eigene Zeile anlegen und beim Chef einmal nachfragen. Licht in Wald und Höhle bleibt Vorgang 176.
