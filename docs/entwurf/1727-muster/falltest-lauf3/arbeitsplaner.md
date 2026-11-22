# Antworten Arbeitsplaner (Falltest Lauf 3, 07:18)

Ladetext: `lt3/sockel.md`, `lt3/kern-buero.md`, `lt3/kern-arbeitsplaner.md`. Repo nur gelesen; alle Schreibbefehle unten sind beschrieben, nicht ausgeführt. Gelesen: `vorgang.py 1694 1535 1727 299 235 535 1417 1515`, `vorgang.py auftrag 1694` (Vorlage), Git der Zweige `claude/spike-1694-griff`, `claude/tom-1535-gruss`, Prüfliste t299 aus Git (`119836f71`), `tools/auftrag.py`, `tools/rueckmeldung.py`. Die Vorgangsdateien `docs/vorgang/1694.md`, `1535.md`, `1727.md` gibt es auf `main` nicht (nur `1789.md`); gelesen habe ich stattdessen Liste, Vorräte, Archiv und die Muster `docs/entwurf/1727-muster/vorgang/1694.md`, `1535.md`.

Gemeinsamer Ablauf je Fall: `python3 tools/vorgang.py offen Arbeitsplaner` (heute: „0 Zeile(n) an Arbeitsplaner“; im Fall stünde die Zeile aus dem Chefwort-Haken da, Kennung hier `<Nr>-Ü<k>`), `python3 tools/vorgang.py annehmen <Nr>-Ü<k> --frist 60`, lesen, Auftrag schreiben, `python3 tools/vorgang.py auftrag <Nr> --datei <Pfad> --pruefen`, bei „gültig“ ohne `--pruefen` eintragen, Rückmeldung, `python3 tools/vorgang.py erledigt <Nr>-Ü<k>`.

## A1 · 1694 Griff in der Faust für alle (Chefwort 18.11., 17:01)

Gelesen und gefunden:
- Chefwort steht wörtlich in der Liste und im Vorrat (Haken hat es eingetragen; fehlte es: `python3 tools/vorgang.py chefwort 1694 "Als Systemlösung, genau. Jetzt sind wir nämlich wieder mal so weit damit, dass wir Sachzusammenhänge erkennen und deswegen auch Lösungen suchen und nicht ständig einzeln rumflicken." --zeit "18.11., 17:01"`).
- Frühere Nein des Chefs: 17:38 „Ja, also die Hand ist geschlossen und die Außenknöchel liegen an der Waffe an, aber der Stiel liegt nicht in der geschlossenen Hand. Also fail. Sorry. Wieder daneben.“; 21:37 „1694 ist nix zu erkennen...“ (Bild ohne Beschriftung, Waffe schwarz, nur Nahsicht). 19.11., 07:45 nicht vorgelegt (Prüfung −0,1 cm, Bild: Stiel quer über dem Fingerrücken).
- Git: `claude/spike-1694-griff` an `7c7ce0f02` (Übergabe `04bf8ffc1`, 19.11., 11:17): `griff_alle_1694` 752 von 1540 Paaren rot; Gruppen laut Spike: 14 Staffelwaffen (Stiel 5–7 cm), Bögen/Armbrüste/scimitar/staff (Griffpunkt), Zombies 54/55 (Hand mit zwei Fingern), Rest 14–39 je Körper. Ursache je Gruppe nicht belegt → nach Feld 3 Nachstellen und Beheben in einem Auftrag.
- Stieldicke der Staffel ist laut Spike „Aussehen der Waffe, Chefsache mit Bild“ → nicht meins (Kern: „Nicht deins: … Aussehen“), darum zusätzlich „Frage“.

Auftrag: `A1.auftrag.md` (dieser Ordner). Prüfung:

```
$ python3 tools/vorgang.py auftrag 1694 --datei docs/entwurf/1727-muster/falltest-lauf3/A1.auftrag.md --pruefen
vorgang.py auftrag 1694: gültig (2032 Byte)
Exit 0
```

