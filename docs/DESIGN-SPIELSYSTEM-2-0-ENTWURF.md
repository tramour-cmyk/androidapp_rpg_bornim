# Spielsystem 2.0 – Anleitung und Nachschlagewerk

Entwurf (Vorgang 422, Sokrates, 31.10.2026). Hier steht nur, was gilt, und am Ende, was noch offen ist. Verlauf und Begründungen stehen in [`DESIGN-SPIELSYSTEM-2-0.md`](DESIGN-SPIELSYSTEM-2-0.md). Alle Zahlen sind Startwerte; sie werden mit einer Simulation in der Godot-Fassung gemessen und angepasst.

## 1. Die Grundidee

**Du wirst, was du tust.** Es gibt keine Klasse, die man am Anfang wählt. Wer viel mit dem Bogen schießt, wird ein besserer Schütze. Wer zaubert, wird ein besserer Zauberer. Wer schleicht und Dolche führt, steht irgendwann auf dem Weg des Schattens.

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
| Wahrnehmung | Verstecktes und Fallen entdecken, Fernkampf-Treffgenauigkeit, Hinterhalte bemerken, Fährten |

Abgeleitet: **Leben** aus Zähigkeit und Stufe, **Ausdauer** aus Zähigkeit und Wille, **Mana** aus Wille. Charisma gibt es nicht; die soziale Wirkung kommt aus Ruf und Gesellschaftsfertigkeiten.

### Heldenerschaffung

- Jeder Grundwert beginnt bei **1**. Der Spieler verteilt **18 Punkte**. Danach liegt jeder Wert zwischen **3 und 8** (Startwerte, versuchsweise).
- Dazu ein **Volk** (Mensch, Elf, Zwerg, Hügelvolk, Orkblütiger) mit kleinem Bonus und einem Volksmerkmal.
- **Werdegang als Starthilfe:** Wer schon weiß, wohin er will, wählt einen Werdegang. Er verteilt die Punkte vor, gibt zwei bis drei Startfertigkeiten und passende Ausrüstung. Er bindet nicht: der Spieler kann die Punkte ändern, und der Held wächst danach mit dem, was er tut.

Die Startfertigkeiten sind auf die neue Liste der 37 Fertigkeiten umgeschrieben; das ist **Vorschlag, noch nicht entschieden**. Ebenso die Umrechnung der Punkte auf 18.

| Werdegang | Richtung | Startfertigkeiten | führt zum Weg |
| --- | --- | --- | --- |
| Schildträger | Schutz | Schild, Mittlere Rüstung, Einhänder | Schutz |
| Schütze | Fernkampf | Bogen, Wurfwaffen, Spähen | Wildnis |
| Zauberer | Magie | Evokation, Schutzmagie | Magie |
| Heiler | Heilung | Heilmagie, Heilkunde, Kräuterkunde | Heilung |
| Kräuterkundiger | Sammeln, Alchemie | Kräuterkunde, Alchemie, Spähen | Meisterschaft Alchemist |
| Schmiedegeselle | Schmieden, Reparatur | Schmieden, Bergbau | Meisterschaft Schmied |
| Frei | selbst gewählt | selbst gewählt | – |

Die Punktverteilung je Werdegang wird auf das Verteilen von 18 Punkten umgerechnet.

## 3. Fertigkeiten

**Prüfregel:** Eine Fertigkeit gibt es nur, wenn sie eine Handlung im Spiel hat, die sie übt, und eine Wirkung, die man merkt.

**37 Fertigkeiten in acht Gruppen** (nach oben offen: kommt eine neue Handlung ins Spiel, etwa Reiten mit Reittieren, kommt die Fertigkeit dazu):

