//
//  AnimalMainView.swift
//  PashuCare
//
//  Created by SAIL on 03/03/26.
//

import SwiftUI

// MARK: - AnimalMainView

struct AnimalMainView: View {

    @EnvironmentObject var router: NavigationRouter
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabRouter: TabRouter // Add tabRouter
    @EnvironmentObject var animalManager: AnimalDataManager

    @State private var searchText: String = ""

    var filteredAnimals: [Animal] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return animalManager.animals }
        return animalManager.animals.filter {
            $0.name.lowercased().contains(q) ||
            $0.tag.lowercased().contains(q) ||
            $0.breed.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header with back button (only shown when not in tab bar)
                if navigationSource == .dashboard {
                    customHeader
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        searchBar

                        if animalManager.isLoading && animalManager.animals.isEmpty {
                            ProgressView()
                                .padding(.top, 40)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(filteredAnimals) { animal in
                                    AnimalRow(animal: animal) {
                                        // Navigate to animal detail
                                        router.push(.animalDetail(animal))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, navigationSource == .tabBar ? 90 : 20) // Adjust bottom padding
                }
                .refreshable {
                    animalManager.fetchAnimals()
                }
            }

            // Floating action button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        router.push(.addAnimal)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, navigationSource == .tabBar ? 16 : 16)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { animalManager.fetchAnimals() }
        .toolbar(navigationSource == .dashboard ? .hidden : .visible, for: .tabBar)
    }

    // Track where this view is being used from
    private var navigationSource: NavigationSource {
        return .dashboard
    }

    // Custom header for when coming from dashboard
    private var customHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.green)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }

            Spacer()

            Text("Animals")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search by name or ID...", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 15, weight: .regular))
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Navigation Source Enum
enum NavigationSource {
    case tabBar
    case dashboard
}

// MARK: - Row

private struct AnimalRow: View {
    let animal: Animal
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Initials avatar
                Text(animal.initials)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Text(animal.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        StatusPill(text: animal.status.rawValue,
                                   bg: animal.status.pillBackground,
                                   fg: animal.status.pillText)

                        Spacer()
                    }

