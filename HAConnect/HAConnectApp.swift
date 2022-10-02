//
// HAConnectApp.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import SwiftUI

@main
struct HAConnectApp: App {

    @StateObject var homeAssistant = HAKitViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(homeAssistant)
        }
    }
}
