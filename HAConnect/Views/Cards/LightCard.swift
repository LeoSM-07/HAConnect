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

struct LightBrightnessSlider: View {

    @EnvironmentObject var homeAssistant: HAKitViewModel
    var originalEntityId: String
    var entity: HAEntity? {
        homeAssistant.entities.first(where: { $0.entityId == originalEntityId })
    }

    var brightness: Int? {
        entity?.attributes.dictionary["brightness"] as? Int
    }

    @State var sliderProgress: CGFloat = 0
    @State var sliderWidth: CGFloat = 0
    @State var lastDragValue: CGFloat = 0
    @State var editingFromTap = false

    var body: some View {
        GeometryReader { geo in

            let maxWidth = geo.size.width

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color("IconBackground"))

                Rectangle()
                    .fill(determineLightColor(entity)?.gradient ?? Color(.gray).gradient)
                    .frame(width: sliderWidth)

            }
            .contentShape(
                Circle()
                    .offset(x: sliderWidth <= 20 ? 10 : sliderWidth-10-maxWidth/2)
            )
            .overlay(
                Rectangle()
                    .frame(width: 3, height: geo.size.height*(0.6))
                    .cornerRadius(5)
                    .foregroundColor(
                        brightness != nil ?
                        .white : Color("IconLabel").opacity(0.2))
                    .offset(x: sliderWidth <= 20 ? 10 : sliderWidth-10),
                alignment: .leading
            )
            .frame(width: maxWidth)
            .cornerRadius(12)
            .gesture(DragGesture(minimumDistance: 0).onChanged({ (value) in
                editingFromTap = true
                withAnimation(.linear(duration: 0.1)) {

                    let translation = value.translation

                    sliderWidth = translation.width + lastDragValue

                    sliderWidth = sliderWidth > maxWidth ? maxWidth : sliderWidth

                    sliderWidth = sliderWidth >= 0 ? sliderWidth : 0

                }

                homeAssistant.updateEntityBrightness(id: originalEntityId, new: Int(Double(sliderWidth/maxWidth) * 255))

                homeAssistant.updateEntityState(id: originalEntityId, new: "on")
//                if let row = homeAssistant.entities.firstIndex(where: {$0.entityId == originalEntityId}) {
//                    homeAssistant.entity[row].attributes.dictionary["brightness"] = (sliderWidth/maxWidth * 255)
//                    if sliderWidth > 0 {
//                        homeAssistant.entities[row].state = "on"
//                    }
//                }
            }).onEnded({ _ in

                DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                    editingFromTap = false
                }

                sliderWidth = sliderWidth > maxWidth ? maxWidth : sliderWidth

                sliderWidth = sliderWidth >= 0 ? sliderWidth : 0

                // Store Last Drag Value
                lastDragValue = sliderWidth

                homeAssistant.updateEntityBrightness(id: originalEntityId, new: Int(Double(sliderWidth/maxWidth) * 255))

                // Set Light Brightness
                homeAssistant.callService(
                    id: originalEntityId,
                    d: "light",
                    s: "turn_on",
                    data: ["brightness": "\(Int((sliderWidth/maxWidth*255)))"]
                )

                if sliderWidth == 0 {

                    homeAssistant.updateEntityState(id: originalEntityId, new: "off")
//                    if let row = homeAssistant.entities.firstIndex(where: {$0.entityId == originalEntityId}) {
//                        homeAssistant.entities[row].state = "off"
//                        $homeAssistant.entity[row].attributes.dictionary["brightness"] = nil
//                    }
                }

            }))
            .onChange(of: brightness) { [brightness] newValue in
                if brightness == nil || !editingFromTap {
                    lastDragValue = CGFloat(Double(newValue ?? 0)/255)*maxWidth
                    sliderWidth = lastDragValue
                }
            }
            .task {
                lastDragValue = CGFloat(Double(brightness ?? 0)/255)*maxWidth
                sliderWidth = lastDragValue
            }
        }
    }
}

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

struct LightCard_Previews: PreviewProvider {
    static var previews: some View {
        LightCard(originalEntityId: "light.leo_table_lamp", sliders: .constant(true))
            .environmentObject(HAKitViewModel())
    }
}
