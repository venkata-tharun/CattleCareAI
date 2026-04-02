import SwiftUI

// MARK: - Models

enum FeedTime: String, CaseIterable, Identifiable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    var id: String { rawValue }
}

enum AnimalType: String, CaseIterable, Identifiable {
    case cow = "Cow"
    case buffalo = "Buffalo"
    case calf = "Calf / Heifer"
    case bull = "Bull"
    case herd = "Entire Herd"
    var id: String { rawValue }
}

enum FeedType: String, CaseIterable, Identifiable {
    case mixedRation = "Mixed Ration (TMR)"
    case silage = "Silage"
    case concentrate = "Concentrate"
    case hay = "Hay / Dry Fodder"
    case greenFodder = "Green Fodder"
    var id: String { rawValue }
}

struct FeedingEntry: Identifiable {
    let id = UUID()
    let date: String
    let time: FeedTime
    let feedType: FeedType
    let targetGroup: String
    let quantity: Double
    let notes: String
}

struct FeedStockItem: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    var quantityValue: Double
    var status: FeedStockStatus
    
    var quantityDisplay: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: quantityValue)) ?? "\(quantityValue)"
        return "\(formatted) kg"
    }
    
    init(id: UUID = UUID(), name: String, quantityValue: Double, status: FeedStockStatus) {
        self.id = id
        self.name = name
        self.quantityValue = quantityValue
        self.status = status
    }
}

enum FeedStockStatus: String, Codable, CaseIterable {
    case good = "Good"
    case medium = "Medium"
    case low = "Low"

    var barColor: Color {
        switch self {
        case .good: return .green
        case .medium: return .green // Keep medium green as well to maintain calm ui
        case .low: return Color.yellow // User specifically requested yellow for low stock, NO RED.
        }
    }
    
    var color: Color { barColor }
}

struct FeedingScheduleItem: Identifiable {
    let id: Int
    let time: String
    let title: String
    let items: [String]
    var isCompleted: Bool = false
}

// MARK: - Feeding Hub View
struct FeedingHubView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var feedManager: FeedDataManager
    @State private var appearAnimated = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.95, green: 0.96, blue: 0.98).ignoresSafeArea()

            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .bottom) {
                    Color.white
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 50)
                    
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        Text("Feed Management")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.9))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .zIndex(1)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Today's Overview
                        VStack(spacing: 16) {
                            HStack {
                                Text("Today's Overview").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Color(white: 0.5))
                                Spacer()
                                Text(Date(), style: .date).font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Color(white: 0.6))
                            }
                            
                            HStack(spacing: 12) {
                                let todayStr = {
                                    let df = DateFormatter()
                                    df.dateFormat = "yyyy-MM-dd"
                                    df.locale = Locale(identifier: "en_US_POSIX")
                                    return df.string(from: Date())
                                }()
                                let todayTotal = feedManager.feedingEntries.filter { 
                                    $0.date.replacingOccurrences(of: "/", with: "-").hasPrefix(todayStr) 
                                }.reduce(0) { $0 + $1.quantity }
                                
                                overviewMiniCard(title: "Total Fed", value: String(format: "%.1f kg", todayTotal), icon: "scalemass", color: .green, index: 0)
                                overviewMiniCard(title: "Stock Items", value: "\(feedManager.stockItems.count)", icon: "shippingbox.fill", color: .blue, index: 1)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Quick Actions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Actions").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Color(white: 0.5))
                            
                            HStack(spacing: 12) {
                                quickActionBtn(title: "Add Feed", icon: "plus.circle.fill", color: .green, route: .feedingEntry, index: 3)
                                quickActionBtn(title: "Update Stock", icon: "shippingbox.fill", color: .blue, route: .feedStock, index: 4)
                            }
                            HStack(spacing: 12) {
                                quickActionBtn(title: "View Schedule", icon: "calendar.badge.clock", color: .indigo, route: .feedingSchedule, index: 5)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Modules List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Modules").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Color(white: 0.5))
                            
                            VStack(spacing: 12) {
                                moduleRow(title: "Feed Entry", desc: "Record daily consumption", icon: "leaf.fill", route: .feedingEntry, index: 6)
                                moduleRow(title: "Stock Management", desc: "Track inventory levels", icon: "shippingbox.fill", route: .feedStock, index: 7)
                                moduleRow(title: "Feeding Schedule", desc: "View & edit timings", icon: "calendar.badge.clock", route: .feedingSchedule, index: 8)
                                moduleRow(title: "Equipment Status", desc: "Monitor tools & machinery", icon: "gearshape.2.fill", route: .equipments, index: 9)
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 50)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            feedManager.loadData()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimated = true
            }
        }
    }
    
    @ViewBuilder
    private func overviewMiniCard(title: String, value: String, icon: String, color: Color, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
        .offset(y: appearAnimated ? 0 : 20)
        .opacity(appearAnimated ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appearAnimated)
    }
    
    @ViewBuilder
    private func quickActionBtn(title: String, icon: String, color: Color, route: AppRoute, index: Int) -> some View {
        Button {
            router.push(route)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 5, y: 2)
        }
        .offset(y: appearAnimated ? 0 : 20)
        .opacity(appearAnimated ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appearAnimated)
    }
    
    @ViewBuilder
    private func moduleRow(title: String, desc: String, icon: String, route: AppRoute, index: Int) -> some View {
        Button {
            router.push(route)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(white: 0.95))
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.black.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.9))
                    Text(desc)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.6))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .offset(y: appearAnimated ? 0 : 20)
        .opacity(appearAnimated ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appearAnimated)
    }

}

