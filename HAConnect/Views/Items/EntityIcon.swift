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
    var originalEntityId: String
    var entity: HAEntity? {
        homeAssistant.entities.first(where: { $0.entityId == originalEntityId })
    }

    var hasColor: Bool {
        if entity?.attributes.dictionary["rgb_color"] != nil {
            return true
        } else { return false }
    }

    var body: some View {
        Image(systemName: "lightbulb.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(hasColor ? determineLightColor(entity!) : .secondary)
            .padding(12)
            .background {
                Circle()
                    .fill(hasColor ? determineLightColor(entity!)!.opacity(0.2) : Color(uiColor: .secondarySystemBackground))
            }
    }
}

struct EntityIcon_Previews: PreviewProvider {
    static var previews: some View {
        EntityIcon(originalEntityId: "light.leo_table_lamp")
            .environmentObject(HAKitViewModel())
    }
}