Dann (nicht ausgeführt):
```
python3 tools/vorgang.py auftrag 1694 --datei docs/entwurf/1727-muster/falltest-lauf3/A1.auftrag.md
python3 tools/vorgang.py rueckmeldung 1694 "Auftrag steht 1694 (Griff in der Faust für alle Figuren und Gegenstände): Systemlösung über alle 1540 Paare, Ursache je Fehlergruppe nachstellen und beheben in einem Auftrag, dann genau ein Bild alt gegen neu; Zweig claude/spike-1694-griff an 7c7ce0f02." --sitzung Arbeitsplaner
python3 tools/vorgang.py rueckmeldung 1694 "Frage 1694 (Griff in der Faust für alle): 14 Staffelwaffen scheitern an jedem Körper, weil der Stiel im Modell 5–7 cm dick ist (Spike 19.11., 11:17, 04bf8ffc1). Stieldicke ist Aussehen: zwei bis drei Varianten als Bild zur Wahl des Chefs, oder bleiben sie bis dahin aus der Prüfung? Der Auftrag lässt sie unverändert und nennt sie. Dazu: 1694 steht noch auf „ruht, bis Sa 21.11.“, der Tag ist vorbei; Lauffreigabe ist nicht meine." --sitzung Arbeitsplaner
python3 tools/vorgang.py erledigt 1694-Ü<k>
```

## A3 · Build 299, Prüfpunkte ausarbeiten

Gelesen: Prüfliste t299 in Git (`119836f71`): dort waren 299.1 (1417) und 299.2 (1515) schon Bild, nicht Handy; 299.3 war dort 1535 (Kleidung), nicht der Wolf.
- 299.1 und 299.2 „Handy“: ein Bild reicht (Hauptmenü in Handygröße, alt gegen neu), also Bild; Ziel aus 1417 (Chef 16.11., 12:37) und 1515 (Chef 17.11., 07:32).
- 299.3 „Kampf gegen den Wolf, Ausweichen nach links antippen“: kein Vorgang, kein Ziel, keine Herkunft genannt; ob es um die Bewegung (Film) oder um das Antippen auf dem Gerät (Handy mit „warum nicht Bild“) geht, wäre eigene Auslegung. Darum „Frage“; der Auftrag wird erst mit der Antwort eingetragen.
- Feld 7 trägt `<Nr>`: ein Build hat keine Vorgangsnummer (`vorgang.py auftrag 299` → „299 steht nicht in der Vorgangsliste“). Auch das ist Teil der Frage.

Auftrag (Entwurf, nicht eintragbar, solange 299.3 und die Nummer offen sind): `A3.auftrag.md`. Prüfung:

```
$ python3 tools/vorgang.py auftrag 299 --datei docs/entwurf/1727-muster/falltest-lauf3/A3.auftrag.md --pruefen
vorgang.py auftrag: 299 steht nicht in der Vorgangsliste
Exit 1
$ python3 tools/vorgang.py auftrag 1694 --datei docs/entwurf/1727-muster/falltest-lauf3/A3.auftrag.md --pruefen
vorgang.py auftrag 1694: gültig (1857 Byte)
Exit 0
```

(„gültig“, obwohl Feld 1 sagt, dass ein Ziel fehlt, und Feld 7 `<Nr>` enthält; siehe Lücken.)

Rückmeldung (nicht ausgeführt; Nummer: der Vorgang, unter dem die Zeile an mich kam, hier `<Nr>`):
```
python3 tools/vorgang.py rueckmeldung <Nr> "Frage zu Build 299 (Schild der Wachsoldatin, Fläche vor dem Schild, Wolf ausweichen): 299.1 und 299.2 werden Bild statt Handy (ein Bild Hauptmenü in Handygröße, alt Build 297 gegen neu, Ziel aus 1417 und 1515). 299.3 „Kampf gegen den Wolf, Ausweichen nach links antippen“: zu welchem Vorgang, was soll der Chef sehen, was ist falsch? Geht es um die Bewegung (dann Film von der Seite) oder um das Antippen auf dem Gerät (dann Handy)? Unter welcher Vorgangsnummer steht der Build-Auftrag?" --sitzung Arbeitsplaner
```
Die Zeile an mich bleibt angenommen, bis die Antwort da ist (`vorgang.py verlaengern <Nr>-Ü<k> --frist 60`).

## A5 · 1727, Chefwort aus der Spracherkennung (21.11., 15:15)

Gelesen: Wortlaut in 1727 „Ja, soweit alles klar. Profiltechnik-Jahr zu 535 Jahren“. Die Vorlage nannte Profil Technik und 235. `vorgang.py 535`: eigener Vorgang „Kampf: Gegnerstufe, Elite …“ (E Kampf, erledigt); 235 (B Werkzeuge): „Wer die Freigabe des Chefs hört, führt den PR selbst zusammen“. Im Vorgangsarchiv steht 21.11., 15:15 die Lesart von Sokrates „Profil Technik ja, zu 235 ja“ mit Vermerk [Spracherkennung …] (Commit `ed0b1fcdc`, 15:16).

