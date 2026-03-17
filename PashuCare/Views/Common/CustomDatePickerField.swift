import SwiftUI

struct CustomDatePickerField: View {
    let icon: String
    let label: String
    @Binding var date: Date
    var isDateTime: Bool = false
    var isTime: Bool = false
    
    @State private var showCalendar = false
    
    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        return f
    }()
    
    private let dtf: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()
    
    var body: some View {
        Button {
            showCalendar = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill((isTime || isDateTime ? Color.blue : Color.green).opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isTime || isDateTime ? .blue : .green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(isTime || isDateTime ? dtf.string(from: date) : df.string(from: date))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: isTime ? "clock" : "calendar")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showCalendar) {
            NavigationStack {
                VStack(spacing: 0) {
                    if isTime {
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                    } else {
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: isDateTime ? [.date, .hourAndMinute] : [.date]
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                    }
                    
                    Spacer()
                }
                .navigationTitle("Select \(label)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showCalendar = false
                        }
                    }
                }
                .presentationDetents(isTime ? [.height(300)] : [.medium, .large])
            }
        }
    }
}
