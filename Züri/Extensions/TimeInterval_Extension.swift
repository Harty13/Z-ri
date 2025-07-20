//
//  TimeInterval_Extension.swift
//  Züri
//
//  Created by Erik Schnell on 16.03.2025.
//

import Foundation

extension TimeInterval {
    func formattedAsHoursAndMinutes() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short  // Use short units like "h" for hours and "min" for minutes
        formatter.allowedUnits = [.hour, .minute]  // Only show hours and minutes
        return formatter.string(from: self) ?? ""
    }
}
