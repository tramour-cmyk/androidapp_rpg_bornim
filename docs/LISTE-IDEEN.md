# Ideenspeicher

Ideen, die noch **nicht umgesetzt** sind, nach Bereichen (124). Hierher gehört jede Kür ohne Zweig, ohne Termin und ohne angefangene Arbeit (137); Kür mit angefangener Arbeit bleibt im Vorrat. **Sonntags** bereitet Homer auf (Urteil je Idee), **montags** holt Perikles beim Wochenziel Reifes in den Vorrat; „verwerfen?“ geht in die Chefrunde, verwerfen nur der Chef. Umgesetztes steht in der [Änderungshistorie](../CHANGELOG.md). Für alle Ideen gelten die [Stil-Leitlinien](DESIGN-STIL.md).

**Urteil** (Homer), je Idee ein Satz Pro und Contra (147); dann **reif** = kann in den Vorrat, sobald Perikles Platz hat; **später** = Bedingung fehlt (meist: nach dem Meilenstein Kapitel 1, Kapitel 2, eine Entscheidung); **verwerfen?** = erledigt, überholt oder doppelt, Chef entscheidet. Der Meilenstein (Kapitel 1 rund vor Neuem, `LISTE-ABNAHME-KAPITEL1.md`) macht fast alles Neue „später“.

**Aufbereitet:** 18.10., 09:0x (Homer): Urteile mit MARS auf `main` nachgezogen (Trefferchancen, Helfen, positive Zustände); „Vorgaben“ und „Bewusst so gelassen“ an ihren Ort (148). Vorher 17.10., 11:5x (erstmals, 137).

## Reif (Übersicht für Perikles)

- **Kampfaktion „Helfen“** → Vorrat Jerry, zu 72.10a.9 (unter Kampf).

Am 17.10. geholt (137): 138, 139, 140, 141, 133, 142.

## Verwerfen? (für die Chefrunde)

Nichts offen. Zuletzt verworfen (Chef 17.10., 137a): Aktive Abwehr per Tippen, Echte Gruppenkämpfe, Gefährte Lyra oder Garrick, Kampfkulisse der Höhle (mit 79), Film-Uhr; Text in Git.

## E Entwicklung

### Welt

