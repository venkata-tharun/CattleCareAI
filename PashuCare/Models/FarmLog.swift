import Foundation

enum LogType: String, CaseIterable, Identifiable, Codable, Hashable {
    case health = "Health"
    case milk = "Milk"
    case feeding = "Feeding"
    var id: String { rawValue }
}

struct FarmLog: Identifiable, Codable, Hashable {
    let id: String
    let type: LogType
    let date: String
    let description: String
    let animalId: String?
}
