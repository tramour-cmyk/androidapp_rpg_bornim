# Meisterschaften und Ruf, Kapitel 1 (Entwurf)

Entwurf Homer, 01.11.; Vorgang 447.4, Abnahmeliste 3.2 (Meisterschaften; Ablauf wie bei den Pfaden, „Für Tom“ in `STORY-LEHRMEISTER-K1.md`) und 3.3 (Ruf bei den Leuten im Dorf; Preis bei Borin und Händler, eine Auskunft mehr). Quellen: Nachschlagewerk `DESIGN-SPIELSYSTEM-2-0-ENTWURF.md` Abschnitte 6, 9, 11; Storyplan `STORY-PLAN-K1.md` „Nebenquests vom Anschlagbrett“; Kampfaufstellung `godot/kampf/aufruf.gd`. Lehrmeister in `STORY-LEHRMEISTER-K1.md`. Fremd geprüft 01.11.

## Meisterschaften (3.2)

### Kräuterfrau Morwen · Alchemist (Alchemie, Kräuterkunde)

`[447.4.morwen.alchemie.ruf]` Deine Tränke taugen etwas. Und du weißt, welches Kraut man pflückt und welches man stehen lässt. / EN: Your potions are worth something. And you know which herb to pick and which to leave.
`[447.4.morwen.alchemie.frage]` Willst du Alchemist werden? Dann zeig mir, was du kannst. Ich sag dir, was fehlt. / EN: Do you want to become an Alchemist? Then show me what you can do. I'll tell you what's missing.
`[447.4.morwen.alchemie.ja]` Heiltränke kannst du. Dann sieh dir das hier an. / EN: Healing potions you can do. Then take a look at this.
`[447.4.morwen.alchemie.hinweis]` Pflück frisch und koch langsam. Und riech an nichts, woran ich nicht vorher gerochen habe. / EN: Pick fresh and brew slowly. And don't sniff anything I haven't sniffed first.
`[447.4.morwen.alchemie.nein]` Dann kauf weiter bei mir. Mir soll's recht sein. / EN: Then keep buying from me. Suits me.
`[447.4.morwen.alchemie.grenze]` Für heute kannst du genug. Den Rest zeigt dir die Welt, und dann prüfe ich dich. / EN: You know enough for now. The world will show you the rest, and then I'll test you.

### Jäger Garrick · Lederarbeit (Lederarbeit, Jagd)

`[447.4.garrick.leder.ruf]` Deine Felle sind sauber abgezogen, und was du daraus machst, hält. / EN: Your pelts are cleanly skinned, and what you make of them holds.
`[447.4.garrick.leder.frage]` Willst du das Leder richtig lernen? Gerben, schneiden, nähen. / EN: Do you want to learn leather properly? Tanning, cutting, stitching.
`[447.4.garrick.leder.ja]` Gut. Du kannst schon was. Sieh dir an, wie ich's mach. / EN: Good. You already know a thing or two. Watch how I do it.
`[447.4.garrick.leder.hinweis]` Ein Loch im Fell ist ein Loch in der Rüstung. Zieh langsam ab. / EN: A hole in the pelt is a hole in the armour. Skin slowly.
`[447.4.garrick.leder.nein]` Gut. Thessa kauft Felle auch roh. / EN: Fine. Thessa buys pelts raw as well.
`[447.4.garrick.leder.grenze]` Mehr Leder gibt dieser Wald nicht her. Draußen gibt's andere Tiere; dann prüf ich dich. / EN: These woods give no better leather. Out there are other beasts; then I'll test you.

### Rowena · Feldkoch (Kochen, Angeln oder Jagd)

`[447.4.rowena.ruf]` Man erzählt sich im Dorf, was du am Feuer brätst, {name}. Da soll Gefühl drinstecken. / EN: Folk in the village talk about what you roast over the fire, {name}. They say there's feeling in it.
`[447.4.rowena.frage]` Willst du richtig kochen lernen? Für unterwegs, nicht für meine Gäste. Die kriegen meins. / EN: Do you want to learn to cook properly? For the road, not for my guests. They get mine.
`[447.4.rowena.ja]` Dann pass auf. Das hier hat schon meine Mutter gemacht. / EN: Then pay attention. My mother made this one.
`[447.4.rowena.hinweis]` Frisch gefangen, gleich gebraten. Wer satt kämpft, kämpft besser. / EN: Freshly caught, roasted at once. A full stomach fights better.
`[447.4.rowena.nein]` Schon recht. Meine Küche läuft dir nicht weg. / EN: All right. My kitchen isn't going anywhere.
`[447.4.rowena.grenze]` Aus meiner Küche kennst du jetzt alles, was zählt. Was fremde Küchen können, zeigt dir die Straße; dann prüf ich dich. / EN: You know everything that matters from my kitchen. The road will show you what other kitchens can do; then I'll test you.

### Schmied und Runenmeister (erst ab Kapitel 2, 447.4a Punkt 3)

