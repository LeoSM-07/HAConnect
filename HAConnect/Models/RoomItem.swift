//
// RoomItem.swift
// HAConnect
//
// Created by LeoSM_07 on 12/18/22.
//

import Foundation

struct RoomGroup: Codable, Hashable {
    var name: String
    var quickActions: [String]
    var actions: [String]
    var iconName: String
    
}
