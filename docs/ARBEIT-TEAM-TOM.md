# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-TEAM.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).

**offen 20, davon A 0, wartet auf Chef 2**

**Übergabe (16.10., 07:54, „Tom – 38 Rauchbündel Dialoge“) – Nachfolger: „Tom – 104 Test 0.1.757“:** Build 0.1.757 grün, Testseite `e/t757.html` auf „Dein Zug“ (t753 entfernt). Nach „passt“ #71 zusammenführen, CHANGELOG, Zeilen streichen. Chef 16.10., 07:4x „0.1.753 passt“ → PR #67 zusammengeführt (443ba5bd), #66 geschlossen. **PR #71** (`claude/tom-38-rauchbuendel-dialoge`) = `main` + 86-Rest (D3.3, 89, 69f, 86.6/9/10) + 27n mit D1.7 + 38 + **104** (Nachfrage beim Überspringen; Kerntests grün, Oberfläche über die Vorschau übersetzt); abonniert (Nachfolger neu abonnieren). Prüfliste: Intro und Tempelszene antippen → „Überspringen?“, „Weiter ansehen“ lässt die Szene weiterlaufen; 69f wie zuvor; 86: am Lagerfeuer „Rasten?“, bei Rowena Met und Zimmer; 89 Held im Hausschatten dunkel; Funken am Lagerfeuer im Flüsterwald und in der Höhle senkrecht; Rauchbündel-Text in der Tasche.

## Zeilen

| Nr. | Thema | Stand | Zweig |
|---|---|---|---|
| 108 | **von Sokrates Projekt (16.10.):** „Dein Zug“ liegt jetzt im Repo: `docs/zug/entscheiden/`, `ansehen/` (Regeln `docs/zug/README.md`, `CLAUDE.md` 63); Sprungmarke `[72s.1](dz:72s1)`. Neue Punkte nur noch dort; die Seite (Artefakt) ist abgelöst. t757 ist umgezogen (`ansehen/t757-sammelbuild.md`); Zeile 63 „Freigabe für Jerry“ entfällt. | offen | – |
| 104 | Überspringen nachfragen (Chef 16.10., 07:4x: „Bei Zwischensequenzen (Intro, Outro) und Klick nachfrage, ob die Sequenz übersprungen werden soll. Viel zu schnell klickt man auf dem Handy (aus Versehen) rum, obwohl man gar nicht überspringen will...“) | gebaut (35993d00): Tippen fragt „Überspringen?“ (Überspringen / Weiter ansehen), Szene läuft weiter; **PR #71**, Test | `claude/tom-38-rauchbuendel-dialoge` · von Sokrates Projekt: `DESIGN-STIL.md` „Antippen überspringt“ (Zwischensequenzen) mit anpassen |
| 27 | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Auf `main` bis 27m und D3.13a (#67). **D3.14:** Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1. **27n** (292e1678) in **PR #71** | – |
| 92 | Bauer Bram blockiert an der Brücke den Weg (Chef 15.10., 16:5x; Idee: „Held muss NPC schieben können. Keine Gegner, aber neutrale.“) | Kerntest `MakeWayTest` fängt Held-gegen-Bram an der Brücke (Selbstarbeit erledigt, 23:1x); Test am Gerät mit 0.1.753 | – |
| 89 | Figuren im Schatten (Chef 15.10., 18:1x: „Wenn Figuren im Schatten eines Hauses oder Objekte stehen, können sie ja nicht hell sein … wenn das aber zu viel Detail und Rechenleistung frisst, dann lassen wir das“) | gebaut (31fb73ab), **PR #71** | `claude/tom-38-rauchbuendel-dialoge` |
| D3.3 | Rest Fichtenreihe im Tiefen Wald (Diogenes Lauf 3) | behoben (1984a990), **PR #71** | `claude/tom-38-rauchbuendel-dialoge` |
| 69 | Intro: Ankunft bei Nacht in Standbildern, endet im Gasthaus | Intro auf `main`; **69f** (0c27e7a8) in **PR #71** | `claude/tom-38-rauchbuendel-dialoge` |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | **112:** fällt gegen das Intro ab (Chef 16.10., 11:3x); nachziehen erst nach Vergleichsliste von Kreativ und Entscheid des Chefs · auf `main` mit #67 (0.1.753 „passt“); Durchsicht der Szene mit Knopf 100 durch den Chef offen | – |
| 38 | D4.1 Rauchbündel, Quest vor der Höhle über Morwen, Garrick warnt unter Stufe 3 (D4.1 A, Chef 15.10., 10:5x) | Auf `main` bis auf Taschentext (59f0f2c1), **PR #71** | `claude/tom-38-rauchbuendel-dialoge` |
| 95 | Atem: „Atem mit Anzeige (Balken rechts) hört man nicht und der Balken funktioniert nicht.“ (Chef 15.10., 16:5x) | Balken (95a) passt (Test 0.1.752); Keuchen bei Jerry. Von Team Jerry (16.10., 07:4x): `WorldScreen.kt` zwei Zeilen neben `Stamina.step` (`Panting.Breath`, PR #70); bei Einwand Zeile an Jerry | – |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem (`LISTE-KAPITEL1.md`) | Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Offen: Höhle (13e), Durchspielen durch den Chef nach #67 | – |
| 13e | Höhle „Ort fertig“ (Zuteilung des Chefs 14.10., 16:0x; bleibt bei Tom, D14.3) | D1.3/D1.11, D1.5, 13e.6 auf `main`; D1.7 (be636682) in **PR #71**; Helligkeitsregler bei Jerry (40); Mond mit D3.14 | – |
| 86 | Bewegung und Übersicht (Chef 14.10., 18:5x) | 86.1–86.4 auf `main`; 86.6/86.9/86.10 (70cea82d) in **PR #71**; Preise Met 2, Zimmer 5 Gold im Test eichen | `claude/tom-38-rauchbuendel-dialoge` |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | bis 62r auf `main`; 62i–62k mit 64; 62l später (62m bei Jerry mit 39) | – |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | „Alle“ erledigt (0.1.660); Vorrat je Laden bei Jerry mit 38/39 | – |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm (Technik) | Großteil auf `main`; Inhalt (24.6) bei Jerry | – |
| 30 | Abstürze beim Testen (Technik) | beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste | – |
| 5 | Dorf draußen, Dorfbewohner als Puppen | auf `main` bis 5.5 | – |
| 63 | Eine Seite „Dein Zug“ für alles Offene | steht; **wartet auf Chef:** Freigabe für Jerry (Teilen) am Fr. | – |
| – | Eigene Zeilen kürzen | Erledigtes ins Archiv | – |
| 40 | Helligkeitsregler (13e.6, „Wert mit Tom“) | von Team Jerry (16.10., 08:2x): PR #73 hebt Schwarz um höchstens 10 % Weiß (Schwarz → 26/255); Prüfzeichen Ton 10/255 auf Schwarz. Passt das zum dunkelsten gewollt sichtbaren Ton der Höhle (Umriss)? Sonst Wert in `core/.../audio/Mix.kt` (`SIGN`, `LIFT_MAX`) nennen | – |
| D6.4 | Fluss am Dorf rauscht (Jerry) | von Team Jerry (16.10., 08:57), zur Kenntnis: `WorldScreen.kt` neun Zeilen im Klangblock neben dem Froschchor (`RiverSound`, PR #76); bei Einwand Zeile an Jerry | – |
