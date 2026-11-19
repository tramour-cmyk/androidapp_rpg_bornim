# 1727 · Sockel: die neue `CLAUDE.md` (Entwurf Sokrates, 19.11., 13:10)

Auftrag Chef 19.11., 13:07: „den Sockel kannst du jetzt auch bauen … dann leg mal vor, dass ich es nachvollziehen kann.“ Grundlage: Grobablauf 1.1, 3.5, 3.7, 5, 11.4 (`1727-grobablauf.md`). Gilt erst mit deinem Wort; die heutige `CLAUDE.md` bleibt bis dahin.

## 1 Der Sockel (so käme er in `CLAUDE.md`)

```markdown
# Chroniken von Bornim

Düsteres, erwachsenes Rollenspiel fürs Handy, in das der Spieler eintauchen soll: Bild, Klang, Kampf und Technik aus einem Guss. Godot (`godot/`), Werkzeuge in `tools/`.

1. Dein Auftrag steht in der ersten Nachricht. Ohne Auftrag nichts bauen, sondern fragen.
2. Deutsch, Berliner Zeit, generisches Maskulinum.
3. Nicht raten, sondern belegen: Quelle, Befehl mit Ausgabe, Bild aus dem Spiel. Geht das nicht oder ist der Auftrag unklar: anhalten und fragen.
4. Schreibe kurz und einfach (KISS).
5. Fund außerhalb des Auftrags: in deiner Rückmeldung nennen, nicht beheben.
6. Nie: Schlüssel, Passwörter oder lokale Pfade committen, App-Kennung `de.bornim.game` ändern, Verlauf umschreiben, Spielcode ohne Test des Chefs auf `main`.
```

Größe: etwa 0,8 KB, Obergrenze 1 KB (heute 15 KB). Zeile 6 ist vorläufig, siehe 2.6.

## 2 Warum jede Zeile drinsteht

Maßstab (Grobablauf 5): nur, was jede Sitzung braucht, nicht selbst sehen kann und kein Werkzeug erzwingen kann.

- **2.1 Kopfzeile:** Claude sieht das Repo, aber nicht, was es ist und wie es klingen soll; „düster“ ist das eine Wort aus deiner obersten Direktive, das jede Arbeit färbt. Alles Weitere zum Spiel steht im Auftrag (Ziel 6.1) und im Leitbild.
- **2.2 Zeile 1, Auftrag:** ersetzt Rollen, Vorrat, Startlektüre: die Sitzung weiß, wer sie ist und was sie tut, aus der ersten Nachricht (heute schon so, 853). Der Nachsatz fängt Sitzungen ohne Auftrag ab (heute „unbekannt → Chef fragen“).
- **2.3 Zeile 2:** kann kein Werkzeug erzwingen; heute „Umgang“, samt generischem Maskulinum (gilt auch für Spieltexte).
- **2.4 Zeile 3:** dein Wort 09:46 („Nicht raten, sondern belegen“), dazu der Abbruchweg aus dem Gegenlesen (11.4). Fasst drei der sechs heutigen „Bekannten Fehler“ zusammen (Gedächtnis, Vermutung, Probe anders als Bau).
- **2.5 Zeile 4, 5:** KISS ist Schreibstil (dein Wort 09:52); „nennen, nicht beheben“ hält die Sitzung im Auftrag und lässt nichts verloren gehen (heute Haltung 4). Die Rückmeldung liest das Büro und legt den Fund als Vorgang an; der Macher kennt keine Vorgangsliste.
- **2.6 Zeile 6, vorläufig:** Diese vier Verbote sollen Sperren werden, die etwas verhindern statt mahnen (Grobablauf 5.6, 5.7). **Nachgesehen:** Heute verhindert keiner unserer Haken das Committen eines Schlüssels oder einen Force-Push, nur `.gitignore` hält `local.properties` fern. Ohne Zeile 6 ginge also still ein Schutz verloren (Nullbasis 5.1). Sie fällt, sobald die Sperre steht und Spike sie mit einem Versuch belegt hat.

## 3 Wohin der Rest der heutigen `CLAUDE.md` zieht

