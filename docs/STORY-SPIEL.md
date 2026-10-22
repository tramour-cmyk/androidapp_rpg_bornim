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

`[203.abwehr]` {0} geht in Abwehrhaltung. / EN: {0} takes a defensive stance. (wie im alten Kampf, 203)

## Gegner mit Absichten (130.3, MARS)

Vier Gegner, je zwei Absichten; jede verlangt eine andere Antwort, damit keine Taste immer richtig ist. Je Absicht: **Name** (für `{1}` in „{0} kündigt an: {1}.“), **Zeichen** (eine Zeile direkt danach: was man sieht), **Folge** (wenn die Antwort sitzt bzw. die Absicht wirkt). Die Spalte „Antwort“ ist Homers Vorschlag für den Bau; Zahlen und Balance entscheidet der Chef.

| Gegner | Absicht | Antwort |
|---|---|---|
| Grak | Schwerer Hieb · Rudel rufen · Kraft sammeln | Abwehr und den Ring treffen, oder vorher hart zuschlagen · Anführer treffen · angreifen |
| Wolf (zu zweit oder dritt) | Anspringen · Einkreisen | Platz tauschen · den Leitwolf treffen |
| Riesenspinne (hintere Reihe) | Gift sammeln · Netz werfen | angreifen, bevor es wirkt · ausweichen (Ring) |
| Goblin-Späher (hintere Reihe) | Anlegen · In den Schatten | Abwehr (ducken) · jetzt angreifen |

Zeichen und Kampfzeilen ortsneutral (230): derselbe Gegner kämpft im Wald und in der Höhle; kein Wald, keine Bäume, kein Holz im Text.

**Grak** (Name und Werte bleiben, nur Zeichen neu)

`[130.3.grak.hieb]` (geändert 280: Grak trägt eine Kriegsaxt, `LISTE-FIGUREN.md`) Zeichen: Er reißt die Axt hinter den Kopf. / EN: He hauls the axe back behind his head.
`[130.3.grak.rudel]` (geändert 230, ortsneutral) Zeichen: Er stampft und brüllt nach seinem Rudel. Irgendwo antwortet Kreischen. / EN: He stamps and bellows for his pack. Somewhere, shrieks answer.
`[130.3.grak.kraft]` Zeichen: Er weicht zurück und atmet schwer, die Narben glühen. / EN: He falls back, breathing hard, his scars aglow.

**Wolf**

`[130.3.wolf.sprung]` Name: Anspringen (auf {2}) / EN: Pounce (at {2}). Zeichen: Er duckt sich flach, die Augen auf {2}. / EN: He crouches low, eyes on {2}.
`[130.3.wolf.sprung.leer]` (Ziel hat den Platz getauscht) Der Sprung geht ins Leere. / EN: The pounce lands on nothing.
`[130.3.wolf.sprung.um]` (trifft; ersetzt durch `[279.wolf.sprung.um]`) {0} reißt {1} zu Boden. / EN: {0} drags {1} to the ground.
`[130.3.wolf.kreis]` Name: Einkreisen / EN: Circle. Zeichen: Die Wölfe ziehen auseinander, einer bleibt zurück und knurrt. / EN: The wolves spread out; one hangs back, growling.
`[130.3.wolf.leit]` (Name des zurückbleibenden Wolfs) Leitwolf / EN: Pack leader
`[130.3.wolf.kreis.zu]` (wirkt) Der Kreis schließt sich. Die Wölfe greifen gemeinsam an. / EN: The circle closes. The wolves strike together.
`[130.3.wolf.kreis.auf]` (Leitwolf getroffen) Der Leitwolf jault. Das Rudel zögert. / EN: The pack leader yelps. The pack hesitates.

**Riesenspinne**

`[130.3.spinne.gift]` Name: Gift sammeln / EN: Gather venom. Zeichen: Gift tropft von ihren Kieferklauen, sie zielt auf {2}. / EN: Venom drips from her fangs; she takes aim at {2}.
`[130.3.spinne.gift.los]` (wirkt) Ein Strahl Gift trifft {1}. / EN: A jet of venom strikes {1}.
`[130.3.spinne.gift.weg]` (vorher hart getroffen) Sie zuckt zusammen, das Gift versickert im Moos. / EN: She flinches; the venom soaks into the moss.
`[130.3.spinne.netz]` Name: Netz werfen / EN: Cast web. Zeichen: Sie hebt den Hinterleib, ein Faden spannt sich. / EN: She raises her abdomen; a thread pulls taut.
`[130.3.spinne.netz.fest]` (trifft) {1} hängt im Netz fest und verliert den nächsten Zug. / EN: {1} is caught in the web and loses the next turn.

**Goblin-Späher**

`[130.3.spaeher.anlegen]` Name: Anlegen (auf {2}) / EN: Take aim (at {2}). Zeichen: Die Sehne knarrt. Die Pfeilspitze sucht {2}. / EN: The bowstring creaks. The arrowhead seeks {2}.
`[130.3.spaeher.duckt]` (Ziel in Abwehr; geändert 230, ortsneutral) {1} duckt sich, der Pfeil zischt vorbei. / EN: {1} ducks; the arrow hisses past.
`[130.3.spaeher.schatten]` Name: In den Schatten / EN: Into the shadows. Zeichen (geändert 230, ortsneutral): Er huscht zurück ins Dunkel. / EN: He slips back into the dark.
`[130.3.spaeher.weg]` (nicht angegriffen) Er ist verschwunden. Der nächste Pfeil kommt von irgendwo. / EN: He is gone. The next arrow comes from somewhere.

Platzhalter: {0} Gegner, {1} getroffene Figur, {2} angepeilte Figur.

## Absichten gegen die Aufstellung (72.10a.8, MARS)

Ersetzt den vorläufigen Wortlaut in `Skirmish.kt` (`Msg72.breaksThrough`, `braced`, `flankEmpty`); die Namen „Durchbrechen“ und „Flanke“ bleiben. Zeichen wie bei 130.3 direkt nach der Ankündigung.

`[72.10a.8.bruch]` Zeichen (Grak, Durchbrechen): Er senkt die Schulter. Sein Blick geht an der vorderen Reihe vorbei, zu {2}. / EN: He lowers his shoulder. His eyes slide past the front row to {2}.
`[72.10a.8.flanke]` Zeichen (Goblin, Flanke): Er löst sich aus der Reihe und schleicht seitlich auf {2} zu. / EN: He slips out of the line and creeps sideways toward {2}.
`[72.10a.8.bruch.durch]` (wirkt; {1} ist die nach hinten gestoßene Figur) {0} bricht durch und stößt {1} nach hinten. / EN: {0} breaks through and shoves {1} back.
`[72.10a.8.bruch.vorn]` (Ziel ist selbst vorgetreten; danach der gewöhnliche Schlag) {1} stellt sich {0} vorn entgegen. Kein Durchkommen. / EN: {1} meets {0} at the front. No way through.
`[72.10a.8.flanke.leer]` (Ziel hat den Platz getauscht) {0} schleicht um die Reihe, doch {1} ist nicht mehr dort. / EN: {0} creeps round the line, but {1} is gone.
`[72.10a.8.halb]` (Zusatz am Zug nach dem Tausch) · halber Zug / EN: · half a turn

## Varianten der Kampfzeilen (279, MARS)

