# Lehrmeister, Kapitel 1 (Entwurf)

Entwurf Homer, 01.11.; Vorgang 447.4, Besetzung entschieden in 447.4a (Vorgangsarchiv). Abnahmeliste Stufe 3: Pfad und Lehrmeister (3.1), Meisterschaften (3.2) und Ruf (3.3) in `STORY-RUF-K1.md`. Quellen: Nachschlagewerk `DESIGN-BRS.md` Abschnitte 5, 6; Figuren `LISTE-FIGUREN.md`. Englische Begriffe nach `[423.namen]`. Fremd geprüft 01.11.; Befunde Sokrates und Diogenes (02.11.) eingearbeitet 03.11. Entschieden 03.11., 15:50 „447.4 1B 2A“ (Vorgangsarchiv): nach „Noch nicht.“ fragt der Lehrmeister beim nächsten Besuch genau einmal, danach nur auf eigene Wahl; der Anwärter wechselt ohne Verlust. **Varianten (504):** jede Zeile, die man wiederholt hört, hat drei Wortlaute (Abschnitt „Varianten“ unten; 1 = Zeile oben); `…ruf`, `…frage`, `…beide`, `…ja`, `…nachfrage` hört man je Weg nur einmal.

## Für Tom

- **Einladung:** beim nächsten Gespräch mit dem Lehrmeister, sobald zwei Kernfertigkeiten seines Pfads Geselle sind (NW 5), bei Meisterschaften Haupt- und Zulieferfertigkeit (NW 6). Erst `…ruf`, dann `…frage`, dann die Wahl `[447.4.wahl.ja]` / `[447.4.wahl.nein]`. Jede `…ruf`-Zeile passt zu jedem Paar von Kernfertigkeiten.
- **Zwei Pfade zugleich** (Osric, Garrick, Morwen): statt `…ruf` und `…frage` die Zeile `…beide` mit drei Antworten.
- **Pfad und Meisterschaft zugleich** (Garrick, Morwen): erst der Pfad, die Meisterschaft im nächsten Gespräch.
- **„Noch nicht.“ (1B):** nach `…nein` fragt der Lehrmeister beim nächsten Gespräch genau einmal mit `…nachfrage` (dann wieder Ja / Noch nicht), danach nicht mehr von selbst; im Gespräch bleibt die Wahl `[447.4.wahl.pfad]` oder `[447.4.wahl.handwerk]`, sie führt zu `…wieder` (statt `…frage`). Bei zwei offenen Wegen ist `{weg}` „Heiler oder Paladin“ usw., die Antworten wie bei `…beide`. Pfad und Meisterschaft offen: erst die `…nachfrage` zum Pfad, die zur Meisterschaft im nächsten Gespräch. Meisterschaften kommen ohne Wechsel dazu (NW 6: man darf mehrere haben).
- **Karte:** sobald ein Lehrmeister eingeladen hat (auch nach „Noch nicht.“), steht unter seiner Zeile „Name – was“ im Schalter „Leute“ (`kartenreiter.gd` `zeichen()`) die zweite Zeile `[447.4.karte]`; Vorschlag Sokrates, Chef 03.11., 15:46.
- **Anwärter** (Pfad und Meisterschaft, NW 6 „genauso“): nach `…ja` die Systemzeile `[447.4.sys.anwaerter]`; danach in jedem Gespräch einmal `…hinweis` vor seinem üblichen Text.
- **Grenze in Kapitel 1:** stehen alle Kernfertigkeiten (bei Meisterschaften beide Fertigkeiten) am Ende von Geselle (49), sagt er statt `…hinweis` die Zeile `…grenze` (Weihe erst ab Kapitel 2, NW 5).
- **Schon ein Pfad:** bei einem anderen Lehrmeister vor `…frage`, `…nachfrage` oder `…wieder` die Zeile `[447.4.wechsel]`, beim selben `[447.4.wechsel.selbst]`; nach „Ja.“ die Systemzeile `[447.4.sys.wechsel]` mit eigener Bestätigung.
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
`[447.4.sys.wechsel]` (Anwärter, 2A; Wortlaut NW 5 „Wechseln“) Du gibst den Pfad {weg} auf. Wirklich wechseln? / EN: You're giving up the {weg} path. Switch?
`[447.4.karte]` Lehrmeister: {wege} / EN: Mentor: {wege} (`{wege}` alle Wege, zu denen er eingeladen hat, mit Komma; z. B. bei Garrick „Lehrmeister: Waldläufer, Schneider“; eigenes Feld, nicht an „Name – was“ hängen: Auftraggeber-Einträge holen die Leute-Zeile mit `get_slice(" – ", 1)`, sonst stünde sie auch unter dem Auftrag)

