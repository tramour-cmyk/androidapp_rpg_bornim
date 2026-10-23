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

## Hinweis beim ersten Öffnen (326)

`[326.hinweis]` (einmal, beim ersten Öffnen des Menüs, `vm.signHintSeen`) Halte ein Zeichen gedrückt, und es erklärt sich.
EN: Press and hold a sign to see what it does.

## Reiternamen (326)

Überschrift groß über der Zeichenleiste: die vorhandenen Namen, ausgeschrieben und unverändert: Held, Tasche, Ausrüstung, Chronik, System, Test (EN: Hero, Bag, Equipment, Chronicle, System, Test). „Ausrüstung“ passt als Überschrift; gekürzt würde es nur in der alten Textleiste.
