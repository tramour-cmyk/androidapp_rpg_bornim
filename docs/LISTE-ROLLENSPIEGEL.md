# Rollenspiegel

Ist-Soll-Abgleich jeder Rolle (340, Chef 23.10., 09:46). **Wann:** mittwochs nach dem Tagesbericht am Ende einer Sitzung (1461, Chef 16.11., 16:27; erste Runde 18.11.), beim ersten Mal sofort. **Wie:** nur über `tools/rollenspiegel.sh <Rolle>` (zeigt Fragen und eigene Vorwochenantwort; `--antwort <datei>` hängt an), diese Datei nie selbst öffnen (340.2). Jede Antwort höchstens zwei Sätze mit Beleg (Vorgangsnummer, Commit oder Zitat); „nichts“ nur mit Begründung. Sokrates wertet aus (drei Muster, drei Vorschläge), der Chef entscheidet. Aus jedem Durchgang höchstens **eine Änderung je Rolle**: als Vorgang mit erwarteter Zahl und Prüfdatum, möglichst als Werkzeug, sonst als Startfrage, zuletzt als Satz; für jede neue Regel fällt eine alte weg. In der Datei bleiben die letzten zwei Wochen, ältere stehen in Git.

## Fragen

0. Was hast du letzte Woche angekündigt, und ist es geschehen? (Zahl)
1. Lies deine Rollendatei: Welche Pflicht hast du nicht oder nur halb erfüllt?
3. Deine Kennzahl: Ziel, Ist, und was du dafür getan hast. Hast du keine: Schlag ein Ziel vor, das jemand anderes messen kann (Muster: Zielvereinbarung Perikles, 341; ab 06.11. für alle Rollen).
4. Was hast du dem Chef vorgelegt? Konnte er damit fundiert entscheiden (Wege, Kosten, Gegenargument, fremd geprüft)? Was fehlte?
5. Welches Ergebnis würde der Chef zurückweisen, wenn er genau hinsieht, oder was hast du ungeprüft als fertig gemeldet?
6. Was ginge besser oder lief bei einer anderen Rolle schief, und du hast es nicht gemeldet? Warum nicht?
7. Wer hat auf dich gewartet, auf wen hast du gewartet? Was hätte das verkürzt?
8. Was hat am meisten gekostet und am wenigsten gebracht?
9. Welche Regel war unklar, welche würdest du streichen, welche fehlt?
10. Wärst du ein Mensch in einer Firma: Rauswurf, ernste Ansage oder Lob? Ein Satz, warum. Dann höchstens drei Schritte zur Besserung. Keinen davon beginnen, bevor der Chef Ja sagt.
11. Vorschlag fürs Spiel: Lies `DESIGN-LEITBILD.md` und die Abnahmeliste, schau auf deine letzten Tage: genau ein Vorschlag, wie Kapitel 1 besser wird (Inhalt, Technik, Grafik, Klang, Kampf, Bedienung, auch außerhalb deines Fachs), mit Auslöser aus den letzten Tagen (Beleg), Leitbildsatz oder Abnahmepunkt, grobem Aufwand, stärkstem Gegenargument; nicht schon in `LISTE-IDEEN.md`. (Ersetzt Frage 2, 1461; das Werkzeug trägt die Antwort in `LISTE-IDEEN.md` ein.)

## Änderungen

| Nr. | Rolle | Änderung | erwartet | Prüfdatum | gewirkt |
|---|---|---|---|---|---|
| 340.3 | alle | A: Hinweise von `notiz.sh` schreibt das Werkzeug täglich in den Vorrat des Besitzers | Hinweise 8 → höchstens 2 | Mo 09.11. | nein: 4 (Diogenes 09.11., Prüfbericht Lauf 92) |
| 340.4 | alle | B: Pflichtzeile „Geprüft an: <Link>“ in Chefsache und bei „gebaut“ | höchstens 2 Runden je Aussehensfrage bis „passt“ | Mo 09.11. | fehlt (Runden nicht gezählt); Zeile da in 76 von 80 Vorlagen |
| 340.5 | alle | C: „Uhr: HH:MM“ nach jedem Arbeitsschritt | 0 falsche Zeitstempel in der Woche | Mo 09.11. | nein: 8 von 201 daneben (`LISTE-REGELTREUE.md`) |
| 340.7 | Perikles, Diogenes | V1: Werkzeug ohne Fund des Chefs ist Kür; Doppelprüfung nur für Regeln mehrerer Rollen | ≤ 100 Werkzeug-Commits Perikles je Woche; Diogenes ≥ ⅓ im Spiel | Mo 23.11. | – |
| 340.8 | Tom, Jerry | V2: Tests vor Push und Filmlauf bis zum Ende; Filmtests nach Bildern | 0 rote Läufe, 0 Filmläufe ohne Film aus eigenen Testfehlern | Mo 23.11. | – |
| 340.9, 340.11 | Sokrates, Homer | V3: Vorlage gegen Muster und Archiv; Wahl gegen Knopf; Auswertung am Tag der Runde | ≤ 2 Fehler 341 je Woche; keine Vorlage über 2 Runden | Mo 23.11. | – |
| 340.10 | Ford | V4: Spiegelzeilen, Betriebskosten, 60 s vor Archivieren im Werkzeug | Nacharbeiten je Nacht 0 | Mo 23.11. | – |

