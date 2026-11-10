# Spieltexte Spielermenü (alle Kapitel)

Texte des Spielermenüs; Verzeichnis `STORY-REGELN.md`. Bau Team Tom (`MenuSigns.kt`, `MenuScreen.kt`).

## Systemreiter: Erklärung bei langem Druck (326)

Ein Satz je Zeichen, im Fenster über dem Menü. Der Zustand (An, Aus, Ruhig …) steht schon unter dem Zeichen; der Satz sagt, was es tut. Vorhanden und unverändert: Tempo (Entwurf Homer, in `MenuSigns.kt`), Rückfragen (`Ui.confirmHint`), Joystick (in `MenuSigns.kt`).

`[326.sys.speichern]` Hält deinen Stand jetzt fest. Beim Verlassen des Spiels und auf dem Weg ins Hauptmenü speichert es ohnehin.
EN: Saves your progress now. The game also saves when you leave it or go to the main menu.

`[326.sys.sprache]` Wechselt zwischen Deutsch und Englisch.
EN: Switches between German and English.

`[326.sys.regeln]` Öffnet die Regeln des Kampfsystems MARS zum Nachlesen.
EN: Opens the rules of the MARS battle system to read.

`[326.sys.hauptmenue]` Speichert und kehrt zum Hauptmenü zurück.
EN: Saves and returns to the main menu.

`[326.sys.blut]` Wie viel Blut Treffer zeigen. Antippen wechselt: Aus, Dezent, Deutlich.
EN: How much blood hits show. Tap to change: off, subtle, strong.

`[326.sys.kampftext]` Ob die Zeilen im Kampf auf dein Antippen warten oder nach einer Lesepause von selbst weiterlaufen.
EN: Whether the lines in a fight wait for your tap or run on by themselves after a pause to read.

`[326.sys.steuerung]` (ersetzt hier `Ui.touchHint`, das nur Wischen erklärt) Wischen: Finger ziehen zum Laufen, weit ziehen zum Rennen, tippen zum Hinlaufen. Klassisch: Steuerkreuz und ein großer Knopf zum Handeln.
EN: Swipe: drag to walk, drag far to run, tap to walk there. Classic: a D-pad and a big button to act.

`[326.sys.rennen]` Wie du rennst. Ring: über den Ring des Joysticks hinausziehen. Taste: dazu ein eigener Knopf zum Rennen.
EN: How you run. Ring: push past the joystick's ring. Button: adds a button of its own to run with.

`[326.sys.aktion]` Auf welcher Seite der Aktionsknopf steht: rechts, oder links für Linkshänder.
EN: Which side the action button sits on: right, or left for left-handed players.

`[326.sys.karte]` Wie nah die Karte ist. Näher zeigt weniger Umgebung, dafür größer.
EN: How close the map is. Nearer shows less around you, but larger.

`[326.sys.ruetteln]` Das Handy zittert kurz, wenn vor dir etwas zu tun ist oder ein Weg nicht geht.
EN: The phone buzzes briefly when there is something to do ahead of you or a way is blocked.

`[326.sys.schritte]` Die Schritte deines Helden hörbar oder still; alle anderen Geräusche bleiben.
EN: Your hero's footsteps audible or silent; all other sounds stay.

`[326.sys.ueber]` Wer das Spiel macht und worauf seine Regeln beruhen.
EN: Who makes the game and what its rules are based on.

`[326.abschnitt.bedienung]` (Überschrift über Steuerung, Joystick, Rennen, Aktion; statt „Steuerung“, das sonst doppelt steht) Bedienung
EN: Handling

`[296.2.kampfsystem]` (Zeichen in der Gruppe Kampf, 296.2; Name „Kampfsystem“, EN „Battle system“; Werte „Klassisch“, „MARS“, EN „Classic“, „MARS“) Wie deine Kämpfe ablaufen. Klassisch: der bewährte Zugkampf. MARS: das neue Kampfsystem, mit Reihen, angesagten Absichten der Gegner und dem Ring zum Abwehren. Gilt ab dem nächsten Kampf.
EN: How your fights play out. Classic: the proven turn-based fight. MARS: the new battle system, with rows, foes announcing their intents and the ring to ward off blows. Applies from the next fight.

## Hinweis beim ersten Öffnen (326)

`[326.hinweis]` (einmal, beim ersten Öffnen des Systemreiters, weil nur dessen Zeichen sich erklären; `vm.signHintSeen`, Tom 23.10.) Halte ein Zeichen gedrückt, und es erklärt sich.
EN: Press and hold a sign to see what it does.

## Reiternamen (326)

Überschrift groß über der Zeichenleiste: die vorhandenen Namen, ausgeschrieben und unverändert: Held, Tasche, Ausrüstung, Chronik, System, Test (EN: Hero, Bag, Equipment, Chronicle, System, Test)

