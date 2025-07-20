//
//  WeatherAPI.swift
//  Züri
//
//  Created by Erik Schnell on 16.03.2025.
//

import Foundation



class WeatherAPI {
    
    struct LimmatTemperature {
        let temperature: Double
        let date: Date
    }
    
    func limmatTemp() async -> LimmatTemperature? {
        let urlString = "https://api.existenz.ch/apiv1/hydro/latest?locations=2243&parameters=temperature&app=zueri"
        
        struct Payload: Decodable {
            let timestamp: TimeInterval
            let val: Double
        }

        struct WeatherResponse: Decodable {
            let payload: [Payload]
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Decode the response
            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
            
            // Access the first payload
            if let firstPayload = response.payload.first {
                let temperature = firstPayload.val
                let date = Date(timeIntervalSince1970: firstPayload.timestamp)
                return LimmatTemperature(temperature: temperature, date: date)
            }
        } catch {
            print("Error: \(error)")
        }
        
        return nil
    }
}
