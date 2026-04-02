import SwiftUI
import Combine

// MARK: - Formatters
extension Date {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

// MARK: - Dashboard View (VisitorsView)
struct VisitorsView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: VisitorDataManager
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
                        Button { router.pop() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        Text("VISITORS")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.9))
                            .tracking(1.0)

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                .zIndex(1)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Metrics Grid
                        VStack(spacing: 16) {
                            MetricCard(title: "Total Today", value: "\(dataManager.todayVisitorsCount)", icon: "person.3.fill", color: .blue, index: 0, animated: appearAnimated)
                            
                            HStack(spacing: 16) {
                                MetricCard(title: "Pending", value: "\(dataManager.pendingCount)", icon: "hourglass", color: .orange, index: 1, animated: appearAnimated)
                                MetricCard(title: "Approved", value: "\(dataManager.approvedCount)", icon: "checkmark.seal.fill", color: .green, index: 2, animated: appearAnimated)
                            }
                            
                            HStack(spacing: 16) {
                                MetricCard(title: "Checked In", value: "\(dataManager.checkedInCount)", icon: "arrow.right.circle.fill", color: .blue, index: 3, animated: appearAnimated)
                                MetricCard(title: "Checked Out", value: "\(dataManager.checkedOutCount)", icon: "arrow.left.circle.fill", color: .gray, index: 4, animated: appearAnimated)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        
                        VStack(spacing: 16) {
                            ActionButton(title: "Add Visitor", icon: "plus.circle.fill", index: 5, animated: appearAnimated) {
                                router.push(.addVisitor)
                            }
                            
                            ActionButton(title: "View All Visitors", icon: "list.bullet", index: 6, animated: appearAnimated) {
                                router.push(.visitorList)
                            }
                            
                            ActionButton(title: "Visitor Reports", icon: "chart.bar.doc.horizontal", index: 7, animated: appearAnimated) {
                                router.push(.reportDetail(.visitors))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 40)
                        
                        // Time Indicator at bottom
                        VStack(spacing: 4) {
                            Text(Date().formattedTime())
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.blue.opacity(0.5))
                        }
                        .padding(.bottom, 40)
                        .offset(y: appearAnimated ? 0 : 20)
                        .opacity(appearAnimated ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: appearAnimated)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimated = true
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let index: Int
    let animated: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(value)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.85))
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        .offset(y: animated ? 0 : 20)
        .opacity(animated ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: animated)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let index: Int
    let animated: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.85))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .frame(height: 70)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .offset(y: animated ? 0 : 20)
        .opacity(animated ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: animated)
    }
}

