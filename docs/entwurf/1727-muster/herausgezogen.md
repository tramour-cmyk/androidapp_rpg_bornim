# 1727 Schritt 1, herausgezogen (21.11., 22:13, Sokrates-Helfer; Auftrag Sokrates, `reihenfolge.md` Schritt 1)

Quelle: `docs/entwurf/1727-gesamtbild.md` an Commit 4d67d1213 (letzte Änderung der Datei; danach unverändert). Je Datei: Kopfzeile, Leerzeile, dann der Text Zeichen für Zeichen. Byte = Text ohne Kopfzeile, UTF-8. Beleg: Python liest beide Dateien, Text == Zeilen a–b des Gesamtbilds und `Text in Gesamtbild`, nur lesend.

| Teil | Datei | Byte | Quelle (Abschnitt, Zeilen) | Beleg exakt |
|---|---|---|---|---|
| Kern Büro | `kern-buero.md` | 2.351 | 3.1, 327–341 | ja |
| Kern Arbeitsplaner (Fassung 2, vor 1727f) | `kern-arbeitsplaner.md` | 2.374 | 4.1, 409–422 | ja |
| Kern Prüfer | `kern-pruefer.md` | 2.529 | 6.1, 790–805 | ja |
| Kern Abnahme | `kern-abnahme.md` | 1.335 | 6.2, 815–823 | ja |
| Profil Prüfer | `profil-pruefer.md` | 1.658 | 6.2, 829–839 | ja |
| Profil Tester | `profil-tester.md` | 1.858 | 6.2, 845–858 | ja |
| Querprofil Signatur und Leben (Fassung 2) | `querprofil-signatur-und-leben.md` | 876 | 1a, 238–244 | ja |
| Profil Figur und Prüfbild | `profil-figur-und-pruefbild.md` | 1.303 | 5.1, 514–518 | ja |
| Profil Regeln (Fassung 2) | `profil-regeln.md` | 1.743 | 5.3 Nr. 2, 556–562 | ja |
| Profil Kampf (Fassung 2) | `profil-kampf.md` | 1.482 | 5.3 Nr. 3, 568–576 | ja |
| Profil Kataloge (Fassung 2) | `profil-kataloge.md` | 1.448 | 5.3 Nr. 5, 584–590 | ja |
| Profil Welt (Fassung 3) | `profil-welt.md` | 1.165 | 5.3 Nr. 6, 644–654 | ja |
| Profil Klang (Fassung 4) | `profil-klang.md` | 645 | 5.3 Nr. 7, 710–714 | ja |
| Profil Oberfläche (Fassung 2) | `profil-oberflaeche.md` | 1.035 | 5.3 Nr. 8, 732–736 | ja |
| Profil Story (Fassung 3) | `profil-story.md` | 1.410 | 5.3 Nr. 9, 772–778 | ja |
| Profil Chefrunde | `profil-chefrunde.md` | 553 | 2.2, 299 | ja |
| Profil Markt und Recherche | `profil-markt-und-recherche.md` | 1.279 | 2.3, 305–312 | ja |

Abweichung zu Tabelle 0.1 je 1 bis 5 Byte (dort mit Zeilenende oder gerundet); Markt und Recherche fehlt in 0.1.

**Nicht herausgezogen:**
- Profil Signatur im Bild (5.2, Zeile 524): ersetzt durch das Querprofil Signatur und Leben (Überblick 0, entschieden 20.11., 12:37).
- Sockel, Kern Leitung, Profile Technik, Disponent, Kosten, Release, Werkzeug, Fremde Inhalte: haben schon eigene Dateien (nicht angefasst).
- Klangkatalog (14:03), Auftragsvorlage 4.2, Routine Wochenzählung 6d, Rundblick 6b: kein Kern oder Profil bzw. eigene Datei vorhanden (`routine-*.md`).

**Entschieden, aber im Gesamtbild noch nicht eingearbeitet (Schritt 2):**
- Kern Arbeitsplaner: 1727f (Archiv 21.11., 21:33) zwei Ladehinweise und „außer markierter Übersetzung“, etwa 2.558 Byte; Text dazu nur in der gelöschten Chefsache (`git show 605dcd2f1^:docs/chefsache/entscheiden/1727f-kern-arbeitsplaner.md`). Herausgezogen ist die Fassung, auf die 1727f verweist (Gesamtbild :419).
- Profil Chefrunde, Kern Büro: 1727d (Archiv 21:31), Sätze L-U10 und L-O1 offen.
- Kern Büro, Kern Arbeitsplaner, Kern Abnahme: Folgen aus 3.3 Fassung 2 Nr. 8 („Jede Rückmeldung weckt dich“, „die Sitzung, die dich gestartet hat“).
- Kern Prüfer (6.1) wird durch Kern Abnahme mit Profil Prüfer (6.2) ersetzt, sobald der Falltest besteht.

**Ladesumme je Sitzungsart** (Byte, aus Tabelle 0.1 und den Messungen oben; ohne Haken):

| Sitzungsart | Teile | Summe |
|---|---|---|
| Leitung | Sockel 1.110 + Kern Leitung 2.838 | 3.948; dazu Gedächtnis bis 3 KB, auf Zuruf Chefrunde 553 oder Markt und Recherche 1.279 |
| Büro: Disponent | Sockel + Kern Büro 2.351 + Profil Disponent | offen (Profil Disponent in eigener Datei, Kern Büro nach 3.3 noch umzuschreiben) |
| Büro: Arbeitsplaner | Sockel + Kern Arbeitsplaner 2.374 | 3.484 (nach 1727f etwa 3.668); nach 3.3 Kern Büro + Profil Arbeitsplaner: offen |
| Werkstatt Welt | Sockel + Signatur und Leben 876 + Welt 1.165 + Figur und Prüfbild 1.303 | 4.454 + Auftrag (bis 1,5 KB) |
| Werkstatt Text | Sockel + Story 1.410 | 2.520 + Auftrag |
| Werkstatt andere Fächer | Sockel + Fachprofil (+ Querprofil bei Bild oder Klang, + geladene Profile) | je Auftrag, offen |
| Abnahme: Prüfer | Sockel + Kern Abnahme 1.335 + Profil Prüfer 1.658 | 4.103 + Auftrag (heute Kern Prüfer: 3.639) |
| Abnahme: Tester | Sockel + Kern Abnahme 1.335 + Profil Tester 1.858 | 4.303 |
| Routinen | Sockel + fester Auftrag | offen |
