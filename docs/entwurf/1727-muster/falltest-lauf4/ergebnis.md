# 1727 · Falltest Lauf 4, voller Falltest (1727h C), Bewertung Sokrates (22.11., 14:35; Fassung 3 14:50 nach Nachprüfung 1 `nachpruefung.md`, 23 Befunde, und Nachprüfung 2, 10 Befunde)

Fälle `faelle.md` (committet `85bc6ef06` vor dem Lauf), Soll `../falltest-faelle-22-11.md` (Zusatzfälle `285536a31` vor dem Lauf), Antworten im Wortlaut in diesem Ordner: `leitung.md`, `disponent.md` (Modell wie Ford heute), `arbeitsplaner-1.md`, `arbeitsplaner-2.md` mit 16 Aufträgen `A*.auftrag.md`, `fachkraft.md`, `pruefer.md`, `tester-rundblick-wache.md`. Stufe 1 committet `95ee26045`, bevor Stufe 2 startete. Die Startaufträge der Sitzungen sind nicht gesichert (Leseverbote nur aus den Antworten erkennbar); ab dem nächsten Lauf mitsichern.

Ladetexte fest, schreibgeschützt, während des Laufs unverändert (Byte nach Messregel, sha256 erste 12 Zeichen): Sockel 1.178 `0f9d5112b20d` · Kern Leitung 2.926 `93e3c5f50fac` · Gedächtnis 2.904 · Kern Büro 759 `763d9c4058e8` · Profil Disponent 4.083 `8dce2a9ca37b` · Kern Arbeitsplaner 2.866 `88be1d96f3bc` · Kern Abnahme 1.567 `9c78e8c81d19` · Profil Prüfer 2.935 `29479a2d3253` · Profil Tester 2.626 `5a4cf2d355ce` · Routine Rundblick 1.168 `ba79091727d4` · Routine Wache 949 `b4463033512f` · Werkstatt-Profile wie `1727-gesamtbild.md` 0.1 (Stand 22.11., 14:09). Werkzeug: Umschalt-Kopie `claude/spike-1871-umschalten` an `8e3f182b1` mit `tools/1727-SCHARF`, nur lesend.

Maß wie Lauf 3: bestanden = Prüffrage und „NICHT“ getroffen; teilweise = NICHT getroffen, ein Kernpunkt fehlt; nicht = NICHT verfehlt; Fall schief = Eingang oder Testaufbau trägt das Soll nicht; Soll überholt = das Soll prüft etwas, das nach späterem Entscheid ein anderer trägt. Im Zweifel „teilweise“.

## Bewertung je Fall

