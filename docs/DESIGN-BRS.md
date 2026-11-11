# Bornimer Rollenspielsystem (BRS) – Anleitung und Nachschlagewerk

Name seit 01.11.2026 (451; vorher Arbeitstitel „Spielsystem 2.0“; Datei bis 09.11. `DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`, seitdem `DESIGN-BRS.md`, 650.2 C1). „BRS“ als Kürzel im Text und im Spiel, nie als eigener Schriftzug oder Logo. Gültige Fassung (Vorgang 422, abgenommen vom Chef 01.11.2026; Zahlen erst nach der Rechensimulation 444). Hier steht nur, was gilt, und am Ende, was noch offen ist. Die Entscheidungen des Chefs („E <Nr.>“) stehen in [`DESIGN-BRS-ENTSCHEIDUNGEN.md`](DESIGN-BRS-ENTSCHEIDUNGEN.md), Verlauf und Begründungen in [`alt/DESIGN-SPIELSYSTEM-2-0.md`](alt/DESIGN-SPIELSYSTEM-2-0.md). Alle Zahlen sind Startwerte; sie werden mit einer Simulation in der Godot-Fassung gemessen und angepasst.

## Auf einen Blick

Vier Dinge machen den Helden aus. Mehr muss man nicht wissen, um zu spielen.

| | Was es ist | Wie es wächst |
| --- | --- | --- |
| **Herkunft** | wie deine Geschichte anfängt: eine Herkunft (Wachsoldat, Jägerkind …) oder keine (Wanderer) | gar nicht; einmal bei der Erschaffung gewählt, freiwillig |
| **Fertigkeiten** | was du kannst: 37 Stück, von Einhänder bis Angeln | **durch Tun.** Am Ende jedes Rangs wartet eine **Prüfung**, erst danach geht es weiter |
| **Pfad** | wohin du dich spezialisierst: Wächter, Paladin, Waldläufer … (höchstens einer); dazu beliebig viele Handwerke (Meisterschaften) | ein **Lehrmeister** bietet ihn dir an, sobald du passende Fertigkeiten übst; dann drei Prüfungen bei ihm |
| **Heldenstufe** | wie stark du insgesamt bist | durch **Erfahrung** aus Kämpfen, Quests, Geschichte, bestandenen Prüfungen und Fertigkeitsaufstiegen; jedes Kapitel setzt eine Grenze |

## Alle Stufen auf einen Blick

Jede Stufenleiter des Spiels steht hier mit ihren Stufen, wovon sie abhängt und wo sie genau beschrieben ist; die Einzelheiten stehen im genannten Abschnitt (früher Entwurf B, Chef 31.10., 21:4x: „was ist mit Kräuterkunde? … was ist mit dem Kaputtgehen von Gegenständen?“; nach oben geholt 11.11., Chef 17:53: „wo steht das alles nochmal, was wie definiert ist? Welche Stufen es für was gibt?“). „Vorschlag“ heißt: noch nicht entschieden. Eine Klassenstufe gibt es nicht. Wer eine Stufenleiter einführt oder ändert, trägt sie hier ein.

**Der Held**

| Was | Wofür | Stufen | Wovon es abhängt | Abschnitt |
| --- | --- | --- | --- | --- |
| Heldenstufe | Leben, Größenordnung im Kampf, Zugang zu Gebieten | 1, 2, 3 …; jedes Kapitel setzt eine Grenze (weich, bis zwei darüber) | Erfahrung aus Kampf, Quests, Story und Fertigkeitsaufstiegen | 4 |
| Grundwerte (6) | Begabung: Kraft, Gewandtheit, Zähigkeit, Verstand, Wille, Wahrnehmung | Start 3 bis 8 | wachsen langsam mit den Fertigkeiten | 2 |
| Fertigkeiten (37) | Können im Einzelnen, auch Sammeln wie Kräutersammeln und Handwerk wie Schmieden | Wert 0 bis 100 in vier Rängen: Anfänger, Geselle, Meister, Großmeister; bei 100 fertig | durch Tun bis zur Rangdecke; der nächste Rang braucht eine Prüfung (Entwurf F) | 3 |
| Pfad oder Meisterschaft | Rolle des Helden: ein Pfad (Kampf und Lebensweg, mit Auflagen), dazu beliebig viele Meisterschaften (Handwerk, ohne Auflagen) | Anwärter → Eingeweihter → Titel → hoher Titel | Lehrmeister: Zusage, dann Weihe, Titelprüfung, Hohe Prüfung (Entwurf F, Namen 466) | 5, 6 |

Wie das zusammenhängt: Kräutersammeln ist eine **Fertigkeit** (Sammeln). Sie gehört zu den Kernfertigkeiten der **Meisterschaft** Alchemist, so wie Schild zur **Berufung** Paladin gehört. Meisterschaften laufen genauso wie Berufungen (Lehrmeister, Prüfungen), nur ohne Auflagen und ohne Grenze der Anzahl. Ein eigener „Meisterschaftsrang“ entfällt; es ist die Stufe in der Meisterschaft.

**Die Welt**

| Was | Wofür | Stufen | Wovon es abhängt | Abschnitt |
| --- | --- | --- | --- | --- |
| Ruf je NPC | Preise, Auskünfte, Lehrstunden, Quests | Fremder, Bekannter, Vertrauter, Freund (Vorschlag) | Quests und Taten für diesen NPC; sinkt bei wenigen Anlässen | 9 |
| Monsterstufe und Gebietsband | wie stark Gegner sind | Monster eine Stufe; ein Gebiet etwa Kapitelgrenze − 5 bis + 2 | fest | 7 |
| Schlossstufe | wie schwer eine Truhe aufgeht | eine Stufe je Truhe, passend zum Gebiet | fest; Knacken mit dem Ring, Dietriche in Güteklassen | 8 |

**Die Gegenstände**

| Was | Wofür | Stufen | Wovon es abhängt | Abschnitt |
| --- | --- | --- | --- | --- |
| Gegenstandsstufe | Stärke und Mindeststufe zum Tragen | wie die Heldenstufe | Fund, Händler, Herstellen | 11 |
| Güte | wie gut ein Stück gemacht ist: hebt die Werte der Grundform (Schaden, Schutzwert); wie viel je Stufe, rechnet 444 | vier, von unten: Schlecht, Normal, Gut, Meisterhaft (vier Stufen und „Schlecht“ Chef 11.11., 17:53; Namen beim Chef). Heute nur Ausrüstung; für alle Dinge (Tränke, Speisen, Dietriche) mit Streuung beim Herstellen: Idee, reif mit 976 | Herstellen: Rang der Handwerksfertigkeit, Material, Ring (966); auch ein schlechtes Stück bringt Übung (Chef 17:53). Fund und Händler: gewürfelt. Einzelstücke: fest | 10, 11 |
| Seltenheit | Zusatzeigenschaften, Preis, Zeichen | sechs: gewöhnlich, ungewöhnlich, selten, sehr selten, episch, göttlich; Decke je Kapitel | Fund, Beute, Einzelstück | 11 |
| Zustand (Abnutzung) | wie gut ein Gegenstand noch wirkt | Makellos, Benutzt, Beschädigt, Defekt (wirkt nicht mehr, geht aber nicht verloren) | sinkt beim Gebrauch; Reparatur beim NPC oder selbst | 11 |

Abnutzung und Reparatur: Reparieren ist keine eigene Fertigkeit mehr; Metall repariert die Fertigkeit **Schmieden**, Leder und Stoff das **Schneidern**. Ihr Rang bestimmt, was man reparieren kann (Anfänger: Werkzeug und Einfaches; Geselle: Metallwaffen, mittlere Rüstung, Schilde, Bögen; Meister: schwere Rüstung, Meisterstücke; Großmeister: magische Stücke mit Runenkunde). Für alle gibt es „Alles reparieren“ beim Handwerker.

## 1. Die Grundidee

**Du wirst, was du tust.** Es gibt keine Klasse, die man am Anfang wählt. Wer viel mit dem Bogen schießt, wird ein besserer Schütze. Wer zaubert, wird ein besserer Zauberer. Wer schleicht und Dolche führt, bekommt irgendwann Besuch von einem Lehrmeister, der ihm einen Pfad anbietet.

- **Alles geht, nichts muss.** Kampf, Handwerk, Sammeln: jeder Weg bringt den Helden voran, keiner ist Pflicht.
- **Eigenes Regelwerk.** Das Spiel folgt nicht mehr dem SRD 5.1. Es gibt keinen W20; der Zufall ist nur Würze. Eigene Namen ersetzen alle Begriffe mit D&D-, WotC- oder SRD-Bezug (Abschnitt 12).
- **Grinden darf man, muss man nie.** Wiederkehrende Gegner bringen Beute und Übung, aber kaum noch Stufen.
- **Kapitel 1 bekommt den Kern** dieses Systems, in der Godot-Fassung.

## 2. Der Held

### Die sechs Grundwerte

| Grundwert | Wirkt auf |
| --- | --- |
| Kraft | Nahkampfschaden, Tragkraft, Aufbrechen und Heben |
| Gewandtheit | Tempo, Ausweichen, Fingerfertigkeit, kritische Treffer |
| Zähigkeit | Leben, Rüstung tragen, Widerstand gegen Gift, Krankheit, Kälte |
| Verstand | Wissen, Handwerk, Alchemie, Lerntempo |
| Wille | Mana, Zauberstärke, Konzentration, Furchtresistenz, Überzeugungskraft |
| Wahrnehmung | verstärkt Spähen beim Entdecken von Verstecktem und Fallen (Entscheidung 83), Fernkampf-Treffgenauigkeit, Hinterhalte bemerken, Fährten |

