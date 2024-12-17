//
//  ApiManagementVm.swift
//  GoldenGlow
//
//  Created by Erika Piccirillo on 13/12/24.
//
import Foundation

@Observable
class FetchWeatherDataViewModel {
    var apiDatas: [OpenWeatherAPIResponse] = []
    var endpp = ""
    var items: [Sun] = []

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

    private var locationManager = LocationManager()

    func fetchDatas(endp: String) {
        let endpoint =
            "https://api.openweathermap.org/data/2.5/weather?q=\(String(describing: locationManager.currentLocation))&appid="

        if let url = URL(string: endpoint) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { datas, response, err in
                if err != nil {
                    print(err!.localizedDescription)
                }
                let Decoder = JSONDecoder()
                if let safeData = datas {
                    do {
                        let jsonData = try Decoder.decode(
                            OpenWeatherAPIResponse.self, from: safeData)
                        DispatchQueue.main.async {
                            self.apiDatas = [jsonData]
                            print(jsonData.name)
                            print(self.locationManager.currentCity)
                        }
                    } catch let err as NSError {
                        print(err.localizedDescription)
                    }
                }
            }
            task.resume()
        }
    }

    func fetchWeatherData() async -> OpenWeatherAPIResponse? {
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
            return nil
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
                    return nil
                }
                print("Something went wrong")
                return nil

            }

            return try JSONDecoder().decode(OpenWeatherAPIResponse.self, from: data)
        } catch {
            print("Something went wrong")
        }
        
        return nil
    }
}
