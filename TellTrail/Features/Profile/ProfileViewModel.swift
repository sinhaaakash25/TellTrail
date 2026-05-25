//
//  ProfileViewModel.swift
//  TellTrail
//
//  Created by Aakash Sinha on 12/05/26.
//

import Foundation
import SwiftUI
import Combine

final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var metrics: [CreatorMetric]
    @Published private(set) var drops: [VoiceDrop]
    @Published var selectedSection = "Drops"

    let profileSections = ["Drops", "Journey", "Saved"]

    init(metrics: [CreatorMetric] = PreviewTrailData.metrics, drops: [VoiceDrop] = PreviewTrailData.drops) {
        self.metrics = metrics
        self.drops = drops
    }
}
