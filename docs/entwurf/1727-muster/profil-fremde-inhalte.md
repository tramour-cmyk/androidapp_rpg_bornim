# 1727, Querprofil Fremde Inhalte; Spieltext einbauen (Gesamtbild 5.3 Nr. 12; Fassung 2, Sokrates 21.11., 20:40, Befunde Gegenprüfung 20:23 eingearbeitet, Nachprüfung offen)

Auftrag: Gesamtbild 5.3 Nr. 12 „Fremde Inhalte; Spieltext einbauen, quer, fehlt“ (Quellen `CLAUDE.md` „Technik und Sicherheit“, `LISTE-QUELLEN.md`; `STORY-REGELN.md`, `LISTE-GLOSSAR.md`); G:781 „quer: Fremde Inhalte (Lizenz, Quelle, Urheber je Datei) · Spieltext einbauen (Wortlaut aus `STORY-REGELN.md`, Begriffe aus `LISTE-GLOSSAR.md`)“; Reihenfolge Schritt 2 (`reihenfolge.md`:11). Form wie `profil-technik.md` F12; neue Profile kurz (Archiv 20.11., 14:02).

Geladen von: jede Fachkraft, deren Auftrag eine fremde Datei (Modell, Bewegung, Klang, Schrift, Effekt, Code) oder einen Spieltext ins Spiel bringt, zusätzlich zum Fachprofil; Arbeitsplaner und Prüfer bei solchen Aufträgen. Nicht hier: Spieltexte schreiben (Profil Story, Nr. 9: Entwurf bis zum Wort des Chefs); Klangkatalog im Einzelnen (Profil Klang, Nr. 7); Namen und Aussehenstexte der Kataloge (Profil Kataloge, Nr. 5, „nur aus der Quelle“); was der Sockel trägt (Zeile 6: „Fremde Dateien nur mit Lizenz für kommerzielle Nutzung; Spieltexte nur aus der Quelle, nie erfunden.“). **Gilt ab der Umstellung;** bis dahin gelten `CLAUDE.md` „Technik und Sicherheit“ und „Story und Dialoge“ wie sie sind.

Quellen: `CLAUDE.md` „Technik und Sicherheit“ (Lizenz, Kauf, Zweit-Repo, Nachweis je Datei), „Story und Dialoge“, „Begriffe“, Bekannte Fehler (`add_repo`, 1472); `LISTE-QUELLEN.md` (Lizenzregel, Prüfschema F1–F8, „Alle Quellen im Bestand“, Lizenzfallen, Lücken 1–2); `LISTE-BESTAND.md` (Kopf); `STORY-REGELN.md` (Regeln, Marke, Englisch); Archiv 348.12c, 780 A (09.11., 17:46), 1320 (Life); Gesamtbild 4.1 (Arbeitsplaner: Prüffrage Spieltext, fehlender Spieltext), 5.3 Nr. 9 (Profil Story F3, entschieden 20.11., 16:43), 3.3 F2.

## Ein- und Ausgang (Raster `ein-ausgang.md`)

| Feld | Inhalt | Fundstelle |
|---|---|---|
| Auslöser | Der Arbeitsplaner hängt das Querprofil unter „Beachte“ an jeden Auftrag, der eine fremde Datei oder einen Spieltext einbaut (wie das Querprofil Signatur und Leben bei Bild oder Klang, Archiv 20.11., 12:37); der Disponent startet die Fachkraft | G:417; VA 20.11., 12:37 (Muster); G:374 |
| Arbeit | Teil A, neben dem Fachprofil | — |
| Ende | wie Fachkraft: „fertig“, „Frage“ oder „abgebrochen“ mit Commit, Fällen, Beleg; dazu je neuer Datei die Nachweiszeile, je Text der Abgleich mit der Quelle | G:420; Teil A |
| Meldung | wie Fachkraft: Zeile über `vorgang.py` an das Büro, Nachricht nur Wecker | 3.3 F2 Nr. 2, 5 |
| Nächster Empfänger | „fertig“ → Prüfer (Prüffrage „jeder Satz wortgleich in der Quelle?“, G 4.1 Nr. 6); „Frage“ (Kauf, Lizenz unklar, Text fehlt) → Büro; Kauf und Geld beim Chef (`CLAUDE.md` „kauft nur der Chef“; Zusammenarbeit 4), Weg über den Meldeweg des Büros an die Leitung (VA 21.11., 11:46; C, VA 14:37) und von dort als Datei in `entscheiden/` (`ein-ausgang.md` Kette 6); fehlender Text → Auftrag mit Profil Story (G 4.1 „Nicht deins“) | G:420; 3.3 F2; G 4.1 |

