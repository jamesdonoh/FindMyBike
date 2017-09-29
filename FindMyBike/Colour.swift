//
//  Colour.swift
//  FindMyBike
//
//  Created by James Donohue on 28/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit

enum Colour: String {
    case black, white, grey, red, green, blue, yellow, orange

    static var all: [Colour] = [.black, .white, .grey, .red, .green, .blue, .yellow, .orange]

    var description: String {
        return String(rawValue.characters.prefix(1)).capitalized + String(rawValue.characters.dropFirst())
    }

    var ui: UIColor {
        switch self {
        case .black:
            return UIColor.black
        case .white:
            return UIColor.white
        case .grey:
            return UIColor.darkGray
        case .red:
            return UIColor(red:0.80, green:0.00, blue:0.00, alpha:1.0)
        case .green:
            return UIColor(red:0.21, green:0.68, blue:0.00, alpha:1.0)
        case .blue:
            return UIColor(red:0.12, green:0.00, blue:0.63, alpha:1.0)
        case .yellow:
            return UIColor(red:0.80, green:0.82, blue:0.02, alpha:1.0)
        case .orange:
            return UIColor(red:0.84, green:0.36, blue:0.02, alpha:1.0)
        }
    }
}
