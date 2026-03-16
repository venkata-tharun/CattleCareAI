import SwiftUI
import Combine

@MainActor
final class AnimalDataManager: ObservableObject {
    @Published var animals: [Animal] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?

    static let shared = AnimalDataManager()
    
    init() {
        fetchAnimals()
    }

    func fetchAnimals() {
        isLoading = true
        NetworkManager.shared.getAnimals { [weak self] fetchedAnimals in
            guard let self = self else { return }
            self.animals = fetchedAnimals
            self.isLoading = false
            
            // Sync with UserDefaults for dashboard if needed
            UserDefaults.standard.set(fetchedAnimals.count, forKey: "totalAnimals")
        }
    }

    func addAnimal(body: [String: Any], completion: @escaping (Bool) -> Void) {
        isLoading = true
        NetworkManager.shared.addAnimal(body) { [weak self] success in
            guard let self = self else { return }
            if success {
                // Refresh list after adding
                self.fetchAnimals()
            }
            self.isLoading = false
            completion(success)
        }
    }
    
    func deleteAnimal(id: Int) {
        NetworkManager.shared.deleteAnimal(id: id) { [weak self] success in
            if success {
                self?.fetchAnimals()
            }
        }
    }
}