Was ich tue: kein Auftrag. Der Wortlaut bleibt unverändert in der Vorgangsdatei, ich schreibe keine Lesart dazu (Kern Büro: „nie umformuliert“). Ein Bau für die Werkstatt ist darin nicht genannt; die Folgen (Profil Technik F12, Build-Kette in die Checkliste) sind Texte der Leitung. Unklar ist das Wort selbst → Sockel 3: anhalten, Frage.

```
python3 tools/vorgang.py rueckmeldung 1727 "Frage 1727 (Neuordnung der Arbeit, Kerne und Profile): Chefwort 21.11., 15:15 aus der Spracherkennung „Ja, soweit alles klar. Profiltechnik-Jahr zu 535 Jahren“ ist nicht eindeutig: die Vorlage nannte Profil Technik und 235, 535 ist ein eigener Vorgang (Kampf: Gegnerstufe, erledigt). Die Lesart „Profil Technik ja, zu 235 ja“ im Archiv ist von Sokrates, nicht der Wortlaut. Bitte vom Chef bestätigen lassen. Einen Werkstatt-Auftrag lege ich nicht an: das Chefwort nennt nichts zu bauen." --sitzung Arbeitsplaner
python3 tools/vorgang.py erledigt 1727-Ü<k>
```

Stärkstes Gegenargument: Sokrates hat die Lesart am selben Tag belegt eingetragen, der Chef hat ihr seitdem nicht widersprochen; eine Frage kostet nur einen Satz bei Sokrates. Ich frage trotzdem, weil 535 ein echter Vorgang ist und mein Ladetext keine Lesart von mir erlaubt.

## A7 · 1535 Kleidung bei gehobenem Arm (Garrick und Kittel)

Gelesen: Chefworte „299.3 ✗“, 15:33 „zieht sich da auch wieder irgendwas von der Jacke“, 15:59 „Das sieht man ja die Beule direkt“; Bisher `7ffa715`, Gewichte am Rumpf, kein sichtbarer Unterschied; Ursache unbekannt → Nachstellen, rot zeigen, Ursache belegen, beheben, in einem Auftrag. Bewohner im Kittel heißt in Git Bram (`1896bc91c`).

Fund in Git (zurückmelden, nicht beheben): `7ffa715` ist `7ffa71528` „431 Tuch letzter Lauf“ (15.11., Zweig `claude/tom-431-umhang`), kein 1535-Commit; die Rumpfregel steht in `547033f9f` (18.11., 16:25, `claude/tom-1535-gruss`). Darum nennt der Auftrag als „alt“ den Stand von Build 299, nicht den Commit. Außerdem: laut Archiv ist 1535 am 21.11., 21:40 gebilligt (`bfd783a3c`); ich behandle den Fall wie gestellt.

Auftrag: `A7.auftrag.md`. Prüfung (erster Entwurf zu groß, gekürzt):

```
$ python3 tools/vorgang.py auftrag 1535 --datei docs/entwurf/1727-muster/falltest-lauf3/A7.auftrag.md --pruefen
vorgang.py auftrag 1535 hält an:
- 2146 Byte, höchstens 2048 (Bauliste 7.1 „etwa 2 KB“)
Exit 1
$ python3 tools/vorgang.py auftrag 1535 --datei docs/entwurf/1727-muster/falltest-lauf3/A7.auftrag.md --pruefen
vorgang.py auftrag 1535 hält an:
- 2079 Byte, höchstens 2048 (Bauliste 7.1 „etwa 2 KB“)
Exit 1
$ python3 tools/vorgang.py auftrag 1535 --datei docs/entwurf/1727-muster/falltest-lauf3/A7.auftrag.md --pruefen
vorgang.py auftrag 1535: gültig (2016 Byte)
Exit 0
```

Dann (nicht ausgeführt):
```
python3 tools/vorgang.py auftrag 1535 --datei docs/entwurf/1727-muster/falltest-lauf3/A7.auftrag.md
python3 tools/vorgang.py rueckmeldung 1535 "Auftrag steht 1535 (Kleidung bei gehobenem Arm, Garrick und Kittel): Ursache an Garrick und Bram nachstellen, mit Prüfung rot am Stand von Build 299, beheben, Prüfung über alle Figuren mit Kaufkleid, dann genau ein Bild alt gegen neu. Fund: Bisher-Commit 7ffa715 ist in Git 431 Tuch (7ffa71528), die Rumpfregel steht in 547033f9f; der Auftrag nimmt Build 299 als alt." --sitzung Arbeitsplaner
python3 tools/vorgang.py erledigt 1535-Ü<k>
```