## Woche 13.11.

### Diogenes (13.11., 00:10, Sitzung „Diogenes – 1087: Prüfliste (13.11., 00:05)“)

0. Angekündigt 02.11. (485): (a) Wochentermine „gelaufen ja/nein“ zählen, (b) Vergleichsbilder 348.9 selbst holen, (c) Meldungen ohne Abkürzungen; geschehen 3 von 3 (Zeile „Wochentermine gelaufen“ in der Wochenzählung 09.11.; 67 Bilder geholt 09.11., keins zu messen; seit 02.11. keine Rückfrage des Chefs zu einer Abkürzung von mir gefunden).
1. Halb erfüllt: Zu 838 zählte meine Stichprobe „Sitzung da“ als erfüllt, obwohl Tom und Jerry nach dem Start untätig standen (Chef 10.11., 12:07 „komisch“). Nicht erfüllt: die Wochenzählung 09.11. ließ 4 Felder „fehlt“ oder „nicht zählbar“ (Empfehlungen Sokrates, 340.4, Warnungen Handänderung D92.1).
2. Etwa 5 % Spiel, 95 % Abläufe: von 89 Läufen seit 06.11. (Lauf 92 bis 188) waren 55 Doppelpacks mit Perikles und rund 30 Werkzeugvorgänge Bereich B; Spielnah nur Lauf 152 (Erstfunde t272–t275) und heute 188 (Prüfliste im Spiel). Falsch gewichtet gegen die oberste Direktive, aber so beauftragt (421, 724).
3. Z3 (in meinem Bereich höchstens 1 Erstfund des Chefs je Woche, 485): Ist 1 (838, s. 1). Ze Verwerfquote: 0 verworfen unter den Befunden D92 bis D187 (Vorgangsliste, Archiv); Z4: kein eigener Vorschlag diese Woche angenommen, der nicht ein Befund war.
4. Vorgelegt: Lauf 152 (Probe 657, an Perikles 903 und den Chef) mit beiden Maßen je Build und „nicht geprüft: Ursache des Rückgangs“; entscheidbar, aber ohne Gegenargument zur Zählweise. Sonst Prüfberichte je Doppelpack, die der Chef nicht entscheiden muss.
5. Die Doppelpacks prüfen Werkzeuge an Probeeingaben in Kopien, nicht im echten Ablauf; die offenen „beim nächsten echten Lauf“-Zeilen (927, 940, 696, 981/982, 1019) zeigen, dass bei etwa 10 Vorgängen die Wirkung im Betrieb noch ungesehen ist. 1087 heute: greift am Rechner, im Reiter Test erst ab nächstem Build gesehen.
6. Nichts verschwiegen gefunden; die Vorräte Betrieb (52 KB), Jerry (25 KB), Tom (16 KB) liegen über der Grenze, das zeigt `notiz.sh` jedem Besitzer bei jedem Start selbst, deshalb kein eigener Vorgang.
7. Auf mich wartete Perikles bei jedem Doppelpack (meist unter 20 Minuten, z. B. 1076 gebaut 20:58, geprüft 21:0x); ich wartete auf echte Läufe für die „beim nächsten Mal“-Zeilen. Verkürzt hätte es eine Stichprobe aus dem Protokoll in der Wochenzählung statt je Zeile einzeln zu warten.
8. Am meisten gekostet bei wenig Nutzen: die Doppelpacks zu kleinen Wortänderungen von Perikles (z. B. 879 Nachfolger-Strich, 893 bedingter Nachfolger), je ein Start mit vollem Lesen für einen Befund „greift“.
9. Unklar: „ein Lauf je Sitzung“ gegen 55 Doppelpacks der Woche. Fehlt: eine Schwelle, ab der eine Ablaufänderung den Doppelpack braucht; streichen: weiter die ruhende Zeile 186.3 (seit 20.10. ohne Bögen).
10. Ernste Ansage: die Befunde halten (0 verworfen), aber fast die ganze Woche ging in Abläufe statt ins Spiel, und der Fehler 838 lag in meiner eigenen Stichprobe. Schritte (erst nach Ja des Chefs): (a) Doppelpack nur für Änderungen an Regeln, die mehrere Rollen binden, Rest sammelt die Wochenzählung; (b) je Build mit Prüfliste ein Lauf am Rechner gegen die Prüfliste vor dem Gerätetest.

### Homer (13.11., 00:10, Sitzung „Homer – 1088: Osric Verbände (13.11., 00:05)“)