| Nr. | Heute in `CLAUDE.md` | Neu | Wer lädt es |
|---|---|---|---|
| 3.1 | Wer wir sind, Firma, Rollentabelle, Account (alle auf Max), Betrieb (Guthaben, Zielvereinbarung, Wochenziel) | entfällt für Macher; Kern Büro und Sokrates | nur diese zwei |
| 3.1a | Kopf: Vorsilben, `docs/README.md`, `FIRMA.md`, alte Kotlin-Fassung | Kern Büro und Sokrates; Arbeitsvorbereitung nennt im Auftrag die Datei, die gebraucht wird | Büro, Sokrates |
| 3.2 | Oberste Direktive, Spielziel, nie Werbung | Kern Sokrates (prüft jede Idee daran), Ziel jedes Auftrags; `DESIGN-LEITBILD.md` bleibt | Sokrates, Arbeitsvorbereitung |
| 3.3 | Haltung 1–7 (prüfen, nicht raten, Chefworte weitergeben, nichts verloren, sparsam, Regelbilanz, Maß) | 2 in Zeile 3; 4 in Zeile 5; 1, 3, 5 (sparsam im Chat, nur sie sprechen mit dir), 6, 7 Kern Sokrates bzw. Büro | – |
| 3.4 | Bekannte Fehler (6 Zeilen, Pflege 347) | Pflege neu: Wiederholer wird Zeile im Profil (Grobablauf 7.3); 3 in Zeile 3; „Helferbefund“ und „Urteil des Chefs nicht umformulieren“ Kern Sokrates und Büro; „Kaufrepo mit `add_repo`“ Profil Figur | Profil bei Bedarf |
| 3.5 | Wo was steht (Vorrat, Vorgangsliste, Archiv, Chefsache) | Kern Büro und Sokrates; der Macher kennt keine Liste (Grobablauf 1.2) | Büro, Sokrates |
| 3.6 | Zusammenarbeit 1–9 (Start, wer entscheidet, anstoßen, Rückfragen, melden) | Kern Büro und Sokrates; Macher meldet nur nach Feld „Zurück“ im Auftrag (6.7) | Büro, Sokrates |
| 3.7 | Notizen nur auf `main` | Kern Büro und Sokrates (nur sie schreiben Notizen) | Büro, Sokrates |
| 3.8 | Feste Regeln: Kerntests, Weckruf | Profil Werkzeug bzw. Build; Prüfart im Auftrag | Profil |
| 3.9 | Nummern, ein Text an einem Ort, Vorräte klein | Kern Büro; `vorgang.py` erzwingt die Form | Büro |
| 3.10 | Story und Spieltexte nie erfinden; Begriffe | Profil Spieltext (Grobablauf 5.8) | Profil |
| 3.11 | Chefsache-Regeln; Idee heißt prüfen, Ideenliste | Kern Sokrates (urteilt Ideen, Grobablauf 4.2) | Sokrates |
| 3.12 | Fremde Inhalte, Lizenz | Profil Fremde Inhalte (Grobablauf 5.9) | Profil beim Einbinden von Dateien |
| 3.13 | Schlüssel, `local.properties`, SDK-Pfad, App-Kennung, Force-Push, `main` | Zeile 6, später Sperre | alle |
| 3.13a | Am Ende alles committen und pushen | Feld „Zurück“ jeder Auftragsvorlage: Zweig gepusht, Commit genannt | jeder Macher über den Auftrag |
| 3.14 | Autorenzeile, Systemzeilen im Commit, keine Modellnamen | Autor setzt `.claude/settings.json` schon; Rest Profil Build | Profil |
| 3.15 | Release nur auf Zuruf | Kern Büro; Release ist ein eigener Auftrag | Büro |

Was nirgends hinzieht: Begründungen mit Vorgangsnummern im Text (bleiben in Git, `docs/alt/CLAUDE-voll.md`).

## 4 Stärkstes Gegenargument

