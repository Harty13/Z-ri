//
//  Color_Extension.swift
//  Züri
//
//  Created by Erik Schnell on 23.03.2025.
//

import SwiftUI

extension Color: Codable {
    private struct ColorRepresentation: Codable {
        var red: Double
        var green: Double
        var blue: Double
        var alpha: Double
        
        init(color: Color) {
            let components = color.cgColor?.components ?? [0, 0, 0, 1]
            self.red = Double(components[0])
            self.green = Double(components[1])
            self.blue = Double(components[2])
            self.alpha = Double(components[3])
        }
        
        func toColor() -> Color {
            return Color(red: red, green: green, blue: blue, opacity: alpha)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let representation = try ColorRepresentation(from: decoder)
        self = representation.toColor()
    }
    
    public func encode(to encoder: Encoder) throws {
        let representation = ColorRepresentation(color: self)
        try representation.encode(to: encoder)
    }
}
