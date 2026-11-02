# 466 · Statt „Handlung“ „Fähigkeit“, und Prüfungen ohne „Geselle“ und „Meister“?
Homer · 02.11., 02:4x · C Texte

**Frage:** Du hast gesagt (01.11., 21:13): „Also wäre es besser verständlich eine Spezialfertigkeit oder Spezialfähigkeit oder etwas in der Art. Handlung ist alles.“ Und (21:21): „Also ist die Reihenfolge Anwärter, Eingeweihter, Geselle und Meister? Und wie werde ich was davon?“ Welches Wort für das, was ein Pfad gibt, und wie heißen die Prüfungen?

**Votum Homer: 1A und 2A.**

1. **Was ein Pfad gibt** (Riposte, Heilende Hand, Tierbegleiter):
   - **A „Fähigkeit“, EN „Ability“.** Dein Wort schon in Entscheidung 62 („eine neue Fähigkeit …, die ich anwenden kann“); das Spiel meldet heute schon „Neue Fähigkeit: …!“ / „New ability“, wenn ein Held etwas Neues anwenden kann.
   - B „Kunst“, EN „Art“ („die Künste des Paladins“). Klingt alt und eigen, verwechselt nichts; Englisch schwach.
   - C „Gabe“, EN „Gift“. Passt zu Paladin und Heiler, schlecht zu Meucheln und Giftklinge.
2. **Prüfungen und Pfadstufen:**
   - **A Prüfungen nach dem Ziel, Pfadstufen ohne Handwerksnamen:**

| Prüfung | danach bist du | EN |
|---|---|---|
| (Zusage beim Lehrmeister) | Anwärter | Aspirant |
| **Weihe** (bisher Zwischenprüfung) | Eingeweihter | Initiation → Initiate |
| **Titelprüfung** (bisher Gesellenprüfung) | den Titel, z. B. „Paladin“ (in der Regel „Titelträger“) | Title Trial → „Paladin“ |
| **Hohe Prüfung** (bisher Meisterprüfung) | den hohen Titel, z. B. „Hoher Paladin“ (bisher Stufe „Meister“) | High Trial → „High Paladin“ |

   Der Spieler liest „Anwärter“, „Eingeweihter“ und den Titel; „Titelträger“ steht nur in der Regel. **Anfänger, Geselle, Meister, Großmeister** gehören dann nur noch den Fertigkeiten (deine Ränge vom 31.10.).
   - B nur die Prüfungen umbenennen, letzte Pfadstufe bleibt „Meister“: kleiner, aber „Meister“ bleibt doppelt.

**Berührt:** BRS-Entwurf Kapitel 5 und 6, Kampf (Riposte als Handlung, Auflagen ab Gesellenprüfung), Rechenmodell („welche Handlungen man hat“), Übersicht und Abschnitt F; Nachschlagewerk Entscheidungen 62, 63, 66, 75, 80 (Wortlaut bleibt, Verweis auf 466); Spielanleitung `[423.pfad.…]`, `[423.pruefung.takt]` mit den Platzhaltern `{pruefung.…_kapitel}` und den englischen „First Trial“, „Journeyman's Trial“, „Master's Trial“; Lehrmeistertexte 447.4 (`[447.4.sys.wechsel]` „Handlungen“/„actions“); Chefsache 406.1 (Schildstoß „als Handlung“). Im Spiel stehen nur „Neue Fähigkeit“ und „Diese Fähigkeit ist erschöpft“ (`klassisch.gd`), heute für Klassenkönnen nach SRD; mit dem BRS werden daraus die Fähigkeiten des Pfads, Wortlaut passt.

## Begründung

- „Handlung“ bleibt das Allgemeine: die Prüfregel sagt, jede Fertigkeit braucht eine Handlung, die sie übt (Schlagen, Schleichen, Kochen); ebenso Abnahme 2.7 („jede Herkunft hat eine Handlung“). Nur was der Pfad schenkt, heißt Fähigkeit.
- Die Verwechslung vom 01.11. kam daher, dass die Gesellenprüfung zum Titel führt und „Meister“ zugleich Pfadstufe und Fertigkeitsrang ist. Mit 2A hat jede Leiter eigene Wörter: Fertigkeiten Handwerksränge, Pfade Weihe und Titel.

## Stärkstes Gegenargument

