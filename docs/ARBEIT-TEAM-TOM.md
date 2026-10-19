# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (19.10., 23:19, „Tom – Rückläufer Build 38 (19.10., 22:04)“):** Build 38 freigegeben, PR #126 zusammengeführt (Rückläufer: 1). 215-Rückläufer (Haustür ist Wand, Klopfen nur über die Taste) auf `claude/tom-215-haustuer` (main eingeholt, Revert zurückgenommen), Kerntests grün, Standbild geprüft; fährt im nächsten Build. Kosten auf: 215. Nachfolger: Tom – nächster Build (215 Haustür).

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 215 | K | **von Chef (19.10., 13:37, über Sokrates):** Übergänge (Tür, Höhleneingang, Weg, Kartenrand) über den Aktionsknopf statt beim Betreten des Felds; Vorgangsarchiv 215, Zu 215 | gebaut: Rückläufer Build 38 (38.4) behoben, Zweig auf main nachgezogen, fährt im nächsten Build; Zu 215, B38 | `claude/tom-215-haustuer` |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | ruht: Chef spielt von selbst durch (13.5, Zu 26) | – |
| 30 | K | Abstürze beim Testen (Technik) | ruht bis zum nächsten Absturzbericht (`adb logcat`) | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | ruht bis Karten Kapitel 2; Kapitel 1 fertig, [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn); Querlink: [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer) | claude/tom-145-kartenmappe |
| 133 | K | Umsetzung 133: Charisma-Wahlen Kapitel 2, Gespräche (`STORY-WAHLEN.md`, Vorgangsarchiv 133) | wartet auf 41 (Kapitel 2 ist nicht im Spiel: keine Rabenschanze, kein Kultlager, kein Vesk, Ansel, Rask) und 49 (Fertigkeiten, ruht); geprüft 19.10. | – |
| 41.2 | K | Umsetzung 41.2: Ansel fährt nach N3 auch nachts (Vorgangsarchiv 41.2) | wartet auf 41 (Kapitel 2 ist nicht im Spiel) | – |

## Einzelheiten


- **Zu 26**: Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch; sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`). Zweig `claude/tom-145-kartenmappe` (nur `tools/preview`, Schalter `KARTENMAPPE=1`) wartet auf Kapitel 2.

- **Zu Build 38 (PR #126)**, Chef 19.10., 22:59 (an Sokrates): „Build 38 freigegeben“ → zusammenführen (Rückläufer in `CHANGELOG.md`), getestete Zeilen streichen; 215-Rückläufer (Haustür, Klopfen) fährt im nächsten Build, nicht in PR #126 nachschieben.
- **Zu 215, B38** (Chef 19.10., 22:38, an Sokrates, Bild: Held steht in der Hauswand an der Gasthaustür, Knopf „Zum Schlafenden Greif“): „Feedback zu Build 38: kartenübergang passt, aber Betreten von Häusern nicht, da der Held "ins Haus" läuft. Aber der Schalter kommt.. Klopfen an verschlossenen Häusern nicht bei hinlaufen, sondern ebenfalls erst bei Schalter.“ → Held bleibt vor der Tür stehen (Türfeld nicht begehbar, Knopf von davor); Klopfen an verschlossener Tür erst über den Aktionsknopf. Gebaut 19.10., 22:5x: Haustür (auch innen) ist Wand, Taste vom Feld davor, Name nur bei offener Tür; Standbild geprüft.
- **Zu 215** (Chef 19.10., 13:37: „215 A wie jetzt empfohlen“): heute wechselt `Game.afterStep` den Ort, sobald der Held auf das Warp-Feld tritt. Neu: der Aktionsknopf (`WorldScreen.kt`, `ActionButton`, rechts unten, Linkshänder links) bietet den Übergang an, mit eigenem Zeichen und dem Ziel als Schrift; erst Tippen wechselt. Gesperrte Übergänge (`requires`, `knock`, `turnBack`) wie heute. `WorldScreen.kt` nur nach Absprache (CLAUDE.md 6); Höhleneingänge mit Jerry abstimmen. Kür, nach den Muss. Gebaut 19.10., 14:38 (Zweig auf 216): alle Übergänge, auch Höhle; `WorldScreen.kt` nur die Schrift über der Taste (Wischsteuerung; im Steuerkreuz nur das Türzeichen); Jerry beim nächsten Start Bescheid geben. Tippen auf einen Übergang geht hin und hindurch. Prüfpunkt: Dorf, auf die Gasthaustür gehen: kein Wechsel, Taste zeigt Türzeichen und „Gasthaus …“; Tippen: drinnen; ebenso Höhleneingang und Kartenrand; gesperrte Tür klopft wie bisher.




