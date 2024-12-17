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

struct Weather: Codable {
    let coordinates: Coordinates
    let weather: [Rain]
    let base: String
    let mainWeatherData: MainWeatherData
    let visibility: Int
    let clouds: Clouds
    let dt: Int
    let timezone, id: Int
    let name: String
    let cod: Int
}
