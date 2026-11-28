# 1727, Abgleich der Rollendateien (4.5)

Anlass: Chef 20.11., 16:35: „ob wir sichergestellt haben, dass die ganzen Rollendateien … sich wiederfinden in dem neuen Konzept. Weil das stellen wir ja gerade mit Homer fest“. Helfer 16:42, Stand de483a419, gegen `1727-gesamtbild.md` (Profil Story Fassung 3 eingerechnet). Nachgesehen von Sokrates: `add_repo` steht nur als Zuordnung in `1727-sockel.md` 47, nicht im Text (Befund 1 bleibt).

**Keine Bedingung, dass jede Zeile ein Ziel hat** (Chef 20.11., 16:50: „wenn wir feststellen, dass wir das nicht mehr brauchen … werden wir sicherlich kein zwangsweise ein Ziel dafür finden“). Die Liste dient dem Durchsehen: je Punkt ein Wort, übernehmen (wohin) oder „fällt“, ohne Begründungspflicht.

Kurzzeichen: NZ = nur zugeordnet (Tabelle oder Befund, nicht im geschriebenen Text) · F = fehlt · X = fällt.

## Zählung

| Datei | gesamt | im Text | nur zugeordnet | fehlt | fällt |
|---|---|---|---|---|---|
| KREATIV | 31 | 9 | 9 | 6 | 7 |
| BERATUNG | 35 | 13 | 5 | 9 | 8 |
| BERATUNG-START | 29 | 15 | 3 | 7 | 4 |
| BETRIEB | 32 | 11 | 9 | 6 | 6 |
| ENTWICKLUNG | 39 | 11 | 6 | 12 | 10 |
| PROJEKT | 45 | 13 | 7 | 10 | 15 |
| PRUEFUNG | 23 | 8 | 3 | 6 | 6 |
| TECHNIK | 30 | 10 | 7 | 5 | 8 |
| **Summe** | **264** | **90** | **49** | **61** | **64** |

## Querbefunde

1. `add_repo` nicht im Text von Sockel oder Kern (steht in 6 Rollendateien und „Bekannte Fehler“) → Sockel.
2. Profil Technik nicht geschrieben (5.3 Nr. 10); daran hängt fast alles aus TECHNIK und Teile von ENTWICKLUNG.
3. Widerspruch: 0c streicht alle Rollendateien, Kern 2.1 schreibt Lehren nach `ROLLE-BERATUNG.md`, 2.3 verweist auf vertrauliche Links dort.
4. Kern Büro lässt nur nach `main`, was der Chef „gut“ nannte; sperrt Werkzeug nach grünem Lauf (1311).
5. Zeile „Nicht geschrieben“ und Überblickszeile 14 veraltet; offen sind Technik, Werkzeug, Fremde Inhalte, Spieltext einbauen, Büro-Profile (3.2), Rundblick, Tagesbericht, Wache.

## Je Datei (nur NZ und F)

**KREATIV:** Z.25 Muster sofort festschreiben NZ → Kern Büro · Z.31 Ideen sonntags NZ → Kern Sokrates/Routine · Z.33 Leveldesign Draufsicht mit Maßstab NZ → Welt · Z.37 Tippfehler direkt F → Spieltext einbauen · Z.49 `story.sh` NZ → Werkzeug 7 · Z.51 add_repo F · Z.56 Bildvorschlag an der Karte nachrechnen (70.6) F → Welt · Z.57 Chefsache-Bild auf Telegram NZ · Z.58 fremd prüfen auch `DESIGN-STIL.md`, Abnahmeliste NZ → Prüfart Text · Z.60 Aussehensvorschlag nennt Kosten NZ → Kern AV · Z.65 Kult mit weitergegebenem Titel NZ (nur Verweis) · Z.66 Heldenbau 49/50 F → Regeln · Z.67 Absicht und Reaktion füllen den Gegnerzug F → Kampf · Z.68 Dunkel erlaubt Schleichen, Wahl je Höhle F → Welt · Z.72 keine Wegweiser NZ für Welt (Chefwort).

**BERATUNG:** Z.10 Fachberater AD&D/DSA/Descent, weder Grind noch Pen and Paper F → Kern Sokrates · Z.21 fast alles „ja“ heißt zu wenig geprüft F · Z.27 Unsicherheit benennen, Fragen nicht zurückspielen F · Z.30 `DESIGN-BRS.md` im selben Schritt F · Z.37 Läufe nach 621 A NZ · Z.39 Bremse „mehr als zwei zurück“ NZ · Z.44 Lagebild nach Testrückmeldung NZ → Routine Tester · Z.45 vertrauliche Links NZ (Querbefund 3) · L1 Helferbefund erst nach Blick in seine Quelle F · L2 Grundtechnik gegen Alternativen NZ (6b) · L5 Start: Chefsache gegen Archiv F · L6 Sperre und Werkzeug vor dem Befolgen prüfen F · L7 Empfehlung am Ergebnis prüfen, Prüfstufe mit Frist und Wächter F · L9 Gültiges an einen Ort F.