// MARK: - Feeding Entry View
struct FeedingEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var feedManager: FeedDataManager

    @State private var date = Date()
    @State private var selectedAnimalType: AnimalType = .cow
    @State private var selectedTime: FeedTime = .morning
    @State private var selectedFeedType: FeedType = .mixedRation
    @State private var quantity: String = ""
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var appearAnimated = false
    @State private var showErrorAlert = false

    private static let backendDf: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private var maxAvailableStock: Double {
        if let stockItem = feedManager.stockItems.first(where: { $0.name == selectedFeedType.rawValue }) {
            return stockItem.quantityValue
        }
        return 0.0
    }
    
    private var hasSufficientStock: Bool {
        guard let entered = Double(quantity) else { return false }
        return entered > 0 && entered <= maxAvailableStock
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.95, green: 0.96, blue: 0.98).ignoresSafeArea()

            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .bottom) {
                    Color.white
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 50)
                    
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        Text("Add Feed Entry")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.9))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                .zIndex(1)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        // Date Card
                        feedCard(index: 0) {
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.black.opacity(0.85))
                        }

                        // Target Group Card
                        feedCard(index: 1) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Target Group").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Color(white: 0.5))
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(AnimalType.allCases) { a in
                                            chip(title: a.rawValue, isSelected: selectedAnimalType == a) {
                                                selectedAnimalType = a
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Feed Type Card
                        feedCard(index: 2) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Feed Type").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Color(white: 0.5))
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(FeedType.allCases) { t in
                                            chip(title: t.rawValue, isSelected: selectedFeedType == t) {
                                                selectedFeedType = t
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Time Card
                        feedCard(index: 3) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Feeding Time").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Color(white: 0.5))
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(FeedTime.allCases) { t in
                                            chip(title: t.rawValue, isSelected: selectedTime == t) {
                                                selectedTime = t
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Details Card (Quantity & Notes only)
                        feedCard(index: 4) {
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Quantity Fed").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Color(white: 0.5))
                                        Spacer()
                                        Text("Available: \(maxAvailableStock, specifier: "%.1f") kg")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    HStack {
                                        TextField("0.0", text: $quantity)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundColor(.black.opacity(0.85))
                                        Text("kg").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.secondary)
                                    }
                                    
                                    if let val = Double(quantity), val > maxAvailableStock {
                                        Text("Insufficient stock! Please update stock first.")
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .foregroundColor(.red)
                                    }
                                    
                                    Divider()
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes (Optional)").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Color(white: 0.5))
                                    TextField("Add any observation...", text: $notes)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .padding(16)
                                        .background(Color(.systemGray6).opacity(0.6))
                                        .cornerRadius(12)
                                }
                            }
                        }

                        Spacer().frame(height: 100)
                    }
                    .padding(20)
                }
            }

            // Save Button
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.96, blue: 0.98).opacity(0), Color(red: 0.95, green: 0.96, blue: 0.98)],
                    startPoint: .top,
                    endPoint: .center
                )
                .frame(height: 40)
                .allowsHitTesting(false)

                Button {
                    isSaving = true
                    if let qtyVal = Double(quantity), qtyVal <= maxAvailableStock {
                        let entry = FeedingEntry(
                            date: Self.backendDf.string(from: date),
                            time: selectedTime,
                            feedType: selectedFeedType,
                            targetGroup: selectedAnimalType.rawValue,
                            quantity: qtyVal,
                            notes: notes
                        )
                        feedManager.addFeedingEntry(entry) { success in
                            isSaving = false
                            if success {
                                dismiss()
                            } else {
                                showErrorAlert = true
                            }
                        }
                    } else {
                        isSaving = false
                    }
                } label: {
                    HStack {
                        if isSaving { ProgressView().tint(.white).padding(.trailing, 8) }
                        Text(isSaving ? "Saving..." : "Save Entry")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(!hasSufficientStock ? Color(white: 0.7) : Color.green)
                    .cornerRadius(28)
                    .shadow(color: !hasSufficientStock ? .clear : Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(!hasSufficientStock || isSaving)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .background(Color(red: 0.95, green: 0.96, blue: 0.98))
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text("Failed to log feeding entry. Please ensure you have sufficient stock and check your connection."), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimated = true
            }
        }
    }

    @ViewBuilder
    private func feedCard<Content: View>(index: Int, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
            .offset(y: appearAnimated ? 0 : 20)
            .opacity(appearAnimated ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appearAnimated)
    }
    
    @ViewBuilder
    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : .black.opacity(0.75))
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(isSelected ? Color.green : Color(white: 0.95))
                .cornerRadius(24)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feed Stock View