Abgeleitet: **Leben** aus Zähigkeit und Stufe, **Ausdauer** aus Zähigkeit, Wille und Stufe, je Stufe langsamer steigend als das Leben (930 Frage 10, Chef 11.11., 14:45; Zahlen Jerry mit 444), **Mana** aus Wille. Charisma gibt es nicht; die soziale Wirkung kommt aus Ruf und Gesellschaftsfertigkeiten.

### Heldenerschaffung

- Jeder Grundwert beginnt bei **3**; der Spieler verteilt **9 Punkte**, kein Wert über **8** (933 A, 11.11.; gleiche Rechnung wie Entscheidung 77: Start 1, 21 Punkte, 12 für die Untergrenze 3 gebunden), etwa Wille 8, Verstand 6, Zähigkeit 4, sonst 3. Formeln rechnen auch Werte unter 3 (Volk, 933).
- Dazu ein **Volk** mit kleinem Bonus und Malus und einem spürbaren Merkmal (Entscheidung 70, 72):

| Volk | Grundwerte | Merkmal |
| --- | --- | --- |
| Mensch | +1 frei | Wandelbar: eine zusätzliche Startfertigkeit |
| Elf | Gewandtheit +1, Wahrnehmung +1, Zähigkeit −1 | Wachsame Sinne |
| Zwerg | Zähigkeit +1, Verstand +1, Gewandtheit −1 | Steinblut |
| Hügelvolk | Gewandtheit +1, Wille +1, Kraft −1 | Glückskind |
| Orkblütiger | Kraft +1, Zähigkeit +1, Wille −1 | Letzter Atemzug |
| Aschgeborene (ab dem Bau nach dem Meilenstein) | Wille +1, Wahrnehmung +1, Gewandtheit −1 | Aschenerbe (Ashen Legacy; 432.3, Chef 02.11., 22:05): Zauberschaden von Gegnern −25 %; nahe dem Siegel von Aschfurt (Siegelstein, Amulett) ein Zeichen am Bildrand, ohne Probe (432.2) |

  Das Volk darf einen Wert auf 9 heben und auf 2 senken (933 A, ersetzt Entscheidung 78), damit sein Abzug immer greift. Leute in der Welt reagieren auf das Volk (Entscheidung 71).
  **Sechstes Volk: Aschgeborene** (432, Chef 01.11., 09:41; Werte 432.2, 02.11., 16:34): Mensch mit aschgrauer Strähne und goldenem Ring um die Iris; wählbar ab dem Bau nach dem Meilenstein Kapitel 1; vor dem Bau in Simulation 444 mit Völkern messen.
- **Herkunft, freiwillig** (Entscheidung 68, 69): Sie verteilt die Punkte vor, gibt zwei bis drei Startfertigkeiten und passende Ausrüstung; ein Satz bei der Erschaffung sagt, wohin sie lenkt. Die Punkte kann man ändern. Wer keine will, ist **Wanderer** und verteilt selbst; er wählt zwei Startfertigkeiten. Jede Startfertigkeit beginnt bei **10** (Startwert, Vorschlag).

| Herkunft | Startfertigkeiten | führt meist zu |
| --- | --- | --- |
| Wachsoldat | Schild, Mittlere Rüstung, Einhänder | Wächter, Paladin |
| Jägerkind | Bogen, Wurfwaffen, Spähen | Waldläufer, Scharfschütze |
| Zauberlehrling | Evokation, Schutzmagie | Magier, Kriegsmagier |
| Klosterschüler | Heilmagie, Heilkunde, Kräutersammeln | Heiler, Paladin |
| Kräutersammler | Kräutersammeln, Alchemie, Spähen | Meisterschaft Alchemist |
| Schmiedelehrling | Schmieden, Bergbau, Stumpfe Waffen (461c; Bergbau zeigt sich ab Kapitel 2) | Meisterschaft Schmied |
| Herumtreiber | Schleichen, Spähen, Dolche | Assassine, Schatzjäger |
| Wanderer | selbst gewählt | – |

## 3. Fertigkeiten

**Prüfregel:** Eine Fertigkeit gibt es nur, wenn sie eine Tätigkeit im Spiel hat, die sie übt, und eine Wirkung, die man merkt.

**37 Fertigkeiten in acht Gruppen** (nach oben offen: kommt eine neue Tätigkeit ins Spiel, etwa Reiten mit Reittieren, kommt die Fertigkeit dazu):

| Gruppe | Fertigkeiten | Geübt durch |
| --- | --- | --- |
| Waffen (10) | Einhänder, Zweihänder, Stangenwaffen, Stumpfe Waffen, Dolche, Faustkampf, Schild, Bogen, Armbrust, Wurfwaffen | Treffen im Kampf |
| Rüstung (4) | Leichte, Mittlere, Schwere Rüstung, Ausweichen | getroffen werden, ausweichen |
| Schatten (4) | Schleichen, Spähen, Schlösser knacken, Fallen entschärfen | anschleichen, stehen bleiben und umsehen, Truhen, Fallen |
| Magie (5) | Evokation, Schutzmagie, Heilmagie, Illusion, Beschwörung (mit Nekromantie) | zaubern |
| Wildnis (1) | Tiere beruhigen | feindliche Tiere vor dem Kampf beruhigen |
| Gesellschaft (3) | Überreden (mit Täuschen), Einschüchtern, Handeln | Gespräche, Läden |
| Sammeln (4) | Kräutersammeln (857a; bis 10.11. „Kräuterkunde“), Bergbau, Angeln, Jagd (Zerlegen, Fährten) | ernten, angeln, erlegte Tiere zerlegen |
| Handwerk (6; 810) | Schmieden (Metall, Reparieren, Dietriche), Schneidern (Gerben, Nähen, Reparieren; 975a A), Alchemie (mit Giften), Kochen, Runenkunde (Verzaubern), Heilkunde | herstellen, verbinden |

### Wie Fertigkeiten wachsen

- **Durch Tun.** Jede Benutzung gegen ein passendes Ziel bringt Übung. Zu leichte Ziele bringen kaum etwas: weit unter dem eigenen Können höchstens ein Zehntel (966, Chef 11.11., 15:58: „nicht 0,2 … dann 0,1 als Ergebnis … die Belohnung sollte nicht so groß sein“). Nichts übt nebenbei: geübt wird nur, wo der Held selbst etwas leistet (Chef 15:44). Je höher die Fertigkeit, desto mehr Übung braucht der nächste Schritt.
- **Wert und Ränge:** Jede Fertigkeit hat einen Wert von 0 bis 100. Die Ränge sind Abschnitte dieses Werts: Anfänger (0–24), Geselle (25–49), Meister (50–74), Großmeister (75–100). Bei 100 ist die Fertigkeit fertig.
- **Prüfung am Ende jedes Rangs.** Üben hebt den Wert bis zum Ende des Rangs (zum Beispiel 49). Dann bleibt er stehen, bis eine Prüfung bestanden ist; erst dann steigt er weiter. Was man in der Zwischenzeit übt, wird bis zu einem kleinen Puffer gemerkt.
  - **Fertigkeiten deines Pfads** prüft dein Lehrmeister (Abschnitt 5). Eine Prüfung öffnet den nächsten Rang für alle Kernfertigkeiten des Pfads.
  - **Alle anderen Fertigkeiten:** eine **Bewährungsprobe** in der Welt, die im Heldenblatt erscheint (etwa „drei Gegner deiner Stufe nur mit dem Schwert, ohne Heiltrank“, „einen Fisch über 3 kg fangen“). Ohne Pfad oder Meisterschaft endet eine Fertigkeit bei Meister; Großmeister gibt es nur im eigenen Pfad oder in der eigenen Meisterschaft.
- **Kapitel als Takt:** Welche Prüfungen und Proben es gibt, hängt am Kapitel (Tabelle in Abschnitt 5). So ersetzt die Prüfung die bisherige unsichtbare Grenze je Kapitel.
- **Rückmeldung:** Ein kurzer Hinweis im Augenblick des Aufstiegs („Bogen ↑“).
- **Sichtbar wird nur, was man getan hat.** Eine Fertigkeit erscheint im Heldenblatt beim ersten Gebrauch („Neue Fertigkeit: Schleichen“). Das Handbuch beschreibt alle Fertigkeiten und wie man sie entwickelt.

## 4. Heldenstufe und Erfahrung

Die **Heldenstufe** wächst über Erfahrung. Sie bestimmt Leben, die Stärke im Kampf (Abschnitt 7) und den Zugang zu Rezepten und Prüfungen.

| Quelle | Wann |
| --- | --- |
| Fertigkeitsaufstieg | bei jedem Aufstieg des Fertigkeitswerts um einen Schritt (Startwert: je 5 Punkte), nicht für bloßes Üben |
| Prüfung und Bewährungsprobe | beim Bestehen, als Tat; Prüfungen beim Lehrmeister geben viel |
| Kampf | beim Sieg; ab 9 Stufen über dem Gegner gibt es nichts mehr (Entscheidung 73) |
| Nebenquests | beim Abschluss, nach Schwierigkeit und Gebiet |
| Hauptquest | in größeren Blöcken, einmalig |

