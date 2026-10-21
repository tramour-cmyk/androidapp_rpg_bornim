# Logo und Geschäftspapiere BornWire TCS (251.1)

Logo „Leiterbahn“ (Vorgangsarchiv 251.3). Alles erzeugt `erzeugen.py` (Aufruf im Kopf der Datei); von Hand nichts ändern, sondern dort.

## Logo (`logo/`)

| Datei | Wofür |
|---|---|
| `quer.svg`, `quer-dunkel.svg` (PNG 1200 px) | Briefkopf, Webseite, Kopf von PDFs; Zeichen, BornWire, Strich, TCS |
| `quer-ohne-tcs*.svg` | wo TCS zu klein würde (unter etwa 25 mm Breite) |
| `hoch.svg`, `hoch-dunkel.svg` (PNG 600 px) | Visitenkarte, Startbild, quadratische Flächen |
| `zeichen.svg`, `-dunkel`, `-sw`, `-weiss` (PNG 48, 192, 512 px) | Zeichen allein; `-sw` für Stempel, Fax, Schwarz-Weiß-Druck |
| `app-symbol.svg` (PNG 512 px), `favicon.ico` | Store-Eintrag des Entwicklers, Webseite |

Schrift als Pfade (Inter, SIL Open Font License 1.1), also ohne installierte Schrift gleich. Farben: Tinte `#161a22`, Papier `#f4f1ea`, Gold `#f0b429`.

## Vorlagen (`vorlagen/`)

Briefbogen, Anschreiben, Rechnung, Quittung Tester: je HTML (zum Ausfüllen, im Browser als PDF drucken) und PDF (Muster). A4 nach DIN 5008 Form B (Anschriftfeld für Fensterumschlag DL, Falz- und Lochmarken). Platzhalter in «…»; Anschrift, Steuernummer und Bank stehen nur im vertraulichen Fahrplan-Dokument (246.2) und kommen nie in Git.

Rechnung mit den Angaben nach § 14 UStG und dem Hinweis nach § 19 UStG (Kleinunternehmer); vor der ersten echten Rechnung vom Steuerberater oder Finanzamt bestätigen lassen.
