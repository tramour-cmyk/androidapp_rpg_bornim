# 1727, Querprofil Fremde Inhalte; Spieltext einbauen (Gesamtbild 5.3 Nr. 12; Fassung 5, Sokrates 21.11., 22:15, Befunde Nachprüfung 21:15 eingearbeitet, Nachprüfung offen; Teil A 1.082 → 1.115 Byte)

Auftrag: Gesamtbild 5.3 Nr. 12 „Fremde Inhalte; Spieltext einbauen, quer, fehlt“ (Quellen `CLAUDE.md` „Technik und Sicherheit“, `LISTE-QUELLEN.md`; `STORY-REGELN.md`, `LISTE-GLOSSAR.md`); G:781 „quer: Fremde Inhalte (Lizenz, Quelle, Urheber je Datei) · Spieltext einbauen (Wortlaut aus `STORY-REGELN.md`, Begriffe aus `LISTE-GLOSSAR.md`)“; Reihenfolge Schritt 2 (`reihenfolge.md`:11). Form wie `profil-technik.md` F12; neue Profile kurz (Archiv 20.11., 14:02).

Geladen von: jede Fachkraft, deren Auftrag eine fremde Datei (Modell, Bewegung, Klang, Schrift, Effekt, Code) oder einen Spieltext ins Spiel bringt, zusätzlich zum Fachprofil; Arbeitsplaner und Prüfer bei solchen Aufträgen. Nicht hier: Spieltexte schreiben (Profil Story, Nr. 9: Entwurf bis zum Wort des Chefs); Klangkatalog im Einzelnen (Profil Klang, Nr. 7); Namen und Aussehenstexte der Kataloge (Profil Kataloge, Nr. 5, „nur aus der Quelle“); was der Sockel trägt (Zeile 6: „Fremde Dateien nur mit Lizenz für kommerzielle Nutzung; Spieltexte nur aus der Quelle, nie erfunden.“). **Gilt ab der Umstellung;** bis dahin gelten `CLAUDE.md` „Technik und Sicherheit“ und „Story und Dialoge“ wie sie sind.

Quellen: Archiv 21.11., 20:52 „Kauf und Lizenz“; `CLAUDE.md` „Technik und Sicherheit“ (Lizenz, Kauf, Zweit-Repo, Nachweis je Datei), „Story und Dialoge“, „Begriffe“, Bekannte Fehler (`add_repo`, 1472); `LISTE-QUELLEN.md` (Lizenzregel, Prüfschema F1–F8, „Alle Quellen im Bestand“, Lizenzfallen, Lücken 1–2); `LISTE-BESTAND.md` (Kopf); `STORY-REGELN.md` (Regeln, Marke, Englisch); Archiv 348.12c, 780 A (09.11., 17:46), 1320 (Life); Gesamtbild 4.1 (Arbeitsplaner: Prüffrage Spieltext, fehlender Spieltext), 5.3 Nr. 9 (Profil Story F3, entschieden 20.11., 16:43), 3.3 F2.

## Ein- und Ausgang (Raster `ein-ausgang.md`)

| Feld | Inhalt | Fundstelle |
|---|---|---|
| Auslöser | Der Arbeitsplaner hängt das Querprofil unter „Beachte“ an jeden Auftrag, der eine fremde Datei oder einen Spieltext einbaut (wie das Querprofil Signatur und Leben bei Bild oder Klang, Archiv 20.11., 12:37); der Disponent startet die Fachkraft | G:417; VA 20.11., 12:37 (Muster); G:374 |
| Arbeit | Teil A, neben dem Fachprofil | — |
| Ende | wie Fachkraft: „fertig“, „Frage“ oder „abgebrochen“ mit Commit, Fällen, Beleg; dazu je neuer Datei die Nachweiszeile, je Text der Abgleich mit der Quelle | G:420; Teil A |
| Meldung | wie Fachkraft: Zeile über `vorgang.py` an das Büro, Nachricht nur Wecker | 3.3 F2 Nr. 2, 5 |
| Nächster Empfänger | „fertig“ → Prüfer (Prüffrage „jeder Satz wortgleich in der Quelle?“, G 4.1 Nr. 6; Ausnahme markierte Übersetzung als Gesprächspunkt, Aufbau); „Frage“ geht über `vorgang.py` an Sokrates (C, VA 21.11., 14:37): Kauf und Lizenz klärt er im Gespräch mit dem Chef, Entscheidungsfrage im Zweifel als Datei in `entscheiden/` (VA 20:52); fehlender Text: den Auftrag mit Profil Story plant der Arbeitsplaner (G:422 „Fehlender Spieltext: eigener Auftrag mit Profil Story“); **Lücke:** C führt „Frage“ zu Sokrates, nicht zum Arbeitsplaner; Vorschlag: Sokrates gibt sie als Eingang ans Büro (Zu 1727, Sammelvorlage) | G:420, 422; 3.3 F2; VA 14:37 C, 20:52 |

