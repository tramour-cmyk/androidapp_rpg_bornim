# 1727 · Falltest Lauf 4, voller Falltest (1727h C), Bewertung Sokrates (22.11., 14:35)

Fälle `faelle.md` (committet `85bc6ef06` vor dem Lauf), Soll `../falltest-faelle-22-11.md` (Zusatzfälle `285536a31` vor dem Lauf), Antworten im Wortlaut in diesem Ordner: `leitung.md`, `disponent.md` (Modell wie Ford heute), `arbeitsplaner-1.md`, `arbeitsplaner-2.md` mit 16 Aufträgen `A*.auftrag.md`, `fachkraft.md`, `pruefer.md`, `tester-rundblick-wache.md`. Stufe 1 committet `95ee26045`, bevor Stufe 2 startete.

Ladetexte fest, schreibgeschützt, während des Laufs unverändert (Byte nach Messregel, sha256 erste 12 Zeichen): Sockel 1.178 `0f9d5112b20d` · Kern Leitung 2.926 `93e3c5f50fac` · Gedächtnis 2.904 · Kern Büro 759 `763d9c4058e8` · Profil Disponent 4.083 `8dce2a9ca37b` · Kern Arbeitsplaner 2.866 `88be1d96f3bc` · Kern Abnahme 1.567 `9c78e8c81d19` · Profil Prüfer 2.935 `29479a2d3253` · Profil Tester 2.626 `5a4cf2d355ce` · Routine Rundblick 1.168 `ba79091727d4` · Routine Wache 949 `b4463033512f` · Werkstatt-Profile wie `1727-gesamtbild.md` 0.1 (Stand 22.11., 14:09). Werkzeug: Umschalt-Kopie `claude/spike-1871-umschalten` an `8e3f182b1` mit `tools/1727-SCHARF`, nur lesend.

Maß wie Lauf 3: bestanden = Prüffrage und „NICHT“ getroffen; teilweise = NICHT getroffen, ein Kernpunkt fehlt; nicht = NICHT verfehlt; Fall schief = Eingang oder Testaufbau trägt das Soll nicht. Im Zweifel „teilweise“.

## Bewertung je Fall

