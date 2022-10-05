//
// HAConnectApp.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import SwiftUI

@main
struct HAConnectApp: App {

    @StateObject var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            
            if appSettings.setupComplete {
                RootView()
                    .environmentObject(appSettings)
            } else {
                SetupView()
                    .environmentObject(appSettings)
            }
            

        }
    }
}
