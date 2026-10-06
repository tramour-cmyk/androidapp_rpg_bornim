package de.bornim.core

/** Body form of a hero, chosen at creation. */
enum class Sex(val title: T) {
    MALE(T("Männlich", "Male")),
    FEMALE(T("Weiblich", "Female")),
}

/** How heavily a hero is built, chosen at creation. */
enum class Build(val title: T) {
    SLIM(T("Schlank", "Slim")),
    AVERAGE(T("Normal", "Average")),
    STRONG(T("Kräftig", "Strong")),
}

/** Skin and hair colours each people comes in. The SRD names sizes only; the tones follow the usual lore, muted for the game's look. */
object Appearance {
    class Tone(val title: T, val rgb: Int)

    fun skins(race: Race): List<Tone> = when (race) {
        Race.HUMAN -> listOf(
            Tone(T("Hell", "Fair"), 0xEACBAE.toInt()),
            Tone(T("Warm", "Warm"), 0xD4A27C.toInt()),
            Tone(T("Oliv", "Olive"), 0xA8764F.toInt()),
            Tone(T("Dunkel", "Dark"), 0x6E4632.toInt()),
        )
        Race.ELF -> listOf(
            Tone(T("Blass", "Pale"), 0xEEDDCC.toInt()),
            Tone(T("Hell", "Fair"), 0xE0BE9E.toInt()),
            Tone(T("Kupfer", "Copper"), 0xC08A64.toInt()),
            Tone(T("Bronze", "Bronze"), 0x93664A.toInt()),
        )
        Race.DWARF -> listOf(
            Tone(T("Rosig", "Ruddy"), 0xE2B094.toInt()),
            Tone(T("Gebräunt", "Tanned"), 0xC48864.toInt()),
            Tone(T("Braun", "Brown"), 0x996246.toInt()),
            Tone(T("Dunkel", "Dark"), 0x6A4432.toInt()),
        )
        Race.HALFLING -> listOf(
            Tone(T("Hell", "Fair"), 0xEACAA8.toInt()),
            Tone(T("Rotwangig", "Rosy"), 0xD8A47E.toInt()),
            Tone(T("Gebräunt", "Tanned"), 0xB07A55.toInt()),
            Tone(T("Dunkel", "Dark"), 0x84573A.toInt()),
        )
        Race.HALF_ORC -> listOf(
            Tone(T("Graugrün", "Grey-green"), 0x8E9682.toInt()),
            Tone(T("Oliv", "Olive"), 0x7A8066.toInt()),
            Tone(T("Aschgrau", "Ash"), 0x86857C.toInt()),
            Tone(T("Moosgrün", "Moss"), 0x646B56.toInt()),
        )
    }

    fun hairs(race: Race): List<Tone> = when (race) {
        Race.ELF -> listOf(Tone(T("Silberblond", "Silver blond"), 0xD8CBA0.toInt()), Tone(T("Kupfer", "Copper"), 0x9A4E2A.toInt()), Tone(T("Schwarz", "Black"), 0x2A2420.toInt()), Tone(T("Weißgrau", "White"), 0xC8C4BC.toInt()))
        Race.DWARF -> listOf(Tone(T("Rot", "Red"), 0x9A4422.toInt()), Tone(T("Braun", "Brown"), 0x5A3A24.toInt()), Tone(T("Schwarz", "Black"), 0x262220.toInt()), Tone(T("Grau", "Grey"), 0x8C8882.toInt()))
        Race.HALF_ORC -> listOf(Tone(T("Schwarz", "Black"), 0x24221F.toInt()), Tone(T("Dunkelbraun", "Dark brown"), 0x3E2C20.toInt()), Tone(T("Grau", "Grey"), 0x6E6C66.toInt()), Tone(T("Rostbraun", "Rust"), 0x6A3A22.toInt()))
        else -> listOf(Tone(T("Braun", "Brown"), 0x5E3C26.toInt()), Tone(T("Blond", "Blond"), 0xB8975E.toInt()), Tone(T("Schwarz", "Black"), 0x262220.toInt()), Tone(T("Rot", "Red"), 0x8A3E22.toInt()))
    }
}
