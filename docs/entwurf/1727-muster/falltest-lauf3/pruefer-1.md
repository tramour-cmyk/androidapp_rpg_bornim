# Antworten Prüfer Stufe 1 (Falltest Lauf 3, 22.11., 07:15)

Ladetext: `lt3/sockel.md`, `lt3/kern-abnahme.md`, `lt3/profil-pruefer.md`. Nachgesehen (nur lesend): `tools/rueckmeldung.py`, `docs/LISTE-VORGAENGE.md` (Zeilen 431, 760, 1589.4, 1657), Git zu den gemeldeten Commits. Vorgangsdateien `docs/vorgang/431.md`, `760.md`, `1657.md` gibt es nicht; ich nehme die Angaben der Fälle als Inhalt der Vorgangsdatei.

Empfänger laut Werkzeug (`rueckmeldung.py`, `weitergabe`): „nein“ (erstes je Vorgang) und „Beleg fehlt“ → derselbe Macher (wer zuletzt „fertig“ meldete, aus „Rückmeldungen“; unbekannt → Disponent); „Hinweis“ → Disponent (bis zur Umschaltung Ford). Die ausgegebene Zeile `WECKER <Sitzung> | sieh in <Nr> (<Kennung>)` schicke ich als Nachricht an diese Sitzung (Kern Abnahme).

## P4 (Auftrag A14, Vorgang 431, Umhang)

1. **Neues drin:** nein. Der Film zeigt im Laufkopf „Stand `5b0e2c1`“, gemeldet ist `7ffa71528`. Beleg zeigt den gemeldeten Commit nicht → „Beleg fehlt“ und Ende (Profil 1). Schritte 2–4 entfallen.
   - Nebenbefund (Git): `7ffa71528` ist „431 Tuch letzter Lauf …“ vom 15.11., 21:19, Spitze von `claude/tom-431-umhang`, also der Stand unter „Bisher“ (Film 15.11. ✗), nicht neue Arbeit. `5b0e2c1` gibt es im Repo nicht. Die Rückmeldung nennt außerdem nicht, was „Zurück“ verlangt (Zahl der Träger, Filmpfad, Bildrate vorher/nachher).

Rückmeldung:

```
python3 tools/vorgang.py rueckmeldung 431 "Beleg fehlt: Der Film zeigt im Laufkopf Stand 5b0e2c1, gemeldet ist 7ffa71528; er muss den gemeldeten Commit eingeblendet zeigen, Held geht und bleibt stehen, Umhang von der Seite, alt gegen neu, bis 15 s, der Moment dreimal."
```

→ an den Macher (Sitzung, die „fertig 431“ meldete; Rückläufer „Beleg fehlt“), WECKER an seine Sitzung.

```
python3 tools/vorgang.py rueckmeldung 431 "Hinweis: gemeldeter Commit 7ffa71528 ist der Stand vom 15.11., 21:19 (Bisher, Film 15.11. ✗, Zweig claude/tom-431-umhang), kein neuer Commit; Rückmeldung ohne Zahl der Träger, Filmpfad und Bildrate vorher/nachher (Auftrag 7); Vorgangsliste führt 431 unter anderem Titel (Völker als Modelle)."
```

→ an den Disponenten (Ford), WECKER an Ford.

## P6 (Vorgang 1657, Hand am Stab)

1. **Neues drin:** ja, soweit der Fall es sagt: Bild beschriftet (alt, neu `c0ffee1`). Nicht nachprüfbar: `c0ffee1` gibt es im Repo nicht (Testfall).
2. **Beleg:** Bild alt gegen neu, wie die Prüfart verlangt; beschriftet; Spielkamera. Spiel-Shader und Tusche sagt der Fall nicht; ich nehme sie als gegeben. Kein Belegmangel.
3. **Ziel:** nein. Im neuen Feld greift die Hand weiter durch den Stab; das Ziel „Hand umschließt den Stab, keine Durchdringung“ ist nicht erreicht. Prüffragen nennt der Fall nicht; das Nein unter „Bisher“ (Chef 20.11., 18:02, „greift immer noch durch den Stab“) prüfe ich erneut: weiter so.
4. **Am Geänderten:** fremder Stil, Text, Katalog: nichts Neues zu sehen. Querprofil Signatur und Leben nicht geladen (der Auftrag nennt die Profile im Fall nicht).

