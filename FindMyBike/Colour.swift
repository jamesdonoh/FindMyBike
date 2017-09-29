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
            return UIColor.gray
        case .red:
            return UIColor.red
        case .green:
            return UIColor.green
        case .blue:
            return UIColor.blue
        case .yellow:
            return UIColor.yellow
        case .orange:
            return UIColor.orange
        }
    }
}
