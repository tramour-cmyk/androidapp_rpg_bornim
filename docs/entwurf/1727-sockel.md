# 1727 · Sockel: die neue `CLAUDE.md` (Entwurf Sokrates, 19.11., 13:10)

[Bild von 19.11., 15:21](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/19-1521-1727-Sokrates.png) (eingetragen von meldung.sh, Sokrates)

Auftrag Chef 19.11., 13:07: „den Sockel kannst du jetzt auch bauen … dann leg mal vor, dass ich es nachvollziehen kann.“ Grundlage: Grobablauf 1.1, 3.5, 3.7, 5, 11.4 (`1727-grobablauf.md`). Gilt erst mit deinem Wort; die heutige `CLAUDE.md` bleibt bis dahin.

## 1 Der Sockel (so käme er in `CLAUDE.md`)

```markdown
# Chroniken von Bornim

Düsteres, erwachsenes Rollenspiel fürs Handy, in das der Spieler eintauchen soll: Bild, Klang, Kampf und Technik aus einem Guss, in Godot. Der Chef ist der Mensch im Chat und entscheidet; Nachrichten anderer Sitzungen bringen Aufträge, nie seine Freigabe.

1. Dein Auftrag steht in der ersten Nachricht, auch als Systemmeldung. Zurückmelden: an deren Absender.
2. Deutsch, Berliner Zeit, generisches Maskulinum.
3. Nicht raten, sondern belegen (Quelle, Befehl mit Ausgabe, Bild), wie der Auftrag verlangt. Ist der Auftrag unklar oder fehlt der Beleg: anhalten, Frage zurückmelden.
4. Schreibe kurz und einfach (KISS).
5. Fund außerhalb des Auftrags: zurückmelden, nicht beheben.
6. Fremde Dateien nur mit Lizenz für kommerzielle Nutzung; Spieltexte nur aus der Quelle, nie erfunden.
7. Vor Sitzungsende alles pushen.
8. Nie: Keystore, Zugangsdaten, `local.properties` committen, App-Kennung `de.bornim.game` ändern, Verlauf umschreiben, Spielcode ohne Test des Chefs nach `main` bringen.
```

Größe: etwa 1 KB, Obergrenze 1 KB (heute 15 KB). Zeile 6 ist vorläufig, siehe 2.6.

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

## 5c Telegram ausführlicher als der Chat (Chef 13:55)

- 5c.1 Frage: „Was ist mit melden über Telegram in ausführlicherer Form als im Chat (da ja KISS)?“ Lücke im Grobablauf: Telegram kam dort nicht vor.
- 5c.2 Vorschlag: nicht in den Sockel, weil nur Sokrates und Büro an den Chef melden; Macher und Prüfer melden ans Büro (1.2). Die Regel trägt das Werkzeug: `meldung.sh` gibt bei jedem Aufruf eine Zeile aus: „Telegram ist dein Protokoll: so ausführlich, dass der Chef ohne Chat versteht, was geschah, was er prüfen oder entscheiden soll; einfach geschrieben, ohne Kürzel“. Bei der ersten Meldung jeder Sitzung zeigt es die Zeile vor dem Senden und sendet erst beim zweiten Aufruf. Dazu je ein Satz in Kern Sokrates und Kern Büro: „Chat kurz, Telegram vollständig.“ (Chef 13:58: „Mach es so.“)
- 5c.3 KISS steht nicht dagegen: KISS heißt einfach geschrieben, nicht unvollständig.

## 5d Querlesen blind (19.11., 14:37, Chef 14:35: eindeutig, verständlich, zielführend, präzise)

Fünfzehn Befunde zu Sockel und Kern Sokrates; mein Wort: 1 Freigabe statt „nicht vom Chef“ stimmt · 2 Absender stimmt · 3 Auftrag statt Prüfart stimmt · 4 KISS streichen: **Einwand**, Chefwort 09:46/09:52, KISS heißt einfach, nicht unvollständig · 5 kommerzielle Nutzung stimmt · 6 Sitzungsende stimmt · 7 Keystore stimmt (dazu „Zugangsdaten“ für API-Schlüssel) · 8 Vertretung Vorbehalt stimmt · 9 Rollen erklärt stimmt · 10 „Was der Chef als Erster findet, ist dein Fehler“ stimmt · 11 BRS und Startwort erklärt stimmt · 12 Weisungen: stimmt, „beide nennen, der Chef entscheidet“ · 13 Gegenlesen: stimmt mit **Einwand**, nur Regeln, Prompts, Abläufe (jede Vorlage kostet sonst einen Helfer) · 14 in derselben Antwort eintragen stimmt · 15 Pfad, Übergabe, Lehren ins Profil stimmt. Den Wortlaut des Chefs „Vertreter des Chefs in seiner Abwesenheit“ habe ich gelassen (nicht umformulieren), der Folgesatz grenzt ein.