- **Deckel:** Höchstens **40 Prozent** der Erfahrung für die nächste Stufe dürfen aus Fertigkeitsaufstiegen stammen. Eine Anzeige sagt, wenn der Deckel erreicht ist.
- **Stufengrenze wie in World of Warcraft:** Jedes Kapitel und jedes neue Gebiet hat eine Grenze; ein neues Kapitel hebt sie. Eine feste Höchststufe gibt es nicht (Entscheidung 35). Kapitel 1: Startwert 6 wie im bisherigen Spiel, gemessen wird in der Simulation.
- **Weiche Grenze:** Die Stufe darf die Kapitelgrenze um bis zu **zwei** Stufen überschreiten, bekommt dafür aber nur **ein Viertel** der Erfahrung.
- **Baseline:** Sind alle Quests erledigt und alle Gegner einmal besiegt, hat der Held die Erfahrung des Kapitels ausgeschöpft.
- **Erfahrungstopf je Gebiet:** Zufallsbegegnungen schöpfen aus einem Topf (die Erfahrung aller Gegner des Gebiets einmal). Ist er leer, gibt es nur noch einen kleinen Anteil. Wiedergekehrte Gegner geben kaum Erfahrung, aber weiter Beute.

**Zahlen für die Simulation (Startwerte, Vorschlag; Befund D54.2):**

| Größe | Startwert |
| --- | --- |
| Erfahrung je Gegner | 10 × Stufe² (Stufe 1: 10, Stufe 2: 40, Stufe 6: 360), Boss × 3; dann Faktor aus Modell D |
| Erfahrung bis zur nächsten Heldenstufe | 100 × jetzige Stufe (Kapitel 1 bis Stufe 6: zusammen 1500) |
| Leben des Helden | 10 + 5 × Stufe + 2 × Zähigkeit |
| Grundschaden der Waffe | Faustkampf 2, Dolch und Wurfwaffe 4, Einhänder, Stumpfe Waffe und Bogen 6, Stangenwaffe und Armbrust 8, Zweihänder 10 |
| Grundwert im Schaden | Kraft im Nahkampf, Gewandtheit bei Dolch, Bogen und Wurfwaffe, keiner bei der Armbrust |
| Gewandtheit | Abwehr beim Ausweichen + 2 je Punkt; kritischer Treffer (anderthalbfach) Gewandtheit in Prozent |
| Wahrnehmung | Trefferchance im Fernkampf + 1 Prozentpunkt je Punkt |
| Zauber | Schaden wie Waffe mit Grundschaden des Zaubers, Grundwert Wille, Fertigkeit = Schule; Mana 10 + 5 × Wille |

Die Ätherdichte (Entscheidung 76) ist noch ohne Zahl.

## 5. Der Pfad und der Lehrmeister

**Pfad** ist der Name für das, was bisher Berufung hieß (Entscheidung 79). Jeder Held hat höchstens einen Pfad.

**So läuft es:**
1. Du übst Fertigkeiten. Sobald **zwei Kernfertigkeiten** eines Pfads Geselle erreicht haben (zum Beispiel Schild und Heilmagie), spricht dich ein **Lehrmeister** an: „Willst du Paladin werden?“
2. Sagst du ja, bist du **Anwärter**. Der Lehrmeister begleitet dich, gibt Hinweise und Aufgaben.
3. Drei **Prüfungen** beim Lehrmeister, jede eine Quest mit einer passenden Tat:

| Prüfung | Voraussetzung | Danach bist du | Bekommst | Ab Kapitel (Startwert) |
| --- | --- | --- | --- | --- |
| Weihe | Kernfertigkeiten am Ende von Geselle (49) | Eingeweihter | Rang Meister für die Kernfertigkeiten, erste Fähigkeit | 2 |
| Titelprüfung | Kernfertigkeiten am Ende von Meister (74) | den Titel, z. B. „Paladin“ (in der Regel „Titelträger“) | Rang Großmeister, stärkere Fähigkeit; ab hier gelten die Auflagen | 4 |
| Hohe Prüfung | Kernfertigkeiten bei 100 | den hohen Titel, z. B. „Hoher Paladin“ | stärkste Fähigkeit | 6 |

Namen nach 466 (Chef 02.11.): **Fähigkeit** (Ability) ist, was ein Pfad gibt; Fertigkeiten haben Wert und Rang, Fähigkeiten nie. Pfadstufen: Anwärter, Eingeweihter, Titel, hoher Titel; Anfänger, Geselle, Meister, Großmeister sind nur Ränge der Fertigkeiten. Im Spiel heißen die Prüfungen nach dem Titel („Prüfung zum Paladin“, „Prüfung zum Hohen Paladin“); „Weihe“, „Titelprüfung“, „Hohe Prüfung“ stehen nur in der Regel. Stufen der Meisterschaften (466 A, Chef 02.11., 22:03) wie beim Pfad: Anwärter → Eingeweihter → Titel → „Hoher“ + Titel; Titel Schmied, Schneider, Alchemist, Runenwirker, Feldkoch (EN Aspirant, Initiate, Smith, Tailor, Alchemist, Runewright, Field Cook, „High …“; Schneider statt Lederer nach 975a A, Chef 11.11., 17:04). „Runenmeister“ bleibt Name der Meisterschaft, keine Stufe.

**Kapitel als Takt für alle Fertigkeiten (Startwerte):**

| Kapitel | höchster Rang im Pfad oder in der Meisterschaft | höchster Rang sonst | Bewährungsproben verfügbar | Lehrmeister |
| --- | --- | --- | --- | --- |
| 1 | Geselle (bis 49) | Geselle (bis 49) | zum Gesellen | spricht an, Anwärter möglich |
| 2–3 | Meister (nach der Weihe) | Geselle | zum Gesellen | Weihe |
| 4–5 | Großmeister (nach der Titelprüfung) | Meister | zum Meister | Titelprüfung |
| 6–7 | Großmeister bis 100 | Meister | zum Meister | Hohe Prüfung |

So zeigt Kapitel 1 die ersten Lehrmeister und Anwärter. Der Pfad beginnt in Kapitel 2 mit der Weihe (Eingeweihter, Entscheidung 51); den Titel („Paladin“) bringt die Titelprüfung ab Kapitel 4 (behebt D48.2, D54.1).

**Was ein Pfad bringt:** neue Fähigkeiten im Kampf und in der Welt, jede besser als die vorige (Riposte, Tierbegleiter, Waffenzauber), keine großen Zahlenaufschläge. Die Kraft bleibt in den Fertigkeiten.

**Wechseln** geht beim Lehrmeister; verloren geht nur, was der alte Pfad gegeben hat (447.4, Chef 03.11.): seine Fähigkeiten, und seine Kernfertigkeiten fallen auf den höchsten Rang ohne Pfad im jeweiligen Kapitel zurück (Tabelle oben, „höchster Rang sonst“; z. B. Kapitel 2–3 Geselle, Wert höchstens 49). Was ohne Pfad erübt ist, bleibt. Als Anwärter (Kapitel 1) kostet der Wechsel nichts; die Frage lautet nur „Du gibst den Pfad {weg} auf. Wirklich wechseln?“.

**Magie und Rüstung (Entscheidung 80):** Die Sperre kommt daher, dass Metall die Aufnahme der Magiepartikel aus der Umgebung stört. Sie gilt darum für jeden, der aus der Umgebung schöpft: **Evokation, Illusion, Beschwörung** gehen nur ohne Metall (Stoff oder Leder). **Heil- und Schutzmagie** schöpfen aus dem eigenen Willen und gehen auch in Rüstung. So zaubern Paladin und Heiler ohne Ausnahmeregel; der Kriegsmagier bleibt die eine Ausnahme bei Evokation (leichte Rüstung).

Die sechs Gruppen ordnen die Pfade; sie sind keine eigene Stufe:

| Gruppe | typische Fertigkeiten | Pfad | Kernfertigkeiten (Einladung, Prüfungen) | Fähigkeiten (Beispiele) | Auflagen ab Titelprüfung |
| --- | --- | --- | --- | --- | --- |
| Schutz (Bewahrer) | Schild, Mittlere und Schwere Rüstung, Ausweichen | Wächter | Schild, Schwere Rüstung | Gegner binden, Gefährten decken | langsam, wenig eigener Schaden |
| | | Paladin (Kernfertigkeiten aus Schutz und Heilung) | Schild, Einhänder, Heilmagie | Heilende Hand, Schutzaura | keine Nekromantie; Ruf muss hoch bleiben |
| Kampf (Kämpe) | Einhänder, Zweihänder, Faustkampf, Ausweichen | Berserker | Zweihänder, Stumpfe Waffen | Raserei | kein Schild, keine Zauber |
| | | Duellant | Einhänder, Ausweichen, Leichte Rüstung | Riposte, Doppelschlag | höchstens leichte Rüstung, kein Schild |
| | | Mönch | Faustkampf, Ausweichen | waffenlose Schläge, Betäuben | keine Rüstung, keine Waffen |
| Schatten (Schattengänger) | Schleichen, Spähen, Dolche | Assassine | Schleichen, Dolche, Alchemie (Gifte) | Meucheln, Giftklinge | höchstens leichte Rüstung, kein Schild |
| | | Schatzjäger | Schlösser knacken, Fallen entschärfen, Spähen | schwerste Schlösser, versteckte Kammern | höchstens leichte Rüstung |
| Wildnis (Waldgänger) | Bogen, Armbrust, Jagd, Spähen | Waldläufer | Bogen, Tiere beruhigen, Jagd | Tierbegleiter, Mehrfachschuss | höchstens mittlere Rüstung |
| | | Scharfschütze | Armbrust oder Bogen, Wurfwaffen, Spähen | Zielschuss, Durchschlagen | höchstens mittlere Rüstung |
| Magie (Adept) | eine Schule: Evokation, Schutzmagie, Illusion oder Beschwörung | Magier | zwei Schulen | stärkste Zauber, große Manareserve | keine Rüstung |
| | | Kriegsmagier | Evokation, Einhänder oder Zweihänder, Leichte Rüstung | Waffenzauber | nur leichte Rüstung, Magie gedeckelt |
| | | Beschwörer | Beschwörung, eine zweite Schule (Entscheidung 82) | Diener beschwören, Untote | keine Rüstung; Ruf sinkt bei Nekromantie; keine Heilmagie |
| Heilung (Heilkundiger) | Heilmagie, Heilkunde, Kräutersammeln | Heiler | Heilmagie, Schutzmagie, Heilkunde | Wiederbeleben, Seuchen heilen | höchstens leichte Rüstung |
| | | Paladin (siehe Schutz) | | | |