// MARK: - Add Visitor View
struct AddVisitorView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: VisitorDataManager
    @Environment(\.dismiss) private var dismiss
    
    var existingVisitor: Visitor?
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var purpose: String = ""
    @State private var date: Date = Date()
    @State private var entryTime: Date = Date()
    @State private var outgoingTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State private var personToMeet: String = ""
    @State private var vehicleNumber: String = ""
    @State private var notes: String = ""
    
    @State private var showError: Bool = false
    @State private var appearAnimated = false
    
    init(existingVisitor: Visitor? = nil) {
        self.existingVisitor = existingVisitor
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
                        Button { router.pop() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        Text(existingVisitor == nil ? "Add Visitor" : "Edit Visitor")
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
                    VStack(alignment: .leading, spacing: 24) {
                        
                        if showError {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Please fill out all required fields (*)")
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .transition(.opacity)
                        }
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            formCard(index: 0) {
                                VStack(spacing: 16) {
                                    SimpleTextField(icon: "person.fill", title: "Visitor Name *", placeholder: "Full Name", text: $name)
                                    SimpleTextField(icon: "phone.fill", title: "Phone Number *", placeholder: "10-digit number", text: $phone, keyboardType: .numberPad)
                                    SimpleTextField(icon: "doc.text.fill", title: "Purpose of Visit", placeholder: "eg. Milk Collection", text: $purpose)
                                }
                            }
                            
                            formCard(index: 1) {
                                VStack(spacing: 16) {
                                    CustomDatePickerField(icon: "calendar", label: "Date", date: $date)
                                    CustomDatePickerField(icon: "clock", label: "Entry Time", date: $entryTime, isTime: true)
                                    CustomDatePickerField(icon: "clock.fill", label: "Outgoing Time", date: $outgoingTime, isTime: true)
                                    SimpleTextField(icon: "figure.walk", title: "Person to Meet", placeholder: "Staff Name", text: $personToMeet)
                                }
                            }
                            
                            formCard(index: 2) {
                                VStack(spacing: 16) {
                                    SimpleTextField(icon: "car.fill", title: "Vehicle Number", placeholder: "Optional", text: $vehicleNumber)
                                    SimpleTextField(icon: "pencil.line", title: "Notes", placeholder: "Any extra notes...", text: $notes)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, showError ? 8 : 24)
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
            
            // Bottom Save Button
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.96, blue: 0.98).opacity(0), Color(red: 0.95, green: 0.96, blue: 0.98)],
                    startPoint: .top,
                    endPoint: .center
                )
                .frame(height: 40)
                .allowsHitTesting(false)

                Button {
                    if name.isEmpty || phone.isEmpty {
                        withAnimation { showError = true }
                    } else {
                        if var visitor = existingVisitor {
                            visitor.name = name
                            visitor.phone = phone
                            visitor.purpose = purpose
                            visitor.date = date
                            visitor.entryTime = entryTime
                            visitor.outgoingTime = outgoingTime
                            visitor.personToMeet = personToMeet
                            visitor.vehicleNumber = vehicleNumber
                            visitor.notes = notes
                            dataManager.updateVisitor(visitor)
                        } else {
                            let newVisitor = Visitor(name: name, phone: phone, purpose: purpose, date: date, entryTime: entryTime, outgoingTime: outgoingTime, personToMeet: personToMeet, vehicleNumber: vehicleNumber, notes: notes, status: .pending)
                            dataManager.addVisitor(newVisitor)
                        }
                        router.pop()
                    }
                } label: {
                    Text("Save Visitor")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.blue)
                        .cornerRadius(29)
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .background(Color(red: 0.95, green: 0.96, blue: 0.98))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let v = existingVisitor {
                name = v.name
                phone = v.phone
                purpose = v.purpose
                date = v.date
                entryTime = v.entryTime
                outgoingTime = v.outgoingTime
                personToMeet = v.personToMeet
                vehicleNumber = v.vehicleNumber
                notes = v.notes
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimated = true
            }
        }
    }
    
    @ViewBuilder
    private func formCard<Content: View>(index: Int, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
            .offset(y: appearAnimated ? 0 : 20)
            .opacity(appearAnimated ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appearAnimated)
    }
}

struct SimpleTextField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(white: 0.5))
            
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(.blue.opacity(0.7))
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.96, green: 0.97, blue: 0.98))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
        }
    }
}


// MARK: - Visitor List View
struct VisitorListView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: VisitorDataManager
    
    @State private var searchText = ""
    @State private var appearAnimated = false
    
    var filteredVisitors: [Visitor] {
        if searchText.isEmpty {
            return dataManager.visitors
        } else {
            return dataManager.visitors.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.phone.contains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Premium Header
            ZStack(alignment: .bottom) {
                Color.white
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 50)
                
                HStack {
                    Button { router.pop() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("All Visitors")
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
            
            // Search Box
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search visitors...", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(red: 0.95, green: 0.96, blue: 0.98))
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if filteredVisitors.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("No visitors found")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 60)
                    } else {
                        ForEach(Array(filteredVisitors.enumerated()), id: \.element.id) { index, visitor in
                            VisitorRow(visitor: visitor) {
                                router.push(.visitorDetail(visitor))
                            }
                            .offset(y: appearAnimated ? 0 : 20)
                            .opacity(appearAnimated ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appearAnimated)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color(red: 0.95, green: 0.96, blue: 0.98))
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation { appearAnimated = true }
        }
    }
}