- **4.1 Mit dem Sockel allein wäre jede heutige Sitzung blind.** Tom, Jerry, Perikles arbeiten heute aus Vorrat und Vorgangsliste, und die Regeln dafür stehen nur in `CLAUDE.md`. Schalten wir den Sockel vor den Kernen, Profilen und der Auftragsvorlage ein, kennt niemand mehr Melden, Vorgänge oder Chefsache.
- **4.2 Entkräftet:** Der Sockel geht nicht allein live, sondern im Schritt 12.1 zusammen mit den Kernen Büro und Sokrates (je höchstens 3 KB) und der Auftragsvorlage; die ersten Macher starten erst mit Auftrag (12.2). Die alte Fassung liegt als `docs/alt/CLAUDE-voll.md` bereit, Rückweg ist ein Commit. Darum baue ich als Nächstes Kern Sokrates, Kern Büro und die Auftragsvorlage; erst wenn alle vier stehen, schlage ich das Umschalten vor.

## 5 Gegenlesen (19.11., 13:10, frischer Helfer mit `CLAUDE.md` daneben)

Zwölf Befunde, mein Wort je Befund:
- 5.1 Kopf (Vorsilben, Verweise) fehlte: **stimmt**, Zeile 3.1a.
- 5.2 Betrieb (Guthaben, Ziele) fehlte: **stimmt**, in 3.1.
- 5.3 Idee-Regel fehlte: **stimmt**, in 3.11.
- 5.4 Generisches Maskulinum fehlte: **stimmt**, in den Sockel (Zeile 2), weil es jeden Text betrifft.
- 5.5 Account fehlte: **stimmt**, in 3.1.
- 5.6 „Am Ende pushen“ und lokale Pfade fehlten: **stimmt**, 3.13a (im Auftrag) und Zeile 6.
- 5.7 Pflege der Bekannten Fehler fehlte: **stimmt**, in 3.4.
- 5.8 Haltung 5 stand fälschlich in Zeile 4: **stimmt**, berichtigt (Kern).
- 5.9 Haltung 3 stand fälschlich in Zeile 3: **stimmt**, berichtigt (Kern).
- 5.10 Testbitten und Eintragen gelten heute für jede Sitzung: **Einwand:** neu nicht mehr, der Macher meldet nur über „Zurück“, das Büro trägt ein (Grobablauf 1.2).
- 5.11 „Melden“ an wen: **stimmt**, Zeile 5 heißt jetzt „in deiner Rückmeldung nennen“.
- 5.12 „Bild“ und „KISS“ unklar: **stimmt** teilweise: „Bild aus dem Spiel“, „Schreibe kurz und einfach (KISS)“.

## 5a Kopfzeile und Signatur (Chef 13:16–13:27)

- 5a.1 Kopfzeile ausgeschrieben statt „immersiv“ (Chef 13:18: „immersiv per se bringt nichts, aber dann halt das auszuschreiben, ist gut“); „erwachsen“ dazu. Gilt für jede Sitzung, weil sie die oberste Leitlinie ist (13:20).
- 5a.2 Signatur nicht im Sockel, weil nur Bildarbeit sie braucht (Votum 13:21, Chef 13:27 ohne Einwand); sie steht im Bildprofil (Figur, Level, Prüfbild), im Kern der Arbeitsvorbereitung und als feste Prüffrage im Kern des Prüfers, nur dort; `DESIGN-STIL.md` „Signatur“ verweist dann darauf. Wortlaut mit Schatten (Chef 13:27; Quelle `DESIGN-STIL.md` Signatur 1, 2 und A2):

  > Unsere Signatur im Bild: (1) Licht hat eine sichtbare Quelle; im Licht warm, im Schatten kaltes Blauschwarz. (2) Tuschelinie um jede Figur und jedes Ding, zur Lichtseite dünn, zur Schattenseite kräftig. (3) Nur Gold, Feuer und Magie glänzen.

- 5a.3 Prüffrage zum Eintauchen im Kern des Prüfers: „Bricht etwas das Eintauchen? Etwa Stilbruch, Ruckeln, ein stummer Moment, ein Text, der nicht aus der Welt kommt.“
- 5a.4 Obergrenze Sockel 1 KB; neue Zeile nur, wenn eine alte geht.

## 6 Was der Chef sagen soll

„**Sockel so**“ oder je Zeile ändern. Dann baue ich die Kerne und die Auftragsvorlage und lege sie ebenso vor.
