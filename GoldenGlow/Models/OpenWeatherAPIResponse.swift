//
//  Datas.swift
//  GoldenGlow
//
//  Created by Erika Piccirillo on 13/12/24.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

struct OpenWeatherAPIResponse: Codable {
    let coordinates: Coordinates
    let weather: [Weather]
    let base: String
    let mainWeatherData: MainWeatherData
    let visibility: Int
    let clouds: Clouds
    let dt: Int
    let sun: Sun
    let timezone, id: Int
    let name: String
    let cod: Int
    
    enum CodingKeys: String, CodingKey {
        case coordinates = "coord"
        case weather
        case base
        case mainWeatherData = "main"
        case visibility
        case clouds
        case dt
        case sun = "sys"
        case timezone, id
        case name
        case cod
    }
}
