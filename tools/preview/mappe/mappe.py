# 145 Kartenmappe: nach `KARTENMAPPE=1 ../../gradlew -q run` die Seite build/kartenmappe.html bauen (python3 mappe/mappe.py)
import base64, io
from PIL import Image
import os
D=os.path.dirname(os.path.abspath(__file__))
S=D+'/../build/screens/mappe_%s.png'
def uri(i):
    im=Image.open(S%i).convert('RGB'); b=io.BytesIO(); im.save(b,'JPEG',quality=88,optimize=True)
    return 'data:image/jpeg;base64,'+base64.b64encode(b.getvalue()).decode()
# land: names over drawing, coords from LandSheet.spots (×3 on 600×900)
land=[('Bornim',60,214),('Flüsterwald',54,174),('Tiefer Flüsterwald',166,112+21)]
labels=''.join(f'<span class="ln" style="left:{x/2:.1f}%;top:{y/3:.1f}%">{n}</span>' for n,x,y in land)
area=[('village','Bornim','Gebietskarte · darin Schänke, Haus des Ältesten, Laden, Tempel'),
      ('forest','Flüsterwald','Gebietskarte · darin die Blutzahnhöhle'),
      ('deep_forest','Tiefer Flüsterwald','Gebietskarte')]
plans=[('inn','Zum Schlafenden Greif','Grundriss · in Bornim'),('elder','Haus des Ältesten','Grundriss · in Bornim'),
       ('shop','Thessas Kramladen','Grundriss · in Bornim'),('temple','Tempel des Morgenlichts','Grundriss · in Bornim'),
       ('cave','Blutzahnhöhle','Grundriss · im Flüsterwald')]
def fig(i,t,c,cls='sheet'):
    return f'<figure class="{cls}"><img src="{uri(i)}" alt="Karte {t}"><figcaption><b>{t}</b><span>{c}</span></figcaption></figure>'
html=open(D+'/kopf.html').read()
html=html.replace('@LAND@',uri('land')).replace('@LABELS@',labels)
html=html.replace('@AREA@',''.join(fig(*a) for a in area))
html=html.replace('@PLANS@',''.join(fig(*p, cls='sheet plan') for p in plans))
open(D+'/../build/kartenmappe.html','w').write(html); print(len(html)//1024,'KB')