Alle Kernfertigkeiten stammen aus der Liste der 37 (behebt D48.4). Die Einladung kommt, wenn zwei davon Geselle sind; die Prüfungen verlangen alle am jeweiligen Rangende.

## 6. Meisterschaften

Handwerk läuft neben dem Pfad, genauso mit Lehrmeister und drei Prüfungen, aber ohne Auflagen. Man kann jede Meisterschaft machen, muss aber keine, und darf mehrere haben. Es gibt **fünf** Meisterschaften (Entscheidung 56). **Einladung (Entscheidung 81):** Hauptfertigkeit und Zulieferfertigkeit auf Geselle, wie beim Pfad zwei Fertigkeiten.

| Meisterschaft | Hauptfertigkeit | Zulieferfertigkeit | Stellt her |
| --- | --- | --- | --- |
| Schmied | Schmieden | Bergbau | Waffen, Metallrüstung, Dietriche, Reparatur von Metall |
| Schneider (975a A) | Schneidern | Jagd | Leder, leichte Rüstung, Taschen, Köcher, Roben und Stoffkleidung (Stoff vom Händler; Chef 11.11., 16:31), Reparatur von Leder und Stoff |
| Alchemist | Alchemie | Kräutersammeln | Tränke, Gegengifte, Gifte, Elixiere |
| Runenmeister | Runenkunde | Bergbau | Verzauberungen, Runen auf Ausrüstung |
| Feldkoch | Kochen | Angeln oder Jagd | Mahlzeiten mit kleinem Bonus |

**Heilkunde** steht in der Gruppe Handwerk (Entscheidung 59: Verbände, Wunden versorgen), ist aber keine eigene Meisterschaft; über Meister hinaus steigt sie nur im Pfad Heiler.

## 7. Kampf

- **Die Stufe entscheidet viel.** Der Unterschied der Stufen zwischen Angreifer und Verteidiger bestimmt, wie viel Schaden ankommt. Ein Held der Stufe 50 erledigt ein Monster der Stufe 1 mühelos, und es kann ihm nicht schaden. Fertigkeiten, Waffen und Grundwerte geben den Rest. **Rechenmodell D „Trennung“ gilt (Entscheidung 73):** die Stufe bestimmt die Größenordnung, die Fertigkeit Treffer und Schaden; Zahlen sind Startwerte für die Simulation.
- **Zufall nur als Würze:** kleine Streuung statt W20; ein Glückstreffer (1 von 100) ist nur ein Kratzer („Kratzer reicht“); kritische Treffer und Ausweichen hängen an Gewandtheit und Fertigkeit. Gegen Gegner, die 9 Stufen und mehr unter dem Helden stehen, gibt es keine Erfahrung (Entscheidung 73).
- **Abwehr:** Die Schildfertigkeit und die Rüstungsfertigkeit erhöhen den Schadensabzug: Abzug = Rüstungswert × (1 + Fertigkeit / 100); die Rüstungsfertigkeit senkt nur den Schaden, nicht die Trefferchance (Entscheidung 74). **Parieren:** Für die Trefferchance zählt als Abwehr der beste von Schild, Ausweichen und halber Fertigkeit der Nahkampfwaffe, nur gegen Nahkampf; gegen Pfeile und Zauber gelten nur Schild und Ausweichen. Riposte bleibt Fähigkeit des Duellanten (Entscheidung 75).
- **Schleichen und Hinterhalt:** Mit der Schleichtaste nähert sich der Held. Bleibt er unbemerkt (Schleichen gegen die Wachsamkeit des Gegners, ohne Würfel), greift er als Erster an und bekommt den Vorteil des Hinterhalts. Mehr Gegner sind schwerer zu überlisten. **Bosse** sind wachsamer, ihr Hinterhalt-Bonus ist gedeckelt.
- **Ausschlüsse sind hart.** Metall stört die Aufnahme der Magiepartikel aus der Umgebung (Entscheidung 10, 33). Die Sperre hängt an der Schule, nicht am Pfad (Entscheidung 80): Evokation, Illusion und Beschwörung gehen für jeden nur ohne Metall, also in Stoff oder Leder; Heil- und Schutzmagie auch in Metall. Dazu trägt der Magier ab der Titelprüfung keine Rüstung, der Kriegsmagier nur leichte. In schwerer Rüstung geht Schleichen nicht („Deine Rüstung klirrt“). Zweihänder und Schild schließen sich aus. Jeder Held hat höchstens einen Pfad.
- **Gegner gehören zu Gebieten**, damit niemand zu früh in zu hohe Stufen läuft. Höhere Gebiete sind betretbar; die Karte zeigt ihr Stufenband.
- **Regeln aus dem Umzug (870a 1–6 A, Chef 10.11., 15:08; Plan `LISTE-UMZUG-BRS.md`):** (1) Spielstände aus der SRD-Zeit laden nicht mehr („Aus der alten Regelfassung, nicht mehr spielbar“, Löschen). (2) Gekämpft wird nur im MARS (626); `klassisch.gd` entfällt. (3) **Kampfhandlungen hängen an Fertigkeiten:** für alle Kraft schöpfen (einmal je Kampf, Leben zurück); mit Rang Geselle je Fertigkeit eine Handlung (etwa Einhänder Finte, Dolche Stich aus dem Hinterhalt, Zweihänder Wuchtschlag; Schild und Bogen eine schwächere Vorform, denn Decken und Zielschuss bleiben Fähigkeiten von Wächter und Scharfschütze, Abschnitt 5); Zauber nach Schule (Abschnitt 12); Extra-Angriff, Doppelzug, Zweiwaffenkampf entfallen; Liste und Zahlen Jerry mit 444, Namen Homer. (4) In Kapitel 1 wachsen die Grundwerte nicht. (5) **Proben als Prozent** wie die Trefferchance: Initiative und Flucht nach Gewandtheit, Abwehrprobe mit Zähigkeit (Gift, Krankheit), Wille (Furcht, Zauber), Gewandtheit (Flächen); Zahlen 444. (6) Abschnitt 11.
- **Schwächen und Stärken der Monster (870a 8 A, Chef 10.11., 15:25):** Schadensarten Schnitt, Stich, Wucht, Feuer, Gift, Säure, Licht. Je Monsterart höchstens eine Schwäche (+50 %) und eine Stärke (−50 %), immun nur, wo die Natur es verlangt. Bei zwei bis drei Arten je Kapitel eine **Gegenwirkung**: das falsche Mittel stärkt den Gegner oder kostet etwas (Beute, Erfahrung), nie tödlich und beim ersten Mal sichtbar. Bekannt wird sie im Kampf und steht danach im Bestiarium; mit Verstand ab 6 sieht man sie vorher (870d, Vorentscheid Sokrates 11.11.; eine Fertigkeit Wissen gibt es nicht). Kampftränke und Wurfmittel tragen eine Schadensart (kaufen, erbeuten, mit Alchemie herstellen). Je Art: `LISTE-BESTIARIUM.md`; Zahlen 444.

## 8. Die Welt

- **Spähen durch Verweilen.** Bleibt der Held etwa zwei Sekunden stehen, schaut er sich um: ein Ring zeigt Fallen, Kräuter, Spuren, versteckte Truhen und lauernde Gegner. Je höher Spähen, desto größer der Ring. Im Gehen sieht er einen kleinen Umkreis, im Rennen fast nichts. Spähen steigt nur, wenn wirklich etwas Neues entdeckt wird.
- **Fallen** stehen an Truhen und frei in Höhlen und Verliesen. Erst entdecken (Wahrnehmung, Spähen), dann entschärfen (Fallen entschärfen). Ohne die Fertigkeit löst die Falle aus.
- **Truhen und Schlösser:** Jede Truhe hat eine Schlossstufe, die zum Gebiet passt. Dietriche gibt es zu kaufen und vom Schmied, in Güteklassen; ein besserer Dietrich hilft, ein schlechter kann brechen. Ohne Schlüssel knackt man das Schloss oder bricht es mit Kraft auf (laut, kann zerbrechliche Beute beschädigen). Besondere Truhen öffnen Schlüssel oder Quests. Truhen in Häusern von NPCs bleiben zu; Stehlen gibt es nicht.
  - **Knacken (954a.1, Chef 11.11., 15:26):** Truhen und Türen. Je Zuhaltung ein Ring wie im MARS (leichtes Schloss eine, schweres drei), tippen im richtigen Moment; die Fertigkeit und ein guter Dietrich machen den Ring langsamer und das gute Fenster breiter; daneben verbiegt sich der Dietrich, ein schlechter bricht. Geübt wird nur beim Öffnen, ein schwereres Schloss bringt mehr, ein leichtes wenig, verbrauchte Dietriche nie. Ein Schloss weit über dem Rang zeigt „zu schwer für dich“, eines unter dem Rang öffnet sich ohne Ring. Wenige verschlossene Truhen und Türen, je höchstens etwa 5 Sekunden, aber genug Gelegenheiten, dass die Fertigkeit sich lohnt (Chef: „ohne Gelegenheiten die Fertigkeit anzuwenden, brauche ich auch die Fertigkeit nicht“).
  - **Kochen und Alchemie (966, Chef 11.11., 15:58 „mit Ring“):** wie Knacken. **Kochen:** der Held brät selbst am Lagerfeuer, ein Ring (wenden im richtigen Moment, etwa 3 s); gelungen gibt der Braten mehr Leben, daneben verkohlt das Stück; Übung einmal je Mahlzeit, nicht je Stück, nach Schwierigkeit (Spieß wenig, Wildschwein oder Rezept mit Kraut mehr). **Alchemie:** der Held braut selbst am Kessel, Morwen lehrt je Trank ein Rezept; ein Ring für die Hitze, daneben verdirbt der Sud und die Kräuter sind weg; Übung nur am eigenen Sud nach Schwierigkeit des Rezepts. Unter dem Rang ohne Ring, Übung höchstens ein Zehntel.
