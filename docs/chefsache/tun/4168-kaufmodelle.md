# 416.8 · Tom das Einbinden der Kaufmodelle erlauben
Tom · 08.11., 17:00 · E Technik

Die Leute drehen sich auf der Stelle, weil die Schrittbewegung beim Bau falsch vermessen wird (die Drehung endet bei 0 statt bei 90 Grad). Um das nachzustellen, braucht Tom die gekauften Bewegungen (privates Repo `bornim-kaufmodelle`) am Rechner. Das Einbinden hat der Prüfhaken der Sitzung heute um 16:46 abgelehnt, obwohl du es am 28.10. erlaubt hast (Archiv 376.1). Dasselbe hält 656 (Beulen im Umhang) und das Auffliegen der Hühner (591) auf.

Weg: in `.claude/settings.json` unter `permissions.allow` diese Regel ergänzen (oder Tom sagt es für dich, wenn du „ja, Regel eintragen“ antwortest):

```
mcp__claude-code-remote__add_repo
```

Danach in der nächsten Tom-Sitzung: „Tom, Kaufmodelle einbinden und 416.8 weiter“.
