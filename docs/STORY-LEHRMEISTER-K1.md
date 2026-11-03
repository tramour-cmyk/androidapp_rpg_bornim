# Lehrmeister, Kapitel 1 (Entwurf)

Entwurf Homer, 01.11.; Vorgang 447.4, Besetzung entschieden in 447.4a (Vorgangsarchiv). Abnahmeliste Stufe 3: Pfad und Lehrmeister (3.1), Meisterschaften (3.2) und Ruf (3.3) in `STORY-RUF-K1.md`. Quellen: Nachschlagewerk `DESIGN-SPIELSYSTEM-2-0-ENTWURF.md` Abschnitte 5, 6; Figuren `LISTE-FIGUREN.md`. Englische Begriffe nach `[423.namen]`. Fremd geprüft 01.11. Prüfpunkte: `docs/chefsache/ansehen/4474-lehrmeister-texte.md`.

## Für Tom

- **Einladung:** beim nächsten Gespräch mit dem Lehrmeister, sobald zwei Kernfertigkeiten seines Pfads Geselle sind (NW 5), bei Meisterschaften Haupt- und Zulieferfertigkeit (NW 6). Erst `…ruf`, dann `…frage`, dann die Wahl `[447.4.wahl.ja]` / `[447.4.wahl.nein]`. Jede `…ruf`-Zeile passt zu jedem Paar von Kernfertigkeiten.
- **Zwei Pfade zugleich** (Osric, Garrick, Morwen): statt `…ruf` und `…frage` die Zeile `…beide` mit drei Antworten.
- **Pfad und Meisterschaft zugleich** (Garrick, Morwen): erst der Pfad, die Meisterschaft im nächsten Gespräch.
- **„Noch nicht.“:** der Lehrmeister fragt nicht von selbst wieder; im Gespräch bleibt die Wahl `[447.4.wahl.pfad]` oder `[447.4.wahl.handwerk]`, sie führt wieder zu `…frage`.
- **Anwärter** (Pfad und Meisterschaft, NW 6 „genauso“): nach `…ja` die Systemzeile `[447.4.sys.anwaerter]`; danach in jedem Gespräch einmal `…hinweis` vor seinem üblichen Text.
- **Grenze in Kapitel 1:** stehen alle Kernfertigkeiten (bei Meisterschaften beide Fertigkeiten) am Ende von Geselle (49), sagt er statt `…hinweis` die Zeile `…grenze` (Zwischenprüfung erst ab Kapitel 2, NW 5).
- **Schon ein Pfad:** bei einem anderen Lehrmeister vor `…frage` die Zeile `[447.4.wechsel]`, beim selben `[447.4.wechsel.selbst]`; nach „Ja.“ die Systemzeile `[447.4.sys.wechsel]` mit eigener Bestätigung.
- `{name}` Held, `{weg}` Name des Pfads oder der Meisterschaft, `{rezept}` Rezeptname aus dem Katalog.

## Wahl und Systemzeilen

`[447.4.wahl.pfad]` Über den Pfad sprechen / EN: Talk about the path
`[447.4.wahl.handwerk]` Über das Handwerk sprechen / EN: Talk about the craft
`[447.4.wahl.ja]` Ja. / EN: Yes.
`[447.4.wahl.nein]` Noch nicht. / EN: Not yet.
`[447.4.sys.anwaerter]` Du bist Anwärter: {weg}. / EN: You are an Aspirant: {weg}.
`[447.4.sys.rezept]` Neues Rezept: {rezept}. / EN: New recipe: {rezept}.
`[447.4.wechsel]` Du gehst schon bei einem anderen in die Lehre. Ich nehme dich trotzdem, wenn du willst. / EN: You're already learning under someone else. I'll take you anyway, if you want.
`[447.4.wechsel.selbst]` Du gehst bei mir schon den anderen Weg. Willst du wechseln? / EN: You're already walking the other path with me. Do you want to switch?
`[447.4.sys.wechsel]` Du gibst den Pfad {weg} auf. Seine Handlungen gehen verloren, seine Kernfertigkeiten fallen um einen Rang. Wirklich wechseln? / EN: You give up the {weg} path. Its actions are lost and its core skills drop one rank. Switch anyway?

