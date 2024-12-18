//
//  CameraView.swift
//  GoldenGlow
//
//  Created by Erika Piccirillo on 15/12/24.
//

import AVFoundation
import Photos
import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @State private var countdownText: String = ""
    @StateObject private var cameraController = CameraController()

    var body: some View {
        ZStack {
            Color.accentColor4.opacity(0.6).edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

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

                CameraPreview(session: cameraController.session)
                    .frame(width: 395, height: 550)  // Dimensioni personalizzate
                    .cornerRadius(20)
                    .padding(.top, 30)

                Spacer()  // Spazio sotto la fotocamera

                Button(action: {
                    cameraController.takePhoto()
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
        .onAppear {
            cameraController.startSession()
        }
        .onDisappear {
            cameraController.stopSession()
        }
    }

    private func isCountdownActive() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        return hour == 16 && minute >= 27 && minute < 37
    }

    private func startCountdown() {
        let now = Date()
        let calendar = Calendar.current
        let currentSeconds = calendar.component(.second, from: now)
        let remainingSeconds =
            (36 - calendar.component(.minute, from: now)) * 60
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
    let session: AVCaptureSession

    class VideoPreviewView: UIView {
            override class var layerClass: AnyClass {
                return AVCaptureVideoPreviewLayer.self
            }

            var videoPreviewLayer: AVCaptureVideoPreviewLayer {
                return layer as! AVCaptureVideoPreviewLayer
            }
        }

        func makeUIView(context: Context) -> VideoPreviewView {
            let view = VideoPreviewView()
            view.videoPreviewLayer.session = session
            view.videoPreviewLayer.videoGravity = .resizeAspectFill
            return view
        }

        func updateUIView(_ uiView: VideoPreviewView, context: Context) {
            uiView.videoPreviewLayer.connection?.videoOrientation = .portrait
            uiView.videoPreviewLayer.frame = uiView.bounds
        }
    }

class CameraController: ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let photoCaptureDelegate = CameraPhotoCapture()

    init() {
        configureSession()
    }

    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
        }
    }

    private func configureSession() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Fotocamera non disponibile.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
        } catch {
            print("Errore nella configurazione della fotocamera: \(error)")
        }
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: photoCaptureDelegate)
    }
}

class CameraPhotoCapture: NSObject, AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }

        // Salva l'immagine nel rullino fotografico
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: imageData, options: options)
                }) { success, error in
                    if success {
                        print("Foto salvata con successo!")
                    } else {
                        print("Errore nel salvataggio della foto: \(error?.localizedDescription ?? "Errore sconosciuto")")
                    }
                }
            } else {
                print("Autorizzazione alla libreria fotografica negata.")
            }
        }
    }
}


#Preview {

}
