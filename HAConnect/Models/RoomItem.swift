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
    var lightItems: [String]
    var primaryLight: String
    var iconName: String
}

struct RoomData {
    let roomList: [RoomGroup] = [
        .init(name: "Couch", quickActions: [], lightItems: [], primaryLight: "light.couch_lights", iconName: "sofa.fill"),
        .init(name: "Living Room", quickActions: [], lightItems: [], primaryLight: "light.living_room_lights", iconName: "tv"),
        .init(name: "Ceiling Fan", quickActions: [], lightItems: [], primaryLight: "light.dining_lights", iconName: "fan.ceiling.fill"),
        .init(name: "Léo's Bedroom", quickActions: [], lightItems: [], primaryLight: "light.leo_bedroom_lights", iconName: "bed.double.fill"),
        .init(name: "Parents' Bedroom", quickActions: [], lightItems: [], primaryLight: "light.parents_bedroom", iconName: "bed.double.fill"),
        .init(name: "Felix's Bedroom", quickActions: [], lightItems: [], primaryLight: "light.felix_bedroom_lights", iconName: "bed.double.fill"),
    ]
}
