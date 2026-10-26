package de.bornim.core

/**
 * 352: the guide in the system menu, how the game goes: the rules in brief, what each screen shows, the abilities.
 * Homer's text (`STORY-ANLEITUNG.md` [352.…]); a paragraph opens with its heading in **bold**, and bold words inside it
 * name buttons. A change of the rules in the code changes its paragraph with it.
 */
object Guide {
    val title = T("Anleitung", "Guide")
    val sign = T("Anleitung", "Guide")
    val signHint = T("Wie das Spiel geht: Regeln, Bildschirme, Fähigkeiten.", "How the game works: rules, screens, abilities.")
    val marsSign = T("MARS", "MARS")
    val marsHint = T("Probekampf nach dem neuen Kampfsystem MARS, mit Söldner. Dein Held und deine Tasche bleiben, wie sie sind.",
        "A trial fight with the new MARS battle system, with a mercenary. Your hero and your bag stay as they are.")

    /** A paragraph; one with a [only] class is shown to that class alone. */
    class Part(val de: String, val en: String, val only: CharClass? = null) {
        operator fun invoke(lang: Lang) = if (lang == Lang.DE) de else en
    }

    val parts = listOf(
        // [352.vorweg]
        Part("Die Regeln folgen dem System Reference Document 5.1 (SRD 5.1), vereinfacht. Hier steht, was du zum Spielen brauchst; den Rest findest du beim Spielen.",
            "The rules follow the System Reference Document 5.1 (SRD 5.1), simplified. Here is what you need to play; the rest you find by playing."),
        // [352.welt]
        Part("**Unterwegs.** Laufen, Ansprechen und Untersuchen erklärt der Hinweis beim Erwachen; einstellen kannst du es unter System, Bedienung. Der Aktionsknopf zeigt, was vor dir zu tun ist: sprechen, öffnen, lesen, rasten, betreten. Im hohen Gras und in der Höhle lauern Monster, die dich aus dem Hinterhalt anfallen; auf den Wegen bist du sicherer. Andere Monster siehst du: manche wandern nur umher, manche lauern still an ihrem Platz, und Jäger folgen dir, bis du ihnen davonläufst oder einen sicheren Ort wie Garricks Feuer erreichst. Wer von hinten auf ein Monster trifft, schlägt zuerst; wen ein Monster von hinten erwischt, der wird überrascht. Wer rennt, wird früher gehört. Besiegte Monster kommen nach einer Weile wieder.",
            "**On the road.** Walking, talking and examining are explained by the hint when you wake; you can change them under System, Handling. The action button shows what there is to do ahead of you: talk, open, read, rest, enter. In tall grass and in the cave, monsters lurk and ambush you; on the paths you are safer. Other monsters you can see: some just roam, some lurk still in their place, and hunters follow you until you outrun them or reach a safe place such as Garrick's fire. Whoever comes upon a monster from behind strikes first; whoever a monster catches from behind is taken by surprise. Running makes you heard sooner. Defeated monsters come back after a while."),
        // [352.leiste]
        Part("**Die Leiste oben.** TP sind deine Trefferpunkte: grün, gelb, dann rot. ZP sind Zauberpunkte, nur bei Magier und Kleriker. EP sind Erfahrungspunkte bis zur nächsten Stufe. Rechts stehen Tag und Uhrzeit. Darunter kleine Zeichen: Zustände wie Gift oder Blut, „Satt“ nach einer Mahlzeit, „Schutz“ für die Magierrüstung und ★, wenn du Punkte verteilen kannst. Der goldene Balken am rechten Rand ist deine Ausdauer beim Rennen; er erscheint nur, wenn sie nicht voll ist. Ein Tipp auf die Leiste öffnet das Menü, das Kartenzeichen die Karte.",
            "**The bar at the top.** HP are your hit points: green, yellow, then red. SP are spell points, for wizard and cleric only. XP are experience points toward the next level. On the right: day and time. Below, small signs: conditions such as Psn or Bld, “Fed” after a meal, “Ward” for mage armor, and ★ when you have points to spend. The golden bar on the right edge is your stamina for running; it shows only when it is not full. A tap on the bar opens the menu, the map sign the map."),
        // [352.kampf]
        Part("**Kampf.** Du und der Gegner ziehen abwechselnd; wer zuerst dran ist, entscheidet ein Wurf, in den deine Geschicklichkeit eingeht. In deinem Zug wählst du eins: **Angriff** mit der Waffe. **Fähigkeiten**: Zauber und Künste deiner Klasse. **Tasche**: Tränke und Wurfgeschosse. **Abwehr**: Angriffe auf dich haben Nachteil, und verfehlt dich der Gegner, hat dein nächster Angriff Vorteil. **Flucht**: gelingt nicht immer und kostet dann den Zug; vor Bossen gibt es keine. **Zug beenden**: du wartest ab.",
            "**Battle.** You and the foe take turns; a roll that counts your dexterity decides who goes first. On your turn you choose one: **Attack** with your weapon. **Abilities**: your class's spells and skills. **Bag**: potions and things to throw. **Defend**: attacks on you have disadvantage, and if the foe misses, your next attack has advantage. **Run**: does not always work and then costs the turn; there is no fleeing from bosses. **End turn**: you wait."),
        // [352.wurf]
        Part("**Würfe.** Ein Angriff würfelt mit dem zwanzigseitigen Würfel und zählt deinen Bonus dazu; erreicht die Summe die Rüstungsklasse (RK) des Gegners, trifft der Angriff. Vorteil heißt: zwei Würfel, der bessere zählt; Nachteil: der schlechtere. Eine 20 ist ein kritischer Treffer mit doppelten Schadenswürfeln; Hiebwaffen lassen dann bluten, Wuchtwaffen können betäuben. Eine 1 geht immer daneben. Das Würfelzeichen unten links schaltet die Anzeige der Würfe ein und aus.",
            "**Rolls.** An attack rolls the twenty-sided die and adds your bonus; if the total reaches the foe's armor class (AC), the attack hits. Advantage means two dice, the better one counts; disadvantage, the worse. A 20 is a critical hit with double damage dice; slashing weapons then make the foe bleed, bludgeoning weapons may stun. A 1 always misses. The dice sign at the bottom left turns the display of rolls on and off."),
        // [352.zweiwaffen]
        Part("**Zwei Waffen.** Trägst du in der Nebenhand eine Waffe statt Schild oder Fackel, schlägt sie bei jedem Angriff von selbst mit, ohne deinen Attributsbonus auf den Schaden. Du gibst dafür die RK des Schildes auf.",
            "**Two weapons.** If you carry a weapon in your off hand instead of a shield or torch, it strikes along with every attack, without your ability bonus to damage. In return you give up the shield's AC."),
        // [352.zustaende]
        Part("**Zustände.** Gift, Brand und Blutung kosten jede Runde TP; Blutung halbiert dazu die Heilung. Betäubt verliert eine Runde. Verlangsamt und Geschwächt senken Treffen, RK oder Schaden; Geblendet und Betrunken geben Nachteil. Gift, Blutung und Schwäche bleiben nach dem Kampf; Gift und Blutung kosten auf dem Weg weiter TP, aber nie bis unter 1. Ein Kräutertrank, eine lange Rast oder Bruder Osric heilen sie. Betrunken vergeht mit jeder Rast.",
            "**Conditions.** Poison, burning and bleeding cost HP every round; bleeding also halves healing. Stunned loses a round. Slowed and weakened lower hitting, AC or damage; blinded and drunk give disadvantage. Poison, bleeding and weakness stay after the fight; poison and bleeding go on costing HP along the way, but never below 1. An herbal remedy, a long rest or Brother Osric cures them. Drunkenness passes with any rest."),
        // [352.rudel]
        Part("**Rudel.** Manche Gegner kommen nicht allein; die anderen kämpfen mit. Fällt der Anführer, fliehen sie.",
            "**Packs.** Some foes do not come alone; the others fight along. When the leader falls, they flee."),
        // [352.fallen]
        Part("**Wenn du fällst.** Sinken deine TP auf null, ist es nicht vorbei: du erwachst Stunden später dort, wo du zuletzt gerastet hast oder geheilt wurdest, ganz geheilt, ohne Gold zu verlieren. Nur der Kampf ist verloren, und die Zeit.",
            "**If you fall.** If your HP drop to zero, it is not over: you wake hours later where you last rested or were healed, fully healed, without losing any gold. Only the fight is lost, and the time."),
        // [352.rast]
        Part("**Rasten.** Am Lagerfeuer wählst du: **kurze Rast** (eine Stunde): Ausdauer voll und ein Viertel der TP zurück. **Lange Rast** (acht Stunden, einmal am Tag): TP, ZP und Ausdauer voll, Zustände geheilt, alle Fähigkeiten wieder bereit. Ein Zimmer in der Schänke ist eine lange Rast für 5 Gold; Bruder Osric im Tempel heilt umsonst. In der Höhle kannst du nicht rasten.",
            "**Resting.** At a campfire you choose: **short rest** (one hour): stamina full and a quarter of your HP back. **Long rest** (eight hours, once a day): HP, SP and stamina full, conditions cured, all abilities ready again. A room at the inn is a long rest for 5 gold; Brother Osric in the temple heals for free. You cannot rest in the cave."),
        // [352.dunkel]
        Part("**Dunkel.** Nachts und in der Höhle siehst du weniger weit. Eine Fackel in der Nebenhand leuchtet weiter, nimmt aber den Platz des Schildes. Ein Leuchtfunke leuchtet bis zur nächsten Rast, macht dich im Dunkeln aber früher sichtbar. Die Fackel verrät dich nicht, der Leuchtfunke schon. Wald und Höhle decken sich erst auf, wenn du hinsiehst.",
            "**Dark.** At night and in the cave you see less far. A torch in your off hand lights farther, but takes the shield's place. A lightspark shines until your next rest, but makes you seen sooner in the dark. The torch does not give you away; the lightspark does. Woods and cave reveal themselves only where you look."),
        // [352.held]
        Part("**Dein Held.** Sechs Attribute: Stärke für Nahkampf, Geschicklichkeit für RK, Fernkampf, Flucht und leises Gehen, Konstitution für TP und Ausdauer, Intelligenz für Magierzauber, Weisheit für Klerikerzauber und Sicht, Charisma für Preise und Gegner, die zögern. Im Reiter Held erklärt jedes Attribut beim Antippen, was es bringt. EP gibt es für Kämpfe. Jede Stufe bringt mehr TP und füllt TP und ZP auf; auf Stufe 2, 3 und 5 kommen Fähigkeiten dazu, auf Stufe 5 auch Treffsicherheit; auf Stufe 4 verteilst du zwei Attributspunkte. In Kapitel 1 ist Stufe 6 das Höchste.",
            "**Your hero.** Six abilities: strength for melee, dexterity for AC, ranged attacks, fleeing and moving quietly, constitution for HP and stamina, intelligence for wizard spells, wisdom for cleric spells and sight, charisma for prices and foes who hesitate. In the Hero tab every ability explains on a tap what it does. XP come from fights. Each level brings more HP and refills HP and SP; levels 2, 3 and 5 bring new abilities, level 5 also accuracy; at level 4 you spend two ability points. In chapter 1, level 6 is the highest."),
        // [352.faehigkeiten]
        Part("**Fähigkeiten.** Manche gelten immer (passiv), manche einmal je Kampf, manche einmal je langer Rast, Zauber kosten ZP. Zaubertricks kosten nichts (∞). In der Liste im Kampf steht hinter jeder Fähigkeit, was sie kostet; Gesperrtes ist grau, Passives steht nicht darin.",
            "**Abilities.** Some always apply (passive), some once per fight, some once per long rest; spells cost SP. Cantrips cost nothing (∞). In the battle list each ability shows its cost; what is locked is gray, passive ones are not listed."),
        // [352.kaempfer]
        Part("**Kämpfer.** Kampfstil: Verteidigung: +1 RK in Rüstung. Zweiter Atem: heilt dich einmal je Kampf. Ab Stufe 2 Tatendrang: zwei volle Angriffe in einem Zug, einmal je langer Rast. Ab Stufe 3 kritisch schon bei 19. Ab Stufe 5 zwei Angriffe bei jedem Angriff.",
            "**Fighter.** Fighting Style: Defense: +1 AC in armor. Second Wind: heals you once per fight. From level 2 Action Surge: two full attacks in one turn, once per long rest. From level 3 a critical hit on 19 as well. From level 5 two attacks with every attack.", CharClass.FIGHTER),
        // [352.magier]
        Part("**Magier.** Feuerpfeil, ein Zaubertrick: Feuer, kann in Brand setzen, kostet nichts. Magisches Geschoss trifft immer. Magierrüstung gibt RK 13 plus Geschicklichkeit für acht Stunden, nur ohne Rüstung. Ab Stufe 3 Sengender Strahl: drei Strahlen. Ab Stufe 5 Feuerball, einmal je Kampf: großer Schaden, verjagt oft ein ganzes Rudel.",
            "**Wizard.** Fire Bolt, a cantrip: fire, may set ablaze, costs nothing. Magic Missile always hits. Mage Armor gives AC 13 plus dexterity for eight hours, only without armor. From level 3 Scorching Ray: three rays. From level 5 Fireball, once per fight: great damage, often drives off a whole pack.", CharClass.WIZARD),
        // [352.schurke]
        Part("**Schurke.** Hinterhältiger Angriff: mehr Schaden beim ersten Treffer im Kampf und bei Vorteil, mit Finesse-Waffe, Fernwaffe oder ohne Waffe. Finte, zweimal je Kampf: ein Angriff mit Vorteil. Ab Stufe 2 Raffinierte Aktion: Flucht gelingt immer, außer vor Bossen. Ab Stufe 3 Unglaubliches Ausweichen: der erste Treffer zählt nur halb, ab Stufe 5 jede Runde.",
            "**Rogue.** Sneak Attack: more damage on the first hit of a fight and with advantage, with a finesse weapon, a ranged weapon or unarmed. Feint, twice per fight: an attack with advantage. From level 2 Cunning Action: fleeing always works, except from bosses. From level 3 Uncanny Dodge: the first hit counts only half, from level 5 every round.", CharClass.ROGUE),
        // [352.kleriker]
        Part("**Kleriker.** Heilige Flamme, ein Zaubertrick: Licht, kann blenden, kostet nichts. Wunden heilen. Segnen: Bonus auf Angriffe für den ganzen Kampf. Ab Stufe 2 Untote vertreiben, einmal je Kampf. Ab Stufe 3 Spirituelle Waffe: schlägt jede Runde mit. Ab Stufe 5 Geisterwächter: trifft jede Runde.",
            "**Cleric.** Sacred Flame, a cantrip: light, may blind, costs nothing. Cure Wounds. Bless: a bonus to attacks for the whole fight. From level 2 Turn Undead, once per fight. From level 3 Spiritual Weapon: strikes along every round. From level 5 Spirit Guardians: hits every round.", CharClass.CLERIC),
        // [352.tasche]
        Part("**Tränke und Wurfgeschosse.** Ein Trank im Kampf kostet den Zug. Heiltränke heilen, die großen mehr; Kräutertränke heilen wenig, nehmen aber Gift und andere Zustände. Alchemistenfeuer trifft immer und setzt in Brand; Weihwasser trifft nur Untote, die dafür hart.",
            "**Potions and things to throw.** A potion in battle costs your turn. Healing potions heal, the greater ones more; herbal remedies heal little but take away poison and other conditions. Alchemist's fire always hits and sets ablaze; holy water hits only the undead, but hard."),
        // [352.menue]
        Part("**Das Menü.** **Held**: Werte, Attribute, Fähigkeiten; hier verteilst du Punkte. **Tasche**: Vorräte benutzen, Ausrüstung anlegen, eine Waffe in die Nebenhand nehmen, Dinge wegwerfen. **Ausrüstung**: was du trägst, Platz für Platz, und deine Kampfwerte. **Karte**: Landkarte, Gebietskarte und Grundriss; Aufträge, Leute und Dienste lassen sich einblenden. **Chronik**: deine Aufträge mit Stand und was bisher geschah. **System**: Speichern, Sprache und Einstellungen; ein langer Druck erklärt jedes Zeichen.",
            "**The menu.** **Hero**: stats, ability scores, abilities; here you spend points. **Bag**: use supplies, put on gear, take a weapon into your off hand, throw things away. **Equipment**: what you wear, slot by slot, and your battle stats. **Map**: land map, area map and floor plan; quests, people and services can be shown. **Chronicle**: your quests with their progress and what has happened so far. **System**: saving, language and settings; a long press explains each sign."),
        // [352.handel]
        Part("**Handel und Aufträge.** Bei Thessa im Laden kaufst und verkaufst du; nach einigen Siegen hat sie neue Ware. Morwen braut dir aus Kräutern Tränke; Kräuter pflückst du, wenn du über Blumenwiesen im Wald läufst. Mit Charisma kaufst du billiger und verkaufst teurer. Am Anschlagbrett vor der Schänke hängen Aufträge; nimm an, was dir gefällt, und bring dem Auftraggeber, was er sucht.",
            "**Trade and jobs.** At Thessa's store you buy and sell; after some victories she has new wares. Morwen brews potions from herbs; you pick herbs by walking over flower meadows in the woods. With charisma you buy cheaper and sell for more. The notice board before the inn holds jobs; take what you like and bring the one who asked what they seek."),
        // [352.speichern]
        Part("**Speichern.** Das Spiel speichert von selbst, wenn du einen Ort betrittst oder verlässt, rastest, fällst, einen Auftrag annimmst oder das Spiel verlässt. Unter System kannst du jederzeit selbst speichern. Im Hauptmenü gibt es vier Plätze für Helden.",
            "**Saving.** The game saves by itself when you enter or leave a place, rest, fall, take a job or leave the game. Under System you can save yourself at any time. The main menu has four slots for heroes."),
    )

    /** The paragraphs a hero of [cls] reads: the abilities of the own class only. */
    fun partsFor(cls: CharClass): List<Part> = parts.filter { it.only == null || it.only == cls }

    /** The text cut where it turns **bold** and back: (text, bold) pieces in order. */
    fun pieces(text: String): List<Pair<String, Boolean>> =
        text.split("**").mapIndexedNotNull { i, s -> if (s.isEmpty()) null else s to (i % 2 == 1) }
}
