//
//  SettingsModule.swift
//  PashuCare
//
//  Created by SAIL on 03/03/26.
//

import SwiftUI
import PhotosUI

// MARK: - Settings View (Tab-level)

struct SettingsView: View {
    @EnvironmentObject var router: NavigationRouter
    @State private var userName: String = "Loading..."
    @State private var farmName: String = "Loading..."
    @State private var isLoggedIn = true
    @State private var showDeleteConfirmation = false
    
    private func fetchProfile() {
        NetworkManager.shared.me { user in
            if let user = user {
                self.userName = user.full_name
                self.farmName = user.farm_name
            }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Premium Header Section
                ZStack(alignment: .top) {
                    // Top Gradient Background
                    LinearGradient(colors: [Color.green.opacity(0.12), Color.white], startPoint: .top, endPoint: .bottom)
                        .frame(height: 220)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.white, Color.green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 90, height: 90)
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                            
                            Text(String(userName.prefix(1)).uppercased())
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                        .padding(.top, 40)

                        VStack(spacing: 5) {
                            HStack(spacing: 6) {
                                Text(userName)
                                    .font(.system(size: 22, weight: .bold))
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16))
                            }
                            
                            Text(farmName)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.bottom, 35)

                VStack(spacing: 22) {
                    settingsSection {
                        settingsRow(icon: "person.crop.circle.fill", iconColor: .blue, title: "Profile Settings") {
                            router.push(.profileSettings)
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        settingsRow(icon: "book.pages.fill", iconColor: .blue, title: "User Guide") {
                            router.push(.userGuide)
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        settingsRow(icon: "lock.shield.fill", iconColor: .green, title: "Privacy Policy") {
                            router.push(.privacyPolicy)
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        settingsRow(icon: "doc.text.fill", iconColor: .orange, title: "Terms of Service") {
                            router.push(.termsOfService)
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        settingsRow(icon: "questionmark.circle.fill", iconColor: .green, title: "Help & Support") {
                            router.push(.helpSupport)
                        }
                    }

                    settingsSection {
                        settingsRow(icon: "arrow.right.square.fill", iconColor: .red, title: "Logout",
                                    titleColor: .red, showChevron: false) {
                            NotificationCenter.default.post(name: .logoutNotification, object: nil)
                        }
                    }

                    settingsSection {
                        settingsRow(icon: "trash.fill", iconColor: .red, title: "Delete Account",
                                    titleColor: .red, showChevron: false) {
                            showDeleteConfirmation = true
                        }
                    }
                }
                .padding(.horizontal, 18)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchProfile()
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete your account? This action is permanent and will remove all your data.")
        }
    }

    private func deleteAccount() {
        NetworkManager.shared.deleteAccount { success in
            if success {
                NotificationCenter.default.post(name: .logoutNotification, object: nil)
            }
        }
    }


    @ViewBuilder
    private func settingsSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    @ViewBuilder
    private func settingsRow(icon: String, iconColor: Color, title: String,
                              titleColor: Color = .primary,
                              showChevron: Bool = true,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(titleColor)

                Spacer()

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Settings View

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var fullName: String = "Loading..."
    @State private var farmName: String = "Loading..."
    @State private var email: String = "Loading..."
    @State private var phone: String = "Loading..."
    @State private var showSaved = false
    @State private var isLoading = false
    @State private var profileImage: UIImage? = nil
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var showPhotoPicker = false
    
    // Validation computed properties
    private var isFullNameValid: Bool {
        let pattern = "^[a-zA-Z\\s]{2,}$"
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2 && fullName.range(of: pattern, options: .regularExpression) != nil
    }
    
    private var isFarmNameValid: Bool {
        let pattern = "^[a-zA-Z\\s]{2,}$"
        let trimmed = farmName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2 && farmName.range(of: pattern, options: .regularExpression) != nil
    }


    
    private var isEmailValid: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    private var isPhoneValid: Bool {
        let digits = phone.filter { $0.isNumber }
        guard digits.count == 10 else { return false }
        
        // Prevent all same digits like 9999999999
        let firstDigit = digits.first
        if digits.allSatisfy({ $0 == firstDigit }) { return false }
        
        // Ensure it starts with 6, 7, 8, or 9 (Indian Mobile Standard)
        guard let firstChar = digits.first, let firstValue = Int(String(firstChar)), (6...9).contains(firstValue) else {
            return false
        }
        
        return true
    }

    
    private var isFormValid: Bool {
        isFullNameValid && isFarmNameValid && isEmailValid && isPhoneValid
    }
    
    private func fetchProfile() {
        NetworkManager.shared.me { user in
            if let user = user {
                self.fullName = user.full_name
                self.farmName = user.farm_name
                self.email = user.email_or_phone
                self.phone = user.phone ?? ""
            }
        }
    }

    private func saveProfile() {
        isLoading = true
        NetworkManager.shared.updateProfile(
            fullName: fullName,
            farmName: farmName,
            email: email,
            phone: phone
        ) { success in
            isLoading = false
            if success {
                showSaved = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
                    showSaved = false 
                    dismiss()
                }
            } else {
                // Handle error if needed
            }
        }
    }

    // Removed @State private var isLoading = false as it was moved up

    @State private var appearAnimated = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Soft gradient background matching screenshot
            LinearGradient(
                colors: [Color(red: 0.91, green: 0.95, blue: 1.0), Color(red: 0.95, green: 0.96, blue: 0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .top) {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.10), Color(red: 0.95, green: 0.96, blue: 0.98).opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 160)
                    .ignoresSafeArea()

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                )
                        }

                        Spacer()

                        Text("Edit Profile")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.85))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                .padding(.bottom, -60)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Avatar (Premium)
                        Button {
                            showPhotoPicker = true
                        } label: {
                            ZStack {
                                // Outer glow ring
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color.blue.opacity(0.08), Color.blue.opacity(0.02), Color.clear],
                                            center: .center,
                                            startRadius: 50,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 140, height: 140)

                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.08), Color.blue.opacity(0.04)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .shadow(color: Color.blue.opacity(0.08), radius: 15, x: 0, y: 8)

                                if let img = profileImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    Text(String(fullName.prefix(1)).uppercased())
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.blue.opacity(0.6))
                                }

                                // Camera Badge
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 34, height: 34)
                                                .shadow(color: Color.blue.opacity(0.35), radius: 8, x: 0, y: 4)
                                            
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2.5)
                                                .frame(width: 34, height: 34)

                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .frame(width: 110, height: 110)
                            }
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(appearAnimated ? 1.0 : 0.85)
                        .opacity(appearAnimated ? 1.0 : 0.0)
                        .padding(.top, 10)
                        .photosPicker(isPresented: $showPhotoPicker, selection: $photoPickerItem, matching: .images)
                        .onChange(of: photoPickerItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    await MainActor.run {
                                        profileImage = uiImage
                                    }
                                }
                            }
                        }

                        // Form Fields
                        VStack(spacing: 16) {
                            profileField(icon: "person.fill", label: "Full Name", placeholder: "Enter your name", text: $fullName, isValid: isFullNameValid, index: 0)
                                .onChange(of: fullName) { oldValue, newValue in
                                    if newValue != "Loading..." {
                                        let filtered = newValue.filter { $0.isLetter || $0.isWhitespace }
                                        if filtered != newValue {
                                            fullName = filtered
                                        }
                                    }
                                }
                            profileField(icon: "house.fill", label: "Farm Name", placeholder: "Farm name", text: $farmName, isValid: isFarmNameValid, index: 1)
                                .onChange(of: farmName) { oldValue, newValue in
                                    if newValue != "Loading..." {
                                        let filtered = newValue.filter { $0.isLetter || $0.isWhitespace }
                                        if filtered != newValue {
                                            farmName = filtered
                                        }
                                    }
                                }
                            profileField(icon: "envelope.fill", label: "Email Address", placeholder: "email@example.com", text: $email, isValid: isEmailValid, keyboard: .emailAddress, index: 2)
                            profileField(icon: "phone.fill", label: "Phone Number", placeholder: "98765 43210", text: $phone, isValid: isPhoneValid, keyboard: .phonePad, index: 3)
                        }
                        .padding(.horizontal, 20)

                        if showSaved {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Profile updated successfully!")
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.4))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.2, green: 0.7, blue: 0.4).opacity(0.08))
                            .cornerRadius(16)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                                removal: .opacity
                            ))
                        }

                        Spacer().frame(height: 90)
                    }
                }
            }

            // Bottom Save Button with elegant fade
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.96, blue: 0.98).opacity(0), Color(red: 0.95, green: 0.96, blue: 0.98)],
                    startPoint: .top,
                    endPoint: .center
                )
                .frame(height: 40)
                .allowsHitTesting(false)

                Button {
                    saveProfile()
                } label: {
                    HStack(spacing: 10) {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                        }
                        Text(isLoading ? "Saving..." : "Save Changes")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        Group {
                            if isFormValid {
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.45), Color.gray.opacity(0.35)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .cornerRadius(29)
                    .shadow(color: isFormValid ? Color.blue.opacity(0.25) : Color.clear, radius: 14, x: 0, y: 8)
                }
                .disabled(isLoading || !isFormValid)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .background(Color(red: 0.95, green: 0.96, blue: 0.98))
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            fetchProfile()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appearAnimated = true
            }
        }
    }

    @ViewBuilder
    private func profileField(icon: String, label: String, placeholder: String, text: Binding<String>,
                                isValid: Bool,
                                keyboard: UIKeyboardType = .default,
                                index: Int = 0) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(0.3)
                
                Spacer()
                
                if !isValid && !text.wrappedValue.isEmpty && text.wrappedValue != "Loading..." {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                        Text("Invalid")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.red.opacity(0.8))
                    .transition(.opacity)
                }
            }
            .padding(.leading, 4)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill((isValid || text.wrappedValue.isEmpty || text.wrappedValue == "Loading...") ? Color.blue.opacity(0.08) : Color.red.opacity(0.08))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor((isValid || text.wrappedValue.isEmpty || text.wrappedValue == "Loading...") ? .blue : .red)
                }
                
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.96, green: 0.97, blue: 0.98))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        (isValid || text.wrappedValue.isEmpty || text.wrappedValue == "Loading...") 
                            ? Color.white.opacity(0.6) 
                            : Color.red.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .offset(y: appearAnimated ? 0 : 20)
        .opacity(appearAnimated ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08), value: appearAnimated)
    }
}

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var criticalAlerts = true
    @State private var dailyReminders = true
    @State private var weeklyReports = false
    @State private var appUpdates = true

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .top) {
                    LinearGradient(colors: [Color.blue.opacity(0.12), Color.white], startPoint: .top, endPoint: .bottom)
                        .frame(height: 180)
                        .ignoresSafeArea()

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }

                        Spacer()

                        Text("Notifications")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.85))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                .padding(.bottom, -60)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        notifSection(
                            title: "Critical Alerts",
                            description: "Get notified about health issues and emergencies",
                            binding: $criticalAlerts
                        )
                        
                        notifSection(
                            title: "Daily Reminders",
                            description: "Feeding schedules and vaccination due dates",
                            binding: $dailyReminders
                        )
                        
                        notifSection(
                            title: "Weekly Reports",
                            description: "Summary of milk production and farm health",
                            binding: $weeklyReports
                        )
                        
                        notifSection(
                            title: "App Updates",
                            description: "New features and system improvements",
                            binding: $appUpdates
                        )
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private func notifSection(title: String, description: String, binding: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.8))
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Toggle("", isOn: binding)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .labelsHidden()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Help & Support View

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header (Premium)
                ZStack(alignment: .top) {
                    LinearGradient(colors: [Color.blue.opacity(0.12), Color.white], startPoint: .top, endPoint: .bottom)
                        .frame(height: 180)
                        .ignoresSafeArea()

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }

                        Spacer()

                        Text("Help & Support")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.85))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                .padding(.bottom, -60)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        helpModule(icon: "envelope.fill", iconColor: .blue, title: "Email Support", subtitle: "pashucareai@gmil.com") {
                            if let url = URL(string: "mailto:pashucareai@gmil.com") {
                                UIApplication.shared.open(url)
                            }
                        }

                        VStack(spacing: 6) {
                            Text("App Version 1.0.0")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            Text("© 2026 PashuCare")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private func helpModule(icon: String, iconColor: Color, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - User Guide View
struct UserGuideView: View {
    @Environment(\.dismiss) private var dismiss

    private let sections: [(icon: String, color: Color, title: String, body: String)] = [
        ("house.fill", .blue, "Dashboard", "The Home screen gives you a quick overview of your farm. See total animals, milk production stats, and recent transactions at a glance."),
        ("pawprint.fill", .blue, "Animals", "Access the Animals module from the Dashboard. Add new animals, view health records, vaccination history, and track each animal's status."),
        ("mug.fill", .blue, "Milk Production", "Log daily milk yield per animal. View total production summaries, graphs, and historical data over time."),
        ("fork.knife", .blue, "Feeding", "Manage feeding schedules and feed stock. Add feeding entries and monitor dietary patterns for each batch."),
        ("cross.case.fill", .blue, "Sanitation", "Track sanitation activities. Use the checklist to ensure your farm meets hygiene standards regularly."),
        ("arrow.left.arrow.right", .blue, "Transactions", "Record income and expenses. Use the Income/Expense segments to log payments, sales, and costs. View summaries in Reports."),
        ("doc.text.fill", .blue, "Reports", "The Reports tab aggregates your farm data — health records, milk production, transactions — in one place."),
        ("viewfinder", .blue, "AI Disease Prediction", "Use the AI tool from the Dashboard to capture or upload an image of your cattle. The AI will analyze the image and suggest a possible diagnosis with precautions."),
    ]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .top) {
                    LinearGradient(colors: [Color.blue.opacity(0.12), Color.white], startPoint: .top, endPoint: .bottom)
                        .frame(height: 180)
                        .ignoresSafeArea()

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }

                        Spacer()

                        Text("User Guide")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.85))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                .padding(.bottom, -60)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(sections, id: \.title) { section in
                            HStack(alignment: .top, spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(section.color.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: section.icon)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(section.color)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(section.title)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(.black.opacity(0.8))
                                    Text(section.body)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(22)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .top) {
                    LinearGradient(colors: [Color.blue.opacity(0.12), Color.white], startPoint: .top, endPoint: .bottom)
                        .frame(height: 180)
                        .ignoresSafeArea()

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }

                        Spacer()

                        Text("Privacy Policy")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.85))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                .padding(.bottom, -60)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        policySection(title: "Information We Collect", body: "PashuCare collects information you provide directly, such as your farm details, animal records, milk logs, and transaction data. We also collect usage data to improve the app experience.")

                        policySection(title: "How We Use Your Information", body: "We use your data solely to provide core app functionality — managing your farm, animals, and reports. We do not sell or share your personal information with third parties.")

                        policySection(title: "Data Storage & Security", body: "All your data is stored securely on your device using encrypted local storage. Cloud sync features, if enabled, use industry-standard encryption protocols.")

                        policySection(title: "AI Predictions", body: "Images uploaded for AI disease prediction are processed temporarily and are not stored permanently on our servers. Results are generated in real time and saved only on your device.")

                        policySection(title: "Your Rights", body: "You may delete your data at any time by clearing app data or uninstalling the application. You may contact us at support@pashucare.in for data-related requests.")

                        policySection(title: "Updates to This Policy", body: "We may update this Privacy Policy from time to time. Continued use of the app after changes constitutes acceptance of the updated policy.")

                        Text("Last updated: March 2026")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                            .padding(.leading, 10)
                    }
                    .padding(20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.black.opacity(0.8))
            Text(body)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .top) {
                    LinearGradient(colors: [Color.blue.opacity(0.12), Color.white], startPoint: .top, endPoint: .bottom)
                        .frame(height: 180)
                        .ignoresSafeArea()

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }

                        Spacer()

                        Text("Terms of Service")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.85))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                .padding(.bottom, -60)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        policySection(title: "Acceptance of Terms", body: "By downloading or using PashuCare, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.")

                        policySection(title: "Use of the Application", body: "PashuCare is intended for farm management use only. You agree not to misuse the application, reverse-engineer it, or use it for any unlawful purposes.")

                        policySection(title: "AI Disclaimer", body: "The AI Disease Prediction feature provides suggestions based on image analysis. These are not a substitute for professional veterinary advice. Always consult a licensed veterinarian for medical decisions.")

                        policySection(title: "Intellectual Property", body: "All content, features, and functionality of PashuCare are the exclusive property of PashuCare Technologies. You may not copy or redistribute any part of the app without permission.")

                        policySection(title: "Limitation of Liability", body: "PashuCare is provided 'as is' without warranties of any kind. We are not liable for any direct or indirect losses arising from the use of the application.")

                        policySection(title: "Changes to Terms", body: "We reserve the right to modify these terms at any time. Continued use of PashuCare constitutes your acceptance of any changes.")

                        policySection(title: "Contact", body: "For any questions about these terms, please contact us at legal@pashucare.in")

                        Text("Effective: March 2026")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                            .padding(.leading, 10)
                    }
                    .padding(20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.black.opacity(0.8))
            Text(body)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(NavigationRouter())
    }
}
