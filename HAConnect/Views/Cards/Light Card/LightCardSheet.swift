//
// LightCardSheet.swift
// HAConnect
//
// Created by LeoSM_07 on 10/4/22.
//

import HAKit
import SwiftUI

// MARK: - Light Sheet View
struct LightsSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var homeAssistant: HAKitViewModel

    let originalEntityId: String

    init(_ originalEntityId: String) {
        self.originalEntityId = originalEntityId
    }

    let columns = [
        GridItem(.fixed(55)),
        GridItem(.fixed(55)),
        GridItem(.fixed(55))
    ]

    var entity: HAEntity? {
        homeAssistant.entities.first(where: { $0.entityId == originalEntityId })
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                EntityIcon(originalEntityId: originalEntityId)

                VStack(alignment: .leading) {
                    Text(entity?.attributes.friendlyName ?? originalEntityId)
                        .font(.headline)
                        .minimumScaleFactor(0.01)
                    HStack(spacing: 0) {
                        Text(entity?.state.capitalized ?? "Unknown")
                        if entity?.state == "on" {
                            Text(" • \(Int(entity?.attributes.dictionary["brightness"]! as! Double/255*100))%")
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical, 8)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.gray, Color(uiColor: .systemFill))
                }
            }
            .frame(height: 45)

            Spacer()

            VStack(spacing: 20) {
                Spacer()

                LightsColorPicker(originalEntityId)

                LazyVGrid(columns: columns) {
                    ForEach(AppSecrets().favoriteColors) { fav in
                        Button {
                            homeAssistant.callService(
                                id: originalEntityId,
                                d: "light",
                                s: "turn_on",
                                data: ["rgb_color": fav.rgbValue]
                            )
                            hapticResponse(.success)
                        } label: {
                            Circle()
                                .fill(fav.color.gradient)
                                .overlay {
                                    Circle()
                                        .strokeBorder(.secondary.opacity(0.33), lineWidth: 1)
                                }
                        }
                    }
                }
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical, 8)
                    .foregroundStyle(.gray)
            }
            .frame(height: 45)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .padding()
        .ignoresSafeArea()
        .navigationTitle("")
    }
}

// MARK: - Light Color Picker
struct LightsColorPicker: View {
    @EnvironmentObject var homeAssistant: HAKitViewModel

    let originalEntityId: String

    init(_ originalEntityId: String) {
        self.originalEntityId = originalEntityId
    }
    
    @State var thumbsize: CGFloat = 30
    @State var rgbColour: RGB = RGB(rColor: 1, gColor: 1, bColor: 1)
    var radius: CGFloat = 250
    
    var entity: HAEntity? {
        homeAssistant.entities.first(where: { $0.entityId == originalEntityId })
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AngularGradientHueView(radius: self.radius)
                    .blur(radius: 35)
                    .shadow(color: .white.opacity(0), radius: 15)
                
                RadialGradient(
                    gradient: Gradient(colors: [.white, .black]),
                    center: .center, startRadius: 0,
                    endRadius: 100
                )
                .opacity(0.5)
                .blendMode(.screen)
                
                Circle()
                    .strokeBorder(Color.gray, lineWidth: 1.5)
                    .background(
                        Circle().foregroundColor(
                            Color(red: rgbColour.rColor, green: rgbColour.gColor, blue: rgbColour.bColor)
                        ))
                    .frame(width: thumbsize)
                    .offset(x: (self.radius/2 - 10) * self.rgbColour.hsv.sValue)
                    .rotationEffect(.degrees(-Double(self.rgbColour.hsv.hValue)))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            .task {
                rgbColour = rgbConvert(entity?.attributes.dictionary["rgb_color"] as? [Int])
            }
            .onChange(of: entity?.attributes.dictionary["rgb_color"] as? [Int]) { newValue in

                if !RGBEqualToArray(newValue, rgbColour) {
                    rgbColour = rgbConvert(newValue)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in

                        // swiftlint:disable identifier_name
                        let y = geometry.frame(in: .global).midY - value.location.y
                        let x = value.location.x - geometry.frame(in: .global).midX

                        let hue = atan2To360(atan2(y, x))

                        let center = CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).midY)

                        let saturation = min(distance(center, value.location)/(self.radius/2), 1)

                        self.rgbColour = HSV(hValue: hue, sValue: saturation, vValue: 1).rgb
                        withAnimation { self.thumbsize = 95 }

                    }

                    .onEnded {_ in
                        withAnimation { self.thumbsize = 30 }

                        homeAssistant.callService(
                            id: originalEntityId,
                            d: "light",
                            s: "turn_on",
                            data: ["rgb_color": [
                                Int(rgbColour.rColor*255),
                                Int(rgbColour.gColor*255),
                                Int(rgbColour.bColor*255)
                            ]]
                        )
                        hapticResponse(.success)
                    }
            )
        }
    }
}
