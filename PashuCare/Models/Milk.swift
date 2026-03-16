import Foundation

enum MilkType: String, CaseIterable, Identifiable, Hashable {
    case bulk = "Bulk Milk"
    case individual = "Individual Milk"
    var id: String { rawValue }
}

struct MilkEntry: Hashable, Identifiable {
    var id = UUID()
    var backendId: Int? = nil   // server-side primary key for delete
    var milkType: MilkType = .bulk
    var date: Date = Date()
    var cattleTag: String = ""

    var am: Double = 0
    var noon: Double = 0
    var pm: Double = 0

    var totalUsed: Double = 0
    var cowMilkedNumber: Int = 0
    var note: String = ""

    // Computed
    var totalMilkProduced: Double { am + noon + pm }
    var remaining: Double { max(0, totalMilkProduced - totalUsed) }
}