struct FeedStockView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var feedManager: FeedDataManager
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .top) {
                    LinearGradient(colors: [Color.blue.opacity(0.12), Color.white], startPoint: .top, endPoint: .bottom)
                        .frame(height: 180)
                        .ignoresSafeArea()

                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }

                        Spacer()

                        Text("Inventory Stock")
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
                        
                        
                        VStack(spacing: 16) {
                            ForEach(feedManager.stockItems) { item in
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text(item.name)
                                            .font(.system(size: 17, weight: .bold, design: .rounded))
                                            .foregroundColor(.black.opacity(0.85))
                                        Spacer()
                                        Text(item.quantityDisplay)
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    let percentage = min(max(item.quantityValue / 2000.0, 0.05), 1.0)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color.gray.opacity(0.08))
                                                    .frame(height: 10)
                                                
                                                Capsule()
                                                    .fill(LinearGradient(colors: [item.status.barColor.opacity(0.8), item.status.barColor], startPoint: .leading, endPoint: .trailing))
                                                    .frame(width: geo.size.width * CGFloat(percentage), height: 10)
                                            }
                                        }
                                        .frame(height: 10)
                                        
                                        if item.status == .low {
                                            HStack(spacing: 4) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .font(.system(size: 10))
                                                Text("Low stock level - consider restocking")
                                                    .font(.system(size: 11, weight: .medium))
                                            }
                                            .foregroundColor(Color.orange.opacity(0.9))
                                            .padding(.top, 2)
                                        }
                                    }
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(22)
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                            }
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(16)
                }
            }

            // Add Stock Button
            VStack {
                Button {
                    router.push(.addStock)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("Add Stock")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue)
                    .cornerRadius(30)
                    .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 6)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .background(
                LinearGradient(colors: [Color(.systemGroupedBackground).opacity(0), Color(.systemGroupedBackground)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 120)
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            feedManager.loadData()
        }
    }
}

