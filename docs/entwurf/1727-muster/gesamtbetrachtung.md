# 1727, Gesamtbetrachtung: bringt der Prozess bessere Ergebnisse? (Sokrates 21.11., 10:36, Fassung 2, gegengeprüft)

Frage Chef 21.11., 10:28 (Vorrat „Zu 1727, Gesamtbetrachtung“): Sitzungen kleiner ist erreicht; unterstützt der Prozess auch bessere Ergebnisse, ist es der Prozess, den wir dafür brauchen? Wenn ja: heute Abend; wenn zum Teil: wie die neuen Bausteine verwenden; „ganz viel hängt ja einfach vom Auftrag ab“.

## Befund (frischer Prüfer 10:31, Stand `c6a9b93d1`, 20 echte Fälle der letzten 14 Tage)

| Fall | Ursache | neuer Prozess fängt? | Element |
|---|---|---|---|
| 760 Wolfsbiss zu kurz (t298, t300; 37 $) | Prüfung: Messung grün, Bild anders | teilweise | 4.1 Nr. 5 „gilt das Bild“, Film seitlich; Prüfer am Bild unbelegt (`kerne-falltest.md` 25) |
| 1043 Ausweichen nicht sichtbar | Prüfung | ja | 6.2 Schritt 1 „Neues drin“ |
| 1535 Kittel beult aus | Prüfung: falsche Bewegung gemessen | teilweise | 4.1 Nr. 6 Prüffrage |
| 1621 Zweihänder Fingerspitzen | Prüfung: angesehen, nicht gesehen | teilweise | 5.1 Profil Figur |
| 1694 Griff (33 $) | Können: Knochen gemessen, Netz gezeichnet | teilweise | 5.1 „gemessen wird, was man sieht“ |
| 1665 Streitkolben unsichtbar (Wiederholung 522) | Prüfung | teilweise | Katalogfrage prüft nicht „hat Modell“ |
| 1664 Goblins gleiten | Übergabe: gebilligt, nie auf `main` | teilweise | nur Tester; Merge ohne Text |
| 1566 Höhlenwasser leuchtet | Prüfung, dann Fix beim Merge verloren | teilweise | Prüfbild ja, Merge-Verlust nein |
| Umhang (19 Vorgänge) | Können: Stoff in der Engine | teilweise | Systemfrage 4.1 Nr. 2; Lösung erst Technik 1735 |
| 1675 Schild schwebt | unklar | unklar | – |
| 1674 Bewohner hängt an der Bank | Prüfung: kein Durchspielen | nein | Tester ohne Werkzeug (1738) |
| 1270.6 Einmessung Niedrig | Können: nur am Gerät | nein | Prüfer lässt Handy aus (6.2) |
| t299 Standbild als Handy-Punkt | Regel nicht befolgt | ja | 4.1 Nr. 6, Prüfer Schritt 2 |
| 1650 👍 ohne Bild | Regel nicht befolgt | ja | 6.2 „erst sehen“ |
| Build 300 „freigegeben“ | anderes | nein | – |
| Steckbrief „Tagwerk“, Seltenheit 4 statt 6 | Regel nicht befolgt (nicht raten) | nein | Sockel = alte Haltung |
| Tagesbericht fehlte | Übergabe | teilweise | 6d Routine, Werkzeug fehlt |
| Vorrang aus Helfertext (21.11.) | Regel nicht befolgt | nein | Leitung ohne Prüftor |
| 901 „Hoch“ wirkte nicht | Prüfung | ja | 4.2 F2 nach 1742 |
| 1301 👎 ohne Wort | Übergabe | teilweise | 4.1 Nr. 3 jedes Nein wörtlich |

Zählung: Ursache Prüfung 8, Regel nicht befolgt 4, Können 3, Übergabe 3, anderes 1, unklar 1. Urteil ja 4, teilweise 10, nein 5, unklar 1. Bei den 12 Spielfehlern: ja 1, teilweise 8, nein 2, unklar 1. **Auftrag:** kein falsches Ziel, aber in 4 von 6 Fällen des Falltests fehlte die Prüffrage im Auftrag (760 Seitenkamera, 1694 früheres Nein, 1535 Commit im Bild, 1650 Name; `kerne-falltest.md` 7–11): „Auftrag falsch im Prüfteil: 4“.

