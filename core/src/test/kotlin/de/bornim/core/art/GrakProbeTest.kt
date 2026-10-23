package de.bornim.core.art

import de.bornim.core.MonsterLook
import kotlin.test.Test
import de.bornim.core.art.HeroFigure.V

class GrakProbeTest {
    @Test
    fun probe() {
        val id = "hobgoblin_captain"
        val look = MonsterLook(0)
        val doll = FoeArt.doll(id, look); val o = FoeArt.outfit(id, look)
        val reach = o.base(de.bornim.core.GearSlot.MAIN_HAND)?.let(Dress::reach) ?: 90.0
        val seq = FoeArt.sequence(id, look, Act.ATTACK, 1)
        fun f(p: P3) = "(%5.1f %5.1f %5.1f)".format(p.x, p.y, p.z)
        fun show(n: String, rig: HeroFigure.Rig) {
            val sk = doll.fit(rig, o).first
            val head = sk.head.apply(doll.headC)
            val w = sk.weapon; val d = sk.hand(0) - sk.hand(1); val off = (d - w * (d dot w)).len()
            val axe = sk.hand(1) + sk.weapon * (reach * 0.85)
            val img = doll.render(FoeArt.W, FoeArt.height(id), FoeArt.ANCHOR_X, FoeArt.ground(id), FoeArt.PX, rig, o)
            fun up(q: P3) = "%.0f".format(FoeArt.ground(id) - img.project(q).second)
            val tip = sk.hand(1) + sk.weapon * reach
            val pw = doll.fit(seq.rigs[10], o).first.weapon
            val lead = (w - pw).let { (it - w * (it dot w)).norm() }
            println("FRAME $n lead=${"%.2f".format(sk.edge dot lead)} tip=${up(tip)} hand=${up(sk.hand(1))} free=${up(sk.hand(0))} head=${up(head)} elW=${up(sk.elbow[1])}")
            println("PROBE $n head${f(head)} free${f(sk.hand(0))} wpn${f(sk.hand(1))} elFree${f(sk.elbow[0])} elW${f(sk.elbow[1])} axe${f(axe)} w${f(w)} edge${f(sk.edge)} off=${"%.1f".format(off)} face${f(sk.head.dir(P3.Z))}")
        }
        val swing = seq.rigs[10]; val hit = seq.rigs[11]; show("drop0", seq.rigs[9])
        show("swing0", swing); show("hit0", hit); show("follow0", seq.rigs[14])
        val cands = (System.getenv("PROBE") ?: "").split(";").filter { it.isNotBlank() }
        for (c in cands) {
            val m = c.split(",").associate { it.split("=").let { (k, v) -> k to v } }
            fun v(s: String?) = s?.split(":")?.map(String::toDouble)?.let { V(it[0], it[1], it[2]) }
            val base = if (m["b"] == "s") swing else hit
            val r = base.copy(rh = v(m["rh"]) ?: base.rh, weapon = v(m["w"]) ?: base.weapon, elbowAt = v(m["ea"]) ?: base.elbowAt,
                elbowUp = m["eu"]?.toDouble() ?: base.elbowUp, headDown = m["hd"]?.toDouble() ?: base.headDown, roll = m["ro"]?.toDouble() ?: base.roll, twist = m["tw"]?.toDouble() ?: base.twist, rPole = v(m["rp"]) ?: base.rPole)
            show(c, r)
        }
    }
}
