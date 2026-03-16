import SwiftUI
import Combine

struct FarmDashboardView: View {

    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var animalManager: AnimalDataManager
    
    // Make these @State so they can be updated
    @State private var userName: String = "Loading..."
    @State private var milkToday: String = "0L"
    @State private var isLoading: Bool = true
    
    // Animation state
    @State private var isAnimating = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Static Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good Morning, \(userName) 👋")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.85))
                            
                            Text("Let's manage your farm today")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Animated Cow Image
                        Image("happy_cow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .offset(y: isAnimating ? -8 : 8)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 10)
                            .onAppear {
                                isAnimating = true
                            }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        
                             StatsCapsule(
                                totalAnimals: animalManager.animals.count,
                                milkToday: milkToday
                            )
                            .padding(.top, 6)

                            FeatureGrid(router: router) // Pass router to FeatureGrid

                            Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 12)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            loadDashboardData()
        }
    }
    
    // MARK: - Load Data
    private func loadDashboardData() {
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? "User"
        
        NetworkManager.shared.me { user in
            if let user = user {
                self.userName = user.full_name
            }
        }
        
        // Fetch dynamic stats from backend
        NetworkManager.shared.fetchDashboardStats { stats in
            if let stats = stats {
                let milk = stats.milkToday
                self.milkToday = milk
                UserDefaults.standard.set(milk, forKey: "milkToday")
            }
            self.isLoading = false
        }
        
        // ensure animals are fetched
        animalManager.fetchAnimals()
    }
}


// MARK: - Stats Capsule
private struct StatsCapsule: View {
    let totalAnimals: Int
    let milkToday: String

    var body: some View {
        HStack(spacing: 0) {
            statItem(title: "Total Animals", value: "\(totalAnimals)", valueColor: .black)
            divider
            statItem(title: "Milk Today", value: milkToday, valueColor: .blue)
        }
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.green.opacity(0.35), lineWidth: 1.5)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.green.opacity(0.35))
            .frame(width: 1, height: 46)
            .padding(.horizontal, 14)
    }

    private func statItem(title: String, value: String, valueColor: Color) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Feature Grid (3 x 2)
private struct FeatureGrid: View {
    let router: NavigationRouter // Add router parameter

    private let items: [FeatureTileModel] = [
        .init(title: "Milk\nProduction", systemIcon: "mug.fill", border: .blue, route: .milkRecordList),
        .init(title: "Animals", systemIcon: "pawprint.fill", border: .red, route: .animalsList),
        .init(title: "Visitors", systemIcon: "person.2.fill", border: .purple, route: .visitors),
        .init(title: "Sanitation", systemIcon: "cross.case.fill", border: .teal, route: .sanitation),
        .init(title: "Biosecurity", systemIcon: "shield.checkerboard", border: .orange, route: .biosecurityCheck),
        .init(title: "Feeding", systemIcon: "fork.knife", border: .orange, route: .feeding),
        .init(title: "Reports", systemIcon: "doc.text.fill", border: .blue, route: .reportsList),
        .init(title: "Calving\nTracker", systemIcon: "calendar.badge.clock", border: Color(red: 0.18, green: 0.49, blue: 0.20), route: .calvingTrackerHome),
        .init(title: "Transactions", systemIcon: "indianrupeesign.circle.fill", border: .teal, route: .transactions)
    ]

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(items) { item in
                FeatureTile(item: item, router: router) // Pass router to each tile
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Updated FeatureTileModel with Route
private struct FeatureTileModel: Identifiable {
    let id = UUID()
    let title: String
    let systemIcon: String
    let border: Color
    let route: AppRoute // Add route for navigation
}

// MARK: - Updated FeatureTile with Navigation
private struct FeatureTile: View {
    let item: FeatureTileModel
    let router: NavigationRouter
    @EnvironmentObject var tabRouter: TabRouter // For tab switching

    var body: some View {
        Button {
            // Handle navigation based on the feature
            switch item.route {
            case .reportsList:
                // Switch to reports tab for reports
                tabRouter.select(.reports)
            default:
                // Push new view for other features
                router.push(item.route)
            }
        } label: {
            VStack(spacing: 10) {
                Image(systemName: item.systemIcon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(item.border)
                    .frame(width: 56, height: 56)

                Text(item.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .frame(height: 132)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(item.border.opacity(0.55), lineWidth: 1.4)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

