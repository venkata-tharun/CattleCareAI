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

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.95, green: 0.96, blue: 0.98).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Premium Header Section
                ZStack(alignment: .bottom) {
                    LinearGradient(colors: [Color.green.opacity(0.18), Color(red: 0.95, green: 0.96, blue: 0.98)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 140)
                        .ignoresSafeArea()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(greeting), \(userName) 👋")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(Color.black.opacity(0.85))
                            
                            Text("Let's manage your farm today")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image("happy_cow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 85, height: 85)
                            .offset(y: isAnimating ? -6 : 6)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 12)
                            .onAppear { isAnimating = true }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // New Modern Stats Cards
                        HStack(spacing: 16) {
                            StatCard(title: "Total Animals", value: "\(animalManager.animals.count)", icon: "pawprint.circle.fill", color: .green)
                            StatCard(title: "Milk Today", value: milkToday, icon: "drop.circle.fill", color: .blue)
                        }
                        .padding(.top, 10)

                        FeatureGrid(router: router)

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
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


// MARK: - Modern Stat Card
private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.85))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Feature Grid (3 x 2)
private struct FeatureGrid: View {
    let router: NavigationRouter

    private let items: [FeatureTileModel] = [
        .init(title: "Animals", systemIcon: "pawprint.fill", border: .red, route: .animalsList),
        .init(title: "Milk\nProduction", systemIcon: "mug.fill", border: .blue, route: .milkRecordList),
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
                FeatureTile(item: item, router: router)
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
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(item.border.opacity(0.08))
                        .frame(width: 48, height: 48)
                    Image(systemName: item.systemIcon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(item.border)
                }

                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 4)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 115)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(item.border.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

