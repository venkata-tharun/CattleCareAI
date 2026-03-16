import Foundation

struct CalvingRecord: Identifiable, Codable, Hashable {
    var id: Int?
    var animalName: String
    var breedingDate: Date
    
    static let gestationDays: Int = 283
    
    var expectedCalvingDate: Date {
        Calendar.current.date(byAdding: .day, value: Self.gestationDays, to: breedingDate) ?? breedingDate
    }
    
    var remainingDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let calvingDay = calendar.startOfDay(for: expectedDate) // Wait, I used expectedDate in my thought, let's fix to expectedCalvingDate
        let components = calendar.dateComponents([.day], from: today, to: calvingDay)
        return max(0, components.day ?? 0)
    }
    
    private var expectedDate: Date { expectedCalvingDate }
}