0. Angekündigt waren drei Schritte; geschehen sind alle drei (Commit 02.11. „486 Rollenspiegel-Schritte“): Fremdprüfung vor „fertig“ seither bei 1085, 1074, 1088 und 986; Vorratsgrenzen gemeldet am 09.11. (716); Stiltext zeigt auf Godot, aber `DESIGN-STIL.md` nennt noch 5 Kotlin-Stellen (`MapSheet`, `.kt`). Ergebnis 2½ von 3.
1. Halb erfüllt: „Fertiges Muster festschreiben“ (Kotlin-Reste in `DESIGN-STIL.md`, siehe 0) und Sonntag 08.11. ohne Ideenspeicher, der kam erst am 09.11. (716).
2. Etwa 25 % Chef (432a, 807a, 830, 348.12g), 70 % Teams und Sokrates (1008, 1015, 1026, 1047, 1057, 1067, 1069, 1074, 1085, 1088, 986), 5 % Betrieb; das ist richtig so, weil Kapitel 1 jetzt an Texten für gebaute Fertigkeiten hängt.
3. Ze (kein Team wartet über 1 Tag): Ist 0, Vorgänge „an Homer“ am selben Tag erledigt (z. B. 1057 an Homer 16:58, fertig vor 18:42; 1088 vergeben 00:02, fertig 00:09). Z3: keine Zeile „Fehler 341“ im Vorrat; Z4: 432a A und 807a A mit Votum Homer (Vorgangsarchiv 10.11.).
4. Vorgelegt habe ich 432a (Aschgeborene) und Voten zu 807, 807a, 830, 975a; Wege, Gegenargument und Fremdprüfung waren dabei. Zu `[830.sprung]` steht mein Änderungsvorschlag seit 11.11. nur als Telegram-Zeile, ohne Chefsache-Datei, gilt also nach Regel 8 nicht als Rückfrage.
5. Zurückweisen könnte der Chef `[504.osric.verband]`, weil der Satz ohne Bild im Kasten in den Build geht (Gegenargument Sokrates in 842). Ungeprüft als fertig gemeldet habe ich diese Woche nichts, die Fremdprüfung zu 1088 fand fünf Punkte („Gabe“ bei festem Preis 8, „bleed out“).
6. Nicht gemeldet: `ARBEIT-BETRIEB.md` 52 KB, `ARBEIT-TEAM-JERRY.md` 25 KB, `ARBEIT-TEAM-TOM.md` 16 KB (`notiz.sh` 13.11.); das ist meine Sonntagspflicht, ich trage es am 15.11. ein.
7. Auf mich gewartet hat nur Tom auf 1088 (7 Minuten), auf den Chef warte ich bei `[830.sprung]`; mit einer Chefsache-Datei statt der Telegram-Zeile wäre das entschieden.
8. Am meisten gekostet und am wenigsten gebracht hat 842 mit zwei Runden (Chef 20:48 „nö, passt nicht“): der zweite Knopf `[1074.zweit]` und Osrics Angebotssatz `[504.osric.verband]` hätten im ersten Text zu 807a stehen müssen, weil ich die Wahl im Gespräch nicht gegen den Knopfbaustein im Code gelesen habe.
9. Unklar ist, ob ein Wochentermin wie 766 (08:00) in einer Nachtsitzung vor der Uhrzeit erledigt werden darf; die Commit-Prüfung sperrt schon eine Uhrzeit nach jetzt im Nachfolger. Streichen würde ich nichts; fehlen würde ein Prüfschritt „Wahl im Gespräch hat zwei Knöpfe und sagt, was sie bietet“ in `STORY-REGELN.md`.
10. Lob mit Vorbehalt: kein Team wartet, Fremdprüfung sitzt, aber 842 kam zweimal zum Chef zurück, weil meine Texte den Knopf nicht mitdachten. Schritte: (a) jede Wahl im Gespräch gegen `skript.gd` lesen, bevor der Text fertig ist; (b) `[830.sprung]` als Chefsache-Datei stellen; (c) Kotlin-Stellen in `DESIGN-STIL.md` auf Godot umstellen.

### Team Jerry (13.11., 00:28, Sitzung „Jerry – 1043: Ausweichen-Film (12.11., 22:04)“)

