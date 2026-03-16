import SwiftUI
import Combine

@MainActor
class LogsDataManager: ObservableObject {
    @Published var logs: [FarmLog] = []
    
    init() { loadData() }
    
    func loadData() {
        NetworkManager.shared.getLogs { [weak self] raw in
            guard let self = self else { return }
            self.logs = raw.compactMap { dict -> FarmLog? in
                guard
                    let idNum = dict["id"] as? Int,
                    let typeStr = dict["type"] as? String,
                    let dateStr = dict["date"] as? String,
                    let desc = dict["description"] as? String
                else { return nil }
                
                let type = LogType(rawValue: typeStr) ?? .health
                return FarmLog(
                    id: String(idNum),
                    type: type,
                    date: dateStr,
                    description: desc,
                    animalId: dict["animalId"] as? String ?? dict["animal_id"] as? String
                )
            }
        }
    }
    
    func addLog(_ log: FarmLog) {
        NetworkManager.shared.addLog([
            "type": log.type.rawValue,
            "date": log.date,
            "description": log.description,
            "animalId": log.animalId ?? ""
        ]) { [weak self] success in
            if success { self?.loadData() }
        }
    }
    
    func updateLog(_ log: FarmLog) {
        guard let idInt = Int(log.id) else { return }
        NetworkManager.shared.updateLog(id: idInt, body: [
            "type": log.type.rawValue,
            "date": log.date,
            "description": log.description,
            "animalId": log.animalId ?? ""
        ]) { [weak self] success in
            if success { self?.loadData() }
        }
    }
    
    func deleteLog(id: String) {
        guard let idInt = Int(id) else { return }
        NetworkManager.shared.deleteLog(id: idInt) { [weak self] success in
            if success { self?.loadData() }
        }
    }
}