| Gruppe | Fertigkeiten | Geübt durch |
| --- | --- | --- |
| Waffen (10) | Einhänder, Zweihänder, Stangenwaffen, Stumpfe Waffen, Dolche, Faustkampf, Schild, Bogen, Armbrust, Wurfwaffen | Treffen im Kampf |
| Rüstung (4) | Leichte, Mittlere, Schwere Rüstung, Ausweichen | getroffen werden, ausweichen |
| Schatten (4) | Schleichen, Spähen, Schlösser knacken, Fallen entschärfen | anschleichen, stehen bleiben und umsehen, Truhen, Fallen |
| Magie (5) | Evokation, Schutzmagie, Heilmagie, Illusion, Beschwörung (mit Nekromantie) | zaubern |
| Wildnis (1) | Tiere beruhigen | feindliche Tiere vor dem Kampf beruhigen |
| Gesellschaft (3) | Überreden (mit Täuschen), Einschüchtern, Handeln | Gespräche, Läden |
| Sammeln (4) | Kräuterkunde, Bergbau, Angeln, Jagd (Zerlegen, Fährten) | ernten, angeln, erlegte Tiere zerlegen |
| Meisterschaften (6) | Schmieden (Metall, Reparieren, Dietriche), Lederarbeit (Gerben, Schneidern), Alchemie (mit Giften), Kochen, Runenkunde (Verzaubern), Heilkunde | herstellen, verbinden |

### Wie Fertigkeiten wachsen

- **Durch Tun.** Jede Benutzung gegen ein passendes Ziel bringt Übung. Zu leichte Ziele bringen kaum etwas. Je höher die Fertigkeit, desto mehr Übung braucht der nächste Schritt.
- **Ränge:** Anfänger (bis 25), Geselle (bis 50), Meister (bis 75), Großmeister (bis 100), danach weitere Ränge, die mit neuen Kapiteln kommen.
- **Grenze je Kapitel.** Jede Fertigkeit kann im Kapitel nur bis zu einem Wert steigen; die Grenze wächst mit der Stufengrenze des Kapitels. Weiter geht es mit einem Lehrer oder einer Quest im nächsten Kapitel. Am Limit wird Übung bis zu einem Rangschritt gespeichert und nach der Freischaltung angerechnet.
- **Rückmeldung:** Ein kurzer Hinweis im Augenblick des Aufstiegs („Bogen ↑“).
- **Sichtbar wird nur, was man getan hat.** Eine Fertigkeit erscheint im Heldenblatt beim ersten Gebrauch („Neue Fertigkeit: Schleichen“). Das Handbuch beschreibt alle Fertigkeiten und wie man sie entwickelt.

## 4. Heldenstufe und Erfahrung

Die **Heldenstufe** wächst über Erfahrung. Sie bestimmt Leben, die Stärke im Kampf (Abschnitt 7) und den Zugang zu Rezepten und Prüfungen.

| Quelle | Wann |
| --- | --- |
| Fertigkeitsaufstieg | einmal bei jedem Aufstieg, nicht für bloßes Üben |
| Kampf | beim Sieg; Gegner weit unter der eigenen Stufe (etwa 10 Stufen) geben nichts |
| Nebenquests | beim Abschluss, nach Schwierigkeit und Gebiet |
| Hauptquest | in größeren Blöcken, einmalig |

- **Deckel:** Höchstens **40 Prozent** der Erfahrung für die nächste Stufe dürfen aus Fertigkeitsaufstiegen stammen. Eine Anzeige sagt, wenn der Deckel erreicht ist.
- **Stufengrenze wie in World of Warcraft:** Jedes Kapitel und jedes neue Gebiet hat eine Grenze; ein neues Kapitel hebt sie. Eine feste Höchststufe gibt es nicht.
- **Weiche Grenze:** Die Stufe darf die Kapitelgrenze um bis zu **zwei** Stufen überschreiten, bekommt dafür aber nur **ein Viertel** der Erfahrung.
- **Baseline:** Sind alle Quests erledigt und alle Gegner einmal besiegt, hat der Held die Erfahrung des Kapitels ausgeschöpft.
- **Erfahrungstopf je Gebiet:** Zufallsbegegnungen schöpfen aus einem Topf (die Erfahrung aller Gegner des Gebiets einmal). Ist er leer, gibt es nur noch einen kleinen Anteil. Wiedergekehrte Gegner geben kaum Erfahrung, aber weiter Beute.

## 5. Wege, Berufungen, Meisterformen

Der Held beginnt als **Wanderer**. Was er tut, führt ihn auf Wege; dort wählt er einmal bewusst seine Berufung.