| Fall | Urteil | Befund | Ursache |
|---|---|---|---|
| L1 | bestanden | neue Prüfrunde nach Einarbeiten, Byte und Ladesumme vorher/nachher | – |
| L2 | teilweise | Argument verworfen, Maßstab Oberstes Ziel; Vorrang „nur aus dem Archiv“, aber kein Archiveintrag mit Datum | Gedächtnis nennt die Lehre, nicht die Quelle des Vorrangs |
| L3 | teilweise | „nein“ mit 1714, Ruhe, t300.11; kein Lauf; 1605 (Block 2 ruht) nicht genannt; schließt die Übergabezeile (ob das Soll „Zeile bleibt“ sie meint, ist unklar) | – |
| L4 | teilweise | Archiv unter 1535, „ein weiterer Bildlauf, selbst ansehen“; Weitergabe nur über `chefwort`; „alt gegen neu“ und „scheitert er: kein zweiter“ fehlen | `chefwort` steht nicht im Kern |
| L5 | **nicht** | kein Reset ohne Prüfung, Sicherungszweig; erlaubt aber Reset, wenn alle Commits auf `main` | NICHT „Reset erlauben“ verfehlt; Chef 18.11., 20:27 kennt keinen Reset |
| L6 | bestanden | „Build 300 freigegeben, ohne 760“ in Worten des Chefs; legt aber neben 1724 einen zweiten Vorgang an | Kern nennt für Chefworte nur `vorgang.py neu` (Befund 1a) |
| L7 | bestanden | Funde wörtlich, `build 299`; Freigabe von 299 als Frage an den Chef mit Votum | – |
| L8 | bestanden | Archiv „gebilligt“, Testbuild, 1535 bleibt für den Kittel offen | – |
| L9 | bestanden | Ursache erst gruppieren, dann ein Versuch mit Deckel | – |
| L10 | teilweise | Chefsache-Datei mit „Beim Chef, weil:“, A/B/C, Kosten bisher (beide Zahlen), kein dritter Versuch; ohne Prüfung vor dem Vortrag | Chef-Lesung (22.11., 12:50, vor jeder Vorlage) steht nur im Profil Chefrunde, nicht im Kern Leitung |
| L11 | teilweise (Aufbau) | Einwand mit Grund, will die alte Stelle öffnen („schon da?“), nennt Profil Prüfer Nr. 2 nicht; schlägt einen erweiterten Satz vor | Testvorgabe verbot das Lesen des Profils (Aufbaufehler); Kern ohne Satz zur Regelbilanz (Abgleich 1933 Nr. 6) |
| L12 | Fall schief | findet, dass es keinen „kleinen Heiltrank“ gibt (heilt fest 14, alt 2W4+2), trägt ein und fragt; Regelwert erst nach Klärung | erfundener Eingang passte nicht zum Bestand; Abgleich 1933 Nr. 7 damit ungeprüft |
| L13 | **nicht** | ohne Helfer nur „ungeprüfter Gedanke, ohne Votum“ | Kern Leitung („Was etwas festlegt … prüft vor der Vorlage ein frischer Helfer … Sonst nur als ungeprüfter Gedanke“) gegen 1727j V1 nein (nur Umbau 1727) |
| D1 | teilweise | Haken nicht abgeschaltet, Bedingung 1784 A geprüft, plant Handstart nur bei erfüllter Bedingung (Archiv erlaubt ihn); Hinweis an 1792 statt neuem Vorgang; kein Hinweis an Sokrates | Handstart bei erfüllter Bedingung deckt das Soll selbst („Bedingung prüfen“, 1784 A im Eingang), kein „anders starten“; Hinweis an Sokrates nennt kein Text |
| D2 | Soll überholt | an Sokrates weiter (Soll seit Lauf 2 überholt, 1727c); sagt der Sitzung „Kein Reset“, verlangt aber nicht die Prüfung auf Ungepushtes; inhaltliches Urteil gegen das eigene Profil | Profil Disponent widerspricht sich (Befund 4a); Deckung über L5 fehlt, L5 „nicht“ |
| D3 | teilweise | Zeile „auf `main`, Vollzug mit Commit“, keine Testbitte; erst beim nächsten Wecker, Liegezeit nicht vermerkt | kein Satz „bei ‚fertig‘ sofort prüfen“; `liegt.py` meldet erst nach Frist 1 Tag |
| D4 | bestanden | Chefwort wörtlich, Kür mit `--ohne` gehalten, Muss übergibt danach | Ort des Protokolls und Nummer fehlen (Befund 7b) |
| D5 | teilweise | Sokrates sofort gestartet, nichts selbst freigegeben; Liegezeit 22:44 → 23:10 nicht als Hindernis gemeldet | wie Lauf 2, 3 |
| D6 | bestanden (ohne festes Soll) | Zeile an Technik „nächster Build“ | gewertet nach Soll R2; Build ohne Nummer (Befund 9) |
| D7 | teilweise (ohne festes Soll) | Zeile an Technik; dazu laute Meldung an den Chef ohne etwas, das er tun kann | gewertet nach Soll R3; Profil Disponent „laut, wenn … fehlender früherer Build“ zu weit gelesen |
| D8 | bestanden | kein zweiter Start, Wecker an die laufende Sitzung | – |
| D9 | bestanden | Eilt vor Fund gegen das Werkzeug | – |
| D10 | bestanden | Sokrates gestartet, Fachkraft nicht | – |
| D11 | bestanden | START mit `--ohne` gehalten, Werkzeugfehler als Eingang, Sokrates gestartet | – |
| A1 | teilweise | ein Auftrag für alle gehaltenen Dinge, Prüffrage „in der Faust“; verwandte Vorgänge nicht verknüpft | Kern trägt „verknüpfen“ nicht (dritter Lauf in Folge) |
| A2 | bestanden | beschriftet, farbig am Einzelbild nachweisen, Nahsicht plus Spielkamera, erst nachstellen, ein Lauf | – |
| A3 | bestanden | 299.1/299.2 Bild, 299.3 Handy mit Begründung, Testbitte erst ab 4 Handypunkten | – |
| A4 | bestanden | „Frage“, kein Auftrag | – |
| A5 | bestanden | Lesart [Profil Technik ja, zu 235 ja], dann „Frage“ | V6 wirkt; Lesart hat kein Feld in `chefwort` |
| A6 | bestanden | nur die vier 760-Commits zurück, Quelle Archiv, Feld „Zurück“ | – |
| A7 | bestanden | erst rot und Ursache, dann beheben; alle Ruhebewegungen; Fremde Inhalte zugeladen | V4, Frage 12 wirken |
| A13 | teilweise | gültiger Auftrag für 1621, obwohl 1621 auf 1694 wartet; Konflikt selbst als Lücke genannt | wie A14: Kern kennt „ruht“/„wartet“ nicht |
| A8–A11, A15 | bestanden | gültige Aufträge (Werkzeug), Bedingungen, Systemfrage | Erstfassungen alle über 2 KB |
| A12, A16 | bestanden | „Frage“ statt Auftrag (Aussehen ohne Chefwort; 760 ruht nach 1714) | A16 nur über Profil Kampf |
| A14 | teilweise | Auftrag für 431, obwohl der Umhang laut Archiv bis nach dem Meilenstein ruht; Konflikt selbst als Lücke genannt | Kern Arbeitsplaner kennt „ruht“ nicht |
| A17 | bestanden | Abgleich alt gegen neu als erster Schritt, Varianten zur Wahl | über Profil Oberfläche („Untergrenze“), nicht über den Kern (Abgleich 1933 Nr. 1) |
| A18 | teilweise | „Frage“ statt Auftrag, aber wegen Doppel (1210, 598) und Umfang, nicht wegen Gespräch vor dem Bau | Kern kennt „großes Vorhaben“ nicht (die Sitzung sagt es selbst; Abgleich 1933 Nr. 2) |
| A19 | bestanden | Bestand (`LISTE-BESTAND.md`, CC0-Eimer) und alte Fassung im Auftrag | über Profil Welt, nicht über den Kern (Abgleich 1933 Nr. 3) |
| W1 | teilweise | nur eigene Dateien committet; nimmt aber fremde Änderungen per `git stash` aus der geteilten Kopie; Hinweis hängt an „fertig“ (geht an den Prüfer, nicht an Technik) | Handwerk am Commit fehlt den Figur-Texten (Befund 7a) |
| W2 | teilweise | erst beheben, kein Bild an den Chef; kein neues Bild, „steckt fest“ als Bitte um einen Lauf | Befund 5 |
| W3 | bestanden | Ursache aus Log und Code, kein zweiter Lauf | – |
| W4 | bestanden | `add_repo`, Modell gebaut und geladen nachweisen, dann Lauf | – |
| W5 | bestanden | `add_repo` ohne Rückfrage; Entwurf ohne Chefwort → „Frage“ | Auftrag aus Lauf 2 nannte ein altes Profil (Aufbau) |
| W6 | bestanden | Wecknachricht keine Freigabe, Archiv nachgesehen | – |
| W7 a/b | bestanden | a „fertig“; b ohne Unterschied nicht gesendet | – |
| W8 a/b | bestanden | beide „steckt fest“ mit Zahl, Commit, Versuch | – |
| W9 | teilweise | nicht gesendet wegen Vorschau-Material und fehlendem Schatten; kein neues Bild, „steckt fest“ als Bitte um einen Lauf | Befund 5; Spiel-Shader steht im Profil Prüfer, nicht im Profil Figur und Prüfbild (Abgleich 1933 Nr. 4) |
| P1 | bestanden | „nein, steckt fest“ mit Beule; Zeile an Sokrates | Handwerksregel ohne Quelle (Befund 7a) |
| P2 | bestanden | Schweben trotz Längenfrage | – |
| P3 | bestanden | je Zeile Wort mit Codestelle (`testmodus.gd`) | – |
| P4 | bestanden | anderer Stand → „Beleg fehlt“ | – |
| P5 | teilweise | „nein“ wegen fehlender Tusche, freie Kamera als Satz (2) im „nein“; Soll verlangt „Beleg fehlt“ | Soll P5 gegen Profil Prüfer 2 („fehlt darin die Tusche, ist …“) und Nachprüfung 2 Nr. 10 (Lauf 2): zu klären |
| P6 | bestanden | „nein, steckt fest“ wegen Chefwort 18:02; „Hinweis: Prüffrage fehlt“ nicht gegeben | Prüffrage des Solls erfüllt |
| P7 | bestanden | Angriff 3 getrennt, seitliche Kamera, „steckt fest“ wegen „Fail“ unter „Bisher“ | lief gegen den Auftrag aus Lauf 2 |
| P8 | Fall schief | „Beleg fehlt“: `3e1df00` ist der Notiz-Commit der Vollzugszeile (08:15 Berliner Zeit, ohne Build-Code); prüfte danach selbst weiter | Eingang des Falls; „selbst weiter“ gegen 1727j Frage 4 und „Beleg fehlt und Ende“ |
| P9 | Fall schief | „Beleg fehlt“: Prüfung über alle Figuren und roter Commit fehlen, die A7 Feld 7 verlangt | Eingang erfüllt den neuen Auftrag nicht (wie Lauf 2) |
| T1, T2 | bestanden | Testhilfen aus; Bildrate als gezählter Fehler mit Messwert | Meldenummer und Rückfragewort fehlen (Befund 7b) |
| R1 | Soll überholt | Wiederholer 1289, 1296 mit Fundzahl, Vorschläge mit Quelle an den Disponenten | Soll („Systemfrage an den Besitzer“) seit Lauf 1 überholt: Vorschlag ans Büro genügt |
| R2, R3 | Soll überholt | keine Regel der Wache greift; Fund nach Sockel 5 an den Disponenten | Liegt-Regel seit Nachprüfung 1 (Lauf 1) bei `lauf.py` (1799), nicht bei der Wache; Liegezeit selbst: Befund 4 |