**Lücken aus `ein-ausgang.md`:** Zeile Nr. 12 (Auslöser, Arbeit, Ende, Meldung, Empfänger „steht nicht“; L-O11): geschlossen durch Raster und Teil A. Der Auslöser braucht einen Satz im Text des Arbeitsplaners (Teil B). **Offen, nicht hier:** der Text des Profils Story endet „bis zum Wort des Chefs“, der Weg dorthin ohne Build ist L-O22; ein Text wird erst nach diesem Wort Quelle und damit einbaubar.

## Aufbau

- **Unity Asset Store (780):** `LISTE-QUELLEN.md` Lücke 1: Lizenzrahmen sagt „Unity Asset Store nein“ (EULA 2.2.1, KI als Eingabe), „Gegen Geld“ nennt ihn zulässig; entschieden ist nur 780 A „Zustimmung von Protofactor und Janpec einholen“; Protofactor schriftlich ja (10.11., 04:48), Janpec offen. Teil A setzt keine eigene Regel dafür, sondern schickt jede Lizenz, die nicht sicher passt, als „Frage“ zurück. Träger: Nachfrage Janpec: „Zu 780“ (`ARBEIT-BERATUNG.md`, Nachfrage bis 23.11.); Kauf: Gespräch mit dem Chef (VA 21.11., 20:52; Sammelvorlage :32).
- **Bedingungen frei gegen gekauft:** `CLAUDE.md` (348.12c a) bindet „jede Engine, unbefristet, ohne Nennung und Umsatzgrenze“ an Gekauftes, für Freies reicht „kommerzielle Nutzung“; `LISTE-QUELLEN.md`:5 nennt die Bedingungen ohne Unterschied für alles. Teil A folgt `CLAUDE.md` (Quelle der Regel); die Hälfte „frei: kommerzielle Nutzung“ trägt Sockel 6 (G:184), darum steht im Profil nur „gekauft“. Ablage (Fassung 4a, bis zum Wort zur Chefsache unten): öffentlich nur CC0 und Lizenzen, die die Weitergabe ausdrücklich erlauben (etwa OFL: Schriften unter OFL 1.1 liegen im öffentlichen Repo, `godot/daten/fondamento.ttf`, `godot/kampf/schrift/alegreya_*.ttf`, `tools/schrift/QUELLEN.md`:3); sonst privat (gekauft, QAL: kommerziell erlaubt, Weitergabe der Dateien verboten); so auch `LISTE-BESTAND.md`:7 (1727b). **Chefsache (Lizenz; Träger: Sokrates, „Zu 1727, Sammelvorlage“ in `ARBEIT-BERATUNG.md`; Weg VA 20:52):** sollen die strengeren Bedingungen auch für freie Lizenzen gelten (dann `CLAUDE.md` ändern) oder `LISTE-QUELLEN.md`:5 angleichen?
- **MIT-Teile** (REEBOO, `LISTE-QUELLEN.md` Lücke 2): Lösung „Hinweis in ‚Über das Spiel‘ wie bei Godot (497)“ steht dort nur zur Klärung; nicht übernommen.
- **Arbeitsplaner:** Teil B ergänzt Punkt 4 „Beachte“ (G 4.1). **Gesprächspunkt, nicht einbauen:** der Kern Arbeitsplaner ist „Abgenommenes, Gespräch nötig, bevor geändert wird“ (`reihenfolge.md`:14, Archiv 20.11., 16:49; künftig Profil Arbeitsplaner, `ein-ausgang.md` Zeile 23). Zum selben Gespräch: Prüffrage bei Spieltext (G:419) „jeder Satz wortgleich in der Quelle, außer markierter Übersetzung?“, sonst muss der Prüfer jede Übersetzung verneinen.
- **Englisch:** `CLAUDE.md` „Englisch selbst übersetzen“ und Profil Story („unsichere englische Stellen markieren“) passen zusammen; Teil A verlangt beim Einbau dasselbe Markieren, damit der Prüfer weiß, was nicht aus der Quelle kommt.

## Teil A: Querprofil Fremde Inhalte; Spieltext einbauen

