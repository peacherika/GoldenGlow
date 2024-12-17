//
//  GoldenGlowApp.swift
//  GoldenGlow
//
//  Created by Erika Piccirillo on 09/12/24.
//

import SwiftUI

@main
struct YourApp: App {
    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            SunsetQualityView()
        }
    }
}