**Lücken aus `ein-ausgang.md`:** Zeile Nr. 12 (Auslöser, Arbeit, Ende, Meldung, Empfänger „steht nicht“; L-O11): geschlossen durch Raster und Teil A. Der Auslöser braucht einen Satz im Text des Arbeitsplaners (Teil B). **Offen, nicht hier:** der Text des Profils Story endet „bis zum Wort des Chefs“, der Weg dorthin ohne Build ist L-O22; ein Text wird erst nach diesem Wort Quelle und damit einbaubar.

## Aufbau

- **Unity Asset Store (780):** `LISTE-QUELLEN.md` Lücke 1: Lizenzrahmen sagt „Unity Asset Store nein“ (EULA 2.2.1, KI als Eingabe), „Gegen Geld“ nennt ihn zulässig; entschieden ist nur 780 A „Zustimmung von Protofactor und Janpec einholen“; Protofactor schriftlich ja (10.11., 04:48), Janpec offen. Teil A setzt keine eigene Regel dafür, sondern schickt jede Lizenz, die nicht sicher passt, als „Frage“ zurück. **Chefsache (offen, keine Datei von mir):** ob neue Käufe aus dem Unity Asset Store ohne Zustimmung des Händlers gehen; ob Janpec bis zur Antwort weiter genutzt wird.
- **Bedingungen frei gegen gekauft:** `CLAUDE.md` (348.12c a) bindet „jede Engine, unbefristet, ohne Nennung und Umsatzgrenze“ an Gekauftes, für Freies reicht „kommerzielle Nutzung“; `LISTE-QUELLEN.md`:5 nennt die Bedingungen ohne Unterschied für alles. Teil A folgt `CLAUDE.md` (Quelle der Regel). **Chefsache (Lizenz, offen, keine Datei von mir):** sollen die strengeren Bedingungen auch für freie Lizenzen gelten (dann `CLAUDE.md` ändern) oder `LISTE-QUELLEN.md`:5 angleichen?
- **MIT-Teile** (REEBOO, `LISTE-QUELLEN.md` Lücke 2): Lösung „Hinweis in ‚Über das Spiel‘ wie bei Godot (497)“ steht dort nur zur Klärung; nicht übernommen.
- **Arbeitsplaner:** Teil B ergänzt Punkt 4 „Beachte“ (G 4.1). 4.1 ist Entwurf (G 0.1: „Entwurf, Fassung 2 17:05 gegengeprüft“), also keine Änderung von Entschiedenem; aufnehmen, wenn das Profil Arbeitsplaner geschrieben wird (L-O2, RF:14).
- **Englisch:** `CLAUDE.md` „Englisch selbst übersetzen“ und Profil Story („unsichere englische Stellen markieren“) passen zusammen; Teil A verlangt beim Einbau dasselbe Markieren, damit der Prüfer weiß, was nicht aus der Quelle kommt.

## Teil A: Querprofil Fremde Inhalte; Spieltext einbauen

```markdown
**Fremde Dateien.** Frei: offene Lizenz, die kommerzielle Nutzung erlaubt (etwa CC0). Gekauft: Lizenz erlaubt den Verkauf in jeder Engine, unbefristet, ohne Nennung und Umsatzgrenze. Lizenz auf der Quellseite prüfen, bei Bearbeitungen auch die des Originals. Neue Quelle erst nach dem Prüfschema in `docs/LISTE-QUELLEN.md`. Je Datei Quelle, Urheber, Lizenz im selben Commit festhalten (Ort je Art: dort „Alle Quellen im Bestand“). Gekaufte Rohdateien nur im privaten Repo `bornim-kaufmodelle` (Zugang `add_repo`), nie hier. Kaufen tut nur der Chef: Kauf oder unsichere Lizenz → „Frage“ zurück.

**Spieltext.** Verzeichnis `docs/STORY-REGELN.md`, Suche über die Marke `[Thema.kurz]`, wortgetreu. Fehlt das Englische, übersetzt du nach den Regeln dort und markierst es. Begriffe nach `docs/LISTE-GLOSSAR.md`. Fehlt ein Text: kein Platzhalter, „Frage“ mit Stelle zurück. Tippfehler im Text deines Auftrags direkt, Commit „Text:“. Beleg: jeder Satz wortgleich in der Quelle.
```

## Teil B: Text des Arbeitsplaners