0. Angekündigt (02.11.) drei Schritte: (a) Messung durch die Spielkamera, (b) Ursache zuerst am Rechner, (c) „ohne Befund“ nur nach Prüferbild. (b) heute gemacht (Seed 7 nachgestellt, 338458c53), (a) halb: 1043 maß Fuß und Kopf, am Rechner ohne Bild aber 0 px; 2 von 3 halb, 1 ganz.
1. Halb: „vor dem Lauf am Rechner prüfen, dass ein Wolf den Helden angreift“ (Sokrates 22:03) habe ich nur ohne Bild und ohne Seed 7 geprüft; Lauf 404 brach darum an einer Zeitgrenze ab, die nur im Filmmodus greift.
2. Etwa 85 % Chef (1043, 833, 1039-Umfeld), 10 % Betrieb (Vorrat, Stände), 5 % andere Rollen; richtig so.
3. Rückläufer, Ziel 0: in dieser Sitzung keiner neu; 1043 hat drei Filmläufe ohne Film verbraucht (389, 396, 404), alle wegen Fehlern in meiner Testschleife.
4. Vorgelegt 1043a (Wege A/B/C mit Kosten und Gegenargument, an Sokrates nach 1077); nicht fremd gegengelesen, weil nachts nur Sokrates da war und er selbst entscheidet.
5. Zurückweisen würde der Chef: drei Läufe für einen Film, den er nie gesehen hat (1043); der Testfehler war jedes Mal meiner.
6. Nichts verschwiegen; add_repo bornim-kaufmodelle wurde in dieser Sitzung abgelehnt, im Chat gemeldet; wald_490 rot in Lauf 404 als fremd zu 1018 (Tom) vermerkt.
7. Der Chef wartet auf den Ausweichfilm seit 12.11., 15:52; ich warte auf 1043a (Sokrates). Kürzer: Filmschleifen nach Bildern statt Uhrzeit messen, mit dem Seed des Bauservers am Rechner nachstellen.
8. Lauf 404 (über 80 Minuten, Kauf-Cache verfehlt) für 32 s Film ohne Ausweichen.
9. Fehlt: „Jeder Filmtest begrenzt nach Bildern, nie nach Uhrzeit (--write-movie läuft langsamer als Echtzeit)“; streichen würde ich nichts.
10. Ernste Ansage: dreimal derselbe Fehlertyp (Testschleife, nicht Spiel) kostet Läufe und Chefzeit. Schritte: (a) Filmtests am Rechner mit Seed und FILM=1 ohne Bild bis zum Ende durchlaufen lassen, (b) Grenzen nach Bildern, (c) Prüfzeile im Test, die abbricht, wenn der Prüfgegenstand nicht vorkam.

### Sokrates (13.11., 00:32, Sitzung „Sokrates – 1077: Nachtführung und Chefrunde Build 281 (13.11., 00:29)“)

0. Angekündigt 02.11.: (a) Wächter für Chefsache-Dateien mit Archiv-Entscheid, (b) Rückmeldung zuerst im Chat, (c) Vorgänger lesen; geschehen 2 von 3: (a) steht als Commit-Prüfung und „Lücken“ (Chefsache-README 383.3), (b) gilt; (c) brach am 12.11., 18:27 (Haarfarbe erneut gefragt, Fehler 341 18:29).
1. Halb erfüllt: „Beraten heißt ergänzen“ und „Vorlage zuerst gegen das gebilligte Muster“: 867 zweimal mit A empfohlen gegen Muster 292.3 (12.11., 21:40), 1051 nur gegen Kapitel 1 statt gegen die Kapiteltabelle gerechnet (22:15).
2. Etwa 60 % Chef (Chefrunden 1036, 1039, 1051, 867, 1072; Nacht 1077), 30 % Teams (Läufe nach 621 A, Gegenlesen t280, t281), 10 % Notizen; richtig, aber das Gegenlesen hat nicht gehalten (t280 1022, Fehler 341 13:51).
3. Z3 Ziel 0, Ist mindestens 10 Fehler 341 vom 11.11. bis 12.11. (`ARBEIT-BERATUNG.md`: 952, 365a, 644a, 1036, 1022, 867 dreimal, 1072, 1051); verfehlt. Z4 und Ze zählt Diogenes; 1051 Vorentscheid hielt keine 20 Minuten (Archiv 22:06 → 22:18).
4. Vorgelegt 1051 (zwei Wege mit Zahlen; der Chef wählte A erst, nachdem er selbst den Verlauf über Kapitel 4 fand), 867 (ohne Gegenprobe am Muster), 1072 (ohne die sechs Plätze 72v, die er selbst nannte); es fehlte jedes Mal die Prüfung gegen das, was schon beschlossen war.
5. Die Nachtentscheide 1077 (Vorentscheide 1022, 842, 1044, 1084, 1085; 867 zweimal „nicht so“): Bildurteile ohne den Chef, er kann sie morgen zurückweisen; ungeprüft gemeldet war t280 „bekannt: Kartenrand“ (1022 nicht im Build).
6. Nicht gemeldet: dass `ARBEIT-BETRIEB.md` (53 KB) und `ARBEIT-TEAM-JERRY.md` (26 KB) seit Tagen über der Grenze liegen; der Haken meldet es jedem, keiner trug es ein, ich bis 13.11., 00:33 auch nicht (dann Eingang Ford, Vorrat Jerry), weil ich es für ihre Sache hielt; Haltung 4 sagt: eintragen.
7. Der Chef wartete auf Vorlagen, die erst im dritten Anlauf stimmten (867 Vorlage 1 bis 5); verkürzt hätte eine Prüfliste je Vorlage aus dem gebilligten Muster, vor dem ersten Lauf an Tom.
8. Am meisten gekostet, am wenigsten gebracht: Läufe für Vorlagen, die ich nicht vorher gegen das Muster gelegt hatte (867 Vorlagen 2 bis 4, 1043 drei Filmläufe ohne Ausweichen).
9. Unklar: ob „Läufe frei“ nach 621 A auch nachts ohne Kostengrenze gilt; streichen würde ich nichts; es fehlt ein Wächter, der eine Zahl einer Fertigkeit über alle Kapitel rechnet (Lehre 1051).
10. Ernste Ansage: Inhalte und Tempo tragen, aber zehn Fehler 341 in zwei Tagen sind genau mein typischer Fehler (zustimmen und warten statt gegen Beschlossenes prüfen). Schritte: (a) jede Vorlage vor dem Lauf gegen das gebilligte Muster und das Archiv der Nummer als drei Prüfpunkte an das Team; (b) jede Zahl bei 0, 24, 49, 74, 100 gegen BRS 5; (c) beim Start die letzten zehn Nachrichten des Vorgängers lesen, bevor ich etwas frage.

