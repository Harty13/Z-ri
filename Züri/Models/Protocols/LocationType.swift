//
//  LocationTypeEnum.swift
//  Züri
//
//  Created by Erik Schnell on 20.07.2025.
//

import Foundation
import SwiftUI

enum LocationType: String, CaseIterable, Codable {
    case brunnen = "brunnen"
    case wc = "wc"
    case bibliothek = "bibliothek"
    case park = "park"
    
    var title: String {
        switch self {
        case .brunnen:
            return "Brunne"
        case .wc:
            return "WC"
        case .bibliothek:
            return "Bibliothek"
        case .park:
            return "Park"
        }
    }
    
    var emoji: String {
        switch self {
        case .brunnen:
            return "⛲️"
        case .wc:
            return "🚽"
        case .bibliothek:
            return "📚"
        case .park:
            return "🌳"
        }
    }
    
    var tint: Color {
        switch self {
        case .brunnen:
            return .blue
        case .wc:
            return .white
        case .bibliothek:
            return .orange
        case .park:
            return .green
        }
    }
    
    var systemImageName: String {
        switch self {
        case .brunnen:
            return "drop.fill"
        case .wc:
            return "toilet.fill"
        case .bibliothek:
            return "book.fill"
        case .park:
            return "tree.fill"
        }
    }
}