Chef 21.10., 15:27 (an Sokrates, Wortlaut): „Feedback zu Mars. Die Textausgabe könnte ja auch mal variieren inhaltlich, leicht, dass es nicht 50 mal die gleichen Sätze sind. Vor allem beim Wolf fällt es halt auf, wenn drei Wölfe sind und die immer ständig das Gleiche machen. Wäre schon schön, wenn man da auch vielleicht eine gewisse Textvarianz reinbekäme. Nach unserem alten Motto, mindestens drei Varianten.“
Chef 16:21 (Wortlaut): „Glorreiche Idee für Mars. Also nee, für die Animation, wenn es heißt, der Held oder wer auch immer fällt zu Boden. Die erste Alternative wäre schon mal, also er fällt nicht zu Boden, sondern wir schreiben, er geht zu Boden. Und dann soll er auch nicht tot umfallen, weil das sieht extrem komisch aus, sondern abknien. Er kann dann auf einem Knie knien, er kann auf dem linken Knie knien, er kann auf dem rechten Knie knien, er kann auf beiden Knien knien oder halt dann sozusagen auf seinen Unterschenkeln absitzen auf dem Boden. Das wäre cool, weil dann unterscheidet sich das auch von dieser Flunz, er liegt einfach da, Animation, die sieht ein bisschen komisch aus. Also, er geht zu Boden, er sinkt nieder, er ist kurz, wie auch immer. Und dann eben drei verschiedene Formen von Abknien. Es sollten andere Animationen sein, als er ist tot.“ 16:24: „Er kam bei dieser Abknieklamotte auch einfach dann so sein Schwert aufstellen, wenn er ein Schwert hat, oder einen Stab aufstellen und dann so darauf abgekniet. Durchatmen. Stelle ich mir ziemlich stark vor die Pose.“

Also mindestens drei Fassungen je Kampfzeile, Wolf zuerst. Für den Bau: Je Marke wählt der Zufall eine Fassung, nie dieselbe wie beim letzten Mal unter dieser Marke (beim Einkreisen also drei verschiedene Bisse hintereinander). Fassung 1 ist der bisherige Wortlaut; Platzhalter wie im Code. Gilt eine Gegnermarke (`279.wolf.…`), ersetzt sie für diesen Gegner die allgemeine. Jede Fassung beschreibt dieselbe Bewegung wie Fassung 1 (Zu 249 „Text und Bild“); „zu Boden“ heißt abknien (Zu 249 „Abknien“), nie „fällt“ oder „reißt um“. Fest bleiben: Ankündigung „{0} kündigt an: {1}.“ und „{0}: {1}!“ (tragen die Namen, auf die Tipps und Regelseite zeigen), Namen der Absichten, Hinweise (`MarsTips.kt`), Systemmeldungen (keine ZP, kein Ziel, schon genutzt, Rast), Würfelzeilen, Zauber- und Heilzeilen.

**Allgemein** ({0} wer handelt, {1} Ziel, {2} Schaden)

`[279.trifft]` (Treffer, Held oder Gegner; ersetzt `Msg72.hits`) 1 {0} trifft {1}: {2} Schaden. / EN: {0} hits {1}: {2} damage. · 2 {0} erwischt {1}: {2} Schaden. / EN: {0} catches {1}: {2} damage. · 3 {0} landet einen Treffer bei {1}: {2} Schaden. / EN: {0} lands a blow on {1}: {2} damage.
`[279.verfehlt]` (`Msg72.misses`) 1 {0} verfehlt {1}. / EN: {0} misses {1}. · 2 Der Angriff von {0} geht an {1} vorbei. / EN: {0}'s attack goes wide of {1}. · 3 {0} zielt auf {1}, doch daneben. / EN: {0} goes for {1}, but misses.
`[279.halb]` (Ring gut; `Msg72.good`) 1 {0} fängt den Schlag halb ab. / EN: {0} half catches the blow. · 2 {0} nimmt dem Schlag die halbe Wucht. / EN: {0} takes half the force out of the blow. · 3 {0} lenkt den Schlag halb ab. / EN: {0} turns the blow half aside.
`[279.ganz]` (Ring perfekt ohne Antwort der Klasse; `Msg72.evades`, `[219.4T.aus]`) 1 {0} weicht dem Schlag ganz aus. / EN: {0} evades the blow entirely. · 2 {0} dreht sich weg, der Schlag geht ins Leere. / EN: {0} twists away; the blow finds nothing. · 3 {0} ist fort, bevor der Schlag ankommt. / EN: {0} is gone before the blow lands.
`[279.abwehr]` (`Msg72.waits`) 1 {0} geht in Abwehrhaltung. / EN: {0} takes a defensive stance. · 2 {0} hebt die Deckung. / EN: {0} raises a guard. · 3 {0} wartet in Abwehr. / EN: {0} waits on guard.
`[279.reihe]` (`Msg72.swaps`) 1 {0} wechselt die Reihe. / EN: {0} switches rows. · 2 {0} tauscht die Reihe. / EN: {0} trades rows. · 3 {0} geht in die andere Reihe. / EN: {0} moves to the other row.
`[279.aus]` (Zug verloren, ohne Aufstehen, z. B. Netz; `Msg130.loses`) 1 {0} verliert den Zug. / EN: {0} loses the turn. · 2 {0} muss diesen Zug aussetzen. / EN: {0} must sit this turn out. · 3 Für {0} ist dieser Zug verloren. / EN: This turn is lost for {0}.
`[279.auf]` (Zug verloren und steht auf, Cue `RISES`; Chef 16:24: aufstützen, durchatmen) 1 {0} stützt sich ab und kommt wieder hoch: Zug verloren. / EN: {0} pushes up and gets back to their feet: turn lost. · 2 {0} atmet durch und steht wieder auf: Zug verloren. / EN: {0} draws a breath and stands again: turn lost. · 3 {0} rappelt sich auf: Zug verloren. / EN: {0} scrambles up: turn lost.
`[279.taumelt]` (`Msg72.broken`) 1 {0} taumelt: {1} vereitelt. / EN: {0} staggers: {1} foiled. · 2 {0} gerät ins Wanken: {1} vereitelt. / EN: {0} reels: {1} foiled. · 3 {0} strauchelt: {1} vereitelt. / EN: {0} stumbles: {1} foiled.
`[279.faellt]` (Gegner besiegt; `Msg72.falls`) 1 {0} fällt. / EN: {0} falls. · 2 {0} bricht zusammen. / EN: {0} collapses. · 3 {0} rührt sich nicht mehr. / EN: {0} lies still.
`[279.held]` (Held besiegt; `Msg72.heroFalls`) 1 {0} bricht zusammen. / EN: {0} collapses. · 2 {0} sinkt nieder, die Kraft ist fort. / EN: {0} sinks down, strength gone. · 3 {0} geht zu Boden und kommt nicht mehr hoch. / EN: {0} goes down and does not rise.
`[279.bewusstlos]` (Söldner; `Msg72.knockedOut`) 1 {0} geht zu Boden, bewusstlos. / EN: {0} goes down, unconscious. · 2 {0} sinkt bewusstlos nieder. / EN: {0} sinks down, senseless. · 3 {0} bricht zusammen, ohne Bewusstsein. / EN: {0} collapses, out cold.

**Wolf**

