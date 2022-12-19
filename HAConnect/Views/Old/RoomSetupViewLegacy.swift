//
// RoomSetupView.swift
// HAConnect
//
// Created by LeoSM_07 on 10/5/22.
//

import SwiftUI

struct RoomSetupViewLegacy: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var homeAssistant: HAKitViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(Array(homeAssistant.roomList.enumerated()), id: \.offset) { index, room in
                        HStack {
                            Button {
                                homeAssistant.roomList[index].isActive.toggle()
                            } label: {
                                Image(systemName: room.isActive ? "checkmark.circle.fill" : "circle")
                            }

                            Text(room.roomName)
                        }
                    }
                } header: {
                    Text("Select Areas")
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
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RoomSetupView_Previews: PreviewProvider {
    static var previews: some View {
        RoomSetupViewLegacy()
    }
}