## Pfade (3.1)

### Wache Jorin · Wächter (Schild, Schwere Rüstung)

`[447.4.jorin.ruf]` Du stehst wie einer, der Schläge eingesteckt hat und nicht umgefallen ist. Das lernt man nicht in der Schänke. / EN: You stand like someone who's taken blows and stayed standing. You don't learn that at the inn.
`[447.4.jorin.frage]` Ein Wächter weicht nicht. Er hält, damit die anderen leben. Willst du Wächter werden? / EN: A Warden doesn't give ground. A Warden holds, so the others live. Do you want to become a Warden?
`[447.4.jorin.ja]` Gut. Ab heute bist du mein Anwärter. Ich steh hier am Schlagbaum, Tag und Nacht. / EN: Good. From today you're my Aspirant. I'm here at the barrier, day and night.
`[447.4.jorin.hinweis]` Lass sie zuschlagen und halt stand. Ein Schild, der nie getroffen wird, lehrt dich nichts. / EN: Let them strike and hold your ground. A shield that's never hit teaches you nothing.
`[447.4.jorin.nein]` Auch recht. Ich steh hier, falls du es dir anders überlegst. / EN: Fair enough. I'm here if you change your mind.
`[447.4.jorin.grenze]` Weiter geht es nicht, nicht in diesem Dorf. Wenn der Weg dich weiterführt, prüfe ich dich. Bis dahin: halt die Stellung. / EN: This is as far as it goes, not in this village. When the road takes you further, I'll test you. Until then: hold the line.

### Bruder Osric · Heiler (Heilmagie, Schutzmagie, Heilkunde) und Paladin (Schild, Einhänder, Heilmagie)

`[447.4.osric.heiler.ruf]` Ich habe gesehen, wie du Wunden versorgst. Du hast ein Gespür dafür, {name}. / EN: I've seen how you tend wounds. You have a feel for it, {name}.
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
`[447.4.garrick.schuetze.hinweis]` Halt still und schau, bevor du schießt. Wer zuerst sieht, schießt zuerst. Und lern werfen; nicht immer ist Zeit, den Bogen zu spannen. / EN: Keep still and look before you shoot. Whoever sees first shoots first. And learn to throw; there isn't always time to draw a bow.
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
`[447.4.morwen.kriegsmagier.ruf]` Du kämpfst leicht und schnell, nicht wie die Eisenköpfe aus dem Dorf. Daraus lässt sich etwas machen. / EN: You fight light and fast, not like the ironheads from the village. Something can be made of that.
`[447.4.morwen.kriegsmagier.frage]` Willst du Kriegsmagier werden? Dann lass das Eisen vom Leib. Leder, nicht mehr. / EN: Do you want to become a Battlemage? Then keep iron off your body. Leather, nothing more.
`[447.4.morwen.beide]` Zwei Türen, {name}. Die eine führt tiefer in die Kunst, die andere mitten in den Kampf. Welche? (Antworten: Magier. / Kriegsmagier. / Noch nicht.) / EN: Two doors, {name}. One leads deeper into the craft, the other into the thick of the fight. Which? (Mage. / Battlemage. / Not yet.)
`[447.4.morwen.ja]` Gut. Dann komm ans Feuer, Anwärter. Hier draußen hört uns keiner. / EN: Good. Then come to the fire, Aspirant. No one hears us out here.
`[447.4.morwen.magier.hinweis]` Übe beide Künste, nicht nur die bequeme. Und zieh aus, was klirrt, wenn du aus der Luft schöpfen willst. / EN: Practise both arts, not just the easy one. And take off whatever clinks if you want to draw from the air.
`[447.4.morwen.kriegsmagier.hinweis]` Schlag zu, und wenn sie zurückweichen, brenn sie. Und bleib beim Leder; Eisen und Glut vertragen sich nicht. / EN: Strike, and when they fall back, burn them. And stick to leather; iron and ember don't get along.
`[447.4.morwen.nein]` Wie du willst. Der Wald wartet. Ich auch. / EN: As you wish. The forest waits. So do I.
`[447.4.morwen.grenze]` Noch nicht. Erst musst du draußen etwas gesehen haben; dann prüfe ich dich. / EN: Not yet. First you have to see something out there; then I'll test you.