`[279.wolf.trifft]` (jeder Treffer eines Wolfs, auch im Kreis) 1 {0} beißt {1}: {2} Schaden. / EN: {0} bites {1}: {2} damage. · 2 {0} schnappt zu und erwischt {1}: {2} Schaden. / EN: {0} snaps and catches {1}: {2} damage. · 3 {0} schlägt die Zähne in {1}: {2} Schaden. / EN: {0} sinks its teeth into {1}: {2} damage. · 4 {0} reißt an {1}: {2} Schaden. / EN: {0} tears at {1}: {2} damage.
`[279.wolf.verfehlt]` 1 {0} schnappt nach {1} und verfehlt. / EN: {0} snaps at {1} and misses. · 2 {0} beißt daneben. / EN: {0} bites at nothing. · 3 Die Zähne von {0} schlagen ins Leere. / EN: {0}'s teeth close on air.
`[279.wolf.sprung]` (Zeichen, `[130.3.wolf.sprung]`) 1 Er duckt sich flach, die Augen auf {2}. / EN: He crouches low, eyes on {2}. · 2 Er drückt sich an den Boden, die Augen auf {2}. / EN: He presses himself to the ground, eyes on {2}. · 3 Er geht tief, die Hinterläufe gespannt, den Blick auf {2}. / EN: He sinks low, hind legs tensed, gaze on {2}.
`[279.wolf.sprung.um]` (trifft, Ziel kniet ab; ersetzt `[130.3.wolf.sprung.um]`, Chef 16:21) 1 {0} springt {1} an. {1} geht zu Boden. / EN: {0} leaps at {1}. {1} goes down. · 2 {0} prallt gegen {1}. {1} sinkt nieder. / EN: {0} slams into {1}. {1} sinks down. · 3 {0} wirft sich auf {1}. {1} geht in die Knie. / EN: {0} throws itself at {1}. {1} is driven to the knees.
`[279.wolf.sprung.leer]` 1 Der Sprung geht ins Leere. / EN: The pounce lands on nothing. · 2 {0} springt ins Leere. / EN: {0} leaps at empty ground. · 3 {0} landet auf leerem Boden und knurrt. / EN: {0} lands on bare ground, growling.
`[279.wolf.kreis]` (Zeichen) 1 Die Wölfe ziehen auseinander, einer bleibt zurück und knurrt. / EN: The wolves spread out; one hangs back, growling. · 2 Das Rudel fächert sich auf, einer hält sich hinten und knurrt. / EN: The pack fans out; one keeps back, growling. · 3 Die Wölfe verteilen sich, nur einer bleibt zurück, die Lefzen hochgezogen. / EN: The wolves scatter wide; only one stays back, lips curled.
`[279.wolf.kreis.zu]` 1 Der Kreis schließt sich. Die Wölfe greifen gemeinsam an. / EN: The circle closes. The wolves strike together. · 2 Der Kreis ist zu. Das Rudel greift an, alle auf einmal. / EN: The circle is shut. The pack attacks, all at once. · 3 Ein Heulen, dann stürzt sich das ganze Rudel zugleich vor. / EN: A howl, and the whole pack surges in at once.
`[279.wolf.faellt]` 1 {0} fällt. / EN: {0} falls. · 2 {0} jault auf und bleibt liegen. / EN: {0} yelps and stays down. · 3 {0} sackt winselnd zusammen. / EN: {0} slumps, whimpering.

**Grak, Riesenspinne, Goblin-Späher** (Zeichen und Folgen aus 130.3 und 72.10a.8; Fassung 1 dort)

`[279.grak.hieb]` 2 Er hebt die Axt mit beiden Händen hoch über den Kopf. / EN: He lifts the axe high over his head with both hands. · 3 Er holt weit aus, die Axt hinter dem Kopf. / EN: He winds up, the axe behind his head.
`[279.grak.rudel]` 2 Er stampft auf und brüllt. Von weiter weg kreischt es zurück. / EN: He stamps and roars. From farther off, a shriek answers. · 3 Er stampft zweimal und reißt das Maul auf. Ein Kreischen antwortet. / EN: He stamps twice and throws his jaws wide. A shriek answers.
`[279.grak.kraft]` 2 Er tritt zurück, die Brust hebt und senkt sich, die Narben glimmen. / EN: He steps back, chest heaving, his scars smouldering. · 3 Er zieht sich einen Schritt zurück und schnauft, seine Narben leuchten auf. / EN: He backs off a step and snorts; his scars flare.
`[279.grak.bruch]` 2 Er zieht den Kopf ein und starrt über die vordere Reihe hinweg auf {2}. / EN: He ducks his head and stares past the front row at {2}. · 3 Er stemmt die Füße in den Boden, den Blick auf {2} hinter der vorderen Reihe. / EN: He plants his feet, eyes on {2} behind the front row.
`[279.spinne.gift]` 2 Ihre Kieferklauen glänzen nass, sie richtet sich auf {2} aus. / EN: Her fangs glisten wet; she turns toward {2}. · 3 Ein Tropfen Gift fällt von ihren Kieferklauen. Sie wendet sich {2} zu. / EN: A drop of venom falls from her fangs. She turns to {2}.
`[279.spinne.gift.los]` 2 Gift spritzt auf {1}. / EN: Venom spatters {1}. · 3 {1} bekommt einen Schwall Gift ab. / EN: {1} takes a splash of venom.
`[279.spinne.netz]` 2 Ihr Hinterleib hebt sich, Spinnfäden glänzen. / EN: Her abdomen rises; silk glints. · 3 Sie reckt den Hinterleib in die Höhe, ein Faden zittert. / EN: She lifts her abdomen high; a thread trembles.
`[279.spinne.netz.fest]` 2 Das Netz legt sich um {1}, der nächste Zug ist verloren. / EN: The web wraps around {1}; the next turn is lost. · 3 {1} zappelt in den Fäden und verliert den nächsten Zug. / EN: {1} struggles in the threads and loses the next turn.
`[279.spaeher.anlegen]` 2 Er spannt den Bogen und zielt auf {2}. / EN: He draws the bow and aims at {2}. · 3 Er zieht die Sehne bis ans Ohr, die Spitze auf {2}. / EN: He draws the string to his ear, the point on {2}.
`[279.spaeher.duckt]` 2 {1} duckt sich, der Pfeil pfeift über den Kopf. / EN: {1} ducks; the arrow whistles overhead. · 3 {1} duckt sich weg, der Pfeil verfehlt. / EN: {1} ducks away; the arrow misses.
`[279.spaeher.schatten]` (Ankündigung: Absicht, er steht noch da; neu 22.10., Chef 14:21) 1 Sein Blick wandert zum Dunkel hinter ihm. / EN: His eyes slide to the dark behind him. · 2 Er tastet sich rückwärts, dem Dunkel entgegen. / EN: He edges backwards, toward the dark. · 3 Er sucht den nächsten Schatten; einen Atemzug noch, dann ist er fort. / EN: He looks for the nearest shadow; one breath more and he is gone.
`[279.spaeher.weg]` 2 Von ihm keine Spur. Irgendwo wartet ein Pfeil. / EN: No trace of him. Somewhere, an arrow waits. · 3 Er ist fort. Woher der nächste Pfeil kommt, weiß keiner. / EN: He is gone. No one knows where the next arrow will come from.
`[279.spaeher.flanke]` 2 Er tritt zur Seite und pirscht sich an {2} heran. / EN: He steps aside and stalks toward {2}. · 3 Er verlässt die Reihe und schleicht außen herum auf {2} zu. / EN: He leaves the line and creeps round the outside toward {2}.

**Umzielen (301.1, Vorgangsarchiv 301)** Chef 22.10., 12:37 (an Sokrates, Wortlaut): „in der Textausgabe steht dann so, der Goblin ist total verärgert so ungefähr und greift jetzt stattdessen den anderen an. Irgendwie so, auch wie in mehreren Variationen halt.“ Gilt für jeden Gegner, dessen angesagter Nahkampfangriff (Stich, Biss …) umzielen muss, weil das Ziel nach hinten getauscht hat; Zeile direkt nach `[279.reihe]`. Ohne Pronomen für {0} (Goblin, Wolf, Spinne); 309 (Chef 22.10., 14:27/14:29): kein Regeltext mehr in der Zeile; man hört den Nachteil heraus (ungelenk, zu spät, hastig, aus dem Tritt, blindlings), die Regel zeigt der Würfel („Nachteil“ am Wurf).

