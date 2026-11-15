# 1270.1 · Messbitte: Ladezeit eines Kampfs und Bilder/s am Handy (Grundwert vor 1270.2)
Spike · 15.11., 11:00 · E Technik · aus 1270 A (Chef 15.11., 10:51)
Kurz: zwei Kämpfe hintereinander, nach jedem „Gerät zeigen“ kopieren und schicken; kein neuer Build nötig.

Geprüft an: [Stand `ae20d1719`](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/ae20d1719/godot/skripte/messung.gd) (Messung steht schon im Spiel: `godot/skripte/messung.gd` „Kampfort bereit nach“ und „Letzter Kampf“, gemessen in `spiel.gd` 751–808)

**Warum zwei Kämpfe:** der erste nach dem App-Start zeigt die Ladezeit kalt (Shader werden erst gebaut, dagegen hilft 1270.3), der zweite warm (Modelle werden trotzdem neu entschlüsselt und gebaut, dagegen hilft 1270.2). Der Unterschied sagt, welcher Hebel mehr bringt.

**Weg (Build 285 oder 286, wie installiert):**
1. App ganz schließen und neu öffnen, „Weiter“ mit deinem Spielstand.
2. Reiter „Test“ → Zeile 286.10 „Lage herstellen“ (Probekampf Wolfsrudel); ohne 286: Teleport „Wald“, ersten Wolf angreifen.
3. Etwa 30 Sekunden kämpfen (ein paar Züge, auch ein Hieb), Kampf zu Ende spielen oder fliehen.
4. Menü → Reiter „Test“ → „Gerät zeigen …“ → „Kopieren“, schicken.
5. Gleich danach Schritt 2 bis 4 noch einmal (zweiter Kampf, ohne App-Neustart).

**Gebraucht aus dem Text:** Zeilen „Kampfort bereit nach“ und „Letzter Kampf (…)“.

**Wenn möglich:** dasselbe auf dem Handy des Testers mit Ruckeln (Galaxy A22, `LISTE-TESTGERAETE.md`); das ist das schwächere Gerät, an dem 1270.2 und 1270.3 sich zeigen müssen.

Nach den Werten: Eintrag in `LISTE-TESTGERAETE.md`, Grundwert in 1270.2 und 1270.3, diese Datei weg.
