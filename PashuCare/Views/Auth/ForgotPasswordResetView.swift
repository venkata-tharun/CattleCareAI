//
//  ForgotPasswordResetView.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//


import SwiftUI

struct ForgotPasswordResetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: NavigationRouter

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var emailOrPhone: String = ""
    var resetToken: String = ""

    var isValid: Bool {
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        !isLoading
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.18)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {

                    Text("New Password")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color.black.opacity(0.9))
                        .padding(.top, 28)

                    Text("Set a strong, new password for your account.")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .lineSpacing(4)

                    VStack(alignment: .leading, spacing: 12) {
                        fieldLabel("New Password")
                        IconField(
                            icon: "lock",
                            placeholder: "Enter new password",
                            text: $newPassword,
                            isSecure: true,
                            keyboard: .default
                        )
                    }
                    .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 12) {
                        fieldLabel("Confirm Password")
                        IconField(
                            icon: "lock",
                            placeholder: "Confirm new password",
                            text: $confirmPassword,
                            isSecure: true,
                            keyboard: .default
                        )
                    }
                    .padding(.top, 6)

                    Button {
                        let passwordPattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#])[A-Za-z\\d$@$!%*?&#]{8,}"
                        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordPattern)
                        guard passwordPredicate.evaluate(with: newPassword) else {
                            errorMessage = "Password must be at least 8 characters long and contain uppercase, lowercase, number, and special character."
                            showError = true
                            return
                        }
                        
                        withAnimation { isLoading = true }
                        
                        NetworkManager.shared.resetPassword(emailOrPhone: emailOrPhone, newPassword: newPassword, resetToken: resetToken) { result in
                            isLoading = false
                            switch result {
                            case .success(let res):
                                    if let user = res.user {
                                        // Auto-login after reset
                                        UserDefaults.standard.set(user.full_name, forKey: "userName")
                                        UserDefaults.standard.set(user.farm_name, forKey: "farmName")
                                        UserDefaults.standard.set(user.email_or_phone, forKey: "userEmail")
                                        UserDefaults.standard.set(user.id, forKey: "userId")
                                        NotificationCenter.default.post(name: .loginNotification, object: nil)
                                    } else if let errMsg = res.error {
                                        errorMessage = errMsg
                                        showError = true
                                    } else {
                                        // Fallback if no user but success
                                        NotificationCenter.default.post(name: .loginNotification, object: nil)
                                    }
                            case .failure(let err):
                                errorMessage = err.localizedDescription
                                showError = true
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
                            Text("Reset Password")
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
            Text("Forgot Password")
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
        ForgotPasswordResetView(emailOrPhone: "demo@example.com", resetToken: "dummy_token")
    }
}
