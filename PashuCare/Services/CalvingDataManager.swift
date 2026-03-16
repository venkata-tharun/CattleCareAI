import SwiftUI
import Combine

@MainActor
class CalvingDataManager: ObservableObject {
    @Published var records: [CalvingRecord] = []

    init() { loadData() }

    func loadData() {
        NetworkManager.shared.getCalvingRecords { [weak self] raw in
            guard let self else { return }
            let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
            self.records = raw.compactMap { dict -> CalvingRecord? in
                guard
                    let id      = dict["id"] as? Int,
                    let name    = dict["animalName"] as? String ?? dict["animal_name"] as? String,
                    let dateStr = dict["breedingDate"] as? String ?? dict["breeding_date"] as? String,
                    let date    = df.date(from: dateStr)
                else { return nil }
                return CalvingRecord(id: id, animalName: name, breedingDate: date)
            }
        }
    }

    func addRecord(_ record: CalvingRecord) {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        NetworkManager.shared.addCalvingRecord([
            "animalName":   record.animalName,
            "breedingDate": df.string(from: record.breedingDate),
        ]) { [weak self] _ in self?.loadData() }
    }

    func updateRecord(_ record: CalvingRecord) {
        guard let id = record.id else { return }
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        NetworkManager.shared.updateCalvingRecord(id: id, body: [
            "animalName":   record.animalName,
            "breedingDate": df.string(from: record.breedingDate)
        ]) { [weak self] _ in self?.loadData() }
    }

    func deleteRecord(_ id: Int) {
        NetworkManager.shared.deleteCalvingRecord(id: id) { [weak self] _ in
            self?.loadData()
        }
    }
}
