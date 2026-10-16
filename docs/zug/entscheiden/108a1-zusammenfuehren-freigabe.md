# 108a.1 · Wer führt #90, #91, #85 nach `main`?

Jerry · 16.10., 15:56 · Builds 3, 4, 5 passen (Chef 15:2x–15:4x)

Kurz: Freigabeprüfung sperrt das Zusammenführen; Regel eintragen oder selbst auf GitHub zusammenführen

#89 ist auf `main` (127d6449). Danach sperrt der Freigabe-Modus der App jeden weiteren Schritt („Merge Without Review“), auch das Prüfen auf Konflikte.

- **A (Empfehlung):** Regel in der App erlauben, Jerry führt #90, #91 (Konflikt in `SfxPlayer.kt` lösen, Build abwarten), #85 zusammen.
- **B:** Chef führt auf GitHub selbst zusammen, Reihenfolge #90, #91, #85; Jerry trägt danach die Notizen nach. #91 zeigt dabei voraussichtlich einen Konflikt, den nur Jerry lösen kann.

Gegenargument zu A: Die Sperre soll verhindern, dass Code ohne Blick des Chefs auf `main` gelangt; getestet hat er die Builds aber schon.
