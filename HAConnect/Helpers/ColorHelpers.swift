//
// ColorHelpers.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI

// MARK: RGB to SwiftUI
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

/// Helpers For Color Wheel
// MARK: AngularGradientHueView
struct AngularGradientHueView: View {

    var colours: [Color] = {
        let hue = Array(0...359).reversed()
        return hue.map {
            Color(UIColor(hue: CGFloat($0) / 359, saturation: 1, brightness: 1, alpha: 1))
        }
    }()
    var radius: CGFloat

    var body: some View {
        AngularGradient(gradient: Gradient(colors: colours), center: UnitPoint(x: 0.5, y: 0.5))
            .frame(width: radius, height: radius)
            .clipShape(Circle())
    }
}

// MARK: RGB
struct RGB: Equatable {

    var rColor: CGFloat // Percent [0,1]
    var gColor: CGFloat // Percent [0,1]
    var bColor: CGFloat // Percent [0,1]

    static func toHSV(rColor: CGFloat, gColor: CGFloat, bColor: CGFloat) -> HSV {
        let min = rColor < gColor ? (rColor < bColor ? rColor : bColor) : (gColor < bColor ? gColor : bColor)
        let max = rColor > gColor ? (rColor > bColor ? rColor : bColor) : (gColor > bColor ? gColor : bColor)

        let vValue = max
        let delta = max - min

        guard delta > 0.00001 else { return HSV(hValue: 0, sValue: 0, vValue: max) }
        guard max > 0 else { return HSV(hValue: -1, sValue: 0, vValue: vValue) } // Undefined, achromatic grey
        let sValue = delta / max

        let hue: (CGFloat, CGFloat) -> CGFloat = { max, delta -> CGFloat in
            if rColor == max { return (gColor-bColor)/delta } // between yellow & magenta
            else if gColor == max { return 2 + (bColor-rColor)/delta } // between cyan & yellow
            else { return 4 + (rColor-gColor)/delta } // between magenta & cyan
        }

        let hValue = hue(max, delta) * 60 // In degrees

        return HSV(hValue: (hValue < 0 ? hValue+360 : hValue), sValue: sValue, vValue: vValue)
    }

    var hsv: HSV {
        return RGB.toHSV(rColor: self.rColor, gColor: self.gColor, bColor: self.bColor)
    }
}

// MARK: HSV
/// Struct that holds hue, saturation, value values. Also has a `rgb` value that converts it's values to hsv.
struct HSV {
    var hValue: CGFloat // Angle in degrees [0,360] or -1 as Undefined
    var sValue: CGFloat // Percent [0,1]
    var vValue: CGFloat // Percent [0,1]

    static func toRGB(hValue: CGFloat, sValue: CGFloat, vValue: CGFloat) -> RGB {
        if sValue == 0 { return RGB(rColor: vValue, gColor: vValue, bColor: vValue) } // Achromatic grey

        // swiftlint:disable identifier_name
        let angle = (hValue >= 360 ? 0 : hValue)
        let sector = angle / 60 // Sector
        let i = floor(sector)
        let f = sector - i // Factorial part of h
        let p = vValue * (1 - sValue)
        let q = vValue * (1 - (sValue * f))
        let t = vValue * (1 - (sValue * (1 - f)))

        // swiftlint:disable control_statement
        switch(i) {
        case 0:
            return RGB(rColor: vValue, gColor: t, bColor: p)
        case 1:
            return RGB(rColor: q, gColor: vValue, bColor: p)
        case 2:
            return RGB(rColor: p, gColor: vValue, bColor: t)
        case 3:
            return RGB(rColor: p, gColor: q, bColor: vValue)
        case 4:
            return RGB(rColor: t, gColor: p, bColor: vValue)
        default:
            return RGB(rColor: vValue, gColor: p, bColor: q)
        }
    }

    var rgb: RGB {
        return HSV.toRGB(hValue: self.hValue, sValue: self.sValue, vValue: self.vValue)
    }

}

func atan2To360(_ angle: CGFloat) -> CGFloat {
    var result = angle
    if result < 0 {
        result = (2 * CGFloat.pi) + angle
    }
    return result * 180 / CGFloat.pi
}

func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt(xDist * xDist + yDist * yDist))
}

extension LightsColorPicker {
    
    func rgbConvert(_ array: [Int]?) -> RGB {
        RGB(
            rColor: CGFloat(Double(array?[0] ?? 1)/255),
            gColor: CGFloat(Double(array?[1] ?? 1)/255),
            bColor: CGFloat(Double(array?[2] ?? 1)/255)
        )
    }
    
    func RGBEqualToArray( _ array: [Int]?, _ rgb: RGB) -> Bool {
        let rgbArray: [Int] = [
            Int(((Double(array?[0] ?? 1)/255)*100).rounded()),
            Int(((Double(array?[1] ?? 1)/255)*100).rounded()),
            Int(((Double(array?[2] ?? 1)/255)*100).rounded())
        ]
        
        let array: [Int] = [
            Int((Double(rgb.rColor)*100).rounded()),
            Int((Double(rgb.gColor)*100).rounded()),
            Int((Double(rgb.bColor)*100).rounded())
        ]
        
        if rgbArray == array { return true } else {
            return false
        }
        
    }
}
