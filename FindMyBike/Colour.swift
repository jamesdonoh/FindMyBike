//
//  Colour.swift
//  FindMyBike
//
//  Created by James Donohue on 28/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit

enum Colour {
    case black, white, grey, red, green, blue, yellow, orange

    static var all: [Colour] = [.black, .white, .grey, .red, .green, .blue, .yellow, .orange]

    var description: String {
        switch self {
        case .black:
            return "Black"
        case .white:
            return "White"
        case .grey:
            return "Grey"
        case .red:
            return "Red"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .yellow:
            return "Yellow"
        case .orange:
            return "Orange"
        }
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