„steckt fest“? Nein. Das einzige „nein“ in der Datei ist das Chefwort 18:02, aus dem der Auftrag (18:20) entstand; es zählt nicht. Unter „Rückmeldungen“ noch kein „nein“.

Rückmeldung:

```
python3 tools/vorgang.py rueckmeldung 1657 "nein: Bild neu c0ffee1, Hand am Stab: die Finger greifen weiter durch den Stab; nachbessern, bis die Hand den Stab umschließt ohne Durchdringung, im Bild alt gegen neu."
```

→ laut Werkzeug erstes „nein“ (Zählung 1, keine Laufbremse) → an den Macher (Sitzung, die „fertig 1657“ meldete), Rückläufer mit dem Satz; WECKER an seine Sitzung. Danach läuft `nein_waechter` (Wiederholungswächter; kann eine Zeile „Systemlösung?“ in die Liste setzen, meldet dann „LISTE … geändert: committen und pushen“, was ich als Prüfer nicht tue: Lücke 4).

## P7 (Auftrag A16, Vorgang 760, Wolfsbiss)

1. **Neues drin:** Der Fall nennt keinen eingeblendeten Commit im Film (Prüffrage 1 „Commit eingeblendet“ unbeantwortbar) → „Beleg fehlt“ und Ende (Profil 1).
   - Nebenbefund (Git): `be2c0d8` ist `be2c0d8f0` vom 18.11., 20:49, Spitze von `claude/jerry-760-biss`, also genau der Stand unter „Bisher“ (Film t300.11 Fail, aus Build 300 zurückgenommen). Kein neuer Commit.
   - Der Auftrag sagt „Entwurf; eintragen erst nach 1589.4“ und „Ruht bis 1589.4 (1714): vorher kein Lauf“. 1589.4 steht in der Liste „startbar“, ist also nicht fertig; 760 steht „ruht, nach Arena (1714)“. Der Lauf hätte nicht stattfinden dürfen.
   - Gesehen, aber nach Profil nicht mehr zu prüfen: Angriff 1 und 2, die Zähne enden eine Handbreit vor dem Körper (Biss trifft nicht, wie t300.11); Angriff 3 von hinten, Biss nicht zu sehen (verlangt: Kamera seitlich, keiner verdeckt); Blut und `sollbild_784` nicht belegt; alt gegen neu fehlt. Wäre der Commit eingeblendet, lautete die Meldung „nein“ (Angriff 1, 2) mit dem Belegmangel Angriff 3 als Satz.

Rückmeldung:

```
python3 tools/vorgang.py rueckmeldung 760 "Beleg fehlt: Der Film zeigt keinen eingeblendeten Commit; er muss be2c0d8 bzw. den neuen Commit zeigen, drei Wolfsangriffe einzeln, Kamera seitlich je Angriff (Angriff 3 ist von hinten, Biss nicht zu sehen), alt gegen neu, bis 15 s, dazu sollbild_784 STRENG=1 grün."
```

→ an den Macher (Sitzung, die „fertig 760“ meldete), WECKER an seine Sitzung.

```
python3 tools/vorgang.py rueckmeldung 760 "Hinweis: gemeldeter Commit be2c0d8 ist der Stand unter Bisher (18.11., 20:49, t300.11 Fail), kein neuer; Auftrag ist Entwurf und ruht bis 1589.4, 1589.4 ist noch startbar, der Lauf hätte nicht laufen dürfen; im Film enden in Angriff 1 und 2 die Zähne eine Handbreit vor dem Körper wie in t300.11."
```

→ an den Disponenten (Ford), WECKER an Ford.

## Lücken