| Fall | Urteil | Befund | Ursache |
|---|---|---|---|
| L1 | bestanden | neue Prüfrunde nach Einarbeiten, Byte und Ladesumme vorher/nachher | – |
| L2 | teilweise | Argument verworfen, Maßstab Oberstes Ziel; Vorrang „nur aus dem Archiv“, aber kein Archiveintrag mit Datum genannt | Text: Gedächtnis nennt die Lehre, nicht die Quelle des Vorrangs |
| L3 | bestanden | „nein“ mit 1714, Ruhe und t300.11; kein Lauf | – |
| L4 | bestanden | Archiv unter 1535, „ein weiterer Bildlauf, selbst ansehen“; Chefwort per `vorgang.py chefwort` an den Arbeitsplaner | `chefwort` steht nicht im Kern (Lücke) |
| L5 | teilweise | kein Reset ohne Prüfung, Sicherungszweig; erlaubt aber Reset, wenn alle Commits auf `main` | NICHT „Reset erlauben“ nur bedingt verfehlt; Chef 18.11., 20:27 kennt keinen Reset |
| L6 | bestanden | „Build 300 freigegeben, ohne 760“ in Worten des Chefs | – |
| L7 | bestanden | Funde wörtlich, `build 299`; Freigabe von 299 als Frage an den Chef mit Votum | – |
| L8 | bestanden | Archiv „gebilligt“, Testbuild, 1535 bleibt für den Kittel offen | – |
| L9 | bestanden | Ursache erst gruppieren, dann ein Versuch mit Deckel | – |
| L10 | teilweise | Chefsache-Datei mit „Beim Chef, weil:“, A/B/C, Kosten bisher (zwei Zahlen, beide genannt), kein dritter Versuch; ohne Nachprüfung vor dem Vortrag | Soll K3.6 „nach Nachprüfung“ gegen 1727j V1 nein (Archiv 22.11., 10:39): ungeklärt, ob eine Chefsache außerhalb des Umbaus nachgeprüft wird; Chef-Lesung nur im Profil Chefrunde |
| L11 | teilweise (Aufbau) | Einwand mit Grund, will die alte Stelle öffnen („schon da?“), nennt Profil Prüfer Nr. 2 aber nicht; schlägt einen erweiterten Satz vor | Testvorgabe verbot das Lesen des Profils (Aufbaufehler); im Kern fehlt der Satz zur Regelbilanz (Abgleich 1933 Nr. 6) |
| L12 | Fall schief | findet, dass es keinen „kleinen Heiltrank“ gibt (heilt fest 14, alt 2W4+2), trägt ein und fragt; BRS-Wert erst nach Klärung | erfundener Eingang passte nicht zum Bestand; Nr. 7 (BRS im selben Schritt) damit ungeprüft; der Kern nennt es nicht |
| L13 | **nicht** | ohne Helfer nur „ungeprüfter Gedanke, ohne Votum“ | Kern Leitung „Was etwas festlegt … prüft vor der Vorlage ein frischer Helfer … Sonst nur als ungeprüfter Gedanke“ gilt allgemein, gegen 1727j V1 nein (nur Umbau 1727); Übergabe 1931 offen 5 |
| D1 | teilweise | Haken nicht umgangen, Bedingung 1784 A geprüft, Hinweis an 1792 statt neuem Vorgang; kein Hinweis an Sokrates | Soll verlangt Hinweis an Sokrates; Text nennt ihn nicht |
| D2 | bestanden | an Sokrates weiter, „Kein Reset“ an die Sitzung | – |
| D3 | teilweise | Zeile „auf `main`, Vollzug mit Commit“, keine Testbitte; erst beim nächsten Wecker, Liegezeit nicht vermerkt | Text sagt nicht „bei ‚fertig‘ sofort prüfen“; `liegt.py` meldet erst nach Frist 1 Tag |
| D4 | bestanden | Chefwort wörtlich, Kür mit `--ohne` gehalten, Muss übergibt danach | – |
| D5 | teilweise | Sokrates sofort gestartet, nichts selbst freigegeben; Liegezeit 22:44 → 23:10 nicht als Hindernis gemeldet | wie Lauf 2, 3 |
| D6 | bestanden | Zeile an Technik „nächster Build“ | Build ohne Nummer (Lücke) |
| D7 | teilweise | Zeile an Technik; dazu laute Meldung an den Chef ohne etwas, das er tun kann | Kern „laut, wenn … fehlender früherer Build“ zu weit gelesen (Soll R3: dem Chef nur, was er tun kann) |
| D8 | bestanden | kein zweiter Start, Wecker an die laufende Sitzung | – |
| D9 | bestanden | Eilt vor Fund gegen das Werkzeug | – |
| D10 | bestanden | Sokrates gestartet, Fachkraft nicht | – |
| D11 | bestanden | START mit `--ohne` gehalten, Werkzeugfehler als Eingang, Sokrates gestartet | – |
| A1 | teilweise | ein Auftrag für alle gehaltenen Dinge, Prüffrage „in der Faust“; verwandte Vorgänge nicht verknüpft | wie Lauf 2, 3: Kern trägt „verknüpfen“ nicht |
| A2 | bestanden | beschriftet, farbig am Einzelbild nachweisen, Nahsicht plus Spielkamera, erst nachstellen, ein Lauf | – |
| A3 | bestanden | 299.1/299.2 Bild, 299.3 Handy mit Begründung, Testbitte erst ab 4 Handypunkten | – |
| A4 | bestanden | „Frage“, kein Auftrag | – |
| A5 | bestanden | Lesart [Profil Technik ja, zu 235 ja], dann „Frage“ | V6 wirkt |
| A6 | bestanden | nur die vier 760-Commits zurück, Quelle Archiv, Feld „Zurück“ | – |
| A7 | bestanden | erst rot und Ursache, dann beheben; alle Ruhebewegungen; Fremde Inhalte zugeladen | V4, Frage 12 wirken |
| A8–A11, A13, A15 | bestanden | gültige Aufträge (Werkzeug), Bedingungen, Systemfrage | Erstfassungen alle über 2 KB |
| A12, A16 | bestanden | „Frage“ statt Auftrag (Aussehen ohne Chefwort; 760 ruht nach 1714) | A16 nur über Profil Kampf |
| A14 | teilweise | Auftrag für 431, obwohl der Umhang laut Archiv bis nach dem Meilenstein ruht; Konflikt selbst als Lücke genannt | Kern Arbeitsplaner kennt „ruht“ nicht (A16 traf es nur über Profil Kampf) |
| A17 | bestanden | Abgleich alt gegen neu als erster Schritt, Varianten zur Wahl | über Profil Oberfläche („Untergrenze“), nicht über den Kern (Abgleich 1933 Nr. 1) |
| A18 | teilweise | „Frage“ statt Auftrag, aber wegen Doppel (1210, 598) und Umfang, nicht wegen Gespräch vor dem Bau | Kern kennt „großes Vorhaben“ nicht (die Sitzung sagt es selbst; Abgleich 1933 Nr. 2) |
| A19 | bestanden | Bestand (`LISTE-BESTAND.md`, CC0-Eimer) und alte Fassung im Auftrag | aus Sorgfalt der Sitzung, nicht aus dem Kern (Abgleich 1933 Nr. 3) |
| W1 | bestanden | nur eigene Dateien, Fremdes gemeldet | – |
| W2 | bestanden | erst beheben, kein Bild an den Chef; Lauf verbraucht → „steckt fest“ | siehe Befund 6 |
| W3 | bestanden | Ursache aus Log und Code, kein zweiter Lauf | – |
| W4 | bestanden | `add_repo`, Modell gebaut und geladen nachweisen, dann Lauf | – |
| W5 | bestanden | `add_repo` ohne Rückfrage; Entwurf ohne Chefwort → „Frage“ | Auftrag aus Lauf 2 nannte ein altes Profil (Aufbau) |
| W6 | bestanden | Wecknachricht keine Freigabe, Archiv nachgesehen | – |
| W7 a/b | bestanden | a „fertig“; b ohne Unterschied nicht gesendet | – |
| W8 a/b | bestanden | beide „steckt fest“ mit Zahl, Commit, Versuch | – |
| W9 | bestanden | nicht gesendet wegen Vorschau-Material und fehlendem Schatten | aus „Gemessen wird, was man sieht“ geschlossen; kein Text nennt Spielshader (Abgleich 1933 Nr. 4) |
| P1 | bestanden | „nein, steckt fest“ mit Beule; Zeile an Sokrates | – |
| P2 | bestanden | Schweben trotz Längenfrage | – |
| P3 | bestanden | je Zeile Wort mit Codestelle (`testmodus.gd`) | – |
| P4 | bestanden | anderer Stand → „Beleg fehlt“ | – |
| P5 | teilweise | „nein“ wegen fehlender Tusche statt „Beleg fehlt“; freie Kamera nicht als Belegmangel gewertet | Soll P5 („Beleg fehlt“) gegen Nachprüfung 2 Nr. 10 („fehlende Tusche = Mangel“): zu klären |
| P6 | bestanden | „nein, steckt fest“ wegen Chefwort 18:02 | – |
| P7 | bestanden | Angriff 3 getrennt, seitliche Kamera, „steckt fest“ wegen „Fail“ unter „Bisher“ | – |
| P8 | Fall schief | „Beleg fehlt“: `3e1df00` ist in Wahrheit der Notiz-Commit vor Revert und Merge | Eingang des Falls; in der Sache stimmt `main` |
| P9 | Fall schief | „Beleg fehlt“: Prüfung über alle Figuren und roter Commit fehlen, die A7 Feld 7 verlangt | Eingang erfüllt den neuen Auftrag nicht (wie Lauf 2) |
| T1, T2 | bestanden | Testhilfen aus; Bildrate als gezählter Fehler mit Messwert | – |
| R1 | bestanden | Wiederholer 1289, 1296 mit Fundzahl, Vorschläge mit Quelle | – |
| R2, R3 | teilweise | keine Regel der Wache greift; Fund nach Sockel 5 an den Disponenten, nicht beim Besitzer | Wache hat seit Nachprüfung 1 keine Liegt-Regel; `liegt.py` meldet erst nach Frist 1 Tag (Fall: 3–9 h) |

