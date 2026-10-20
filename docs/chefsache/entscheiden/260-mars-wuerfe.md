# 260 · MARS: Würfe mit eigenem Knopf, über allem, sanft ausblenden
Sokrates · 20.10., 18:05 · G Kampf · K (Chef 20.10., 18:00: „… da brauchen wir wie fürs Gitter so einen halbtransparenten An- und Ausknopf, weil mancher will das gar nicht sehen … das muss über allen anderen Anzeigen liegen, also auch über der Absicht der Monster. Es muss definitiv ein Ticken länger eingeblendet werden und dann … sanft ausgeblendet … auch die anderen Sachen, Namen und so“; Wortlaut ganz in `ARBEIT-TEAM-JERRY.md` Zu 260)

## Befund (Code `SkirmishScreen.kt`, `TestTab.kt` auf `main`)

- Schalter gibt es schon, nur im Test-Reiter („Würfe im Kampf zeigen“, Standard an, `vm.showRolls`).
- Der Wurf (`RollTag`) wird vor den Absichten gezeichnet; die Absicht liegt darüber.
- Er steht 1,5 s (`ROLL_MS`) und ist dann schlagartig weg; Namen ebenso.

## Vorschlag

1. **Knopf im Kampfort** neben dem Raster-Knopf unten rechts, halbtransparent, Würfel als Zeichen, an = heller; schaltet `showRolls`, Wahl gespeichert; der Eintrag im Test-Reiter fällt weg. Verschwindet wie der Raster-Knopf, solange Ring, Hinweis oder Urteil unten zu sehen sind.
2. **Wurf über allem,** auch über den Absichten.
3. **Etwa 2,5 s statt 1,5 s,** dann in etwa 0,4 s weich ausblenden; ebenso Namen, Urteil („Gut“/„Perfekt“) und Hinweise.
4. **Standard an,** solange die Tester die Regeln von MARS bewerten (249); vor dem Marktstart neu ansehen.

## Empfehlung

**Ja zu 1 bis 4.** *Stärkstes Gegenargument:* Ein zweiter Knopf nimmt auf dem kleinen Bildschirm Platz, und die meisten stellen so etwas nur einmal ein; dafür genügte ein Eintrag in den Einstellungen. Dagegen: Tester wollen im Spiel zwischen „mit Zahlen“ und „ohne“ vergleichen, beim Raster hat sich der Knopf bewährt. *Zweiter Einwand:* Ganz oben verdeckt der Wurf 2,5 s lang eine Absicht; vertretbar, weil die Absicht danach stehen bleibt.

**Widerspruch zu Entschiedenem:** keiner; 229 (Raster-Knopf) ist das Vorbild, 211.15 (Namen nur bei Zielwahl und langem Druck) bleibt, nur das Verschwinden wird weich. Kosten: klein, fährt in einem Jerry-Build mit.

## Antwort

„260 ja“, „260 Standard aus“ oder „nein“.

**Berührt:** 229, 211.15, 249.
