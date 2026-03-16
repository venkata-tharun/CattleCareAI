import SwiftUI

enum ReportType: String, CaseIterable, Identifiable, Hashable {
    case milk = "milk"
    case health = "health"
    case feeding = "feeding"
    case finance = "finance"
    case visitors = "visitors"
    var id: String { rawValue }

    var title: String {
        switch self {
        case .milk: return "Milk Production Summary"
        case .health: return "Health & Disease Report"
        case .feeding: return "Feeding Efficiency"
        case .finance: return "Finance Summary"
        case .visitors: return "Visitor Analytics"
        }
    }

    var detailTitle: String {
        switch self {
        case .milk: return "Milk Production Report"
        case .health: return "Health & Disease Report"
        case .feeding: return "Feeding Efficiency Report"
        case .finance: return "Finance Report"
        case .visitors: return "Visitor Report"
        }
    }

    var statLine: String {
        switch self {
        case .milk: return "4,520 Liters"
        case .health: return "96% Healthy"
        case .feeding: return "1,200 kg"
        case .finance: return "Transactions"
        case .visitors: return "Visitors"
        }
    }

    var subtext: String {
        switch self {
        case .milk: return "Total this month"
        case .health: return "Herd health status"
        case .feeding: return "Feed consumed"
        case .finance: return "Income & Expense"
        case .visitors: return "Traffic & Logs"
        }
    }

    var icon: String {
        switch self {
        case .milk: return "drop.fill"
        case .health: return "waveform.path.ecg"
        case .feeding: return "chart.line.uptrend.xyaxis"
        case .finance: return "indianrupeesign.circle.fill"
        case .visitors: return "person.2.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .milk: return .blue
        case .health: return .red
        case .feeding: return .orange
        case .finance: return .teal
        case .visitors: return .indigo
        }
    }

    var iconBg: Color {
        switch self {
        case .milk: return Color.blue.opacity(0.1)
        case .health: return Color.red.opacity(0.1)
        case .feeding: return Color.orange.opacity(0.1)
        case .finance: return Color.teal.opacity(0.1)
        case .visitors: return Color.indigo.opacity(0.1)
        }
    }
}
