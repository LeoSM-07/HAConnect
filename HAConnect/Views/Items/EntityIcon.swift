//
// EntityIcon.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI

struct EntityIcon: View {

    @EnvironmentObject var homeAssistant: HAKitViewModel
    let originalEntityId: String
    let icon: String
    let padding: CGFloat
    var entity: HAEntity? {
        homeAssistant.entities.first(where: { $0.entityId == originalEntityId })
    }

    init(_ originalEntityId: String, icon: String? = nil, padding: CGFloat? = nil) {
        self.originalEntityId = originalEntityId
        self.icon = icon ?? "lightbulb.fill"
        self.padding = padding ?? 12
    }

    var hasColor: Bool {
        if entity?.attributes.dictionary["rgb_color"] != nil {
            return true
        } else { return false }
    }

    var body: some View {
        Image(systemName: icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(hasColor ? determineLightColor(entity!) : .secondary)
            .padding(padding)
            .background {
                Circle()
                    .fill(hasColor ? determineLightColor(entity!)!.opacity(0.2) : Color(uiColor: .secondarySystemBackground))
            }
    }
}

struct EntityIcon_Previews: PreviewProvider {
    static var previews: some View {
        EntityIcon("light.leo_table_lamp")
            .environmentObject(HAKitViewModel())
    }
}
