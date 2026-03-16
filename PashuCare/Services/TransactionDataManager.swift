import SwiftUI
import Combine

@MainActor
final class TransactionDataManager: ObservableObject {
    @Published var transactions: [TransactionItem] = []

    init() { loadData() }

    func loadData() {
        NetworkManager.shared.getTransactions { [weak self] raw in
            guard let self else { return }
            self.transactions = raw.compactMap { dict -> TransactionItem? in
                // Parse amount from multiple possible types
                let amountValue: Double? = {
                    if let n = dict["amount"] as? NSNumber {
                        return n.doubleValue
                    }
                    if let d = dict["amount"] as? Double {
                        return d
                    }
                    if let i = dict["amount"] as? Int {
                        return Double(i)
                    }
                    if let s = dict["amount"] as? String {
                        return Double(s)
                    }
                    return nil
                }()

                guard
                    let category = dict["category"] as? String,
                    let dateStr  = dict["date"] as? String,
                    let type     = dict["type"] as? String,
                    let amount   = amountValue,
                    let id       = dict["id"] as? Int
                else {
                    print("⚠️ TransactionDataManager: Skipping invalid record: \(dict)")
                    return nil
                }

                // Stable date parsing for yyyy-MM-dd
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: dateStr) ?? Date()

                return TransactionItem(
                    id: id,
                    category: category,
                    date: date,
                    type: type,
                    amount: amount,
                    receiptNo: dict["receiptNo"] as? String ?? dict["receipt_no"] as? String ?? "",
                    note: dict["note"] as? String ?? ""
                )
            }
        }
    }

    func addTransaction(_ item: TransactionItem) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        NetworkManager.shared.addTransaction([
            "category":   item.category,
            "date":       df.string(from: item.date),
            "type":       item.type,
            "amount":     item.amount,
            "receiptNo":  item.receiptNo,
            "note":       item.note,
        ]) { [weak self] success in
            if success {
                self?.loadData()
            }
        }
    }

    var totalIncome:  Double { transactions.filter { $0.category == "Income"  }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { transactions.filter { $0.category == "Expense" }.reduce(0) { $0 + $1.amount } }
    var balance:      Double { totalIncome - totalExpense }
}
