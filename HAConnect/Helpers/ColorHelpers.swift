//
// ColorHelpers.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI

extension View {
    func determineLightColor(_ entity: HAEntity?) -> Color? {
        if entity?.domain == "light" {
            let colorList = entity!.attributes.dictionary["rgb_color"] as? [Int]
            if colorList?.count == 3{
                return Color(
                    red:  Double(colorList?[0] ?? 128)/255,
                    green: Double(colorList?[1] ?? 128)/255,
                    blue: Double(colorList?[2] ?? 128)/255
                )
            } else {
                return nil
            }

        } else {
            return nil
        }
    }
}
