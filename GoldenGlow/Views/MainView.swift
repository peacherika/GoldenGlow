import AVFoundation
import Combine
import SwiftUI

struct MainView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isCameraActive: Bool = false
    @State private var viewModel = FetchWeatherDataViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Mostra la posizione attuale
                Text(locationManager.currentCity)
                    .font(.system(size: 24, weight: .medium))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.top, 90)

                Spacer()

                // Sun and Quality
                VStack(spacing: 8) {
                    ZStack {
                        Image("Sun")
                            .frame(width: 180.0, height: 180.0)
                            .offset(x: 0, y: -20)

                        HStack {
                            Text("\(viewModel.weatherData?.clouds.all ?? 0)" )
                                .font(.system(size: 130, weight: .bold))
                                .foregroundColor(.clear)
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.accentColor3,
                                            Color.accentColor3, Color.black,
                                        ]),
                                        startPoint: .top,
                                        endPoint: .init(x: 0.55, y: 0.85)
                                    )
                                )
                                .mask(
                                    Text("\(viewModel.weatherData?.clouds.all ?? 0)")
                                        .font(.system(size: 130, weight: .bold))
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.trailing)
                                )
                                .multilineTextAlignment(.trailing)
                                .offset(x: 0, y: 70)

                            Text("%")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.clear)  // Transparent text
                                .multilineTextAlignment(.trailing)
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.accentColor3, Color.black,
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .mask(
                                    Text("%")
                                        .font(.system(size: 20, weight: .bold))
                                        .multilineTextAlignment(.trailing)
                                )
                                .offset(x: 0, y: 110)
                        }
                    }

                    Text("Cloud Coverage")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.black)
                        .offset(x: 0, y: 25)
                }

                Spacer()

                // Sunset and Date
                VStack(spacing: 16) {
                    Text("Sunset at " + (viewModel.readableSunsetTime ?? "00:00"))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(Color.accentColor2)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .offset(x: 0, y: -20)

                    HStack {
                        Text("Date")
                            .font(.headline)
                            .foregroundColor(Color.accentColor2)
                            .multilineTextAlignment(.center)
                        Spacer()
                        Text((formattedDate()))
                            .font(.body)
                            .foregroundColor(Color.accentColor2)
                            .padding(.all, 7)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)

                    Divider()
                        .padding(.horizontal)

                    // Time Periods
                    VStack(spacing: 4) {
                        HStack {
                            Text("8:04")  //Cosa voglio metttere qua?
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text("Golden")
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text("15:52")
                                .multilineTextAlignment(.trailing)
                        }

                        HStack {
                            Text("7:20")  //sunrise
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "sunrise.fill")
                            Image(systemName: "sunset.fill")
                            Spacer()
                            Text("16:36")  //sunset
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("6:50")
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text("Civil")
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text("17:07")
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("6:15")
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text("Naut.")
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text("17:41")
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("5:42")
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text("Astro")
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text("18:15")
                                .multilineTextAlignment(.trailing)
                        }
                    }.foregroundColor(Color.accentColor)
                        .padding(.horizontal, 20)
                        .font(.system(size: 15))
                }

                .padding(.vertical, 30)
                Spacer()

                // Bottom Navigation Bar
                NavigationBar(isCameraActive: $isCameraActive)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.pink.opacity(0.4), Color.accentColor4,
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .edgesIgnoringSafeArea(.all)
        }
        .task {
            await viewModel.fetchWeatherData()
        }
    }
    
    
}

struct NavigationBar: View {
    @Binding var isCameraActive: Bool

    var body: some View {
        HStack {
            Spacer()

            // Home Button
            Button(action: {
                print("Home tapped")
            }) {
                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 25)
                    .foregroundColor(.black)
            }

            Spacer()

            // Camera Button
            Button(action: {
                isCameraActive = true  // Attiva la navigazione verso la fotocamera
            }) {
                ZStack {
                    Circle()
                        .fill(Color.pink.opacity(0.2))  // Sfondo rosa
                        .frame(width: 60, height: 60)
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
            }
            .fullScreenCover(isPresented: $isCameraActive) {
                CameraView()  // Vista della fotocamera a schermo intero
            }

            Spacer()

            // Navigation/Arrow Button
            Button(action: {
                print("Navigation tapped")
            }) {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 25)
                    .foregroundColor(.black)
            }

            Spacer()
        }
        .padding(.horizontal)
        .offset(y: -35)
    }
}

private func formattedDate() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: Date())
}

#Preview {
    MainView()
}