`[447.4.borin.schmied]` (Borin, einmal, sobald Schmieden Geselle ist) Hrmpf. Du hältst den Hammer schon richtig herum. Aber ein Schmied, der sein Erz kaufen muss, ist ein halber Schmied. Lern erst, wie man es aus dem Berg holt. / EN: Hrmph. You're holding the hammer the right way round, at least. But a smith who has to buy his ore is half a smith. First learn how to get it out of the mountain.
`[447.4.borin.runen]` (Borin, einmal, sobald Runenkunde Geselle ist) Runen? Davon verstehst du nichts, noch nicht. Und ohne Erz aus dem Berg erst recht nicht. / EN: Runes? You know nothing about them, not yet. And without ore from the mountain, even less.

## Ruf (3.3)

### Für Tom

- Ruf in Kapitel 1 kommt aus den fünf Nebenquests vom Anschlagbrett (Thessa, Gwenna, Borin, Morwen, Jorin). Die gibt es bisher nur in der alten Fassung (`Jobs.kt`); ohne ihren Umzug (2.11) gibt es in Kapitel 1 keinen Ruf. Aldric und Osric danken am Kapitelende; ihre Ruf-Zeilen folgen mit Kapitel 2.
- Stufe je Person aus der Datendatei (2.10). Ab der zweiten Stufe ersetzt `…gruss` die erste Zeile der üblichen Begrüßung; `…auskunft` einmal, solange ihre Bedingung gilt; `…preis` beim Öffnen des Ladens oder der Reparatur.
- `{name}` Held, `{person}` Name aus `geschichte.gd`.

### Anzeige

`[447.4.ruf.stufen]` (Vorschlag) Fremd · Bekannt · Geschätzt · Vertraut / EN: Stranger · Known · Valued · Trusted
`[447.4.ruf.titel]` Bekannte Personen / EN: Known People
`[447.4.ruf.auf]` Ruf bei {person} ↑ / EN: Reputation with {person} ↑
`[447.4.ruf.vorteil.preis]` Günstigere Preise / EN: Better prices
`[447.4.ruf.vorteil.auskunft]` Erzählt dir mehr / EN: Tells you more

### Gespräche

`[447.4.ruf.thessa.gruss]` Ah, {name}! Meine liebste Kundschaft. / EN: Ah, {name}! My favourite customer.
`[447.4.ruf.thessa.preis]` Für dich mach ich's billiger. Sag's nicht weiter. / EN: For you I'll make it cheaper. Don't spread it around.
`[447.4.ruf.thessa.auskunft]` (Gwennas Ring angenommen, nicht abgegeben) Gwennas Mann trug ihren Ring, als die Goblins ihn holten. Was sie rauben, landet in ihren Truhen; eine steht im Südwesten ihrer Höhle, heißt es. Wenn er auftaucht: Gwenna zahlt mehr als ich. / EN: Gwenna's husband wore her ring when the goblins took him. Whatever they steal ends up in their chests; there's one in the southwest of their cave, they say. If it turns up: Gwenna will pay more than I would.
`[447.4.ruf.borin.gruss]` Hrmpf. Da bist du ja. Der Stuhl ist frei. / EN: Hrmph. There you are. The chair's free.
`[447.4.ruf.borin.preis]` Für dich flick ich's für weniger. Erzähl's nicht in der ganzen Schänke. / EN: For you I'll mend it for less. Don't tell the whole inn.
`[447.4.ruf.borin.auskunft]` (ein Stück Ausrüstung Beschädigt) Lass dein Zeug nicht so weit kommen, dass es gar nicht mehr taugt. Was defekt ist, wirkt nicht. Bring's mir vorher. / EN: Don't let your gear get to where it's no good at all. What's broken does nothing. Bring it to me before that happens.
`[447.4.ruf.gwenna.gruss]` Du bist es. Bleib einen Moment, wenn du willst. / EN: It's you. Stay a moment, if you like.
`[447.4.ruf.gwenna.auskunft]` (Feuer am Steinkreis offen) Nachts am Fluss sehe ich manchmal Licht zwischen den Bäumen, dort, wo die alten Steine stehen. Goblins machen da kein Feuer. / EN: At night by the river I sometimes see a light among the trees, where the old stones stand. Goblins don't light fires there.
`[447.4.ruf.morwen.gruss]` Du schon wieder. Gut. Das Feuer kennt dich. / EN: You again. Good. The fire knows you.
`[447.4.ruf.morwen.preis]` Für dich weniger. Frag nicht, warum. / EN: Less, for you. Don't ask why.
`[447.4.ruf.morwen.auskunft]` (Grimmzahn lebt) Grimmzahn geht nie allein. Zwei aus seinem Rudel halten ihm den Rücken. / EN: Grimfang never goes alone. Two of his pack guard his back.
`[447.4.ruf.jorin.gruss]` {name}. Du kommst und gehst, wie du willst; das hast du dir verdient. / EN: {name}. You come and go as you please; you've earned that.
`[447.4.ruf.jorin.auskunft]` (Grak lebt) Grak ruft seine Leute, wenn es eng wird. Fäll ihn, bevor sie kommen. / EN: Grak calls his men when things get tight. Bring him down before they come.

### Offen

- **Rufstufen:** das Nachschlagewerk nennt keine Namen; die vier sind ein Vorschlag (Chefsache 447.4).
- **Borins Auskunft** hilft nicht in einer Quest, sondern bei der Abnutzung (3.5); in Kapitel 1 hat Borin keine zweite Quest, auf die er weisen könnte.