G 4.1 Punkt 4 „Beachte“, hinter „bei Bild oder Klang das Querprofil Signatur und Leben“, **neu:** „; bei fremder Datei oder Spieltext das Querprofil Fremde Inhalte“.

## Eigene Prüfung (20:19)

- **Größe** (UTF-8, gemessen mit `wc -c`): Teil A 963 Byte (Ziel bis etwa 1.200). Teil B 64 Byte: Kern Arbeitsplaner 2.375 → etwa 2.439 Byte. Eine Fachkraft mit diesem Querprofil lädt Sockel 1.110 + Auftrag (bis etwa 2 KB) + Fachprofil (650–1.740) + 963. Regelbilanz: mit der Umstellung wird der Sockel die neue `CLAUDE.md` (Archiv 19.11., 13:33); die Absätze „Story und Dialoge“ (Einbau-Teil) und der Lizenzteil von „Technik und Sicherheit“ tragen danach Sockel 6 und dieses Profil, „Plot und Texte festlegen“ trägt Profil Story.
- **Quellen je Satz (Teil A):**
  1. „Frei: … kommerzielle Nutzung (etwa CC0). Gekauft: … jede Engine, unbefristet, ohne Nennung und Umsatzgrenze“: `CLAUDE.md` „Technik und Sicherheit“ (348.12c a); Abweichung `LISTE-QUELLEN.md`:5 im Aufbau.
  2. „Lizenz auf der Quellseite prüfen, bei Bearbeitungen auch die des Originals“: `CLAUDE.md` ebenda wörtlich; Fall Remixe (`LISTE-QUELLEN.md` Lizenzfallen 2).
  3. „Neue Quelle erst nach dem Prüfschema“: `LISTE-QUELLEN.md` Kopf (623, Chef 07.11.: Schema „auf … kommende Internetseiten anwenden“).
  4. „Je Datei Quelle, Urheber, Lizenz im selben Commit festhalten (Ort je Art …)“: `CLAUDE.md` („Quelle, Urheber, Lizenz je Datei festhalten“); „im selben Schritt“ `LISTE-BESTAND.md` Kopf; Orte `LISTE-QUELLEN.md` „Alle Quellen im Bestand“ (`LISTE-BESTAND.md`, `tools/klang/QUELLEN.md`, `tools/schrift/QUELLEN.md`). „Commit“ statt „Schritt“: Übersetzung in die Arbeitsweise der Fachkraft.
  5. „Gekaufte Rohdateien nur im privaten Repo … (Zugang `add_repo`), nie hier“: `CLAUDE.md` „Technik und Sicherheit“ und Bekannte Fehler (1472); Name `LISTE-QUELLEN.md` Lizenzregel, `LISTE-BESTAND.md` Kopf.
  6. „Kaufen tut nur der Chef: … ‚Frage‘ zurück“: `CLAUDE.md` („kauft nur der Chef“); „Frage“ als Ende der Fachkraft (G:420), Sockel 3 („unklar … anhalten, Frage zurückmelden“).
  7. „Verzeichnis …, Marke …, wortgetreu“: `CLAUDE.md` „Story und Dialoge“; `STORY-REGELN.md` Kopf und Regeln; „nur aus der Quelle“ trägt Sockel 6, darum nicht wiederholt.
  8. „Fehlt das Englische, übersetzt du nach den Regeln dort und markierst es“: `CLAUDE.md` („Englisch selbst übersetzen“); Regeln `STORY-REGELN.md` „Englische Spieltexte“; Markieren wie Profil Story F3 („unsichere englische Stellen markiert“); Erweiterung auf jede eigene Übersetzung: mein Vorschlag (Aufbau).
  9. „Begriffe nach `LISTE-GLOSSAR.md`“: `CLAUDE.md` „Begriffe (auch im Spiel)“; G:781.
  10. „Fehlt ein Text: kein Platzhalter, ‚Frage‘ mit Stelle zurück“: `CLAUDE.md` („Fehlt ein Text: … nie erfinden“); G 4.1 „Fehlender Spieltext: eigener Auftrag mit Profil Story, nie ein Platzhalter“; „Frage“ statt „Vorgang an Homer“, weil Rollen fallen (G:128) und das Büro weitergibt.
  11. „Tippfehler im Text deines Auftrags direkt, Commit ‚Text:‘“: `CLAUDE.md` „Story und Dialoge“, eingegrenzt durch Sockel 5 (Fund außerhalb des Auftrags zurückmelden, G:182, entschieden 20.11., 12:06).
  12. „Beleg: jeder Satz wortgleich in der Quelle“: G 4.1 Nr. 6 (Prüffrage bei Spieltext).
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
