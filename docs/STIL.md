# Stil-Leitlinien

Gilt für **alle** künftigen Arbeiten und Überarbeitungen an Grafik, Animation und Klang. Stand: 07.10.2026, 13:20 (Berliner Zeit).

Siehe auch: [Offen](OFFEN.md) · [Merkliste](MERKLISTE.md) · [Änderungshistorie](../CHANGELOG.md)

## Richtung

- **Weg vom Nintendo- und Pokémon-Stil** (knuffig, quietschbunt, Spielzeug), **hin zu erwachsener, etwas düsterer Fantasy.**
- Bessere Grafik: echte Formen, Licht und Schatten, glaubwürdige Proportionen (Körpermaße, Waffengrößen nach realen Vorbildern).
- Bessere Übergänge: keine Sprünge zwischen Haltungen, Bewegungen gehen fließend ineinander über.
- Licht kommt von sichtbaren Quellen (Sonne, Mond, Fackeln, Feuer, Pilze, Fenster). Dunkelheit ist erlaubt.
- Blut und Wunden gehören dazu, abgestuft über die Menüeinstellung „Blut bei Treffern“ (Aus, Dezent, Deutlich), für Held und Gegner gleich.

## Abwechslung: mindestens drei Varianten

- **Kein Gegner sieht aus wie der vorige seiner Art.** Jede Gegnerart bekommt mindestens drei Varianten in Aussehen und Ausrüstung, zum Beispiel ein Goblin mit Krummsäbel und Schild, einer mit Speer, einer mit Keule und Helm. Dazu kommen Hautton, Fell oder Narben.
- **Die Werte bleiben gleich:** Varianten sind Optik. Schaden, Rüstungsklasse und Trefferpunkte kommen aus den Monsterdaten.
- **Jede Bewegung in mindestens drei Varianten:** Angriff, Treffer, Ausweichen und Sieg oder Niederlage, damit Kämpfe nicht gleichförmig wirken. Das gilt für Gegner wie für den Helden.
- **Kein Gegner verschwindet einfach:** Jede Gegnerart bekommt eigene Sterbeanimationen (mindestens drei), erst danach blendet sie aus. Ein tödlicher kritischer Treffer bekommt einen eigenen Killerschlag (siehe Liste [Offen](OFFEN.md) unter „Geplant“).
- **Größe und Körperbau variieren** im Rahmen des SRD, zum Beispiel Goblins 98–118 cm (Small), Skelette 160–185 cm, dazu schlank, normal oder kräftig. Größe, Körperbau, Ausrüstung und Hautton werden unabhängig voneinander gewählt.
- Die Variante wird beim Kampfbeginn aus dem Erscheinungsbild-Zufall des Gegners gewählt und bleibt für diesen Gegner im ganzen Kampf gleich.
- **Ausnahme Bosse:** Benannte Bosse (etwa Krogg, Grak, Grimmzahn) haben ein festes Aussehen ohne Varianten, damit man sie wiedererkennt; ihre Bewegungen haben trotzdem je drei Varianten.
- Gilt für alle künftigen Gegner, Tiere, Begleiter und Figuren.

## Ausrüstung der Gegner

- Feste Ausrüstung je Gegnerart nach SRD, in mindestens drei Varianten.
- Zustände wie „rostig“ (altes Eisen) und „grob“ (Holzschild aus Planken) sind reine Optik. Sie kommen nicht in Beute- oder Händlerlisten.
- Die Ausrüstung passt zum Angriffsnamen des Gegners, etwa „Morgenstern“ bei Krogg oder „Kurzbogen“ beim Goblin-Späher.

## Selbst prüfen, bevor etwas gezeigt wird

- Jede neue Animation, Haltung oder Waffe wird automatisch auf **Kollisionen** geprüft: Waffe durch Körper, Kopf, Beine oder Schild, Stab durch den Körper, Schild durch die Waffe. Für alle Völker, Geschlechter und Staturen.
  - Werkzeuge in der Vorschau (`tools/preview`): `CLASH=1`, `CLERICCLASH=1` und vergleichbare Prüfläufe; Ziel ist immer 0 Treffer.
- Jede Bewegung wird als Bildfolge angesehen, nicht nur ein Standbild: Ausholen, Treffer, Rückweg, Übergänge.
- Jeder Angriff ist sichtbar, auch ein Fehlschlag: Geschosse fliegen vorbei, Flammen schlagen neben dem Ziel ein.
- Umgang mit Waffen muss stimmen: Griff, Abstützen, Rückstoß, Haltung in Ruhe.

## Klang

- **Weg von quietschenden Chiptune- und Nintendo-Tönen, hin zu glaubwürdigen Geräuschen**: Stahl, Holz, Leder, Schritte, Feuer, Stimmen von Tieren.
- Mindestens drei Varianten je Geräusch, damit es nicht eintönig wird. Die Varianten sind echte Alternativen mit eigenem Charakter (z. B. Abwehr: Klonk auf Holz und Eisen, hölzernes Pochen, Klinge gegen Klinge), nicht nur dieselbe Aufnahme in anderer Tonhöhe. Im Spiel wird zufällig gewechselt.
- Zu neuen oder geänderten Klängen gibt es Hörproben zum Vergleich (Vorschau: `SOUNDS=NAME,…`).
- Was noch zu überarbeiten ist, steht in der Liste [Offen](OFFEN.md) unter „Geplant“.