| Ebene | Wie man sie erreicht | Auflagen |
| --- | --- | --- |
| **Weg** | von selbst: zwei Kernfertigkeiten des Wegs auf Geselle; ein kleiner Perk, ein Eintrag in der Chronik | keine; mehrere Wege zugleich möglich |
| **Berufung** | beim Lehrmeister: Fertigkeiten der Berufung auf Meister, Prüfungsquest, Ruf beim Lehrmeister | ja; genau eine Berufung |
| **Meisterform** | in späteren Kapiteln beim Lehrmeister (etwa Wächter → Bollwerk) | wie die Berufung |

**Der Lehrmeister** begleitet den Helden auf seinem Weg, bringt ihm Dinge bei und prüft ihn: **Zwischenprüfung, Gesellenprüfung, Meisterprüfung**. Kapitel 1 zeigt die Wege; Berufungen gibt es ab Kapitel 2.

**Was eine Berufung bringt:** neue Handlungen im Kampf und in der Welt, die besser sind als die bisherigen (Riposte, Tierbegleiter, Waffenzauber), keine großen Zahlenaufschläge. Die Kraft bleibt in den Fertigkeiten.

**Wechseln** geht beim Lehrmeister mit Abschlägen: Die Handlungen der alten Berufung gehen verloren, ihre Kernfertigkeiten sinken um einen Rang.

| Weg (wer ihn geht) | Kernfertigkeiten | Berufung | braucht auf Meister | Handlungen (Beispiele) | Auflagen |
| --- | --- | --- | --- | --- | --- |
| Schutz (Bewahrer) | Schild, Mittlere und Schwere Rüstung, Ausweichen | Wächter | Schild, Schwere Rüstung | Gegner binden, Gefährten decken | langsam, wenig eigener Schaden |
| | | Paladin (braucht auch den Weg Heilung) | Schild, Einhänder, Heilmagie | Heilende Hand, Schutzaura | nicht Beschwörer; Ruf muss hoch bleiben |
| Kampf (Kämpe) | Einhänder, Zweihänder, Faustkampf, Ausweichen | Berserker | Zweihänder, Stumpfe Waffen | Raserei | kein Schild, keine Zauber |
| | | Duellant | Einhänder, Ausweichen, Leichte Rüstung | Riposte, Doppelschlag | höchstens leichte Rüstung, kein Schild |
| | | Mönch | Faustkampf, Ausweichen | waffenlose Schläge, Betäuben | keine Rüstung, keine Waffen |
| Schatten (Schattengänger) | Schleichen, Spähen, Dolche | Assassine | Schleichen, Dolche, Alchemie (Gifte) | Meucheln, Giftklinge | höchstens leichte Rüstung, kein Schild |
| | | Schatzjäger | Schlösser knacken, Fallen entschärfen, Spähen | schwerste Schlösser, versteckte Kammern | höchstens leichte Rüstung |
| Wildnis (Waldgänger) | Bogen, Armbrust, Jagd, Spähen | Waldläufer | Bogen, Tiere beruhigen, Jagd | Tierbegleiter, Mehrfachschuss | höchstens mittlere Rüstung |
| | | Scharfschütze | Armbrust oder Bogen, Wurfwaffen, Spähen | Zielschuss, Durchschlagen | höchstens mittlere Rüstung |
| Magie (Adept) | eine Schule: Evokation, Schutzmagie, Illusion oder Beschwörung | Magier | zwei Schulen | stärkste Zauber, große Manareserve | keine Rüstung |
| | | Kriegsmagier | Evokation, Einhänder oder Zweihänder, Leichte Rüstung | Waffenzauber | nur leichte Rüstung, Magie gedeckelt |
| | | Beschwörer | Beschwörung | Diener beschwören, Untote | keine Rüstung; Ruf sinkt bei Nekromantie; nicht Paladin, nicht Heiler |
| Heilung (Heilkundiger) | Heilmagie, Heilkunde, Kräuterkunde | Heiler | Heilmagie, Schutzmagie, Heilkunde | Wiederbeleben, Seuchen heilen | höchstens leichte Rüstung |
| | | Paladin (siehe Schutz) | | | |

