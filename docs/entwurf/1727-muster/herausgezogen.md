# 1727 Schritt 1, herausgezogen (21.11., 22:13, Sokrates-Helfer; Auftrag Sokrates, `reihenfolge.md` Schritt 1) · Fassung 2 (21.11., 22:26, Gegenprüfung 22:22 B6, B11): Übergabekette nach Messregel (ohne Kopfzeile, Leerzeile, letztes Zeilenende) 2.134 → 2.290 → 2.399, Absatz „Schritt 2“ auf Stand; Byte der Datei 5.241 → 5.457 · Fassung 3 (21.11., 22:39, Nachprüfung 22:29 H1, H2): Messregel an beiden Stellen, Wochenzählung 6.318 → 6.561, Hinweis `kern-buero.md`:11 unter „3.3 Nr. 8 offen“; Byte 5.457 → 6.332 (Messregel) · Fassung 4 (21.11., 22:50, Gegenprüfung 22:44): Kern Büro schmal, Kern Abnahme, Profil Prüfer, Profil Tester, Kopf Kern Prüfer; Ladesummen Abnahme und Disponent; Byte 6.332 → 7.711 (Messregel) · Fassung 5 (21.11., 22:5x, Konsolidierung Sokrates): Messregel-Wortlaut an beiden Stellen (Ladetext bzw. Teil A); Stände Stand 8c4da3b8d; Ladesummen Disponent 4.858, Arbeitsplaner 4.346 (ohne Kern Büro 3.666); Byte 7.711 → 10.161 (Messregel) · Fassung 6 (21.11., 23:12): Ladesummen bereinigt (Nachprüfungen 23:00/23:03), Sockel 1.109, Kern Leitung 2.837, Chefrunde 574 nachgemessen; kein Ladetext, ganze Datei Byte 10.161 → 11.122 (Messregel: ohne Kopfzeile und Leerzeile danach, ohne letztes Zeilenende)