`[301.stattdessen]` ({0} Gegner, {1} neues Ziel; `Msg301.reaims`; neu 309) 1 {0} knurrt wütend und fährt ungelenk zu {1} herum. / EN: {0} snarls with rage and wheels clumsily round on {1}. · 2 {0} faucht dem verlorenen Ziel nach und wendet sich zu spät {1} zu. / EN: {0} hisses after the lost mark and turns to {1} too late. · 3 Verärgert sucht {0} ein neues Ziel und geht {1} hastig an. / EN: Annoyed, {0} casts about for a new mark and goes hastily for {1}. · 4 {0} schnaubt vor Wut und kommt aus dem Tritt; jetzt muss {1} herhalten. / EN: {0} snorts with fury, thrown off stride; now {1} will have to do. · 5 Um das Ziel betrogen, geht {0} blindlings auf {1} los. / EN: Cheated of the mark, {0} lunges blindly at {1}.

**Abknien (303, Klassisch)** Chef 22.10., 13:22 (Wortlaut): „Erstens steht jetzt da im Text stürzt, aber es wird ja nur noch abgekniet in der Animation. Also da passt der Text nicht.“ Ersetzt `Msg.prone` (Battle.kt, `MonsterSpecial.KNOCKDOWN`); der Held kniet seit 295 auf die Waffe gestützt. Regel bleibt: der nächste eigene Angriff des Helden hat Nachteil, darum „aus dem Knien“; ohne Pronomen für {0}.

`[303.knie]` ({0} Held; neu 309) {0} wird in die Knie gezwungen und muss sich schwer auf die Waffe stützen. / EN: {0} is driven to one knee and has to lean hard on the weapon.

## Durchgang Kampftexte (280)

Homer 21.10.: Kampftexte, die nicht zum Bild oder zur Welt passen. Bau Jerry (280.2).

`[280.grak.axt]` Grak trägt eine Kriegsaxt (`LISTE-FIGUREN.md`, `MonsterKit.kt`), nicht eine Keule: `[130.3.grak.hieb]`, `[279.grak.hieb]` und `[210T.heavy]` sind geändert („Axt“); im Code `Msg130.signs["heavy"]` und `MarsTips.kt`.
`[280.elite]` (Elite-Merkmale, `Monsters.kt` `EliteTrait`; heute „Er …“ auch bei Spinne und Ratte, „zäh wie altes Holz“ gegen 230 ortsneutral) Wild: Schlägt mit roher Wucht zu. / EN: Strikes with raw force. · Uralt: Zäh wie altes Leder. / EN: Tough as old leather. · Flink: Blitzschnell und schwer zu treffen. / EN: Lightning fast and hard to hit. · Giftig: Greift mit Gift an. / EN: Attacks with venom. · Glühend: Brennt vor unheiliger Glut. / EN: Burns with an unholy glow. · Blutdurstig: Nährt sich von deinem Blut. / EN: Feeds on your blood.
`[280.wirkung]` (klassischer Kampf, `Battle.kt`; heute „Das ist (nicht) sehr effektiv“, ein bekannter Spruch aus fremdem Spiel) Schwäche: Das trifft eine Schwachstelle! / EN: That hits a weak spot! · Widerstand: Das richtet kaum etwas aus … / EN: That barely leaves a mark …
`[280.soeldner.en]` Englische MARS-Texte schreiben „Söldner“ (Regelseite, Test-Reiter, Auto-Schalter): dort „mercenary“; nur die Namen der Söldner bleiben gleich (`[72.10a.5.namen]`).

## Rolle je Klasse (72.10a.9, MARS)

Ersetzt den vorläufigen Wortlaut in `Skirmish.kt` (`Msg72.covers`, `strikesBack`, `stepsBehind`, `prays`, `flamesBack`). Ohne „er“ oder „ihn“, weil {0} jede Figur sein kann.

`[72.10a.9.decken]` Taste (Kämpfer) Decken / EN: Cover
`[72.10a.9.deckt]` {0} stellt sich vor die anderen und zieht jeden Schlag auf sich. / EN: {0} stands before the others and draws every blow.
`[72.10a.9.zurueck]` (Kämpfer, Ring perfekt; geändert 219.4T) {0} weicht dem Schlag aus und schlägt zurück. / EN: {0} evades the blow and strikes back.
`[72.10a.9.ruecken]` (Schurke, perfekt; geändert 219.4T, 309) {0} weicht aus und gleitet {1} in den Rücken, wo die Deckung offen ist. / EN: {0} dodges and slips behind {1}, where the guard is open.
`[72.10a.9.gebet]` (Kleriker, perfekt; danach die Heilmeldung; geändert 219.4T) {0} weicht aus und murmelt ein Gebet. / EN: {0} dodges and murmurs a prayer.
`[72.10a.9.feuer]` (Magier, perfekt, 219.3T; {1} ist der Angreifer; danach die Schadensmeldung) {0} weicht aus und schleudert {1} einen Feuerpfeil entgegen. / EN: {0} dodges and hurls a fire bolt back at {1}.

## Zweitwaffe (72.10a.11, MARS)

Ersetzt `Msg72.draws`; {1} ist der Waffenname ohne Artikel.

`[72.10a.11.wechsel]` {0} wechselt die Waffe: {1}. / EN: {0} switches weapons: {1}.
`[72.10a.11.knopf]` (Knopf unter „Wechsel“, 225) Waffe: {Waffenname} / EN: Weapon: {weapon}
`[72.10a.11.platz]` (Zusatz bei der Reihe unter „Wechsel“) hinten + {Waffenname} / EN: back + {weapon}

## Knopf „Wechsel“ (225T, Chef 19.10.)

Vorgangsarchiv 225: Knopf „Platz“ heißt „Wechsel“. Homer hat Regelseite (`MarsRules.kt`), lange Drucke (`MarsTips.kt`) und Ringtexte (`SkirmishScreen.kt`) gegen den Code gelesen (Zweig `claude/jerry-223-nachteil-hinten` mit Build 36, 19.10.). Build 36 trägt noch ältere Fassungen; mit 225 alle Marken dieses Dokuments übernehmen, die „geändert“ tragen oder seit 203/219T neu sind: `[201.absicht]`, `[201.ring]`, `[201.klassen]`, `[201.zug]`, `[201.halb]`, `[201.decken]`, `[204T.platz]`, `[204T.decken]`, `[210T.flank]`, `[210T.flank.eingebung]`, `[210T.pounce]`, `[219T.erster]`, `[219T.jetzt]`, `[219T.unten]`, `[223T.angriff]`, `[223T.reihen]` und die beiden unten. Der Hinweis „(ab .8/.9/.11)“ entfällt: alles ist gebaut. Chef 18:23: „Oben im Erklärtext kann aber "zwei Reihen" stehen bleiben, da passt es, finde ich.“ Im Test eigens abfragen: Knopf „Wechsel“, Regelseite ganz.

`[225.knopf]` (Knopf im Kampf, statt „Platz“) Wechsel / EN: Switch
`[225.log]` (ersetzt `Msg72.swaps`) {0} wechselt die Reihe. / EN: {0} switches rows.

## Regelseite MARS (201T, Chef 19.10.)

Scrollbare Seite beim Start des MARS-Probekampfs aus dem Systemmenü. Je Marke ein Absatz, Überschriften fett. Absätze mit „(ab .8)“, „(ab .9)“, „(ab .11)“ nur, wenn der Bau im selben Build steckt, sonst den Satz in Klammern weglassen. Unten eine Taste.

`[201.titel]` MARS – Probekampf / EN: MARS – Trial fight

`[201.vorweg]` (neu 312, ohne Testerton) Hier übst du den Kampf nach MARS. Dein Held und ein Söldner treten gegen eine kleine Gruppe an, beide auf Stufe 3. Dein Held und deine Tasche bleiben, wie sie sind: hier geht nichts verloren und nichts wird gewonnen.
EN: Here you practise battle the MARS way. Your hero and a mercenary face a small group, both at level 3. Your hero and your bag stay as they are: nothing is lost here, and nothing is won.

