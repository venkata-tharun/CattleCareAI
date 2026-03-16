//
//  OTPVerificationView.swift
//  PashuCare
//

import SwiftUI

struct OTPVerificationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: NavigationRouter
    
    @State private var otpCode: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // We need context to know if we are verifying registration or forgot password
    // For simplicity, let's assume we pass the email/phone and context via environment or init
    // Or we handle both cases. Let's add properties to handle context.
    var emailOrPhone: String = ""
    var isRegistration: Bool = true
    
    var isValid: Bool {
        !otpCode.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.18)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    Text("Verify OTP")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color.black.opacity(0.9))
                        .padding(.top, 28)
                    
                    Text("Enter the OTP code sent to your device.")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        fieldLabel("OTP Code")
                        IconField(
                            icon: "key",
                            placeholder: "Enter OTP Code",
                            text: $otpCode,
                            isSecure: false,
                            keyboard: .numberPad
                        )
                    }
                    .padding(.top, 22)
                    
                    Button {
                        withAnimation { isLoading = true }
                        
                        if isRegistration {
                            NetworkManager.shared.verifyRegistration(emailOrPhone: emailOrPhone, otp: otpCode) { result in
                                isLoading = false
                                switch result {
                                case .success(let res):
                                    if res.error != nil {
                                        errorMessage = res.error!
                                        showError = true
                                    } else {
                                        // Registration verified, go to login
                                        router.popToWelcomeAndLogin()
                                    }
                                case .failure(let err):
                                    errorMessage = err.localizedDescription
                                    showError = true
                                }
                            }
                        } else {
                            NetworkManager.shared.verifyForgotPassword(emailOrPhone: emailOrPhone, otp: otpCode) { result in
                                isLoading = false
                                switch result {
                                case .success(let res):
                                    if res.error != nil {
                                        errorMessage = res.error!
                                        showError = true
                                    } else {
                                        // Wait until OTP is verified to show reset screen
                                        let token = res.reset_token ?? ""
                                        router.push(.reset(emailOrPhone, token))
                                    }
                                case .failure(let err):
                                    errorMessage = err.localizedDescription
                                    showError = true
                                }
                            }
                        }
                        
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 62)
                                .background(Color(red: 0.06, green: 0.65, blue: 0.29))
                                .cornerRadius(18)
                        } else {
                            Text("Verify OTP")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 62)
                                .background(Color(red: 0.06, green: 0.65, blue: 0.29))
                                .cornerRadius(18)
                                .opacity(isValid ? 1.0 : 0.55)
                        }
                    }
                    .disabled(!isValid)
                    .padding(.top, 18)
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 22)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white.ignoresSafeArea())
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header (Back + Title)
    private var header: some View {
        ZStack {
            Text("Verification")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 0.06, green: 0.65, blue: 0.29))
                        .frame(width: 44, height: 44, alignment: .leading)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
    
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(Color.black.opacity(0.75))
    }
}

// MARK: - Reusable Field (Icon + Rounded Border)
private struct IconField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let keyboard: UIKeyboardType
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray.opacity(0.7))
                .frame(width: 26)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 62)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.22), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        OTPVerificationView(emailOrPhone: "demo@example.com", isRegistration: true)
            .environmentObject(NavigationRouter())
    }
}
