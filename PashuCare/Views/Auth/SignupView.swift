//
//  SignupView.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//


import SwiftUI

struct SignupView: View {

    @EnvironmentObject var router: NavigationRouter

    @State private var fullName: String = ""
    @State private var phoneOrEmail: String = ""
    @State private var farmName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""


    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Top Bar
            HStack {
                Button { router.pop() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 0.06, green: 0.65, blue: 0.29))
                        .frame(width: 44, height: 44, alignment: .leading)
                }

                Spacer()

                Text("Create Account")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(.label))

                Spacer()

                // balance spacing
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            Divider()
                .padding(.top, 10)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {

                    Spacer().frame(height: 26)

                    labeledField(
                        title: "Full Name",
                        icon: "person",
                        placeholder: "Enter your full name",
                        text: $fullName,
                        isSecure: false,
                        keyboard: .default
                    )
                    .onChange(of: fullName) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isLetter || $0.isWhitespace }
                        if filtered != newValue {
                            fullName = filtered
                        }
                    }

                    labeledField(
                        title: "Phone or Email",
                        icon: "envelope",
                        placeholder: "Enter phone or email",
                        text: $phoneOrEmail,
                        isSecure: false,
                        keyboard: .emailAddress
                    )
                    .onChange(of: phoneOrEmail) { oldValue, newValue in
                        if newValue.allSatisfy(\.isNumber) {
                            if newValue.count > 10 {
                                phoneOrEmail = String(newValue.prefix(10))
                            }
                            if newValue.count == 10 && newValue.allSatisfy({ $0 == newValue.first }) {
                                phoneOrEmail = ""
                                errorMessage = "Invalid phone number. All digits cannot be the same."
                                showError = true
                            }
                        }
                    }

                    labeledField(
                        title: "Farm Name",
                        icon: "house",
                        placeholder: "Enter your farm name",
                        text: $farmName,
                        isSecure: false,
                        keyboard: .default
                    )
                    .onChange(of: farmName) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isLetter || $0.isWhitespace }
                        if filtered != newValue {
                            farmName = filtered
                        }
                    }


                    labeledField(
                        title: "Password",
                        icon: "lock",
                        placeholder: "Create a password",
                        text: $password,
                        isSecure: true,
                        isPasswordVisible: $isPasswordVisible,
                        keyboard: .default
                    )

                    labeledField(
                        title: "Confirm Password",
                        icon: "lock",
                        placeholder: "Confirm your password",
                        text: $confirmPassword,
                        isSecure: true,
                        isPasswordVisible: $isConfirmPasswordVisible,
                        keyboard: .default
                    )

                    Spacer().frame(height: 22)

                    Button {
                        guard !fullName.isEmpty, !phoneOrEmail.isEmpty, !password.isEmpty else {
                            errorMessage = "Please fill in all required fields."
                            showError = true
                            return
                        }
                        
                        let contact = phoneOrEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                        let isPhone = contact.allSatisfy(\.isNumber)
                        
                        let namePattern = "^[a-zA-Z\\s]{2,}$"
                        let namePredicate = NSPredicate(format:"SELF MATCHES %@", namePattern)
                        
                        guard namePredicate.evaluate(with: fullName.trimmingCharacters(in: .whitespaces)) else {
                            errorMessage = "Full Name must contain only alphabets and be at least 2 characters."
                            showError = true
                            return
                        }
                        
                        guard namePredicate.evaluate(with: farmName.trimmingCharacters(in: .whitespaces)) else {
                            errorMessage = "Farm Name must contain only alphabets and be at least 2 characters."
                            showError = true
                            return
                        }

                        if isPhone {
                            guard contact.count == 10 else {
                                errorMessage = "Phone number must be exactly 10 digits."
                                showError = true
                                return
                            }
                            if contact.allSatisfy({ $0 == contact.first }) {
                                errorMessage = "Invalid phone number (too repetitive)."
                                showError = true
                                return
                            }
                            if !["6","7","8","9"].contains(String(contact.first!)) {
                                errorMessage = "Phone number must start with 6, 7, 8, or 9."
                                showError = true
                                return
                            }
                        } else {
                            let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)
                            guard emailPredicate.evaluate(with: contact) else {
                                errorMessage = "Please enter a valid email or a 10-digit phone number."
                                showError = true
                                return
                            }
                        }

                        guard password == confirmPassword else {
                            errorMessage = "Passwords do not match."
                            showError = true
                            return
                        }
                        
                        let passwordPattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#])[A-Za-z\\d$@$!%*?&#]{8,}"
                        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordPattern)
                        guard passwordPredicate.evaluate(with: password) else {
                            errorMessage = "Password must be at least 8 characters long and contain uppercase, lowercase, number, and special character."
                            showError = true
                            return
                        }

                        
                        isLoading = true
                        NetworkManager.shared.register(
                            fullName: fullName,
                            emailOrPhone: phoneOrEmail,
                            farmName: farmName,
                            password: password
                        ) { result in
                            isLoading = false
                            switch result {
                            case .success(let res):
                                if res.error != nil {
                                    errorMessage = res.error!
                                    showError = true
                                } else {
                                    // Navigate to Login screen instead of OTP
                                    router.pop()
                                }

                            case .failure(let err):
                                errorMessage = err.localizedDescription
                                showError = true
                            }
                        }
                    } label: {
                        Text("Create Account")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    }
                    .padding(.top, 10)
                    
                    // Already have an account? Login
                    HStack(spacing: 8) {
                        Text("Already have an account?")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.systemGray))

                        Button {
                            router.pop()
                        } label: {
                            Text("Login")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showError) {
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

    // MARK: - Reusable Labeled Field
    private func labeledField(
        title: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        isPasswordVisible: Binding<Bool>? = nil,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(.label))

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 26)

                if isSecure {
                    if let isVisible = isPasswordVisible {
                        if isVisible.wrappedValue {
                            TextField(placeholder, text: text)
                                .font(.system(size: 18))
                                .textInputAutocapitalization(.never)
                        } else {
                            SecureField(placeholder, text: text)
                                .font(.system(size: 18))
                        }
                        
                        Button {
                            isVisible.wrappedValue.toggle()
                        } label: {
                            Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(.systemGray3))
                                .frame(width: 34, height: 34)
                        }
                    } else {
                        SecureField(placeholder, text: text)
                            .font(.system(size: 18))
                    }
                } else {
                    TextField(placeholder, text: text)
                        .font(.system(size: 18))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(keyboard)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(.systemGray5), lineWidth: 1.2)
            )
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(NavigationRouter())
}
