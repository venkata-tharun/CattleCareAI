import SwiftUI

struct DiseasePredictionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var tabRouter: TabRouter
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showCameraError = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            HStack {
                Spacer()
                Text("AI Disease Prediction")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.white)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - Upload Area Card
                    VStack(spacing: 24) {
                        
                        // Icon Circle or Selected Image
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.88, green: 0.98, blue: 0.92)) // Very light mint
                                .frame(width: 120, height: 120)
                            
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera")
                                    .font(.system(size: 44))
                                    .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.3))
                            }
                        }
                        .padding(.top, 50)
                        
                        // Text Info
                        VStack(spacing: 12) {
                            Text(selectedImage == nil ? "Upload Cattle Image" : "Image Selected")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(.darkGray))
                            
                            Text(selectedImage == nil ? "Upload a Clear image of the\naffected cattle area for AI-\npowered disease detection" : "Our AI will analyze this image to detect potential diseases.")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 20)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    sourceType = .camera
                                    showImagePicker = true
                                } else {
                                    showCameraError = true
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                    Text("Take Photo")
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(red: 0.1, green: 0.5, blue: 0.3))
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color(red: 0.88, green: 0.98, blue: 0.92))
                                .cornerRadius(14)
                            }
                            
                            Button(action: {
                                sourceType = .photoLibrary
                                showImagePicker = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "photo.fill")
                                    Text("Choose from Gallery")
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(.systemGray5), lineWidth: 1.5)
                                )
                            }
                            
                            if let image = selectedImage {
                                Button(action: {
                                    router.push(.aiImagePreview(image))
                                }) {
                                    Text("Start Analysis")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color.green)
                                        .cornerRadius(14)
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 50)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color(.systemGray6), lineWidth: 1.5)
                            .padding(1)
                    )
                    .padding(.horizontal, 22)
                    .padding(.top, 30)
                    
                    Spacer().frame(height: 30)
                    
                    // MARK: - Tip Card
                    HStack(alignment: .top, spacing: 14) {
                        Text("Tip:")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.6))
                        
                        Text("Ensure good lighting and focus on the specific symptom area for best results.")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.6))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.94, green: 0.97, blue: 1.0))
                    .cornerRadius(16)
                    .padding(.horizontal, 22)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGray6).opacity(0.2))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
        }
        .alert("Camera Unavailable", isPresented: $showCameraError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This device does not have a functional camera.")
        }
    }
}

#Preview {
    DiseasePredictionView()
}