### Perikles (13.11., 01:07, Sitzung „Perikles – Spiegel: Rollenspiegel 13.11. (13.11., 01:05)“)

0. Angekündigt 02.11.: (1) Werkzeugregel gegen die echten Läufe des Vortags prüfen, (2) Uhrzeit nur aus `date`, (3) Notizen nur mit Edit; (2) geschehen über die Uhr-Zeile des Hakens (340.5); (3) nicht gezählt, also unbelegt; (1) nicht: der Haken 464 griff an den echten Läufen nicht (D95.1, 748: 52 von 185 rot).
1. Nicht erfüllt: Tagesbericht 06.11. fehlte (Z1), den Rollenspiegel 06.11. ließ ich ausfallen (759), und die Kostenauswertung mit Sparvorschlag (Chef 17.10.) habe ich diese Woche nicht vorgelegt; „sagen, wenn der Schwerpunkt zu den Abläufen kippt“ habe ich bei mir selbst nicht getan (Frage 2).
2. Etwa 20 % Chef (Wochenziel 09.11., Tagesberichte, Vorlagen 720, 724, 743, 822, 903, 264.1), 70 % Werkzeuge und Betrieb (464 Commits „Perikles:“ seit 03.11., darunter 927–1078), 10 % andere Rollen (M?-Entscheide, Vorrang Jerry 1052); falsch so, das ist mein typischer Fehler „Abläufe statt Spiel“.
3. Woche 02.–08.11. laut Diogenes: Z3 1 Fehler (Ziel 0), Z4 6 Vorlagen, 5 ja, 1 ja, aber (Ziel 1), Z5 74 % (Ziel 70), Z6 nein, Muss 94 %; diese Woche Z3 mindestens 1 (11.11., 18:14, Aufwand „Mittel“ statt Hoch, 981/982), Z4 903 B, 822, 724 A, 743 angenommen, Wochenziel 09.–15.11. „Kampf funktioniert“ läuft noch.
4. Vorgelegt 903 (Checkliste nach Probe, Chef „B mit Zusätzen“), 822 (Haken abschalten), 724, 743, 720, 264.1, alle entschieden; es fehlte bei den Werkzeugvorgängen die Kostenangabe, und beim Wochenziel 09.11. kein Gegenweg mit Kosten.
5. Zurückweisen würde der Chef den Tagesbericht 12.11., der erst nach 14 Befunden der Gegenlesung stimmte, und dass ich 1076/1078 (Film nur Prüfgegenstand) als gebaut meldete, ohne dass ein echter Film danach geprüft ist; ungeprüft fertig war 981 (lauf.py gab Hoch aus, die App zeigte Mittel).
6. ARBEIT-BETRIEB.md (53 KB) und ARBEIT-BERATUNG.md (16 KB) überschreiten seit Tagen die Grenze, der Haken meldet es jedem Start; ich habe es Ford nicht in den Vorrat geschrieben (Sokrates tat es 13.11., 00:33), weil ich die Warnung für Rauschen hielt.
7. Der Chef wartete 4 h auf das Verschwinden von t280 (1070, 12.11.); 483, 866, 896 warten seit Tagen auf das „greift“ von Diogenes, 870.10 auf 882.2; kürzer wäre es mit einem Prüflauf Diogenes je Tag für alle meine Prüfzeilen auf einmal.
8. Am meisten gekostet und am wenigsten gebracht: `probelauf.py` viermal repariert (929, 943, 961, 1042) und `startbar.antworten()` zweimal (1010, 1011), jeweils am nächsten Einzelfall statt an allen echten Aufrufen des Vortags.
9. Unklar: wann ein Werkzeugvorgang M ist, wenn er keinen Fund des Chefs hat (ich setze ihn meist M); streichen würde ich die Größenwarnung für ARBEIT-BETRIEB in `notiz.sh`, solange das Protokoll darin steht (sie rauscht bei jedem Start, 340.3 nein); fehlt: nichts.
10. Ernste Ansage: rund 460 Commits auf Werkzeuge in einer Woche, in der Kapitel 1 das Ziel ist, und ein Fund des Chefs (981), den ich am Ergebnis hätte sehen müssen. Schritte: (1) Werkzeugvorgang ohne Fund des Chefs nur noch K, außer er blockiert ein Team; (2) jede Reparatur an allen echten Aufrufen des Vortags probieren, höchstens eine Reparatur je Werkzeug und Tag; (3) montags im Wochenziel Kosten je Rolle mit einem Sparvorschlag.

