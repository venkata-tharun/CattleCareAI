import Foundation

struct TransactionItem: Identifiable, Codable, Hashable {
    let id: Int
    let category: String // "Income" or "Expense"
    let date: Date
    let type: String
    let amount: Double
    let receiptNo: String
    let note: String

    init(id: Int, category: String, date: Date, type: String, amount: Double, receiptNo: String = "", note: String = "") {
        self.id = id
        self.category = category
        self.date = date
        self.type = type
        self.amount = amount
        self.receiptNo = receiptNo
        self.note = note
    }
}