Die Spalten „braucht auf Meister“ sind auf die 37 Fertigkeiten umgeschrieben; Feinschliff beim Ausarbeiten der Prüfungen.

## 6. Meisterschaften

Handwerk läuft neben der Berufung, ohne Kampfauflagen. Man kann jede Meisterschaft machen, muss aber keine, und darf mehrere haben.

| Meisterschaft | Fertigkeit | Stellt her |
| --- | --- | --- |
| Schmied | Schmieden | Waffen, Metallrüstung, Dietriche, Reparatur |
| Lederarbeit | Lederarbeit | Leder, leichte Rüstung, Taschen, Köcher |
| Alchemist | Alchemie | Tränke, Gegengifte, Gifte, Elixiere |
| Runenmeister | Runenkunde | Verzauberungen, Runen auf Ausrüstung |
| Feldkoch | Kochen | Mahlzeiten mit kleinem Bonus |

## 7. Kampf

- **Die Stufe entscheidet viel.** Der Unterschied der Stufen zwischen Angreifer und Verteidiger bestimmt, wie viel Schaden ankommt. Ein Held der Stufe 50 erledigt ein Monster der Stufe 1 mühelos, und es kann ihm nicht schaden. Fertigkeiten, Waffen und Grundwerte geben den Rest. Das genaue Rechenmodell ist noch offen (Entwurf A).
- **Zufall nur als Würze:** kleine Streuung statt W20; kritische Treffer und Ausweichen hängen an Gewandtheit und Fertigkeit.
- **Schleichen und Hinterhalt:** Mit der Schleichtaste nähert sich der Held. Bleibt er unbemerkt (Schleichen gegen die Wachsamkeit des Gegners, ohne Würfel), greift er als Erster an und bekommt den Vorteil des Hinterhalts. Mehr Gegner sind schwerer zu überlisten. **Bosse** sind wachsamer, ihr Hinterhalt-Bonus ist gedeckelt.
- **Ausschlüsse sind hart.** Magier tragen ab der Berufung keine Rüstung, weil Metall die Aufnahme der Magiepartikel aus der Umgebung stört; der Kriegsmagier darf nur leichte Rüstung tragen. In schwerer Rüstung geht Schleichen nicht („Deine Rüstung klirrt“). Zweihänder und Schild schließen sich aus. Jeder Held hat genau eine Berufung.
- **Gegner gehören zu Gebieten**, damit niemand zu früh in zu hohe Stufen läuft. Höhere Gebiete sind betretbar; die Karte zeigt ihr Stufenband.

## 8. Die Welt

- **Spähen durch Verweilen.** Bleibt der Held etwa zwei Sekunden stehen, schaut er sich um: ein Ring zeigt Fallen, Kräuter, Spuren, versteckte Truhen und lauernde Gegner. Je höher Spähen, desto größer der Ring. Im Gehen sieht er einen kleinen Umkreis, im Rennen fast nichts. Spähen steigt nur, wenn wirklich etwas Neues entdeckt wird.
- **Fallen** stehen an Truhen und frei in Höhlen und Verliesen. Erst entdecken (Wahrnehmung, Spähen), dann entschärfen (Fallen entschärfen). Ohne die Fertigkeit löst die Falle aus.
- **Truhen und Schlösser:** Jede Truhe hat eine Schlossstufe, die zum Gebiet passt. Dietriche gibt es zu kaufen und vom Schmied, in Güteklassen; ein besserer Dietrich hilft, ein schlechter kann brechen. Ohne Schlüssel knackt man das Schloss oder bricht es mit Kraft auf (laut, kann zerbrechliche Beute beschädigen). Besondere Truhen öffnen Schlüssel oder Quests. Truhen in Häusern von NPCs bleiben zu; Stehlen gibt es nicht.
- **Tiere beruhigen:** Ein feindliches Tier lässt sich vor dem Kampf beruhigen; gelingt es, dreht es ab, und der Held bekommt Erfahrung wie für einen Sieg. Je höher der Rang, desto stärkere Tiere.
- **Tierbegleiter:** Nur der Waldläufer bekommt mit seiner Berufung ein Tier, das ihn begleitet und auf dem Platz eines Gefährten mitkämpft. Tiere werden weder verkauft noch in den Beutel gepackt.