**BERATUNG-START:** Z.20 Chefsache seit Übergabe, Entschiedenes löschen F · Z.25 „Gegengeprüft: <Datei>“ sonst „ungeprüfter Gedanke“ (1732) F → Kern · Z.28 Sperre prüfen F · Z.33 add_repo F · Z.39 BRS mitpflegen F · Z.40 Chefsache-Bild `--bild` NZ · Z.41 Entwürfe als .md, Artefakt nur ausnahmsweise F · Z.55 Schwerpunkt Spieledesigner NZ · Z.59 BornWire 253 NZ · Z.63 Nacht: Lizenz und Accounts im Vorbehalt, Morgenliste F.

**BETRIEB:** Z.29 „Pause bis“ NZ → lauf.py · Z.33 Alter von Anstößen NZ · Z.35 rote Läufe laut NZ · Z.35 `probelauf.py` hält Push bis „Rot:“ F → 7 · Z.39 Doppelstart, nachts nie laut NZ · Z.39 „Ruht die Niederlassung“, Umschichten F → 3.2 · Z.49 Archivieren 1441 NZ · Z.51 add_repo F · Z.55 „wartet auf“ leeren NZ · Z.56 RUNNING = working F · Z.57 Kosten idle über 60 s, total_cost_usd F → lauf.py/3.2 · Z.58 Archivregel im Einzelnen NZ · Z.60 15-Minuten-Schutz NZ · Z.61 erst ohne, dann mit `--sperre` F.

**ENTWICKLUNG:** Z.11 Prüfzeile Schritt/passt/falsch NZ → Testbitte · Z.25 „Vor jeder Vorlage“ (461) F → Figur/Abnahme · Z.29 Kleines im Bereich selbst entscheiden F · Z.29 Warten ist kein Zugende F → Technik · Z.31 Alt zuerst, Zeile „Alt:“ F → Kern AV, 7 · Z.31 großes Vorhaben 1236 NZ · Z.33 Bestand vor Modell, Bewegung, Textur F → Figur · Z.33 Kaufrepo, „ruht, wartet auf Kaufrepo“ F · Z.33 „Bestand geprüft:“ F · Z.33 Bestand → Netz → Kaufvorschlag → Eigenbau, drehender Film F → Fremde Inhalte · Z.39 große Dateien nur beim Anfassen zerlegen F → Technik · Z.45 Testbitte je Punkt mit Art NZ · Z.49 21–7 Uhr nur Technik F → lauf.py · Z.49 PROBE=, probelauf NZ · Z.49 Headless-Test ist kein Probelauf (390a) F → Technik · Z.58 `check-env.sh` NZ · Z.59 Ford muss laufen NZ · Z.61 `LISTE-FIGUREN.md` vor jeder Figur F → Figur.

**PROJEKT:** Z.11 Regelbilanz F → Kern Sokrates · Z.30 Werkzeug reparieren statt neuer Regel F · Z.38 Reifes holen NZ · Z.39 höchstens drei Empfehlungen NZ · Z.44 Guthaben, Abos, Sparvorschläge NZ · Z.46 Werkzeug ist Kür, höchstens 100 Commits je Woche F → 6d · Z.46 Doppelpack NZ · Z.47 Tagesbericht NZ · Z.72 add_repo F · Z.74 Ford muss laufen NZ · Z.83 ein Text an einem Ort F · Z.85 Doppelstart sperren NZ · Z.92 Abhängigkeit erst mit letztem Nutzer entfernen F → Technik · Z.94 Regelzeile nur an der genannten Stelle ändern F · Z.98 `git clone` statt `cp -r` F → Technik · Z.106 Umbau von der alten Datei aus, jede Übernahme dreifach prüfen F → Kern Sokrates · Z.108 Last auf alle Entwickler verteilen F → Kern Büro.

**PRUEFUNG:** Z.29 Kontaktblatt messen, nicht den Film (368) F → Prüfer · Z.30 Helligkeit gegen Stimmung, Schattenrichtung F → Welt/Prüfer · Z.31 Flimmern, Verdecken, Rückseiten texturiert F → Welt/Figur · Z.32 „gemessen“ im Bestand F · Z.33 Stichprobe 373 NZ · Z.34 `main` vor Release NZ · Z.34 `regelcheck.py --anlass` F → 7 · Z.34 Regeländerung gegen Wortlaut des Chefs NZ · Z.51 add_repo F.

**TECHNIK:** Z.13 Guru-Profil, Nein auch zu Teams NZ · Z.13 vorberechnete Dateien NZ · Z.18 Sammelbuild, Prüfliste NZ · Z.18 unter 4 Handypunkten keine APK (1524) F → lauf.py · Z.19 Cache nach Bauskript-Merge (1666) NZ · Z.19 Laufzeit in der Testbitte F · Z.20 A56 als Maß, Tablet Untergrenze NZ · Z.20 Werkzeug ist Kür F · Z.24 Startlisten NZ · Z.31 Werkzeug sofort nach `main` (1311) F · Z.31 eine Probe, Sokrates gibt frei NZ · Z.47 Bauzeit unter 25 min, Cache-Treffer F → 6d/Technik.