// MARK: - Add Stock View
struct AddStockView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var feedManager: FeedDataManager

    @State private var itemName: String = "Silage"
    @State private var quantity: String = ""
    @State private var isSaving = false
    @State private var showError = false

    private let quickTypes = ["Silage", "Concentrate", "Hay / Dry Fodder", "Green Fodder", "Mixed Ration (TMR)"]

    var body: some View {
        ZStack(alignment: .bottom) {
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

                        Text("Add Feed Stock")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.85))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                .padding(.bottom, -60)

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select Item")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                            
                            FlowLayout(items: quickTypes) { type in
                                Button { itemName = type } label: {
                                    Text(type)
                                        .font(.system(size: 14, weight: itemName == type ? .bold : .medium))
                                        .foregroundColor(itemName == type ? .white : .primary.opacity(0.7))
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                        .background(itemName == type ? Color.blue : Color.gray.opacity(0.08))
                                        .cornerRadius(22)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quantity (kg)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                            
                            TextField("0.0", text: $quantity)
                                .keyboardType(.numbersAndPunctuation)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .padding(20)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                    }
                    .padding(16)
                }
            }

            VStack(spacing: 8) {
                Button {
                    isSaving = true
                    if let val = Double(quantity), val != 0 {
                        feedManager.addStock(to: itemName, amount: val) { success in
                            isSaving = false
                            if success {
                                dismiss()
                            } else {
                                showError = true
                            }
                        }
                    } else { isSaving = false }
                } label: {
                    Text(isSaving ? "Saving..." : "Save Stock")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(quantity.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .cornerRadius(30)
                        .shadow(color: (quantity.isEmpty ? Color.clear : Color.blue.opacity(0.3)), radius: 12, x: 0, y: 6)
                }
                .disabled(quantity.isEmpty || isSaving)
            }
            .padding(16)
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text("Failed to save stock. Please check your connection and try again."), dismissButton: .default(Text("OK")))
        }
    }
}

// Custom flow layout for chips since Wrap is iOS 16+
struct FlowLayout: View {
    var items: [String]
    var action: (String) -> AnyView
    
    init(items: [String], @ViewBuilder action: @escaping (String) -> some View) {
        self.items = items
        self.action = { AnyView(action($0)) }
    }
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return GeometryReader { g in
            ZStack(alignment: .topLeading) {
                ForEach(items, id: \.self) { item in
                    action(item)
                        .padding([.horizontal, .vertical], 4)
                        .alignmentGuide(.leading, computeValue: { d in
                            if (abs(width - d.width) > g.size.width) {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if item == items.last! { width = 0 }
                            else { width -= d.width }
                            return result
                        })
                        .alignmentGuide(.top, computeValue: { _ in
                            let result = height
                            if item == items.last! { height = 0 }
                            return result
                        })
                }
            }
        }.frame(minHeight: 100)
    }
}

