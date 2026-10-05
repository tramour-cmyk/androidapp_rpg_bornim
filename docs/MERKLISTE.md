# Merkliste

Ideen und Vorschläge aus der bisherigen Entwicklung, die noch **nicht umgesetzt** sind. Gesammelt, damit wir sie später prüfen, neu bewerten oder verwerfen können. Stand: 05.10.2026, 17:05 (Berliner Zeit).

Bereits umgesetzte Punkte stehen in der [Änderungshistorie](../CHANGELOG.md).

## Attribute (Rest aus dem Attribut-Paket)

- **Stärke – rohe Gewalt:** Manche verschlossene Truhen oder Gitter lassen sich ab einem Mindestwert aufbrechen statt nur mit Schlüssel. Braucht neuen Karteninhalt, daher für Kapitel 2 gedacht.
- **Charisma – Gesprächsoptionen:** „Überreden“ oder „Einschüchtern“ bei Wachen, Händlern und Bösewichten, wenn es zur Geschichte passt. Braucht neue Dialoge, daher für Kapitel 2 gedacht.
- **Charisma – Auftreten auf der Karte:** Wanderer und schwächere Monster weichen einem einschüchternden Helden aus.
- **Weisheit – Lauerer erkennen:** Lauernde Monster (Spinne, Fledermaus) werden früher sichtbar.

## Kapitel 2

- **Geschichte:** die Spur des „Grauen Propheten“ und der „Tag der Asche“ als Bedrohung.
- **Neue Region:** z. B. Sumpf oder Ruinenstadt. Vorgabe: **Karten ab Kapitel 2 deutlich größer** als in Kapitel 1.
- **Technisch beim Start von Kapitel 2:** den Merker `chapter2_started` setzen. Damit gelten automatisch:
  - die Stufengrenze 6 fällt, aufgehobene EP werden angerechnet;
  - bessere Beute (normal bis „selten“, besondere Beute bis „sehr selten“);
  - höhere Obergrenzen für Ausrüstungsboni (+2).
- **Neue Monster (SRD):** Banditen und Kultisten, Gnoll, Worg, Harpyie (Gesang/Bezauberung), Belebte Rüstung, Mimik (Klammern), Oger, Eulenbär.
- **Neue Untote:** Schatten (Stärke entziehen), Gruft-Unhold (Lebensraub), Irrlicht (unsichtbar).
- **Neue Bosse:** Banditenhauptmann, Ogerhäuptling, Gelatinewürfel; mehrphasig, rufen Verstärkung.

## Gruppe und Kampf

- **Begleiter:** Lyra (Heilerin) oder Jäger Wilhelm als zweites Gruppenmitglied.
- **Echte Gruppenkämpfe:** mehrere Gegner gleichzeitig mit Zielauswahl, eigenen Lebensbalken und Flächenzaubern gegen alle. Großer Umbau; die heutigen Rudel (Begleiter im Hintergrund) wären die Vorstufe.
- **Weitere Zauber** ab Stufe 5 für alle Zauberklassen.
- **Kleriker-Fähigkeit „Läutern“:** heilt Zustände.
- **Positive Zustände:** Gesegnet, Geschützt, Hast, z. B. durch Tränke.
- **Neue Ausrüstungseigenschaft:** Giftresistenz.

## Welt und Leben auf der Karte

- **Kartenansicht** im Menü mit den bereits erkundeten Bereichen.
- **Bewohner mit Tagesablauf:** Der Wirt fegt vor der Tür, die Wache dreht Runden, Läden haben nachts geschlossen.
- **Monsterverhalten:** Goblins patrouillieren auf Wegen, Fledermäuse hängen an der Höhlendecke und stürzen herab.
- **Wetter:** Nebel; Windgeräusche als weiterer Umgebungsklang.
- **Nebenquests** über ein Anschlagbrett, z. B. „Bring 5 Wolfsfelle“ oder „Finde Gretas verlorenen Ring“.
- **Sammelbares und Verstecke:** geheime Truhen, rissige Wände.

## Zutaten und Handwerk

- **Handwerk:** Felle und Hauer verarbeiten, z. B. Lederrüstung verbessern (heute nur zum Verkaufen).
- **Fleisch an die Wirtin** im Gasthaus verkaufen (heute bei Tilda und Hedda).
- **Kräuter wachsen am Morgen nach** statt schon um Mitternacht (Spielzeit).

## Balance – offene Beobachtungen

- **Kämpfer** erledigt normale Monster auf Stufe 5–6 meist in einer Runde (Zusätzlicher Angriff). Bei Bossen ist er gefordert. Falls störend: nachlegen.
- **Magier** ist gegen Bosse die zerbrechlichste Klasse (Grak auf Stufe 5–6: 44–62 % Siege in der Simulation).
- **Feuerball:** heute einmal pro Kampf mit 8W6. Falls er doch zu stark wirkt, gibt es zwei geprüfte Alternativen: 6W6 oder höhere Kosten (9 ZP).
- Werkzeug zum Prüfen: Kapitelsimulation `SIM=1 ./gradlew -p core test --tests '*ChapterSimTest*'`.

## Sonstiges

- **Rechtliches:** Vor einer Veröffentlichung im Play Store oder einer kommerziellen Nutzung eine kurze Prüfung durch einen Anwalt für Marken- und Urheberrecht.