```markdown
**Fremde Dateien.** Gekauft nur, wenn die Lizenz den Verkauf in jeder Engine erlaubt, unbefristet, ohne Nennung und Umsatzgrenze. Lizenz auf der Quellseite prüfen, bei Bearbeitungen auch die des Originals. Neue Quelle erst nach dem Prüfschema in `docs/LISTE-QUELLEN.md`. Je Datei Quelle, Urheber, Lizenz im selben Commit festhalten (Ort je Art: dort „Alle Quellen im Bestand“). Öffentlich nur CC0 und Lizenzen, die die Weitergabe ausdrücklich erlauben (etwa OFL); andere Rohdateien nur im privaten Repo `bornim-kaufmodelle` (Zugang `add_repo`), nie hier. Kaufen tut nur der Chef: Kauf oder unsichere Lizenz → „Frage“ zurück.

**Spieltext.** Verzeichnis `docs/STORY-REGELN.md`, Suche über die Marke `[Thema.kurz]`, wortgetreu. Fehlt das Englische, übersetzt du nach den Regeln dort und markierst es. Begriffe nach `docs/LISTE-GLOSSAR.md`. Fehlt ein Text: kein Platzhalter, „Frage“ mit Stelle zurück. Tippfehler in einem Spieltext, den dein Auftrag einbaut, in der Quelle auf `main` (Commit „Text:“) und im Einbau. Beleg: jeder Satz wortgleich in der Quelle, außer markierter Übersetzung.
```

## Teil B: Text des Arbeitsplaners

G 4.1 Punkt 4 „Beachte“, hinter „bei Bild oder Klang das Querprofil Signatur und Leben“, **neu:** „; bei fremder Datei oder Spieltext das Querprofil Fremde Inhalte“.

## Eigene Prüfung (20:19)

- **Größe Fassung 1, überholt (gültig: letzter Abschnitt)** (UTF-8, gemessen mit `wc -c`): Teil A 963 Byte (Ziel bis etwa 1.200). Teil B 64 Byte: Kern Arbeitsplaner 2.375 → etwa 2.439 Byte. Eine Fachkraft mit diesem Querprofil lädt Sockel 1.110 + Auftrag (bis etwa 2 KB) + Fachprofil (650–1.740) + 963. Regelbilanz: mit der Umstellung wird der Sockel die neue `CLAUDE.md` (Archiv 19.11., 13:33); die Absätze „Story und Dialoge“ (Einbau-Teil) und der Lizenzteil von „Technik und Sicherheit“ tragen danach Sockel 6 und dieses Profil, „Plot und Texte festlegen“ trägt Profil Story.
- **Quellen je Satz (Teil A):**
  1. „Gekauft nur, wenn … jede Engine, unbefristet, ohne Nennung und Umsatzgrenze“: `CLAUDE.md` „Technik und Sicherheit“ (348.12c a); „frei: kommerziell“ trägt Sockel 6; Abweichung `LISTE-QUELLEN.md`:5 im Aufbau.
  2. „Lizenz auf der Quellseite prüfen, bei Bearbeitungen auch die des Originals“: `CLAUDE.md` ebenda wörtlich; Fall Remixe (`LISTE-QUELLEN.md` Lizenzfallen 2).
  3. „Neue Quelle erst nach dem Prüfschema“: `LISTE-QUELLEN.md` Kopf (623, Chef 07.11.: Schema „auf … kommende Internetseiten anwenden“).
  4. „Je Datei Quelle, Urheber, Lizenz im selben Commit festhalten (Ort je Art …)“: `CLAUDE.md` („Quelle, Urheber, Lizenz je Datei festhalten“); „im selben Schritt“ `LISTE-BESTAND.md` Kopf; Orte `LISTE-QUELLEN.md` „Alle Quellen im Bestand“ (`LISTE-BESTAND.md`, `tools/klang/QUELLEN.md`, `tools/schrift/QUELLEN.md`). „Commit“ statt „Schritt“: Übersetzung in die Arbeitsweise der Fachkraft.
  5. „Öffentlich nur CC0 und Lizenzen, die die Weitergabe ausdrücklich erlauben (etwa OFL); andere Rohdateien nur im privaten Repo … (Zugang `add_repo`), nie hier“: `CLAUDE.md` „Technik und Sicherheit“ (gekaufte) und Bekannte Fehler (1472); QAL „Weitergabe der Dateien als Asset“ verboten (`LISTE-QUELLEN.md`, „Gegen Geld“); OFL-Schriften liegen öffentlich (`tools/schrift/QUELLEN.md`:3); wie `LISTE-BESTAND.md`:7 (1727b); Name `LISTE-QUELLEN.md` Lizenzregel.
  6. „Kaufen tut nur der Chef: … ‚Frage‘ zurück“: `CLAUDE.md` („kauft nur der Chef“); „Frage“ als Ende der Fachkraft (G:420), Sockel 3 („unklar … anhalten, Frage zurückmelden“).
  7. „Verzeichnis …, Marke …, wortgetreu“: `CLAUDE.md` „Story und Dialoge“; `STORY-REGELN.md` Kopf und Regeln; „nur aus der Quelle“ trägt Sockel 6, darum nicht wiederholt.
  8. „Fehlt das Englische, übersetzt du nach den Regeln dort und markierst es“: `CLAUDE.md` („Englisch selbst übersetzen“); Regeln `STORY-REGELN.md` „Englische Spieltexte“; Markieren wie Profil Story F3 („unsichere englische Stellen markiert“); Erweiterung auf jede eigene Übersetzung: mein Vorschlag (Aufbau).
  9. „Begriffe nach `LISTE-GLOSSAR.md`“: `CLAUDE.md` „Begriffe (auch im Spiel)“; G:781.
  10. „Fehlt ein Text: kein Platzhalter, ‚Frage‘ mit Stelle zurück“: `CLAUDE.md` („Fehlt ein Text: … nie erfinden“); G 4.1 „Fehlender Spieltext: eigener Auftrag mit Profil Story, nie ein Platzhalter“; „Frage“ statt „Vorgang an Homer“, weil Rollen fallen (G:128) und das Büro weitergibt.
  11. „Tippfehler in einem Spieltext, den dein Auftrag einbaut, in der Quelle auf `main` (Commit ‚Text:‘) und im Einbau“: `CLAUDE.md` „Story und Dialoge“, eingegrenzt durch Sockel 5 (Fund außerhalb des Auftrags zurückmelden, G:183, entschieden 20.11., 12:06).
  12. „Beleg: jeder Satz wortgleich in der Quelle, außer markierter Übersetzung“: G 4.1 Nr. 6 (Prüffrage bei Spieltext); Ausnahme aus Satz 8 (eigene Übersetzung markiert, `CLAUDE.md` „Englisch selbst übersetzen“).
