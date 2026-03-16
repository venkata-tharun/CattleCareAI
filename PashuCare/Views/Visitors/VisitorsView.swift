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
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 0) {
                HStack {
                    Button {
                        router.pop()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 59/255, green: 130/255, blue: 246/255))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                    Text("VISITORS MANAGEMENT")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .tracking(1.0)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                Divider().opacity(0.1)
            }
            .background(Color.white)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Metrics Grid
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            MetricCard(title: "Total Today", value: "\(dataManager.todayVisitorsCount)")
                            MetricCard(title: "Pending", value: "\(dataManager.pendingCount)")
                        }
                        
                        HStack(spacing: 12) {
                            MetricCard(title: "Approved", value: "\(dataManager.approvedCount)")
                            MetricCard(title: "Checked Out", value: "\(dataManager.checkedOutCount)")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        ActionButton(title: "Add Visitor", icon: "plus.circle.fill") {
                            router.push(.addVisitor)
                        }
                        
                        ActionButton(title: "View All Visitors", icon: "list.bullet") {
                            router.push(.visitorList)
                        }
                        
                        ActionButton(title: "Visitor Reports", icon: "chart.bar.doc.horizontal") {
                            router.push(.reportDetail(.visitors))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 40)
                    
                    // Time Indicator at bottom
                    VStack(spacing: 4) {
                        Text(Date().formattedTime())
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea())
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.black)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(Color(red: 59/255, green: 130/255, blue: 246/255))
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

// MARK: - Add Visitor View
struct AddVisitorView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: VisitorDataManager
    
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
    
    init(existingVisitor: Visitor? = nil) {
        self.existingVisitor = existingVisitor
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    router.pop()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 59/255, green: 130/255, blue: 246/255))
                }
                Spacer()
                Text(existingVisitor == nil ? "Add Visitor" : "Edit Visitor")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Color.clear.frame(width: 60, height: 44) // Placeholder for alignment
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    if showError {
                        Text("Please fill out required fields (*)")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    }
                    
                    // SECTION 1
                    VStack(alignment: .leading, spacing: 16) {
                        Text("VISITOR INFORMATION")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Divider()
                        
                        SimpleTextField(title: "Visitor Name *", placeholder: "Full Name", text: $name)
                        SimpleTextField(title: "Phone Number *", placeholder: "10-digit number", text: $phone, keyboardType: .numberPad)
                        SimpleTextField(title: "Purpose of Visit", placeholder: "eg. Milk Collection", text: $purpose)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // SECTION 2
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MEETING DETAILS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Divider()
                        
                        CustomDatePickerField(
                            icon: "calendar",
                            label: "Date",
                            date: $date
                        )
                        
                        CustomDatePickerField(
                            icon: "clock",
                            label: "Entry Time",
                            date: $entryTime,
                            isDateTime: true
                        )
                        
                        CustomDatePickerField(
                            icon: "clock.fill",
                            label: "Outgoing Time",
                            date: $outgoingTime,
                            isDateTime: true
                        )
                        
                        SimpleTextField(title: "Person to Meet", placeholder: "Staff Name", text: $personToMeet)
                    }
                    .padding(.horizontal, 24)
                    
                    // SECTION 3
                    VStack(alignment: .leading, spacing: 16) {
                        Text("OTHER DETAILS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Divider()
                        
                        SimpleTextField(title: "Vehicle Number", placeholder: "Optional", text: $vehicleNumber)
                        SimpleTextField(title: "Notes", placeholder: "Any extra notes...", text: $notes)
                    }
                    .padding(.horizontal, 24)
                    
                    // SPACE
                    Spacer().frame(height: 30)
                    
                    Button {
                        if name.isEmpty || phone.isEmpty {
                            showError = true
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
                        Text("SAVE VISITOR")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 59/255, green: 130/255, blue: 246/255))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
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
        }
    }
}

struct SimpleTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .keyboardType(keyboardType)
                .padding(.vertical, 4)
            
            Divider()
        }
    }
}


