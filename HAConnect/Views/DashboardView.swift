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
                    ForEach(RoomData().roomList, id: \.self) { room in

                        VStack {
                            HStack {
                                Button {
                                    homeAssistant.callService(id: room.primaryLight, d: "light", s: "toggle", data: nil)
                                    hapticResponse(.success)
                                } label: {
                                    EntityIcon(room.primaryLight, icon: room.iconName, padding: 13)
                                        .frame(height: 38)
                                }

                                VStack {
                                    Text(room.name)
                                        .font(.title3.weight(.semibold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .cardStyle()

//                        if room.entities.contains(where: { $0.starts(with: "scene.") }) {
//                            GridRow {
//                                Text("Scenes Here")
//                                    .cardStyle()
//                                    .gridCellColumns(2)
//                            }
//                        }
//                        ForEach(lightsArrayModified, id: \.self) { array in
//                            GridRow {
//                                ForEach(array, id: \.self) { entity in
//                                    LightCard(originalEntityId: entity, sliders: $showSliders)
//                                }
//                            }
//                            .frame(height: 120)
//                        }
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