### Ford (13.11., 05:07)

0. Letzte Woche angekündigt: Antworten der Vorwoche liegen nur für die Sitzung vom 02.11. vor (has_more-Filter, Archivieren); heute Nacht (Sitzung 12.11., 23:51 bis 05:07) archiviert Ford alle fälligen Sitzungen und bucht Kosten, `archive_session` ging durch (eine Ablehnung beim ersten Versuch 23:51, zweiter Versuch ging). Erfüllt.
1. Rollendatei: Kosten nicht in einem Zug auf alle Vorgänge verteilt (Tom 23:53 erst 2,41 $ je Vorgang, dann Kommaliste nachgebucht); `Betrieb`-Kostenzeile bei Perikles Spiegel nicht von `lauf.py` gefunden, von Hand eingetragen (Commit-Warnung). Archiviert habe ich Sokrates 03:41 bei updated_at 03:40:54, also unter 60 s nach dem letzten Ereignis (Rest 0,37 $ nachgebucht).
2. Etwa 100 % Betrieb (Neustarts Tom ×6, Sokrates ×4, Jerry ×2, Starts Homer, Diogenes, Perikles); richtig so, aber Toms und Sokrates' Neustarts alle 15 bis 70 Minuten in dieser Nacht kosten je 5 bis 7 $.
3. Kennzahl: Läufe ohne Nacharbeit; Ist heute Nacht: 2 Nacharbeiten (Kosten Betrieb von Hand, Sokrates 03:41 zu früh archiviert) bei 9 Läufen und 12 Neustarts.
4. Dem Chef nichts vorgelegt; nachts nur eine lautlose Telegram-Meldung (Vorentscheid-Bremse 05:07).
5. Zurückweisen würde der Chef: 23 Warnungen „gebaut ohne Build“ aus `lauf.py` (Abgleich) habe ich nur als Zeile im Protokoll gemeldet, nicht an die Besitzer in den Vorrat geschrieben.
6. `lauf.py` gibt jede Stunde den Spike-Start für den Tom-Spiegel aus; das hätte ich Perikles melden müssen (der Spiegel gehört dem Besitzer selbst); ich habe ihn nur mit `--ohne Spiegel` unterdrückt.
7. Auf mich warteten die Neustart-Meldungen von Tom, Sokrates, Jerry (jeweils unter 3 Minuten bearbeitet). Ich wartete auf die Leerlaufzeit von 60 s der alten Sitzungen (je 1 bis 2 Minuten).
8. Am meisten gekostet und am wenigsten gebracht: Toms Neustart-Haken alle 20 Minuten in der Nacht (00:10, 00:25, 00:48 und weitere).
9. Unklar: `lauf.py --kosten` mit Zeile „Betrieb“ nach `--aufraeumen`; fehlt: ein fester Schlüssel für Betriebskosten ohne Vorgang. Streichen: der Spike-Start für fremde Spiegelzeilen.
10. Lob, ein Satz: Alle Neustarts nach Prüfung des Commits, keine Doppelstarts, Kosten gebucht; Schritte: (a) Spiegel-Zeilen in `lauf.py` vom Spike-Start ausnehmen, (b) Betriebskosten-Zeile festschreiben, (c) 60-Sekunden-Regel vor `archive_session` im Werkzeug prüfen lassen. Keinen davon beginnen, bevor der Chef Ja sagt.

### Team Tom (13.11., 08:51, Sitzung „Tom – 282: Lauf 420 auswerten, Testbitte; 1092 messen (13.11., 07:14)“)