## Pfade (3.1)

### Wache Jorin · Wächter (Schild, Schwere Rüstung)

`[447.4.jorin.ruf]` Du stehst wie einer, der Schläge eingesteckt hat und nicht umgefallen ist. Das lernt man nicht in der Schänke. / EN: You stand like someone who's taken blows and stayed on his feet. You don't learn that at the inn.
`[447.4.jorin.frage]` Ein Wächter weicht nicht. Er hält, damit die anderen leben. Willst du Wächter werden? / EN: A Warden doesn't give ground. He holds, so the others live. Do you want to become a Warden?
`[447.4.jorin.ja]` Gut. Ab heute bist du mein Anwärter. Ich steh hier am Schlagbaum, Tag und Nacht. / EN: Good. From today you're my Aspirant. I'm here at the barrier, day and night.
`[447.4.jorin.hinweis]` Lass sie zuschlagen und halt stand. Ein Schild, der nie getroffen wird, lehrt dich nichts. / EN: Let them strike and hold your ground. A shield that's never hit teaches you nothing.
`[447.4.jorin.nein]` Auch recht. Ich steh hier, falls du es dir anders überlegst. / EN: Fair enough. I'm here if you change your mind.
`[447.4.jorin.grenze]` Weiter geht es nicht, nicht in diesem Dorf. Wenn der Weg dich weiterführt, prüfe ich dich. Bis dahin: halt die Stellung. / EN: This is as far as it goes, not in this village. When the road takes you further, I'll test you. Until then: hold the line.

### Bruder Osric · Heiler (Heilmagie, Schutzmagie, Heilkunde) und Paladin (Schild, Einhänder, Heilmagie)

`[447.4.osric.heiler.ruf]` Ich habe gesehen, wie du Wunden versorgst und dich schützt. Du hast ein Gespür dafür, {name}. / EN: I've seen how you tend wounds and shield yourself. You have a feel for it, {name}.
`[447.4.osric.heiler.frage]` Willst du Heiler werden? Es ist ein stiller Weg. Dank bekommt man selten. / EN: Do you want to become a Healer? It's a quiet path. Thanks are rare.
`[447.4.osric.paladin.ruf]` Du weichst nicht zurück, und du gibst nicht auf. So fängt ein Paladin an. / EN: You don't back down, and you don't give up. That's how a Paladin begins.
`[447.4.osric.paladin.frage]` Willst du Paladin werden? Dann trägst du das Licht nicht nur, du verteidigst es. Und die Leute müssen dir trauen können. / EN: Do you want to become a Paladin? Then you don't just carry the light, you defend it. And people must be able to trust you.
`[447.4.osric.beide]` Zwei Wege stehen dir offen, {name}: der des Heilers und der des Paladins. Welchen willst du gehen? (Antworten: Heiler. / Paladin. / Noch nicht.) / EN: Two paths lie open to you, {name}: the Healer's and the Paladin's. Which will you walk? (Healer. / Paladin. / Not yet.)
`[447.4.osric.ja]` Dann sei willkommen, Anwärter. Der Tempel steht dir offen, bei Tag und bei Nacht. / EN: Then be welcome, Aspirant. The temple is open to you, by day and by night.
`[447.4.osric.heiler.hinweis]` Heile, wo es nötig ist, und schütze, bevor es nötig wird. Und lerne, eine Wunde auch ohne Gebet zu verbinden. / EN: Heal where it's needed, and shield before it's needed. And learn to bind a wound without a prayer.
`[447.4.osric.paladin.hinweis]` Halte den Schild vor die Schwachen und das Schwert gegen die Starken. Und vergiss das Heilen nicht, wenn der Kampf vorbei ist. / EN: Hold your shield before the weak and your sword against the strong. And don't forget to heal when the fight is over.
`[447.4.osric.nein]` Das Licht drängt niemanden. Komm wieder, wenn du bereit bist. / EN: The light rushes no one. Come back when you're ready.
`[447.4.osric.grenze]` Weiter kann ich dich hier noch nicht führen. Wenn die Zeit reif ist, prüfe ich dich. Das Licht hat Geduld; hab sie auch. / EN: I can't lead you further yet. When the time is right, I'll test you. The light is patient; be patient too.