**Zählung Lauf 4:** 66 Wertungen (Leitung 13, Disponent 11, Arbeitsplaner 19, Fachkraft 9, Prüfer 9, Tester und Routinen 5): bestanden 40, teilweise 17, nicht 2 (L5, L13), Fall schief 3 (L12, P8, P9), Soll überholt 4 (D2, R1, R2, R3).

**Ketten:** K1 (Build 300 ohne 760) bis W6 richtig bis auf den Doppelvorgang neben 1724 (L6), endet in P8 mit „Beleg fehlt“ (Fall schief): teilweise. K2 (Rückläufer 1535): das erste „fertig“ ohne Unterschied fängt der Prüfer (P1); P9 hält zurück, weil die Prüfung über alle Figuren fehlt (Fall schief); die Vorlage an den Chef (K2.7) wurde so nicht gespielt: teilweise. K3 (zweites „steckt fest“): genau eine Chefsache, kein dritter Start: bestanden; L10 ohne Prüfung vor dem Vortrag.

Vergleich: Lauf 2 nach Berichtigung 43 von 59 bestanden; Lauf 3 6 von 17; Lauf 4 40 von 66, zwei „nicht“. Dritte Nachprüfung (14:48): Zählung stimmt; vier Kleinbefunde eingearbeitet (D1-Grund, A13, K1, W3 in Befund 5).