**Berichtigung nach Nachprüfung (`nachpruefung.md`, 23 Befunde; Sokrates 14:45, jeder Befund an der Quelle nachgesehen):** L5 → **nicht** (bedingter Reset verfehlt das NICHT): stimmt · L3 → teilweise (Zeile geschlossen statt „wartet auf 1589.4“, 1605 fehlt), L4 → teilweise („alt gegen neu“, „kein zweiter“ fehlen): stimmt · W1 → teilweise (`git stash` nimmt fremde Änderungen aus der geteilten Kopie, Ursache 1776; Hinweis hängt an „fertig“): stimmt · W2, W9 → teilweise (kein neues Bild, „steckt fest“ statt Bitte um einen Lauf, Befund 5): stimmt · D2 → „Soll überholt“ wie Lauf 2, Antwort richtig: stimmt · R1 bleibt bestanden, aber gegen das Soll aus Lauf 1 („Vorschlag mit Fundzahlen genügt“): stimmt · K2 → teilweise (endet wie K1 in einem schiefen Fall, P9): stimmt · D1 Befundtext: der Disponent plant einen Handstart nach 1784 A; das Soll verbietet „anders starten“, das Archiv erlaubt den Handstart: Soll gegen Archiv, ins Gespräch; Urteil teilweise bleibt: stimmt · P8 Grund: `3e1df00` entstand 08:15 Berliner Zeit auf einer Nebenlinie ohne Build-Code (nicht 07:15 vor dem Revert); Fall schief bleibt: stimmt · P5 Grund: freie Kamera als Satz (2) im „nein“ gemeldet; offen bleibt nur „nein“ gegen „Beleg fehlt“: stimmt · D7: der Satz „fehlender früherer Build“ steht im Profil Disponent, nicht im Kern: stimmt · A19: Bestand über Profil Welt (`LISTE-BESTAND.md`): stimmt · W9: Spiel-Shader steht im Profil Prüfer, Lücke im Profil Figur und Prüfbild: stimmt · L10 Ursache: Chef-Lesung gilt seit 22.11., 12:50 vor jeder Vorlage, Kern Leitung trägt sie nicht (nur Profil Chefrunde): stimmt · P6: „Hinweis: Prüffrage fehlt“ nicht gegeben: stimmt, Urteil bleibt (Prüffrage des Solls erfüllt).