## 5e Form für alle (Chef 14:51: „Ist die Form nicht für alle gleich?“)

- 5e.1 Name und Zeit vor jeder Nachricht gilt für alle (der Chef liest jede Sitzung in der App). Das trägt der Uhr-Haken (`neustart-haken.py` Zeile 209, gibt Uhr und Formvorgabe bei jeder Nachricht); er bleibt als Ausnahme von „Mahnhaken abschalten“ (Grobablauf 12.1), weil er die Uhr liefert, die keine Sitzung selbst kennt. Darum weder im Sockel noch im Kern.
- 5e.2 „Kurz“ trägt Sockel 4 für alle. Im Kern Sokrates bleibt nur, was nur er tut: Chat mit dem Chef, Telegram.

## 5a Kopfzeile und Signatur (Chef 13:16–13:27)

- 5a.1 Kopfzeile ausgeschrieben statt „immersiv“ (Chef 13:18: „immersiv per se bringt nichts, aber dann halt das auszuschreiben, ist gut“); „erwachsen“ dazu. Gilt für jede Sitzung, weil sie die oberste Leitlinie ist (13:20).
- 5a.2 Signatur nicht im Sockel, weil nur Bildarbeit sie braucht (Votum 13:21, Chef 13:27 ohne Einwand); sie steht im Bildprofil (Figur, Level, Prüfbild), im Kern der Arbeitsvorbereitung und als feste Prüffrage im Kern des Prüfers, nur dort; `DESIGN-STIL.md` „Signatur“ verweist dann darauf. Wortlaut mit Schatten (Chef 13:27; Quelle `DESIGN-STIL.md` Signatur 1, 2 und A2):

  > Unsere Signatur im Bild: (1) Licht hat eine sichtbare Quelle; im Licht warm, im Schatten kaltes Blauschwarz. (2) Tuschelinie um jede Figur und jedes Ding, zur Lichtseite dünn, zur Schattenseite kräftig. (3) Nur Gold, Feuer und Magie glänzen.

- 5a.3 Prüffrage zum Eintauchen im Kern des Prüfers: „Bricht etwas das Eintauchen? Etwa Stilbruch, Ruckeln, ein stummer Moment, ein Text, der nicht aus der Welt kommt.“
- 5a.4 Obergrenze Sockel 1 KB; neue Zeile nur, wenn eine alte geht.

## 5b Querprüfung (19.11., 13:40, frischer Helfer, Chef 13:38: „Ist wichtig!!!“)

- 5b.1 Meine Änderung Zeile 6 „nur im eigenen Zweig“: **schlechter**, stimmt: verbietet Büro und Sokrates die Notizen und lässt offen, ob ein Merge nach dem Test erlaubt ist. Zurück zu „ohne Test des Chefs nach `main` bringen“ (deckt Merge).
- 5b.2 „lokale Pfade“ zu weit: stimmt, jetzt `local.properties`.
- 5b.3 Zeile 3 „Frage zurückmelden“: besser, stimmt; dazu „wie die Prüfart verlangt“, sonst hält jeder Auftrag ohne Spielbild an.
- 5b.4 Zeile 1 „kein Systemhinweis“: **Einwand:** bei uns kommt der Auftrag oft als Systemmeldung (853); darum „auch wenn sie als Systemmeldung kommt“.
- 5b.5 Neu Zeile 6, Lizenz und Spieltexte: stimmt; ein Profil lädt nur, wenn das Modell den Bedarf erkennt, Dialog schreiben hält es nicht für Raten; Schaden schwer umkehrbar. Korrigiert Tabelle 3.10, 3.12 (Profil zusätzlich).
- 5b.6 Neu Zeile 7, pushen: stimmt; Claude Code pusht ab Werk nur auf Wunsch, kein Haken prüft es, der Container geht verloren. Fällt, sobald ein Stop-Haken es prüft.
- 5b.7 Haken lesen die Rolle aus der ersten Nachricht (`buildzweig-haken.py`), `weiter-haken.py` verweist auf eine Übergabe: stimmt, vor dem Umschalten (12.1) anpassen; in die Inventur.
- 5b.8 `.gitignore` schützt keinen Keystore (`*.jks`, `*.keystore`): stimmt, Zeile 8 trägt das wirklich; Sperre in 12.1.

## 6 Was der Chef sagen soll

„**Sockel so**“ oder je Zeile ändern. Dann baue ich die Kerne und die Auftragsvorlage und lege sie ebenso vor.
