# 857a · Fertigkeit „Kräuterkunde“: heißt sie künftig „Kräutersammeln“?
Homer · 10.11., 13:09 · G Story · aus deinem Wort 13:01 beim Test t274.6 (Reiter „Fertigkeiten“)
Kurz: Kräuterkunde heißt künftig „Kräutersammeln“ (EN „Foraging“); Regel bleibt, nur der Name; Trankwirkung zieht zu Alchemie

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/7434b4a26 (`DESIGN-BRS.md` (63–64, 83, 180, 193, 233, 402–405, 445–446), `STORY-HANDBUCH-1.md` `[423.fert]`, `[423.herkunft.liste]`, `[423.fert.liste]`, `STORY-HANDBUCH-2.md` `[423.meister]`, `STORY-HANDBUCH-3.md` `[423.sammeln]`, `STORY-MENUE.md` 94, `godot/skripte/erschaffung_brs.gd` 66, `godot/regeln/talente.gd` 147, `LISTE-SIMULATION-444.md` Abschnitt 6; Fremdprüfung 13:08)

**Frage:** Im Reiter „Fertigkeiten“ steht unter Sammeln: Kräuterkunde, Bergbau, Angeln, Jagd. Die Regel dahinter passt schon: Sammeln bringt mehr Ausbeute, Brauen ist Alchemie (Handwerk). Falsch ist nur der Name, denn Kräuterkunde klingt nach Rezepten und Brauen. Welcher neue Name?

**Votum:** „857a A“: **Kräutersammeln**, englisch **Foraging**.

**Berührt:** Tom (Bau: Erschaffung, Heldenblatt, Talenttext, Prüfliste t274), Jerry (Simulation 444: Name ist dort Schlüssel in `werte.json` und `sim.py`, samt Tests), Sokrates (481: Trankwirkung „nach Rang in Kräuterkunde“ zieht zu Alchemie), Homer (Handbuch DE/EN, Menütexte, `DESIGN-BRS.md`, `DESIGN-BRS-ENTSCHEIDUNGEN.md` 81, `STORY-RUF-K1.md` Morwen)

**Begründung:** Dein Wort 13:01: „Ich sammle Kräuter und Pilze, ich kann angeln, da sammle ich Fische und ich jage, da sammle ich Tiere und ich klopfe Steine, da sammle ich Erze“; „[Kräuterkunde] wäre das Zubereiten von Tränken … unter Alchemie“; „eher etwas, was mit Rezepten und Erfolgswahrscheinlichkeiten bei der Zubereitung von Tränken zu tun hat“. Der Name soll also das Tun nennen wie Bergbau, Angeln, Jagd.

**Sachverhalt:**
- Gruppe Sammeln: Kräuterkunde, Bergbau, Angeln, Jagd; Kräuter, Pilze, Blüten gehören zu Kräuterkunde (`DESIGN-BRS.md` 83, 233).
- Herkünfte mit Kräuterkunde: Klosterschüler (Heilmagie, Heilkunde, Kräuterkunde), Kräutersammler (Kräuterkunde, Alchemie, Spähen) (`DESIGN-BRS.md` 63–64).
- Meisterschaft Alchemist: Hauptfertigkeit Alchemie, Zulieferfertigkeit Kräuterkunde, wie Schmied mit Schmieden und Bergbau (`DESIGN-BRS.md` 193, `[423.meister]`).
- Englisch heute uneinheitlich: „Herbalism“ (Erschaffung, Handbuch), „Herb lore“ (Talenttext).
- Handbuch nennt „Ernten“ für die ganze Gruppe („Sammeln beim Ernten, Angeln und Zerlegen“, `[423.fert]`), Erz eingeschlossen (`[423.sammeln]`).
- Simulation 444 rechnet die Trankwirkung als 0,5 + 0,05 × Kräuterkunde.

**Auswertung:**
- **A (Empfehlung) Kräutersammeln / Foraging:** sagt, was der Held tut; passt zur Herkunft Kräutersammler und zum Muster der Meisterschaften (Alchemie braucht Kräutersammeln wie Schmieden Bergbau); ein Name in DE und EN für alle Stellen. Kosten: reine Umbenennung, Bau bei Tom klein.
- **B Pflücken / Picking:** kurz, ein Tunwort wie Angeln; der Talenttext sagt schon „beim Pflücken“. Klingt klein für eine Fertigkeit bis Großmeister, „Picking“ ist schwach.
- **C Ernten / Harvesting:** heißt wie der Aktionsknopf, aber das Handbuch nennt so die ganze Gruppe samt Erz; verwechselbar.
- **D Kräuterkunde als eigene Wissensfertigkeit behalten, Sammeln daneben neu:** widerspricht deinem Wort (das Wissen um Rezepte gehört zu Alchemie) und bringt eine Fertigkeit mehr.
- **Stärkstes Gegenargument gegen A:** Mit dem Namen wandert auch die Trankwirkung von Kräuterkunde zu Alchemie (481). Der Klosterschüler beginnt ohne Alchemie, seine Tränke werden schwächer; die Siegquoten aus Abschnitt 6 (Kräutersammler 8–27 %, Klosterschüler 69–96 %) gelten dann nicht mehr und sind neu zu rechnen. Daneben: „Sammeln“ steht doppelt (Gruppe Sammeln, darin Kräutersammeln), Pilze und Blüten stecken nur mittelbar in „Kräuter“; „Foraging“ heißt auch Futtersuche.

**Folgerungen:** Bei A zieht Homer alle Notizen und Spieltexte nach (DE/EN) und schreibt den Bau an Tom (Name im Spiel) und an Jerry (Simulation, Neuberechnung); Sokrates stellt 481 auf Alchemie um. Klosterschüler behält Kräutersammeln als Startfertigkeit, wenn du nichts anderes sagst (Annahme von Homer). Alte Kotlin-Fassung (`Perks.kt`) bleibt unberührt.

Antwort: …