- **Karten als Ware (62l)** (entschieden ja 13.10., 11:5x, mit 62e–62m; aus Toms Vorrat 18.10., weil Kür ohne Zweig und Termin): Händler verkaufen Karten fremder Gebiete, die die Kartenansicht füllen. → **später:** nach dem Meilenstein, sinnvoll erst mit den größeren Karten ab Kapitel 2.
- **Wind an Büschen, Farn, Schilf, Wäsche und Kronen** (D29.3 Rest, Diogenes Lauf 30; aus Toms Vorrat 19.10., Kür ohne Zweig): heute wiegt sich nur das Heilkraut. Braucht Bilder je Windstufe und den Tausch in der festen Objektliste von `WorldScreen.kt` (Absprache Jerry), Kosten Speicher und Bildrate auf dem Gerät. Gegenargument: ruhige Karte liest sich besser, Wind nur dort, wo er etwas sagt (Sturm, Höhe).
- **Wetter:** Nebel; Wind als Umgebungsklang. → **später:** Kapitel 1 hat Regen und Donner (D3.10); neues Wetter erst mit neuen Orten.
- **Monsterverhalten:** Goblins patrouillieren auf Wegen, Fledermäuse hängen an der Höhlendecke und stürzen herab. → **später:** nach dem Meilenstein; die Höhle ist „Ort fertig“ (13e) ohne das.
- **Sammelbares und Verstecke:** geheime Truhen, rissige Wände. → **später:** Kapitel 2, mit der Katze aus 72.15 (findet Geheimtüren).
- **Schnellreise über die Kartenübersicht** (Idee 09.10., 12:49): Pergamentkarte (Entwurf C, `tools/preview` Modus `WEGE`) mit Nebel des Unerkundeten; entdeckte Orte (Bornim, Garricks Feuer, Höhleneingang) sind Reiseziele gegen Gold. Gedanken: Fuhrmann in Bornim oder Garrick als Führer statt Teleport; Preis nach Entfernung; Zeit vergeht; unterwegs ein Wurf auf einen Überfall, nachts höher; nicht aus Höhlen, nicht im Kampf. → **später:** Kapitel 2 (Karten deutlich größer); in Kapitel 1 sind die Wege kurz.
- *(131, 17.10.: Gehen wird halb so schnell; weite Wege sollen Schnellreise oder Fuhrmann kürzen, nicht das Tempo.)*
- **Schwimmen oder Waten** (Chef 19.10., 15:44, Wortlaut: „Idee: Schwimmen oder Waten durch Teich/Fluss/Bach mit hohem Malus...“): heute ist Wasser nicht begehbar (Ufer, Brücke). Sokrates: nur Waten an gezeichneten Furten (Bach, flacher Teichrand), Tempo stark gebremst, Rennen nicht möglich; kein freies Schwimmen, weil Brücke und Schlagbaum sonst als Engstellen der Karten wegfallen und je Klasse Bilder für Waten und Schwimmen nötig wären. → **später:** mit den größeren Karten ab Kapitel 2 (Sumpf, Aschfurt).
- **86.5 Pferd** (Chef 14.10., 21:2x, zu 86.3 Ausdauer): Reittier für lange Wege draußen. → **später:** zusammen mit der Schnellreise prüfen, beide lösen dasselbe.
- **Licht als Mechanik** (Idee 4, 10.10.): Fackel brennt ab; im Dunkeln sieht man Lauerer später, Untote sind stärker. → **später:** Teil von 84 (Fackel 84.1 im Vorrat Homer); erst wenn 84.1 gebaut ist.
- **84.2 Schnellwechsel** zweier Handbelegungen (Chef 14.10.; aus Vorrat Homer, 84). → **später:** braucht 84.1 (Fackel in der Nebenhand), vorher gibt es nichts zu wechseln.
- **84.3 Schleichen** (Chef 14.10.; aus Vorrat Homer, 84). → **später:** hängt am Kampfteil 72b; Lauschen und „Rennen laut“ sind schon gebaut (86). 131: eigene Taste, wenn gebaut.
- **84.4 Lauschen beim Stehen** (Chef 14.10., 18:0x/18:1x „sehr gut“; aus Vorrat Homer, 84): Welle am Helden zur Geräuschquelle, Stärke = Deutlichkeit, Wort nur bei deutlichem Hören; Stufen Stehen > Schleichen > Gehen > Rennen. → **später:** nach dem Meilenstein; Bau Jerry (mit 86, „Rennen laut“ gebaut).

### Figuren

