//
// SettingsView.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var homeAssistant: HAKitViewModel

    var body: some View {
        NavigationView {
            List {
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
