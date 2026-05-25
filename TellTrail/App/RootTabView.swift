//
//  RootTabView.swift
//  TellTrail
//
//  Created by Aakash Sinha on 12/05/26.
//

import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            TrailTheme.background.ignoresSafeArea()

            TabView(selection: $coordinator.selectedTab) {
                FeedView(viewModel: FeedViewModel())
                    .tag(TrailTab.feed)

                JourneyView(viewModel: JourneyViewModel())
                    .tag(TrailTab.journey)

                RecordVoiceDropView(viewModel: RecordVoiceDropViewModel())
                    .tag(TrailTab.record)

                ChatView(viewModel: ChatViewModel())
                    .tag(TrailTab.chat)

                ProfileView(viewModel: ProfileViewModel())
                    .tag(TrailTab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            TrailTabBar(selectedTab: coordinator.selectedTab) { tab in
                coordinator.select(tab)
            }
        }
    }
}

private struct TrailTabBar: View {
    let selectedTab: TrailTab
    let onSelect: (TrailTab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TrailTab.allCases) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    TrailTabItem(tab: tab, isSelected: selectedTab == tab)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.rawValue)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.10), radius: 16, y: 8)
        .padding(.horizontal, 18)
        .padding(.bottom, 10)
    }
}

private struct TrailTabItem: View {
    let tab: TrailTab
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: tab.symbol)
                .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                .symbolVariant(isSelected ? .fill : .none)
                .frame(width: 28, height: 24)

            Text(tab.rawValue)
                .font(.caption2.weight(isSelected ? .semibold : .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Capsule()
                .fill(isSelected ? TrailTheme.cyan : Color.clear)
                .frame(width: 18, height: 2)
                .padding(.top, 1)
        }
        .foregroundStyle(isSelected ? TrailTheme.primaryText : TrailTheme.secondaryText)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