`[201.reihen]` **Zwei Reihen.** Jede Seite steht in zwei Reihen. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht; Fernkampf und Zauber erreichen jeden. Wer hinten steht, ist gedeckt, solange vorn ein Freund steht: Angriffe auf ihn haben Nachteil. Wer von vorn mit Bogen oder Armbrust auf die vordere Reihe schießt, hat ebenfalls Nachteil.
EN: **Two rows.** Each side stands in two rows. Melee reaches only the front row while anyone stands there; ranged attacks and spells reach everyone. Whoever stands at the back is covered while a friend stands in front: attacks on them have disadvantage. Shooting a bow or crossbow from the front row at the front row has disadvantage too.

`[201.absicht]` **Der Gegner sagt an.** Jeder Gegner kündigt seinen nächsten Zug an: was er vorhat, gegen wen, und ein Zeichen, woran du es erkennst. Rot heißt: das wird wehtun. Ein harter Treffer vor seinem Zug vereitelt manche Absicht. Andere verlangen eine andere Antwort: die Reihe wechseln, in Abwehr gehen, schnell zuschlagen. Lies die Zeichen. (geändert 225)
EN: **The foe announces.** Every foe announces its next move: what it intends, against whom, and a sign to recognise it by. Red means: this will hurt. A hard hit before its turn foils some intents. Others ask for a different answer: switch rows, defend, strike fast. Read the signs.

`[201.ring]` **Der Ring.** Trägt eine Ansage das Zeichen ◯, zieht sich beim Schlag ein großer Ring um die getroffene Figur zusammen, auf einen kleinen, der stillsteht. Tippe, wenn der große genau auf dem kleinen liegt; wohin du tippst, ist gleich. Knapp daneben ist gut: halber Schaden, wenn der Schlag trifft. Genau ist perfekt: ganz ausgewichen, und deine Klasse antwortet, jedes Mal. Alles andere kommt ohne Ring. (geändert 219T, 219T.1, 219.4T)
EN: **The ring.** When an announcement carries the sign ◯, a large ring closes around the figure it strikes, onto a small one that stays still. Tap when the large one lies exactly on the small one; where you tap does not matter. Just off is good: half damage, if the blow lands. Exact is perfect: no damage at all, and your class answers, every time. Everything else comes without a ring.

`[201.klassen]` (ab .9) **Perfekt je Klasse.** Der Kämpfer schlägt zurück, der Schurke gleitet dem Gegner in den Rücken, der Kleriker heilt mit einem Gebet, der Magier schleudert einen Feuerpfeil zurück. (Magier ergänzt 225, nach 219.3)
EN: **Perfect, by class.** The fighter strikes back, the rogue slips behind the foe, the cleric heals with a prayer, the wizard hurls a fire bolt back.

`[201.zug]` **Dein Zug.** Angriff mit der Waffe. Können: Zauber und Fähigkeiten; Heilung erreicht jeden Freund. Tasche: Heiltränke aus einem gemeinsamen Vorrat, für dich oder einen Freund. Wechsel: in die andere Reihe (steht dort ein Freund, tauscht ihr) oder die Waffe, Nahkampf oder Fern. Abwehr: bis zu deinem nächsten Zug haben Angriffe auf dich Nachteil. Die Leiste oben zeigt, wer als Nächstes dran ist. Jeder Wurf zeigt kurz am Ziel seine Zahlen. (geändert 225)
EN: **Your turn.** Attack with your weapon. Skills: spells and abilities; healing reaches any friend. Bag: healing potions from a shared stock, for you or a friend. Switch: to the other row (if a friend stands there, you trade places) or your weapon, melee or ranged. Defend: until your next turn, attacks on you have disadvantage. The bar at the top shows who acts next. Every roll briefly shows its numbers at the target.

`[201.halb]` Ein Wechsel kostet nur einen halben Zug, danach bleibt noch ein Schlag. Reihe und Waffe zugleich wechseln kostet ebenfalls nur einen halben Zug. (geändert 225)
EN: A switch costs only half a turn; one blow remains after it. Switching row and weapon together likewise costs only half a turn.

`[201.decken]` Der Kämpfer in der vorderen Reihe kann **Decken**: einen Zug lang zieht er jeden angekündigten Schlag auf sich, und jeder kommt mit Ring. (geändert 225)
EN: A fighter in the front row can **Cover**: for one turn, every announced blow falls on them, and each comes with a ring.

`[201.auto]` **Automatik.** Der Söldner kämpft auf Wunsch selbst, sonst steuerst du ihn. Die Automatik spielt auch deinen Helden: Waffe, Zaubertricks, Heilung, wenn ein Freund schwach ist; den Ring trifft sie immer gut, nie perfekt. Sie hält an, wenn dein Held unter ein Drittel seiner Lebenspunkte fällt oder ein Gegner etwas Starkes ansagt, und gegen Bosse läuft sie nie.
EN: **Autopilot.** The Söldner can fight on their own, or you steer them. The autopilot can play your hero too: weapon, cantrips, healing when a friend is weak; it always meets the ring with good, never perfect. It stops when your hero drops below a third of their life points or a foe announces something strong, and it never runs against bosses.

`[201.fallen]` **Wer fällt.** Ein Söldner, der fällt, ist bewusstlos, nicht tot. Wer außer Atem in den Kampf geht, würfelt die Reihenfolge mit Nachteil.
EN: **Who falls.** A Söldner who falls is unconscious, not dead. Whoever enters the fight out of breath rolls for the order with disadvantage.

`[201.feedback]` (neu 312, ohne Testerton) Grak, Wölfe, Spinne, Späher: jeder Gegner verlangt eine andere Antwort. Finde sie, bevor es ernst wird.
EN: Grak, wolves, spider, scout: each foe asks for a different answer. Find it before it counts.

`[201.taste]` Zum Kampf / EN: To battle

## Tiptexte MARS (204T, Chef 19.10.)

Bei langem Druck auf einen Knopf. Fähigkeiten und Gegenstände zeigen ihre Beschreibung aus `Rules.kt` bzw. `Items.kt`; dahinter, nur wo angegeben, ein Zusatz für MARS. „Abwarten“ heißt seit 203 „Abwehr“ (SRD Ausweichen).

`[204T.angriff]` Ein Schlag oder Schuss mit der Waffe. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht.
EN: One blow or shot with your weapon. Melee reaches only the front row while anyone stands there.

`[204T.koennen]` Zauber und Fähigkeiten deiner Klasse. Zauber kosten Zauberpunkte, manches geht nur einmal pro Kampf oder bis zur Rast.
EN: Your class's spells and abilities. Spells cost spell points; some things work only once per battle or until you rest.

`[204T.tasche]` Ein Heiltrank aus dem gemeinsamen Vorrat, für dich oder einen Freund. Kostet den Zug.
EN: A healing potion from the shared stock, for you or a friend. Costs your turn.

`[204T.platz]` (Knopf „Wechsel“, 225) In die andere Reihe gehen (steht dort ein Freund, tauscht ihr) oder die Waffe wechseln, oder beides zugleich. Hinten bist du gedeckt, solange vorn ein Freund steht. Ein halber Zug: danach bleibt noch ein Schlag. (geändert 225)
EN: (button “Switch”, 225) Move to the other row (if a friend stands there, you trade places) or switch weapons, or both at once. At the back you are covered while a friend stands in front. Half a turn: one blow remains after it.

`[204T.abwarten]` (Knopf „Abwehr“, 203) Bis zu deinem nächsten Zug haben Angriffe auf dich Nachteil, Rettungswürfe auf Geschicklichkeit Vorteil. Manchmal ist das die richtige Antwort.
EN: (button “Defend”, 203) Until your next turn, attacks on you have disadvantage and Dexterity saves have advantage. Sometimes that is the right answer.

`[204T.soeldner]` Auto: der Söldner kämpft selbst. Selbst: du gibst ihm jeden Befehl.
EN: Auto: the Söldner fights on their own. Manual: you give every order.

