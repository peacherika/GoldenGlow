//
//  ApiManagementVm.swift
//  GoldenGlow
//
//  Created by Erika Piccirillo on 13/12/24.
//
import Foundation

@Observable
class FetchWeatherDataViewModel {
    var apiDatas: [Weather] = []
    var endpp = ""
    var items: [Sun] = []

    private var locationManager = LocationManager()
    init() {
        fetchDatas(
            endp:
                "https://api.openweathermap.org/data/2.5/weather?q=\(String(describing: locationManager.currentLocation))&appid=4e828e100c642aec139ad21633e4d43d"
        )
    }

    func fetchDatas(endp: String) {
        let endpoint =
            "https://api.openweathermap.org/data/2.5/weather?q=\(String(describing: locationManager.currentLocation))&appid=4e828e100c642aec139ad21633e4d43d"

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
                            Weather.self, from: safeData)
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
}
