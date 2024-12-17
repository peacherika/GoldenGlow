//
//  CameraView.swift
//  GoldenGlow
//
//  Created by Erika Piccirillo on 15/12/24.
//

import AVFoundation
import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @State private var countdownText: String = ""

    var body: some View {
        ZStack {
            Color.accentColor4.opacity(0.6).edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()  // Spazio sopra la fotocamera

                if isCountdownActive() {
                    Text(countdownText)
                        .font(.title)
                        .foregroundColor(.black.opacity(0.7))
                        .padding()
                        .cornerRadius(10)
                        .onAppear {
                            startCountdown()
                        }
                }

                CameraPreview()
                    .frame(width: 395, height: 550)  // Dimensioni personalizzate
                    .cornerRadius(20)
                    .padding(.top, 30)

                Spacer()  // Spazio sotto la fotocamera

                Button(action: {
                    print("Scatta una foto")
                }) {
                    Circle()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .padding(.bottom, 20)
                }
            }

            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                            .padding(10)
                    }
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private func isCountdownActive() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        return hour == 16 && minute >= 35 && minute < 45
    }

    private func startCountdown() {
        let now = Date()
        let calendar = Calendar.current
        let currentSeconds = calendar.component(.second, from: now)
        let remainingSeconds =
            (44 - calendar.component(.minute, from: now)) * 60
            + (59 - currentSeconds)

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingSeconds - Int(timer.fireDate.timeIntervalSince(now))
                >= 0
            {
                let timeLeft =
                    remainingSeconds
                    - Int(timer.fireDate.timeIntervalSince(now))
                countdownText = String(
                    format: "%02d:%02d", timeLeft / 60, timeLeft % 60)
            } else {
                timer.invalidate()
                countdownText = ""
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    class CameraPreviewView: UIView {
        var previewLayer: AVCaptureVideoPreviewLayer {
            guard let layer = self.layer as? AVCaptureVideoPreviewLayer else {
                fatalError("Layer non è di tipo AVCaptureVideoPreviewLayer.")
            }
            return layer
        }

        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
    }

    let session = AVCaptureSession()

    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill

        configureSession()
        session.startRunning()

        return view
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {}

    private func configureSession() {
        guard
            let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .back)
        else {
            print("Fotocamera non disponibile.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            let output = AVCapturePhotoOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
        } catch {
            print("Errore nella configurazione della fotocamera: \(error)")
        }
    }
}

#Preview {

}