`[204T.automatik]` Spielt deinen Helden: Waffe, Zaubertricks, Heilung für einen schwachen Freund. Fängt den Ring immer gut, nie perfekt. Hält an unter einem Drittel der Lebenspunkte und bei einer starken Absicht; nie gegen Bosse.
EN: Plays your hero: weapon, cantrips, healing for a weak friend. Always meets the ring with good, never perfect. Stops below a third of life points and on a strong intent; never against bosses.

`[204T.decken]` (Kämpfer) Nur aus der vorderen Reihe: einen Zug lang zieht der Kämpfer jeden angekündigten Schlag auf Freunde auf sich, jeden mit Ring. Ring perfekt: Gegenschlag. (geändert 225)
EN: Front row only: for one turn the fighter draws every announced blow aimed at friends, each with a ring. Perfect ring: a counterblow.

Zusätze hinter der Beschreibung (neue Zeile):

`[204T.wunden]` (Wunden heilen) Auch für einen Freund, über alle Reihen. / EN: Also for a friend, across all rows.
`[204T.finte]` (Finte, ab .9) Aus der hinteren Reihe, wenn vorn ein Freund steht: erreicht jeden Gegner ohne Deckung. / EN: From the back row, with a friend in front: reaches any foe without cover.
`[204T.feuerball]` (Feuerball, ab Stufe 5, nicht im Probekampf) Trifft die ganze Reihe des Ziels. / EN: Strikes the target's whole row.
`[204T.trank]` (Heiltrank; die Beschreibung nennt die Heilung nicht) Heilt 2W4+2 TP. / EN: Heals 2d4+2 HP.

Nebenbefund für Jerry: Tatendrang macht in MARS (`Skirmish.useSkill`) auf Stufe 3 zwei Schläge, die Beschreibung verspricht einen (zwei erst ab Stufe 5). Beschreibung oder Code angleichen; Balance entscheidet der Chef.

## Ansagen erklärt (210T, Chef 19.10.)

(A) Bei langem Druck auf die Ansage eines Gegners: Satz 1 sagt, was sie tut, Satz 2, was hilft und was beim Vereiteln bleibt. (B) Beim ersten Auftreten jeder Ansage einmal je Spielstand eine Zeile im Kampfbericht, die Eingebung des Helden (eigene Farbe oder kursiv). Regeln nachgesehen in `Skirmish.kt` (Zweig `claude/jerry-203-abwehr`, 19.10.); ändert Jerry eine Regel, ändert Homer den Text. „Ein Fünftel seiner Lebenspunkte“ folgt `BREAK_SHARE`.

**Grak**

`[210T.heavy]` (geändert 280) Schwerer Hieb: die Axt mit voller Wucht, 2W6 mehr Schaden, gegen eine Figur. Hilft: vorher ein Fünftel seiner Lebenspunkte abnehmen, dann taumelt er und der Zug ist verloren; sonst Abwehr, Decken oder den Ring treffen.
EN: Heavy blow: the axe at full force, 2d6 extra damage, against one figure. Helps: take a fifth of his life points first and he staggers, his turn lost; otherwise Defend, Guard or meet the ring.
`[210T.heavy.eingebung]` Er holt zu weit aus. Treffe ich ihn jetzt hart, kommt er aus dem Tritt.
EN: He winds up too far. If I hit him hard now, he loses his footing.

`[210T.call]` Rudel rufen: ein Goblin kommt, beim zweiten Mal ein Späher, mehr nicht. Hilft: Verhindern lässt es sich nicht; nutze den Zug, um Grak selbst zuzusetzen oder dich aufzustellen.
EN: Call the pack: a goblin comes, the second time a scout, no more. Helps: it cannot be stopped; use the turn to wear Grak down or to set your line.
`[210T.call.eingebung]` Er ruft Hilfe. Die halte ich nicht auf, aber ihn kann ich treffen, solange er brüllt.
EN: He calls for help. That I cannot stop, but I can hit him while he roars.

`[210T.gather]` Kraft sammeln: er heilt sich um 2W10 Lebenspunkte. Hilft: ein Fünftel seiner Lebenspunkte vorher abnehmen, dann bleibt die Heilung aus.
EN: Gather strength: he heals 2d10 life points. Helps: take a fifth of his life points first and the healing fails.
`[210T.gather.eingebung]` Er holt Luft. Jetzt nachsetzen, sonst steht er gleich wieder voll da.
EN: He is catching his breath. Press now, or he stands whole again.

`[210T.breakthrough]` Durchbrechen: er stößt die Figur vorn nach hinten und schlägt die dahinter, die nun vorn steht, mit 1W6 mehr Schaden. Hilft: der Bedrohte tritt selbst nach vorn, dann bleibt ein einfacher Schlag; oder ein Fünftel seiner Lebenspunkte vorher.
EN: Break through: he shoves the front figure back and strikes the one behind, now in front, with 1d6 extra damage. Helps: the threatened one steps forward, leaving a plain blow; or a fifth of his life points first.
`[210T.breakthrough.eingebung]` Er will durch die Reihe. Steht der Bedrohte schon vorn, läuft er ins Leere.
EN: He means to break the line. If the threatened one already stands in front, he charges into nothing.

**Goblin**

`[210T.stab]` Stich: ein einfacher Schlag, ohne Ring. Hilft: Abwehr gibt ihm Nachteil; meist lohnt der eigene Angriff mehr.
EN: Stab: a plain blow, without a ring. Helps: Defend gives it disadvantage; usually your own attack is worth more.
`[210T.stab.eingebung]` Nur ein Stich. Dafür lohnt kein Ausweichen.
EN: Just a stab. Not worth dodging.

`[210T.flank]` Flanke: er läuft um die Reihe und sticht eine Figur hinten, ohne Deckung. Hilft: die Figur wechselt die Reihe, dann sticht er ins Leere; oder jeder Treffer auf ihn, auch ein leichter.
EN: Flank: he runs round the line and stabs a figure at the back, without cover. Helps: that figure changes places and he stabs at nothing; or any hit on him, however light.
`[210T.flank.eingebung]` Er will hintenrum. Ein Kratzer hält ihn auf, ein Wechsel der Reihe auch.
EN: He means to go round. A scratch stops him, and so does a change of place.

**Wolf**

`[210T.pounce]` Anspringen: trifft er, verliert die Figur ihren nächsten Zug. Hilft: die Figur wechselt die Reihe, dann springt er ins Leere; ein Wechsel kostet nur einen halben Zug.
EN: Pounce: if it hits, the figure loses its next turn. Helps: that figure changes places and it leaps at nothing; a swap costs only half a turn.
`[210T.pounce.eingebung]` Er duckt sich zum Sprung. Wer nicht mehr dort steht, wird nicht getroffen.
EN: It crouches to leap. Whoever no longer stands there is not struck.

`[210T.circle]` Einkreisen: alle Wölfe beißen zugleich dieselbe Figur. Hilft: jeder Treffer auf den Wolf, der es ansagt, auch ein leichter, zerstreut das Rudel.
EN: Circle: every wolf bites the same figure at once. Helps: any hit on the wolf that calls it, however light, scatters the pack.
`[210T.circle.eingebung]` Der eine führt das Rudel. Den treffen, egal wie leicht.
EN: That one leads the pack. Hit it, however lightly.

**Riesenspinne**

`[210T.venom]` Gift sammeln: der nächste Biss hat 2W6 mehr Schaden, ohne Ring. Hilft: ein Fünftel ihrer Lebenspunkte vorher, dann versiegt das Gift; sonst Abwehr.
EN: Gather venom: the next bite deals 2d6 extra damage, without a ring. Helps: a fifth of her life points first and the venom dries up; otherwise Defend.
`[210T.venom.eingebung]` Das Gift kommt ohne Warnung. Ich muss sie treffen, bevor sie beißt.
EN: The venom comes without warning. I must hit her before she bites.

