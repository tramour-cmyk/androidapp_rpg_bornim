# 1727, Prüfung des Gesamtbilds (20.11., 21:40)

Auftrag Chef 20.11., 21:36: „Lass das Dokument nochmals komplett auf Funktionalität, Komplexität, Vollumfänglichkeit und Stringenz prüfen.“ Zwei frische Helfer, Stand main d88963a2c. Mein Wort je Befund in der Spalte rechts.

## Schwerste Befunde

| Nr. | Befund | Wort Sokrates |
|---|---|---|
| 1 | Gesamtbild als Quelle nicht verlässlich: 143 KB, etwa 81 % Verlauf, 28 Codeblöcke; Statuszeilen veraltet (Überblick Zeilen 5, 10–14; „Nicht geschrieben“ 754; 5.3 Nr. 1, 13, 14); gültiger Text in 2.2, 2.3, 5.1 als Blockzitat | stimmt; je Teil eine Arbeitsdatei nur mit gültigem Text (Chef 16:50 Schritt 2), Verlauf in Git, 0.1 per Skript |
| 2 | Übergabekette länger: 8–10 Übergaben je Vorgang über das Büro (heute etwa 3), jedes Nein +4, Zeit je Übergabe nicht gemessen; je Sitzung einfacher, als System eher komplexer | stimmt; stärkster Einwand gegen das Konzept; Weiterleiten mechanisch in `lauf.py`, im Falltest mit Zeit messen; Frage an den Chef |
| 3 | Kreislauf hängt an Werkzeugen, die fehlen: `vorgang.py --hilfe`, `auftrag`, `schliessen`, Vorgangsdatei, Laufbremse, `lauf.py` mit Prüfer und Rückläufern, Ende-Haken, Herzschlag, Testbitte A13, Build-Vergleich, Auslöser Routinen, Rufnamen, Eingang, Umzug „Zu <Nr>“; Bauliste 7.1 nur drei Zeilen | stimmt; 7.1 vollständig, Umstellung erst, wenn jedes grün läuft |
| 4 | Build, Merge nach `main`, Release ohne Text: Profil Technik fehlt, Signalkette nennt „Profil Build“, Kern Büro sagt nicht, wer mergt und den Tester startet | stimmt; Profil Technik als Nächstes |
| 5 | Feste Regeln ohne Ort und ohne „fällt“: Kerntests vor Code-Commit, Weckruf nach Push, Werkzeug nach grünem Lauf sofort nach `main` (1311, Kern Büro widerspricht), Notizen auf `main` per Edit/Write, `CHANGELOG.md`, Vollzugszeile, Commit-Systemzeilen, keine Modellnamen, `add_repo`, Kauf und Zweit-Repo | stimmt; 0c Spalte „bleibt, wo“ je Zeile aus „Feste Regeln“ und „Technik und Sicherheit“ |
| 6 | Auftragsfelder an vier Stellen verschieden (0a 11, Kern 7, Baukasten 7, Feld 8, `vorgang.py` „sieben“); Stand des Vorgangs zugleich „abgeleitet“ und Katalogwert | stimmt; Feldliste nur im Werkzeug, Kern und 0a verweisen |
| 7 | Doppelte gültige Texte: Kern Prüfer 6.1 neben 6.2; Signatur im Kern Abnahme ausgeschrieben statt Verweis (gegen Archiv 12:37); Baukasten 4.2 neben Kern Arbeitsplaner | stimmt; 6.1 und 4.2 als Verlauf markieren, Kern Abnahme verweist |
| 8 | Lücken nach Wegfall von Leitbild, Rollen, `CLAUDE.md`: Tester verweist aufs Leitbild; 72a ohne Ort (2.3 enthält es nicht); Chefrunde und Markt hängen an `ROLLE-BERATUNG*.md`; „Bekannte Fehler“, Eingang, Ideendurchsicht (Archiv 19.11., 17:13) ohne Ort; Telegram-Regeln erst mit `meldung.sh` | stimmt; Verweisprüfung per grep in den Falltest |
| 9 | „Macher“ in Kern Büro und Kern Arbeitsplaner (Archiv 07:26, 07:53: Ersatz „Fachkraft“); Kern Büro kennt weder Werkstatt, Abnahme noch Tester | stimmt; berichtigen |
| 10 | Meldewege offen: „Frage“, „abgebrochen“ der Werkstatt und „Frage“ des Arbeitsplaners ohne Weg im Kern Büro; Kern Leitung ohne „steckt fest“ und „gut“ ans Büro; Kennung des Büros für gestartete Sitzungen | stimmt; `lauf.py` schreibt Kennung ins Feld „Zurück“, Kern Büro je erstes Wort eine Zeile |
| 11 | Guthaben knapp, festgefahren: Laufbremse, Höchstdauer, Tagesbericht, Wache nicht gebaut; Regler „Zahl der Werkstätten“ in keinem Kern | stimmt; Freigabe ab 40 $ gilt ohnehin bis zur Umstellung |
| 12 | Kerne für genau eine Funktion (Büro, Leitung, Arbeitsplaner) gegen Grundsatz 07:22 „jede Stufe von mehreren geteilt“ | Frage; Kern heißt hier „Startprompt der Funktion“, Grundsatz neu fassen oder Kerne zusammenlegen |
| 13 | Vier Bremsen (Lauf, Dauer, Größe, Hoch) | stimmt; im Falltest auf zwei prüfen |
| 14 | Kleinere: `docs/akte/` statt `docs/vorgang/` in 7.1; Sperre `main` muss Notizen frei lassen; Profil Kampf Pfad ohne `docs/`; toter Anker im Überblick; Größen im Fließtext abweichend; 0.1 ohne Wochenzählung, Figur, Chefrunde, Markt; Summen „Neu“ unterschätzen (Werkstatt Kampf etwa 8,5 KB) | stimmt; mit dem Aufräumen |

## Noch nicht geschrieben

Profile Technik, Werkzeug, Fremde Inhalte, Spieltext einbauen; Büro-Profile (Release, Kosten); Routinen Tagesbericht, Wache; Chefrunde an neue Ordnung anpassen. Entwurf, Falltest offen: Kern Büro, Kern Arbeitsplaner, Kern Abnahme, Profil Prüfer, Profil Tester, Profil Figur.

## Offen beim Chef (nur im Text, ohne Chefsache-Datei)

Leitbild löschen nach Umzug der Reste (1a); „Eintauchen“ in die Abnahme; Pfad Eingang; Feld Modell und Aufwand (1742); Werkzeuge der Teams E Technik oder B Werkzeuge; Routine auch für C; Takt Tester, Rundblick; Katalog fester Werte (30 Befunde); Schutz 15 Minuten (Spike).