## 9. Ruf

- **Ruf je NPC.** Wer für jemanden Quests erledigt, steigt in dessen Achtung. Fraktionen gibt es nicht.
- **Wirkungen eines guten Rufs:** günstigere Preise, mehr Auskünfte in Gesprächen, die in Quests weiterhelfen, Sonderwaren, günstigere Lehrer, frühere Prüfungen.
- **Ortsruf** ergibt sich aus dem Ruf der NPCs eines Ortes; wichtige NPCs (etwa Wirt, Schmied, Ortsvorsteher) zählen mehr. Er wirkt auf Wachen und die Stimmung im Ort.
- **Der Ruf sinkt** nur bei wenigen klaren, angekündigten Anlässen, etwa bei einer abgebrochenen Quest oder Verrat, und lässt sich durch Quests wieder aufbauen.
- **Anzeige:** eine Liste „Bekannte Personen“ mit Rufstufe und aktuellen Vorteilen.

## 10. Herstellen und Sammeln

**Drei Wege zum selben Ziel:** kaufen, herstellen oder finden. Wer nicht herstellen will, verkauft, was er sammelt, und kauft, was er braucht.

**Sammeln:**

| Rohstoff | Fundort | Fertigkeit |
| --- | --- | --- |
| Kräuter, Pilze, Blüten | Wiesen, Wald, Höhlen | Kräuterkunde |
| Erz, Steine | Adern, Felswände | Bergbau |
| Fische | Teich, Fluss | Angeln (Fang nach Rang, Angel und Gebiet) |
| Fleisch, Fell, Knochen, Sehnen, Zähne | erlegte Tiere | Jagd (Zerlegen nach dem Sieg; ohne Jagd weniger und schlechtere Teile, nie nichts) |

Ernten ist eine kurze Handlung ohne Minispiel. Fundorte wachsen nach einer Zeit nach. Höhere Gebiete liefern bessere Rohstoffe.

**Die Kette vom Tier zum Gegenstand:** Jagd (zerlegen) → Kochen (Fleisch, Fisch) · Lederarbeit (Fell zu Leder, leichte Rüstung, Taschen) · Alchemie (Zähne, Giftdrüsen, seltene Fische) · Händler (alles).

**Herstellen:**
- **Werkorte gestaffelt:** einfache Rezepte überall (Lagerfeuer), höhere an Schmiede, Werkbank, Alchemietisch, Gerberei.
- **Feste Rezepte** zuerst; Experimentieren kommt später, nur für Alchemie und Kochen. Rezepte gibt es bei Lehrmeistern und Handwerkern, in Büchern, als Belohnung und beim Händler.
- **Alchemie** wird als erste Rezeptgruppe gebaut, danach Rüstung.
- **Technik:** Jedes Rezept ist ein Datensatz (Zutaten, Fertigkeit und Rang, Werkort, Ergebnis). Tasche, Truhe, Werkort-Ablage und Händlerware sind dasselbe Bauteil. Die Rezeptliste zeigt drei Zustände: herstellbar, eine Zutat fehlt, gesperrt. Das Inventar ist eine Liste wie im alten Spiel, kein Raster; Herstellen ohne Wartebalken.
- **NPC-Handwerker** stellen gegen Gebühr her, wenn man die Zutaten bringt.

**Tragkraft:** Kraft bestimmt, wie viel der Held trägt. Früh im Spiel gibt es den **Nimmersatt-Beutel**, der die Tragkraft stark erhöht. Wer mehr trägt, wird langsamer; aufnehmen kann er trotzdem.

## 11. Abnutzung und Reparatur