`[210T.web]` Netz werfen: trifft es, verliert die Figur ihren nächsten Zug. Hilft: den Ring perfekt treffen; Abwehr gibt ihr Nachteil.
EN: Cast web: if it hits, the figure loses its next turn. Helps: meet the ring perfectly; Defend gives her disadvantage.
`[210T.web.eingebung]` Das Netz fliegt langsam. Wer den Moment trifft, ist frei.
EN: The web flies slowly. Catch the moment and you are free.

**Goblin-Späher**

`[210T.aim]` Anlegen: ein Schuss mit 1W6 mehr Schaden, ohne Ring. Hilft: die Figur geht in Abwehr, dann duckt sie sich und der Pfeil geht vorbei.
EN: Take aim: a shot with 1d6 extra damage, without a ring. Helps: that figure goes on the defensive, ducks, and the arrow misses.
`[210T.aim.eingebung]` Er zielt auf mich. Ducke ich mich, verfehlt er.
EN: He is aiming at me. If I duck, he misses.

`[210T.shadow]` In den Schatten: er verschwindet, bis zu seinem nächsten Zug haben Angriffe auf ihn Nachteil. Hilft: jeder Treffer vorher, auch ein leichter, hält ihn im Licht.
EN: Into the shadows: he vanishes; until his next turn, attacks on him have disadvantage. Helps: any hit before, however light, keeps him in the light.
`[210T.shadow.eingebung]` Er sucht das Dunkel. Ein Kratzer jetzt, und er bleibt sichtbar.
EN: He seeks the dark. A scratch now, and he stays in sight.

## Der Ring erklärt (219T, Chef 19.10.)

Ring heute nur bei Schwerer Hieb, Netz werfen, Durchbrechen (`ring = true` in `Skirmish.kt`, Zweig `claude/jerry-build-34`, nachgesehen 19.10.). Ändert Jerry das, ändert sich nur, wo das Zeichen steht.

**Zeichen (Entscheid Homer, Aussehen):** ein kleiner goldener Ring, gezeichnet wie der echte Ring (Kreislinie, nicht gefüllt, etwa so hoch wie die Schrift), zwischen dem bisherigen Zeichen und dem Namen: „!! ◯ Schwerer Hieb“. Gezeichnet statt Schriftzeichen, damit er auf jedem Gerät gleich aussieht und an den Ring erinnert. Auch in der Zugleiste und im Popup der Ansage (210T A), falls dort ein Zeichen steht.

`[219T.erster]` (einmal je Spielstand, Zeile im Kampfbericht wie die Eingebung, 210T B; wenn ein Gegner zum ersten Mal eine Ansage mit Ring gegen eine Figur ansagt, die der Spieler steuert, also vor dem Schlag, nicht erst beim Ring) Das Zeichen ◯ heißt: dieser Schlag kommt mit Ring; um deine Figur zieht sich ein großer Ring auf einen kleinen zusammen; tippe, wenn er genau auf ihm liegt: knapp daneben nimmst du halben Schaden, genau getroffen gar keinen. (geändert 219T.1)
EN: The sign ◯ means: this blow comes with a ring; a large ring closes around your figure onto a small one; tap when it lies exactly on it: just off, you take half damage, exactly, none at all.

`[219T.jetzt]` (nur beim ersten Ring je Spielstand, kurz über dem Ring, bis getippt oder vorbei) Tippen, wenn die Ringe aufeinanderliegen! (geändert 219T.1)
EN: Tap when the rings meet!

`[219T.unten]` (Zeile unten im Kampfort, solange der Ring läuft; ersetzt „Tippen, wenn der Ring sich schließt“, 219T.1) Tippen, wenn der große Ring auf dem kleinen liegt
EN: Tap when the large ring lies on the small one

Ergebnis am Ziel (219.2, Wortlaut aus dem Vorgangsarchiv), statt des bloßen Worts:

`[219.ring.perfekt]` Perfekt: ausgewichen / EN: Perfect: dodged

`[219.ring.gut]` Gut: halber Schaden / EN: Good: half damage

`[219.ring.verpasst]` Verpasst / EN: Missed

Die Antwort der Klasse auf „Perfekt“ steht als Kampfzeile (`[72.10a.9.…]`), die des Magiers als `[72.10a.9.feuer]` (219.3T).

### Perfekt zählt immer (219.4T, Vorgangsarchiv 219.4)

Ein perfekter Ring zählt auch, wenn der Angriffswurf verfehlt hätte. Im Kampfbericht steht dann **genau eine Zeile** für das Ausweichen: mit Antwort der Klasse deren Zeile (`.zurueck`, `.ruecken`, `.gebet`, `.feuer`, alle sagen das Ausweichen mit), sonst `[219.4T.aus]`. Statt „{1} verfehlt {0}“ und statt `Msg72.reacts` (PERFECT) in `Skirmish.kt`; „weicht dem Schlag ganz aus“ nie zusätzlich zur Zeile der Klasse. `[72.10a.9.feuer]` gilt im Wortlaut oben (Code hat noch „antwortet mit einem Feuerpfeil auf“).

`[219.4T.aus]` (Perfekt ohne Antwort der Klasse, ob der Wurf getroffen hätte oder nicht: Magier ohne Feuerpfeil, Figuren ohne Klasse) {0} weicht dem Schlag ganz aus. / EN: {0} evades the blow entirely.

Bei Gut oder Verpasst und Fehlwurf zeigt das Fenster nur das Wort, der Bericht die gewöhnliche Zeile „{0} verfehlt {1}.“:

`[219.4T.gut]` (Gut bei Fehlwurf, statt `[219.ring.gut]`) Gut / EN: Good

## Nahkampf von hinten (223T, Chef 19.10.)

Regel (Vorgangsarchiv 223): Nahkampf aus der hinteren Reihe greift mit Nachteil an, Speer und Hellebarde nicht (die Stangenwaffen, `Icon.SPEAR` in `Gear.kt`). Zählt Jerry andere Waffen dazu, ändert Homer die Namen. Stab und Zauberstab gelten als Nahkampf (72.10a.11), Zauber bleiben frei. Die Absätze unten ersetzen `[204T.angriff]` und ergänzen `[201.reihen]`, beide nur mit dem Bau von 223 im selben Build.

`[223T.eingebung]` (einmal je Spielstand, Zeile im Kampfbericht wie die Eingebung, 210T B; beim ersten Nahkampfangriff mit Nachteil aus der hinteren Reihe einer Figur, die der Spieler steuert, nicht in der Automatik; vor dem Wurf) Von hier hinten reiche ich kaum hin. Vorn, mit einem Speer oder aus der Ferne träfe ich besser.
EN: From back here I can barely reach. Up front, with a spear or from afar, I would strike better.

`[223T.angriff]` (ersetzt `[204T.angriff]`) Ein Schlag oder Schuss mit der Waffe. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht, und hat von hinten an einem Freund vorbei Nachteil, außer mit Speer oder Hellebarde. Bogen und Armbrust haben Nachteil, wenn du vorn stehst und auf die vordere Reihe schießt.
EN: One blow or shot with your weapon. Melee reaches only the front row while anyone stands there, and from the back past a friend it has disadvantage, except with a spear or halberd. Bows and crossbows have disadvantage when you stand in front and shoot at the front row.

`[223T.reihen]` (Satz am Ende von `[201.reihen]`) Umgekehrt hat Nahkampf aus der hinteren Reihe an einem Freund vorbei Nachteil, außer mit Speer oder Hellebarde, die weit genug reichen.
EN: (sentence at the end of `[201.reihen]`) Likewise, melee from the back row past a friend has disadvantage, except with a spear or halberd, which reach far enough.

## Schnell im leichten Kampf (259T, Jerry 20.10.)