- **Handlaterne für Jorin** (66a, 13.10.): Laterne in der freien Hand bei Nacht, neue Haltungen für Gehen, Wache, Abstellen. → **später:** neue Haltungen nach dem Meilenstein; Leerlauf (55) und Licht im Dorf (66) sind erledigt.
- **114.1 Aufstehsequenz** (Chef 16.10., 12:2x: „Idee: Aufstehsequenz aus Bett?“): Held liegt und steht auf. → **später:** Tom empfiehlt „noch nicht“ (neue Bilder liegend und aufstehend in allen Richtungen); 114 selbst bleibt im Vorrat Homer (Entwurf PR #83).
- **Mehr Abwechslung beim Helden** (Rest aus 08.10.): Ausweichen ist nur ein Hüpfer (zwei Seiten), der Speer hat zwei Stöße, Zauber eine Bewegung je Fokus. → **später:** mit 52.
- **Flüssigere Grafik mit mehr Zwischenbildern** (Wunsch 10.10., 11:00; teils erledigt: Sprungtest 12/12a, Gehen in 8 Bildern): Haltungen wechseln 11- bis 13-mal pro Sekunde und bremsen an jeder Zwischenhaltung. Mehr Bilder, längeres Vorabzeichnen. → **später:** erst wenn dem Chef etwas unrund vorkommt (19e im Vorrat Jerry, Meilenstein).

### Kampf

- **Tipp beim eigenen Angriff** (Sokrates 19.10., Chef „Rest wie vorgeschlagen“, Vorgangsarchiv 219): im richtigen Moment tippen, härter treffen, wie Paper Mario; teuer, jede Angriffsbewegung braucht festen Takt. Gehört zu 72.10a.13. → **später:** nach dem Meilenstein mit 212.
- **Bedenkzeit im MARS-Zug** (Chef 19.10., 15:28, Wortlaut: „… dass man zumindest vielleicht auch einen Timer runterlaufen lässt, wenn man bis dahin nichts macht. [Der Held] hält dumm da. Und kriegt halt eine auf die Mütze. Oder ist das zu hardcore? Oder eine Möglichkeit, das zu und abzuschalten … Maximal 10 Sekunden … Oder 5. Oder gar nicht.“): Sokrates: Uhr nur abschaltbar, Standard aus, bei Ablauf Abwehr statt Nichtstun, Pause beim Verlassen der App; straft sonst das Lesen der Absichten, also die Wahl, um die es MARS geht. Nur als Schwierigkeitsstufe (Vorgangsarchiv 219). Gehört zu 72.10a.13 (Takt, „noch nicht“). → **später:** nach dem Meilenstein mit 212.
- **52 Feinarbeit an den Kampfanimationen** (gesamt, auch Krogg; aus Vorrat Jerry): Krogg so lassen, später alle gesamt; Rudelwölfe auf `main`. → **später:** nach den neuen Kampforten (72u) und der Probe 72.10, sonst doppelte Arbeit.
- **Todesstoß für Fernkampf und Zauber** (gewünscht 09.10.): Pfeil, der den Gegner umreißt und festnagelt; Feuer, das ihn verzehrt; Kraft, die ihn zerreißt. → **später:** nach dem Meilenstein, mit 52.
- **Echtes Zerteilen in 3D** (Killerschlag, 09.10. als späterer Schritt gewählt): Körpermodell durchschneiden, Schnittflächen, Hälften fallen räumlich; auch für Tiere; ein bis zwei Arbeitstage. → **später:** nach dem Meilenstein; Altersfreigabe (Blut) vorher klären (45).
- **Trefferchancen sichtbar** (Teil von Idee 2): Chance vor dem Angriff anzeigen. Pro: fair, Würfelglück wird lesbar (Leitbild 4); Contra: noch mehr Zahlen über dem Kampfort. → **später:** MARS zeigt seit 18.10. den Wurf danach (72.10a.10); erst das Urteil des Chefs dazu abwarten.
- **Verletzungen bis zur Rast** (Idee 3): wer tief fällt, behält eine Wunde (z. B. −1 RK), sichtbar als Verband; das Gasthaus heilt sie. → **später:** = 72c (Empfehlung „ab Kapitel 2“, unbeantwortet im Marktvergleich).
- **Kampfaktion „Helfen“** (Chef 12.10., zu 34): Gefährte greift im Vorteil an. Pro: der Söldner in MARS bekommt eine eigene Wahl; Contra: noch eine Taste. → **reif, zu 72.10a.9** (Rolle je Klasse, Vorrat Jerry): dort mit abwägen, kein eigener Bau.
- **Weitere Zauber** ab Stufe 5 für alle Zauberklassen; **Kleriker „Läutern“** (heilt Zustände); **positive Zustände** (Gesegnet, in MARS seit 18.10. gebaut, Geschützt, Hast, z. B. durch Tränke); **Ausrüstung mit Giftresistenz.** → **später:** Kapitel 2, Werte mit dem Balanceplan (38).
- **Zeichen der Absicht als eigene Zeile** (Rest 130.3, Jerry 18.10.): Zeichen des Gegners heute nur im MARS-Protokoll; eigene Zeile über dem Gegner, Ringtext für die Spinne. Pro: Absicht schneller lesbar; Contra: mehr Text am Kampfort, Chef zu Build 22 „alles passt“. → offen
- **Rauchbündel allgemein** (Sokrates 15.10., D4.1): bei Morwen kaufbar gegen jeden Hinterhalt oder ersten Hieb. → **später:** erst wenn „Normal“ eingestellt ist (38, Wochenziel); sonst verschiebt es die Messung.

### Klang

- **Ortsklang, Vorschlagsliste aus D29.1/D29.2** (Diogenes Lauf 30, geprüft von Jerry 19.10.; Rangfolge nach Wirkung je Aufwand): (1) Schritte auf Laub und Waldboden im Wald und Tiefen Wald, Plätschern in Furt und Ufer (hört man ständig; heute Gras/Erde wie im Dorf). (2) Blätterrauschen nach Bäumen in der Nähe statt gleichförmigem Wind, im Tiefen Wald dunkler mit Knarren. (3) Dorf: Brunnen (Eimer, Kette), Fackeln und Lampen leise knistern in der Nähe, Wäscheleine bei Wind, Tor knarrt. (4) Fremde Türen, Schritte von Leuten und Tieren (Arbeit der Leute: Tom). Pro: Stilregel „man hört, was da ist, aber das voll“ (44d), Dorf heute fast stumm. Contra: jedes Geräusch braucht drei CC0-Fassungen und Hörproben; zu viel auf einmal wird Brei. Vorschlag: (1) zuerst, je Punkt Hörprobe.
- **Treffer, Fehlschlag, Abwehr, Schwung, Biss, Pfeil aus Aufnahmen** (Jerry 19.10. bei 141): diese zehn Kampfklänge sind noch Synthese (`Sfx.kt`), alles andere kommt aus CC0-Aufnahmen (18, 18f, 18.11). Pro: Stilregel „echte Aufnahmen statt Synthese“, man hört sie am häufigsten. Contra: schon einmal realistischer gemacht, Abwehr und Fehlschlag gelten als gut; Gefahr, dass Aufnahmen gegen die Stimmen matschen. Vorschlag: Hörprobe alt gegen neu, je drei Fassungen.
- **Musik in Schichten** (Idee 10): nähert sich ein Jäger, schleicht eine dunkle Spur in die Musik, bevor der Kampf beginnt; Stille bewusst einsetzen. → **später:** nach dem Meilenstein; Musik (28) und Raumklang (119) sind fertig.

### Oberfläche

- **Gezeichnete Bilder auf dem Gerät speichern** (24.4, 11.10.): Figuren-, Boden- und Kampfbilder nach dem ersten Zeichnen ablegen, damit der nächste Start ohne Wartezeit geht. → **später:** erst messen, wie lang das Übergangsbild nach 24.1–24.3 noch dauert.
- **59.6 Händler: Filter** „nur tragbare“, Sortierung nach Platz (Chef 12.10., 22:49). → **später:** wenn es mehr Ware gibt (Kapitel 2).
- **59.7 Händler mit Gesicht:** Name, Bild, Begrüßungssatz statt „Laden“; Texte Chef und Homer (41) (Chef 12.10., 22:49). → **später:** nach dem Meilenstein; neue Bilder je Händler.

## G Gestaltung

### Story

- **Kapitel 2, Geschichte:** Spur des „Grauen Propheten“, „Tag der Asche“ als Bedrohung. → **später:** steht im Storyplan (41).
- **Dorran, der Schmied** (wohnt heute hinter verschlossener Tür, „Er ist wohl in seiner Werkstatt“):
  - **Schmiede:** offene Werkstatt neben seinem Haus mit Esse, Amboss, Wassertrog; Funken, Hammerschläge, abends glüht die Esse.
  - **Einstieg als Quest:** Esse kalt, Goblins haben den Erzkarren auf der Waldstraße überfallen; **Eisenerz** aus der Blutzahnhöhle (Erzadern, Kisten) öffnet die Schmiede.
  - **Aufwerten:** Schaden oder RK um eine Stufe gegen Gold und Material (Eisenerz für Metall, Felle für Leder, Hauer und Giftdrüsen für besondere Werte); wenige Stufen je Teil, nie über die Obergrenze des Kapitels.
  - **Zerlegen:** Ausrüstung in Material (Eisen, Leder, ab „selten“ **Glutstaub** für bessere Aufwertungen).
  - **Auftragsarbeit:** Waffe für die eigene Klasse, am nächsten Spieltag fertig.
  - **Attribute:** Charisma senkt Preise; Stärke hilft am Amboss, spart Material.
  - **Bedienung:** eigener Reiter im Laden („Schmieden“), Material-Anzeige wie bei den Rezepten.
  - **Kapitel 2:** Runen, Sockel, seltene Erze, Belohnung für eine größere Aufgabe.
  - → **später:** der Meilenstein nennt den Schmied ausdrücklich als „Neues danach“; 72e entschieden (19.10.): Umschmieden gestrichen, der Rest bleibt.
- **Handwerk:** Felle und Hauer verarbeiten, z. B. Lederrüstung verbessern (heute nur zum Verkaufen). → **später:** mit dem Schmied, sonst zwei Wege für dasselbe.
- **70 Bildsprache der Zwischensequenzen, Rest** (Chef 14.10., 08:00; aus Vorrat Homer): 70.1–70.6 entschieden (`DESIGN-STIL.md`). → **später:** mit dem nächsten Kapitel.
- **Mond nach Himmelsrichtung** (Chef 15.10., 13:5x, zu 70.6, „vorerst nicht“): in Bornim (52° N) steht der Mond nie im Norden; Blick nach Norden zeigt nur sein Licht, Ost bis West darf er ins Bild. → **später:** mit 70 Rest.
- **Eigenes Haus** (Chef 14.10.): irgendwo ein Haus kaufen, Ausrüstung lagern, Begleiter zurücklassen und einen anderen mitnehmen (Hund daheim, Katze oder Rabe dabei). → **später:** braucht mehr als einen Begleiter (72.15).
- **Begleiter mit Bindung** (72.15, Richtung beschlossen 14.10.): ein Begleiter zur Zeit, aus Geschichte oder Welt, nie gekauft (45). Vertrautheit in 4 Stufen durch gemeinsame Orte, Füttern am Feuerplatz, Nutzen seiner Gabe, nie durch Töten oder Warten; jede Stufe öffnet ein Verhalten und zeigt sich am Tier (Halsband, Narbe, Gruß). Hund (Wolf-Modell): hört Gegner früher (84), folgt Spuren (61a), weckt bei Überfall an der Rast (86.11), findet Verstecktes. Später Rabe (späht Nebel), Katze (Fallen, Geheimtüren). Verletzt zieht er sich bis zur Rast zurück, stirbt nie. Tiermeister: derselbe Begleiter kämpft mit. → **später:** erst nach Probe 72.10, Start mit einem Hund.

### Balance und Attribute

- **Stärke, rohe Gewalt:** Truhen oder Gitter ab einem Mindestwert aufbrechen statt nur mit Schlüssel. → **später:** neuer Karteninhalt, Kapitel 2.
- **Charisma, Gesprächsoptionen:** „Überreden“ oder „Einschüchtern“ bei Wachen, Händlern, Bösewichten, wenn es zur Geschichte passt. → **später:** Vorschlag mit 133 (Vorrat Homer), gebaut in Kapitel 2.
- **Charisma, Auftreten auf der Karte:** Wanderer und schwächere Monster weichen einem einschüchternden Helden aus. → **später:** nach dem Meilenstein; verschiebt sonst die Messung 38.
- **Weisheit, Lauerer erkennen:** Spinne, Fledermaus werden früher sichtbar. → **später:** mit 84 (Lauschen, Licht), sonst zwei Regeln für dasselbe.
- **Klassensets** (Chef 19.10., 10:30: „Klassensets mit Boni je nach Anzahl der getragenen zusammengehörigen Teile.“): Pro Sammelziel über Kapitel, Klassenbild (passt zu 49/50); Contra klassischer Farm-Antrieb (Leitbild, 45), Bindung an ein Set nimmt Wahl. Fassung Sokrates: Teile nur an festen Orten oder Aufträgen (etwa eins je Kapitel), nie in Zufallsbeute oder Laden; Bonus eher eine neue Kampfoption als Zahlen. → Urteil Homer; vermutlich **später** (nach dem Meilenstein, 179).

### Kapitel 2: Region und Gegner

- **Neue Region:** z. B. Sumpf oder Ruinenstadt; **Karten ab Kapitel 2 deutlich größer.** → **später:** Storyplan Kapitel 2 (41).
- **Neue Monster (SRD):** Banditen und Kultisten, Gnoll, Worg, Harpyie (Gesang, Bezauberung), Belebte Rüstung, Mimik (Klammern), Oger, Eulenbär. Gebaut auf den 3D-Grundmodellen (Heldenpuppe für Menschenähnliche, Vierbeiner wie der Wolf); ein neues Monster braucht vor allem Ausrüstung, Maße, Kopf, eigene Haltungen; je drei Varianten (`DESIGN-STIL.md`). Aufwand: sehr gering Banditen, Kultisten, Worg (Wolf, größer und dunkler); gering Belebte Rüstung (hohl wie das Skelett); gering bis mittel Oger (Large, um 2,7 m); mittel Gnoll (Hyänenkopf), Eulenbär; eher hoch Harpyie (Flügel, Vogelbeine); eigenes Modell Mimik (Truhe mit Maul). Was für Kobold, Zombie, Krogg, Grak, Wildschwein, Ratte entsteht, macht sie günstiger. → **später:** Kapitel 2.
- **Neue Untote:** Schatten (Stärke entziehen), Gruft-Unhold (Lebensraub), Irrlicht (unsichtbar). → **später:** Kapitel 2.
- **Neue Bosse:** Banditenhauptmann, Ogerhäuptling, Gelatinewürfel; mehrphasig, rufen Verstärkung. → **später:** Kapitel 2.

## B Betrieb

### Werkzeuge

- **Dokumente WireStormTCS nachziehen (102)** (aus Perikles' Vorrat 18.10., Kür ohne Termin): Firmenhandbuch und Begleittexte auf den Stand nach dem Umbau 17.10. bringen.
- **`DESIGN-BLENDE.md` kürzen (111)** (aus Perikles' Vorrat 18.10., erst nach 24.6): Entschiedenes ins Vorgangsarchiv, Rest auf das Nötige.
- **Kennzahl des Chefs** (Chef 19.10., 10:42: „Wie werde ich eigentlich gemessen oder bilanziert?“): heute keine eigene; Vorschlag Sokrates: **Wartezeit auf den Chef** (Stunden von Datei in `entscheiden/`/`billigen/` bis Löschen, aus Git, ohne Zählkosten) neben „ersparte Fragen“ (FIRMA.md). Contra: „Mehr Kennzahlen nicht“ (106.1), Chef ist kein Mitarbeiter. → Urteil Homer/Perikles; Wochenzählung 26.10.


## M Markt

### Veröffentlichung

- **Weg** (besprochen 10.10., 13:36): (1) Stilumbau abschließen. (2) Pflichttest im Play Store (neues privates Konto: mindestens 12 Tester, 14 Tage am Stück) als echten Test, Rückmeldungen sammeln. (3) Kapitel 1 kostenlos (99 Cent bringen kaum Käufer: keine Sichtbarkeit ohne Bewertungen, nach Steuer und Google-Anteil etwa 70 Cent). (4) Vollversion mit einmaligem Kauf, spätere Kapitel nachkaufbar (45a); Preis offen (72g). Vorher: Datenschutzerklärung, Altersfreigabe (Blut), Zahlungsprofil mit Händleradresse, kurze Rechtsprüfung (Schriften, Klänge).
- **Anmeldung mit Google Play** (Play Games Services): Anmeldung mit dem Google-Konto, Spielstände in der Cloud je Platz, Erfolge („Grak besiegt“, „Erste schimmernde Beute“), auf Wunsch Bestenlisten; im Code Bibliothek, Anmeldung beim Start, Cloud-Abgleich. → **später:** erst wenn das Spiel öffentlich erscheint.
- **Rechtliches:** vor öffentlicher Veröffentlichung oder kommerzieller Nutzung kurze Prüfung durch einen Anwalt für Marken- und Urheberrecht. → **später:** vor Schritt 3, nicht für den geschlossenen Test.
