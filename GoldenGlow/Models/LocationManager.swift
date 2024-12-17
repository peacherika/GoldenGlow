//
//  LocationManager.swift
//  GoldenGlow
//
//  Created by Erika Piccirillo on 17/12/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocation? = nil
    @Published var currentCity: String = "Unknown Location"

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
    }

    private func checkAuthorizationStatus() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            DispatchQueue.main.async {
                self.currentCity = "Location Access Denied"
            }
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            DispatchQueue.main.async {
                self.currentCity = "Unknown Authorization Status"
            }
        }
    }

    func locationManager(
        _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        print("Location updated: \(locations)")
        guard let location = locations.last else {
            print("No valid location found")
            return
        }
        currentLocation = location
        fetchCityName(from: location)
    }

    func locationManager(
        _ manager: CLLocationManager, didFailWithError error: Error
    ) {
        print("Failed to find location: \(error)")
    }

    func fetchCityName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) {
            [weak self] placemarks, error in
            if let error = error {
                print("Reverse geocoding failed with error: \(error)")
                return
            }

            guard let placemark = placemarks?.first else {
                print(
                    "No placemarks found for location: \(location.coordinate)")
                return
            }

            print("Resolved placemark: \(placemark)")
            let city = placemark.locality ?? "Unknown City"
            DispatchQueue.main.async {
                self?.currentCity = city
            }
        }

    }
}