- **Tiere beruhigen:** Ein feindliches Tier lässt sich vor dem Kampf beruhigen; gelingt es, dreht es ab, und der Held bekommt Erfahrung wie für einen Sieg. Je höher der Rang, desto stärkere Tiere.
- **Tierbegleiter:** Nur der Waldläufer bekommt mit seinem Pfad ein Tier, das ihn begleitet und auf dem Platz eines Gefährten mitkämpft. Tiere werden weder verkauft noch in den Beutel gepackt.

## 9. Ruf

- **Ruf je NPC.** Wer für jemanden Quests erledigt, steigt in dessen Achtung. Fraktionen gibt es nicht.
- **Wirkungen eines guten Rufs:** günstigere Preise, mehr Auskünfte in Gesprächen, die in Quests weiterhelfen, Sonderwaren. Ob der Ruf beim Lehrmeister etwas bewirkt, ist offen: Lehrstunden gibt es nicht (Entwurf F), Prüfungen folgen dem Kapitel-Takt (D54.5).
- **Profil** (Entscheidung 76): Taten und Chronik zuerst, dann Ätherdichte und Ruf mit Gedächtnis (Entwurf C).
- **Ortsruf** ergibt sich aus dem Ruf der NPCs eines Ortes; wichtige NPCs (etwa Wirt, Schmied, Ortsvorsteher) zählen mehr. Er wirkt auf Wachen und die Stimmung im Ort.
- **Der Ruf sinkt** nur bei wenigen klaren, angekündigten Anlässen, etwa bei einer abgebrochenen Quest oder Verrat, und lässt sich durch Quests wieder aufbauen.
- **Anzeige:** eine Liste „Bekannte Personen“ mit Rufstufe und aktuellen Vorteilen.

## 10. Herstellen und Sammeln

**Drei Wege zum selben Ziel:** kaufen, herstellen oder finden. Wer nicht herstellen will, verkauft, was er sammelt, und kauft, was er braucht.

**Sammeln:**

| Rohstoff | Fundort | Fertigkeit |
| --- | --- | --- |
| Kräuter, Pilze, Blüten | Wiesen, Wald, Höhlen | Kräutersammeln |
| Erz, Steine | Adern, Felswände | Bergbau |
| Fische | Teich, Fluss | Angeln (Fang nach Rang, Angel und Gebiet) |
| Fleisch, Fell, Knochen, Sehnen, Zähne | erlegte Tiere | Jagd (Zerlegen nach dem Sieg; ohne Jagd weniger und schlechtere Teile, nie nichts) |

Ernten ist eine kurze Tätigkeit ohne Minispiel. Fundorte wachsen nach einer Zeit nach. Höhere Gebiete liefern bessere Rohstoffe.

**Die Kette vom Tier zum Gegenstand:** Jagd (zerlegen) → Kochen (Fleisch, Fisch) · Schneidern (Fell zu Leder, leichte Rüstung, Taschen) · Alchemie (Zähne, Giftdrüsen, seltene Fische) · Händler (alles).

**Herstellen:**
- **Werkorte gestaffelt:** einfache Rezepte überall (Lagerfeuer), höhere an Schmiede, Werkbank, Alchemietisch, Gerberei.
- **Feste Rezepte** zuerst; Experimentieren kommt später, nur für Alchemie und Kochen. Rezepte gibt es bei Lehrmeistern und Handwerkern, in Büchern, als Belohnung und beim Händler. **Rezeptbuch** (Chef 11.11., 16:31): eins für alle Handwerke, zeigt die Rezeptliste je Handwerk. **Wege:** wer die Fertigkeit hat, bekommt die einfachen Rezepte beim Lehrmeister ohne Quest (Morwen: Heiltrank, Kräutertrank), wer nicht, kauft sie; starke Rezepte (Großer Heiltrank, Alchemistenfeuer) für alle nur über eine Quest (481: Feuer kippt sonst früh die Kämpfe).
- **Alchemie** wird als erste Rezeptgruppe gebaut, danach Rüstung.
- **Technik:** Jedes Rezept ist ein Datensatz (Zutaten, Fertigkeit und Rang, Werkort, Ergebnis). Tasche, Truhe, Werkort-Ablage und Händlerware sind dasselbe Bauteil. Die Rezeptliste zeigt drei Zustände: herstellbar, eine Zutat fehlt, gesperrt. Das Inventar ist eine Liste wie im alten Spiel, kein Raster; Herstellen ohne Wartebalken.
- **NPC-Handwerker** stellen gegen Gebühr her, wenn man die Zutaten bringt.

**Tragkraft:** Kraft bestimmt, wie viel der Held trägt. Früh im Spiel gibt es den **Nimmersatt-Beutel**, der die Tragkraft stark erhöht. Wer mehr trägt, wird langsamer; aufnehmen kann er trotzdem.

## 11. Ausrüstung: Seltenheit, Abnutzung und Reparatur

**Vier Achsen je Stück** (644 B, Chef 08.11.): Der Gegenstandskatalog beschreibt die Grundform („Langschwert“); was beim Fund gewürfelt oder beim Herstellen bestimmt wird, entsteht nach den Regelwerten (`tools/sim444/werte.json`; heute noch in `beute.gd`, Ablösung 644). Einzelstücke haben feste Werte.

| Achse | Was sie bestimmt | Stufen |
| --- | --- | --- |
| Gegenstandsstufe | Stärke und Mindeststufe zum Tragen | wie die Heldenstufe |
| Güte | wie gut es gemacht ist: hebt die Werte der Grundform (Schaden, Schutzwert) | vier: Schlecht, Normal, Gut, Meisterhaft (Chef 11.11., 17:53; Namen beim Chef) |
| **Seltenheit** | wie viel Besonderes darin steckt: Zahl der Zusatzeigenschaften, Preis, Zeichen | sechs, unten |
| Zustand | wie gut es noch wirkt | Makellos, Benutzt, Beschädigt, Defekt (unten) |

Seltenheit und Güte sind getrennt: ein gewöhnliches Schwert kann meisterhaft geschmiedet sein, ein sehr seltenes nur normal. Die „Verbesserung +1“ der alten Fassung entfällt; sie geht in Güte und Runenkunde auf. Das „+1“ der Einzelstücke (Graks Kriegsaxt, Klinge von Bornim) wird Güte Meisterhaft (870a 6 A, Chef 10.11., 15:08).

**Zusatzeigenschaften** (870a 6 A): nur aus dieser Liste: Grundwert +1, Schutzwert +1 oder +2, Leben +5, Mana +5, kritisch +3 %, Zauberschaden +10 %, Abwehrprobe +5 %; Fertigkeit +1/+2 nur ab episch (644 C1). Namensfarbe je Seltenheit bleibt. Zahlen 444; Abnutzung und Zustand kommen nach dem Umzug als eigener Vorgang.

**Seltenheit:**

| Seltenheit | Zusatzeigenschaften | woran man sie erkennt | in Kapitel 1 |
| --- | --- | --- | --- |
| gewöhnlich | 0 | schlicht | ja |
| ungewöhnlich | 1 | Material und Zeichen (455, 458.3) | als Beute ab Heldenstufe 2 |
| selten | 2 | Material und Zeichen (Wicklung, Messing, blaue Steine) | nur Bosse und besondere Funde |
| sehr selten | 3 | Material und Zeichen | nein |
| episch | 4 | sichtbarer Effekt statt Färbung (458.3, 415) | nur als Einzelstück mit Geschichte |
| göttlich | 5 | sichtbarer Effekt | nein |

- **Zusatzeigenschaften** werden je Platz aus einer erlaubten Liste gewürfelt und sind gedeckelt (Regelwerte); bei Einzelstücken stehen sie fest im Katalog. Sie nennen nur BRS-Werte (Grundwerte, Schutzwert, Mana, Fertigkeiten …), keine Altwerte.
- **„Fertigkeit +1“ oder „+2“** (eine Fertigkeit, solange das Stück getragen wird) gibt es nur ab episch. Der Preis ist die Seltenheit; ein Nachteil am selben Stück darf sein, muss nicht (644 C1, Chef 08.11., 14:32). Flüche nur bei Einzelstücken mit Geschichte (Homer).
- **Mindeststufe je Seltenheit:** episch erst ab einer Gegenstandsstufe, göttlich ab einer höheren (Regelwerte).
- **Seltenheitsdecke je Kapitel** (644 C2): in Kapitel 1 als Beute höchstens ungewöhnlich, Bosse und besondere Funde höchstens selten; spätere Kapitel heben die Decke Schritt für Schritt (heutiger Code, Startwert; Regelwerte).
- **Preis** wächst mit der Seltenheit (Preisformel in den Regelwerten).
- Alle Zahlen dazu (Gewichte, Decken, Mindeststufen, Preisfaktoren) sind Startwerte der alten Fassung und werden in der Simulation 444 gemessen, dann zum Chef; sie stehen nur in den Regelwerten.

