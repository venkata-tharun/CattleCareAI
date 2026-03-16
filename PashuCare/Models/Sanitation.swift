import Foundation

struct SanitationRecord: Codable {
    let score: Int
    let lastUpdated: Date
    let tasksCompleted: Int
    let totalTasks: Int
}