## Varianten (504)

Wahl nach Zufall, nie zweimal hintereinander derselbe Wortlaut (Regeln oben in `STORY-VARIANTEN-K1.md`); 1 ist die Zeile oben. `…nachfrage` hört man nur einmal, `…wieder` hat drei eigene Wortlaute.

### Für alle Lehrmeister

`[447.4.wechsel]` 2. Du lernst schon bei einem anderen. Mir soll's recht sein, wenn du zu mir willst. / EN: You're already learning under someone else. Fine by me, if you want to come to me. · 3. Ein anderer hat dich schon. Und doch stehst du hier. Also? / EN: Someone else already has you. And yet here you stand. Well?
`[447.4.wechsel.selbst]` 2. Du gehst bei mir schon einen Weg. Willst du den anderen? / EN: You're already walking one path with me. Do you want the other? · 3. Umdenken ist erlaubt. Sag nur, welchen Weg du willst. / EN: Changing your mind is allowed. Just tell me which path you want.

### Jorin

`[447.4.jorin.nachfrage]` Neulich hast du gezögert. Ich frag noch einmal, dann lass ich's: Wächter? / EN: You hesitated the other day. I'll ask once more, then I'll let it be: Warden?
`[447.4.jorin.wieder]` 1. Also doch? Ja oder nein, {name}. / EN: So you've come round? Yes or no, {name}. · 2. Du willst über den Schild reden. Dann sag mir: Wächter, ja oder nein? / EN: You want to talk about the shield. Then tell me: Warden, yes or no? · 3. Ein Wächter entscheidet schnell. Also? / EN: A Warden decides quickly. Well?
`[447.4.jorin.hinweis]` 2. Trag das schwere Eisen, auch wenn es drückt. Wer es gewohnt ist, steht länger. / EN: Wear the heavy iron, even when it chafes. Whoever's used to it stands longer. · 3. Fang die Schläge mit dem Schild, nicht mit dem Kopf. Jeder Treffer darauf macht dich besser. / EN: Catch the blows on your shield, not your head. Every hit it takes makes you better.
`[447.4.jorin.nein]` 2. Gut. Der Schlagbaum steht, und ich auch. / EN: Good. The barrier stands, and so do I. · 3. Deine Sache. Ich lauf nicht weg. / EN: Your call. I'm not going anywhere.
`[447.4.jorin.grenze]` 2. Mehr bringt dir hier keiner bei, ich auch nicht. Zieh weiter, dann prüf ich dich. / EN: No one here can teach you more, not even me. Move on, then I'll test you. · 3. Du hältst, was ein Dorf von dir verlangen kann. Für die Prüfung musst du weiter hinaus. / EN: You hold what a village can ask of you. For the trial you have to go further out.

### Osric

