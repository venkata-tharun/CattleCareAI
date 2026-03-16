//
//  SettingsModule.swift
//  PashuCare
//
//  Created by SAIL on 03/03/26.
//

import SwiftUI

// MARK: - Settings View (Tab-level)

struct SettingsView: View {
    @EnvironmentObject var router: NavigationRouter
    @State private var userName: String = "Loading..."
    @State private var farmName: String = "Loading..."
    @State private var isLoggedIn = true
    
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
                // Profile Header (Premium Look)
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.green.opacity(0.1), Color.green.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                        
                        Text(String(userName.prefix(1)).uppercased())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 4) {
                        Text(userName)
                            .font(.system(size: 20, weight: .bold))
                        Text(farmName)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 30)
                .background(Color.white)

                // Settings Menu
                VStack(spacing: 20) {
                    settingsSection {
                        settingsRow(icon: "person.fill", iconColor: .blue, title: "Profile Settings") {
                            router.push(.profileSettings)
                        }
                        
                        Divider().padding(.leading, 56)
                        
                        // Notifications removed as per user request
                        
                        settingsRow(icon: "questionmark.circle.fill", iconColor: .green, title: "Help & Support") {
                            router.push(.helpSupport)
                        }
                    }

                    settingsSection {
                        settingsRow(icon: "rectangle.portrait.and.arrow.right", iconColor: .red, title: "Logout",
                                    titleColor: .red, showChevron: false) {
                            NotificationCenter.default.post(name: .logoutNotification, object: nil)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchProfile()
        }
    }

    @ViewBuilder
    private func settingsSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    @ViewBuilder
    private func settingsRow(icon: String, iconColor: Color, title: String,
                              titleColor: Color = .primary,
                              showChevron: Bool = true,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 16, weight: .medium))
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

    @State private var isLoading = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header (Premium)
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Edit Profile")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Avatar (Premium)
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Text(String(fullName.prefix(1)).uppercased())
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.green)
                            
                            // Edit Badge
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    ZStack {
                                        Circle().fill(Color.green).frame(width: 32, height: 32)
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .frame(width: 100, height: 100)
                        }
                        .padding(.top, 20)

                        // Form
                        VStack(spacing: 20) {
                            profileField(icon: "person.fill", label: "Full Name", text: $fullName)
                            profileField(icon: "house.fill", label: "Farm Name", text: $farmName)
                            profileField(icon: "envelope.fill", label: "Email Address", text: $email, keyboard: .emailAddress)
                            profileField(icon: "phone.fill", label: "Phone Number", text: $phone, keyboard: .phonePad)
                        }
                        .padding(.horizontal, 16)

                        if showSaved {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Profile updated successfully!")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        Spacer().frame(height: 100)
                    }
                }
            }

            // Bottom Save Button
            VStack(spacing: 0) {
                Divider()
                Button {
                    saveProfile()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.white).padding(.trailing, 8)
                        }
                        Text(isLoading ? "Saving..." : "Save Changes")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.green)
                    .cornerRadius(16)
                    .padding(16)
                    .padding(.bottom, 8)
                }
                .disabled(isLoading)
                .background(Color.white)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            fetchProfile()
        }
    }

    @ViewBuilder
    private func profileField(icon: String, label: String, text: Binding<String>,
                               keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                TextField(label, text: text)
                    .keyboardType(keyboard)
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
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
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Notifications")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        notifSection(
                            title: "Critical Alerts",
                            description: "Get notified about health issues and emergencies",
                            label: "Enable Alerts",
                            binding: $criticalAlerts
                        )
                        Divider().padding(.leading, 16)
                        notifSection(
                            title: "Daily Reminders",
                            description: "Feeding schedules and vaccination due dates",
                            label: "Enable Reminders",
                            binding: $dailyReminders
                        )
                        Divider().padding(.leading, 16)
                        notifSection(
                            title: "Weekly Reports",
                            description: "Summary of milk production and farm health",
                            label: "Email Reports",
                            binding: $weeklyReports
                        )
                        Divider().padding(.leading, 16)
                        notifSection(
                            title: "App Updates",
                            description: "New features and system improvements",
                            label: "System Updates",
                            binding: $appUpdates
                        )
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private func notifSection(title: String, description: String, label: String, binding: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: binding)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .labelsHidden()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// MARK: - Help & Support View

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateTo: HelpDestination? = nil

    enum HelpDestination: Identifiable {
        case userGuide, privacy, terms
        var id: Int { hashValue }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Help & Support")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        helpModule(icon: "book.fill", iconColor: .blue, title: "User Guide", subtitle: "Learn how to use PashuCare") {
                            navigateTo = .userGuide
                        }
                        
                        helpModule(icon: "lock.shield.fill", iconColor: .green, title: "Privacy Policy", subtitle: "How we protect your data") {
                            navigateTo = .privacy
                        }
                        
                        helpModule(icon: "doc.plaintext.fill", iconColor: .orange, title: "Terms of Service", subtitle: "App usage terms & conditions") {
                            navigateTo = .terms
                        }

                        VStack(spacing: 6) {
                            Text("App Version 1.0.0")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("© 2026 PashuCare")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: Binding(
            get: { navigateTo != nil },
            set: { if !$0 { navigateTo = nil } }
        )) {
            switch navigateTo {
            case .userGuide: UserGuideView()
            case .privacy: PrivacyPolicyView()
            case .terms: TermsOfServiceView()
            case nil: EmptyView()
            }
        }
    }

    @ViewBuilder
    private func helpModule(icon: String, iconColor: Color, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func helpSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            content()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    @ViewBuilder
    private func helpRow(icon: String, iconColor: Color, title: String, subtitle: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - User Guide View
struct UserGuideView: View {
    @Environment(\.dismiss) private var dismiss

    private let sections: [(icon: String, color: Color, title: String, body: String)] = [
        ("house.fill", .green, "Dashboard", "The Home screen gives you a quick overview of your farm. See total animals, milk production stats, and recent transactions at a glance."),
        ("pawprint.fill", .orange, "Animals", "Access the Animals module from the Dashboard. Add new animals, view health records, vaccination history, and track each animal's status."),
        ("mug.fill", .blue, "Milk Production", "Log daily milk yield per animal. View total production summaries, graphs, and historical data over time."),
        ("fork.knife", .purple, "Feeding", "Manage feeding schedules and feed stock. Add feeding entries and monitor dietary patterns for each batch."),
        ("cross.case.fill", .teal, "Sanitation", "Track sanitation activities. Use the checklist to ensure your farm meets hygiene standards regularly."),
        ("arrow.left.arrow.right", .cyan, "Transactions", "Record income and expenses. Use the Income/Expense segments to log payments, sales, and costs. View summaries in Reports."),
        ("doc.text.fill", .indigo, "Reports", "The Reports tab aggregates your farm data — health records, milk production, transactions — in one place."),
        ("viewfinder", .red, "AI Disease Prediction", "Use the AI tool from the Dashboard to capture or upload an image of your cattle. The AI will analyze the image and suggest a possible diagnosis with precautions."),
    ]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("User Guide")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(sections, id: \.title) { section in
                            HStack(alignment: .top, spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(section.color.opacity(0.13))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: section.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(section.color)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(section.title)
                                        .font(.system(size: 16, weight: .bold))
                                    Text(section.body)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(16)
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
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Privacy Policy")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        policySection(title: "Information We Collect", body: "PashuCare collects information you provide directly, such as your farm details, animal records, milk logs, and transaction data. We also collect usage data to improve the app experience.")

                        policySection(title: "How We Use Your Information", body: "We use your data solely to provide core app functionality — managing your farm, animals, and reports. We do not sell or share your personal information with third parties.")

                        policySection(title: "Data Storage & Security", body: "All your data is stored securely on your device using encrypted local storage. Cloud sync features, if enabled, use industry-standard encryption protocols.")

                        policySection(title: "AI Predictions", body: "Images uploaded for AI disease prediction are processed temporarily and are not stored permanently on our servers. Results are generated in real time and saved only on your device.")

                        policySection(title: "Your Rights", body: "You may delete your data at any time by clearing app data or uninstalling the application. You may contact us at support@pashucare.in for data-related requests.")

                        policySection(title: "Updates to This Policy", body: "We may update this Privacy Policy from time to time. Continued use of the app after changes constitutes acceptance of the updated policy.")

                        Text("Last updated: March 2026")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(16)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
            Text(body)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Terms of Service")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        policySection(title: "Acceptance of Terms", body: "By downloading or using PashuCare, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.")

                        policySection(title: "Use of the Application", body: "PashuCare is intended for farm management use only. You agree not to misuse the application, reverse-engineer it, or use it for any unlawful purposes.")

                        policySection(title: "AI Disclaimer", body: "The AI Disease Prediction feature provides suggestions based on image analysis. These are not a substitute for professional veterinary advice. Always consult a licensed veterinarian for medical decisions.")

                        policySection(title: "Intellectual Property", body: "All content, features, and functionality of PashuCare are the exclusive property of PashuCare Technologies. You may not copy or redistribute any part of the app without permission.")

                        policySection(title: "Limitation of Liability", body: "PashuCare is provided 'as is' without warranties of any kind. We are not liable for any direct or indirect losses arising from the use of the application.")

                        policySection(title: "Changes to Terms", body: "We reserve the right to modify these terms at any time. Continued use of PashuCare constitutes your acceptance of any changes.")

                        policySection(title: "Contact", body: "For any questions about these terms, please contact us at legal@pashucare.in")

                        Text("Effective: March 2026")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(16)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
            Text(body)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(NavigationRouter())
    }
}
