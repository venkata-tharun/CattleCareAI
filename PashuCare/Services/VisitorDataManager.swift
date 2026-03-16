import SwiftUI
import Combine

@MainActor
class VisitorDataManager: ObservableObject {
    @Published var visitors: [Visitor] = []

    init() { loadData() }

    func loadData() {
        NetworkManager.shared.getVisitors { [weak self] raw in
            guard let self else { return }
            let iso = ISO8601DateFormatter()
            let dateOnlyFmt: DateFormatter = {
                let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
            }()
            self.visitors = raw.compactMap { dict -> Visitor? in
                guard
                    let name  = dict["name"] as? String,
                    let phone = dict["phone"] as? String
                else { return nil }
                let dateStr  = dict["date"]         as? String ?? ""
                let entryStr = dict["entryTime"]    as? String ?? dict["entry_time"] as? String ?? ""
                let outStr   = dict["outgoingTime"] as? String ?? dict["outgoing_time"] as? String ?? ""
                let date     = dateOnlyFmt.date(from: dateStr) ?? Date()
                let entry    = iso.date(from: entryStr) ?? Date()
                let outgoing = iso.date(from: outStr) ?? Date()
                let rawStatus = dict["status"] as? String ?? "Pending"
                let status: VisitorStatus = {
                    switch rawStatus {
                    case "Approved":     return .approved
                    case "Rejected":     return .rejected
                    case "Checked In":   return .checkedIn
                    case "Checked Out":  return .checkedOut
                    default:             return .pending
                    }
                }()
                return Visitor(
                    id: UUID(),
                    serverId: dict["id"] as? Int,
                    name: name, phone: phone,
                    purpose: dict["purpose"] as? String ?? "",
                    date: date, entryTime: entry, outgoingTime: outgoing,
                    personToMeet: dict["personToMeet"] as? String ?? dict["person_to_meet"] as? String ?? "",
                    vehicleNumber: dict["vehicleNumber"] as? String ?? dict["vehicle_number"] as? String ?? "",
                    notes: dict["notes"] as? String ?? "",
                    status: status
                )
            }
        }
    }

    func addVisitor(_ visitor: Visitor) {
        let iso = ISO8601DateFormatter()
        let df  = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        NetworkManager.shared.addVisitor([
            "name":           visitor.name,
            "phone":          visitor.phone,
            "purpose":        visitor.purpose,
            "date":           df.string(from: visitor.date),
            "entryTime":      iso.string(from: visitor.entryTime),
            "outgoingTime":   iso.string(from: visitor.outgoingTime),
            "personToMeet":   visitor.personToMeet,
            "vehicleNumber":  visitor.vehicleNumber,
            "notes":          visitor.notes,
            "status":         visitor.status.rawValue,
        ]) { [weak self] _ in self?.loadData() }
    }

    func updateVisitor(_ visitor: Visitor) {
        if let index = visitors.firstIndex(where: { $0.id == visitor.id }) {
            visitors[index] = visitor
        }
    }

    func updateStatus(for id: UUID, to status: VisitorStatus) {
        if let index = visitors.firstIndex(where: { $0.id == id }) {
            var v = visitors[index]
            v.status = status
            
            let iso = ISO8601DateFormatter()
            let df  = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
            let body: [String: Any] = [
                "name":           v.name,
                "phone":          v.phone,
                "purpose":        v.purpose,
                "date":           df.string(from: v.date),
                "entryTime":      iso.string(from: v.entryTime),
                "outgoingTime":   iso.string(from: v.outgoingTime),
                "personToMeet":   v.personToMeet,
                "vehicleNumber":  v.vehicleNumber,
                "notes":          v.notes,
                "status":         v.status.rawValue
            ]
            
            visitors[index].status = status
            
            if let serverId = v.serverId {
                NetworkManager.shared.updateVisitor(id: serverId, body: body) { _ in }
            }
        }
    }

    var todayVisitorsCount: Int {
        visitors.filter { Calendar.current.isDateInToday($0.date) }.count
    }
    var pendingCount: Int {
        visitors.filter { $0.status == .pending && Calendar.current.isDateInToday($0.date) }.count
    }
    var approvedCount: Int {
        visitors.filter { $0.status == .approved && Calendar.current.isDateInToday($0.date) }.count
    }
    var checkedOutCount: Int {
        visitors.filter { $0.status == .checkedOut && Calendar.current.isDateInToday($0.date) }.count
    }
}