- **Fälle:**
  - 780, Unity Asset Store (Protofactor ja, Janpec offen): Satz 6 schickt die unsichere Lizenz zurück, keine eigene Auslegung.
  - Quaternius „Bestiary“ unter QAL statt CC0 (`LISTE-QUELLEN.md` Lizenzfallen 1): Satz 2 (Quellseite je Paket, nicht je Händler).
  - „WarWolf“, Blendswap-Remix mit ungeprüfter Lizenz (Lizenzfallen 2): Satz 2, Original.
  - 1320, „HP“ statt „Life“ (Chef 15.11., 20:15): Satz 8 (Regeln in `STORY-REGELN.md` „Englische Spieltexte“ 3).
  - Feste Namen („Tiefer Wald“ statt „Tiefer Flüsterwald“, `STORY-REGELN.md`): Satz 7, wortgetreu.
  - Text fehlt beim Bau: Satz 10; früher Platzhalter, jetzt „Frage“, Auftrag mit Profil Story.
- **Rollen:** Teil A nennt keine Rolle; „Chef“ nur als Käufer (Vorbehalt Geld).

## Gegenprüfung 20:23 (frischer Helfer, Fassung 1), mein Wort und Einarbeitung in Fassung 2

1 Bedingungen an Freies gehängt, 348.12c a bindet sie an Gekauftes, `LISTE-QUELLEN.md`:5 an alles: **stimmt**, Teil A trennt frei/gekauft nach `CLAUDE.md`, Abweichung als Chefsache im Aufbau · 2 „Tippfehler direkt“ gegen Sockel 5: **stimmt**, „im Text deines Auftrags“ · 3 wiederholt Sockel 6: **stimmt**, „Nur aus der Quelle“ gestrichen. Teil A danach 995 Byte (vorher 963).

## Nachprüfung 20:43 (frischer Helfer, Fassung 2), mein Wort und Einarbeitung in Fassung 3

