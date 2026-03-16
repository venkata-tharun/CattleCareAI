import SwiftUI

enum VisitorStatus: String, Codable, Hashable, CaseIterable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
    case checkedIn = "Checked In"
    case checkedOut = "Checked Out"
    
    var color: Color {
        switch self {
        case .pending: return Color(red: 234/255, green: 179/255, blue: 8/255) // Yellow
        case .approved: return Color(red: 34/255, green: 197/255, blue: 94/255) // Green
        case .rejected: return Color(red: 239/255, green: 68/255, blue: 68/255) // Red
        case .checkedIn: return Color(red: 59/255, green: 130/255, blue: 246/255) // Blue
        case .checkedOut: return Color(red: 107/255, green: 114/255, blue: 128/255) // Gray
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "hourglass"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .checkedIn: return "arrow.down.right.circle.fill"
        case .checkedOut: return "arrow.up.right.circle.fill"
        }
    }
}

struct Visitor: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var serverId: Int? // Backend primary key
    var name: String
    var phone: String
    var purpose: String
    var date: Date
    var entryTime: Date
    var outgoingTime: Date
    var personToMeet: String
    var vehicleNumber: String
    var notes: String
    var status: VisitorStatus = .pending
}
