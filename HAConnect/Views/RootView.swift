//
// ContentView.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var homeAssistant = HAKitViewModel()

    
    var body: some View {
        DashboardView()
            .onChange(of: scenePhase, perform: { newValue in
                if newValue == .background {
                    homeAssistant.saveRoomList()
                }
            })
            .environmentObject(homeAssistant)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
