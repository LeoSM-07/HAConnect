//
// Haptics.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import SwiftUI

extension View {
    
    func hapticResponse(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func sheetHaptics() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}