## Votum (Fassung 2, 10:36, gegengeprüft): ja, mit einer Bedingung, heute Abend umstellen wie entschieden

1. **Ziel** (Chef 19.11., 08:30 „ganz, ganz, ganz kleine Prompts“; 19.11., 22:13–22:20 „nichts liegt lange“; 21.11., 10:28 „Regeln schärfen, dass die Ergebnisse besser werden“): Größe, Fluss und Qualität. Größe ist selbst ein Hebel für Qualität: 4 der 20 Fälle sind „Regel stand da, nicht befolgt“; weniger Geladenes heißt weniger Übersehenes (Spike „reingeballert“, 19.11.).
2. **Qualität am Spiel** hängt am Prüfteil des Auftrags (Prüffragen, „Bisher“ mit jedem früheren Nein wörtlich) und am frischen Prüfer am Bild. These des Chefs stimmt: am Auftrag hängt es, aber an seinen Prüffragen, nicht am Ziel. Gegen Wiederholer wirkt das stark, gegen den ersten Fund schwach (die Prüffrage kennt man oft erst nach dem ersten Nein).
3. **Bedingung: ob der Prüfer am Bild sieht, ist unbelegt** (dasselbe Modell übersah 1621, 1650, 1535, 1694; er sieht, wenn er weiß, wonach er sucht: Spike bei 1694, Sokrates bei 1535). Darum als erster Fall im Falltest heute Abend (steht schon dort, `kerne-falltest.md` 25): Bilder alt gegen neu, gemischt mit fehlerfreien, je einmal **ohne** und **mit** Prüffrage. Bilder: in Git nur `chefsache/bilder/1566-hoehlenwasser.webp`, `t298-5-teich-chef.webp`; 1535, 1621, 1694 kamen über Telegram, werden aus den Zweigen neu gerendert; 760 war Film, nur als Film prüfen. Ergebnis schaltet „Prüfer am Bild“ an (sieht er ohne Prüffrage) oder auf „nur mit Prüffrage“ oder aus (dann Messung am gezeichneten Bild, Spike, und Tester am Gerät).
4. **Nicht getroffen, gehört in die Reihenfolge Schritt 2:** Können und Technik (Stoff, Griff, Gerät: bleibt Technik); Merge und Build (Profil Technik zuerst, mit Prüfpunkt „Gebilligtes ist auf `main`“; 1566, wohl 1664); Handy und Durchspielen (1738); „nicht nachgesehen“ bei Leitung und Büro (kein Prüftor; Gegenmittel Größe und Lehren im Gedächtnis).
5. **3.3** (entschieden 10:11) dient Fluss und Größe; die zusätzlichen Übergaben sichert 1760 (Test vor Umstellung).

## Stärkstes Gegenargument

Der Qualitätsgewinn am Spiel steht und fällt mit einem Prüfer, dessen Blick unbelegt ist; die Umstellung kostet den ganzen Abend und mehr, und wenn er nicht sieht, bleibt am Spiel fast alles beim Chef. Entkräftet: die Umstellung lohnt sich auch dann (Größe, Fluss, Wiederholer über „Bisher“), und der Test kommt als erster Fall, bevor auf den Prüfer am Bild gebaut wird.

## Gegenprüfung 10:34 (frischer Helfer, 8 Befunde), mein Wort

1 Zählung Spielfehler teilweise 8, unklar 1: **stimmt**, berichtigt · 2 „Auftrag falsch 0“ hängt an der Einteilung, Prüfteil 4: **stimmt** · 3 1664 „nie auf main“ unbelegt (Liste: erledigt, t300 bestanden): **stimmt**, „wohl“ · 4 Ziel zu eng (Größe, Fluss): **stimmt** · 5 „ohne Eile“ widerspricht Chef 20.11., 10:31 „so lange arbeiten, bis wir umstellen können“: **stimmt**, gestrichen · 6 Test nicht neu, Bilder fehlen, nicht blind, Maß dünn, Film: **stimmt**, in den Falltest mit und ohne Prüffrage · 7 stärkeres Gegenargument: Größe selbst ist Qualitätshebel: **stimmt**, ins Votum · 8 Option volle Umstellung fehlt: **stimmt**, jetzt Votum.
