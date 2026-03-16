import SwiftUI
import Combine

@MainActor
class SanitationDataManager: ObservableObject {
    @Published var score: Int = 0
    @Published var isSaving: Bool = false
    
    var conditionText: String {
        if score >= 80 { return "Excellent Condition" }
        if score >= 60 { return "Good Condition" }
        if score >= 40 { return "Fair Condition" }
        return "Poor Condition"
    }
    
    var conditionColor: Color {
        if score >= 80 { return .green }
        if score >= 60 { return .blue }
        if score >= 40 { return .orange }
        return .red
    }
    
    init() { fetchScore() }
    
    func fetchScore() {
        NetworkManager.shared.getSanitationScore { [weak self] score in
            self?.score = score
        }
    }
    
    func saveChecklist(tasks: [String: Bool], completion: @escaping (Bool) -> Void) {
        isSaving = true
        let completed = tasks.values.filter { $0 }.count
        let newScore = Int((Double(completed) / Double(tasks.count)) * 100)
        
        let body: [String: Any] = [
            "score": newScore,
            "tasks": tasks
        ]
        
        NetworkManager.shared.saveSanitationChecklist(body) { [weak self] success in
            guard let self = self else { return }
            self.isSaving = false
            if success {
                self.score = newScore
            }
            completion(success)
        }
    }
}