## Lücken

1. **Ort des Auftrags.** Kern: „**Der Auftrag** (oben in die Vorgangsdatei …)“; `tools/auftrag.py` hängt ihn hinten an: „`alt + kopf + … "## Auftrag (%s)\n\n%s\n%s"`“.
2. **Feldname 6.** Kern: „6. **Prüfart:**“; Werkzeug verlangt „Prüfart und Prüfe vor dem Senden“ (`FELDER`), sonst „Feld 6 … fehlt“. Feld 2 im Werkzeug „Pflicht bei Bezügen“, im Kern nicht.
3. **Pfad des Profils.** Kern: „höchstens fünf Punkte und der Pfad des Profils“, nennt aber keinen Pfad. Profil Figur, Profil Technik, Querprofil Signatur und Leben gibt es nur als Entwurf unter `docs/entwurf/1727-muster/` (alt: `docs/LISTE-HANDWERK-FIGUR-PRUEFBILD.md`); keins liegt in `lt3/`. Ich habe die Entwurfspfade genommen.
4. **2 KB gegen Pflichtinhalt.** Kern verlangt jedes frühere Nein „wörtlich unter ‚Bisher‘“, dazu Systemfrage mit Quelle, Beleg-Form und 3–5 Fragen; das Werkzeug hält über 2048 Byte an. A1 2032 Byte nur mit gekürzten Zitaten („…“), A7 brauchte zwei Kürzungen. Das ganze Nein von 17:38 passt nicht hinein.
5. **„Auftrag steht“ geht nirgends hin.** Kern: „erstes Wort ‚Auftrag steht‘ oder ‚Frage‘“; `rueckmeldung.py` kennt es nicht: „eingetragen, kein Signalwort zum Weitergeben“. Wer die Fachkraft startet, sagt mein Ladetext nicht (nur `lauf.py` prüft `auftrag_fehlt`). `annehmen`, `erledigt`, `verlaengern` für meine eigene Zeile stehen nicht im Ladetext.
6. **Build-Auftrag ohne Nummer.** Kern: „Meldungen über `vorgang.py rueckmeldung <Nr>`“; ein Build hat keine: „vorgang.py auftrag: 299 steht nicht in der Vorgangsliste“.
7. **Prüfung prüft nur Form.** A3 ist „gültig (1857 Byte)“, obwohl Feld 1 „Ziel und Herkunft fehlen“ sagt und Feld 7 `<Nr>` trägt; „ohne Rückfrage bauen“ prüft das Werkzeug nicht.
8. **Kein Ausgang „kein Auftrag nötig“.** Kern kennt nur „Auftrag steht“ oder „Frage“; bei A5 (Freigabe auf eine Vorlage der Leitung, nichts zu bauen) bleibt nur „Frage“.
9. **Spracherkennung.** Kern Büro: „Chefworte wörtlich … nie umformuliert“; was bei unlesbarem Wortlaut gilt, sagt er nicht (ich nehme Sockel 3: „Ist der Auftrag unklar …: anhalten, Frage“).
10. **Aussehen in der Ursache.** Kern: „liegt die Ursache außerhalb des Ziels: ‚Frage‘“ und „Nicht deins: … Aussehen … zwei bis drei Varianten zur Wahl des Chefs“. Bei der Stieldicke (A1) passt beides; ob die Varianten in den Auftrag gehören oder nur als Frage, bleibt offen.
11. **Lauf, Kosten, Deckel.** 1694 steht „ruht, bis Sa 21.11.“ (Guthaben), 33,37 $, Archiv „scheitert er, kein zweiter“; der Kern sagt nicht, ob ein Auftrag eine Lauffreigabe oder einen Deckel braucht und wer ihn ins Feld schreibt.
12. **Neins der Bezugsvorgänge.** „Jedes frühere Nein des Chefs oder Prüfers … wird eine Prüffrage“: gilt das auch für die Neins der Bezüge (1621 16:50, 1657 16:56)? Ich habe sie als eine Frage zusammengefasst.
13. **Vorgangsdatei fehlt.** „Lies zuerst die Vorgangsdatei (`docs/vorgang/<Nr>.md`)“: auf `main` gibt es für 1694, 1535 und 1727 keine; was dann gilt, sagt der Ladetext nicht.
14. **Lehrenbuch.** `vorgang.py auftrag 1694` gibt „Lehren des Bereichs … passende in ‚Beachte‘ und ‚Umsetzen‘, höchstens fünf“ aus (heute „keine“); der Kern Arbeitsplaner erwähnt das Lehrenbuch nicht.
