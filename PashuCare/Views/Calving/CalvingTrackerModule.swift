import SwiftUI
import Combine

// MARK: - 1. Tracker Home Screen
struct CalvingTrackerHomeView: View {
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text("Calving Tracker")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(.label))
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 10)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Illustration & Description
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                            .padding(.top, 40)
                        
                        Text("Calving Prediction Tracker")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.black.opacity(0.85))
                        
                        Text("Track breeding date and know the expected calving date of your animal.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .lineSpacing(4)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button {
                            router.push(.addCalvingRecord)
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Add Calving Record")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color(red: 0.18, green: 0.49, blue: 0.20))
                            .cornerRadius(16)
                        }
                        
                        Button {
                            router.push(.calvingRecordsList)
                        } label: {
                            HStack {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 20))
                                Text("View Records")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.18, green: 0.49, blue: 0.20), lineWidth: 1.5)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGray6).opacity(0.3).ignoresSafeArea())
    }
}

// MARK: - 2. Add Calving Record Screen
struct AddCalvingRecordView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: CalvingDataManager
    
    @State private var animalName: String = ""
    @State private var breedingDate: Date = Date()
    @State private var showCalculation: Bool = false
    
    // Derived values
    private var expectedDate: Date {
        Calendar.current.date(byAdding: .day, value: CalvingRecord.gestationDays, to: breedingDate) ?? breedingDate
    }
    
    private var remainingDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let calvingDay = calendar.startOfDay(for: expectedDate)
        let components = calendar.dateComponents([.day], from: today, to: calvingDay)
        return max(0, components.day ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text("Add Record")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(.label))
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 10)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Animal Name")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.black.opacity(0.8))
                        
                        TextField("e.g. Ganga, Moti", text: $animalName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Breeding Date")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.black.opacity(0.8))
                        
                        DatePicker("", selection: $breedingDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            .onChange(of: breedingDate) {
                                showCalculation = false
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    if showCalculation {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Expected Calving")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                                    Text(expectedDate, style: .date)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Remaining")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                                    Text("\(remainingDays) Days")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(20)
                            .background(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 30)
                    
                    VStack(spacing: 16) {
                        if !showCalculation {
                            Button {
                                withAnimation {
                                    showCalculation = true
                                }
                            } label: {
                                Text("Calculate")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color(red: 0.18, green: 0.49, blue: 0.20))
                                    .cornerRadius(16)
                                    .opacity(animalName.isEmpty ? 0.6 : 1.0)
                            }
                            .disabled(animalName.isEmpty)
                        } else {
                            Button {
                                // Save Record
                                let record = CalvingRecord(animalName: animalName, breedingDate: breedingDate)
                                dataManager.addRecord(record)
                                router.push(.calvingRecordDetail(record))
                            } label: {
                                Text("Save Record")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color(red: 0.18, green: 0.49, blue: 0.20))
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGray6).opacity(0.3).ignoresSafeArea())
    }
}

