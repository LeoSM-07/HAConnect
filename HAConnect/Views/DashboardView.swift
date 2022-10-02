//
// DashboardView.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI


struct DashboardView: View {

    @EnvironmentObject var homeAssistant: HAKitViewModel
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State var showSliders = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(homeAssistant.roomEntityList.enumerated()), id: \.element) { index, entityList in
                        Section{
                            ForEach(entityList, id: \.self) { entityId in
                                if entityId.contains("light.") {
                                    LightCard(originalEntityId: entityId, sliders: $showSliders)
                                }
                            }
                        } header: {
                            Divider()
                        }

                    }
                }
                .padding(.horizontal)
            }
            .background(Color("MainBackground"))
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {

                        Button {} label: {
                            Label("Settings", systemImage: "gear")
                        }
                        Section {
                            Toggle(isOn: $showSliders) {
                                Label("Brightness Sliders", systemImage: "slider.horizontal.3")
                            }
                            Button {} label: {
                                Label("Reorder Rooms", systemImage: "arrow.up.arrow.down")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}


/*
struct DashboardView: View {

    @EnvironmentObject var homeAssistant: HAKitViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(homeAssistant.roomEntityList.enumerated()), id: \.element) { index, entityList in
                    Section {
                        ForEach(entityList, id: \.self) { entityId in
                            testingLineView(originalEntityID: entityId)
                        }
                    } header: {
                        Text(homeAssistant.roomIdList[index])
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button { } label: {
                        Image(systemName: "gear")
                    }
                }
            })
            .navigationTitle("Home")
        }
    }
}

struct testingLineView: View {
    @EnvironmentObject var homeAssistant: HAKitViewModel

    let originalEntityID: String
    var entity: HAEntity? {
        homeAssistant.entities.first(where: { $0.entityId == originalEntityID })
    }

    var lightColor: Color? { determineLightColor(entity) }

    var body: some View {
        HStack {
            if let entity = entity {
                if let lightColor = lightColor {
                    Circle()
                        .fill(lightColor)
                        .frame(height: 10)
                } else {
                    Circle()
                        .frame(height: 10)
                        .opacity(lightColor == nil && entity.domain == "light" ? 1 : 0)
                }
                Text(entity.attributes.friendlyName ?? entity.entityId)


            } else {
                Text(originalEntityID)
            }

        }
    }
}
*/

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(HAKitViewModel())
    }
}
