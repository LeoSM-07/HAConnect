//
// SecretsManager.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import SwiftUI

class AppSettings: ObservableObject {
    
    @AppStorage("ha_internal_url") var internalURL: String = ""
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
    
    var useableURLString: String {
// MARK: TODO
        return externalURL
    }
    
    var useableURL: URL? {
        return URL(string: useableURLString)
    }
    
    init() {
        
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
