# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (20.10., 07:4x, „Tom – Rückläufer Build 39 (20.10., 07:07)“):** Build 39 zusammengeführt (PR #127, Rückläufer: 1), t39 gelöscht. 215.1 Klopfen gebaut auf `claude/tom-215-1-klopfen` (Kenney-CC0, `tools/klang/klopfen.py`, Kerntest in `FreeWalkTest`), wartet auf den nächsten Sammelbuild (nicht allein). Alte Notiz-Kopie hatte 11 ungepushte Commits vom 19.10., 21:4x (Sokrates 211.10, Tom 224/38): lokal als Zweig `sicherung-alt-1910` in `bornim-main`, inhaltlich durch spätere Commits abgelöst. Nachfolger: Tom – Sammelbuild 40er.

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 215.1 | K | **von Chef (20.10., 06:42, über Sokrates):** Klopfgeräusch, wenn der Held per Aktionstaste an eine verschlossene Tür klopft | wartet auf Build (gebaut 20.10., fährt im nächsten Sammelbuild mit) | `claude/tom-215-1-klopfen` |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | ruht: Chef spielt von selbst durch (13.5, Zu 26) | – |
| 30 | K | Abstürze beim Testen (Technik) | ruht bis zum nächsten Absturzbericht (`adb logcat`) | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | ruht bis Karten Kapitel 2; Kapitel 1 fertig, [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn); Querlink: [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer) | claude/tom-145-kartenmappe |
| 133 | K | Umsetzung 133: Charisma-Wahlen Kapitel 2, Gespräche (`STORY-WAHLEN.md`, Vorgangsarchiv 133) | wartet auf 41 (Kapitel 2 ist nicht im Spiel: keine Rabenschanze, kein Kultlager, kein Vesk, Ansel, Rask) und 49 (Fertigkeiten, ruht); geprüft 19.10. | – |
| 41.2 | K | Umsetzung 41.2: Ansel fährt nach N3 auch nachts (Vorgangsarchiv 41.2) | wartet auf 41 (Kapitel 2 ist nicht im Spiel) | – |

## Einzelheiten


- **Zu 26**: Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch; sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`). Zweig `claude/tom-145-kartenmappe` (nur `tools/preview`, Schalter `KARTENMAPPE=1`) wartet auf Kapitel 2.