`[447.4.osric.nachfrage]` Du warst neulich nicht bereit. Ein letztes Mal frage ich von mir aus: {weg}? / EN: You weren't ready the other day. One last time I'll ask of my own accord: {weg}?
`[447.4.osric.wieder]` 1. Du kommst darauf zurück. Das freut mich. Sag mir, wie du dich entschieden hast. / EN: You come back to it. That gladdens me. Tell me what you've decided. · 2. Hast du in dich gehört, {name}? Dann sprich. / EN: Have you listened within, {name}? Then speak. · 3. Das Licht hat Geduld, aber die Frage bleibt dieselbe: {weg}? / EN: The light is patient, but the question stays the same: {weg}?
`[447.4.osric.heiler.hinweis]` 2. Ein Verband zur rechten Zeit spart ein Gebet. Übe beides. / EN: A bandage at the right time saves a prayer. Practise both. · 3. Leg den Schutz, bevor der Schlag fällt, nicht danach. Und versorg die Wunde, solange sie frisch ist. / EN: Lay the ward before the blow falls, not after. And tend the wound while it's fresh.
`[447.4.osric.paladin.hinweis]` 2. Schild und Klinge, {name}, und ein Gebet für die, die fallen. Alle drei wollen geübt sein. / EN: Shield and blade, {name}, and a prayer for those who fall. All three want practice. · 3. Ein Paladin steht vorn. Also musst du auch heilen können, zuerst dich selbst. / EN: A Paladin stands at the front. So you must be able to heal as well, yourself first.
`[447.4.osric.nein]` 2. Dann bete ich für dich, bis du so weit bist. / EN: Then I'll pray for you until you're ready. · 3. Nicht jeder Weg beginnt am ersten Tag. Geh in Frieden. / EN: Not every path begins on the first day. Go in peace.
`[447.4.osric.grenze]` 2. Was ich dir hier geben kann, hast du. Den Rest prüft der Weg, und danach ich. / EN: What I can give you here, you have. The road will test the rest, and then I will. · 3. Du bist so weit gekommen, wie dieses Dorf dich tragen kann. Für die Prüfung musst du hinaus. / EN: You've come as far as this village can carry you. For the trial you must go out.

### Garrick

`[447.4.garrick.nachfrage]` (Wortlaut aus der Chefsache 447.4, in Git) Ich hab dich neulich was gefragt. {weg}? Ich frag kein drittes Mal. / EN: I asked you something the other day. {weg}? I won't ask a third time.
`[447.4.garrick.wieder]` 1. Also doch? Dann sag, was du willst. / EN: So, after all? Then say what you want. · 2. Hast du drüber nachgedacht? Gut. {weg}? / EN: Thought it over? Good. {weg}? · 3. Setz dich. Und dann raus damit. / EN: Sit down. Then out with it.
`[447.4.garrick.waldlaeufer.hinweis]` 2. Lauf leise und lies die Spuren. Ein Wolf, den du beruhigst, beißt dich nicht. / EN: Walk quietly and read the tracks. A wolf you calm won't bite you. · 3. Üb den Bogen jeden Tag. Und wenn ein Tier dich anknurrt: erst reden, dann schießen. / EN: Practise the bow every day. And when a beast snarls at you: talk first, shoot after.
`[447.4.garrick.schuetze.hinweis]` 2. Such dir den Platz, bevor du den Pfeil suchst. Wer gut steht, sieht mehr. / EN: Find your spot before you reach for an arrow. Whoever stands well sees more. · 3. Was du werfen kannst, ist schneller als jeder Bogen. Und die Augen immer offen. / EN: Whatever you can throw is faster than any bow. And your eyes always open.
`[447.4.garrick.nein]` (Wortlaute aus der Chefsache 447.4, in Git) 2. Wie du meinst. Du weißt, wo mein Feuer ist. / EN: As you like. You know where my fire is. · 3. Dann eben ein andermal. / EN: Another time, then.
`[447.4.garrick.grenze]` 2. Der Wald hat dir gezeigt, was er kann. Den Rest findest du draußen; dann prüf ich dich. / EN: The woods have shown you what they can. You'll find the rest out there; then I'll test you. · 3. Mehr kann ich dir hier nicht beibringen. Komm wieder, wenn du fremdes Land gesehen hast; dann prüf ich dich. / EN: I can't teach you more here. Come back once you've seen strange country; then I'll test you.

### Thessa