Gegen den Code gelesen (`claude/jerry-259-schwach`: `SkirmishScreen.kt`, `MarsTips.quick`, `Skirmish.quick`, 21.10.): „Schnell“ spielt Held und Söldner mit der Automatik und hält an, wenn der Held unter ein Drittel fällt. Ersetzt die Platzhalter.

`[259T.frage]` (Zeile über „Kämpfen“/„Schnell“ am Kampfbeginn) Ein leichter Kampf: Stufe {0} gegen Herausforderungsgrad {1}.
EN: An easy fight: level {0} against challenge rating {1}.

`[259T.knoepfe]` (bleiben) Kämpfen · Schnell; im Kampf: Schnell › / EN: Fight · Quick; Quick ›

`[259T.tip]` (ersetzt `MarsTips.quick`) Nur gegen schwache Gegner: dein Held mindestens 4 Stufen über dem stärksten, nie gegen Bosse. Die Automatik spielt den Kampf für Held und Söldner in einem Rutsch, ohne Bilder. Hält an, wenn dein Held unter ein Drittel der Lebenspunkte fällt; dann übernimmst du. Ab 7 Stufen Abstand nur halber Schaden, ab 10 keiner.
EN: Weak foes only: your hero at least 4 levels above the strongest, never against bosses. The automatic plays the fight for hero and Söldner in one go, without pictures. Stops when your hero falls below a third of life points; then you take over. From 7 levels apart only half damage, from 10 none.

`[259T.halt]` (Tip, wenn „Schnell“ anhält; {0} = Name des Helden) Schnell hält an: {0} ist unter einem Drittel der Lebenspunkte. Du übernimmst.
EN: Quick stops: {0} is below a third of life points. You take over.

`[259T.sieg]` (Kampfende gewonnen, gegen alle außer Grak; „Grak ist besiegt.“ bleibt) Der Kampf ist gewonnen.
EN: The fight is won.

`[259T.tafel]` (unter der Siegzeile nach „Schnell“, je Gefährte mit „ · “ getrennt; bleibt) {Name} −{n} LP; im Probekampf angehängt „ · Probekampf: keine Beute, keine EP“. Im Spiel später statt dessen „ · Beute: {Liste} · {n} EP“.
EN: {Name} −{n} HP; trial: “ · trial fight: no loot, no XP”; in the game: “ · Loot: {list} · {n} XP”.

## Laden: neue Ware (59e.1T)

Ersetzt „Neue Ware nach jeweils 8 Siegen.“ im Laden. Bewusst vage: wann genau, findet der Spieler selbst heraus.

`[59e.1T.hinweis]` Neue Ware kommt, wenn sich draußen etwas tut. Und wenn du stärker wirst.
EN: New stock comes when something stirs out there. And when you grow stronger.

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

`[86.9.betrunken]` Betrunken · Kurz: Betrunken (Zustand, nicht Ursache; Chef 18.10.) · Angriffe und Flucht mit Nachteil, bis zur nächsten Rast.
EN: Drunk · Short: Drunk · Attacks and fleeing at a disadvantage, until your next rest.

`[86.9.atem]` (Kampfzeile, wenn der Held außer Atem in den Kampf kommt; neu 309) {0} kommt keuchend an und braucht einen Augenblick, bis die Waffe oben ist.
EN: {0} arrives gasping and needs a moment to get the weapon up.

## Licht: Fackel und Leuchtfunke (84.1, 84.5)

`Light.kt`, `Items.kt`, `Gear.kt`. Du-Form wie bei der Rast. Fackel und Funke ändern nur im Dunkeln etwas; Meldungen zur Fackel darum nur im Dunkeln (Nacht draußen, immer in der Höhle).

`[84.1.name]` Fackel / EN: Torch (bleibt)

`[84.1.laden]` (Beschreibung im Laden und in der Ausrüstung) Pech und Werg auf einem Stock. In der Nebenhand, statt eines Schilds. Im Dunkeln siehst du weiter als mit einem Leuchtfunken. Brennt, solange du sie trägst.
EN: Pitch and tow on a stick. Held in the off hand, instead of a shield. In the dark you see further than with a lightspark. Burns as long as you carry it.

`[84.1.an]` (Fackel in die Nebenhand gelegt, im Dunkeln) Du zündest die Fackel an.
EN: You light the torch.

`[84.1.aus]` (Fackel abgelegt, im Dunkeln) Du drückst die Fackel aus. Das Dunkel rückt heran.
EN: You snuff out the torch. The dark closes in.

`[84.5.name]` Leuchtfunke / EN: Lightspark (bleibt)

`[84.5.laden]` (Beschreibung im Laden und im Beutel) Ein Fläschchen, von Morwen gebraut. Getrunken steigt ein Funke auf und leuchtet über dir bis zur nächsten Rast. Im Dunkeln siehst du weiter, aber Monster bemerken dich früher. Nicht im Kampf.
EN: A flask brewed by Morwen. Drink it, and a spark rises to glow above you until your next rest. In the dark you see further, but monsters notice you sooner. Not in battle.

`[84.5.trinken]` Du trinkst das Fläschchen. Ein Funke steigt auf und bleibt über deinem Kopf stehen.
EN: You drink the flask. A spark rises and settles above your head.

`[84.5.schon]` (Funke leuchtet schon; nichts verbraucht) Dein Funke leuchtet noch.
EN: Your spark is still glowing.

`[84.5.taste]` (Taste in der Zeile „Leuchtfunke“ im Beutel) Löschen
EN: Put out

`[84.5.aus]` (nach der Taste) Der Funke verglimmt. Weg ist weg.
EN: The spark fades. Gone is gone.

`[84.5.rast]` (nach einer Rast, nur wenn der Funke brannte; hinter die Meldung der Rast; nach einem Morgen in einer Szene als erste Zeile nach dem Aufwachen, vor jeder Rede, 84.1T.1) Dein Funke ist verglommen.
EN: Your spark has faded.

## Über das Spiel (312)

`I18n.kt` `aboutText`, Seite „Über das Spiel“ (Bau Tom). Chef 22.10., 14:54: „Da stimmt es auch noch nicht so ganz.“ Ohne Zahlen, die veralten (Monsterarten, Stufendeckel je Kapitel); SRD-Absatz unverändert, er ist die Lizenzangabe. Logo, Copyright und Schriftenzeile sind Toms Teil.

`[312.ueber]` Ein Fantasy-Rollenspiel in Kapiteln. Erkunde das Dorf Bornim und das Land darum, stelle dich Wölfen, Goblins und Schlimmerem im rundenbasierten Kampf, sammle Beute in sechs Seltenheitsstufen und schreibe mit deinem Helden die Chroniken von Bornim fort.
EN: A fantasy role-playing game told in chapters. Explore the village of Bornim and the land around it, face wolves, goblins and worse in turn-based battle, gather loot in six rarities and carry the Chronicles of Bornim onward with your hero.

`[312.srd]` (unverändert) Regeln, Klassen, Völker, Zauber und Monster sind vereinfacht und basieren auf dem System Reference Document 5.1 (SRD 5.1) von Wizards of the Coast LLC, verfügbar unter https://dnd.wizards.com/resources/systems-reference-document. Das SRD 5.1 ist lizenziert unter der Creative Commons Namensnennung 4.0 International (https://creativecommons.org/licenses/by/4.0/legalcode).
EN: Rules, classes, races, spells and monsters are simplified and based on the System Reference Document 5.1 (SRD 5.1) by Wizards of the Coast LLC, available at https://dnd.wizards.com/resources/systems-reference-document. The SRD 5.1 is licensed under the Creative Commons Attribution 4.0 International License (https://creativecommons.org/licenses/by/4.0/legalcode).

`[312.eigen]` Geschichte, Orte und Figuren sind eigene Erfindungen.
EN: The story, places and characters are original.
