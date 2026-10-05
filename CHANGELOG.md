# Änderungshistorie

Alle Änderungen an „Chroniken von Bornim“, neueste zuerst. Jede Version ist als [Release](https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases) mit fertiger APK verfügbar. Zeiten in Berliner Zeit.

## Unveröffentlicht

## v0.1.11 – 05.10.2026, 14:48

**Neu**
- **Nebel des Unbekannten** in Wald und Höhle: Unerkundetes ist schwarz, Gesehenes bleibt abgedunkelt sichtbar. Der Held sieht in einem Kegel von 160° in Blickrichtung etwa 5 Felder weit (nachts und in der Höhle 4) und rundum ein Feld; Bäume, Felsen und Wände verdecken die Sicht. Monster sieht man nur, wenn sie im Blick sind – das „!“ eines Verfolgers hört man aber auch aus dem Nebel. Erkundetes wird gespeichert. Antippen zum Hinlaufen geht nur in bereits erkundetes Gebiet.
- **Tiefer Flüsterwald:** neues, gut doppelt so großes Gebiet östlich des Flüsterwalds (Ausgang beim Jägerlager), Gebietsstufe 2, 13 umherstreifende Monster, nachts Untote und Ghule, vier Truhen.
- **Kräuterfrau Hedda** am Lagerfeuer im Tiefen Flüsterwald: verkauft Tränke und Kräutertränke; ihr Kräuterrauch macht das Lager zur Schutzzone.
- **Grimmzahn, der Leitwolf:** optionaler Boss im Norden des Tiefen Flüsterwalds mit eigenem Beutestück „Grimmzahns Fang“ (episches Amulett mit Blutungschance). Lässt sich im Testmenü mit „Bosse zurücksetzen“ erneut herausfordern.

## v0.1.10 – 05.10.2026, 14:28

**Fehlerbehebungen**
- Ausrüstungsreiter: Nach dem Ablegen eines Gegenstands wird die Ausrüstungsgrafik sofort aktualisiert (vorher blieb das alte Bild stehen).
- Tasche und Laden: Die Pfeile ▲/▼ (besser/schlechter als das Angelegte) sind nach dem Anlegen sofort aktuell.

## v0.1.9 – 05.10.2026, 14:19

**Neu**
- **Kobold-Rudel:** Kobolde kommen mit ein oder zwei sichtbaren Begleitern. Diese stehen im Kampf hinter dem Anführer und stechen mit zu; fällt der Anführer, fliehen sie. Ein Feuerball verjagt das Rudel sofort. Auf der Karte laufen Kobolde als Grüppchen. (Ersetzt den bisherigen unsichtbaren „Vorteil“-Wurf.)
- **Schutzzonen:** Am Lager von Jäger Wilhelm, an den Waldausgängen und am Höhleneingang greifen keine Monster an und es gibt keine Hinterhalte. Am Lager erscheint der Hinweis „Jäger Wilhelm schwenkt seine Fackel – die Biester weichen zurück!“.
- **Ein- und Zweihänder erkennbar:** „2H“-Plakette am Symbol, „Zweihändig“/„Einhändig“/„Nebenhand“ im Untertitel, eigene Zeile in den Details und Warnung, was beim Anlegen abgelegt wird.

**Geändert**
- Monster sehen den Helden erst ab 4 Feldern (vorher 5) und verfolgen ihn etwas langsamer.
- Verfolger geben auf, wenn der Held mehr als 7 Felder Vorsprung hat oder sie mehr als 9 Felder von ihrem Revier entfernt sind.

**Fehlerbehebungen**
- Monster, die die Verfolgung abbrechen, kehren zu ihrem Startpunkt zurück, statt am Abbruchpunkt stehen zu bleiben.

## v0.1.8 – 05.10.2026, 13:25

**Neu – lebendige Welt**
- **Tag und Nacht:** Eine Spielstunde dauert eine Minute; Uhrzeit und Tag stehen oben rechts. Nachts wird es dunkel, um den Helden liegt ein Laternenschein, Fenster und Lagerfeuer leuchten.
- **Nachtmonster:** Nachts streifen Skelette, Zombies und Fledermäuse durch den Wald.
- **Schlafen:** Nachts kann man im Gasthaus-Bett bis zum Morgen schlafen (volle TP und ZP).
- **Dorfleben:** Finn und Greta laufen im Dorf umher und bleiben stehen, wenn man neben ihnen steht.
- **Kleinigkeiten:** Schmetterlinge, auffliegende Vögel, Schornsteinrauch, Glühwürmchen, fallende Blätter, gelegentlicher Regen.
- **Umgebungsgeräusche:** Vögel am Tag, Grillen und Eule in der Nacht, Tropfen in der Höhle.
- **Testmenü:** „Uhrzeit +3 h“ und „Regen an/aus“.

## v0.1.7 – 05.10.2026, 13:11

**Neu – sichtbare Monster**
- Monster streifen sichtbar durch Wald und Höhle:
  - **Jäger** (Wolf, Goblin, Ghul, Skelett …) entdecken den Helden mit rotem „!“ und Signalton und verfolgen ihn.
  - **Lauerer** (Spinne, Fledermaus, Gallerte) warten versteckt und springen erst aus der Nähe heran.
  - **Wanderer** ziehen friedlich umher.
