# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-TEAM.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).

**offen 9, davon A 0, wartet auf Chef 2**

**Übergabe (16.10., 14:4x, „Tom – Eigene Zeilen kürzen“) – Nachfolger: keiner jetzt; nächster Start bei Rückmeldung des Chefs (0.1.781, 92 am Gerät; Rast t757 erledigt, Chef 12:2x):** Zeilen 5, 24, 59e, 95 gestrichen (Rest bei Jerry). D3 als PR #92 (0.1.781 grün), Prüfliste `t781-d3-monster.md`. Nachfolger: #92 neu abonnieren.

## Zeilen

| Nr. | Thema | Stand | Zweig |
|---|---|---|---|
| D3 | Übernahme von Jerry (118): D3.5, D3.6, D3.9 (Lautstärke), D3.12 | **PR #92 (Sammelbuild 5, 0.1.781 grün)**, Prüfliste `docs/zug/ansehen/t781-d3-monster.md`; **Chef 16.10., 17:49 (an Ford): „unter meinen To-Dos anzusehen, Tom, habe ich die Tests gemacht, die waren alle positiv. Da war nicht eine richtige Nummer dabei. Das ist so ein Bündel-Build.“** → passt; Wunsch: Testseite mit klarer Nummer; bei „passt“ zusammenführen, CHANGELOG | `claude/tom-118-uebernahme` |
| 27 | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Auf `main` bis 27m und D3.13a (#67). **D3.14:** Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1. 27n auf `main` (#71) | – |
| 92 | Bauer Bram blockiert an der Brücke den Weg (Chef 15.10., 16:5x; Idee: „Held muss NPC schieben können. Keine Gegner, aber neutrale.“) | **Test 0.1.791 nicht bestanden** (Chef 16.10., 16:2x: „92, Bram schubsen, bekomme ich anscheinend nicht hin. Auch keinen anderen … ich laufe dauerhaft gegen ihn … da passiert nichts, da bewegt sich nichts, da wird keine Position gewechselt.“). Prüfen: zählt Dauerlaufen als Anstoß (`PUSH_BUMPS` 2 in `Game.kt`), ist Bram an der Brücke ein Walker; `MakeWayTest` grün, am Gerät nicht | – |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | **112:** fällt gegen das Intro ab (Chef 16.10., 11:3x); nachziehen erst nach Vergleichsliste von Kreativ und Entscheid des Chefs · auf `main` mit #67 (0.1.753 „passt“); Durchsicht der Szene mit Knopf 100 durch den Chef offen | – |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem (`LISTE-KAPITEL1.md`) | Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Offen: Höhle (13e), Durchspielen durch den Chef nach #67 | – |
| 13e | Höhle „Ort fertig“ (Zuteilung des Chefs 14.10., 16:0x; bleibt bei Tom, D14.3) | D1.3/D1.11, D1.5, 13e.6 auf `main`; D1.7 auf `main` (#71); Helligkeitsregler bei Jerry (40); Mond mit D3.14 | – |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | bis 62r auf `main`; 62i–62k mit 64; 62l später (62m bei Jerry mit 39) | – |
| 30 | Abstürze beim Testen (Technik) | beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste | – |
| D3.10 | **von Team Jerry (16.10., 19:25), Absprache `WorldScreen.kt`:** für den Regenklang ändere ich dort nur die Klangschleife (neben Fluss: `rain`/`rainStream`, `RainSound`, Ausblenden im `finally`), sonst nichts | Einwand hier, sonst gilt ok; Zweig `claude/jerry-d3-rest` | – |