- Ausrüstung hat einen **Zustand**: Gut, Abgenutzt, Beschädigt, Defekt. Mit sinkendem Zustand sinkt die Leistung. Das Spiel warnt rechtzeitig.
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
| Zaubertrick, Feuerpfeil, Heilige Flamme, Segnen | Kleinzauber, Funkenpfeil, Gleißstrahl, Beistand |
| Zweiter Atem, Tatendrang, Kampfstil Verteidigung | Kraft schöpfen, Doppelzug, Wehrhaltung |
| Stirge, Ockergallerte, Grottenschrat (Krogg), Hobgoblin (Grak) | Blutflügler, Ockerschleim, Bärenschrat, Goblin-Hauptmann |
| Rüstungsklasse, Übungsbonus, Rettungswurf, Vorteil/Nachteil | Schutzwert, Fertigkeitsbonus, Abwehrprobe, Gunst/Ungunst |
| Zauberpunkte, Zauberplatz | Mana |
| Kurze Rast, Lange Rast | Kurze Erholung (2 Stunden), Langes Ausruhen (9 Stunden) |
| Klassen Kämpfer, Schurke, Magier, Kleriker | entfallen; dafür Wege und Berufungen |

Folklore-Wesen (Goblin, Kobold, Skelett, Zombie, Ghul) und Tiere behalten ihre Namen. Gestrichen sind Barde, Gaukler, Taschendiebstahl, Reiter, Kaufmann und Hauptmann. Der Hinweis „SRD 5.1 · CC BY 4.0“ bleibt stehen, bis alles SRD-Abgeleitete ersetzt ist, auch die Monsterwerte und Zaubertexte.

## 13. Offen

- Rechenmodell für den Kampf (Entwurf A, Empfehlung Modell D).
- Taten, Chronik, Ätherdichte, Ruf mit Gedächtnis (Entwurf C).
- Werdegänge für die Wege Kampf und Schatten (Entwurf D).
- Wie Zwischen-, Gesellen- und Meisterprüfung auf Berufung und Meisterform verteilt sind; Umfang der Prüfungsquests.
- Wie die Grundwerte durch Fertigkeiten wachsen (Anteile je Haupt- und Nebenwert).
- Rufstufen, Gefährten ohne Klassen, Niederlage, Übernahme alter Spielstände, Reparaturverlust.
- Namensdopplung: Werdegang „Heiler“ und Berufung „Heiler“.
- Alle Zahlen: nach der Simulation.

---

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

**Die Idee:** Die **Stufe** bestimmt die Größenordnung (Schaden und Leben). Die **Fertigkeit** bestimmt das Können (ob man trifft und welche Handlungen man hat). D ist der Stufenunterschied: Stufe des Angreifers minus Stufe des Verteidigers.

| Regel | Formel (Startwerte) |
| --- | --- |
| Schaden | (Waffe + Grundwert) × (1 + D / 10), nie unter 0; danach minus Rüstung, nie unter 0 |
| Trefferchance | 70 % + (Angriffsfertigkeit − Abwehrfertigkeit des Gegners) × 0,5 %, begrenzt auf 5 bis 95 % |
| Glückstreffer | 1 von 100 Treffern rechnet mit Faktor 1 statt mit dem Stufenfaktor; gilt für beide Seiten |
| Erfahrung | Stufe über dem Gegner (D > 0): × (1 − D / 10), null ab D ≥ 10; Stufe unter dem Gegner (D < 0): × (1 − D / 10), höchstens doppelt |

**Monster braucht:** Stufe, Leben, Rüstung, Grundschaden je Angriff, Angriffsfertigkeit, Abwehrfertigkeit, Wachsamkeit gegen Schleichen.

**Beispiele** (alle Zahlen Beispiel):

