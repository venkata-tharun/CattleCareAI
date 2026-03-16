import SwiftUI

struct ImageScanningView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: NavigationRouter
    
    @State private var scanOffset: CGFloat = -200
    @State private var isScanning = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            HStack {
                Button { router.pop() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green)
                        .padding(10)
                }
                Spacer()
                Text("Preview Image")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.3))
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.white)
            
            // MARK: - Image Preview Area
            ZStack {
                Color(red: 0.14, green: 0.18, blue: 0.23) // Dark blue/gray background
                    .ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        // Scanning Bar Animation
                        ZStack {
                            if isScanning {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.clear, .green.opacity(0.5), .clear]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: 100)
                                    .offset(y: scanOffset)
                            }
                        }
                    )
                    .clipped()
                
                if !isScanning {
                    Text("Image Preview")
                        .font(.system(size: 18))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Bottom Action
            VStack {
                Button(action: {
                    guard !isScanning else { return }
                    
                    // Start Animation
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                        isScanning = true
                        scanOffset = 200
                    }
                    
                    // Navigate after delay or inference
                    Task {
                        // Attempt real prediction
                        if let realPrediction = await AIPredictionService.shared.predict(image: image) {
                            router.push(.aiPredictionResult(image, realPrediction))
                        } else {
                            // Fallback to a random mock if prediction fails (e.g. model not loaded)
                            let mockPredictions: [DiseasePrediction] = [
                                DiseasePrediction(
                                    diseaseName: "Lumpy Skin Disease",
                                    confidence: "87%",
                                    status: "Critical",
                                    symptoms: ["High fever", "Nodules on skin", "Reduced milk yield", "Loss of appetite"],
                                    precautions: ["Isolate the affected animal immediately", "Contact your veterinarian", "Vaccinate healthy cattle in the herd", "Disinfect the shed and equipment"]
                                ),
                                DiseasePrediction(
                                    diseaseName: "Foot and Mouth Disease (FMD)",
                                    confidence: "92%",
                                    status: "Critical",
                                    symptoms: ["Blisters on mouth & hooves", "Lameness", "Fever", "Excessive salivation"],
                                    precautions: ["Strict isolation", "Report to local authorities", "Do not move animals", "Disinfect premises"]
                                )
                            ]
                            let randomPrediction = mockPredictions.randomElement()!
                            router.push(.aiPredictionResult(image, randomPrediction))
                        }
                        
                        isScanning = false
                        scanOffset = -200
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                        Text(isScanning ? "Processing..." : "Predict Disease")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color(red: 0.1, green: 0.65, blue: 0.35))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 30)
                }
            }
            .background(Color.black)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ImageScanningView(image: UIImage())
}
