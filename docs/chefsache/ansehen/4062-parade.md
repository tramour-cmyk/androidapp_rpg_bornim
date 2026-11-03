# 406.2 · Parade-Film: Angriff gehen, gelungene Abwehr als Parade · Jerry · 03.11., 08:28

E Figuren
Berührt: D2 Gang aus dem Waffenpaket, D4 kein Gleiten, E4 Sword & Shield, F1 Schild vor dem Biss, F5 Ausweichen, G1 Ausschnitt
Kurz: Film nach deinem Wort von 06:59; das Gehen stimmt im einen gezeigten Angriff, die Paraden noch nicht.
Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41587796869 (Lauf 212, Commit f596907c1)

**Zu sehen:** Film (Telegram 406.2), 108 s, aufgebaut wie der Schildfilm von 06:59. 0–53 s beide Helden von vorn mit allen Bewegungen; 54–80 s der Kämpfer gegen das Wolfsrudel, 81–108 s der Kleriker.

**Geändert nach deinem Wort von 06:59:** Zum Angriff geht der Held mit dem Schritt aus dem Satz „Sword & Shield“, 1,3-mal so schnell wie normal (schneller rutschen die Füße). Gelingt die Abwehr, pariert er mit dem Schild, statt auszuweichen. Misslingt sie, bleibt es wie bisher.

**Prüfer am Film (03.11., 08:26):**
- Gehen: kein Rennen, kein Hopsen, kein Gleiten. Zu sehen ist aber nur ein Angriff, beim Kämpfer (77–79 s), ab 79 s steht er hinter einem Baumstamm. Der Kleriker greift im Film nicht an.
- Parade: der Held weicht nicht mehr aus. Er pariert aber jedes Mal gleich, mit dem Schild über dem Kopf (63,5 s, 90,5 s, 99,8 s). Du wolltest beim Wolf tief, Mitte, links, rechts und abwechselnd.
- Schild zu spät: beim Kleriker ist der Wolfskopf zweimal schon am Schild, bevor der Schild hochgeht (89,8 s, 99,0 s).
- Kampf des Kämpfers sehr dunkel, Helden klein und fast schwarz, links eine große schwarze Fläche (wie im Film von 06:59); beim Kleriker stehen die Helden die ganzen 27 s an ihrem Platz.

**Ursache Paraden (Jerry, am Code):** Die Wölfe greifen springend an. Für einen Sprung nimmt der Held die hohe Parade. Links oder rechts pariert er erst, wenn der Wolf mehr als 30° von der Seite kommt; im Film kamen sie von vorn. Richtig wäre nach deinem Wort: gegen Wölfe auch im Sprung tief oder Mitte, links oder rechts schon bei kleinerem Winkel. Mit deinem Wort baue ich das ohne neuen Film, es kommt mit dem nächsten Build.

**Stärkstes Gegenargument:** Ein Film zeigt nur einen Kampf mit Zufall. Ob die Paraden wechseln, sieht man sicherer im Spiel, im nächsten Build.

**Zu sagen:** „406.2 passt so“, „Paraden ändern wie Jerry“ oder was anders sein soll. Ohne dein Wort bleibt 406.2 bis nach dem Durchspielen eingefroren; der nächste Build hat denselben Stand wie dieser Film.

Erledigt: Antwort ins Vorgangsarchiv, Datei löschen (Jerry).