### Jäger Garrick · Waldläufer (Bogen, Tiere beruhigen, Jagd) und Scharfschütze (Armbrust oder Bogen, Wurfwaffen, Spähen)

`[447.4.garrick.waldlaeufer.ruf]` Ich hab dich im Wald gesehen. Du weißt, was du tust. / EN: I've watched you in the woods. You know what you're doing.
`[447.4.garrick.waldlaeufer.frage]` Willst du Waldläufer werden? Sag es, wenn es dir ernst ist. / EN: Do you want to be a Ranger? Say so if you're serious.
`[447.4.garrick.schuetze.ruf]` Du triffst, bevor sie dich sehen. Das kann kaum einer. / EN: You hit them before they see you. Hardly anyone can.
`[447.4.garrick.schuetze.frage]` Willst du Scharfschütze werden? Dann lernst du auch, wann man nicht schießt. / EN: Do you want to be a Marksman? Then you'll also learn when not to shoot.
`[447.4.garrick.beide]` Bogen und Wild oder Auge und Ziel. Beides kannst du. Was willst du werden? (Antworten: Waldläufer. / Scharfschütze. / Noch nicht.) / EN: Bow and beast, or eye and mark. You can do both. Which will it be? (Ranger. / Marksman. / Not yet.)
`[447.4.garrick.ja]` Gut. Am Feuer ist Platz. / EN: Good. There's room by the fire.
`[447.4.garrick.waldlaeufer.hinweis]` Nicht jedes Tier muss sterben. Sprich mit ihm, bevor du den Bogen spannst. Und was du erlegst, zerleg sauber. / EN: Not every beast has to die. Talk to it before you draw the bow. And whatever you kill, butcher it cleanly.
`[447.4.garrick.schuetze.hinweis]` Halt still und schau, bevor du schießt. Wer zuerst sieht, schießt zuerst. Und lern werfen; ein Messer ist schneller zur Hand als ein Pfeil. / EN: Keep still and look before you shoot. Whoever sees first shoots first. And learn to throw; a knife is quicker to hand than an arrow.
`[447.4.garrick.nein]` Auch gut. Das Feuer brennt trotzdem. / EN: That's fine too. The fire burns all the same.
`[447.4.garrick.grenze]` Mehr geht hier nicht. Wenn du weiter draußen warst als dieser Wald, prüf ich dich. / EN: This is as far as it goes here. Once you've been further out than these woods, I'll test you.

### Thessa · Schatzjäger (Schlösser knacken, Fallen entschärfen, Spähen)

`[447.4.thessa.ruf]` Flinke Finger und wache Augen, {name}. Das gefällt mir. / EN: Nimble fingers and sharp eyes, {name}. I like that.
`[447.4.thessa.frage]` Ich frage nicht, woher. Ich frage, ob du mehr willst. Willst du Schatzjäger werden? / EN: I don't ask where from. I ask if you want more. Do you want to become a Treasure Hunter?
`[447.4.thessa.ja]` Abgemacht. Du bist mein Anwärter, und kein Wort davon am Brunnen. Liska hört alles. / EN: Deal. You're my Aspirant, and not a word of it at the well. Liska hears everything.
`[447.4.thessa.hinweis]` Schau dich um, bevor du eine Truhe anfasst. Fallen beißen nur die Eiligen. Und nimm gute Dietriche; billige brechen. / EN: Look around before you touch a chest. Traps only bite the hasty. And use good lockpicks; cheap ones break.
`[447.4.thessa.nein]` Schade. Mein Laden steht dir trotzdem offen. Meistens. / EN: Pity. My shop is still open to you. Mostly.
`[447.4.thessa.grenze]` Hier im Dorf gibt es für dich nichts mehr zu knacken. Wenn du weiter warst, prüf ich dich. / EN: There's nothing left in this village for you to crack. Once you've been further, I'll test you.