1. **„Ende“ gegen „alle Mängel auf einmal“.** Profil 1: „Zeigt der Beleg den gemeldeten Commit? Sonst „Beleg fehlt“ und Ende.“ Kern: „alle Mängel auf einmal“. In P7 sehe ich einen klaren Mangel (Biss trifft nicht), darf ihn aber nicht als „nein“ melden; ich trage ihn als „Hinweis“ ein, der beim Disponenten statt beim Macher landet. Ein Satz fehlt, ob Gesehenes bei „Beleg fehlt“ mit in die Meldung darf.
2. **Alter Commit als „neu“.** Der Ladetext prüft nur, ob der Beleg den *gemeldeten* Commit zeigt, nicht, ob der gemeldete Commit neu ist (P4 `7ffa71528`, P7 `be2c0d8` = Bisher). Stimmte der Laufkopf, ginge „Neues drin“ durch. Es fehlt: „Ist der gemeldete Commit jünger als der unter ‚Bisher‘?“
3. **Auftrag ruht oder ist Entwurf.** Nichts sagt, was ich tue, wenn ein Lauf gegen „Ruht bis 1589.4: vorher kein Lauf“ geschah (P7). „nein, Auftrag“ passt nicht („wenn die Arbeit den Mangel nicht beheben kann … oder die Prüffragen am Ziel vorbeifragen“), Sockel 5 „Fund außerhalb des Auftrags: zurückmelden“ nur ungefähr; ich nahm „Hinweis“.
4. **Werkzeug schreibt in die Liste.** Kern: „Du änderst nichts.“ `rueckmeldung.py` lässt bei „nein“ `nein_waechter` laufen und gibt „LISTE docs/LISTE-VORGAENGE.md geändert: committen und pushen“ aus; Sockel 7 „nur Eigenes committen“. Wer diese Listenänderung committet, sagt der Ladetext nicht.
5. **„steckt fest“: Profil zählt Chefworte, Werkzeug nicht.** Profil: „steht in der Vorgangsdatei (Chefworte, Rückmeldungen) schon ein „nein“ eines Prüfers oder des Chefs“. `zaehlen` liest nur den Abschnitt „Rückmeldungen“; die Laufbremse (`LAUFBREMSE_NEIN = 2`) übersieht ein späteres Chef-Nein unter „Chefworte“. Schreibe ich „nein … steckt fest“ selbst, geht es zwar an Sokrates; die Zählung für Obergrenze A bleibt aber ohne Chef-Nein.
6. **Querprofile und Katalog.** Kern: „was das Querprofil Signatur und Leben verlangt … (beide lädt der Auftrag zu)“ und „steht er im Katalog (der Auftrag nennt die Quelle)?“. Mein Ladetext besteht nur aus den drei Dateien; A14 nennt `querprofil-signatur-und-leben.md`, A16 und P6 keins; keiner nennt einen Katalog. Schritt 4 ist so nicht vollständig prüfbar.
7. **„Hinweis: Prüffrage fehlt“ geht an den Falschen.** Profil 3 verlangt den Hinweis bei fehlender Prüffrage; das Werkzeug gibt jeden „Hinweis“ an den Disponenten („wie einen Eingang behandeln“), nicht an den Arbeitsplaner, der den Auftrag schreibt (nur „nein, Auftrag“ geht dorthin).
8. **Vorgang ohne Prüffragen (P6).** Der Ladetext setzt Prüffragen voraus („Je Prüffrage Ja oder Nein“); für einen Auftrag ohne Prüffragen sagt er nicht, ob ich „nein, Auftrag“ melde oder nur am Ziel prüfe. Ich prüfte am Ziel.
9. **Macher.** Das Werkzeug nimmt als Macher den Eintrag „wer“ der letzten „fertig“-Rückmeldung (`_rolle_aus_besetzung`); trägt die Fachkraft ohne Besetzung ein, steht dort „unbekannt“ und der Rückläufer geht an den Disponenten. Der Ladetext sagt dazu nichts (nur „das Werkzeug … nennt den Empfänger“).
