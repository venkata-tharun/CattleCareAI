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
    let id = UUID()
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
                    Text("Feed Management")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // Today's Overview
                        VStack(spacing: 16) {
                            HStack {
                                Text("Today's Overview").font(.system(size: 16, weight: .bold)).foregroundColor(.secondary)
                                Spacer()
                                Text(Date(), style: .date).font(.system(size: 13, weight: .medium)).foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 12) {
                                let todayStr = {
                                    let df = DateFormatter()
                                    df.dateFormat = "yyyy-MM-dd"
                                    return df.string(from: Date())
                                }()
                                let todayTotal = feedManager.feedingEntries.filter { $0.date == todayStr }.reduce(0) { $0 + $1.quantity }
                                
                                overviewMiniCard(title: "Total Fed", value: "\(Int(todayTotal)) kg", icon: "scalemass", color: .green)
                                overviewMiniCard(title: "Stock Items", value: "\(feedManager.stockItems.count)", icon: "shippingbox.fill", color: .blue)
                                overviewMiniCard(title: "Next Feed", value: "2:00 PM", icon: "clock", color: .purple)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)


                        // Quick Actions
                        VStack(spacing: 12) {
                            Text("Quick Actions").font(.system(size: 16, weight: .bold)).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                quickActionBtn(title: "Add Feed", icon: "plus.circle.fill", color: .green, route: .feedingEntry)
                                quickActionBtn(title: "Update Stock", icon: "shippingbox.fill", color: .blue, route: .feedStock)
                                quickActionBtn(title: "View Schedule", icon: "calendar.badge.clock", color: .indigo, route: .feedingSchedule)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Modules List
                        VStack(spacing: 12) {
                            Text("Modules").font(.system(size: 16, weight: .bold)).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                            
                            moduleRow(title: "Feed Entry", desc: "Record daily consumption", icon: "leaf.fill", route: .feedingEntry)
                            moduleRow(title: "Stock Management", desc: "Track inventory levels", icon: "shippingbox.fill", route: .feedStock)
                            moduleRow(title: "Feeding Schedule", desc: "View & edit timings", icon: "calendar.badge.clock", route: .feedingSchedule)
                            moduleRow(title: "Equipment Status", desc: "Monitor tools & machinery", icon: "gearshape.2.fill", route: .equipments)
                        }
                        .padding(.horizontal, 16)

                        // Recent Activity
                        if !feedManager.feedingEntries.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Feed Entries").font(.system(size: 16, weight: .bold)).foregroundColor(.secondary).padding(.leading, 4)
                                
                                VStack(spacing: 0) {
                                    ForEach(feedManager.feedingEntries.prefix(3)) { entry in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(entry.feedType.rawValue).font(.system(size: 15, weight: .semibold))
                                                Text("\(entry.quantity, specifier: "%.1f") kg at \(entry.time.rawValue)").font(.system(size: 13)).foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text(entry.date).font(.system(size: 11)).foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        
                                        if entry.id != feedManager.feedingEntries.prefix(3).last?.id {
                                            Divider().padding(.leading, 16)
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer().frame(height: 50)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            feedManager.loadData()
        }
    }
    
    @ViewBuilder
    private func overviewMiniCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 11)).foregroundColor(.secondary)
                Text(value).font(.system(size: 16, weight: .bold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
    }
    
    @ViewBuilder
    private func quickActionBtn(title: String, icon: String, color: Color, route: AppRoute) -> some View {
        Button {
            router.push(route)
        } label: {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundColor(.primary)
                Spacer()
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
        }
    }
    
    @ViewBuilder
    private func moduleRow(title: String, desc: String, icon: String, route: AppRoute) -> some View {
        Button {
            router.push(route)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.gray.opacity(0.1)).frame(width: 44, height: 44)
                    Image(systemName: icon).font(.system(size: 18)).foregroundColor(.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 15, weight: .semibold)).foregroundColor(.primary)
                    Text(desc).font(.system(size: 13)).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.gray)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
        }
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

    private static let backendDf: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Add Feed Entry")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        
                        // Date Card
                        feedCard {
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .font(.system(size: 15, weight: .medium))
                        }

                        // Animal Target Card
                        feedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Target Group").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
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
                        feedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Feed Type").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
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
                        feedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Feeding Time").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                HStack(spacing: 8) {
                                    ForEach(FeedTime.allCases) { t in
                                        chip(title: t.rawValue, isSelected: selectedTime == t) {
                                            selectedTime = t
                                        }
                                    }
                                }
                            }
                        }

                        // Details Card
                        feedCard {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Quantity Fed").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                    HStack {
                                        TextField("0.0", text: $quantity)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 24, weight: .bold))
                                        Text("kg").font(.system(size: 16, weight: .semibold)).foregroundColor(.secondary)
                                    }
                                    Divider()
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Photo Proof (Optional)").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                    Button {
                                        // Camera action mockup
                                    } label: {
                                        HStack {
                                            Image(systemName: "camera.fill")
                                            Text("Tap to capture photo")
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.green)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes (Optional)").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                    TextField("Add any observation...", text: $notes)
                                        .font(.system(size: 15))
                                        .padding(12)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                            }
                        }

                        Spacer().frame(height: 100)
                    }
                    .padding(16)
                }
            }

            // Save Button
            VStack(spacing: 4) {
                
                Button {
                    isSaving = true
                    if let qtyVal = Double(quantity) {
                        let entry = FeedingEntry(
                            date: Self.backendDf.string(from: date),
                            time: selectedTime,
                            feedType: selectedFeedType,
                            quantity: qtyVal,
                            notes: notes
                        )
                        feedManager.addFeedingEntry(entry)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isSaving = false
                            dismiss()
                        }
                    } else {
                        isSaving = false
                    }
                } label: {
                    HStack {
                        if isSaving { ProgressView().tint(.white).padding(.trailing, 8) }
                        Text(isSaving ? "Saving..." : "Save Entry")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(quantity.isEmpty ? Color.gray.opacity(0.5) : Color.green)
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
                }
                .disabled(quantity.isEmpty || isSaving)
            }
            .padding(16)
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func feedCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color.gray.opacity(0.1))
                .cornerRadius(20)
        }
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
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Inventory Stock")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        
                        VStack(spacing: 12) {
                            ForEach(feedManager.stockItems) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(item.name).font(.system(size: 15, weight: .semibold))
                                        Spacer()
                                        Text(item.quantityDisplay).font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                                    }
                                    
                                    // Progress bar representation without generic "alert" colors or popups
                                    // Uses yellow for low, green for everything else based on requested style.
                                    let percentage = min(max(item.quantityValue / 2000.0, 0.05), 1.0)
                                    
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(height: 8)
                                            Capsule()
                                                .fill(item.status.barColor)
                                                .frame(width: geo.size.width * CGFloat(percentage), height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                    
                                    if item.status == .low {
                                        Text("Low stock level - consider restocking").font(.system(size: 11)).foregroundColor(Color.yellow.opacity(0.8))
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
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
                    HStack {
                        Text("Add Stock")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
                }
            }
            .padding(16)
            .background(Color(.systemGroupedBackground))
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
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold)).foregroundColor(.blue).frame(width: 40, height: 40)
                    }
                    Spacer(); Text("Add Feed Stock").font(.system(size: 18, weight: .bold)); Spacer(); Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12).padding(.vertical, 10).background(Color.white)

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Item").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                            FlowLayout(items: quickTypes) { type in
                                Button { itemName = type } label: {
                                    Text(type).font(.system(size: 14)).foregroundColor(itemName == type ? .white : .primary)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(itemName == type ? Color.blue : Color.gray.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(16).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quantity (kg)").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                            TextField("0.0", text: $quantity).keyboardType(.decimalPad).font(.system(size: 24, weight: .bold))
                                .padding(16).background(Color(.systemGray6)).cornerRadius(12)
                        }
                        .padding(16).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                    }
                    .padding(16)
                }
            }

            VStack(spacing: 8) {
                Button {
                    isSaving = true
                    if let val = Double(quantity), val > 0 {
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
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56)
                        .background(quantity.isEmpty ? Color.gray.opacity(0.5) : Color.blue).cornerRadius(28)
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
    
    @State private var schedules = [
        FeedingScheduleItem(time: "06:00 AM", title: "Morning Feed", items: ["Silage", "Concentrate"]),
        FeedingScheduleItem(time: "02:00 PM", title: "Afternoon Snack", items: ["Green Fodder"]),
        FeedingScheduleItem(time: "06:00 PM", title: "Evening Feed", items: ["Hay", "Mineral Mix"])
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold)).foregroundColor(.indigo).frame(width: 40, height: 40) }
                    Spacer(); Text("Feeding Schedule").font(.system(size: 18, weight: .bold)); Spacer(); Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12).padding(.vertical, 10).background(Color.white)

                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill").foregroundColor(.purple)
                            Text("Completion checks log directly to your schedule history.").font(.system(size: 13, weight: .medium)).foregroundColor(.purple)
                            Spacer()
                        }
                        .padding(12).background(Color.purple.opacity(0.1)).cornerRadius(10)
                        
                        ForEach($schedules) { $schedule in
                            HStack(alignment: .top, spacing: 16) {
                                VStack {
                                    Text(schedule.time.prefix(5)).font(.system(size: 16, weight: .bold))
                                    Text(schedule.time.suffix(2)).font(.system(size: 11)).foregroundColor(.secondary)
                                }
                                .frame(width: 60)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(schedule.title).font(.system(size: 16, weight: .bold))
                                    Text(schedule.items.joined(separator: ", ")).font(.system(size: 13)).foregroundColor(.secondary)
                                }
                                Spacer()
                                Button {
                                    schedule.isCompleted.toggle()
                                } label: {
                                    Image(systemName: schedule.isCompleted ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 24))
                                        .foregroundColor(schedule.isCompleted ? .indigo : .gray.opacity(0.5))
                                }
                            }
                            .padding(16).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
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

    @State private var time = Date()
    @State private var title: String = ""
    @State private var items: String = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold)).foregroundColor(.indigo).frame(width: 40, height: 40) }
                    Spacer(); Text("Add Time Slot").font(.system(size: 18, weight: .bold)); Spacer(); Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12).padding(.vertical, 10).background(Color.white)

                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill").foregroundColor(.purple)
                            Text("Updates Schedule History.").font(.system(size: 13, weight: .medium)).foregroundColor(.purple)
                            Spacer()
                        }
                        .padding(12).background(Color.purple.opacity(0.1)).cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Slot Name").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                            TextField("e.g. Evening Supplement", text: $title)
                                .font(.system(size: 16))
                                .padding(14).background(Color(.systemGray6)).cornerRadius(12)
                        }
                        .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Feed Items (Comma Separated)").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                            TextField("e.g. Silage, Concentrate", text: $items)
                                .font(.system(size: 16))
                                .padding(14).background(Color(.systemGray6)).cornerRadius(12)
                        }
                        .padding(16).frame(maxWidth: .infinity, alignment: .leading).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(16)
                }
            }
            
            VStack {
                Button {
                    // Action mockup
                    dismiss()
                } label: {
                    Text("Save to Schedule")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56)
                        .background(!title.isEmpty && !items.isEmpty ? Color.indigo : Color.gray.opacity(0.5)).cornerRadius(28)
                }
                .disabled(title.isEmpty || items.isEmpty)
            }
            .padding(16)
        }
        .navigationBarHidden(true)
    }
}
