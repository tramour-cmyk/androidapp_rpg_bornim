# 1317: MESS-Lauf mit --headless gilt nicht als Bildlauf, auch wenn der Test save_png enthält. Aufruf: python3 tools/probelauf_mess_test.py
import os, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import probelauf

tmp = tempfile.mkdtemp()
os.makedirs(os.path.join(tmp, "godot", "tests"))
open(os.path.join(tmp, "godot", "tests", "bild_t.gd"), "w").write('if ordner != "":\n\troot.get_texture().get_image().save_png("x.png")\n')
fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

kopf = "MESS=1314 godot --path godot "
soll("--headless: kein Bild", probelauf.bild_im_test(kopf + "--headless --fixed-fps 30 -s res://tests/bild_t.gd", tmp, None), False)
soll("ohne --headless: Bild", probelauf.bild_im_test(kopf + "--fixed-fps 30 -s res://tests/bild_t.gd", tmp, None), True)
soll("xvfb-run ohne --headless: Bild", probelauf.bild_im_test("MESS=1314 xvfb-run godot --path godot -s res://tests/bild_t.gd", tmp, None), True)
soll("--headless mit --write-movie: Bild", probelauf.bild_im_test(kopf + "--headless --write-movie a.avi -s res://tests/bild_t.gd", tmp, None), True)
soll("--headless-x ist kein --headless", probelauf.bild_im_test(kopf + "--headless-x -s res://tests/bild_t.gd", tmp, None), True)
sys.exit(1 if fehl else 0)
