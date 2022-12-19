//
// DashboardView.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var homeAssistant: HAKitViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State var showSliders = true
    @State var showSettingsSheet = false
    @State var showNewRoomView = false


    var body: some View {
        NavigationView {
            ScrollView {
                Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                    ForEach(Array(homeAssistant.roomList.enumerated()), id: \.element) { index, room in
                        let lightsArrayModified = room.entities.filter { $0.starts(with: "light.") }.chunked(into: 2)

                        Text(room.roomName)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if room.entities.contains(where: { $0.starts(with: "scene.") }) {
                            GridRow {
                                Text("Scenes Here")
                                    .cardStyle()
                                    .gridCellColumns(2)
                            }
                        }

                        ForEach(lightsArrayModified, id: \.self) { array in
                            GridRow {
                                ForEach(array, id: \.self) { entity in
                                    LightCard(originalEntityId: entity, sliders: $showSliders)
                                }
                            }
                            .frame(height: 120)
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
                        Button {
                            showSettingsSheet.toggle()
                            sheetHaptics()
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                        #warning("Testing")
                        Button {
                            showNewRoomView.toggle()
                        } label: {
                            Label("New Room", systemImage: "plus")
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
        .sheet(isPresented: $appSettings.needsRoomSetup, content: {
            RoomSetupView()
                .interactiveDismissDisabled()
        })
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
        }
        .sheet(isPresented: $showNewRoomView) {
            RoomSetupView()
        }
        .onChange(of: showSettingsSheet, perform: { v in
            if v == false { homeAssistant.saveRoomList() }
        })
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(HAKitViewModel())
    }
}