**Abnutzung und Reparatur:**

- Ausrüstung hat einen **Zustand**: Makellos (neu gekauft, frisch hergestellt oder voll repariert), Benutzt, Beschädigt, Defekt (Vorschlag Chef 31.10., 21:5x). Mit sinkendem Zustand sinkt die Leistung. Das Spiel warnt rechtzeitig.
- **Defekt statt zerstört:** Ein defekter Gegenstand wirkt nicht mehr, verschwindet aber nicht.
- Gegen viel schwächere Gegner nutzt sich Ausrüstung kaum ab.
- **Drei Wege:** beim NPC-Handwerker reparieren lassen (Gold, mit gutem Ruf günstiger; er kann nur bis zu seiner eigenen Stufe), selbst reparieren (Material, Werkort, Rang), Notreparatur unterwegs mit Reparaturset (nur teilweise).
- **Vier Ränge** bestimmen, was der Held selbst reparieren kann: Anfänger (Werkzeug, einfache Waffen, Leder, Stoff), Geselle (Metallwaffen, mittlere Rüstung, Schilde, Bögen), Meister (schwere Rüstung, Meisterwerke), Großmeister (magische Gegenstände, mit Runenkunde).
- **„Alles reparieren“** mit einem Tippen.

## 12. Namen

| Alt | Neu |
| --- | --- |
| Halbling, Halbork | Hügelvolk, Orkblütiger |
| Vielseitig, Scharfe Sinne, Zwergische Widerstandskraft, Glückspilz, Unerbittlich | Wandelbar, Wachsame Sinne, Steinblut, Glückskind, Letzter Atemzug |
| Feuerball, Brennende Hände, Magisches Geschoss, Magierrüstung, Schild (Zauber), Wunden heilen | Glutkugel, Flammenfächer, Arkanpfeil, Arkanhaut, Bannschild, Wundsegen |
| Zaubertrick, Feuerpfeil, Heilige Flamme, Segnen, Sengender Strahl | Kleinzauber, Funkenpfeil, Gleißstrahl, Beistand, Glutstrahlen (Ember Rays; Homer 870.14) |
| Zweiter Atem, Tatendrang, Kampfstil Verteidigung | Kraft schöpfen, Doppelzug, Wehrhaltung |
| Stirge, Ockergallerte, Grottenschrat (Krogg), Hobgoblin (Grak) | Blutflügler, Ockerschleim, Bärenschrat, Goblin-Hauptmann |
| Rüstungsklasse, Übungsbonus, Rettungswurf, Vorteil/Nachteil | Schutzwert, Fertigkeitsbonus, Abwehrprobe, Gunst/Ungunst |
| Zauberpunkte, Zauberplatz | Mana |
| Kurze Rast, Lange Rast | Kurze Erholung (2 Stunden), Langes Ausruhen (9 Stunden) |
| Klassen Kämpfer, Schurke, Magier, Kleriker | entfallen; dafür Pfade |

Folklore-Wesen (Goblin, Kobold, Skelett, Zombie, Ghul) und Tiere behalten ihre Namen, ebenso Mensch, Elf, Zwerg, Trefferpunkte und kritischer Treffer; der Trefferwürfel entfällt mit dem neuen Kampf. Die Wirkungen der Volksmerkmale und alle Beschreibungstexte werden beim Umbau neu geschrieben (Glossar vom 31.10., E 24, E 27; seit 10.11. nur noch hier, 650.2). Gestrichen sind Barde, Gaukler, Taschendiebstahl, Reiter, Kaufmann und Hauptmann. Der Hinweis „SRD 5.1 · CC BY 4.0“ bleibt stehen, bis alles SRD-Abgeleitete ersetzt ist, auch die Monsterwerte und Zaubertexte.

## 13. Offen

- Monsterwerte Kapitel 1 sind entschieden (427, Chef 02.11.: `LISTE-BESTIARIUM.md` „Werte 2.0“); Krogg und Grimmzahn nachgemessen, Werte wie im Bestiarium gelten endgültig (427.1, Chef 02.11., 20:22; ersetzt „offen nur Krogg und Grimmzahn, nachmessen mit Überfall, Rudel, Umreißen“), mit zwei Bedingungen: Hinweis auf Morwens Rauch spätestens nach der ersten Niederlage gegen Krogg, Krogg erst abnehmen, wenn der Rauch im Spiel zu bekommen ist; offen nur die Herkünfte (481).
- Profil (Entwurf C) ist entschieden (Entscheidung 76); offen bleibt nur die Reihenfolge der Bausteine über Taten und Chronik hinaus.
- Umfang der Prüfungsquests beim Lehrmeister.
- Wie die Grundwerte ab Kapitel 2 wachsen (in Kapitel 1 nicht, 870a 4 A); Haupt- und Nebenwert für Spähen, Tiere beruhigen, Schneidern.
- Rufstufen, Gefährten ohne Klassen, Niederlage, Reparaturverlust, Abnutzungsrate.
- Ruf und Lehrmeister (Abschnitt 9, D54.5).
- Übrige Zahlen (Abschnitt 4: Helden, Übung, Erfahrung): gemessen mit Simulation 444, dann zum Chef.
- Seltenheit (Abschnitt 11): beim Herstellen und beim Händler, ob und wie Rang und Material sie bestimmen; ob die Zusatzeigenschaft Magiefund (höhere Seltenheit beim Fund) bleibt; göttlich heute mit fester Eigenschaft „alle Werte“.

---

*Die Entwürfe A bis F unten stehen nur zum Nachlesen. Entschieden sind A (Modell D, Entscheidung 73), C (76), D (68), F (67); was gilt, steht in den Abschnitten 1 bis 12. Ältere Wörter dort (Werdegang, Späher, Weg, Lehrstunde) gelten nicht mehr.*

## Entwurf A zur Entscheidung: Rechenmodelle für den Kampf

Gemeinsam ist allen: Schaden = (Waffe + Grundwert + Fertigkeit) × Faktor − Rüstung, kleine Streuung. Die Modelle unterscheiden sich darin, woraus der **Faktor** kommt. Die Zahlen sind Beispiele.

| | A: reine Heldenstufe | B: Kampfstufe | C: Fertigkeit gegen Fertigkeit |
| --- | --- | --- | --- |
| Faktor aus | Heldenstufe gegen Gegnerstufe: 1 + Unterschied / 10, nie unter 0 | Kampfstufe gegen Gegnerstufe; Kampfstufe = Heldenstufe ± 1 je 10 Punkte der benutzten Fertigkeit über oder unter dem Kapitelsoll, höchstens ± 5 | benutzte Fertigkeit gegen Abwehrfertigkeit des Gegners: 1 + Unterschied / 20, nie unter 0; die Stufe gibt nur Leben |
| **Held Stufe 5 gegen Wolf Stufe 5**, Fertigkeiten im Soll | beide Faktor 1 | beide Faktor 1 | beide Faktor 1 |
| **Handwerker Stufe 8**, nie gekämpft, Rüstung und Ausweichen 0, Kapitelsoll 30, gegen Wolf Stufe 5 | Wolf trifft mit 0,7; der Handwerker hält viel aus, obwohl er nie gekämpft hat | Abwehr-Kampfstufe 8 − 3 = 5: Wolf trifft mit 1,0 | Wolf (Biss 30) gegen Abwehr 0: Faktor 2,5; der Handwerker ist im Kampf schwach |
| **Held Stufe 50 gegen Monster Stufe 1** | Held 5,9; Monster 0 | wie A, die Fertigkeit verschiebt nur um ± 5 | Held weit über der Abwehr des Monsters, Monster unter der Abwehr des Helden: wie gewünscht, aber nur, wenn die Fertigkeiten mit der Stufe gewachsen sind |

**Welche Werte ein Monster braucht**

| Wertefeld | A | B | C |
| --- | --- | --- | --- |
| Stufe | ja | ja (gilt als Kampfstufe) | ja (nur für Leben und Erfahrung) |
| Leben | ja | ja | ja |
| Rüstung (Abzug vom Schaden) | ja | ja | ja |
| Schaden je Angriff | ja | ja | ja |
| Angriffsfertigkeit (zum Beispiel Biss) | – | – | ja |
| Abwehrfertigkeit (zum Beispiel Ausweichen) | – | – | ja |
| Wachsamkeit gegen Schleichen | ja | ja | ja |

**Rechenbeispiel Wolf** (alle Zahlen Beispiel): Wolf Stufe 5, Leben 30, Rüstung 1, Biss Schaden 6, Angriffsfertigkeit 30, Abwehrfertigkeit 25, Wachsamkeit 40 (scharfe Sinne). Held Stufe 5, Leben 40, Rüstung 3, Schwert: Waffe 8 + Kraft 2 + Fertigkeit 2 = 12, Einhänder 30, Abwehr (Mittlere Rüstung) 30, Kapitelsoll 30.

