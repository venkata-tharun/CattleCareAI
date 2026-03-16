//
//  LoginView.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var router: NavigationRouter
    @Binding var isLoggedIn: Bool // Add this binding
    
    @State private var emailOrPhone: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    init(isLoggedIn: Binding<Bool> = .constant(false)) {
        self._isLoggedIn = isLoggedIn
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    // MARK: - Logo
                    ZStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 150)
                            .foregroundColor(.green)
                    }

                    Spacer().frame(height: 26)

                    // MARK: - Headline + Subtitle
                    Text("Welcome Back!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(.label))

                    Spacer().frame(height: 10)

                    Text("Sign in to continue managing your farm.")
                        .font(.system(size: 18))
                        .foregroundColor(Color(.systemGray))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 34)

                    // MARK: - Fields
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Phone or Email")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(.label))

                        inputField(
                            icon: "envelope.fill",
                            placeholder: "Enter your phone or email",
                            text: $emailOrPhone,
                            isSecure: false,
                            trailing: nil
                        )

                        Spacer().frame(height: 14)

                        Text("Password")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(.label))

                        passwordField()

                        // Forgot password
                        HStack {
                            Spacer()
                            Button(action: {
                                router.push(.forgotpassword)
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 26)

    // MARK: - Login Button
    Button(action: {
        guard !emailOrPhone.isEmpty, !password.isEmpty else { return }
        isLoading = true
        NetworkManager.shared.login(emailOrPhone: emailOrPhone, password: password) { result in
            isLoading = false
            switch result {
            case .success(let response):
                if let user = response.user {
                    // Persist user details locally for display
                    UserDefaults.standard.set(user.full_name, forKey: "userName")
                    UserDefaults.standard.set(user.farm_name, forKey: "farmName")
                    UserDefaults.standard.set(user.email_or_phone, forKey: "userEmail")
                    UserDefaults.standard.set(user.id, forKey: "userId")
                    withAnimation { isLoggedIn = true }
                } else {
                    errorMessage = response.error ?? "Invalid credentials"
                    showError = true
                }
            case .failure(let err):
                errorMessage = err.localizedDescription
                showError = true
            }
        }
    }) {
                        Text("Login")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 36)

                    // MARK: - Bottom Create Account
                    HStack(spacing: 8) {
                        Text("Don't have an account?")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.systemGray))

                        Button {
                            router.push(.createaccount)
                        } label: {
                            Text("Create Account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.bottom, 22)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert("Login Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .overlay {
            if isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
    }

    // MARK: - Reusable Input Field
    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        trailing: AnyView?
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(.systemGray))
                .frame(width: 28)

            if isSecure {
                SecureField(placeholder, text: text)
                    .font(.system(size: 18))
            } else {
                TextField(placeholder, text: text)
                    .font(.system(size: 18))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
            }

            if let trailing {
                trailing
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Password Field
    private func passwordField() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(.systemGray))
                .frame(width: 28)

            Group {
                if isPasswordVisible {
                    TextField("Enter your password", text: $password)
                        .font(.system(size: 18))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } else {
                    SecureField("Enter your password", text: $password)
                        .font(.system(size: 18))
                }
            }

            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 34, height: 34)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(NavigationRouter())
    }
}