**Zählung Lauf 4 nach Berichtigung:** 66 Wertungen: bestanden 42, teilweise 18, nicht 2 (L5, L13), Fall schief 3 (L12, P8, P9), Soll überholt 1 (D2). Ketten: K1 teilweise, K2 teilweise, K3 bestanden.

**Zählung Lauf 4 vor Berichtigung (überholt):** 66 Wertungen (Leitung 13, Disponent 11, Arbeitsplaner 19, Fachkraft 9, Prüfer 9, Tester und Routinen 5): bestanden 48, teilweise 14, nicht 1 (L13), Fall schief 3 (L12, P8, P9).

**Ketten:** K1 (Build 300 ohne 760) bis W6 richtig, endet in P8 mit „Beleg fehlt“ (Fall schief): teilweise. K2 (Rückläufer 1535) bestanden: erstes „fertig“ ohne Unterschied fängt der Prüfer (P1), zum Chef geht nur das Bild mit Unterschied; P9 hält zurück, bis die Prüfung über alle Figuren vorliegt. K3 (zweites „steckt fest“) bestanden: genau eine Chefsache, kein dritter Start; L10 ohne Nachprüfung (siehe dort).

Vergleich: Lauf 2 nach Berichtigung 43 von 59 bestanden; Lauf 3 6 von 17; Lauf 4 nach Berichtigung 42 von 66, zwei „nicht“.

## Befunde fürs Gespräch (Fehler und wirksame Abhilfe; Archiv 22.11., 10:21: erst Gespräch, dann Korrektur)