### Kräuterfrau Morwen · Magier (zwei Schulen) und Kriegsmagier (Evokation, Einhänder oder Zweihänder, Leichte Rüstung)

`[447.4.morwen.magier.ruf]` Na sieh an. Du rufst, und es kommt. Und nicht nur auf eine Weise. / EN: Well, well. You call, and it comes. And not in just one way.
`[447.4.morwen.magier.frage]` Ich weiß mehr davon, als ich im Dorf erzähle. Willst du Magier werden? / EN: I know more of this than I tell in the village. Do you want to become a Mage?
`[447.4.morwen.kriegsmagier.ruf]` Du kämpfst wie einer, der mehr will als Eisen. Das sieht man selten, und meistens nicht lange. / EN: You fight like someone who wants more than iron. You rarely see that, and usually not for long.
`[447.4.morwen.kriegsmagier.frage]` Willst du Kriegsmagier werden? Dann lass das Eisen vom Leib. Leder, nicht mehr. / EN: Do you want to become a Battlemage? Then keep iron off your body. Leather, nothing more.
`[447.4.morwen.beide]` Zwei Türen, {name}. Die eine führt tiefer in die Kunst, die andere mitten in den Kampf. Welche? (Antworten: Magier. / Kriegsmagier. / Noch nicht.) / EN: Two doors, {name}. One leads deeper into the craft, the other into the thick of the fight. Which? (Mage. / Battlemage. / Not yet.)
`[447.4.morwen.ja]` Gut. Dann komm ans Feuer, Anwärter. Hier draußen hört uns keiner. / EN: Good. Then come to the fire, Aspirant. No one hears us out here.
`[447.4.morwen.magier.hinweis]` Übe beide Künste, nicht nur die bequeme. Und zieh aus, was klirrt, wenn du aus der Luft schöpfen willst. / EN: Practise both arts, not just the easy one. And take off whatever clinks if you want to draw from the air.
`[447.4.morwen.kriegsmagier.hinweis]` Schlag zu, und wenn sie zurückweichen, brenn sie. Und bleib beim Leder; Eisen und Glut vertragen sich nicht. / EN: Strike, and when they fall back, burn them. And stick to leather; iron and ember don't get along.
`[447.4.morwen.nein]` Wie du willst. Der Wald wartet. Ich auch. / EN: As you wish. The forest waits. So do I.
`[447.4.morwen.grenze]` Noch nicht. Erst musst du draußen etwas gesehen haben; dann prüfe ich dich. / EN: Not yet. First you have to see something out there; then I'll test you.

## Offen

- **Erstes Rezept beim Ja** (`[447.4.sys.rezept]`; die `…ja`-Zeilen von Morwen, Garrick, Rowena reichen etwas): das Nachschlagewerk sagt nur „Rezepte gibt es bei Lehrmeistern“ (NW 10), 3.2 „je ein Rezept“. Ob das Rezept mit dem Ja kommt, entscheidet Perikles mit 3.2; sonst entfallen die Systemzeile und der Halbsatz nach dem Punkt.
- **Aufgaben des Lehrmeisters** (NW 5 „Hinweise und Aufgaben“): hier nur Hinweise. Aufgaben mit Lohn wären Quests mit Regelwirkung; Texte erst, wenn sie festgelegt sind.
- **Wechsel als Anwärter in Kapitel 1:** ob die Kernfertigkeiten auch dann um einen Rang fallen, legt das Nachschlagewerk nicht fest (Sokrates).
- **Dietriche:** Thessa führt heute keine (`geschichte.gd` SHOP_STOCK); `[447.4.thessa.hinweis]` setzt sie nicht als Ware voraus.
