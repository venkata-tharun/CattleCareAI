import SwiftUI
import Combine

struct StockActivityEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let itemName: String
    let amountAdded: Double
    let date: Date
    
    init(id: UUID = UUID(), itemName: String, amountAdded: Double, date: Date = Date()) {
        self.id = id
        self.itemName = itemName
        self.amountAdded = amountAdded
        self.date = date
    }
}

@MainActor
final class FeedDataManager: ObservableObject {
    @Published var stockItems: [FeedStockItem] = []
    @Published var stockActivity: [StockActivityEntry] = []
    @Published var feedingEntries: [FeedingEntry] = []
    
    init() {
        loadData()
    }
    
    func addStock(to itemName: String, amount: Double, completion: @escaping (Bool) -> Void = { _ in }) {
        let body: [String: Any] = [
            "itemName": itemName,
            "amountAdded": amount
        ]
        NetworkManager.shared.addFeedStock(body) { [weak self] success in
            if success {
                self?.loadData()
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func addFeedingEntry(_ entry: FeedingEntry) {
        NetworkManager.shared.addFeedEntry([
            "date": entry.date, // "yyyy-MM-dd"
            "feedTime": entry.time.rawValue,
            "feedType": entry.feedType.rawValue,
            "quantity": entry.quantity,
            "notes": entry.notes
        ]) { [weak self] success in
            if success { self?.loadData() }
        }
    }
    
    func loadData() {
        NetworkManager.shared.getFeedStock { [weak self] raw in
            guard let self = self else { return }
            self.stockItems = raw.compactMap { dict -> FeedStockItem? in
                guard let name = dict["name"] as? String else { return nil }
                
                let quantity: Double = {
                    if let d = dict["quantity"] as? Double { return d }
                    if let i = dict["quantity"] as? Int { return Double(i) }
                    if let s = dict["quantity"] as? String, let d = Double(s) { return d }
                    return 0.0
                }()
                let statusStr = dict["status"] as? String ?? "Good"
                return FeedStockItem(
                    name: name,
                    quantityValue: quantity,
                    status: FeedStockStatus(rawValue: statusStr) ?? .good
                )
            }
        }
        
        NetworkManager.shared.getFeedActivity { [weak self] raw in
            guard let self = self else { return }
            self.stockActivity = raw.compactMap { dict -> StockActivityEntry? in
                guard
                    let name = dict["itemName"] as? String ?? dict["item_name"] as? String,
                    let amt  = dict["amountAdded"] as? Double ?? dict["amount_added"] as? Double,
                    let dateStr = dict["date"] as? String
                else { return nil }
                let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
                let date = df.date(from: dateStr) ?? Date()
                return StockActivityEntry(itemName: name, amountAdded: amt, date: date)
            }
        }

        NetworkManager.shared.getFeedEntries { [weak self] raw in
            guard let self = self else { return }
            self.feedingEntries = raw.compactMap { dict -> FeedingEntry? in
                guard
                    let date = dict["date"] as? String,
                    let qt   = (dict["quantity"] as? NSNumber)?.doubleValue
                else { return nil }
                
                let time = FeedTime(rawValue: dict["feedTime"] as? String ?? dict["feed_time"] as? String ?? "Morning") ?? .morning
                let type = FeedType(rawValue: dict["feedType"] as? String ?? dict["feed_type"] as? String ?? "Mixed Ration (TMR)") ?? .mixedRation
                
                return FeedingEntry(
                    date: date,
                    time: time,
                    feedType: type,
                    quantity: qt,
                    notes: dict["notes"] as? String ?? ""
                )
            }
        }
    }
}