struct VisitorRow: View {
    let visitor: Visitor
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Text(String(visitor.name.prefix(1)).uppercased())
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(visitor.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.9))
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text("\(visitor.entryTime.formattedTime()) → \(visitor.outgoingTime.formattedTime())")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text(visitor.status.rawValue.uppercased())
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(visitor.status.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(visitor.status.color.opacity(0.15))
                        .clipShape(Capsule())
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Visitor Detail View
struct VisitorDetailView: View {
    let visitorParam: Visitor
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: VisitorDataManager
    @State private var appearAnimated = false
    
    var visitor: Visitor {
        dataManager.visitors.first(where: { $0.id == visitorParam.id }) ?? visitorParam
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Premium Header
            ZStack(alignment: .bottom) {
                Color.white
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 50)
                
                HStack {
                    Button { router.pop() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Visitor Details")
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
                VStack(spacing: 24) {
                    
                    // Profile Banner
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Text(String(visitor.name.prefix(1)).uppercased())
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                        }
                        
                        Text(visitor.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.9))
                        
                        Text(visitor.status.rawValue.uppercased())
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(visitor.status.color)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(visitor.status.color.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 24)
                    .offset(y: appearAnimated ? 0 : 20)
                    .opacity(appearAnimated ? 1 : 0)
                    
                    // INFO GRID
                    VStack(spacing: 0) {
                        DetailInfoRow(icon: "phone.fill", color: .green, title: "Phone", value: visitor.phone)
                        Divider().padding(.leading, 50)
                        DetailInfoRow(icon: "briefcase.fill", color: .orange, title: "Purpose", value: visitor.purpose.isEmpty ? "-" : visitor.purpose)
                        Divider().padding(.leading, 50)
                        DetailInfoRow(icon: "calendar", color: .red, title: "Date", value: visitor.date.formattedDate())
                        Divider().padding(.leading, 50)
                        DetailInfoRow(icon: "clock.fill", color: .blue, title: "Timing", value: "\(visitor.entryTime.formattedTime()) to \(visitor.outgoingTime.formattedTime())")
                        Divider().padding(.leading, 50)
                        DetailInfoRow(icon: "person.fill.viewfinder", color: .purple, title: "To Meet", value: visitor.personToMeet.isEmpty ? "-" : visitor.personToMeet)
                        Divider().padding(.leading, 50)
                        DetailInfoRow(icon: "car.fill", color: .gray, title: "Vehicle", value: visitor.vehicleNumber.isEmpty ? "No Vehicle" : visitor.vehicleNumber)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    .offset(y: appearAnimated ? 0 : 20)
                    .opacity(appearAnimated ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: appearAnimated)
                    
                    // ACTION BUTTONS TO CHANGE STATUS
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            StatusButton(title: "APPROVE", icon: "checkmark.circle.fill", color: Color(red: 0.2, green: 0.8, blue: 0.44)) {
                                dataManager.updateStatus(for: visitor.id, to: .approved)
                            }
                            StatusButton(title: "REJECT", icon: "xmark.circle.fill", color: Color(red: 1.0, green: 0.3, blue: 0.4)) {
                                dataManager.updateStatus(for: visitor.id, to: .rejected)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            StatusButton(title: "CHECK IN", icon: "arrow.right.circle.fill", color: .blue) {
                                dataManager.updateStatus(for: visitor.id, to: .checkedIn)
                            }
                            StatusButton(title: "CHECK OUT", icon: "arrow.left.circle.fill", color: .gray) {
                                dataManager.updateStatus(for: visitor.id, to: .checkedOut)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .offset(y: appearAnimated ? 0 : 20)
                    .opacity(appearAnimated ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: appearAnimated)
                    
                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(red: 0.95, green: 0.96, blue: 0.98).ignoresSafeArea())
        .onAppear {
            withAnimation { appearAnimated = true }
        }
    }
}

struct DetailInfoRow: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 14, weight: .bold)).foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.85))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct StatusButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 16))
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}
