//
// RoomSetupView.swift
// HAConnect
//
// Created by LeoSM_07 on 10/5/22.
//

import SwiftUI

struct RoomSetupView: View {
    
    @EnvironmentObject var appSettigs: AppSettings
    @EnvironmentObject var homeAssistant: HAKitViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(homeAssistant.roomList) { room in
                        VStack(alignment: .leading) {
                            Text(room.roomName)
                        }
                    }
                } footer: {
                    Text("Select which areas you would like to be present in HAConnect.")
                }
            }
            .toolbar(content: {
                Button("Done"){
                    homeAssistant.saveRoomList()
                    dismiss()
                }
            })
            .task {
                homeAssistant.populateRoomList()
            }
            .scrollContentBackground(.hidden)
            .background(Color("MainBackground"))
            .navigationTitle("Room Setup")
        }
    }
}

struct RoomSetupView_Previews: PreviewProvider {
    static var previews: some View {
        RoomSetupView()
    }
}
