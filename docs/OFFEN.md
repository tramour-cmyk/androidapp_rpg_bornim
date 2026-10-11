# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 22** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Nachtarbeit](NACHT.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 13 | Diagonale Sicht | Tom | `tom-diagonal` | Schänke auf `main` (v0.1.471). Ältester, Laden, Tempel getestet in 0.1.482 („alles passt“), PR #20 wartet auf Freigabe. Danach: Dorf draußen (5) |
| 5 | Dorf draußen, Dorfbewohner als Puppen (auch Aldric mit Stock) | Tom | `tom-dorf` (von `tom-diagonal`) | 5e go: 5.1 → 5.2 → 5.3 → 5.4. 5f „super“ (13:19). 5h (Nutzer): Fenster außen und innen müssen zusammenpassen; Vorschlag im Chat 13:22. 5g (Glockenstuhl/Turm) offen |
| 17 | Nachschwingen: Umhang, Haare, Köcher, Riemen beim Stoppen und Drehen | Tom | neu von `main` | freigegeben 10.10.; nach 13 |
| 14 | Neustart-Haken: misst Gesprächsgröße, Hinweis an die Sitzung | Tom | neu von `main` (Werkzeug, PR) | freigegeben 10.10. |
| 15 | `OFFEN.md` entschlacken, Archiv, Themenliste | Tom | `main` (Notizen) | erledigt 11.10.; Jerrys Teil geprüft 11.10. |
| 9i | Übrige Gegner auf der Karte (Entwürfe `MAPFOE=others\|cave\|wood`) | Jerry | – | freigegeben; nach 13 |
| 10, 11 | Höhle: Flammen feiner, Lichtstrahl am Schacht | Jerry | – | zurückgestellt bis zur diagonalen Höhle (13e) |
| 18 | Klänge neu aus echten Aufnahmen (CC0) | Jerry | `claude/session-start-l65s4j`, PR #19 | 0.1.486 getestet 13:10 („okay“); wartet auf Freigabe zum Zusammenführen; danach Runde 2 und übrige Gegner |
| 20 | Uhrzeit der APK im ZIP 2 h zu früh (ZIP speichert Ortszeit ohne Zone, Runner läuft in UTC) | Tom | `claude/beautiful-feynman-ta7v9p`, PR #21 | 20a ja (13:00): `TZ=Europe/Berlin` beim Hochladen, Build läuft, Prüfung am ZIP |
| 19e | „Bewegungen teilweise unrund“ (ohne Beispiel) | Jerry | – | zur Beobachtung |
| 21 | Releaseflut eindämmen (jeder PR auf `main` = ein Release) | Jerry (Vorschlag) | – | Ideen 21.1–21.4, Rückfrage 21a |

Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (11.10., 11:40)

- Alles gepusht. `main` = v0.1.471 (13 Schänke diagonal, getestet und freigegeben). Zweig `tom-diagonal`: Entwürfe Ältester, Laden, Tempel nur in der Vorschau (`World.drafts`; `ISODINGE=aeltester|laden|tempel`, `ONLY=zoom_nah_e|l|t`), neue Felder `DESK d`, `TRUNK a`, `ARMCHAIR s`, `HANGING V`, `RACK U`, `CANDLES N`, `FONT &`.
- **Als Nächstes:** Grundriss A von Ältestem, Laden und Tempel ins Spiel (unter dem Schalter „Dorf und Räume“), Tempelwände Stein, Kerntest (Held erreicht Person und Tür), Zweig-Build. Dann 17, dann 14.
- Feste Weck-Routinen für Tom eingerichtet und getestet (`docs/NACHT.md`).

### Jerry (11.10., 12:43)

- `main` = v0.1.483 (12.3b, 12.3c; PR #18 zusammengeführt). Kein offener Zweig.
- 18: Hörproben aus echten Aufnahmen (CC0) beim Nutzer (`hoerproben_18_echt.zip`, Rückfrage 18g). Werkzeug (Python: `klang.py`, `recipes.py`) liegt nur im Notizblock dieser Sitzung; bei Zusage als `tools/klang/` in einen eigenen Zweig, Dateien nach `app/src/main/assets`.
- Als Nächstes: 18 nach Rückmeldung; 9i nach Toms 13; 10, 11 nach 13e. Feste Weck-Routinen 00:27, 03:17, 05:57.
- APK in den Chat: Release `gh api -H "Accept: application/octet-stream" repos/tramour-cmyk/androidapp_rpg_bornim/releases/assets/<id>`; Zweig-Artefakt `gh api repos/…/actions/artifacts/<id>/zip`.

## Zu testen

– nichts offen –

## Rückfragen an den Nutzer

- **21a** (Jerry): Welcher Weg gegen die Releaseflut? Empfehlung 21.1 (Release nur auf Zuruf) + 21.4 (doppelte Zweig-Builds weg).



- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). **Zurückgestellt** (Nutzer 11.10., 13:00), bis die Umstellung auf die diagonale Sicht mit allen Facetten fertig ist.
