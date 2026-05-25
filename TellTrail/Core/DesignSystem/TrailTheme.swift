import SwiftUI

enum TrailThemeVariant {
    case daybreak
    case meadow
    case sunset
    case night
    case travel
    case environment
    case voices
    case echo
    case wanderlust
    case coastalEscape
    case lushExplorer
    case sunsetWanderlust
    case modernMinimalist
    case tripGlass
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
    static let activeVariant: TrailThemeVariant = .tripGlass

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
        case .travel:
            TrailPalette(
                background: Color(red: 0.95, green: 0.98, blue: 1.00),
                surface: Color(red: 1.00, green: 1.00, blue: 0.98),
                elevated: Color(red: 0.88, green: 0.95, blue: 0.96),
                primaryText: Color(red: 0.05, green: 0.13, blue: 0.27),
                secondaryText: Color(red: 0.34, green: 0.45, blue: 0.54),
                purple: Color(red: 0.15, green: 0.26, blue: 0.56),
                cyan: Color(red: 0.00, green: 0.58, blue: 0.63),
                green: Color(red: 0.12, green: 0.56, blue: 0.35),
                orange: Color(red: 0.96, green: 0.67, blue: 0.15),
                subtleFill: Color(red: 0.05, green: 0.13, blue: 0.27).opacity(0.07),
                border: Color(red: 0.05, green: 0.13, blue: 0.27).opacity(0.10)
            )
        case .environment:
            TrailPalette(
                background: Color(red: 0.92, green: 0.96, blue: 0.90),
                surface: Color(red: 0.98, green: 1.00, blue: 0.96),
                elevated: Color(red: 0.84, green: 0.91, blue: 0.82),
                primaryText: Color(red: 0.05, green: 0.16, blue: 0.09),
                secondaryText: Color(red: 0.29, green: 0.42, blue: 0.32),
                purple: Color(red: 0.38, green: 0.35, blue: 0.66),
                cyan: Color(red: 0.05, green: 0.46, blue: 0.42),
                green: Color(red: 0.06, green: 0.42, blue: 0.20),
                orange: Color(red: 0.68, green: 0.39, blue: 0.16),
                subtleFill: Color(red: 0.05, green: 0.16, blue: 0.09).opacity(0.08),
                border: Color(red: 0.05, green: 0.16, blue: 0.09).opacity(0.11)
            )
        case .voices:
            TrailPalette(
                background: Color(red: 0.06, green: 0.06, blue: 0.08),
                surface: Color(red: 0.12, green: 0.12, blue: 0.15),
                elevated: Color(red: 0.17, green: 0.16, blue: 0.20),
                primaryText: Color(red: 0.98, green: 0.97, blue: 0.95),
                secondaryText: Color(red: 0.68, green: 0.66, blue: 0.71),
                purple: Color(red: 0.66, green: 0.45, blue: 0.90),
                cyan: Color(red: 0.27, green: 0.76, blue: 0.78),
                green: Color(red: 0.30, green: 0.70, blue: 0.42),
                orange: Color(red: 0.94, green: 0.58, blue: 0.28),
                subtleFill: Color.white.opacity(0.10),
                border: Color.white.opacity(0.09)
            )
        case .echo:
            TrailPalette(
                background: Color(red: 0.95, green: 0.96, blue: 0.98),
                surface: Color(red: 1.00, green: 1.00, blue: 1.00),
                elevated: Color(red: 0.90, green: 0.92, blue: 0.95),
                primaryText: Color(red: 0.10, green: 0.12, blue: 0.18),
                secondaryText: Color(red: 0.43, green: 0.46, blue: 0.54),
                purple: Color(red: 0.47, green: 0.41, blue: 0.82),
                cyan: Color(red: 0.08, green: 0.55, blue: 0.70),
                green: Color(red: 0.20, green: 0.58, blue: 0.42),
                orange: Color(red: 0.84, green: 0.45, blue: 0.24),
                subtleFill: Color(red: 0.10, green: 0.12, blue: 0.18).opacity(0.06),
                border: Color(red: 0.10, green: 0.12, blue: 0.18).opacity(0.09)
            )
        case .wanderlust:
            TrailPalette(
                background: Color(red: 0.95, green: 0.97, blue: 0.95),
                surface: Color(red: 1.00, green: 0.99, blue: 0.97),
                elevated: Color(red: 0.90, green: 0.94, blue: 0.91),
                primaryText: Color(red: 0.12, green: 0.13, blue: 0.10),
                secondaryText: Color(red: 0.45, green: 0.48, blue: 0.42),
                purple: Color(red: 0.50, green: 0.38, blue: 0.78),
                cyan: Color(red: 0.03, green: 0.52, blue: 0.61),
                green: Color(red: 0.18, green: 0.55, blue: 0.31),
                orange: Color(red: 0.83, green: 0.39, blue: 0.19),
                subtleFill: Color(red: 0.12, green: 0.13, blue: 0.10).opacity(0.07),
                border: Color(red: 0.12, green: 0.13, blue: 0.10).opacity(0.10)
            )
        case .coastalEscape:
            TrailPalette(
                background: Color(red: 0.95, green: 0.99, blue: 1.00),
                surface: Color(red: 1.00, green: 1.00, blue: 0.99),
                elevated: Color(red: 0.88, green: 0.96, blue: 0.98),
                primaryText: Color(red: 0.00, green: 0.18, blue: 0.33),
                secondaryText: Color(red: 0.30, green: 0.43, blue: 0.51),
                purple: Color(red: 0.00, green: 0.47, blue: 0.71),
                cyan: Color(red: 0.56, green: 0.88, blue: 0.94),
                green: Color(red: 0.11, green: 0.58, blue: 0.48),
                orange: Color(red: 1.00, green: 0.84, blue: 0.00),
                subtleFill: Color(red: 0.00, green: 0.47, blue: 0.71).opacity(0.09),
                border: Color(red: 0.00, green: 0.18, blue: 0.33).opacity(0.10)
            )
        case .lushExplorer:
            TrailPalette(
                background: Color(red: 0.94, green: 0.98, blue: 0.95),
                surface: Color(red: 1.00, green: 1.00, blue: 0.97),
                elevated: Color(red: 0.87, green: 0.94, blue: 0.90),
                primaryText: Color(red: 0.06, green: 0.18, blue: 0.15),
                secondaryText: Color(red: 0.34, green: 0.45, blue: 0.40),
                purple: Color(red: 0.23, green: 0.37, blue: 0.35),
                cyan: Color(red: 0.16, green: 0.62, blue: 0.56),
                green: Color(red: 0.16, green: 0.62, blue: 0.56),
                orange: Color(red: 0.96, green: 0.64, blue: 0.38),
                subtleFill: Color(red: 0.16, green: 0.62, blue: 0.56).opacity(0.10),
                border: Color(red: 0.06, green: 0.18, blue: 0.15).opacity(0.10)
            )
        case .sunsetWanderlust:
            TrailPalette(
                background: Color(red: 0.97, green: 0.95, blue: 0.90),
                surface: Color(red: 1.00, green: 0.98, blue: 0.94),
                elevated: Color(red: 0.94, green: 0.90, blue: 0.84),
                primaryText: Color(red: 0.15, green: 0.27, blue: 0.33),
                secondaryText: Color(red: 0.43, green: 0.47, blue: 0.48),
                purple: Color(red: 0.15, green: 0.27, blue: 0.33),
                cyan: Color(red: 0.16, green: 0.46, blue: 0.52),
                green: Color(red: 0.23, green: 0.55, blue: 0.39),
                orange: Color(red: 0.91, green: 0.44, blue: 0.32),
                subtleFill: Color(red: 0.91, green: 0.44, blue: 0.32).opacity(0.10),
                border: Color(red: 0.15, green: 0.27, blue: 0.33).opacity(0.10)
            )
        case .modernMinimalist:
            TrailPalette(
                background: Color(red: 0.94, green: 0.95, blue: 0.96),
                surface: Color.white,
                elevated: Color(red: 0.90, green: 0.92, blue: 0.95),
                primaryText: Color(red: 0.08, green: 0.10, blue: 0.14),
                secondaryText: Color(red: 0.42, green: 0.46, blue: 0.53),
                purple: Color(red: 0.00, green: 0.33, blue: 1.00),
                cyan: Color(red: 0.00, green: 0.33, blue: 1.00),
                green: Color(red: 0.12, green: 0.56, blue: 0.38),
                orange: Color(red: 0.94, green: 0.54, blue: 0.12),
                subtleFill: Color(red: 0.00, green: 0.33, blue: 1.00).opacity(0.08),
                border: Color(red: 0.08, green: 0.10, blue: 0.14).opacity(0.09)
            )
        case .tripGlass:
            TrailPalette(
                background: Color(red: 0.02, green: 0.06, blue: 0.16),
                surface: Color(red: 0.10, green: 0.15, blue: 0.30).opacity(0.95),
                elevated: Color(red: 0.18, green: 0.23, blue: 0.40).opacity(0.88),
                primaryText: Color(red: 0.97, green: 0.98, blue: 1.00),
                secondaryText: Color(red: 0.70, green: 0.77, blue: 0.88),
                purple: Color(red: 0.22, green: 0.32, blue: 0.64),
                cyan: Color(red: 0.28, green: 0.78, blue: 0.94),
                green: Color(red: 0.90, green: 1.00, blue: 0.24),
                orange: Color(red: 0.99, green: 0.93, blue: 0.18),
                subtleFill: Color.white.opacity(0.12),
                border: Color.white.opacity(0.13)
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
