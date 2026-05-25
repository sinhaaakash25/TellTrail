//
//  ApplicationCoordinator.swift
//  TellTrail
//
//  Created by Aakash Sinha on 12/05/26.
//

import SwiftUI
import Combine

final class AppCoordinator: ObservableObject {
    @Published var selectedTab: TrailTab = .feed

    func select(_ tab: TrailTab) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
            selectedTab = tab
        }
    }
}