// MARK: - Feeding Schedule View
struct FeedingScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var feedManager: FeedDataManager
    @EnvironmentObject var router: NavigationRouter
    @State private var showDeleteAlert = false
    @State private var itemToDelete: FeedingScheduleItem? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.indigo)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Feeding Schedule").font(.system(size: 18, weight: .bold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12).padding(.vertical, 10).background(Color.white)

                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill").foregroundColor(.indigo)
                            Text("Tap ✓ to mark a feed done. Swipe left to delete, or tap edit to modify.").font(.system(size: 13, weight: .medium)).foregroundColor(.indigo)
                            Spacer()
                        }
                        .padding(12).background(Color.indigo.opacity(0.08)).cornerRadius(10)

                        if feedManager.schedules.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 48))
                                    .foregroundColor(.indigo.opacity(0.4))
                                Text("No schedules yet")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text("Tap \"Add Time Slot\" to create your first feeding schedule.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(32)
                        }

                        ForEach(feedManager.schedules) { schedule in
                            HStack(alignment: .top, spacing: 16) {
                                // Time column
                                VStack(spacing: 2) {
                                    let parts = formatTime(schedule.time)
                                    Text(parts.0)
                                        .font(.system(size: 16, weight: .bold))
                                    Text(parts.1)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 60)

                                // Content
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(schedule.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .strikethrough(schedule.isCompleted, color: .secondary)
                                    Text(schedule.items.joined(separator: ", "))
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()

                                // Action buttons
                                VStack(spacing: 8) {
                                    // Complete toggle
                                    Button {
                                        feedManager.updateSchedule(
                                            id: schedule.id,
                                            title: schedule.title,
                                            time: schedule.time,
                                            items: schedule.items,
                                            isCompleted: !schedule.isCompleted
                                        )
                                    } label: {
                                        Image(systemName: schedule.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 24))
                                            .foregroundColor(schedule.isCompleted ? .indigo : .gray.opacity(0.4))
                                    }

                                    // Edit button
                                    Button {
                                        router.push(.updateSchedule(schedule))
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.indigo)
                                            .frame(width: 30, height: 30)
                                            .background(Color.indigo.opacity(0.1))
                                            .clipShape(Circle())
                                    }

                                    // Delete button
                                    Button {
                                        itemToDelete = schedule
                                        showDeleteAlert = true
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.red)
                                            .frame(width: 30, height: 30)
                                            .background(Color.red.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                            .opacity(schedule.isCompleted ? 0.6 : 1.0)
                        }

                        Spacer().frame(height: 100)
                    }
                    .padding(16)
                }
            }

            // Add Time Slot Button
            VStack {
                Button {
                    router.push(.updateSchedule(nil))
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Time Slot")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.indigo)
                    .cornerRadius(28)
                    .shadow(color: Color.indigo.opacity(0.3), radius: 8, y: 4)
                }
            }
            .padding(16)
        }
        .navigationBarHidden(true)
        .onAppear { feedManager.loadData() }
        .alert("Delete Schedule?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    feedManager.deleteSchedule(id: item.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove this feeding time slot.")
        }
    }

    private func formatTime(_ time: String) -> (String, String) {
        // time is stored as "HH:mm" or "06:00 AM" etc.
        // We parse if possible
        let df24 = DateFormatter()
        df24.dateFormat = "HH:mm"
        let dfDisplay = DateFormatter()
        dfDisplay.dateFormat = "hh:mm"
        let dfAmPm = DateFormatter()
        dfAmPm.dateFormat = "a"

        if let d = df24.date(from: time) {
            return (dfDisplay.string(from: d), dfAmPm.string(from: d))
        }
        // Fallback: show as-is
        if time.count >= 5 {
            return (String(time.prefix(5)), String(time.dropFirst(6)))
        }
        return (time, "")
    }
}



