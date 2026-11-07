# 275.2 · Regeltexte beim Umschalten (Perikles, 07.11.)

Diese Ersetzungen macht Perikles im Umschalt-Commit auf `main` mit Edit (nicht per Skript); Diogenes prüft sie im Quertest gegen die Werkzeuge. Regelbilanz: jede Zeile ersetzt eine alte, keine neue Regel.

## CLAUDE.md

1. „Wo was steht“, Punkt `ARBEIT-…` mit seinen drei Unterpunkten → zwei Punkte:
   - `ARBEIT-…` = **Vorrat** je Rolle (`-TEAM-TOM`, `-TEAM-JERRY`, `-KREATIV`, `-PROJEKT`, `-BERATUNG`, `-PRUEFUNG`): oben „Übergabe:“, ggf. „Pause bis …“ (Ford startet dann keine neue Arbeit, nur den Nachfolger einer Übergabe, 347); darunter „Zu <Nr.>“; keine Tabelle (275.2).
   - `LISTE-VORGAENGE.md` = **Vorgangsliste**, je Vorgang eine Zeile (Nr., Titel, Besitzer, Kl., Stand, wartet auf, Zweig, Build, Bereich, Kosten); nie ganz lesen: `python3 tools/vorgang.py --rolle <Rolle>`; schreiben nur mit `vorgang.py`. Zeilenfolge je Besitzer = Vorrang; Kl. **M** Muss (im Wochenziel oder Chef sagt „jetzt“, dann `„jetzt“ TT.MM., HH:MM` in den Titel, Wächter 383), **K** Kür, „M?“ (Perikles entscheidet); Kür nur, wenn kein Muss startbar; danach „nach Meilenstein“; Zahlen: `startbar.py --stand`.
   (Der alte Punkt `LISTE-VORGAENGE.md`: „je Vorgang eine Zeile (Bereich, Klasse, Kosten, ein Wort Stand)“ entfällt; `PROJEKTPLAN.md` bleibt als eigener Satz.)
2. „Wie wir zusammenarbeiten“ 5: „Vorgang in dessen Vorrat mit Absender („von Team Tom“)“ → „Vorgang mit dessen Rolle als Besitzer (`vorgang.py neu`, Absender im Titel oder als „Zu <Nr.>“)“.
3. „Nummern“: „und eine Zeile in `LISTE-VORGAENGE.md` (Bereich, Klasse)“ → „und eine Zeile in der Vorgangsliste (`vorgang.py neu` zählt und trägt ein)“.
4. „Jeder Text an einem Ort“: „Stand im Vorrat“ → „Stand in der Vorgangsliste“.
5. „Vorräte klein halten“, die zwei ersten Unterpunkte →
   - je Vorrat höchstens etwa 15 KB; Listenzeile höchstens 400 Zeichen, Stand ein Wort (275) und höchstens ein kurzer Zusatz;
   - Auftrag des Chefs und Einzelheiten als „Zu <Nr.>:“ im Vorrat; worauf ein Vorgang wartet, nur im Feld „wartet auf“ (Nummer, Rolle, Datum, `t<Build>`, `Chef` mit Datei; löst sich von selbst), nie im Text; nach dem Test eines Builds `vorgang.py build <n>` (275.2);

## Rollendateien und Listen (je „Start“)

- `ROLLE-ENTWICKLUNG.md` Start 1: „dein Vorrat bis „Einzelheiten“ ganz (…)“ → „`python3 tools/vorgang.py --rolle <NAME>` (deine Zeilen in Vorrangfolge, dazu fremde, die auf dich warten); dein Vorrat bis „Einzelheiten“ ganz (…)“, Rest unverändert.
- `ROLLE-PROJEKT.md` Start 1, `ROLLE-PRUEFUNG.md` Start 1, `ROLLE-BERATUNG.md` Start 1, `ROLLE-KREATIV.md` Start: hinter „dein Vorrat (…)“ jeweils „, deine Zeilen (`vorgang.py --rolle <Rolle>`)“.
- `LISTE-BETRIEB.md` Schritt 4: hinter „`WARNUNG …` → lautlos melden.“ einfügen „`GELÖST <Nr> | Rolle | … | an <id>` → `send_message` an `<id>`: „GELÖST <Nr>: wartet auf … erfüllt, startbar“ (bei `-` nichts: `lauf.py` startet die Rolle wie bei jeder startbaren Zeile); `lauf.py --sperre` hat die Zeile schon gesetzt (Automatik A, 275.2), Ford pusht die Notizen.“
- `LISTE-BAUEN-TESTEN.md` „Gemeinsamer Build“: hinter „öffnet einen PR und schreibt die Prüfliste“ einfügen „, trägt die Vorgänge ein (`vorgang.py build <n> --mit <Nr,…>`)“; „Zu jedem Build“: Prüfliste bekommt nach dem Test einen Abschnitt „## Ergebnis“ („- n.k ✓“, „- n.k ✗ <Fund>“, „- Rest ✓“), dann `vorgang.py build <n>` (Automatik B) vor dem Archiveintrag „tn“.
- `ROLLE-BERATUNG.md` 77 (Rückmeldung zu einer Vorlage): bleibt; „Stand auf „startbar“ setzen (`vorgang.py …`)“ gilt weiter.

## Vorräte (macht `umstellen.py`)

- Tabelle und „## Zeilen“ fallen weg, die Pause-Zeilen „Pause bis die neue Vorgangsliste läuft (275.2)“ auch.
- Jede alte Zeile steht wörtlich unter „## Alte Zeilen (bis 275.2)“ als „- **Alt <Nr>:** …“; `vorgang.py <Nr>` zeigt sie.