// MARK: - 3. Records List Screen
struct CalvingRecordsListView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: CalvingDataManager
    @State private var recordToDelete: CalvingRecord?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20)) // Dark Farm Green
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text("Saved Records")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(.label))
                
                Spacer()
                
                Button {
                    router.push(.addCalvingRecord)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 10)
            
            Divider()
            
            if dataManager.records.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.5))
                    Text("No Calving Records")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("Add your first breeding record to track expected delivery dates.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(dataManager.records.sorted(by: { $0.expectedCalvingDate < $1.expectedCalvingDate })) { record in
                            CalvingRecordCard(record: record) {
                                router.push(.calvingRecordDetail(record))
                            } onEdit: {
                                router.push(.editCalvingRecord(record))
                            } onDelete: {
                                recordToDelete = record
                                showDeleteConfirmation = true
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGray6).opacity(0.3).ignoresSafeArea())
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Record"),
                message: Text("Are you sure you want to delete the calving record for \(recordToDelete?.animalName ?? "")?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let record = recordToDelete, let id = record.id {
                        dataManager.deleteRecord(id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

// MARK: - Reusable Record Card
struct CalvingRecordCard: View {
    let record: CalvingRecord
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                            .font(.system(size: 18))
                    }
                    
                    Text(record.animalName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Menu {
                        Button("Edit", action: onEdit)
                        Button("Delete", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Expected Calving")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                        Text(record.expectedCalvingDate, style: .date)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Remaining")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                        Text("\(record.remainingDays) Days")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.12))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 4. Record Details Screen
struct CalvingRecordDetailView: View {
    @EnvironmentObject var router: NavigationRouter
    let record: CalvingRecord
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text(record.animalName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(.label))
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 10)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Main Status Card
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 36))
                                .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                        }
                        .padding(.top, 10)
                        
                        VStack(spacing: 8) {
                            Text("Delivery in")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                            Text("\(record.remainingDays) Days")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color.black.opacity(0.9))
                        }
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("Animal Name")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(record.animalName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            
                            HStack {
                                Text("Breeding Date")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(record.breedingDate, style: .date)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            
                            HStack {
                                Text("Expected Calving")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(record.expectedCalvingDate, style: .date)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Actions
                    VStack(spacing: 16) {
                        Button {
                            router.push(.editCalvingRecord(record))
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20))
                                Text("Edit Record")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.18, green: 0.49, blue: 0.20))
                            .cornerRadius(16)
                        }
                        
                        Button {
                            router.push(.calvingRecordsList)
                        } label: {
                            Text("Back to Records")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.18, green: 0.49, blue: 0.20), lineWidth: 1.5)
                                )
                        }
                        
                        Button {
                            router.push(.calvingTrackerHome)
                        } label: {
                            Text("Tracker Home")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGray6).opacity(0.3).ignoresSafeArea())
    }
}

// MARK: - 5. Edit Record Screen
struct EditCalvingRecordView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var dataManager: CalvingDataManager
    
    let originalRecord: CalvingRecord
    
    @State private var animalName: String
    @State private var breedingDate: Date
    
    init(record: CalvingRecord) {
        self.originalRecord = record
        _animalName = State(initialValue: record.animalName)
        _breedingDate = State(initialValue: record.breedingDate)
    }
    
    // Derived values
    private var expectedDate: Date {
        Calendar.current.date(byAdding: .day, value: CalvingRecord.gestationDays, to: breedingDate) ?? breedingDate
    }
    
    private var remainingDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let calvingDay = calendar.startOfDay(for: expectedDate)
        let components = calendar.dateComponents([.day], from: today, to: calvingDay)
        return max(0, components.day ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    router.pop()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Edit Record")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(.label))
                
                Spacer()
                
                // Placeholder for symmetry
                Color.clear
                    .frame(width: 50, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 10)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Animal Name")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.black.opacity(0.8))
                        
                        TextField("e.g. Ganga, Moti", text: $animalName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Breeding Date")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.black.opacity(0.8))
                        
                        DatePicker("", selection: $breedingDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                    
                    // Live Calculation Preview
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Expected Calving")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                                Text(expectedDate, style: .date)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Remaining")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                                Text("\(remainingDays) Days")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(20)
                        .background(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 30)
                    
                    Button {
                        // Update Record
                        var updatedRecord = originalRecord
                        updatedRecord.animalName = animalName
                        updatedRecord.breedingDate = breedingDate
                        dataManager.updateRecord(updatedRecord)
                        
                        router.pop() // Go back to detail
                    } label: {
                        Text("Update Record")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.18, green: 0.49, blue: 0.20))
                            .cornerRadius(16)
                            .opacity(animalName.isEmpty ? 0.6 : 1.0)
                    }
                    .disabled(animalName.isEmpty)
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGray6).opacity(0.3).ignoresSafeArea())
    }
}
