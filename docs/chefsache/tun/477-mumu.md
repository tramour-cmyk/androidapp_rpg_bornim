# 477 · Godot-Build im MuMu Player: einmal genau ansehen, was passiert
Tom · 03.11., 00:5x · E Technik

Am Rechner lässt sich MuMu hier nicht nachstellen (kein Emulator in unserer Umgebung). Darum einmal bei dir, wenn du ohnehin den nächsten Build installierst:

1. Godot-APK im MuMu Player installieren und starten.
2. Was passiert? Eins davon reicht als Antwort:
   - **a** Installation schlägt fehl (Meldung abschreiben)
   - **b** App öffnet sich, Schirm bleibt schwarz
   - **c** App schließt sich sofort wieder
   - **d** etwas anderes (ein Satz)
3. In MuMu unter Einstellungen den Grafikmodus ansehen (bei MuMu 12: „Rendering-Modus“ Vulkan oder DirectX) und nennen, welcher eingestellt ist. Ist es DirectX: auf Vulkan stellen, MuMu neu starten, App noch einmal starten, wieder a bis d.

Zu sagen: „477: b, DirectX; mit Vulkan läuft es“ oder ähnlich. Damit weiß ich, ob es am Grafikweg liegt (unser Spiel braucht Vulkan oder weicht auf OpenGL aus) oder an etwas anderem.
