import SwiftUI

enum TrailThemeVariant {
    case daybreak
    case meadow
    case sunset
    case night
}

struct TrailPalette {
    let background: Color
    let surface: Color
    let elevated: Color
    let primaryText: Color
    let secondaryText: Color
    let purple: Color
    let cyan: Color
    let green: Color
    let orange: Color
    let subtleFill: Color
    let border: Color
}

enum TrailTheme {
    static let activeVariant: TrailThemeVariant = .daybreak

    private static var palette: TrailPalette {
        switch activeVariant {
        case .daybreak:
            TrailPalette(
                background: Color(red: 0.96, green: 0.98, blue: 0.97),
                surface: Color(red: 1.00, green: 1.00, blue: 0.99),
                elevated: Color(red: 0.91, green: 0.96, blue: 0.95),
                primaryText: Color(red: 0.08, green: 0.11, blue: 0.13),
                secondaryText: Color(red: 0.39, green: 0.47, blue: 0.50),
                purple: Color(red: 0.48, green: 0.32, blue: 0.92),
                cyan: Color(red: 0.04, green: 0.56, blue: 0.68),
                green: Color(red: 0.08, green: 0.58, blue: 0.32),
                orange: Color(red: 0.91, green: 0.37, blue: 0.12),
                subtleFill: Color(red: 0.08, green: 0.11, blue: 0.13).opacity(0.07),
                border: Color(red: 0.08, green: 0.11, blue: 0.13).opacity(0.10)
            )
        case .meadow:
            TrailPalette(
                background: Color(red: 0.93, green: 0.97, blue: 0.92),
                surface: Color(red: 0.99, green: 1.00, blue: 0.97),
                elevated: Color(red: 0.86, green: 0.94, blue: 0.87),
                primaryText: Color(red: 0.08, green: 0.15, blue: 0.11),
                secondaryText: Color(red: 0.35, green: 0.47, blue: 0.38),
                purple: Color(red: 0.38, green: 0.34, blue: 0.80),
                cyan: Color(red: 0.05, green: 0.54, blue: 0.55),
                green: Color(red: 0.12, green: 0.55, blue: 0.25),
                orange: Color(red: 0.82, green: 0.43, blue: 0.14),
                subtleFill: Color(red: 0.08, green: 0.15, blue: 0.11).opacity(0.07),
                border: Color(red: 0.08, green: 0.15, blue: 0.11).opacity(0.10)
            )
        case .sunset:
            TrailPalette(
                background: Color(red: 0.99, green: 0.95, blue: 0.91),
                surface: Color(red: 1.00, green: 0.99, blue: 0.97),
                elevated: Color(red: 0.97, green: 0.90, blue: 0.84),
                primaryText: Color(red: 0.17, green: 0.10, blue: 0.08),
                secondaryText: Color(red: 0.52, green: 0.39, blue: 0.34),
                purple: Color(red: 0.58, green: 0.28, blue: 0.73),
                cyan: Color(red: 0.04, green: 0.53, blue: 0.67),
                green: Color(red: 0.20, green: 0.55, blue: 0.28),
                orange: Color(red: 0.91, green: 0.35, blue: 0.13),
                subtleFill: Color(red: 0.17, green: 0.10, blue: 0.08).opacity(0.07),
                border: Color(red: 0.17, green: 0.10, blue: 0.08).opacity(0.10)
            )
        case .night:
            TrailPalette(
                background: Color(red: 0.03, green: 0.04, blue: 0.07),
                surface: Color(red: 0.08, green: 0.10, blue: 0.14),
                elevated: Color(red: 0.10, green: 0.13, blue: 0.18),
                primaryText: Color(red: 0.97, green: 0.98, blue: 0.99),
                secondaryText: Color(red: 0.58, green: 0.64, blue: 0.72),
                purple: Color(red: 0.55, green: 0.36, blue: 0.96),
                cyan: Color(red: 0.13, green: 0.83, blue: 0.93),
                green: Color(red: 0.13, green: 0.77, blue: 0.37),
                orange: Color(red: 0.98, green: 0.45, blue: 0.09),
                subtleFill: Color.white.opacity(0.10),
                border: Color.white.opacity(0.08)
            )
        }
    }

    static var background: Color { palette.background }
    static var surface: Color { palette.surface }
    static var elevated: Color { palette.elevated }
    static var primaryText: Color { palette.primaryText }
    static var secondaryText: Color { palette.secondaryText }
    static var purple: Color { palette.purple }
    static var cyan: Color { palette.cyan }
    static var green: Color { palette.green }
    static var orange: Color { palette.orange }
    static var subtleFill: Color { palette.subtleFill }
    static var border: Color { palette.border }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [purple, cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
