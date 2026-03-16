import SwiftUI
import Combine

@MainActor
class MilkDataManager: ObservableObject {
    @Published var records: [MilkEntry] = []
    
    struct ProducerStats {
        let tag: String
        let avgProduction: Double
    }

    var topProducer: ProducerStats? {
        // Only calculate for individual milk
        let individualRecords = records.filter { $0.milkType == .individual && !$0.cattleTag.isEmpty }
        guard !individualRecords.isEmpty else { return nil }

        let grouped = Dictionary(grouping: individualRecords, by: { $0.cattleTag })
        
        let stats = grouped.map { (tag, entries) -> ProducerStats in
            let total = entries.reduce(0) { $0 + $1.totalMilkProduced }
            let avg = total / Double(entries.count)
            return ProducerStats(tag: tag, avgProduction: avg)
        }
        
        return stats.max(by: { $0.avgProduction < $1.avgProduction })
    }
    
    init() { loadData() }
    
    func loadData() {
        NetworkManager.shared.getMilkEntries { [weak self] raw in
            guard let self = self else { return }
            self.records = raw.compactMap { dict -> MilkEntry? in
                let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
                let typeStr = dict["milkType"] as? String ?? "Bulk Milk"
                let dateStr = dict["date"] as? String ?? ""
                let date = df.date(from: dateStr) ?? Date()
                let am   = (dict["am"]   as? NSNumber)?.doubleValue ?? 0.0
                let noon = (dict["noon"] as? NSNumber)?.doubleValue ?? 0.0
                let pm   = (dict["pm"]   as? NSNumber)?.doubleValue ?? 0.0
                let used = (dict["totalUsed"] as? NSNumber)?.doubleValue ?? 0.0
                let tag  = dict["cattleTag"] as? String ?? ""
                let cowNum  = (dict["cowMilkedNumber"] as? NSNumber)?.intValue ?? 0
                let note    = dict["note"] as? String ?? ""
                let backendId = dict["id"] as? Int

                return MilkEntry(
                    backendId: backendId,
                    milkType: MilkType(rawValue: typeStr) ?? .bulk,
                    date: date,
                    cattleTag: tag,
                    am: am,
                    noon: noon,
                    pm: pm,
                    totalUsed: used,
                    cowMilkedNumber: cowNum,
                    note: note
                )
            }
        }
    }
    
    func addEntry(_ entry: MilkEntry, completion: @escaping (Bool) -> Void) {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        let body: [String: Any] = [
            "milkType": entry.milkType.rawValue,
            "date": df.string(from: entry.date),
            "cattleTag": entry.cattleTag,
            "am": entry.am,
            "noon": entry.noon,
            "pm": entry.pm,
            "totalUsed": entry.totalUsed,
            "cowMilkedNumber": entry.cowMilkedNumber,
            "note": entry.note
        ]
        
        if let bid = entry.backendId {
            NetworkManager.shared.updateMilkEntry(id: bid, body: body) { success in
                if success { self.loadData() }
                completion(success)
            }
        } else {
            NetworkManager.shared.addMilkEntry(body) { success in
                if success { self.loadData() }
                completion(success)
            }
        }
    }

    func deleteEntry(backendId: Int) {
        NetworkManager.shared.deleteMilkEntry(id: backendId) { [weak self] _ in
            self?.loadData()
        }
    }
}