| Fall | Werte | Held trifft | Gegner trifft | Ausgang |
| --- | --- | --- | --- | --- |
| **Held Stufe 1 gegen Monster Stufe 10** | Held: Grundschaden 8, Leben 20, Rüstung 2, Fertigkeit 10. Monster: Grundschaden 10, Leben 120, Rüstung 4, Angriff 50, Abwehr 40. D = −9 | Chance 70 − 15 = 55 %; Schaden 8 × 0,1 = 0,8 − 4 → 0. Glückstreffer: 8 − 4 = 4 | Chance 70 + 20 = 90 %; Schaden 10 × 1,9 = 19 − 2 = 17 | Held fällt nach zwei Treffern. Der Glückstreffer kratzt, rettet aber nicht. Erfahrung bei einem Sieg wäre × 1,9 |
| **Held Stufe 10 gegen Monster Stufe 1** | Held: Grundschaden 8, Fertigkeit 40. Monster: Grundschaden 5, Leben 12, Rüstung 4, Angriff 10, Abwehr 5. D = +9 | Chance 70 + 17,5 = 87,5 %; Schaden 8 × 1,9 = 15 − 4 = 11, das Monster fällt nach zwei Treffern | Schaden 5 × 0,1 = 0,5 − Rüstung → 0. Glückstreffer: 5 − 2 = 3 | Held gewinnt mühelos. Erfahrung × 0,1 |
| **Zwei gleich Starke, Stufe 5** | beide Grundschaden 10, Leben 50, Rüstung 2. Einer Geselle (Fertigkeit 40), einer Anfänger (20). D = 0 | Geselle: Chance 80 %, Schaden 8, braucht 7 Treffer | Anfänger: Chance 60 %, Schaden 8, braucht 7 Treffer | Der Geselle gewinnt deutlich öfter, weil er öfter trifft. Die genaue Quote misst die Simulation |

**Was das Modell leistet:**
- Ein kleiner Held verliert gegen ein starkes Monster, auch mit Glückstreffer.
- Der große Held gegen ein kleines Monster nimmt fast keinen Schaden und bekommt kaum Erfahrung.
- Bei gleicher Stufe entscheidet das Können: Üben zahlt sich sofort aus.
- Der „kaum zu tötende Handwerker“ entfällt: Er nimmt zwar wenig Schaden je Treffer, wird aber fast immer getroffen und trifft selbst selten.

**Zwei offene Punkte im Modell:**
- Der Glückstreffer macht Schaden, aber keinen Sieg. Soll der kleine Held wirklich einmal in hundert Kämpfen gewinnen können, braucht es eine andere Regel (etwa ein seltener entscheidender Treffer).
- Stufe 10 gegen Stufe 1 ist D = 9 und gibt noch ein Zehntel. Soll es dort schon null sein, beginnt die Null bei D ≥ 9.

- **Votum Sokrates: D.** Es erfüllt alle drei Anforderungen und hält die Rollen klar: Stufe für die Größe, Fertigkeit für das Können.
- **Stärkstes Gegenargument:** zwei Formeln statt einer (Schaden und Trefferchance), und alle Werte sind Startwerte ohne Messung. Ohne Simulation kann der Kampf zu lang oder zu kurz werden.

## Entwurf B zur Entscheidung: alle Stufen und Ränge auf einen Blick

Eine Klassenstufe gibt es nicht mehr. Es gibt: Heldenstufe, Grundwerte, Fertigkeitsrang, Ebene im Baum (Weg, Berufung, Meisterform), Meisterschaftsrang, Rufstufe, Monsterstufe und Gebietsband, Gegenstandsstufe.

| Was | Wofür | Stufen | Wie man aufsteigt |
| --- | --- | --- | --- |
| Grundwerte | Grundlage des Helden | Start 3 bis 8, offen nach oben | wachsen mit den Fertigkeiten |
| Fertigkeitsrang | wie gut der Held etwas kann | Anfänger, Geselle, Meister, Großmeister, weitere je Kapitel | durch Tun; Grenze je Kapitel, Lehrer als Tür |
| Heldenstufe | Leben, Kampfstärke, Zugang | 1, 2, 3 … ohne feste Höchststufe | Erfahrung aus Aufstiegen, Kampf, Quests, Story |
| Kapitelgrenze | Deckel der Heldenstufe je Kapitel | je Kapitel neu, weich bis zwei darüber | Kapitel abschließen |
| Weg | Richtung, in die der Held wächst | sechs Wege, mehrere zugleich | von selbst: zwei Kernfertigkeiten auf Geselle |
| Berufung | die eine bewusste Wahl | dreizehn Berufungen, eine je Held | beim Lehrmeister, ab Kapitel 2 |
| Meisterform | stärkere Form der Berufung | je Berufung eine | spätere Kapitel, beim Lehrmeister |
| Lehrmeister-Prüfung | Schritte auf dem Weg zur Berufung | Zwischenprüfung, Gesellenprüfung, Meisterprüfung | Quest beim Lehrmeister |
| Meisterschaft | Handwerk neben der Berufung | fünf, beliebig viele | Rang der Handwerksfertigkeit |
| Ruf | Ansehen bei einem NPC | Fremder, Bekannter, Vertrauter, Freund (Vorschlag) | Quests für diesen NPC |
| Meisterschaftsrang | wie gut der Held ein Handwerk kann | Ränge der Handwerksfertigkeit (Anfänger bis Großmeister) | herstellen |
| Monsterstufe und Gebietsband | Stärke eines Gegners; Stufenbereich eines Gebiets | Monster eine Stufe; Gebiet etwa Grenze − 5 bis Grenze + 2 | fest je Monster und Gebiet |
| Gegenstandsstufe | Stärke und Mindeststufe eines Gegenstands | wie die Heldenstufe | Fund, Händler, Herstellen nach Material und Rang |