## Grundwerte im Reiter „Held“ (817)

Homer 10.11.; ersetzt die SRD-Sätze aus `Perks.describe` (Ausfuhr `held.json` „erklaerung“, `menue.gd` 293; gleicher Wortlaut in `talente.gd` `describe`). Wörter nach `[423.werte]` und 683 (Schutzwert, Leben); Grundwert in Klammern = alter Schlüssel der Brücke `brs_held.gd` `ATTR_ALT`. **Nur, was der Code heute tut** (geprüft 10.11., 10:44, `godot` main 92b2f63f3); Platzhalter wie im Code. Gestrichen, weil es nirgends wirkt: Abwehr gegen Umwerfen, Wurfflaschen +Schaden, Abwehr gegen Netze, Schwächen erkennen, Lernen +Erfahrung, Abwehr gegen Flüche, Sicht im Nebel, Spirituelle Waffe. Kommt eine Wirkung dazu, kommt ihre Zeile mit.

`[817.kopf]` Wert %d, Bonus %s / EN: Value %d, bonus %s

`[817.kraft]` (STR)
- Treffer und Schaden mit Nahkampfwaffen; leichte Klingen wie Dolch und Kurzschwert nehmen die Gewandtheit, wenn sie höher ist. / EN: Hit and damage with melee weapons; light blades such as dagger and shortsword use Agility if it is higher.
- Schaden mit bloßen Fäusten. / EN: Damage with bare fists.
- Schwere Rüstung ohne genug Kraft halbiert die Ausdauer. / EN: Heavy armor without enough Strength halves your stamina.

`[817.gewandtheit]` (DEX)
- Schutzwert ohne Rüstung, mit leichter und (bis +2) mittlerer Rüstung. / EN: Protection without armor, with light and (up to +2) medium armor.
- Treffer und Schaden mit Fernwaffen und leichten Klingen. / EN: Hit and damage with ranged weapons and light blades.
- Wer im Kampf zuerst handelt, und die Aussicht zu fliehen. / EN: Who acts first in combat, and your chance to flee.
- Schleichen: jagende Monster bemerken dich erst ab %d Feldern (sonst 4). / EN: Sneaking: hunting monsters only notice you within %d tiles (normally 4).

`[817.zaehigkeit]` (CON)
- Leben je Stufe. / EN: Life per level.
- Abwehrprobe gegen Gift, Betäubung und Blendung. / EN: Defense roll against poison, stunning and blinding.
- Gift und Blutung klingen nach dem Kampf %d Runden schneller ab. / EN: Poison and bleeding wear off %d rounds sooner after combat.
- Mahlzeiten heilen +%d Leben. / EN: Meals heal +%d life.
- Länger rennen: je Punkt Bonus zwei Sekunden mehr Ausdauer. / EN: Run longer: two more seconds of stamina per point of bonus.

`[817.verstand]` (INT)
- (nur Zauberlehrling) Treffer und Stärke deiner Zauber; es zählt Verstand oder Wille, was höher ist. / EN: (Apprentice Mage only) Hit and power of your spells; Wits or Will counts, whichever is higher.
- Alchemie: %s Aussicht auf einen zusätzlichen Trank beim Brauen. / EN: Alchemy: %s chance of an extra potion when brewing.

`[817.wahrnehmung]` (WIS)
- (nur Klosterschüler) Treffer, Stärke und Heilung deiner Zauber; es zählt Wahrnehmung oder Wille, was höher ist. / EN: (Cloister Pupil only) Hit, power and healing of your spells; Perception or Will counts, whichever is higher.
- Hinterhalte: %s seltener. / EN: Ambushes: %s less often.
- Kräuterkunde: %s Aussicht auf ein zusätzliches Kraut beim Pflücken. / EN: Herbalism: %s chance of an extra herb when picking.

`[817.wille]` (CHA)
- Handeln: %d %% günstiger einkaufen und %d %% teurer verkaufen. (negativ: %d %% teurer einkaufen und %d %% billiger verkaufen.) / EN: Haggling: buy for %d%% less and sell for %d%% more. (negative: buy for %d%% more and sell for %d%% less.)
- Auftreten: %s Aussicht, dass ein gewöhnlicher Gegner eingeschüchtert zögert und seine erste Runde verliert (nie im Hinterhalt, nie bei einem Boss). / EN: Presence: %s chance that an ordinary foe hesitates, cowed, and loses its first round (never in an ambush, never against a boss).
- (Zauberlehrling, Klosterschüler) zählt für deine Zauber, wenn er höher ist als Verstand oder Wahrnehmung. / EN: (Apprentice Mage, Cloister Pupil) counts for your spells if it is higher than Wits or Perception.. „Ausrüstung“ passt als Überschrift; gekürzt würde es nur in der alten Textleiste.