| | A | B | C |
| --- | --- | --- | --- |
| Held trifft Wolf | 12 × 1 − 1 = 11, Wolf fällt nach 3 Treffern | gleich wie A (Fertigkeit im Soll) | Faktor 1 + (30 − 25) / 20 = 1,25: 12 × 1,25 − 1 = 14, 3 Treffer |
| Wolf beißt Held | 6 × 1 − 3 = 3, Held fällt nach 14 Bissen | gleich wie A | Faktor 1 + (30 − 30) / 20 = 1: 3, 14 Bisse |
| Wolf beißt Handwerker Stufe 8 (Rüstung 0, Abwehr 0) | Faktor 0,7: 6 × 0,7 = 4 | Abwehr-Kampfstufe 5: 6 je Biss | Faktor 1 + (30 − 0) / 20 = 2,5: 15 je Biss |
| Wachsamkeit 40 gegen Schleichen | unbemerkt, wenn Schleichen des Helden über 40 | gleich | gleich |

Zu A bis C: A ist am einfachsten, aber Üben zählt im Kampf kaum, und der Handwerker hält zu viel aus. B löst das mit zwei Stufenbegriffen. C ist am reinsten „du wirst, was du tust“, trennt aber Stufe und Kampfkraft so weit, dass ein hoher Held mit ungeübter Waffe schwach bleibt.

### Modell D: Trennung (Empfehlung Sokrates)

Anforderung des Chefs (31.10., 21:3x): Ein kleiner Held gegen ein starkes Monster muss verlieren, mit vielleicht einem Glückstreffer von 1 zu 100; umgekehrt gibt Stufe 10 gegen Stufe 1 keine Erfahrung.

**Die Idee:** Die **Stufe** bestimmt die Größenordnung (Schaden und Leben). Die **Fertigkeit** bestimmt das Können: wie oft man trifft, wie hart man trifft und welche Fähigkeiten man nutzt. Wer das Schwert tausendmal geführt hat, trifft öfter und härter (Nachfrage Chef 31.10., 21:4x: „wo taucht denn das in deiner Berechnung des Schadens auf?“). D ist der Stufenunterschied: Stufe des Angreifers minus Stufe des Verteidigers.

| Regel | Formel (Startwerte) |
| --- | --- |
| Schaden | (Waffe + Grundwert) × (1 + Fertigkeit / 100) × (1 + D / 10), Stufenfaktor nie unter 0; danach minus Abzug, nie unter 0. Fertigkeit 50 heißt anderthalbfacher Schaden, 100 doppelter |
| Abzug (Abwehr) | Rüstungswert des Gegenstands × (1 + Fertigkeit / 100); Fertigkeit = Schild beim Block mit Schild, sonst die Rüstungsfertigkeit der getragenen Rüstung. Fertigkeit 100 heißt doppelter Abzug (Chef 31.10., 22:2x) |
| Trefferchance | 70 % + (Angriffsfertigkeit − Abwehrwert des Gegners) × 0,5 %, begrenzt auf 5 bis 95 %. Abwehrwert = der beste von: Schild, Ausweichen, halbe Fertigkeit der Nahkampfwaffe in der Hand (Parieren, nur gegen Nahkampf). Rüstung senkt die Trefferchance nicht, nur den Schaden (Chef 31.10., 22:2x) |
| Glückstreffer | 1 von 100 Treffern rechnet mit Stufenfaktor 1; gilt für beide Seiten |
| Erfahrung | Stufe über dem Gegner (D > 0): × (1 − D / 9), null ab D ≥ 9; Stufe unter dem Gegner (D < 0): × (1 − D / 10), höchstens doppelt |

**Monster braucht:** Stufe, Leben, Rüstung, Grundschaden je Angriff, Angriffsfertigkeit (zählt bei Monstern zugleich als Fertigkeit im Schaden), Abwehrfertigkeit, Wachsamkeit gegen Schleichen. Monster haben keine Rüstungsfertigkeit: ihr Abzug ist der bloße Rüstungswert. Die Beispiele unten rechnen vereinfacht mit der vollen Abwehr; gültig ist Entscheidung 75 (halbe Waffenfertigkeit beim Parieren).

**Beispiele** (alle Zahlen Beispiel):

| Fall | Werte | Held trifft | Gegner trifft | Ausgang |
| --- | --- | --- | --- | --- |
| **Held Stufe 1 gegen Monster Stufe 10** | Held: Grundschaden 8, Leben 20, Rüstung 2, Fertigkeit 10. Monster: Grundschaden 10, Leben 120, Rüstung 4, Angriff 50, Abwehr 40. D = −9 | Chance 70 − 15 = 55 %; Schaden 8 × 1,1 × 0,1 = 0,9 − 4 → 0. Glückstreffer: 8,8 − 4 = 5 | Chance 70 + 20 = 90 %; Schaden 10 × 1,5 × 1,9 = 28 − 2 = 26 | Held fällt nach einem Treffer. Der Glückstreffer kratzt, rettet aber nicht. Erfahrung bei einem Sieg wäre × 1,9 |
| **Held Stufe 10 gegen Monster Stufe 1** | Held: Grundschaden 8, Fertigkeit 40. Monster: Grundschaden 5, Leben 12, Rüstung 4, Angriff 10, Abwehr 5. D = +9 | Chance 70 + 17,5 = 87,5 %; Schaden 8 × 1,4 × 1,9 = 21 − 4 = 17, das Monster fällt nach einem Treffer | Schaden 5 × 1,1 × 0,1 = 0,6 − Rüstung → 0. Glückstreffer: 5,5 − 2 = 3 | Held gewinnt mühelos. Erfahrung 0 (Entscheidung 73) |
| **Zwei gleich Starke, Stufe 5** | beide Grundschaden 10, Leben 50, Rüstung 2. Einer Geselle (Fertigkeit 40), einer Anfänger (20). D = 0 | Geselle: Chance 80 %, Schaden 10 × 1,4 − 2 = 12, braucht 5 Treffer | Anfänger: Chance 60 %, Schaden 10 × 1,2 − 2 = 10, braucht 5 Treffer | Der Geselle gewinnt deutlich öfter, weil er öfter und härter trifft. Die genaue Quote misst die Simulation |

**Was das Modell leistet:**
- Ein kleiner Held verliert gegen ein starkes Monster, auch mit Glückstreffer.
- Der große Held gegen ein kleines Monster nimmt fast keinen Schaden und bekommt kaum Erfahrung.
- Bei gleicher Stufe entscheidet das Können: Üben zahlt sich sofort aus.
- Der „kaum zu tötende Handwerker“ entfällt: Er nimmt zwar wenig Schaden je Treffer, wird aber fast immer getroffen und trifft selbst selten.

**Entschieden (Chef 31.10., 22:2x):** Modell D. Der Glückstreffer bleibt ein Kratzer („Kratzer reicht“). Stufe 10 gegen Stufe 1 gibt keine Erfahrung mehr (Null ab D ≥ 9). In den Beispielen oben heißt „Erfahrung × 0,1“ damit 0.

- **Votum Sokrates: D.** Es erfüllt alle drei Anforderungen und hält die Rollen klar: Stufe für die Größe, Fertigkeit für das Können. *Gegenargument:* Die Fertigkeit wirkt jetzt doppelt (Treffer und Schaden). Darum ist ihr Schadensanteil mit 1 % je Punkt bewusst mäßig; die Simulation zeigt, ob er passt.
- **Stärkstes Gegenargument:** zwei Formeln statt einer (Schaden und Trefferchance), und alle Werte sind Startwerte ohne Messung. Ohne Simulation kann der Kampf zu lang oder zu kurz werden.

## Entwurf C zur Entscheidung: das eigene Profil

- **Taten:** benannte Leistungen, die die Welt bemerkt. Sie bringen etwas Erfahrung, Ruf und sind Voraussetzung für Prüfungen. Beispiele: „Den Wolfsbau ohne Fackel geräumt“; „Grak ohne Heiltrank besiegt“.
- **Die Chronik schreibt mit:** Prüfungen, Pfade und Taten werden Einträge in unserem Tusche-Stil. Beispiele: „Am dritten Tag bot ihm der alte Jäger den Pfad des Waldläufers an.“; „Morwen nannte ihn zum ersten Mal Freund.“
- **Ätherdichte:** Jeder Ort hat eine Magiestärke; Mana erholt sich und Zauber wirken danach. Beispiele: Im Wald und in Ruinen wirkt die Glutkugel stärker; in der Schmiede und in der Stadt erholt sich Mana langsamer. Start: eine Zahl je Gebiet und Kampfort.
- **Ruf mit Gedächtnis:** NPCs sprechen den Helden auf seine Taten an. Beispiele: „Du bist der, der die Wölfe vom Hof vertrieben hat.“; der Wirt gibt nach der Tat „Ratten im Keller“ einen Hinweis, den er Fremden nicht gibt. Texte über Homer.
- **Votum:** Taten und Chronik zuerst; Ätherdichte und Ruf mit Gedächtnis danach.

## Entwurf D zur Entscheidung: Werdegänge für Kampf und Schatten

- **Späher** für den Weg Schatten: Gewandtheit und Wahrnehmung betont; Startfertigkeiten Schleichen, Spähen, Dolche; Ausrüstung Dolch, Lederrüstung, Dietriche.
- **Kampf** bleibt ohne eigenen Werdegang, weil der Schildträger den Nahkampf abdeckt und der Haudegen gestrichen ist; über den freien Werdegang erreichbar.
- **Votum:** Späher ja; Kampf ohne eigenen Werdegang.

