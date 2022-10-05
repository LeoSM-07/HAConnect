//
// SettingsView.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var homeAssistant: HAKitViewModel
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        NavigationView {
            List {
                SettingsListItem("Current SSID", appSettings.getWiFiSSID())
                SettingsListItem("Current URL", appSettings.useableURLString)
                NavigationLink("Reconfigure HomeAssistant") {
                    SetupView()
                        .navigationBarBackButtonHidden(true)
                        .interactiveDismissDisabled(true)
                }
                .foregroundColor(.accentColor)
                
                Section("Areas") {
                    ForEach(homeAssistant.roomIdList) { item in
                        NavigationLink(item.roomName) {
                            RoomEditView(roomItem: item)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("MainBackground"))
            .navigationTitle("Settings")
        }
        .task {
            homeAssistant.getUserImagePath()
        }
    }
}

struct SettingsListItem: View {
    
    let headlineText: String
    var bodyText: String
    
    init (_ headline: String, _ body: String) {
        self.headlineText = headline
        self.bodyText = body
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(headlineText)
            .foregroundColor(.secondary)
            .font(.footnote)
            
            Text(bodyText)
                .lineLimit(1)
        }
    }
}

struct RoomEditView: View {

    let roomItem: RoomItem

    var body: some View {
        Form {
            Text(roomItem.roomId)
        }
        .scrollContentBackground(.hidden)
        .background(Color("MainBackground"))
        .navigationTitle(roomItem.roomName)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(HAKitViewModel())
    }
}
