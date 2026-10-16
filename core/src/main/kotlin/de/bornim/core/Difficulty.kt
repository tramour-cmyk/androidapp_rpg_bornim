package de.bornim.core

/**
 * 39 (Beschluss 39a, 12.10., 10:10): Leicht, Normal, Schwer change only the foes' hit points and the damage they deal,
 * any time in the menu. "Normal" is the measured balance (38); the factors below are a proposal until the Chef decides.
 */
enum class Difficulty(val hp: Double, val damage: Double) {
    EASY(0.8, 0.8),
    NORMAL(1.0, 1.0),
    HARD(1.2, 1.2),
}
