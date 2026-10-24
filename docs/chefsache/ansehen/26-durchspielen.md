# 26 · Durchspielen Kapitel 1: Checkliste · Sokrates · 23.10., 16:17
E Spiel

Dein eigener Bogen als Chef. Die 12 Tester bekommen den Prüfbogen (`tools/pruefbogen/pruefbogen.pdf`, 186, 250); den musst du nicht zusätzlich ausfüllen.

Wofür: Du spielst einmal ganz durch (26) und hältst nebenbei nur fest, was wir sonst nachfragen würden (Ausgleich 38; der Schwierigkeitsgrad 39 ist noch nicht gebaut, es gibt also nichts zu wählen). Je Station **ein Kreuz und höchstens ein Satz**, gern als Sprachnachricht. Alles, was hier nicht steht, musst du nicht beobachten.

**Vorher (einmal):** Build-Nummer · Klasse · neues Spiel ja/nein. Gekämpft wird klassisch; MARS ist im Spiel noch nicht wählbar, nur als Probekampf im Systemmenü (212).

**Je Station:** S = zu schwer, P = passt, L = zu leicht · bei Kämpfen: Anzahl Versuche, Heiltränke verbraucht · F = Fehler (ein Wort, Bildschirmfoto genügt) · Uhrzeit, wenn du die Station erreichst.

| # | Station | Worauf achten | S/P/L | Versuche, Tränke | F | Uhr |
|---|---|---|---|---|---|---|
| 0 | Intro, Charaktererstellung | Erster Eindruck: wirkt es fertig? Figur beim Drehen | | – | | |
| 1 | Erwachen im Gasthaus | Weißt du, was zu tun ist? | | – | | |
| 2 | Auftrag des Ältesten | Ist das Ziel klar? | | – | | |
| 3 | Schlagbaum (Jorin) | Weg frei? Jorin verständlich? | | – | | |
| – | Flüsterwald (Kämpfe im hohen Gras) | Kämpfe fair? Zu oft, zu selten? | | | | |
| 4 | Garrick am Lagerfeuer (freiwillig) | Warnung verständlich? | | – | | |
| 5 | Blutzahnhöhle, Krogg | Kampf fair? Gefahr vorher lesbar? | | | | |
| 6 | Graks Halle | Bosskampf | | | | |
| 7 | Lyras Befreiung | Gespräch verständlich? | | – | | |
| 8 | Rückkehr zu Aldric, Tempel, Ende | Gefühl am Ende | | – | | |
| – | Morwen, Grimmzahn (freiwillig) | Kampf mit Grimmzahn | | | | |
| – | Nebenquests vom Anschlagbrett | welche gemacht, lohnend? | | | | |

**Am Ende (drei Fragen):**
1. Die Uhrzeiten oben reichen; die genaue Spielzeit lesen wir aus dem Spielstand (`playedMs`).
2. Musstest du an einer Stelle grinden (Stufen sammeln), um weiterzukommen? Wo?
3. Die drei Dinge, die am meisten gestört haben, und das eine, das am besten war.

**Nicht nötig:** Schadenszahlen, Würfe, genaue Lebenspunkte. Die ermitteln wir mit dem Zufallsspieler (`PlayerSimTest`, 38), nicht über dich.

Nach dem Spielen die Tabelle ausgefüllt zurück, als Bild, Text oder Sprachnachricht. Daraus macht Perikles die Vorgänge.

## Ergebnis Chef (Durchspielen 23.10., diktiert 24.10. an Sokrates)

**Vorher:** Build 0.1.1008 · Kämpfer · neues Spiel · Beginn 19:31.