// MARK: - Reports List Preview (For Feeding Module View)
struct ReportsListView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold)).foregroundColor(.purple).frame(width: 40, height: 40) }
                    Spacer(); Text("Reports Dashboard").font(.system(size: 18, weight: .bold)); Spacer(); Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12).padding(.vertical, 10).background(Color.white)

                ScrollView {
                    VStack(spacing: 16) {
                        // Date Navigator
                        HStack(spacing: 16) {
                            Image(systemName: "chevron.left").foregroundColor(.blue)
                            Text("March 12, 2026").font(.system(size: 16, weight: .semibold))
                            Image(systemName: "chevron.right").foregroundColor(.blue)
                        }
                        .padding(.vertical, 16)

                        // Report Modules
                        reportCard(title: "Daily Feed Consumption", icon: "scalemass.fill", color: .green, stats: [("Total Fed", "150 kg"), ("TMR Cost", "₹1200")])
                        reportCard(title: "Inventory Usage", icon: "shippingbox.fill", color: .blue, stats: [("Used Silage", "50 kg"), ("Additions", "0 kg")])
                        reportCard(title: "Schedule Adherence", icon: "calendar.badge.clock", color: .indigo, stats: [("Completed", "100%"), ("Missed", "0")])
                        reportCard(title: "Equipment Maintenance", icon: "gearshape.fill", color: .orange, stats: [("Active", "2"), ("Needs Attention", "1")])
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button {
                            } label: {
                                HStack { Image(systemName: "square.and.arrow.up"); Text("Export PDF") }
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color.blue).cornerRadius(10)
                            }
                            Button {
                            } label: {
                                HStack { Image(systemName: "printer.fill"); Text("Print") }
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color.purple).cornerRadius(10)
                            }
                        }
                        .padding(.top, 16)

                        Spacer().frame(height: 100)
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func reportCard(title: String, icon: String, color: Color, stats: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.system(size: 15, weight: .bold))
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.secondary)
            }
            Divider()
            HStack {
                ForEach(stats, id: \.0) { stat in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.0).font(.system(size: 12)).foregroundColor(.secondary)
                        Text(stat.1).font(.system(size: 16, weight: .semibold))
                    }
                    if stat.0 != stats.last?.0 { Spacer() }
                }
            }
        }
        .padding(16).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
    }
}

// MARK: - Update Schedule View
struct UpdateScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var feedManager: FeedDataManager

    /// If non-nil, we're editing an existing schedule
    var existingSchedule: FeedingScheduleItem?

    @State private var time = Date()
    @State private var title: String = ""
    @State private var items: String = ""
    @State private var isSaving = false

    private var isEditing: Bool { existingSchedule != nil }

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.indigo)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text(isEditing ? "Edit Time Slot" : "Add Time Slot")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12).padding(.vertical, 10).background(Color.white)

                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: isEditing ? "pencil.circle.fill" : "info.circle.fill")
                                .foregroundColor(.indigo)
                            Text(isEditing ? "Edit this feeding time slot." : "Create a new feeding time slot.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.indigo)
                            Spacer()
                        }
                        .padding(12).background(Color.indigo.opacity(0.08)).cornerRadius(10)

                        // Time Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)

                        // Slot Name
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Slot Name").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                            TextField("e.g. Evening Supplement", text: $title)
                                .font(.system(size: 16))
                                .padding(14).background(Color(.systemGray6)).cornerRadius(12)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)

                        // Feed Items
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Feed Items (Comma Separated)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            TextField("e.g. Silage, Concentrate", text: $items)
                                .font(.system(size: 16))
                                .padding(14).background(Color(.systemGray6)).cornerRadius(12)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)

                        Spacer().frame(height: 100)
                    }
                    .padding(16)
                }
            }

            VStack {
                Button {
                    guard !title.isEmpty, !items.isEmpty else { return }
                    isSaving = true
                    let timeStr = Self.timeFormatter.string(from: time)
                    let itemList = items
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }

                    if let existing = existingSchedule {
                        feedManager.updateSchedule(
                            id: existing.id,
                            title: title,
                            time: timeStr,
                            items: itemList,
                            isCompleted: existing.isCompleted
                        )
                    } else {
                        feedManager.addSchedule(title: title, time: timeStr, items: itemList)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        isSaving = false
                        dismiss()
                    }
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView().tint(.white).padding(.trailing, 6)
                        }
                        Text(isSaving ? "Saving..." : (isEditing ? "Update Schedule" : "Save to Schedule"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(!title.isEmpty && !items.isEmpty ? Color.indigo : Color.gray.opacity(0.5))
                    .cornerRadius(28)
                    .shadow(color: Color.indigo.opacity(0.3), radius: 8, y: 4)
                }
                .disabled(title.isEmpty || items.isEmpty || isSaving)
            }
            .padding(16)
        }
        .navigationBarHidden(true)
        .onAppear {
            if let s = existingSchedule {
                title = s.title
                items = s.items.joined(separator: ", ")
                // Parse stored "HH:mm" back to Date
                if let d = Self.timeFormatter.date(from: s.time) { time = d }
            }
        }
    }
}
