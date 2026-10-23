# Logo und Geschäftspapiere BornWire TCS (251.1)

Logo „Leiterbahn“ (Vorgangsarchiv 251.3) mit Lötaugen an beiden Enden (251.4, Fassung C; innen ausgestanzt, also in jeder Grundfarbe; Favicon ohne, weil sie bei 16 px verschwimmen). Alles erzeugt `erzeugen.py` (Aufruf im Kopf der Datei); von Hand nichts ändern, sondern dort.

## Logo (`logo/`)

| Datei | Wofür |
|---|---|
| `quer.svg`, `quer-dunkel.svg` (PNG 1200 px) | Briefkopf, Webseite, Kopf von PDFs; Zeichen, BornWire, Strich, TCS |
| `quer-papier.svg` (PNG 2400 px) | Briefkopf der Vorlagen: TCS in Tinte statt Gold (Vorgangsarchiv 251.1, C) |
| `quer-ohne-tcs*.svg` | wo TCS zu klein würde (unter etwa 25 mm Breite) |
| `hoch.svg`, `hoch-dunkel.svg` (PNG 600 px) | Visitenkarte, Startbild, quadratische Flächen |
| `zeichen.svg`, `-dunkel`, `-sw`, `-weiss` (PNG 48, 192, 512 px) | Zeichen allein; `-sw` für Stempel, Fax, Schwarz-Weiß-Druck |
| `app-symbol.svg` (PNG 512 px), `favicon.ico` | Store-Eintrag des Entwicklers, Webseite |
| `entwicklersymbol-512.png` | Entwicklerseite in der Play Console: App-Symbol ohne Transparenz auf Tinte (Google verlangt 24-Bit-PNG) |

Schrift als Pfade (Inter, SIL Open Font License 1.1), also ohne installierte Schrift gleich. Farben: Tinte `#161a22`, Papier `#f4f1ea`, Gold `#f0b429`.

## Vorlagen (`vorlagen/`)

Briefbogen, Anschreiben, Rechnung, Quittung Tester: je HTML (zum Ausfüllen, im Browser als PDF drucken), PDF (Muster) und Word (`.docx`, Schrift Arial; Falz- und Lochmarken nur in HTML und PDF; Lage im Fensterumschlag einmal an einem Ausdruck prüfen). A4 nach DIN 5008 Form B (Anschriftfeld für Fensterumschlag DL, Falz- und Lochmarken). Platzhalter in «…»; Anschrift, Steuernummer und Bank stehen nur im vertraulichen Fahrplan-Dokument (246.2) und kommen nie in Git.

Rechnung mit den Angaben nach § 14 UStG und dem Hinweis nach § 19 UStG (Kleinunternehmer); vor der ersten echten Rechnung vom Steuerberater oder Finanzamt bestätigen lassen.