Querbefund G-Zeilen: **stimmt**, behoben 20:44 · 1 nach der Trennung käme Freies außer CC0 (QAL) ins öffentliche Repo: **stimmt**, „Rohdateien außer CC0 nur privat“ (`LISTE-BESTAND.md`:7) · 2 fehlender Text: „Frage“ geht über C an Sokrates, Story-Auftrag ohne Träger: **stimmt**, als offener Weg mit Sammelfrage C · 3 „wortgleich“ gegen markierte Übersetzung: **stimmt**, „außer markierter Übersetzung“ · 4 Teil B ändert Abgenommenes: **stimmt**, Gesprächspunkt · 5 Chefsachen ohne Träger: **stimmt**, Träger Sokrates · 6 „frei“ wiederholt Sockel 6: **stimmt**, nur noch „gekauft“ · 7 G:182: **stimmt**, Sockel 5 ist G:183 · 8 Größe: **stimmt**, unten · 9 „Tippfehler im Text deines Auftrags“ mehrdeutig: **stimmt**, „in einem Spieltext, den dein Auftrag einbaut“.

Größe Fassung 3 (`wc -c`, Codeblock Teil A): 998 Byte; Teil B 64 Byte. Ladesumme Fachkraft: Sockel 1.110 + Auftrag bis etwa 2 KB + Fachprofil (650–1.740) + 998.

Nachtrag 20:52 (b339bd3d1): Raster „Nächster Empfänger“ nach Archiv „Kauf und Lizenz“.

## Nachprüfung 20:54 (frischer Helfer, Fassung 3), mein Wort und Einarbeitung in Fassung 4

1 „außer CC0 nur privat“ verbietet OFL-Schriften im Repo: **stimmt**, „deren Lizenz die Weitergabe verbietet (gekauft, QAL)“ · 2 Prüffrage verneint jede Übersetzung: **stimmt**, in den Gesprächspunkt Kern Arbeitsplaner · 3 Chefsachen ohne Träger, Unity hat „Zu 780“: **stimmt**, Unity auf „Zu 780“, frei/gekauft auf „Zu 1727, Sammelvorlage“, Weg VA 20:52 · 4 Story-Weg überzogen „steht nirgends“: **stimmt**, Lücke genau benannt (C führt zu Sokrates, nicht zum Arbeitsplaner, G:422) · 5 fehlender Text doppelt, 20:52 nicht vermerkt: **stimmt**, Raster einmal, Quelle und Vermerk · 6 Zitate 11, 12 und alte Größe: **stimmt**, angeglichen, alte Größe als überholt.

Größe Fassung 4 (`wc -c`, Codeblock Teil A): 1.042 Byte.

## Nachprüfung 21:03 (frischer Helfer, Fassung 4), mein Wort, eingearbeitet (Fassung 4a)

1 Ablage als Verbotsliste nimmt die offene Lizenzfrage vorweg: **stimmt**, bis zum Wort „öffentlich nur CC0 und Lizenzen, die die Weitergabe ausdrücklich erlauben (etwa OFL); sonst privat“ · 2 Ausnahme Übersetzung und „Beachte“-Satz ohne Träger: **stimmt**, Sammelvorlage Nr. 10 · Unity ohne Träger: **stimmt**, Sammelvorlage Nr. 11 (in Fassung 5 angeglichen: Nachfrage Janpec „Zu 780“, Kauf Gespräch) · teils doppelt zu Sockel 3, 6: **Einwand**, bleibt, weil die Fälle (Text fehlt, Kauf) das „Frage“ erst konkret machen. Teil A 1.082 Byte. Nachprüfung der Fassung 4a offen.

## Nachprüfung 21:15, mein Wort (frischer Helfer, Fassung 4a an `dcbb29a98`; Teil A 1.082 Byte stimmt), eingearbeitet in Fassung 5

Votum Prüfer: vorlegbar nach 3. Mein Wort (Sokrates 21:17): alle **stimmt**, FI 4 schon in der Sammelvorlage F2 umgesetzt.
1 Quelle 5 und Aufbau (:24, :49) auf Ablage 4a angleichen: **stimmt, eingearbeitet**, beide auf „öffentlich nur CC0 und ausdrücklich erlaubte Weitergabe (etwa OFL), sonst privat“; `LISTE-BESTAND.md`:7 sagt an `main` schon dasselbe (1727b), der Satz „zu eng“ entfällt · 2 Unity zwei Träger (:23/:86): **stimmt, eingearbeitet**, „Nachfrage Janpec: Zu 780; Kauf: Gespräch“ an beiden Stellen · 3 Tippfehler „in der Quelle auf `main` (Commit ‚Text:‘) und im Einbau“, sonst Nein des Prüfers (Fehler): **stimmt, eingearbeitet**, Teil A und Quelle 11 · 4 „Text fehlt“ kein Chefwort (Vorentscheid): **stimmt**, schon erledigt, nicht geändert · 5 Kopfzeile: **stimmt, eingearbeitet**, Fassung 5 mit Größe. Teil A 1.115 Byte. Nachprüfung der Fassung 5 offen.