                    Text("\(animal.tag) • \(animal.breed)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Animal Detail View
struct AnimalDetailView: View {
    let animal: Animal
    @EnvironmentObject var router: NavigationRouter
    @Environment(\.dismiss) private var dismiss

    @State private var healthRecords: [HealthRecord] = []
    @State private var vaccinations: [Vaccination] = []
    @State private var isLoadingRecords = false
    @State private var filterDate: Date? = nil
    @State private var showDatePicker = false
    @State private var currentStatus: AnimalStatus = .healthy
    @EnvironmentObject var animalManager: AnimalDataManager

    private var combinedRecords: [HealthRecord] {
        let hr: [HealthRecord] = healthRecords
        let vax: [HealthRecord] = vaccinations.map { v in
            HealthRecord(
                id: v.id,
                date: v.dateGiven,
                title: "🛡️ Vaccination: \(v.vaccineName)",
                doctor: "",
                treatment: v.batchNumber.isEmpty ? "" : "Batch: \(v.batchNumber)",
                cost: "",
                status: "Next Due: \(v.nextDueDate)"
            )
        }
        
        var all: [HealthRecord] = hr + vax
        
        // Filter by date if selected
        if let filter = filterDate {
            let df = DateFormatter(); df.dateFormat = "dd-MM-yyyy"
            let filterStr = df.string(from: filter)
            all = all.filter { $0.date == filterStr }
        }
        
        // Sort newest-first by normalizing dd-MM-yyyy or yyyy-MM-dd to yyyy-MM-dd string
        func normalized(_ dateStr: String) -> String {
            let components = dateStr.split(separator: "-")
            if components.count == 3 {
                if components[0].count == 4 {
                    // Already yyyy-MM-dd
                    return dateStr
                } else if components[2].count == 4 {
                    // dd-MM-yyyy -> yyyy-MM-dd
                    return "\(components[2])-\(components[1])-\(components[0])"
                }
            }
            return dateStr
        }
        
        return all.sorted { (lhs: HealthRecord, rhs: HealthRecord) -> Bool in
            let lk = normalized(lhs.date)
            let rk = normalized(rhs.date)
            return lk > rk
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Premium Header
                    ZStack(alignment: .top) {
                        LinearGradient(colors: [Color.green.opacity(0.12), Color.white], startPoint: .top, endPoint: .bottom)
                            .frame(height: 180)
                            .ignoresSafeArea()

                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.green)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                            }

                            Spacer()

                            Text("Animal Details")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.black.opacity(0.85))

                            Spacer()

                            Color.clear.frame(width: 44, height: 44)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                    }
                    .padding(.bottom, -60)

                    // Animal profile card
                    VStack(spacing: 18) {
                        // Premium Avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.white, Color.green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 110, height: 110)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
                            
                            Text(animal.initials)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                        .padding(.top, 10)

                        VStack(spacing: 6) {
                            Text(animal.name)
                                .font(.system(size: 28, weight: .bold))

                            HStack(spacing: 8) {
                                Menu {
                                    ForEach(AnimalStatus.allCases) { s in
                                        Button {
                                            let oldStatus = currentStatus
                                            currentStatus = s
                                            animalManager.updateAnimalStatus(id: animal.id, animal: animal, newStatus: s) { success in
                                                if !success {
                                                    currentStatus = oldStatus // Revert on failure
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(s.rawValue)
                                                if currentStatus == s {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        StatusPill(text: currentStatus.rawValue,
                                                   bg: currentStatus.pillBackground,
                                                   fg: currentStatus.pillText)
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                                .buttonStyle(.plain)

                                Text("•")
                                    .foregroundColor(.gray.opacity(0.5))

                                Text("\(animal.breed) • \(animal.tag)")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Stats Row (Inside card)
                        HStack(spacing: 0) {
                            miniStat(label: "Age", value: animal.age.isEmpty ? "N/A" : animal.age, icon: "calendar", color: .green)
                            divider
                            miniStat(label: "Weight", value: animal.weight.isEmpty ? "N/A" : "\(animal.weight) kg", icon: "scalemass.fill", color: .blue)
                            divider
                            miniStat(label: "Gender", value: animal.gender, icon: "venus.mars.fill", color: .orange)
                        }
                        .padding(.top, 8)
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(22)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 18)
                    .padding(.top, 20)


                    // Health Records Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Health Records")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.black.opacity(0.85))
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                // Date filter button
                                Button {
                                    showDatePicker.toggle()
                                } label: {
                                    Image(systemName: filterDate == nil ? "calendar" : "calendar.badge.minus")
                                        .font(.system(size: 16))
                                        .foregroundColor(filterDate == nil ? .gray : .red)
                                        .frame(width: 36, height: 36)
                                        .background(Color.gray.opacity(0.08))
                                        .clipShape(Circle())
                                }
                                
                                Menu {
                                    Button {
                                        router.push(.addHealthRecord(animal))
                                    } label: {
                                        Label("Add Health Record", systemImage: "stethoscope")
                                    }
                                    
                                    Button {
                                        router.push(.addVaccineRecord(animal))
                                    } label: {
                                        Label("Add Vaccination", systemImage: "syringe")
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.green)
                                        .shadow(color: Color.green.opacity(0.2), radius: 4, x: 0, y: 3)
                                }
                            }
                        }

                        if showDatePicker {
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { filterDate ?? Date() },
                                    set: { filterDate = $0; showDatePicker = false }
                                ),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .scaleEffect(0.9)
                            .frame(height: 300)
                            .padding(.bottom, 10)
                        }

                        VStack(spacing: 18) {
                            recordsListView
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(22)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 18)
                    .padding(.top, 24)

                    Spacer(minLength: 120)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("🛠 AnimalDetailView: Showing \(animal.name) - Age: \(animal.age), Weight: \(animal.weight)")
            currentStatus = animal.status
            loadRecords()
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private func loadRecords() {
        isLoadingRecords = true
        let dispatchGroup = DispatchGroup()
        
        // Load Health Records
        dispatchGroup.enter()
        NetworkManager.shared.getHealthRecords(animalId: animal.id) { raw in
            print("📥 Received \(raw.count) health records for \(animal.name)")
            let dfIn = DateFormatter(); dfIn.dateFormat = "yyyy-MM-dd"
            let dfOut = DateFormatter(); dfOut.dateFormat = "dd-MM-yyyy"
            
            let records = raw.compactMap { dict -> HealthRecord? in
                guard
                    let id = dict["id"] as? Int,
                    let dateStr = dict["date"] as? String
                else { return nil }
                
                // Keep date as dd-MM-yyyy for display consistency if possible
                let displayDate: String
                if let date = dfIn.date(from: String(dateStr.prefix(10))) {
                    displayDate = dfOut.string(from: date)
                } else {
                    displayDate = dateStr
                }
                
                return HealthRecord(
                    id: id,
                    date: displayDate,
                    title: dict["title"] as? String ?? "Health Visit",
                    doctor: dict["doctor"] as? String ?? "",
                    treatment: dict["treatment"] as? String ?? "",
                    cost: String(describing: dict["cost"] ?? ""),
                    status: dict["status"] as? String ?? "Completed"
                )
            }
            DispatchQueue.main.async { self.healthRecords = records }
            dispatchGroup.leave()
        }
        
        // Load Vaccinations
        dispatchGroup.enter()
        NetworkManager.shared.getVaccinations(animalId: animal.id) { raw in
            print("📥 Received \(raw.count) vaccinations for \(animal.name)")
            let dfIn = DateFormatter(); dfIn.dateFormat = "yyyy-MM-dd"
            let dfOut = DateFormatter(); dfOut.dateFormat = "dd-MM-yyyy"
            
            let vax = raw.compactMap { dict -> Vaccination? in
                guard
                    let id = dict["id"] as? Int,
                    let name = dict["vaccineName"] as? String,
                    let givenStr = dict["dateGiven"] as? String
                else { return nil }
                
                let formattedGiven: String
                if let date = dfIn.date(from: String(givenStr.prefix(10))) {
                    formattedGiven = dfOut.string(from: date)
                } else {
                    formattedGiven = givenStr
                }
                
                let nextDue = dict["nextDueDate"] as? String ?? ""
                let formattedDue: String
                if let date = dfIn.date(from: String(nextDue.prefix(10))) {
                    formattedDue = dfOut.string(from: date)
                } else {
                    formattedDue = nextDue
                }
                
                return Vaccination(
                    id: id,
                    vaccineName: name,
                    dateGiven: formattedGiven,
                    nextDueDate: formattedDue,
                    batchNumber: dict["batchNumber"] as? String ?? ""
                )
            }
            DispatchQueue.main.async { self.vaccinations = vax }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoadingRecords = false
        }
    }

    private func deleteHealthRecord(_ recordId: Int) {
        NetworkManager.shared.deleteHealthRecord(animalId: animal.id, recordId: recordId) { success in
            if success {
                DispatchQueue.main.async { loadRecords() }
            }
        }
    }

    private func deleteVaccination(_ vaxId: Int) {
        NetworkManager.shared.deleteVaccination(animalId: animal.id, vaccinationId: vaxId) { success in
            if success {
                DispatchQueue.main.async { loadRecords() }
            }
        }
    }

    @ViewBuilder
    private var recordsListView: some View {
        if isLoadingRecords && combinedRecords.isEmpty {
            ProgressView()
                .padding()
                .frame(maxWidth: .infinity)
        } else if combinedRecords.isEmpty {
            Text(filterDate == nil ? "No records available" : "No records found for this date")
                .foregroundColor(.secondary)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
        } else {
            ForEach(combinedRecords) { record in
                HealthRecordRow(record: record, onEdit: {
                    if record.title.contains("🛡️ Vaccination:") {
                        if let vax = vaccinations.first(where: { $0.id == record.id }) {
                            router.push(.editVaccineRecord(animal, vax))
                        }
                    } else {
                        router.push(.editHealthRecord(animal, record))
                    }
                }, onDelete: {
                    if record.title.contains("🛡️ Vaccination:") {
                        deleteVaccination(record.id)
                    } else {
                        deleteHealthRecord(record.id)
                    }
                })
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.15))
            .frame(width: 1, height: 26)
            .padding(.horizontal, 5)
    }

    @ViewBuilder
    private func miniStat(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.black.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func statCard(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.green)
            
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}


// MARK: - Supporting Views
struct StatusPill: View {
    let text: String
    let bg: Color
    let fg: Color

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(bg.opacity(0.15))
            .clipShape(Capsule())
    }
}

struct HealthRecordRow: View {
    let record: HealthRecord
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.date)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    Text(record.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Menu {
                    Button { onEdit() } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) { onDelete() } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            HStack(spacing: 12) {
                // Status Pill
                Text(record.status)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.12))
                    .clipShape(Capsule())

                if let doctor = record.doctor, !doctor.isEmpty {
                    Label(doctor, systemImage: "stethoscope")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if let treatment = record.treatment, !treatment.isEmpty {
                Text(treatment)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
            }
            
            if let cost = record.cost, !cost.isEmpty, cost != "0", cost != "0.0" {
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Cost:")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("₹\(cost)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.85))
                    }
                }
            }
            
            if record.id != -1 { // Only show divider if not the last item (simplified check)
                Divider()
                    .padding(.top, 5)
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AnimalMainView()
            .environmentObject(NavigationRouter())
            .environmentObject(TabRouter())
            .environmentObject(AnimalDataManager.shared)
    }
}