// MARK: - Visitor List View
struct VisitorListView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: VisitorDataManager
    
    @State private var searchText = ""
    
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
            // Header
            HStack {
                Button {
                    router.pop()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 59/255, green: 130/255, blue: 246/255))
                }
                Spacer()
                Text("All Visitors")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Color.clear.frame(width: 60, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            Divider()
            
            VStack(spacing: 0) {
                // Search Box
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by name or phone...", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider().opacity(0.1)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        if filteredVisitors.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "person.2.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No visitors found")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(filteredVisitors) { visitor in
                                VisitorRow(visitor: visitor) {
                                    router.push(.visitorDetail(visitor))
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea())
    }
}

struct VisitorRow: View {
    let visitor: Visitor
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(red: 59/255, green: 130/255, blue: 246/255))
                                .font(.system(size: 16))
                            Text(visitor.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                            Text(visitor.phone)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                            Text("\(visitor.entryTime.formattedTime()) → \(visitor.outgoingTime.formattedTime())")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: visitor.status.icon)
                        Text(visitor.status.rawValue)
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(visitor.status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(visitor.status.color.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Divider().opacity(0.1)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }
}


// MARK: - Visitor Detail View
struct VisitorDetailView: View {
    let visitorParam: Visitor
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: VisitorDataManager
    
    // We bind to the specific visitor in data manager
    var visitor: Visitor {
        dataManager.visitors.first(where: { $0.id == visitorParam.id }) ?? visitorParam
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    router.pop()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 59/255, green: 130/255, blue: 246/255))
                }
                Spacer()
                Text("Visitor Details")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                // Edit feature could go here, omitting for simplicity/adherence to mockup
                Color.clear.frame(width: 60, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 8) {
                        Text("👤 \(visitor.name)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Divider()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // INFO GRID
                    VStack(spacing: 16) {
                        DetailInfoRow(title: "📞 Phone Number", value: visitor.phone)
                        DetailInfoRow(title: "🎯 Purpose", value: visitor.purpose.isEmpty ? "-" : visitor.purpose)
                        DetailInfoRow(title: "📅 Date", value: visitor.date.formattedDate())
                        DetailInfoRow(title: "⏰ Entry Time", value: visitor.entryTime.formattedTime())
                        DetailInfoRow(title: "⏰ Outgoing Time", value: visitor.outgoingTime.formattedTime())
                        DetailInfoRow(title: "👤 Person to Meet", value: visitor.personToMeet.isEmpty ? "-" : visitor.personToMeet)
                        DetailInfoRow(title: "🚗 Vehicle", value: visitor.vehicleNumber.isEmpty ? "No Vehicle" : visitor.vehicleNumber)
                        DetailInfoRow(title: "📝 Notes", value: visitor.notes.isEmpty ? "-" : visitor.notes)
                    }
                    .padding(.horizontal, 24)
                    
                    Divider()
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    
                    // STATUS BAR
                    HStack {
                        Text("Current Status:")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Text(visitor.status.rawValue)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(visitor.status.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(visitor.status.color.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)
                    
                    // ACTION BUTTONS TO CHANGE STATUS
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            StatusButton(title: "APPROVE", color: Color(red: 34/255, green: 197/255, blue: 94/255)) {
                                dataManager.updateStatus(for: visitor.id, to: .approved)
                            }
                            StatusButton(title: "REJECT", color: Color(red: 239/255, green: 68/255, blue: 68/255)) {
                                dataManager.updateStatus(for: visitor.id, to: .rejected)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            StatusButton(title: "CHECK IN", color: Color(red: 59/255, green: 130/255, blue: 246/255)) {
                                dataManager.updateStatus(for: visitor.id, to: .checkedIn)
                            }
                            StatusButton(title: "CHECK OUT", color: Color(red: 107/255, green: 114/255, blue: 128/255)) {
                                dataManager.updateStatus(for: visitor.id, to: .checkedOut)
                            }
                        }
                        
                        Spacer().frame(height: 10)
                        
                        HStack(spacing: 16) {
                            SimpleOutlineButton(title: "Back to List") {
                                router.pop() // Goes back to list
                            }
                            SimpleOutlineButton(title: "Home") {
                                router.popToRoot() // Goes back to dashboard
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
}

struct DetailInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.leading, 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StatusButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(color)
                .cornerRadius(8)
        }
    }
}

struct SimpleOutlineButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 59/255, green: 130/255, blue: 246/255))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 59/255, green: 130/255, blue: 246/255), lineWidth: 1.5))
        }
    }
}
