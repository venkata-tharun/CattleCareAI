//
//  ForgotPasswordView.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//


import SwiftUI

struct ForgotPasswordView: View {

    @EnvironmentObject var router: NavigationRouter
    @State private var phoneOrEmail: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Top Bar
            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Text("Forgot Password")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(.label))

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            Divider()
                .padding(.top, 10)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Spacer().frame(height: 46)

                    Text("Reset Password")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(.label))
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 14)

                    Text("Enter your email or phone to receive a\nreset code.")
                        .font(.system(size: 18))
                        .foregroundColor(Color(.systemGray))
                        .lineSpacing(6)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 42)

                    // MARK: - Field Label
                    Text("Phone or Email")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(.label))
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 12)

                    // MARK: - Input
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(.systemGray3))
                            .frame(width: 26)

                        TextField("Enter your phone or email", text: $phoneOrEmail)
                            .font(.system(size: 18))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 64)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(.systemGray5), lineWidth: 1.2)
                    )
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 22)

                    // MARK: - Send OTP Button
                    Button {
                        withAnimation { isLoading = true }
                        
                        NetworkManager.shared.forgotPassword(emailOrPhone: phoneOrEmail) { result in
                            isLoading = false
                            switch result {
                            case .success(let res):
                                if res.error != nil {
                                    errorMessage = res.error!
                                    showError = true
                                } else {
                                    router.push(.otp(phoneOrEmail, false))
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
                                .frame(height: 64)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        } else {
                            Text("Send OTP")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        }
                    }
                    .disabled(isLoading || phoneOrEmail.isEmpty)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 40)
                }
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(NavigationRouter())
}
