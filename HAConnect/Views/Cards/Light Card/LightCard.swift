//
// LightCard.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI

struct LightCard: View {

    @EnvironmentObject var homeAssistant: HAKitViewModel

    let originalEntityId: String
    @Binding var sliders: Bool

    var entity: HAEntity? {
        homeAssistant.entities.first(where: { $0.entityId == originalEntityId })
    }

    @State var isShowingPopup = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Button {
                    homeAssistant.callService(id: originalEntityId, d: "light", s: "toggle", data: nil)
                    hapticResponse(.success)
                } label: {
                    EntityIcon(originalEntityId: originalEntityId)
                        .frame(height: 50)
                }

                Button {
                    isShowingPopup = true
                    sheetHaptics()
                } label: {
                    VStack(alignment: .leading) {
                        Text(entity?.attributes.friendlyName ?? "Unknown Entity")
                            .font(.headline)
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                        HStack(spacing: 0) {
                            Text(entity?.state.capitalized ?? "Unknown")
                            if entity?.state == "on" {
                                Text(" • \(Int(Double(entity?.attributes.dictionary["brightness"]! as! Int)/255*100))%")
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }

            if sliders {
                LightBrightnessSlider(originalEntityId: originalEntityId)
                    .frame(height: 45)
                    .foregroundColor(.gray)
            }
        }
        .sheet(isPresented: $isShowingPopup, onDismiss: {
            sheetHaptics()
        }, content: {
            LightsSheetView(originalEntityId)
        })
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color("ElementBackground"))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(.secondary.opacity(0.2), lineWidth: 0.75)
            }
        }
        .animation(.default, value: sliders)

    }
}

struct LightCard_Previews: PreviewProvider {
    static var previews: some View {
        LightCard(originalEntityId: "light.leo_table_lamp", sliders: .constant(true))
            .environmentObject(HAKitViewModel())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}