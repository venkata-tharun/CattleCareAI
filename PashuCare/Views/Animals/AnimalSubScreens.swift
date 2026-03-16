//
//  AnimalSubScreens.swift
//  PashuCare
//
//  Created by SAIL on 03/03/26.
//

import SwiftUI

// MARK: - Add Animal View

struct AddAnimalView: View {
    @EnvironmentObject var animalManager: AnimalDataManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var tag = ""
    @State private var breed = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var gender = "Female"
    @State private var status: AnimalStatus = .healthy

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.green)
                                .frame(width: 40, height: 40)
                        }
                        Spacer()
                        Text("Add New Animal")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Color.clear.frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)

                    // Avatar Placeholder
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 96, height: 96)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 14) {
                        // Name
                        animalFormCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name *").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                TextField("e.g. Bella", text: $name)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }

                        // Tag
                        animalFormCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tag *").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                TextField("e.g. TG-1234", text: $tag)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }

                        // Breed
                        animalFormCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Breed *").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                TextField("e.g. Holstein", text: $breed)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }

                        // Age & Weight
                        HStack(spacing: 12) {
                            animalFormCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Age *").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                    TextField("e.g. 4 years", text: $age)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            animalFormCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Weight *").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                    TextField("e.g. 650kg", text: $weight)
                                        .keyboardType(.decimalPad)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                        }

                        // Gender
                        animalFormCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Gender").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                HStack(spacing: 12) {
                                    ForEach(["Female", "Male"], id: \.self) { g in
                                        Button { gender = g } label: {
                                            Text(g)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(gender == g ? .white : .primary)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(
                                                    Capsule()
                                                        .fill(gender == g ? Color.green : Color.gray.opacity(0.1))
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        // Health Status
                        animalFormCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Health Status").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                                HStack(spacing: 8) {
                                    ForEach(AnimalStatus.allCases) { s in
                                        Button { status = s } label: {
                                            Text(s.rawValue)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(status == s ? .white : s.pillText)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 7)
                                                .background(
                                                    Capsule()
                                                        .fill(status == s ? s.pillText : s.pillBackground)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        Spacer().frame(height: 80)
                    }
                    .padding(.horizontal, 16)
                }
            }

            Button {
                let animalBody: [String: Any] = [
                    "name": name,
                    "tag": tag,
                    "breed": breed,
                    "age": age,
                    "weight": weight,
                    "gender": gender,
                    "status": status.rawValue
                ]
                animalManager.addAnimal(body: animalBody) { success in
                    if success {
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                }
            } label: {
                Text("Add Animal")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(name.isEmpty || tag.isEmpty ? Color.gray : Color.green)
                    .cornerRadius(28)
            }
            .disabled(name.isEmpty || tag.isEmpty)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private func animalFormCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Add Health Record View

struct AddHealthRecordView: View {
    let animal: Animal
    var recordToEdit: HealthRecord? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var doctor = ""
    @State private var diagnosis = ""
    @State private var treatment = ""
    @State private var cost = ""

    private static let backendDF: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false

    private static let displayDF: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        return f
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.green)
                                .frame(width: 40, height: 40)
                        }
                        Spacer()
                        Text(recordToEdit == nil ? "Add Health Record" : "Edit Health Record")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Color.clear.frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .onAppear {
                        if let record = recordToEdit {
                            self.doctor = record.doctor ?? ""
                            self.diagnosis = record.title
                            self.treatment = record.treatment ?? ""
                            self.cost = record.cost ?? ""
                            
                            let df = DateFormatter(); df.dateFormat = "dd-MM-yyyy"
                            if let d = df.date(from: record.date) {
                                self.date = d
                            }
                        }
                    }

                    // Animal Banner
                    HStack(spacing: 10) {
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Adding record for:")
                                .font(.system(size: 13))
                                .foregroundColor(Color.green.opacity(0.8))
                            Text("\(animal.name) (\(animal.tag))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(14)
                    .padding(.horizontal, 16)

                    VStack(spacing: 14) {
                        // Date
                        CustomDatePickerField(
                            icon: "calendar",
                            label: "Date",
                            date: $date
                        )

                        // Doctor
                        healthCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Veterinarian / Doctor *", systemImage: "stethoscope")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                TextField("Dr. Name", text: $doctor)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }

                        // Diagnosis
                        healthCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Diagnosis / Issues *")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                TextEditor(text: $diagnosis)
                                    .frame(height: 90)
                                    .font(.system(size: 15))
                                    .scrollContentBackground(.hidden)
                                    .overlay(
                                        Group {
                                            if diagnosis.isEmpty {
                                                Text("Describe symptoms and diagnosis...")
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 15))
                                                    .padding(.top, 8)
                                                    .padding(.leading, 4)
                                            }
                                        },
                                        alignment: .topLeading
                                    )
                            }
                        }

                        // Treatment
                        healthCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Treatment / Medication")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                TextEditor(text: $treatment)
                                    .frame(height: 70)
                                    .font(.system(size: 15))
                                    .scrollContentBackground(.hidden)
                                    .overlay(
                                        Group {
                                            if treatment.isEmpty {
                                                Text("Prescribed medicines...")
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 15))
                                                    .padding(.top, 8)
                                                    .padding(.leading, 4)
                                            }
                                        },
                                        alignment: .topLeading
                                    )
                            }
                        }

                        // Cost
                        healthCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Cost (Optional)", systemImage: "indianrupeesign.circle")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                TextField("0.00", text: $cost)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }

                        Spacer().frame(height: 80)
                    }
                    .padding(.horizontal, 16)
                }
            }

            Button {
                isSaving = true
                let dateStr = Self.backendDF.string(from: date)
                
                let recordBody: [String: Any] = [
                    "date": dateStr,
                    "title": diagnosis, // mapping diagnosis to title
                    "doctor": doctor,
                    "treatment": treatment,
                    "cost": cost,
                    "status": "Completed"
                ]
                
                print("📤 Sending Health Record: \(recordBody)")
                
                if let record = recordToEdit {
                    NetworkManager.shared.updateHealthRecord(animalId: animal.id, recordId: record.id, body: recordBody) { success in
                        DispatchQueue.main.async {
                            isSaving = false
                            if success { dismiss() }
                            else { alertMessage = "Failed to update record."; showAlert = true }
                        }
                    }
                } else {
                    NetworkManager.shared.addHealthRecord(animalId: animal.id, body: recordBody) { success in
                        DispatchQueue.main.async {
                            isSaving = false
                            if success {
                                dismiss()
                            } else {
                                alertMessage = "Failed to save record. Please check your connection."
                                showAlert = true
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    if isSaving { ProgressView().tint(.white).padding(.trailing, 8) }
                    Text(isSaving ? "Saving..." : (recordToEdit == nil ? "Save Record" : "Update Record"))
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(diagnosis.isEmpty || doctor.isEmpty || isSaving ? Color.gray : Color.green)
                .cornerRadius(28)
            }
            .disabled(diagnosis.isEmpty || doctor.isEmpty || isSaving)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .alert("Health Record", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private func healthCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Add Vaccine Record View

struct AddVaccineRecordView: View {
    let animal: Animal
    var recordToEdit: Vaccination? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var vaccineName = ""
    @State private var dateGiven = Date()
    @State private var nextDueDate = Date()
    @State private var batchNumber = ""

    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.green)
                                .frame(width: 40, height: 40)
                        }
                        Spacer()
                        Text(recordToEdit == nil ? "Add Vaccination" : "Edit Vaccination")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Color.clear.frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)

                    // Animal Banner
                    HStack(spacing: 10) {
                        Image(systemName: "syringe.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Vaccinating:")
                                .font(.system(size: 13))
                                .foregroundColor(Color.blue.opacity(0.8))
                            Text("\(animal.name) (\(animal.tag))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(14)
                    .padding(.horizontal, 16)

                    VStack(spacing: 14) {
                        // Vaccine Name
                        vaccineCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Vaccine Name *", systemImage: "syringe")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                TextField("e.g. FMD, Brucellosis", text: $vaccineName)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }

                        // Date Given
                        CustomDatePickerField(
                            icon: "calendar.badge.checkmark",
                            label: "Date Administered",
                            date: $dateGiven
                        )

                        // Next Due Date
                        CustomDatePickerField(
                            icon: "calendar.badge.exclamationmark",
                            label: "Next Due Date",
                            date: $nextDueDate
                        )

                        // Batch Number
                        vaccineCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Batch Number (Optional)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                TextField("e.g. VAX-2026-001", text: $batchNumber)
                                    .font(.system(size: 16))
                                    .textInputAutocapitalization(.characters)
                            }
                        }

                        Spacer().frame(height: 80)
                    }
                    .padding(.horizontal, 16)
                }
            }

            Button {
                let vaccineBody: [String: Any] = [
                    "vaccineName": vaccineName,
                    "dateGiven": Self.df.string(from: dateGiven),
                    "nextDueDate": Self.df.string(from: nextDueDate),
                    "batchNumber": batchNumber
                ]
                if let vax = recordToEdit {
                    NetworkManager.shared.updateVaccination(animalId: animal.id, vaccinationId: vax.id, body: vaccineBody) { success in
                        if success {
                            DispatchQueue.main.async { dismiss() }
                        }
                    }
                } else {
                    NetworkManager.shared.addVaccination(animalId: animal.id, body: vaccineBody) { success in
                        if success {
                            DispatchQueue.main.async {
                                dismiss()
                            }
                        }
                    }
                }
            } label: {
                Text(recordToEdit == nil ? "Record Vaccination" : "Update Vaccination")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(28)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private func vaccineCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AddAnimalView()
    }
}
