//
// DashboardView.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI


struct DashboardView: View {
    @EnvironmentObject var appSettigs: AppSettings
    @EnvironmentObject var homeAssistant: HAKitViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State var showSliders = true
    @State var showSettingsSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                Button("Print Room List") {
                    print(homeAssistant.roomList)
                    print(homeAssistant.roomListData)
                }
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(homeAssistant.roomList.enumerated()), id: \.element) { index, room in
                        if room.isActive {
                            Section{
                                ForEach(room.entities, id: \.self) { entityId in
                                    if entityId.contains("light.") {
                                        LightCard(originalEntityId: entityId, sliders: $showSliders)
                                    }
                                }
                            } header: {
                                VStack(alignment: .leading) {
                                    Text(room.roomName)
                                    Divider()
                                }

                            }
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
        .sheet(isPresented: $appSettigs.needsRoomSetup, content: {
            RoomSetupView()
                .interactiveDismissDisabled()
        })
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
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
