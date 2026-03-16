import SwiftUI

// MARK: - Entry Screen

struct NewMilkEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var milkDataManager: MilkDataManager

    var existingEntry: MilkEntry?
    @State private var entry: MilkEntry

    init(existingEntry: MilkEntry? = nil) {
        self.existingEntry = existingEntry
        if let existing = existingEntry {
            _entry = State(initialValue: existing)
        } else {
            _entry = State(initialValue: MilkEntry())
        }
    }

    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        return f
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Text(existingEntry != nil ? "Edit Milk" : "New Milk")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.leading, 12)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Milk Type
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 4) {
                                Image(systemName: "container.rate") // Closest to milk bottle icon
                                    .foregroundColor(.gray)
                                Text("Milk Type")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            
                            HStack(spacing: 12) {
                                milkTypeButton(title: "Bulk Milk", isSelected: entry.milkType == .bulk) {
                                    entry.milkType = .bulk
                                }
                                milkTypeButton(title: "Individual Milk", isSelected: entry.milkType == .individual) {
                                    entry.milkType = .individual
                                }
                            }
                        }
                        
                        // Date
                        CustomDatePickerField(
                            icon: "calendar",
                            label: "Enter your Date",
                            date: $entry.date
                        )
                        
                        // Cattle Tag No (Only for Individual)
                        if entry.milkType == .individual {
                            outlinedField(label: "Cattle Tag No.", icon: "person.text.rectangle", isRequired: true) {
                                HStack {
                                    TextField("Enter cattle tag", text: $entry.cattleTag)
                                        .font(.system(size: 16))
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // AM / Noon / PM
                        HStack(spacing: 12) {
                            miniOutlinedField(label: "Am", value: $entry.am)
                            miniOutlinedField(label: "Noon", value: $entry.noon)
                            miniOutlinedField(label: "Pm", value: $entry.pm)
                        }
                        
                        // Total Milk Product
                        outlinedField(label: "Total Milk Product", icon: "container.rate") {
                            Text(String(format: "%.1f", entry.totalMilkProduced))
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.cyan.opacity(0.8), lineWidth: 1.5)
                        )
                        
                        // Total Used
                        outlinedField(label: "Total Used", icon: "container.rate") {
                            TextField("0.0", value: $entry.totalUsed, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 16))
                        }
                        
                        // Cow Milked number (Only for Bulk)
                        if entry.milkType == .bulk {
                            outlinedField(label: "Cow Milked number", icon: "container.rate") {
                                TextField("0", value: $entry.cowMilkedNumber, format: .number)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 16))
                            }
                        }
                        
                        // Note
                        VStack(alignment: .leading, spacing: -8) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                                Text("Note")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.leading, 12)
                            .padding(.top, 8)
                            .zIndex(1)
                            
                            TextEditor(text: $entry.note)
                                .frame(height: 100)
                                .padding(12)
                                .padding(.top, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        Spacer().frame(height: 100) // Padding for the floating button
                    }
                    .padding(16)
                }
            }
            
            // Save Button
            VStack {
                Spacer()
                Button {
                    milkDataManager.addEntry(entry) { success in
                        if success {
                            DispatchQueue.main.async {
                                dismiss()
                            }
                        }
                    }
                } label: {
                    Text("Save")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.cyan)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(Color.white)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            if let existing = existingEntry {
                self.entry = existing
            }
        }
    }
    
    @ViewBuilder
    private func milkTypeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .cyan : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.cyan : Color.gray.opacity(0.3), lineWidth: 1.5)
                )
        }
    }
    
    @ViewBuilder
    private func outlinedField<Content: View>(label: String, icon: String, isRequired: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                if isRequired {
                    Text("*").foregroundColor(.red)
                }
            }
            .padding(.horizontal, 4)
            .background(Color.white)
            .offset(x: 12, y: 8)
            .zIndex(1)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
                content()
            }
            .padding(.horizontal, 12)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    @ViewBuilder
    private func miniOutlinedField(label: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
                .background(Color.white)
                .offset(x: 12, y: 8)
                .zIndex(1)
            
            HStack(spacing: 8) {
                Image(systemName: "container.rate")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                TextField("0.0", value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15))
            }
            .padding(.horizontal, 10)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - List View

struct MilkRecordListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: MilkDataManager
    
    @State private var selectedDate = Date()
    
    private var filteredRecords: [MilkEntry] {
        dataManager.records.filter { record in
            Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.cyan)
                            .font(.system(size: 18))
                        
                        DatePicker(
                            "Choose date",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .tint(.cyan)
                        .scaleEffect(0.9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.leading, 8)
                    
                    Button {
                        router.push(.equipments)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.cyan)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Milk Record")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal, 16)
                        
                        if filteredRecords.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.3))
                                    .padding(.top, 40)
                                
                                Text("No records found for this date")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Button {
                                    selectedDate = Date()
                                } label: {
                                    Text("Reset to Today")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.cyan)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .stroke(Color.cyan, lineWidth: 1)
                                        )
                                }
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            ForEach(filteredRecords) { record in
                                MilkRecordCard(record: record, onEdit: {
                                    router.push(.editMilk(record))
                                }, onDelete: {
                                    if let bid = record.backendId {
                                        dataManager.deleteEntry(backendId: bid)
                                    }
                                })
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            
            // FAB
            Button {
                router.push(.milk)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.cyan)
                    .clipShape(Circle())
                    .shadow(color: Color.cyan.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(24)
        }
        .navigationBarHidden(true)
        .onAppear { dataManager.loadData() }
    }
}

struct MilkRecordCard: View {
    let record: MilkEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        return f
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text(Self.df.string(from: record.date))
                            .font(.system(size: 15))
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "container.rate")
                            .foregroundColor(.gray)
                        if record.milkType == .bulk {
                            Text("\(record.milkType.rawValue)(\(record.cowMilkedNumber))")
                                .font(.system(size: 15))
                        } else {
                            Text(record.milkType.rawValue)
                                .font(.system(size: 15))
                        }
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                }
            }
            .padding(16)
            
            // Table
            HStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("Total Milk(L)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(String(format: "%.2f", record.totalMilkProduced))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.cyan)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 40)
                
                VStack(spacing: 8) {
                    Text("Used")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(String(format: "%.2f", record.totalUsed))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 40)
                
                VStack(spacing: 8) {
                    Text("UnUsed")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(String(format: "%.2f", record.remaining))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MilkRecordListView()
            .environmentObject(NavigationRouter())
    }
}
