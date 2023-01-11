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
                    EntityIcon(originalEntityId)
                        .padding(2)
                        .frame(height: 50)
                }

                LightCardLabel()
            }

            if sliders {
                LightBrightnessSlider(originalEntityId: originalEntityId)
                    .frame(height: 45)
                    .foregroundColor(.gray)
            } else {
                Spacer()
            }
        }
        .sheet(isPresented: $isShowingPopup, onDismiss: {
            sheetHaptics()
        }, content: {
            LightsSheetView(originalEntityId)
        })
        .cardStyle()
        .animation(.default, value: sliders)

    }

    @ViewBuilder
    func LightCardLabel() -> some View {
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
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyleModifier())
    }
}

struct CardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
//            .frame(height: 120)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color("ElementBackground"))
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.secondary.opacity(0.2), lineWidth: 0.75)
                }
            }
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
