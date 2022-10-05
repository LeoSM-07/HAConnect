//
// SecretsManager.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import SwiftUI
import SystemConfiguration.CaptiveNetwork

enum WifiStatus: String {
    case onLocal = "Connected To Local"
    case onExternal = "Not Connected To Local"
}

class AppSettings: ObservableObject {
    
    @AppStorage("ha_internal_url") var internalURL: String = "http://homeassistant.local:8123/"
    @AppStorage("ha_external_url") var externalURL: String = ""
    @AppStorage("ha_user_token") var token: String = ""
    @AppStorage("user_wifi_keyword") var wifiKeyword: String = ""
    @AppStorage("user_external_only") var externalURLOnly: Bool = false

//    let url = "http://homeassistant.local:8123"
//    let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI2M2YzMmY5ZmVkNTE0ZGE4OTNlNGFmOTAzNTFiMWZhMyIsImlhdCI6MTY2NDc0NjAwMywiZXhwIjoxOTgwMTA2MDAzfQ.svmRm8YC0Oh5VdqA3WJunSlDTNb1PUlj9HxGMjnQd9w"


    var setupComplete: Bool {
        if internalURL == "" || token == "" { return false } else { return true }
    }
    
    @Published var favoriteColors: [FavColor] = [
        FavColor(rgbValue: [255, 205, 120]),
        FavColor(rgbValue: [255, 254, 250]),
        FavColor(rgbValue: [255, 149, 47]),
        FavColor(rgbValue: [110, 0, 255]),
        FavColor(rgbValue: [255, 172, 41]),
        FavColor(rgbValue: [255, 94, 79])
    ]
    @Published var wifiStatus: WifiStatus
    
    init() {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                // swiftlint:disable force_cast
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        // swiftlint:disable control_statement
        if ((ssid?.contains("Cosmos")) != nil) {
            wifiStatus = .onLocal
        } else {
            wifiStatus = .onExternal
        }
    }
    
    func getWiFiSSID() -> String {

        LocationManager().requestAuthorization()

        var SSID: String?

        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {

                // swiftlint:disable force_cast
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    SSID = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }

        }

        return SSID ?? "Unknown"
    }
    
    var useableURL: URL? {
        return URL(string: useableURLString)
    }
    
    var useableURLString: String {
        if getWiFiSSID().contains(wifiKeyword) && !externalURLOnly {
            return internalURL
        } else if externalURL == "" {
            return internalURL
        } else {
            return externalURL
        }
    }
    
}




struct FavColor: Hashable, Identifiable {
    var id = UUID()
    var rgbValue: [Int]
    var color: Color {
        convertRGB(rgbValue)
    }

    private func convertRGB(_ numbers: [Int]?) -> Color {
        return Color(red: Double((numbers?[0] ?? 128))/255,
                     green: Double((numbers?[1] ?? 128))/255,
                     blue: Double((numbers?[2] ?? 128))/255
        )
    }
}
