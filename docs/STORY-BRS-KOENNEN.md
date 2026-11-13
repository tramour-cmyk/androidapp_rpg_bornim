# Kampfhandlungen und Zauber nach dem BRS (870.14)

Homer 10.11.; Teil von `STORY-BRS-KAMPF.md` (Grundsätze und Begriffe `[870.14.namen]` dort). Knopf „Können“ / “Abilities”.

## Kampfhandlungen der Fertigkeiten (870a 3 A)

Namen und Tipps; Liste, Wirkung und Zahlen legt Jerry mit 444 fest (870.3). Freigeschaltet mit Rang Geselle; „Kraft schöpfen“ für alle.

- `[870.14.hand.kraft]` Kraft schöpfen / Draw Strength: Einmal je Kampf: du atmest durch und holst dir Leben zurück. / EN: Once per battle: you catch your breath and win back some life.
- `[870.14.hand.einhaender]` Finte / Feint (Einhänder): Ein angetäuschter Hieb öffnet die Deckung; der nächste Schlag trifft leichter. / EN: A feigned cut opens the guard; your next blow lands more easily.
- `[870.14.hand.dolche]` Stich aus dem Hinterhalt / Ambush Stab (Dolche): Wer dich nicht kommen sieht, den trifft die Klinge härter. / EN: Against a foe who never saw you coming, the blade bites harder.
- `[870.14.hand.zweihaender]` Wuchtschlag / Crushing Swing (Zweihänder): Ein Schlag mit ganzem Gewicht, langsam und schwer. / EN: A blow with all your weight behind it, slow and heavy.
- `[870.14.hand.stange]` Auf Abstand / Hold at Bay (Stangenwaffen): Die Spitze hält den Gegner fern; wer trotzdem vorstürmt, läuft hinein. / EN: The point keeps the foe at bay; whoever charges anyway runs onto it.
- `[870.14.hand.stumpf]` Schädelstoß / Skull Knock (Stumpfe Waffen): Ein Schlag auf den Kopf, der betäuben kann. / EN: A blow to the head that can stun.
- `[870.14.hand.faust]` Griff / Grapple (Faustkampf): Du packst zu; der Gegner kommt nicht vom Fleck. / EN: You seize hold; the foe cannot move away.
- `[870.14.hand.schild]` Schildwall / Shield Wall (Schild; Vorform von Decken): Einen Zug lang fängt dein Schild einen Schlag ab, der einem Freund neben dir gilt. / EN: For one turn your shield takes a blow meant for a friend beside you.
- `[870.14.hand.bogen]` Ruhige Hand / Steady Hand (Bogen; Vorform von Zielschuss): Du hältst den Atem an; der nächste Pfeil trifft leichter. / EN: You hold your breath; your next arrow lands more easily.
- `[870.14.hand.armbrust]` Durchschlag / Punch Through (Armbrust): Der Bolzen geht durch Rüstung, als wäre sie Leder. / EN: The bolt goes through armor as if it were leather.
- `[870.14.hand.wurf]` Zwei auf einmal / Double Throw (Wurfwaffen): Zwei Würfe in einem Zug, jeder schwächer. / EN: Two throws in one turn, each weaker.
- Wehrhaltung (alte „Kampfstil Verteidigung“) nur, wenn Jerry sie als Handlung behält: `[870.14.hand.wehr]` Wehrhaltung / Guarded Stance: Du kämpfst vorsichtig; man trifft dich schwerer, du triffst seltener. / EN: You fight with care; you are harder to hit, and hit less often.

## Zauber (Schulen nach `DESIGN-BRS.md` 7, 12)

In `werte.json` stehen heute nur Funkenpfeil, Wundsegen, Bannschild; die übrigen gelten, sobald Jerry sie in die Fähigkeitentabelle aufnimmt (870.3). Tipps ohne Kosten und Zahlen; Wirkung wie heute im Code (`mars.gd`), weicht sie ab: Vorgang an Homer.

- `[870.14.zauber.funken]` Funkenpfeil / Spark Bolt (Evokation): Ein Funke, der sticht wie ein Pfeil. Feuer. / EN: A spark that stings like an arrow. Fire.
- `[870.14.zauber.arkan]` Arkanpfeil / Arcane Dart (Evokation): Ein Pfeil aus reiner Kraft; keine Art widersteht ihm. / EN: A dart of pure force; no kind resists it. (ohne Schadensart; Schaden zeigt keine Art)
- `[870.14.zauber.strahlen]` Glutstrahlen / Ember Rays (Evokation; ersetzt Sengender Strahl, Name neu für `DESIGN-BRS.md` 12): Drei Strahlen Glut, jeder auf ein Ziel deiner Wahl. Feuer. / EN: Three rays of embers, each at a target of your choice. Fire.
- `[870.14.zauber.faecher]` Flammenfächer / Flame Fan (Evokation): Feuer aus beiden Händen, gegen die ganze vordere Reihe. Feuer. / EN: Fire from both hands, against the whole front row. Fire.
- `[870.14.zauber.glut]` Glutkugel / Ember Orb (Evokation): Eine Kugel Glut, die in einer Reihe der Gegner zerplatzt. Feuer. / EN: An orb of embers that bursts in one row of foes. Fire.
- `[870.14.zauber.haut]` Arkanhaut / Arcane Skin (Schutzmagie): Eine Haut aus Kraft, die Schläge dämpft; hält bis zum Ende des Kampfes. / EN: A skin of force that dulls blows; it lasts until the battle ends.
- `[870.14.zauber.bann]` Bannschild / Ward (Schutzmagie): Einmal je Kampf: ein Schild aus Licht, der Schläge dämpft. / EN: Once per battle: a shield of light that dulls blows.
- `[870.14.zauber.wund]` Wundsegen / Woundmend (Heilmagie): Legt sich auf eine Wunde und schließt sie. / EN: Settles on a wound and closes it.
- `[870.14.zauber.gleiss]` Gleißstrahl / Glare Ray (Heilmagie): Ein Strahl grellen Lichts. Licht. / EN: A ray of harsh light. Light.
- `[870.14.zauber.beistand]` Beistand / Succor (Heilmagie): Du triffst leichter, eine Weile lang. / EN: You land blows more easily for a while.
- Der Goblin-Schamane heilt mit Wundsegen (`mars.gd` 1385); Meldung bleibt MSG72_HEALS.
