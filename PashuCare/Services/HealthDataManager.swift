import SwiftUI
import Combine

struct AIHealthEvent: Identifiable, Codable {
    let id: UUID
    let animalName: String
    let diseaseName: String
    let date: String
    let status: String
    let confidence: String
    
    init(id: UUID = UUID(), animalName: String, diseaseName: String, date: String, status: String, confidence: String) {
        self.id = id
        self.animalName = animalName
        self.diseaseName = diseaseName
        self.date = date
        self.status = status
        self.confidence = confidence
    }
}

struct DiseasePrediction: Hashable {
    let diseaseName: String
    let confidence: String
    let status: String
    let symptoms: [String]
    let precautions: [String]
}

@MainActor
final class HealthDataManager: ObservableObject {
    @Published var healthEvents: [AIHealthEvent] = []
    
    private let saveKey = "SavedAIHealthEvents"
    
    init() {
        loadData()
    }
    
    func addEvent(_ event: AIHealthEvent) {
        healthEvents.insert(event, at: 0)
        saveData()
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(healthEvents) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func fetchEvents() {
        NetworkManager.shared.getAIPredictions { results in
            let fetched = results.compactMap { dict -> AIHealthEvent? in
                guard
                    let idString = dict["uuid"] as? String,
                    let disease = dict["disease_name"] as? String,
                    let confidence = dict["confidence"] as? String,
                    let status = dict["status"] as? String,
                    let date = dict["created_at"] as? String
                else {
                    return nil
                }
                
                // Parse UUID optionally, then coalesce outside the guard
                let uuid = UUID(uuidString: idString) ?? UUID()
                
                return AIHealthEvent(
                    id: uuid,
                    animalName: "Unknown Animal",
                    diseaseName: disease,
                    date: date,
                    status: status,
                    confidence: confidence
                )
            }
            self.healthEvents = fetched
            self.saveData()
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([AIHealthEvent].self, from: data) {
            healthEvents = decoded
        }
        
        // Also fetch from backend to keep in sync
        fetchEvents()
    }
}