`[447.4.thessa.nachfrage]` Mein Angebot von neulich gilt noch. Einmal frag ich noch: Schatzjäger? / EN: My offer from the other day still stands. I'll ask once more: Treasure Hunter?
`[447.4.thessa.wieder]` 1. Na? Hast du es dir überlegt? / EN: Well? Thought it over? · 2. Du willst also reden. Leise, bitte. Schatzjäger, ja oder nein? / EN: So you want to talk. Quietly, please. Treasure Hunter, yes or no? · 3. Ich wusste, dass du wiederkommst. Also? / EN: I knew you'd come back. Well?
`[447.4.thessa.hinweis]` 2. Erst schauen, dann tasten, dann öffnen. In dieser Reihenfolge, immer. / EN: First look, then feel, then open. In that order, always. · 3. Ein Draht über der Schwelle, ein Stift im Schloss: übe an beiden. Und zähl dein Gold erst, wenn du draußen bist. / EN: A wire across the threshold, a pin in the lock: practise on both. And count your gold only once you're outside.
`[447.4.thessa.nein]` 2. Wie du willst. Wer flinke Finger hat, den vergesse ich nicht. / EN: As you like. I never forget anyone with nimble fingers. · 3. Schon gut. Liska erfährt nichts davon, von mir jedenfalls nicht. / EN: All right. Liska won't hear of it, not from me anyway.
`[447.4.thessa.grenze]` 2. Jedes Schloss im Dorf kriegst du auf. Draußen gibt es bessere; dann prüf ich dich. / EN: You can open every lock in the village. Out there are better ones; then I'll test you. · 3. Mehr bringt dir Bornim nicht bei. Komm wieder, wenn du Fremdes geöffnet hast; dann prüf ich dich. / EN: Bornim can't teach you more. Come back once you've opened stranger things; then I'll test you.

### Morwen

`[447.4.morwen.nachfrage]` (auch für Alchemist) Du hast neulich gezögert. Einmal frag ich noch: {weg}? / EN: You hesitated the other day. I'll ask once more: {weg}?
`[447.4.morwen.wieder]` (auch für Alchemist) 1. Also doch. Ich hab's gerochen. Sag, welchen Weg. / EN: So, after all. I could smell it. Tell me which way. · 2. Die Kräuter warten nicht, und ich nicht ewig. {weg}? / EN: The herbs don't wait, and I won't wait forever. {weg}? · 3. Du bist zurück, weil es dich nicht loslässt. Also? / EN: You're back because it won't let you go. Well?
`[447.4.morwen.magier.hinweis]` 2. Eine Kunst allein ist ein halbes Lied. Übe die andere auch, und lass das Eisen im Dorf. / EN: One art alone is half a song. Practise the other too, and leave the iron in the village. · 3. Schöpf langsam, nicht gierig. Und trag Stoff, kein Kettenhemd. / EN: Draw slowly, not greedily. And wear cloth, not mail.
`[447.4.morwen.kriegsmagier.hinweis]` 2. Klinge zuerst, dann das Feuer. Und dein Leib bleibt in Leder. / EN: Blade first, then the fire. And your body stays in leather. · 3. Wer brennt und schlägt, braucht freie Haut. Eisen erstickt die Glut; lass es. / EN: Whoever burns and strikes needs bare skin. Iron smothers the ember; leave it.
`[447.4.morwen.nein]` 2. Wie du willst. Der Kessel kocht auch ohne dich. / EN: Your call. The cauldron boils without you too. · 3. Wie du meinst. Ich bin geduldiger als die Kräuter. / EN: As you like. I'm more patient than the herbs.
`[447.4.morwen.grenze]` 2. Was der Wald dich lehren kann, weißt du. Bring mir etwas von draußen mit; dann prüfe ich dich. / EN: What the forest can teach you, you know. Bring me something from out there; then I'll test you. · 3. Hier kommst du nicht weiter, nicht bei mir. Erst die Welt, dann die Prüfung. / EN: You won't get further here, not with me. First the world, then the trial.

Meisterschaften (Morwen Alchemist, Garrick Schneider, Rowena) und Ruf: Varianten in `STORY-RUF-K1.md`.

## Offen

- **Erstes Rezept beim Ja** (`[447.4.sys.rezept]`; die `…ja`-Zeilen von Morwen, Garrick, Rowena reichen etwas): das Nachschlagewerk sagt nur „Rezepte gibt es bei Lehrmeistern“ (NW 10), 3.2 „je ein Rezept“. Ob das Rezept mit dem Ja kommt, entscheidet Perikles mit 3.2; sonst entfallen die Systemzeile und der Halbsatz nach dem Punkt.
- **Aufgaben des Lehrmeisters** (NW 5 „Hinweise und Aufgaben“): hier nur Hinweise. Aufgaben mit Lohn wären Quests mit Regelwirkung; Texte erst, wenn sie festgelegt sind.
- **Dietriche:** Thessa führt heute keine (`geschichte.gd` SHOP_STOCK); `[447.4.thessa.hinweis]` setzt sie nicht als Ware voraus.