0. Angekündigt (06.11.): je Aussehensfrage zuerst das gute Bild als Maßstab, Widerspruch Messung–Prüfer mit Bild klären, Zeit nur aus der Uhr. Geschehen: Zeit aus der Uhr ja; Maßstab und Bild nicht messbar belegt, 21 Tom-Vorgänge stehen „zu testen“ (vorgang.py --rolle Tom, 13.11.).
1. Halb erfüllt: „ein Build mit Test je Sitzung“ und Prüftreppe; Lauf 419 war rot mit zwei veralteten Tests (e7992230b), die vor dem Push am Rechner auffindbar gewesen wären.
2. Heute etwa 60 % Chef (Testbitte 282, Befund 1092), 30 % Betrieb (Modellbau am Rechner, Weckrufe, Vorrat), 10 % andere (1101 an Jerry). Richtig so; der Betriebsanteil ist zu hoch, weil der Kaufcache nicht greift (1101).
3. Ziel weiter: höchstens zwei Runden je Aussehensfrage bis „passt“, gezählt von Diogenes; Ist kenne ich nicht, festgefahren nach 827 A sind 431, 492, 505, 757, 814, 882.1, 1022 (startbar.py, 13.11.).
4. Vorgelegt: 1092 (Ursache gemessen, Weg, Kosten, Gegenargument „558 nicht zu clean“, Text fremd geprüft; ansehen/1092-streifen.md). Fehlte: ein Bild „nachher“, weil nicht gebaut werden durfte.
5. Zurückweisen könnte er, dass Rowena in 1092 nur gemessen, aber nicht im Befundbild ist, und dass die Prüfliste t282 zuerst Version 0.348.418 trug, bevor ich sie auf 420 setzte.
6. Gemeldet: Kaufcache-Ablegen scheitert (1101, Jerry). ARBEIT-BETRIEB.md 56 KB (notiz.sh-Warnung) hatte Sokrates schon gemeldet (Eingang 00:33), steht in Fords Übergabe; darum nicht doppelt.
7. Auf mich wartete der Chef auf Build 282 (APK 08:02). Ich wartete etwa 45 Minuten auf den Modellbau am Rechner, weil Lauf 420 nichts ablegen konnte; 1101 verkürzt das für alle Sitzungen.
8. Am meisten gekostet bei wenig Ertrag: der erste Modellbau am Rechner (30 Minuten), den ich abbrach in der Annahme, Lauf 420 lege ab; vorher die Ablegebedingung zu prüfen hätte ihn gespart.
9. Unklar: ob der Probelauf-Haken (621 A) einen Rechnerlauf zur Ursache als Probe zählt; er zählte ihn als 1 von 1. Fehlt nichts; streichen würde ich nichts.
10. Ernste Ansage: Builds und Befunde kommen, aber 492 und 505 sind mit über 170 $ festgefahren. Schritte: (a) vor jedem Push die betroffenen Tests am Rechner laufen lassen; (b) Annahmen über Werkzeuge (Cache, Ablegen) vorher im Code prüfen; (c) festgefahrene Vorgänge nicht mehr anfassen, ohne den Weg vorher mit Sokrates zu klären.

## Woche 18.11.

### Perikles (18.11., 07:52, Sitzung „Perikles – 448: Tagesbericht 18.11. (18.11., 07:42)“)

0. Angekündigt 13.11.: (1) Werkzeug ohne Fund des Chefs nur K, (2) jede Reparatur an allen echten Aufrufen des Vortags probieren, (3) montags Kosten je Rolle mit Sparvorschlag; (1) geschehen als Regel 340.7 (Chef 15.11., 18:30), (2) halb (1398 an t290/t291 nachgestellt, 1414 an 4 Vorlagen), (3) nicht geschehen, im Wochenziel 16.11. stand kein Sparvorschlag je Rolle.
1. Halb erfüllt: Teilen nach Last aller vier Entwickler (1600 ging ganz an Jerry, Chef 17.11., 23:16 „warum ich dich erinnern muss“, 1604) und das Durchsehen jedes „wartet auf t<n>“ gegen den jüngsten Build (Fehler 341 vom 15.11., 22:37).
3. Woche 09.–15.11. zählt Diogenes am 23.11.; selbst gesehen: Z3 mindestens 2 Fehler (15.11., 22:37 Warten auf t287; 17.11., 23:16 Verteilung 1604), Z1 erfüllt (Tagesbericht 16., 17., 18.11.), Z6 nein, das Wochenziel „Kampf passt“ wird wegen 1605 (Kampf ruht bis 21.11.) nicht erreicht.
4. Vorgelegt: Entscheid 1594 (Umfang Schlussbuild 299, mit Gegenargument zwei Builds), Votum zu 1605, Vorentscheid 1602 (Gegenlesen je Abschnitt); fremd geprüft war nur der Tagesbericht, bei 1594 fehlte eine Kostenzahl je Build.
5. Zurückweisen würde der Chef die Teilung 1600 nach Fach (Jerry alles) und den Tagesbericht 18.11. in erster Fassung, den das Gegenlesen an zehn Stellen berichtigte (Zahlen, unerklärte Begriffe, Widerspruch zu den Vorentscheiden).
6. Fünf Vorräte (Betrieb, Beratung, Jerry, Spike, Tom) liegen über 15 KB, und Diogenes hat 1608 (getestete Builds nicht auf `main`, Build 274 seit 178 h) erst als Wächterzeile bekommen; beides sah ich seit Tagen in jedem Start und habe es nicht als Vorgang beim Besitzer angelegt, weil ich es für bekannt hielt.
7. Auf mich wartete der Chef bei der Verteilung (1604) und Sokrates bei 1620 (Vorentscheid-Bremse, seit 07:32 startbar); ich wartete auf Diogenes für 1610, 1615, 1616 und auf den Termin 23.11. bei 14 Zeilen; kürzer mit einem gebündelten Prüflauf Diogenes je Tag.
8. Am meisten gekostet, am wenigsten gebracht: die Werkzeuge rund um Ford (1148, 1572, 1610, 1615, 1616: Hängeralarm, Wache, Blättern), fünf Bauten in vier Tagen für einen Ablauf, den der Chef 17.11., 17:05 mit „Da muss mir das mal jemand sagen“ einfacher wollte.
9. Unklar: ob Vorentscheide aus der Nacht als „gebilligt“ für den Schlussbuild 299 zählen (1595 sagt „Gebilligtes“, die Vorentscheide sagen „nächster Sammelbuild“); streichen würde ich die Größengrenze 15 KB im Starthaken, weil die Regel in CLAUDE.md 30 KB sagt; fehlt: nichts.
10. Ernste Ansage: dieselbe Lehre (nach Last teilen, Fehler 341 vom 03.11.) musste der Chef am 17.11. ein drittes Mal geben, obwohl das Signal im Überblick stand. Schritte: (1) jede Teilung mit mehr als einer Stufe vor dem Eintragen gegen „startbar je Rolle“ prüfen und Spike oder Tuffy zuerst nennen, (2) Werkzeug-Commits je Woche zählen und über 100 nichts Neues bauen, (3) Sparvorschlag je Rolle im Wochenziel 23.11.
11. Vorschlag fürs Spiel: Der Kräutersammler bekommt vor der Blutzahnhöhle eine eigene Herkunftshandlung, in der er aus gesammelten Kräutern einen Trank für den Bosskampf braut. Auslöser: Rechnung 1486 (17.11., 21:26), Kräutersammler gewinnt gegen die Bosse nur 56–62 von 100, Wachsoldat und Klosterschüler 93–100; Abnahmepunkt Stufe 2 „je Herkunft eine Handlung“ und Leitbild „Grinden darf man, muss man nie“. Aufwand etwa 2 Sitzungen (Text Homer, Bau Tom). Stärkstes Gegenargument: Balance liegt beim Chef, und das neue Kampfsystem (1589) misst ab 21.11. ohnehin neu, die Schere kann sich von selbst schließen.