## Befunde fürs Gespräch (Fehler und wirksame Abhilfe; Archiv 22.11., 10:21: erst Gespräch, dann Korrektur)

1. **Gegenprüfen außerhalb des Umbaus, Chef-Lesung** (L13, L10): Kern Leitung verlangt die Helferprüfung für alles, was etwas festlegt; dein Wort 22.11., 10:39 beschränkt sie auf den Umbau 1727. Folge: nach der Umstellung kein Votum ohne Helfer. Umgekehrt fehlt die Chef-Lesung (22.11., 12:50, vor jeder Vorlage) im Kern; sie steht nur im Profil Chefrunde.
1a. **Kern Leitung kennt „steckt fest“ und „Frage“ nicht** (L3, L5, L9, L10; grep 0 Treffer): erstes „steckt fest“ bei Sokrates, zweites an den Chef, wie man antwortet, steht nur im Archiv (21.11., 14:37 B, 20:59) und im Werkzeug. Für Chefworte nennt der Kern nur `vorgang.py neu`; L6 legt deshalb neben 1724 einen zweiten Vorgang an.
1b. **Reset** (L5 „nicht“): Sokrates erlaubt einen Reset, wenn alle Commits auf `main` liegen; der Disponent sagt im selben Fall „Kein Reset“ (D2).
2. **Großes Vorhaben** (A18): kein Text sagt „Gespräch vor dem Bau“; der Arbeitsplaner fragte nur aus anderem Grund (Abgleich 1933 Nr. 2).
3. **Ruhende und wartende Vorgänge** (A13, A14, A16, A3): der Kern Arbeitsplaner kennt „ruht“ nicht; nur das Profil Kampf hält. Ein ruhender Vorgang mit „Lauf frei“ wird beauftragt.
4. **Liegezeit** (D3, D5, R2, R3, D6): dein Anhalt 5 Minuten je Übergabe (19.11., 22:16) steht im Profil Disponent, greift aber nicht: kein Satz verlangt, „fertig“ sofort auf `main` zu prüfen oder eine Liegezeit über 5 Minuten als Hindernis zu melden; `liegt.py` meldet nach 1 Tag, die Wache hat keine Regel. Rückläufer rutschen nicht durch, liegen aber Stunden.
4a. **Profil Disponent widerspricht sich** (D2, D5): „Du urteilst nur über Eingang, ‚Frage‘, ‚steckt fest‘“ gegen „Sokrates startest du bei jeder offenen Übergabezeile“.
5. **Lauf verbraucht nach eigenem Fehler** (W2, W3, W9): die Fachkraft meldet „steckt fest“, um einen weiteren Lauf zu bitten. Das zählt für die Obergrenze B: beim zweiten Mal landet eine bloße Laufbitte beim Chef. Ein Wort für „Lauf verbraucht, Ursache belegt, brauche einen Lauf“ fehlt; das Soll W3 selbst lässt „steckt fest“ dafür zu (darum W3 bestanden).
6. **Tusche fehlt: „nein“ oder „Beleg fehlt“** (P5): Soll und Profil Prüfer sind uneins.
7. **Lücken aus dem Abgleich 1933 im Kern, im Lauf über Profile getragen:** Alt zuerst (A17 über Profil Oberfläche), Bestand zuerst (A19 über Profil Welt), Spiel-Shader vor jeder Vorlage (W9: steht im Profil Prüfer, fehlt im Profil Figur und Prüfbild), Regelbilanz (L11, nirgends). Ungeprüft: Regelwerk im selben Schritt (L12, Fall schief).
7a. **Werkstatt ohne Handwerk am Commit** (W1, W2, W4, W6): Kerntests stehen nur in Profil Technik und Werkzeug, `[skip ci]` und `MESS=` in keinem Ladetext (nur `probelauf.py`); fremde Änderungen per `git stash` beiseitegeräumt (W1). Die „Handwerksregel“, die der Prüfer bei „steckt fest“ nennen soll, hat keine Quelle (P1, P2, P6).
7b. **Meldewege ohne Nummer oder Ort:** Chefwort ohne Vorgang und Ort des Protokolls (D4), Wecker der Wache und „Stand in deiner Datei“ (R2, R3), Meldenummer des Testers (T2: Build 300 = Vorgang 300) und sein Rückfragewort (T1: Sockel 3 „Frage“ gegen Kern Abnahme „Wörter deines Profils“), Lesart in Klammern ohne Feld in `chefwort` (A5).
8. **Kleinere Textlücken:** Hinweis an Sokrates bei Werkzeugfehler (D1); laute Meldung an den Chef nur, wenn er etwas tun kann (D7); verwandte Vorgänge verknüpfen (A1, dritter Lauf in Folge); „Hinweis: Prüffrage fehlt“ (P6); offene Fäden im Gedächtnis verweisen auf `ARBEIT-BERATUNG.md`, das nach der Umstellung wegfällt.
9. **Werkzeuglücken** (für Spike, nach dem Gespräch): `vorgang.py auftrag --pruefen` nimmt Nummern, die nicht in der Liste stehen (1997–1999 „gültig“); `lauf.py --help` bricht in einer veralteten Kopie ab, statt Hilfe zu zeigen; gültige Empfängernamen für `uebergabe` (Technik, Spike, Figur?) nennt kein Text, das Werkzeug nur alte Namen; Rundblick „fertig“ unter 1734 ohne Titelmarke wird nicht angenommen; `chef_nein` liest „Bisher“ nicht, das Profil Prüfer zählt es; Build ohne Vorgangsnummer hat keinen Weg (`<Nr>` abgelehnt, D6, A3).
10. **Aufbau des Tests** (meine Fehler): L11 verbot das Lesen des zu ändernden Profils; L12 erfand einen Bestand, den es nicht gibt; P7, P8, P9 und W5 trugen Eingänge oder Aufträge aus Lauf 2, die nicht zu den neuen Aufträgen oder zum Repo passen; 1724, 1535, 1569 sind in der Kopie schon erledigt bzw. gebaut; A10, A11, A14, A15 nannten den Chef ohne Wortlaut und Zeit; D6, D7 ohne festes Soll; Startaufträge nicht gesichert.