## Entwurf C zur Entscheidung: das eigene Profil

- **Taten:** benannte Leistungen, die die Welt bemerkt. Sie bringen etwas Erfahrung, Ruf und sind Voraussetzung für Prüfungen. Beispiele: „Den Wolfsbau ohne Fackel geräumt“; „Grak ohne Heiltrank besiegt“.
- **Die Chronik schreibt mit:** Wege, Prüfungen, Berufungen und Taten werden Einträge in unserem Tusche-Stil. Beispiele: „Am dritten Tag betrat der Held den Weg des Schattens.“; „Morwen nannte ihn zum ersten Mal Freund.“
- **Ätherdichte:** Jeder Ort hat eine Magiestärke; Mana erholt sich und Zauber wirken danach. Beispiele: Im Wald und in Ruinen wirkt die Glutkugel stärker; in der Schmiede und in der Stadt erholt sich Mana langsamer. Start: eine Zahl je Gebiet und Kampfort.
- **Ruf mit Gedächtnis:** NPCs sprechen den Helden auf seine Taten an. Beispiele: „Du bist der, der die Wölfe vom Hof vertrieben hat.“; der Wirt gibt nach der Tat „Ratten im Keller“ einen Hinweis, den er Fremden nicht gibt. Texte über Homer.
- **Votum:** Taten und Chronik zuerst; Ätherdichte und Ruf mit Gedächtnis danach.

## Entwurf D zur Entscheidung: Werdegänge für Kampf und Schatten

- **Späher** für den Weg Schatten: Gewandtheit und Wahrnehmung betont; Startfertigkeiten Schleichen, Spähen, Dolche; Ausrüstung Dolch, Lederrüstung, Dietriche.
- **Kampf** bleibt ohne eigenen Werdegang, weil der Schildträger den Nahkampf abdeckt und der Haudegen gestrichen ist; über den freien Werdegang erreichbar.
- **Votum:** Späher ja; Kampf ohne eigenen Werdegang.

## Entwurf E zur Entscheidung: neuer Wortlaut für Leitbild und `CLAUDE.md`

Nur Vorschlag; geändert wird erst nach deinem Ja.

**`DESIGN-LEITBILD.md`, Punkt 4 (ersetzt „Das SRD ist das Gerüst, nicht das Ziel …“):**

> 4. **Eigenes Regelwerk: du wirst, was du tust.** Wir spielen nach unserem eigenen Spielsystem 2.0 (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`), nicht mehr nach dem SRD. Keine Klasse zu Beginn: Fertigkeiten wachsen durch Benutzung, Wege kommen von selbst, eine Berufung verdient man beim Lehrmeister. Keine feste Höchststufe; jedes Kapitel hebt die Stufengrenze. Zufall ist Würze, kein W20. Zahlen werden gemessen, nicht geraten.

**`CLAUDE.md`, erster Absatz (ersetzt „Regeln nach SRD 5.1“):**

> … Regeln nach unserem eigenen Spielsystem 2.0 (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`); der Hinweis „SRD 5.1 · CC BY 4.0“ bleibt, bis alles SRD-Abgeleitete ersetzt ist.