### Ford (18.11., 07:54, Sitzung „Ford – Betriebsleiter (17.11., 18:24)“)

0. Angekündigt (13.11.): drei Werkzeugschritte erst nach Ja des Chefs; keiner begonnen, Ja kam nicht. Erfüllt im Sinne der Ankündigung (0 von 3 gebaut).
1. Halb erfüllt: Laufkurzzeilen teils geschätzt statt gelesen (Tom 23:03 als idle eingetragen, lief noch; 01:03 Jerry 1595 fast vor 13:00 gestartet), dazu einmal 14 s nach dem letzten Ereignis archiviert (Sokrates 20:27, Regel 60 s).
3. Kennzahl Ze Stillstand aus Fehler: Ziel 0, Ist 0 h seit 18:24 (17.11.); Fehler 341: 2 (Homer 1235 trotz „noch nicht“ vom Doppel-Ford 18:29, mein falscher Anstoß 1068 um 00:04).
4. Vorgelegt: Neustart-Text Ford mit Rechten (19:55), Einstellungseintrag autoMode (20:07), Kostenfrage mit Zahlen (19:53); Wege und Kosten standen dabei, ein fremd geprüftes Gegenargument fehlte.
5. Zurückweisen würde der Chef die Nachtschleife Diogenes↔Perikles an der Wache (1610, 1615, 1616, 1617, 1618; sechs Neustarts, gut 20 $), die ich erst nach der vierten Runde gebremst habe.
6. Nicht gemeldet: lauf.py hält „gebaut, wartet auf Sammelbuild“ für startbar (Spike 458.3, 1484a, Tom 1606 um 07:03 und 07:41 gestartet); erst um 07:42 an Perikles.
7. Auf mich warteten Neustart-Meldungen (meist unter 3 min); ich wartete auf Sokrates' Freigaben 621 A (Tom 1569, Jerry 1587, 20:07–20:11) – eine Regel „Läufe am Rechner frei bis 1 Lauf/h“ hätte das verkürzt.
8. Am meisten gekostet, am wenigsten gebracht: Neustarts nach 200-Tsd.-Haken bei Sokrates (vier zwischen 20:03 und 02:25, je 4–6 $) mitten im Chefgespräch.
9. Unklar: ob Ford bei IDLE+blocked „need_input“ schreibt (jetzt 1618); fehlt: Sokrates-Schwelle wie Kaufrepo (400 Tsd.); streichen: Uhr-Sitzung und Ford-Starter (seit 17.11. archiviert, Regeln noch in ROLLE-BETRIEB).
10. Ernste Ansage, ein Satz: Betrieb lief durch, aber mit zu vielen Neustarts und Nachtschleifen auf Kosten des Guthabens; Schritte: (a) Sokrates-Schwelle 400 Tsd., (b) lauf.py „wartet auf Sammelbuild“ nicht startbar, (c) ROLLE-BETRIEB von Uhr-Sitzung/Starter befreien.
11. Vorschlag: Alle Lichtquellen der Höhle (Fackeln, Glut, Funken) nach Dunkelheit am Ort statt nach Uhrzeit steuern, wie Chef 17.11., 23:56 für 1211 entschied; Leitbild „düstere, erwachsene Fantasy“, Abnahme „düster, immersiv“; Aufwand etwa 1 Tag Spike; Gegenargument: Aussehen eingefroren bis zum Durchspielen (488).
