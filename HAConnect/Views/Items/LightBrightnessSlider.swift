//
// LightBrightnessSlider.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI

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

struct LightBrightnessSlider_Previews: PreviewProvider {
    static var previews: some View {
        LightBrightnessSlider(originalEntityId: "light.leo_table_lamp")
            .environmentObject(HAKitViewModel())
    }
}
