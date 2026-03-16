import SwiftUI

struct PredictionResultView: View {
    let image: UIImage
    let prediction: DiseasePrediction
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var healthManager: HealthDataManager
    
    @StateObject private var animalManager = AnimalDataManager.shared
    @State private var selectedAnimal: Animal?
    @State private var isSaved = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green)
                        .padding(10)
                }
                Spacer()
                Text("Prediction Result")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.white)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    if prediction.diseaseName == "Non-Cattle Detected" {
                        // MARK: - Non-Cattle Detected View
                        VStack(spacing: 30) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "questionmark.app.dashed")
                                    .font(.system(size: 60))
                                    .foregroundColor(.orange)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Detection Failed")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                                
                                Text("Our AI couldn't find a cow in this image. Please try again with a clearer photo of your livestock.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            Button(action: { dismiss() }) {
                                Text("Retry Analysis")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.orange)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(32)
                        .background(Color.white)
                        .cornerRadius(32)
                        .shadow(color: Color.black.opacity(0.05), radius: 20, y: 10)
                        .padding(.horizontal, 16)
                        .padding(.top, 40)
                        
                    } else {
                        // MARK: - Main Result Card
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // Analysis Image with Improved Fit
                            ZStack {
                                Color(.systemGray6)
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 300)
                                    .cornerRadius(12)
                                    .padding(8)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipped()
                            
                            VStack(alignment: .leading, spacing: 20) {
                            // Header: Disease Name & Confidence
                            VStack(alignment: .leading, spacing: 6) {
                                Text(prediction.diseaseName)
                                    .font(.system(size: 26, weight: .black))
                                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                                
                                HStack(spacing: 8) {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(prediction.diseaseName == "Healthy" ? Color.green : Color.red)
                                            .frame(width: 8, height: 8)
                                        Text(prediction.diseaseName == "Healthy" ? "Animal looks healthy" : "Requires attention")
                                    }
                                    
                                    Text("•")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 10))
                                    
                                    Text(String(format: "%.1f%% Confidence", prediction.confidence * 100))
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)

                                
                                if !isSaved {
                                    // Premium Animal Picker
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("LINK TO ANIMAL").font(.system(size: 11, weight: .bold)).foregroundColor(.secondary).tracking(1)
                                        Menu {
                                            ForEach(animalManager.animals) { animal in
                                                Button { selectedAnimal = animal } label: {
                                                    Text("\(animal.name) (\(animal.tag))")
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: "tag.fill")
                                                    .foregroundColor(.green)
                                                Text(selectedAnimal?.name ?? "Choose animal profile...")
                                                    .font(.system(size: 15, weight: .medium))
                                                Spacer()
                                                Image(systemName: "chevron.up.chevron.down")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 14)
                                            .background(Color(.systemGray6).opacity(0.5))
                                            .cornerRadius(12)
                                            .foregroundColor(.primary)
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                // Details Section (Symptoms & Precautions)
                                VStack(spacing: 24) {
                                    // Symptoms
                                    VStack(alignment: .leading, spacing: 12) {
                                        Label(prediction.diseaseName == "Healthy" ? "Why we think so" : "Symptoms Spotted", systemImage: prediction.diseaseName == "Healthy" ? "sparkles" : "eye.trianglebadge.exclamationmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(prediction.diseaseName == "Healthy" ? .green : .orange)
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            ForEach(prediction.symptoms, id: \.self) { symptom in
                                                resultRow(symptom, color: prediction.diseaseName == "Healthy" ? .green : .orange)
                                            }
                                        }
                                    }
                                    
                                    // Precautions
                                    VStack(alignment: .leading, spacing: 12) {
                                        Label("Next Steps", systemImage: "bolt.shield.fill")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            ForEach(prediction.precautions, id: \.self) { precaution in
                                                resultRow(precaution, color: .blue)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(24)
                        }
                        .background(Color.white)
                        .cornerRadius(32)
                        .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        
                        // MARK: - Action Buttons
                        VStack(spacing: 12) {
                            if !isSaved {
                                Button(action: {
                                    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
                                    NetworkManager.shared.uploadAIPrediction(
                                        image: imageData,
                                        diseaseName: prediction.diseaseName,
                                        confidence: prediction.confidence,
                                        status: prediction.status,
                                        symptoms: prediction.symptoms,
                                        precautions: prediction.precautions,
                                        animalId: selectedAnimal?.id
                                    ) { success in
                                        if success {
                                            let df = DateFormatter()
                                            df.dateFormat = "MMM dd, yyyy"
                                            let newEvent = AIHealthEvent(
                                                animalName: selectedAnimal?.name ?? "Unknown Animal",
                                                diseaseName: prediction.diseaseName,
                                                date: df.string(from: Date()),
                                                status: prediction.status,
                                                confidence: prediction.confidence
                                            )
                                            healthManager.addEvent(newEvent)
                                            withAnimation { isSaved = true }
                                        }
                                    }
                                }) {
                                    Text(selectedAnimal == nil ? "Save This Analysis" : "Link to \(selectedAnimal!.name)")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(selectedAnimal == nil ? Color.green.opacity(0.8) : Color.green)
                                        .cornerRadius(16)
                                        .shadow(color: Color.green.opacity(0.3), radius: 8, y: 4)
                                }
                                .padding(.top, 10)
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                    Text("Analysis saved to records").font(.system(size: 16, weight: .semibold))
                                }
                                .padding(.vertical, 20)
                            }
                            
                            Button(action: {
                                router.popToRoot()
                                tabRouter.selectedTab = .home
                            }) {
                                Text("Return to Home")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(Color(.systemGray6).opacity(0.4))
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func resultRow(_ text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(color.opacity(0.6))
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary.opacity(0.8))
        }
    }
    
    // Legacy helper - kept for compatibility if needed elsewhere
    @ViewBuilder
    private func symptomRow(_ text: String) -> some View {
        resultRow(text, color: .orange)
    }
    
    @ViewBuilder
    private func precautionRow(_ text: String) -> some View {
        resultRow(text, color: .green)
    }
}

#Preview {
    PredictionResultView(
        image: UIImage(),
        prediction: DiseasePrediction(
            diseaseName: "Lumpy Skin Disease",
            confidence: "87%",
            status: "Critical",
            symptoms: ["High fever", "Nodules on skin"],
            precautions: ["Isolate", "Call Vet"]
        )
    )
}
