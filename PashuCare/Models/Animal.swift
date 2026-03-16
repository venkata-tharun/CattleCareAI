import SwiftUI

enum AnimalStatus: String, CaseIterable, Identifiable, Codable {
    case healthy = "Healthy"
    case sick = "Sick"
    case underTreatment = "Under Treatment"

    var id: String { rawValue }

    var pillBackground: Color {
        switch self {
        case .healthy: return Color.green.opacity(0.18)
        case .sick: return Color.red.opacity(0.18)
        case .underTreatment: return Color.yellow.opacity(0.22)
        }
    }

    var pillText: Color {
        switch self {
        case .healthy: return Color.green
        case .sick: return Color.red
        case .underTreatment: return Color.orange
        }
    }
}

struct Animal: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
    let tag: String
    let breed: String
    var age: String = ""
    var weight: String = ""
    var gender: String = "Female"
    let status: AnimalStatus

    enum CodingKeys: String, CodingKey {
        case id, name, tag, breed, age, weight, gender, status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        tag = try container.decode(String.self, forKey: .tag)
        breed = try container.decode(String.self, forKey: .breed)
        age = try container.decodeIfPresent(String.self, forKey: .age) ?? ""
        weight = try container.decodeIfPresent(String.self, forKey: .weight) ?? ""
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? "Female"
        status = try container.decode(AnimalStatus.self, forKey: .status)
    }

    // Default init for previews/mocking if needed
    init(id: Int, name: String, tag: String, breed: String, age: String, weight: String, gender: String, status: AnimalStatus) {
        self.id = id
        self.name = name
        self.tag = tag
        self.breed = breed
        self.age = age
        self.weight = weight
        self.gender = gender
        self.status = status
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let second = parts.dropFirst().first?.first.map(String.init) ?? ""
        let two = (first + second)
        return two.isEmpty ? String(name.prefix(2)).uppercased() : two.uppercased()
    }
}

struct HealthRecord: Identifiable, Codable, Hashable {
    let id: Int
    let date: String
    let title: String
    var doctor: String? = ""
    var treatment: String? = ""
    var cost: String? = ""
    let status: String
}

struct Vaccination: Identifiable, Codable, Hashable {
    let id: Int
    let vaccineName: String
    let dateGiven: String
    let nextDueDate: String
    let batchNumber: String
}
