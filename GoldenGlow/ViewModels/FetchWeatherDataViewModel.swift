//
//  ApiManagementVm.swift
//  GoldenGlow
//
//  Created by Erika Piccirillo on 13/12/24.
//
import Foundation

@Observable
class FetchWeatherDataViewModel {
    var weatherData: OpenWeatherAPIResponse?

    var readableSunsetTime: String? {
        guard let sunsetTimestamp = weatherData?.sun.sunset,
            let timezoneOffset = weatherData?.timezone
        else {
            return nil
        }

        // Convert the sunset time to Date
        let sunsetDate = Date(
            timeIntervalSince1970: TimeInterval(sunsetTimestamp))

        // Format the Date to a readable string using the timezone offset
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)

        return dateFormatter.string(from: sunsetDate)
    }

    private var apiKey: String {
        if let filePath = Bundle.main.path(
            forResource: "OpenWeatherSecret", ofType: "plist")
        {
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "API_KEY") as? String else {
                fatalError(
                    "Couldn't find key 'API_KEY' in 'OpenWeatherSecret.plist'.")
            }
            return value
        }

        fatalError("Couldn't find key 'API_KEY' in 'OpenWeatherSecret.plist'.")
    }

    var session: URLSession {
        let sessionConfiguration: URLSessionConfiguration
        sessionConfiguration = URLSessionConfiguration.default
        return URLSession(configuration: sessionConfiguration)
    }

    func fetchWeatherData() async {
        let currentCity = "naples"

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/weather"
        urlComponents.queryItems = [
            URLQueryItem(
                name: "q",
                value: "\(currentCity)"),
            URLQueryItem(name: "appid", value: apiKey),
        ]

        guard let url = urlComponents.url else {
            return
        }

        let request = URLRequest(url: url)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 404
                {
                    print("Something went wrong")
                    return
                }
                print("Something went wrong")
                return

            }

            weatherData = try JSONDecoder().decode(
                OpenWeatherAPIResponse.self, from: data)
        } catch {
            print("Something went wrong")
        }
    }
}