Quelle: `docs/entwurf/1727-gesamtbild.md` an Commit 4d67d1213 (letzte Änderung der Datei; danach unverändert). Je Datei: Kopfzeile, Leerzeile, dann der Text Zeichen für Zeichen. Byte nach Messregel: ohne Kopfzeile und die Leerzeile danach, ohne letztes Zeilenende, UTF-8; bei Dateien mit Prüfabschnitten zählt der Ladetext (bis zum ersten „##“ bzw. der Codeblock Teil A, wie in der Datei angegeben). Beleg: Python liest beide Dateien, Text == Zeilen a–b des Gesamtbilds und `Text in Gesamtbild`, nur lesend.

| Teil | Datei | Byte | Quelle (Abschnitt, Zeilen) | Beleg exakt | nach Schritt 2 (21.11., 22:16) |
|---|---|---|---|---|---|
| Kern Büro | `kern-buero.md` | 2.351 | 3.1, 327–341 | ja | 680 (Fassung 2 „Kern Büro schmal“, Archiv 21.11., 11:46, Gegenprüfung 22:44; Fassung 1 als Verlauf in der Datei, ganze Datei 5.096; Sätze für Profil Disponent in dessen F9 als Vorschlag Sokrates, 22:5x) |
| Kern Arbeitsplaner (Fassung 2, vor 1727f) | `kern-arbeitsplaner.md` | 2.374 | 4.1, 409–422 | ja | 2.556 (1727f) |
| Kern Prüfer | `kern-pruefer.md` | 2.529 | 6.1, 790–805 | ja | unverändert; Kopf „Verlauf, nicht laden, nur Vergleich im Falltest“ (22:44) |
| Kern Abnahme | `kern-abnahme.md` | 1.335 | 6.2, 815–823 | ja | 1.183 (Fassung 2, Gegenprüfung 22:44 Nr. 1–5: Meldeweg `vorgang.py rueckmeldung`, Querprofil, Eintauchen, Quelle im Auftrag, Meldeform ins Profil; ganze Datei 2.327) |
| Profil Prüfer | `profil-pruefer.md` | 1.658 | 6.2, 829–839 | ja | 1.854 (Fassung 2, 22:44 Nr. 1, Meldeform aus dem Kern; ganze Datei 2.485; offen: drittes „Beleg fehlt“ Chefsache, Falltestfall Chef-Nein) |
| Profil Tester | `profil-tester.md` | 1.858 | 6.2, 845–858 | ja | 1.962 (Fassung 2, 22:44 Nr. 2–4; ganze Datei 2.745; Werkzeuglücke 1795; offen: Release-Prüfung, Takt, Testbitte, Chefsache) |
| Querprofil Signatur und Leben (Fassung 2) | `querprofil-signatur-und-leben.md` | 876 | 1a, 238–244 | ja | unverändert |
| Profil Figur und Prüfbild | `profil-figur-und-pruefbild.md` | 1.303 | 5.1, 514–518 | ja | unverändert |
| Profil Regeln (Fassung 2) | `profil-regeln.md` | 1.743 | 5.3 Nr. 2, 556–562 | ja | unverändert |
| Profil Kampf (Fassung 2) | `profil-kampf.md` | 1.482 | 5.3 Nr. 3, 568–576 | ja | unverändert |
| Profil Kataloge (Fassung 2) | `profil-kataloge.md` | 1.448 | 5.3 Nr. 5, 584–590 | ja | unverändert |
| Profil Welt (Fassung 3) | `profil-welt.md` | 1.165 | 5.3 Nr. 6, 644–654 | ja | unverändert |
| Profil Klang (Fassung 4) | `profil-klang.md` | 645 | 5.3 Nr. 7, 710–714 | ja | unverändert |
| Profil Oberfläche (Fassung 2) | `profil-oberflaeche.md` | 1.035 | 5.3 Nr. 8, 732–736 | ja | unverändert |
| Profil Story (Fassung 3) | `profil-story.md` | 1.410 | 5.3 Nr. 9, 772–778 | ja | unverändert |
| Profil Chefrunde | `profil-chefrunde.md` | 553 | 2.2, 299 | ja | 574 (1727d L-U10) |
| Profil Markt und Recherche | `profil-markt-und-recherche.md` | 1.279 | 2.3, 305–312 | ja | unverändert |
| Übergabekette 3.3 (Fassung 2; herausgezogen 21.11., 22:18) | `uebergabekette.md` | 2.134 | 3.3, 369–377 | ja | 2.290 (1727d L-S2/L-U8 Nr. 3, L-U15 Nr. 7); 2.399 (Fassung 4, Freigabewörter Nr. 7, 22:25) |

**Stand 8c4da3b8d (22:5x; Disponent, Werkzeug, Fremde Inhalte mit diesem Commit)**, Byte nach Messregel: ohne Kopfzeile und die Leerzeile danach, ohne letztes Zeilenende, UTF-8; bei Dateien mit Prüfabschnitten zählt der Ladetext (bis zum ersten „##“ bzw. der Codeblock Teil A, wie in der Datei angegeben); Ladetext / ganze Datei:
- Übergabekette `uebergabekette.md` (F6): Text bis Nr. 8 2.442 / 3.502
- Profil Disponent `profil-disponent.md` (F9): Profiltext 3.068 / 15.175
- Routine Wochenzählung `routine-wochenzaehlung.md` (F6): Text 1.938 / 7.464
- Profil Technik `profil-technik.md`: Teil A 1.219, Teil B 4.232 / 17.781
- Kern Büro `kern-buero.md` (F2): 680 / 5.096
- Kern Abnahme `kern-abnahme.md` (F2): 1.183 / 2.327
- Profil Prüfer `profil-pruefer.md` (F2): 1.854 / 2.485
- Profil Tester `profil-tester.md` (F2): 1.962 / 2.745
- Profil Werkzeug `profil-werkzeug.md` (F9): Teil A 1.103 / 21.621
- Querprofil Fremde Inhalte `profil-fremde-inhalte.md` (F9): Teil A 1.168 / 20.976
- Routine Rundblick `routine-rundblick.md` (F7): Teil A 1.168 (Kopf dort 1.169, mit Zeilenende) / 24.447

**Schritt 2, weitere Dateien, Verlauf** (nicht herausgezogen, Byte der ganzen Datei nach Messregel wie oben): `profil-technik.md` 16.543 → 16.594 (1727d L-T6, Vorschlagstext Checkliste 13); `profil-disponent.md` 7.614 → 7.993 → 8.162 → 8.558, Profiltext 2.275 → 2.422 → 2.433 (1727c in Satz :22 eingebaut, Wortlaut Vorschlag Sokrates; „gut“ in :20); `profil-kosten.md` 3.490 → 3.721 (1727e vermerkt, kein Profiltext); `routine-wochenzaehlung.md` 6.318 → 6.561 (1727c als entschieden vermerkt, Text unverändert 1.938); 3.3 als `uebergabekette.md` mit 1727d L-S2/L-U8 (Nr. 3) und L-U15 (Nr. 7) eingebaut. Stand 22:25 (Gegenprüfung 22:22): `profil-technik.md` 17.090. Offen: L-O1 (Kern Leitung, Gespräch); 3.3 Nr. 8 ohne Wortlaut.

Abweichung zu Tabelle 0.1 je 1 bis 5 Byte (dort mit Zeilenende oder gerundet); Markt und Recherche fehlt in 0.1.

**Nicht herausgezogen:**
- Profil Signatur im Bild (5.2, Zeile 524): ersetzt durch das Querprofil Signatur und Leben (Überblick 0, entschieden 20.11., 12:37).
- Sockel, Kern Leitung, Profile Technik, Disponent, Kosten, Release, Werkzeug, Fremde Inhalte: haben schon eigene Dateien (nicht angefasst).
- Klangkatalog (14:03), Auftragsvorlage 4.2, Routine Wochenzählung 6d, Rundblick 6b: kein Kern oder Profil bzw. eigene Datei vorhanden (`routine-*.md`).

**Entschieden, aber im Gesamtbild noch nicht eingearbeitet (Schritt 2):**
- Kern Arbeitsplaner: 1727f (Archiv 21.11., 21:33) zwei Ladehinweise und „außer markierter Übersetzung“, eingebaut 2.556 Byte (Messregel; vorher geschätzt etwa 2.558); Text dazu nur in der gelöschten Chefsache (`git show 605dcd2f1^:docs/chefsache/entscheiden/1727f-kern-arbeitsplaner.md`). Herausgezogen ist die Fassung, auf die 1727f verweist (Gesamtbild :419).
- Profil Chefrunde, Kern Büro: 1727d (Archiv 21:31), Sätze L-U10 und L-O1 offen.
- Kern Büro, Kern Arbeitsplaner, Kern Abnahme: Folgen aus 3.3 Fassung 2 Nr. 8 („Jede Rückmeldung weckt dich“, „die Sitzung, die dich gestartet hat“). Stand 22:50 (Gegenprüfung 22:44): Kern Abnahme eingearbeitet (Meldung über `vorgang.py rueckmeldung`); Kern Büro schmal trägt den Satz nicht mehr, er steht seit Profil Disponent F9 (22:5x) als Vorschlag Sokrates in :14 („sofort, Anhalt 5 Minuten, Stundenuhr nur Nachlese“; `kern-buero.md`, Gegenprüfung, Liste Nr. 3); Kern Arbeitsplaner offen.
- Kern Prüfer (6.1) wird durch Kern Abnahme mit Profil Prüfer (6.2) ersetzt, sobald der Falltest besteht.

**Ladesumme je Sitzungsart** (Byte nach Messregel; Sockel 1.109 und Kern Leitung 2.837 aus den Codeblöcken von `1727-gesamtbild.md` 1 und 2.1 Fassung 2, Chefrunde 574 aus `profil-chefrunde.md`, neu gemessen 21.11., 23:10; übrige aus den Messungen oben und Tabelle 0.1; ohne Haken):

| Sitzungsart | Teile | Summe |
|---|---|---|
| Leitung | Sockel 1.109 + Kern Leitung 2.837 | 3.946; dazu Gedächtnis bis 3 KB, auf Zuruf Chefrunde 574 oder Markt und Recherche 1.279 |
| Büro: Disponent | Sockel 1.109 + Kern Büro 680 (schmal) + Profil Disponent 3.040 (Profiltext F10) | 4.829 (F9: 1.110 + 680 + 3.068 = 4.858) |
| Büro: Arbeitsplaner | Sockel 1.109 + Kern Büro 680 + Kern Arbeitsplaner 2.649 (F4) | 4.438 (ohne Kern Büro 3.758); + Profil Werkzeug Teil A 1.103 = 5.541, + Querprofil Fremde Inhalte Teil A 1.168 = 5.606; Profil Arbeitsplaner nach 3.3: offen |
| Werkstatt Welt | Sockel + Signatur und Leben 876 + Welt 1.165 + Figur und Prüfbild 1.303 | 4.453 + Auftrag (bis 1,5 KB) |
| Werkstatt Text | Sockel + Story 1.410 | 2.519 + Auftrag |
| Werkstatt andere Fächer | Sockel + Fachprofil (+ Querprofil bei Bild oder Klang, + geladene Profile) | je Auftrag, offen |
| Abnahme: Prüfer | Sockel + Kern Abnahme 1.567 (F3) + Profil Prüfer 2.030 (F3) (+ Querprofil Signatur und Leben 876, + Querprofil Fremde Inhalte Teil A 1.168, wenn der Auftrag sie zulädt) | 4.706, mit Signatur und Leben 5.582, mit beiden 6.750, + Auftrag (heute Kern Prüfer: 3.638) |
| Abnahme: Tester | Sockel + Kern Abnahme 1.567 + Profil Tester 2.473 (F3) (+ Querprofil 876, wenn geladen) | 5.149, mit Querprofil 6.025 |
| Routinen | Sockel + fester Auftrag | offen |

## Nachprüfung 22:29/22:30, mein Wort

Mein Wort (Sokrates): alle **stimmt**. H1 Messregel: **stimmt, eingearbeitet**, an beiden Stellen (Kopf „Byte = …“ und „Schritt 2“) „ohne Kopfzeile, ohne Leerzeile, ohne letztes Zeilenende“ · H2 Wochenzählung: **stimmt, eingearbeitet**, `routine-wochenzaehlung.md` 6.318 → 6.561 in „Schritt 2“ · Hinweis aus `uebergabekette.md` (`kern-buero.md`:11 nur „gut“, Beleg): **stimmt, eingearbeitet**, Zeile Kern Büro unter „3.3 Nr. 8 offen“.

## Gegenprüfung 22:44, mein Wort

Byte nachgezogen: stimmt, eingearbeitet (Kern Büro 680, Kern Abnahme 1.183, Profil Prüfer 1.854, Profil Tester 1.962, Kern Prüfer unverändert 2.529; Ladetext nach Messregel bis zum ersten „##“ der Datei) · Ladesummen Abnahme mit und ohne Querprofil 876, Disponent 4.223: stimmt, eingearbeitet · 3.3 Nr. 8: Kern Abnahme erledigt, Kern Büro an Profil Disponent weitergereicht (offen), Kern Arbeitsplaner offen.

## Konsolidierung 22:5x, mein Wort

Mein Wort (Sokrates), Fassung 5: **stimmt, eingearbeitet**. Messregel-Wortlaut an beiden Stellen (Kopf „Byte nach Messregel“ und Standliste vor „Schritt 2“): ohne Kopfzeile und die Leerzeile danach, ohne letztes Zeilenende, UTF-8; Ladetext bis zum ersten „##“ bzw. Codeblock Teil A · Stände auf Stand 8c4da3b8d als Liste (Übergabekette, Disponent F9, Wochenzählung, Technik, Kern Büro, Kern Abnahme, Prüfer, Tester, Werkzeug F9, Fremde Inhalte F9, Rundblick); Rundblick Teil A nach Messregel 1.168 (dort im Kopf 1.169 mit Zeilenende, nicht meine Datei) · Ladesummen: Disponent 1.110 + 680 + 3.068 = 4.858; Arbeitsplaner 1.110 + 680 + 2.556 = 4.346, ohne Kern Büro 3.666 (statt „etwa 3.668“), mit Werkzeug 5.449, mit Fremde Inhalte 5.514 · Kern Büro, Sätze für den Disponenten: in Profil Disponent F9 als Vorschlag Sokrates (Tabelle, „3.3 Nr. 8“) · Kern Arbeitsplaner 2.556 statt „etwa 2.558“.

## Runde 23:05, mein Wort

- Nur die Tabelle „Ladesumme je Sitzungsart“ und ihr Einleitungssatz geändert: statt „aus Tabelle 0.1“ jetzt Sockel 1.109 und Kern Leitung 2.837 (Codeblöcke `1727-gesamtbild.md` :173–:186 und Fassung 2 :275–:292) und Chefrunde 574 (`profil-chefrunde.md`), nach Messregel nachgemessen, nur lesend. Dazu die Ladetexte dieser Runde: Disponent 3.040, Kern Arbeitsplaner 2.649, Kern Abnahme 1.567, Profil Prüfer 2.030, Profil Tester 2.473; Kern Büro 680 unverändert. Prüfer mit beiden Querprofilen ergänzt (Kern Abnahme Fassung 3 lädt Fremde Inhalte zu).
- Standliste „Stand 8c4da3b8d“, Tabelle oben und Abschnitt „Entschieden, aber …“ nicht nachgezogen (Begleittext).
- Kein vom Chef abgenommener Text berührt.