- **Erstschlag:** Wer ein Monster von hinten angreift, überrascht es (es setzt eine Runde aus). Wer von hinten erwischt wird, gerät in einen **Hinterhalt**.
- Elite-Monster leuchten schon auf der Karte in ihrer Farbe, schimmernde funkeln.
- Antippen eines Monsters greift es an; die Aktionstaste zeigt dann gekreuzte Schwerter.
- Ist der Held der Gegend weit überlegen, weichen normale Monster aus.
- Besiegte Monster kehren nach 60 Schritten zurück.

**Geändert**
- Zufallskämpfe gibt es nur noch sehr selten (0,4 % pro Schritt im hohen Gras), immer als Hinterhalt mit eigenem Klang.

## v0.1.6 – 05.10.2026, 13:02

**Neu – Statuseffekte**
- Sieben Zustände mit Rundenzähler, als farbige Schilder an den Lebensbalken: Vergiftet, Brennend, Blutend, Betäubt, Verlangsamt, Geschwächt, Geblendet.
- Quellen:
  - **Monster:** Spinnengift und Netz, Ghul-Lähmung (Elfen immun), Schamanenfluch und Feuerpfeil, Fledermaus blendet, Stirge und Grak lassen bluten, Krogg betäubt.
  - **Kritische Treffer** – Klingen lassen bluten, Wuchtwaffen betäuben (für Held und Monster).
  - **Zauber:** Feuerzauber und Alchemistenfeuer setzen in Brand, Heilige Flamme kann blenden.
  - **Elite-Eigenschaften:** Giftig, Glühend.
- Neue Eigenschaften auf Ausrüstung: Gift-, Blutungs- und Betäubungschance, Standhaftigkeit (wehrt Zustände ab).
- Neuer **Kräutertrank** im Laden (20 Gold): heilt alle Zustände.

**Geändert**
- Spinnengift wirkt jetzt über mehrere Runden statt als Sofortschaden.
- Giftige und glühende Eliten abgeschwächt, damit sie nicht zu hart sind.

## v0.1.5 – 05.10.2026, 12:45

**Geändert**
- Reiter „Held“: Der Anteil der Ausrüstung an jedem Attribut steht blau neben dem Wert.

**Fehlerbehebungen**
- Testmenü: Beim Herabstufen werden zu viel verteilte Attributspunkte zurückgenommen (zuerst beim am stärksten gesteigerten Wert). Ein Held auf Stufe X hat danach genau X − 1 Punkte.

## v0.1.4 – 05.10.2026, 11:23

**Geändert**
- „Über das Spiel“: neue Beschreibung, passend zum README.

## v0.1.3 – 05.10.2026, 11:15

- Nur README (neue Kurzbeschreibung); die App ist unverändert zu v0.1.2.

## v0.1.2 – 05.10.2026, 11:09

**Geändert**
- APK mit eigenem, dauerhaftem Signierschlüssel. Einmalig v0.1.1 deinstallieren, danach funktionieren Updates normal.

## v0.1.1 – 05.10.2026, 10:45

**Neu**
- Umzug in dieses Repository. Funktionsumfang wie der letzte Stand des Vorgängerprojekts (siehe unten).
- Eigene App-Kennung `de.bornim.game`: Die App wird als neue App installiert, alte Spielstände werden nicht übernommen.
- Signiert noch mit einem temporären Schlüssel.

---

## Vorgeschichte (Vorgängerprojekt, bis 05.10.2026)

Die Entwicklung begann in einem früheren Repository. Die wichtigsten Schritte bis zum Umzug:

1. **Grundspiel:** Kapitel 1 „Der Blutzahn-Stamm“ (Dorf, Flüsterwald, Blutzahnhöhle, Krogg und Hauptmann Grak), 5 Völker, 4 Klassen, vereinfachte Regeln nach SRD 5.1, rundenbasierte Kämpfe, Deutsch und Englisch, Speichern und Laden.
2. **Spielgefühl:** flüssige Bewegung, volle Heilung beim Stufenaufstieg, Attributspunkte mit Bestätigung, Ladenkauf mit Gegenstandsdetails.
3. **Musik und Grafik:** lizenzfreie, selbst komponierte Musik (Oberwelt, Kampf, Bosskampf, epische Titelmusik), abschaltbar; Grafik in 32 px mit Schrägansicht; Copyright auf dem Titelbild.
4. **Beutesystem:** 9 Ausrüstungsplätze, Ein- und Zweihänder, Kampf mit zwei Waffen, zufällige Eigenschaften, 6 Seltenheitsstufen von gewöhnlich bis göttlich, Elite-Gegner, mitwachsende Monster.
5. **Klang und Kampf:** neu synthetisierte Musik, 26 Soundeffekte, Kampfanimationen mit Variationen.
6. **Name:** Das Dorf und das Spiel heißen jetzt Bornim.
7. **Fehlerbehebung:** TP-Anzeige oben rechts aktualisiert nach Lagerfeuer oder Heilung beim Priester.
8. **Neue Kampfgrafik:** 64-px-Monster mit Licht, Schatten und Animationen; Varianten pro Begegnung; Held zeigt seine Ausrüstung; 8 neue Monsterarten (insgesamt 17); Elite-Eigenschaften mit Aura; schimmernde Varianten.
9. **Testmenü** (7-mal auf das Copyright tippen); Eliten erst ab Heldenstufe 2.
10. **Touch-Steuerung:** Ziehen und Tippen zum Laufen, Aktionstaste mit Symbol statt A/B, klassisches Steuerkreuz als Option.
