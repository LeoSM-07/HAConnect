//
// LocationManager.swift
// HAConnect
//
// Created by LeoSM_07 on 10/4/22.
//

import CoreLocation

class LocationManager: ObservableObject {
    private let manager = CLLocationManager()
    init() {
        requestAuthorization()
    }
    func requestAuthorization() {
        manager.requestAlwaysAuthorization()
    }
}
