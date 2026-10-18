# Spieltexte: Kampf, Rast, Zustände

Texte, die in allen Kapiteln gelten und nicht zur Blende gehören (Regeln in `STORY-REGELN.md`). Höchstens etwa 15 KB.

## Kampfmeldungen MARS (72.10a.T, mit 72.10)

Zeilen im Kampfprotokoll (`Skirmish.kt` `Msg72`). Knapp, Gegenwart, ohne Ausrufezeichen außer beim Gegnerzug. Punkte immer „TP“ (wie Rast, Regeln, Leiste), nie „Lebenspunkte“. Trankname ohne Artikel in Klammern, weil „Großer Heiltrank“ sich sonst beugen müsste.

`[72.10a.T.zauber]` (Zauber, Kosten ZP oder Zaubertrick: Magier, Kleriker)
{0} wirkt {1}.
EN: {0} casts {1}.

`[72.10a.T.faehigkeit]` (Fähigkeit ohne Zauber: Kämpfer, Schurke, z. B. Zweiter Atem, Tatendrang, Finte)
{0} setzt {1} ein.
EN: {0} uses {1}.

`[72.10a.T.segen]` (Segnen)
{0} ist gesegnet.
EN: {0} is blessed.

`[72.10a.T.entgeht]` (Rettungswurf geschafft, Zauber ohne halben Schaden, z. B. Heilige Flamme)
{0} entgeht dem Zauber.
EN: {0} escapes the spell.

`[72.10a.T.heilt]` (heilt einen anderen)
{0} heilt {1}: +{2} TP.
EN: {0} heals {1}: +{2} HP.

`[72.10a.T.heiltsich]` (heilt sich selbst)
{0} heilt sich: +{1} TP.
EN: {0} heals: +{1} HP.

`[72.10a.T.trinkt]` (Trank selbst)
{0} trinkt ({1}): +{2} TP.
EN: {0} drinks a {1}: +{2} HP.

`[72.10a.T.reicht]` (Trank an einen Verbündeten)
{0} reicht {1} einen Trank ({2}): +{3} TP.
EN: {0} hands {1} a {2}: +{3} HP.

`[72.10a.T.keinezp]` (Zauber, zu wenig ZP)
Nicht genug Zauberpunkte.
EN: Not enough spell points.

`[72.10a.T.kampf]` (einmal pro Kampf, schon genutzt)
In diesem Kampf schon genutzt.
EN: Already used in this fight.

`[72.10a.T.rast]` (einmal pro Rast, z. B. Tatendrang)
Erst nach einer Rast wieder.
EN: Not again until you rest.

`[72.10a.T.wurf]` (Angriffswurf am Ziel; Abzug als „12 − 1“, nie „12 + -1“; bei 20 statt „Treffer“ „kritisch“)
{w} + {b} = {s} gegen RK {rk} · Treffer / daneben / kritisch
EN: {w} + {b} = {s} vs AC {rk} · hit / miss / critical

`[72.10a.T.rw]` (Rettungswurf des Ziels; Vorsilbe zeigt, dass das Ziel würfelt)
RW {w} + {b} = {s} gegen SG {sg} · geschafft / misslungen
EN: Save {w} + {b} = {s} vs DC {sg} · made / failed

Aus 72.10 geändert (übrige Platzhalter bleiben wortgleich):

`[72.10.ansetzen]` (Gegner zeigt Absicht) {0} setzt an: {1}. / EN: {0} readies: {1}.

`[72.10.bewusstlos]` {0} sinkt bewusstlos zu Boden. / EN: {0} sinks to the ground, unconscious.

`[72.10.kraft]` {0} sammelt Kraft: +{1} TP. / EN: {0} gathers strength: +{1} HP.

`[72.10.herbei]` (statt „Ein {0}“, passt für jedes Geschlecht) Verstärkung: {0} eilt herbei. / EN: Reinforcement: {0} comes running.

`[72.10.taumelt]` {0} taumelt: {1} vereitelt. / EN: {0} staggers: {1} foiled.

## Feuerball (72.14)

`[72.14.feuerball]` (Beschreibung `Rules.kt` FIREBALL, ersetzt „Verjagt Begleiter …“)
8W6 Feuerschaden, GES-Rettungswurf halbiert. Verjagt Rudel und Späher des Gegners, die ihren Rettungswurf nicht schaffen. Einmal pro Kampf.
EN: 8d6 fire damage, DEX save for half. Drives off the foe's pack and scouts that fail their save. Once per battle.

## Rast, Met, Zimmer (86)

`Resting.kt`; Platzhalter, die hier nicht stehen, bleiben wortgleich.

`[86.kurzwirkt]` Ausdauer voll, ein Viertel der TP zurück / EN: Stamina full, a quarter of HP back

`[86.langwirkt]` TP, ZP und Ausdauer voll, Zustände geheilt / EN: HP, SP and stamina full, conditions cured

`[86.zimmerwirkt]` Ein Bett für die Nacht: lange Rast / EN: A bed for the night: long rest

`[86.kurzfertig]` Eine Stunde Ruhe. Die Ausdauer ist voll, +{0} TP. / EN: An hour of rest. Your stamina is full, +{0} HP.

`[86.langfertig]` Acht Stunden Schlaf. TP, ZP und Ausdauer sind voll. / EN: Eight hours of sleep. HP, SP and stamina are full.

`[86.met]` (Met getrunken, noch nicht betrunken) Der Met wärmt. Die Ausdauer ist voll. / EN: The mead warms you. Your stamina is full.

`[86.metzuviel]` (der Met, der betrunken macht) Ein Met zu viel. Du bist betrunken bis zur nächsten Rast. / EN: One mead too many. You are drunk until your next rest.

`[86.rowena.met]` (Rowena, wenn das Feld „Schänke“ aufgeht; Wechsel mit `[86.rowena.zimmer]`)
Ein Met wärmt die Beine. Nach dem vierten findest du die Tür aber nicht mehr.
EN: A mead warms the legs. After the fourth, though, you won't find the door.

`[86.rowena.zimmer]`
Oben ist ein Zimmer frei. Frische Laken, und keiner schnarcht durch die Wand. Meistens.
EN: There's a room free upstairs. Fresh sheets, and nobody snores through the wall. Mostly.

`[86.rowena.genug]` (Held betrunken)
Genug für heute, {name}. Geh schlafen, die Treppe ist links.
EN: Enough for today, {name}. Go to bed, the stairs are on the left.

## Zustände außerhalb des Kampfs (86.9)

Wie die übrigen Zustände in `Status.kt` (Name, Kurzwort, Text), Zeichen in der oberen Leiste und im Kampf. Nicht „Vergiftet“ nennen: „Vergiftet“ heißt im Spiel Schaden jede Runde, das trifft hier nicht zu.

`[86.9.betrunken]` Betrunken · Kurz: Met · Angriffe und Flucht mit Nachteil, bis zur nächsten Rast.
EN: Drunk · Short: Mead · Attacks and fleeing at a disadvantage, until your next rest.

`[86.9.atem]` (Kampfzeile, wenn der Held außer Atem in den Kampf kommt) {0} ist außer Atem: Initiative mit Nachteil.
EN: {0} is out of breath: initiative at a disadvantage.