**„Fähigkeit“ und „Fertigkeit“ klingen fast gleich**, und das Nachschlagewerk sagt in Entscheidung 2 selbst „Fähigkeiten werden durch Benutzung besser“ für Fertigkeiten. Dagegen: Eine Fertigkeit hat immer Wert und Rang (Einhänder 34, Geselle), eine Fähigkeit nie; Englisch ist es eindeutig (Skill / Ability). Wer das Risiko nicht will, nimmt 1B „Kunst“.

Gegen 2A: „Meister“ bleibt in Lehrmeister, Meisterschaft und Runenmeister. Das sind Namen von Personen und Handwerken, keine Stufe des Helden; verwechseln lässt sich nur die Stufe. Die Meisterschaften haben dieselbe Leiter, und „Hoher Schmied“ klingt fremd; ihre Titel schlage ich getrennt vor, sobald 2 entschieden ist.

## Folgerungen

Bei Ja trage ich die Wörter in BRS-Entwurf, Spielanleitung und 447.4 ein (Notizen, kein Code) und lasse sie fremd gegen die Quelle prüfen.

## Stellungnahme Sokrates (02.11., 03:4x)

- **Stärkstes Gegenargument gegen 1A:** Du selbst hast beide Wörter für beides gesagt: Entscheidung 2 nennt die Fertigkeiten „Fähigkeiten“ („werden durch Benutzung besser“), Entscheidung 62 das, was die Berufung gibt, ebenfalls „Fähigkeit“; am 01.11. schlugst du „Spezialfertigkeit oder Spezialfähigkeit“ vor. Wer im Sprechen beides mischt, mischt es auch beim Lesen.
- **Entkräftet:** nicht über das Wort, sondern über die Anzeige: eine Fertigkeit erscheint nur mit Wert und Rang („Einhänder 34 · Geselle“), eine Fähigkeit nur als Knopf im MARS-Menü und als Meldung „Neue Fähigkeit: …“ (steht so schon in `klassisch.gd` und `lohn.gd`, kein Umbau). Englisch Skill/Ability ist eindeutig. „Kunst“ (1B) ist sicherer, klingt aber im Kampfmenü („Kunst einsetzen“) gestelzt.
- **Lücke in 2A:** Die Meisterschaften laufen „genauso mit Lehrmeister und drei Prüfungen“ (Entwurf Abschnitt 6), heißen selbst „Meister-schaft“ und eine davon „Runenmeister“. Homer verschiebt ihre Titel; dann bleibt „Meister“ genau dort doppelt, wo es am nächsten liegt (Fertigkeit Schmieden Rang Meister neben der Meisterschaft Schmied). Weg: die Titel der Meisterschaften in derselben Antwort mitentscheiden, nicht danach.
- **Zu den Prüfungsnamen:** „Titelprüfung“ und „Hohe Prüfung“ sind Regelwörter, im Spiel nüchtern. Im Spiel besser nach dem Titel selbst: „Prüfung zum Paladin“, „Prüfung zum Hohen Paladin“; „Titelprüfung“ nur in der Regel, wie Homer es für „Titelträger“ schon vorsieht. „Weihe“ passt zu „Eingeweihter“ (Entscheidung 51) auch bei Meuchler und Duellant, weil es dort Aufnahme in einen Kreis heißt.
- **Widerspruch zu Entschiedenem:** keiner. Entscheidung 51 („Eingeweihter“) bleibt; die Ränge vom 31.10. (Anfänger bis Großmeister, Entwurf Abschnitt 4) bleiben; 62 meint mit „Fähigkeit“ schon das, was 1A festlegt. 406.1 („Schildstoß als Handlung“) und 447.4 ziehen nur das Wort nach.
- **Kosten:** nur Notizen (Entwurf Kapitel 5 und 6, Spielanleitung `[423.…]`, 447.4), etwa eine halbe Homer-Sitzung mit Prüfer; im Code nichts, die Meldungen sagen schon „Fähigkeit“.
- **Empfehlung:** „466: 1A und 2A“, mit zwei Zusätzen: im Spiel heißen die Prüfungen nach dem Titel („Prüfung zum Paladin“), und Homer legt die Stufen der Meisterschaften ohne „Meister“ als Stufe in einer Zeile dazu, bevor er einträgt.