| # | Station | Urteil | Versuche, Tränke | F | Chef (24.10.) |
|---|---|---|---|---|---|
| 0 | Intro, Charaktererstellung | P (intuitiv) | – | Figur beim Drehen | „ja, war okay“; Puppe sieht beim Drehen „nicht sonderlich fein“ aus; Name, Farben, Punkte verteilen „alles intuitiv“; Intro „sehr schön“, Erstellung kurz |
| 1 | Erwachen im Gasthaus (19:33) | klar | – | – | umgesehen, mit allen geredet, Hinweis „zum Ältesten“ verstanden |
| 2 | Auftrag des Ältesten (19:34) | klar | – | – | Auftrag klar; erst das Dorf erkundet (verschlossene und offene Türen, Händlerladen), mit allen geredet, „soweit schön“; bei manchen Bewohnern: „was machen die da eigentlich?“ (= Idee „Dorfbewohner mit Tätigkeit“, `LISTE-IDEEN.md`) |
| – | Händler | nervig | – | Mengen | Kaufen nur ×1/×5, Verkaufen ×1/×5/Alle; Menge frei einstellen fehlt (−1/+1) → **349** (Jerry) |
| 3 | Schlagbaum (Jorin, vor 19:38) | klar | – | – | unterhalten, Schlagbaum geht hoch, in den Wald |
| 4 | Garrick am Lagerfeuer (19:38) | klar | – | – | direkt den Weg entlang zu Garrick (Wache riet: auf dem Weg bleiben), unterhalten; Hinweis „kleiner Bube, erst stärker werden“ klar |
| – | Flüsterwald (Kämpfe) | S auf Stufe 1, dann L | nie gestorben; Rast bei Garrick, öfter zweimal kurze Rast | – | Wildschweine, Ratten, Goblins, Wölfe; „mit Stufe 1 … echt happig“; alle Kisten angesehen, will erkunden; bewusst hochgelevelt (erfahrener AD&D-Spieler); Stufe 3 um 19:49, „dann war das alles gar kein Problem“; **ab Stufe 3 keine Wahl mehr:** „einfach die Angriffstaste beim Kämpfer gespammt … allerhöchstens mal ab und zu einen Tatendrang, aber der ging ja dann auch bloß einmal“ (gegen Leitbild „Kampf nie langweilig, echte Wahl“; klassischer Kampf, MARS nicht wählbar) |
| – | Tiefer Wald (um 20:01) | P; Riesenspinne S | 2 Tränke auf der Karte; einmal geflohen (Spinne, Stufe 3) | – | Goblins, Skelette; „Riesenspinne war aber echt eine harte Nuss“; bei Morwen gekauft und verkauft |
| – | Morwen, Grimmzahn | L | – | – | Gespräch „alles soweit gut“; Grimmzahn „easy“, Angriffstaste gespammt, ein Tatendrang |
| – | Nebenquests vom Anschlagbrett | | | | alle, die gingen, schon beim Aufbruch mitgenommen; Ring abgegeben; „fünf Wolfs…“ und eine weitere nicht voll bekommen, „da ich jetzt durch war mit der Aufgabe, war mir das relativ egal“ (Lohn zu klein oder Ziel zu weit?) |
| 5 | Blutzahnhöhle, Krogg (20:12) | L | – | – | „echt dunkel, das war cool“; vorsichtig geschlichen, Kisten; Fledermäuse, Skelette „alles easy“; Krogg „auch easy“ |
| 6 | Graks Halle (20:18) | L | 1 Versuch; etwa 5 Tränke in der ganzen Höhle (nach Kämpfen aufgefüllt, Boss mit vollen LP) | – | Stufe 4, zwei Waffen statt Schild, gute Funde; Grak „einfach zerlegt“, ein Tatendrang oder nur Angriffe; „der leichteste [Bosskampf], den ich jemals gehabt hatte“; in der Höhle Rast nicht möglich, nach Kämpfen nur Lebenspunkte aufgefrischt; „mit zwei Waffen, mit dem Kämpfer das macht schon echt Schaden“ (Befund Sokrates: Nebenhand schlägt bei jedem Angriff von selbst mit, `Battle.attackAction`; Schaden regelgerecht ohne positiven Modifikator, aber keine Wahl); „der Boss hat mir auch keinen Schaden gemacht. Der war dann einfach tot.“ |
| 7 | Lyras Befreiung | klar | – | – | nur ansprechen, „die ist ja dann verschwunden“; kein eigenes Erlebnis |
| 8 | Rückkehr zu Aldric, Ende (20:31) | P | – | – | Abspann „grundsätzlich gut gefallen“; zwischendurch einmal aus dem Tiefen Wald zurück in den Laden, dort bessere Waffe gekauft |

**Spielzeit:** 48 Minuten laut Spielstand (19:31–20:31 auf der Uhr). Grundsätzliche Hinweise zum Spiel folgen (Chef 17:13).

**Einschränkung (Chef 17:14):** kennt Wege und Karten, Kämpfer ist leichter als Magier: „bin ich jetzt nicht der Maßstab“. Sokrates: gilt für Spielzeit und Wege; nicht für Bosse ohne Schaden auf Stufe 4 und Kampf ohne Wahl ab Stufe 3; Gegenprobe mit Magier oder Zufallsspieler (`PlayerSimTest`, 38).

**Zum Bogen selbst:** S/P/L passt bei Stationen ohne Kampf nicht (Chef zu Station 0); dort besser „klar / unklar“. Handelssystem fehlt im Bogen (Chef zu Station 2; kommt nach).