**Neu (Chef 31.10., 21:4x, Verwechslung Werdegang „Heiler“ und Berufung „Heiler“): Werdegänge heißen nach der Herkunft, nicht nach der Rolle.** Der Werdegang ist nur, was der Held **vor** dem Spiel war (vorverteilte Punkte, zwei bis drei Startfertigkeiten, Ausrüstung). Die Berufung ist, was er **im** Spiel wird. Mit Herkunftsnamen kann beides nie gleich heißen:

| bisher | neu (Vorschlag) | Startfertigkeiten | führt meist zu |
| --- | --- | --- | --- |
| Schildträger | Wachsoldat | Schild, Mittlere Rüstung, Einhänder | Wächter, Paladin |
| Schütze | Jägerkind | Bogen, Wurfwaffen, Spähen | Waldläufer, Scharfschütze |
| Zauberer | Zauberlehrling | Evokation, Schutzmagie | Magier, Kriegsmagier |
| Heiler | Klosterschüler | Heilmagie, Heilkunde, Kräutersammeln | Heiler, Paladin |
| Kräuterkundiger | Kräutersammler | Kräutersammeln, Alchemie, Spähen | Meisterschaft Alchemist |
| Schmiedegeselle | Schmiedelehrling | Schmieden, Bergbau, Stumpfe Waffen (461c; Bergbau zeigt sich ab Kapitel 2) | Meisterschaft Schmied |
| Späher (neu) | Herumtreiber | Schleichen, Spähen, Dolche | Assassine, Schatzjäger |
| Frei | Wanderer (keine Herkunft; du verteilst die 18 Punkte selbst und wählst Startfertigkeiten frei) | selbst gewählt | – |

## Entwurf E zur Entscheidung: neuer Wortlaut für Leitbild und `CLAUDE.md`

Nur Vorschlag; geändert wird erst nach deinem Ja.

**`DESIGN-LEITBILD.md`, Punkt 4 (ersetzt „Das SRD ist das Gerüst, nicht das Ziel …“):**

> 4. **Eigenes Regelwerk: du wirst, was du tust.** Wir spielen nach unserem eigenen Spielsystem 2.0 (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`), nicht mehr nach dem SRD. Keine Klasse zu Beginn: Fertigkeiten wachsen durch Benutzung; wer passende Fertigkeiten übt, den lädt ein Lehrmeister zu einem Pfad ein, und dort besteht er Prüfungen. Keine feste Höchststufe; jedes Kapitel hebt die Stufengrenze. Zufall ist Würze, kein W20. Zahlen werden gemessen, nicht geraten.

**`CLAUDE.md`, erster Absatz (ersetzt „Regeln nach SRD 5.1“):**

> … Regeln nach unserem eigenen Spielsystem 2.0 (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`); der Hinweis „SRD 5.1 · CC BY 4.0“ bleibt, bis alles SRD-Abgeleitete ersetzt ist.

## Entwurf F zur Entscheidung: Fertigkeiten, Prüfungen und Berufung aus einem Guss

*Verlauf. Namen überholt durch 466 (Chef 02.11.): Weihe, Titelprüfung, Hohe Prüfung statt Zwischen-, Gesellen-, Meisterprüfung; Pfadstufen Anwärter, Eingeweihter, Titel, hoher Titel; „Fähigkeit“ statt „Handlung“. Gültig ist Abschnitt 5 „Der Pfad und der Lehrmeister“.*

Anlass (Chef 31.10., 21:4x): „Anfänger, Geselle, Meister, Großmeister … aber weiter soll es dann auch nicht gehen … dann ist aber eine Fertigkeit einfach fertig. Und für jeden Aufstieg im Fertigkeitsrang wäre … eine Quest erforderlich oder eine Art Prüfung beim Lehrmeister … allein um den Weg zu beschreiten, … muss ich doch erstmal einen Lehrmeister haben. Der sagt, hey, willst du Paladin werden? … wenn ich jetzt schon ganz viele Fertigkeiten gemacht habe …, dann bin ich ja vielleicht sozusagen schon Meister, ohne was gemacht zu haben.“

**Das Problem:** Bisher gab es zwei Leitern nebeneinander: Fertigkeiten steigen durch Tun, und Weg, Berufung, Meisterform sitzen obendrauf. Wer viel geübt hat, hätte beim ersten Lehrmeister alles auf einmal bekommen. Und „Weg“ als eigene Stufe ist schwer zu verstehen.

**Vorschlag: eine Leiter, eine Tür.** Üben füllt, die Prüfung öffnet.

1. **Fertigkeiten enden bei 100.** Vier Ränge: Anfänger (0–24), Geselle (25–49), Meister (50–74), Großmeister (75–100). Danach ist die Fertigkeit fertig. Das ersetzt „nach oben offen“.
2. **Üben füllt nur bis zur Rangdecke.** Durch Tun steigt der Wert bis zum Ende des Rangs (zum Beispiel 49). Weiter geht es erst nach einer **Prüfung**. Was man darüber hinaus übt, wird bis zu einem kleinen Puffer gemerkt (wie schon entschieden: „hart mit Puffer“). So kann keiner „schon Meister sein, ohne was gemacht zu haben“: Ohne Prüfung bleibt jeder am Ende seines Rangs stehen.
3. **Wo die Prüfung stattfindet:**
   - **Fertigkeiten der eigenen Berufung** prüft der eigene Lehrmeister, gebündelt in drei Prüfungen (unten). Eine Prüfung öffnet den nächsten Rang für alle Kernfertigkeiten der Berufung zugleich.
   - **Alle anderen Fertigkeiten: Bewährungsprobe statt Lehrstunde** (Chef 21:4x: „Lehrstunde … kann ich mir aufstecken … nicht so, dass man sich das verdient hätte … einfaches Rumlaufen“). An der Rangdecke erscheint im Heldenblatt eine Probe, die man in der Welt mit genau dieser Fertigkeit besteht, ohne irgendwohin zu laufen. Beispiele: Einhänder zum Gesellen: „drei Gegner deiner Stufe nur mit dem Schwert besiegen, ohne Heiltrank“; Schlösser knacken zum Meister: „ein Schloss der Stufe 3 öffnen“; Kräutersammeln: „eine seltene Pflanze finden“; Angeln: „einen Fisch über 3 kg fangen“. Die Proben entstehen aus wenigen Vorlagen je Fertigkeitsgruppe (acht Gruppen, drei Ränge), nicht als hundert einzelne Quests; Texte von Homer, die Chronik vermerkt jede bestandene Probe.
   - **Großmeister nur in der eigenen Berufung oder Meisterschaft.** Fertigkeiten außerhalb kommen höchstens bis Meister. Das hält Spezialisten wertvoll und bremst den Alleskönner ohne weitere Regel.
4. **Die Berufung beginnt beim Lehrmeister.** Statt eines „Wegs“ als eigener Stufe gibt es die **Neigung**: Das Spiel merkt, was du tust (zum Beispiel Schild und Heilmagie auf Geselle). Dann spricht dich ein Lehrmeister an: „Willst du Paladin werden?“ Du sagst ja, nein oder später. Mit Ja bist du **Anwärter**.
5. **Drei Prüfungen der Berufung**, jede eine Quest beim Lehrmeister, mit einer passenden Tat:

| Stufe in der Berufung | Prüfung | Voraussetzung | Öffnet | Bekommt |
| --- | --- | --- | --- | --- |
| Anwärter | Zusage beim Lehrmeister | Neigung: zwei Kernfertigkeiten auf Geselle | – | Lehrmeister begleitet dich, erste Hinweise |
| Eingeweihter | Zwischenprüfung | Kernfertigkeiten am Ende von Geselle | Rang Meister für die Kernfertigkeiten | erste Handlung der Berufung |
| Titelträger, z. B. „Paladin“ | Gesellenprüfung | Kernfertigkeiten am Ende von Meister | Rang Großmeister | zweite, stärkere Handlung; Auflagen gelten ab hier |
| Meister, z. B. „Hoher Paladin“ | Meisterprüfung | Kernfertigkeiten bei 100 | – (Fertigkeiten fertig) | stärkste Handlung |

6. **Kapitel als Takt:** Welche Prüfungen ein Lehrmeister abnimmt, hängt am Kapitel (Zwischenprüfung ab Kapitel 2, Gesellenprüfung später, Meisterprüfung spät). Das ist die bisherige Fertigkeitsgrenze je Kapitel, nur als Tür beim Lehrmeister statt als unsichtbare Decke.
7. **Wer schon viel geübt hat,** steht bei allen Kernfertigkeiten an der Rangdecke und kann die Prüfungen zügig nacheinander ablegen, aber er muss sie ablegen. Die Prüfung ist das Tun.

**Was sich gegenüber den Entscheidungen ändert:** „Weg“ als eigene Ebene entfällt und wird zur Neigung, die den Lehrmeister einlädt (bisher Weg → Berufung → Meisterform). Die sechs Gruppen (Schutz, Kampf, Schatten, Wildnis, Magie, Heilung) bleiben als Ordnung der Berufungen. Fertigkeitsränge enden bei 100 statt „nach oben offen“.

*Stärkstes Gegenargument:* Prüfungen an jeder Rangdecke können sich wie Wände anfühlen, wenn man gerade gut im Üben ist. Gegenmittel: Der Puffer merkt das Weiterüben, das Spiel zeigt die nahe Prüfung früh an („Dein Lehrmeister erwartet dich“), und Lehrstunden außerhalb der Berufung sind kurz.

**Entschieden** (Chef 31.10., 21:5x: „F ja, Werdegänge nach Herkunft auch ja“), mit Bewährungsprobe und Großmeister nur in eigener Berufung. Die Abschnitte 2, 3 und 5 oben werden beim nächsten Durchgang darauf umgeschrieben.