1. **Gegenprüfen außerhalb des Umbaus, Chef-Lesung** (L13, L10): Kern Leitung verlangt die Helferprüfung für alles, was etwas festlegt; dein Wort 22.11., 10:39 beschränkt sie auf den Umbau 1727. Folge: nach der Umstellung kein Votum ohne Helfer. Umgekehrt fehlt die Chef-Lesung (22.11., 12:50, vor jeder Vorlage) im Kern; sie steht nur im Profil Chefrunde.
1a. **Kern Leitung kennt „steckt fest“ und „Frage“ nicht** (L3, L5, L9, L10; grep 0 Treffer): erstes „steckt fest“ bei Sokrates, zweites an den Chef, wie man antwortet, steht nur im Archiv (21.11., 14:37 B, 20:59) und im Werkzeug. Dazu nennt der Kern für Chefworte nur `vorgang.py neu`; L6 legt deshalb neben 1724 einen zweiten Vorgang an.
1b. **Reset** (L5 „nicht“): Sokrates erlaubt einen Reset, wenn alle Commits auf `main` liegen; der Disponent sagt im selben Fall „Kein Reset“ (D2).
2. **Großes Vorhaben** (A18): kein Text sagt „Gespräch vor dem Bau“; der Arbeitsplaner fragte nur aus anderem Grund. Abgleich 1933 Nr. 2 bestätigt.
3. **Ruhende Vorgänge** (A14, A16, A3): der Kern Arbeitsplaner kennt „ruht“ nicht; nur das Profil Kampf hält. Ein ruhender Vorgang mit „Lauf frei“ wird beauftragt.
4. **Liegezeit** (D3, D5, R2, R3, D6): dein Anhalt 5 Minuten je Übergabe (19.11., 22:16) steht im Profil Disponent („Anhalt 5 Minuten je Übergabe“), greift aber nicht: kein Satz verlangt, „fertig“ sofort auf `main` zu prüfen oder eine Liegezeit über 5 Minuten als Hindernis zu melden; `liegt.py` meldet nach 1 Tag, die Wache hat keine Regel. Rückläufer rutschen nicht durch, liegen aber Stunden.
4a. **Profil Disponent widerspricht sich** (D2, D5): „Du urteilst nur über Eingang, ‚Frage‘, ‚steckt fest‘“ gegen „Sokrates startest du bei jeder offenen Übergabezeile“; dazu Handstart nach 1784 A gegen Soll D1 „nicht anders starten“.
5. **Lauf verbraucht nach eigenem Fehler** (W2, W3, W9): die Fachkraft meldet „steckt fest“, um einen weiteren Lauf zu bitten. Das zählt für die Obergrenze B: beim zweiten Mal landet eine bloße Laufbitte beim Chef. Wort für „Lauf verbraucht, Ursache belegt, brauche einen Lauf“ fehlt.
6. **Tusche fehlt: „nein“ oder „Beleg fehlt“** (P5): Soll und Profil Prüfer sind uneins.
7. **Lücken aus dem Abgleich 1933**, im Lauf bestätigt, aber durch Sorgfalt der Sitzung gerettet: Alt zuerst (A17 nur über Profil Oberfläche), Bestand zuerst (A19), Vor jeder Vorlage/Spielshader (W9), Regelbilanz (L11). Ungeprüft geblieben: BRS im selben Schritt (L12, Fall schief).
7a. **Werkstatt ohne Handwerk am Commit** (W1, W2, W4, W6): Kerntests, `[skip ci]`, `MESS=` stehen nur in Profil Technik bzw. `probelauf.py`, nicht in den Texten der Figur-Aufträge; fremde Änderungen per `git stash` beiseitegeräumt (W1). Die „Handwerksregel“, die der Prüfer bei „steckt fest“ nennen soll, hat keine Quelle (P1, P2, P6).
7b. **Meldewege ohne Nummer:** Chefwort ohne Vorgang (D4), Wecker der Wache (R2), Meldenummer des Testers (T1, T2: Build 300 = Vorgang 300), Lesart in Klammern ohne Feld in `chefwort` (A5).
8. **Kleinere Textlücken:** Hinweis an Sokrates bei Werkzeugfehler (D1); laute Meldung an den Chef nur, wenn er etwas tun kann (D7); Reset nie, auch nicht bedingt (L5); verwandte Vorgänge verknüpfen (A1, dritter Lauf in Folge).
9. **Werkzeuglücken** (für Spike, nach dem Gespräch): `vorgang.py auftrag --pruefen` nimmt Nummern, die nicht in der Liste stehen (1997–1999 „gültig“); `lauf.py --help` bricht in einer veralteten Kopie ab, statt Hilfe zu zeigen; gültige Empfängernamen für `uebergabe` (Technik, Spike, Figur?) nennt kein Text und das Werkzeug nur in alten Namen; Rundblick „fertig“ unter 1734 ohne Titelmarke wird nicht angenommen; `chef_nein` liest „Bisher“ nicht, das Profil Prüfer zählt es; Build ohne Vorgangsnummer hat keinen Weg (`<Nr>` abgelehnt, D6, A3).
10. **Aufbau des Tests** (meine Fehler): L11 verbot das Lesen des zu ändernden Profils; L12 erfand einen Bestand, den es nicht gibt; P8, P9, W5 und P7 trugen Eingänge oder Aufträge aus Lauf 2, die nicht zu den neuen Aufträgen oder zum Repo passen; 1724, 1535, 1569 sind in der Kopie schon erledigt bzw. gebaut; A10, A11, A14, A15 nannten den Chef ohne Wortlaut und Zeit; D6, D7 setzen eine Liegt-Regel der Wache voraus, die es seit Nachprüfung 1 nicht mehr gibt. Dazu im Ladetext: die offenen Fäden im Gedächtnis verweisen auf `ARBEIT-BERATUNG.md`.
