import SwiftUI

struct HeaderView: View {
    let title: String
    let subtitle: String
    let actionSymbol: String

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(TrailTheme.primaryText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(TrailTheme.secondaryText)
            }
            Spacer()
            Image(systemName: actionSymbol)
                .font(.headline)
                .foregroundStyle(TrailTheme.primaryText)
                .frame(width: 44, height: 44)
                .background(TrailTheme.surface, in: Circle())
        }
    }
}

struct AvatarView: View {
    let initials: String
    let size: CGFloat

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(TrailTheme.accentGradient, in: Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
    }
}

struct WaveformView: View {
    let progress: Double
    let isActive: Bool
    private let bars: [CGFloat] = [0.28, 0.72, 0.44, 0.88, 0.35, 0.64, 0.96, 0.52, 0.78, 0.40, 0.68, 0.30, 0.84, 0.50, 0.74, 0.46, 0.90, 0.36]

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 4) {
                ForEach(bars.indices, id: \.self) { index in
                    Capsule()
                        .fill(color(for: index))
                        .frame(height: max(8, proxy.size.height * bars[index]))
                }
            }
        }
        .frame(height: 28)
    }

    private func color(for index: Int) -> Color {
        let activeBars = Int(Double(bars.count) * progress)
        guard isActive, index <= activeBars else { return Color.white.opacity(0.18) }
        return index.isMultiple(of: 2) ? TrailTheme.cyan : TrailTheme.purple
    }
}

struct FilterChip: View {
    let title: String
    let symbol: String
    let isSelected: Bool

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption.weight(.bold))
            .foregroundStyle(isSelected ? .white : TrailTheme.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(isSelected ? AnyShapeStyle(TrailTheme.accentGradient) : AnyShapeStyle(TrailTheme.surface), in: Capsule())
    }
}

struct LockBadge: View {
    let isUnlocked: Bool

    var body: some View {
        Label(isUnlocked ? "Unlocked" : "Locked", systemImage: isUnlocked ? "lock.open.fill" : "lock.fill")
            .font(.caption2.weight(.bold))
            .foregroundStyle(isUnlocked ? TrailTheme.green : TrailTheme.orange)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.08), in: Capsule())
    }
}

struct ActionLabel: View {
    let symbol: String
    let text: String

    var body: some View {
        Label(text, systemImage: symbol)
            .font(.caption.weight(.bold))
            .foregroundStyle(TrailTheme.primaryText)
    }
}

enum CompactButtonStyle {
    case primary
    case secondary
    case dark
}

struct CompactButton: View {
    let title: String
    let symbol: String
    let style: CompactButtonStyle

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption.weight(.bold))
            .foregroundStyle(style == .secondary ? TrailTheme.primaryText : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(background, in: Capsule())
    }

    private var background: some ShapeStyle {
        switch style {
        case .primary:
            AnyShapeStyle(TrailTheme.accentGradient)
        case .secondary:
            AnyShapeStyle(Color.white.opacity(0.10))
        case .dark:
            AnyShapeStyle(Color.black.opacity(0.28))
        }
    }
}

struct SegmentControl: View {
    let options: [String]
    let selected: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Text(option)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(option == selected ? .white : TrailTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(option == selected ? AnyShapeStyle(TrailTheme.accentGradient) : AnyShapeStyle(Color.clear), in: Capsule())
            }
        }
        .padding(5)
        .background(TrailTheme.surface, in: Capsule())
    }
}
