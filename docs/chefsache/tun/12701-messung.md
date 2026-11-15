# 1270.1 · Messbitte: Ladezeit eines Kampfs und Bilder/s je Ort, auf dem Galaxy A22 des Testers und deinem A56
Spike · 15.11., 11:14 · E Technik · aus 1270 A (Chef 15.11., 10:51) und deinem Wort 11:04 (Messgerät A22)
Kurz: Weg für den Tester (und dich): drei Orte je 20 Sekunden, zwei Kämpfe, nach jedem Schritt „Gerät zeigen“ kopieren und schicken; kein neuer Build nötig.

Geprüft an: [Stand `ae20d1719`](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/ae20d1719/godot/skripte/messung.gd) (die Messung steht schon im Spiel: „Bilder je Sekunde“, „Ladezeit je Ort“, „Kampfort bereit nach“, „Letzter Kampf“)

**Was du tust:** den Weg unten an den Tester weitergeben, mit der APK von Build 286 ([Lauf 473](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43637577563/artifacts/14133442612)); seine fünf kopierten Texte an mich (Telegram genügt). Gern denselben Weg auf deinem A56.

**Weg (zum Weitergeben):**
1. App installieren und öffnen; im Hauptmenü siebenmal auf das Firmenzeichen unten tippen (schaltet den Testmodus an); neues Spiel oder „Weiter“.
2. Im Dorf etwa 20 Sekunden herumgehen. Dann Menü → Reiter „Test“ → „Gerät zeigen …“ → „Kopieren“, Text schicken.
3. Reiter „Test“ → Teleport „Wald“; 20 Sekunden gehen; kopieren und schicken wie in 2.
4. Im Wald das nächste Monster angreifen, etwa 30 Sekunden kämpfen, zu Ende spielen oder fliehen; kopieren und schicken.
5. Gleich noch einen Kampf wie in 4, ohne die App neu zu starten; kopieren und schicken.
6. Reiter „Test“ → Teleport „Höhle“; 20 Sekunden gehen; kopieren und schicken.

**Warum zwei Kämpfe:** der erste nach dem Start baut die Grafik erst auf (dagegen hilft 1270.3), der zweite lädt die Figuren trotzdem neu (dagegen hilft 1270.2). Der Unterschied zeigt, was mehr bremst.

Nach den Werten: Eintrag in `LISTE-TESTGERAETE.md`, Grundwert in 1270.2 und 1270.3, diese Datei weg.
