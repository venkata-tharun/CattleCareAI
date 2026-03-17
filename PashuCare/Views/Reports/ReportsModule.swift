//
//  ReportsModule.swift
//  PashuCare
//
//  Created by SAIL on 03/03/26.
//

import SwiftUI

// MARK: - Reports View (Tab-level)

struct ReportsView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var transactionManager: TransactionDataManager
    @EnvironmentObject var milkManager: MilkDataManager
    @EnvironmentObject var feedManager: FeedDataManager
    @EnvironmentObject var healthManager: HealthDataManager
    @EnvironmentObject var visitorManager: VisitorDataManager
    @EnvironmentObject var sanitationManager: SanitationDataManager
    @EnvironmentObject var logsManager: LogsDataManager
    @EnvironmentObject var animalManager: AnimalDataManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                // Finance summary at the top
                FinanceSummaryCard(manager: transactionManager) {
                    router.push(.reportDetail(.finance))
                }

                ForEach(ReportType.allCases.filter { $0 != .finance }) { report in
                    Button {
                        router.push(.reportDetail(report))
                    } label: {
                        ReportCard(
                            report: report,
                            statLine: getStatLine(for: report),
                            subtext: getSubtext(for: report)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            transactionManager.loadData()
            milkManager.loadData()
            feedManager.loadData()
            visitorManager.loadData()
            logsManager.loadData()
            animalManager.fetchAnimals()
        }
    }

    private func getStatLine(for report: ReportType) -> String {
        switch report {
        case .milk:
            let total = milkManager.records.reduce(0) { $0 + $1.am + $1.noon + $1.pm }
            return "\(Int(total)) Liters"
        case .health:
            let healthy = animalManager.animals.filter { $0.status == .healthy }.count
            let total = animalManager.animals.count
            return total > 0 ? "\(healthy)/\(total) Healthy" : "\(sanitationManager.score)% Score"
        case .feeding:
            let total = feedManager.stockItems.reduce(0) { $0 + $1.quantityValue }
            return "\(Int(total)) kg"
        case .visitors:
            return "\(visitorManager.visitors.count) Visitors"
        default: return report.statLine
        }
    }

    private func getSubtext(for report: ReportType) -> String {
        switch report {
        case .milk: return "\(milkManager.records.count) Records"
        case .health: return "\(animalManager.animals.count) Animals tracked"
        case .feeding: return "Stock remaining"
        case .visitors: return "\(visitorManager.visitors.count) total logs"
        default: return report.subtext
        }
    }
}

// MARK: - Report Card

private struct ReportCard: View {
    let report: ReportType
    let statLine: String
    let subtext: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(report.iconBg)
                        .frame(width: 48, height: 48)
                    Image(systemName: report.icon)
                        .font(.system(size: 22))
                        .foregroundColor(report.iconColor)
                }

                Spacer()
                
                // Keep the rest same

                HStack(spacing: 4) {
                    Button {
                        // Share action
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                    .buttonStyle(.plain)

                    Button {
                        // Download action
                    } label: {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(report.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(statLine)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                Text(subtext)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Finance Summary Card (Top of Reports)

private struct FinanceSummaryCard: View {
    @ObservedObject var manager: TransactionDataManager
    let onTap: () -> Void

    private func currency(_ value: Double) -> String {
        String(format: "₹%.2f", value)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.teal.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: "indianrupeesign.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.teal)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .padding(8)

                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                }

                Text("Finance Summary")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                HStack(alignment: .lastTextBaseline, spacing: 8) {
                     Text("\(manager.transactions.count) Transactions")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Income & Expense")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Report Detail View

struct ReportDetailView: View {
    let reportType: ReportType
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var transactionManager: TransactionDataManager
    @EnvironmentObject var milkManager: MilkDataManager
    @EnvironmentObject var feedManager: FeedDataManager
    @EnvironmentObject var healthManager: HealthDataManager
    @EnvironmentObject var visitorManager: VisitorDataManager
    @EnvironmentObject var sanitationManager: SanitationDataManager
    @EnvironmentObject var logsManager: LogsDataManager
    @EnvironmentObject var animalManager: AnimalDataManager

    @State private var generatedPDF: URL?
    @State private var showShareSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text(reportType.detailTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        reportContent()

                        Spacer().frame(height: 120) // Increased to clear floating buttons + padding
                    }
                    .padding(16)
                }
            }

            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    exportToPDF()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle")
                        Text("Download PDF")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.green, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)

                Button {
                    exportToPDF()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.green)
                    .cornerRadius(26)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showShareSheet) {
            if let url = generatedPDF {
                ShareSheet(items: [url])
            }
        }
    }

    @ViewBuilder
    private func reportContent() -> some View {
        switch reportType {
        case .milk:
            MilkReportContent(manager: milkManager)
        case .health:
            HealthReportContent()
        case .feeding:
            FeedingReportContent(manager: feedManager)
        case .finance:
            FinanceReportContent()
        case .visitors:
            VisitorReportContent()
        }
    }

    @MainActor
    private func exportToPDF() {
        print("🛠 ReportsModule: Exporting \(reportType.detailTitle) to PDF")

        let title = reportType.detailTitle.replacingOccurrences(of: " ", with: "_")
        let url = URL.documentsDirectory.appending(path: "\(title)_Report_\(Int(Date().timeIntervalSince1970)).pdf")
        print("🛠 ReportsModule: Saving PDF to \(url.path)")

        // Render the actual report content (which displays backend-fetched data from managers)
        let viewToRender = VStack(spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("PashuCare — " + reportType.detailTitle)
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            Text("Generated: " + Date().formatted(date: .long, time: .shortened))
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            reportContent()
                .padding(20)
        }
        .frame(width: 8.5 * 72)
        .background(Color.white)
        .environmentObject(transactionManager)
        .environmentObject(milkManager)
        .environmentObject(feedManager)
        .environmentObject(healthManager)
        .environmentObject(visitorManager)
        .environmentObject(sanitationManager)
        .environmentObject(logsManager)
        .environmentObject(animalManager)

        PDFExporter.render(view: viewToRender, to: url)
        self.generatedPDF = url
        self.showShareSheet = true
        print("✅ ReportsModule: PDF ready at \(url.path)")
    }
}

// MARK: - Finance Report Content

private struct FinanceReportContent: View {
    @EnvironmentObject var transactionManager: TransactionDataManager

    private func currency(_ value: Double) -> String {
        String(format: "₹%.2f", value)
    }

    private var income: Double { transactionManager.totalIncome }
    private var expense: Double { transactionManager.totalExpense }
    private var balance: Double { transactionManager.balance }

    private let df: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; return f
    }()

    var body: some View {
        VStack(spacing: 16) {
            // Summary Row
            HStack(spacing: 12) {
                summaryCard(label: "Total Income", value: currency(income), color: .green)
                summaryCard(label: "Total Expense", value: currency(expense), color: .red)
            }
            HStack(spacing: 12) {
                summaryCard(label: "Balance", value: currency(balance), color: .teal)
                summaryCard(label: "Transactions", value: "\(transactionManager.transactions.count)", color: .blue)
            }

            // Recent Transactions
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "indianrupeesign.circle.fill")
                        .foregroundColor(.teal)
                    Text("Recent Transactions")
                        .font(.system(size: 16, weight: .bold))
                }

                if transactionManager.transactions.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "creditcard.and.123")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No transactions yet")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Type").frame(maxWidth: .infinity, alignment: .leading)
                            Text("Date").frame(maxWidth: .infinity, alignment: .leading)
                            Text("Amount").frame(width: 100, alignment: .trailing)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                        Divider()

                        ForEach(transactionManager.transactions.prefix(10)) { t in
                            HStack {
                                Text(t.type)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(df.string(from: t.date))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(String(format: "%@₹%.2f", t.category == "Income" ? "+" : "-", t.amount))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(t.category == "Income" ? .green : .red)
                                    .frame(width: 100, alignment: .trailing)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            Divider()
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }

    @ViewBuilder
    private func summaryCard(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(color.opacity(0.9))
            Text(value)
                .font(.system(size: 22, weight: .bold))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .cornerRadius(14)
    }
}

// MARK: - Milk Report Content

private struct MilkReportContent: View {
    @ObservedObject var manager: MilkDataManager
    @EnvironmentObject var animalManager: AnimalDataManager

    private var aggregatedHistory: [(id: String, date: String, morning: Double, noon: Double, evening: Double, total: Double)] {
        let df = DateFormatter(); df.dateFormat = "MMM d"
        let groupDf = DateFormatter(); groupDf.dateFormat = "yyyy-MM-dd"
        
        let grouped = Dictionary(grouping: manager.records) { entry in
            groupDf.string(from: entry.date)
        }
        
        return grouped.map { (key, entries) in
            let am = entries.reduce(0) { $0 + $1.am }
            let noon = entries.reduce(0) { $0 + $1.noon }
            let pm = entries.reduce(0) { $0 + $1.pm }
            let date = entries.first != nil ? df.string(from: entries.first!.date) : key
            return (id: key, date: date, morning: am, noon: noon, evening: pm, total: am + noon + pm)
        }.sorted { $0.id > $1.id }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Summary Row
            let total = manager.records.reduce(0) { $0 + $1.am + $1.noon + $1.pm }
            let avg = manager.records.isEmpty ? 0 : total / Double(Set(manager.records.map { Calendar.current.startOfDay(for: $0.date) }).count)
            
            HStack(spacing: 12) {
                summaryCard(label: "Total Production", value: "\(Int(total))L", trend: nil, trendUp: true, color: .blue)
                summaryCard(label: "Avg per Day", value: String(format: "%.1fL", avg), trend: nil, trendUp: true, color: .blue)
            }

            // Production History
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                    Text("Production History (Last 7 Days)")
                        .font(.system(size: 16, weight: .bold))
                }

                VStack(spacing: 0) {
                    HStack {
                        Text("Date").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Morning").frame(width: 70, alignment: .center)
                        Text("Evening").frame(width: 70, alignment: .center)
                        Text("Total").frame(width: 60, alignment: .trailing)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                    Divider()

                    ForEach(aggregatedHistory.prefix(7), id: \.id) { row in
                        HStack {
                            Text(row.date).font(.system(size: 14, weight: .medium)).frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(Int(row.morning))L").font(.system(size: 14)).foregroundColor(.secondary).frame(width: 70, alignment: .center)
                            Text("\(Int(row.evening))L").font(.system(size: 14)).foregroundColor(.secondary).frame(width: 70, alignment: .center)
                            Text("\(Int(row.total))L").font(.system(size: 14, weight: .bold)).foregroundColor(.blue).frame(width: 60, alignment: .trailing)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        Divider()
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)

            // Top Producer Card
            if let top = manager.topProducer {
                let animalName = animalManager.animals.first(where: { $0.tag == top.tag })?.name ?? top.tag
                let displayTitle = animalName == top.tag ? top.tag : "\(animalName) (\(top.tag))"
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Top Producer").font(.system(size: 13)).foregroundColor(Color.blue.opacity(0.8))
                        Text(displayTitle).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.1fL", top.avgProduction)).font(.system(size: 32, weight: .bold)).foregroundColor(.white)
                        Text("/ day avg").font(.system(size: 11)).foregroundColor(Color.blue.opacity(0.8))
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(18)
            } else {
                // Default placeholder if no data
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Top Producer").font(.system(size: 13)).foregroundColor(Color.blue.opacity(0.8))
                        Text("No Data Yet").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("-- L").font(.system(size: 32, weight: .bold)).foregroundColor(.white)
                        Text("/ day avg").font(.system(size: 11)).foregroundColor(Color.blue.opacity(0.8))
                    }
                }
                .padding(20)
                .background(Color.gray.opacity(0.6))
                .cornerRadius(18)
            }
        }
    }

    @ViewBuilder
    private func summaryCard(label: String, value: String, trend: String?, trendUp: Bool, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(color).textCase(.uppercase)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value).font(.system(size: 22, weight: .bold))
                if let trend = trend {
                    HStack(spacing: 2) {
                        Image(systemName: trendUp ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10))
                        Text(trend).font(.system(size: 11))
                    }
                    .foregroundColor(trendUp ? .green : .red)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .cornerRadius(14)
    }
}

// MARK: - Health Report Content

private struct HealthReportContent: View {
    @EnvironmentObject var healthManager: HealthDataManager
    @EnvironmentObject var logsManager: LogsDataManager
    @EnvironmentObject var animalManager: AnimalDataManager

    private var healthyCount: Int {
        let dbHealthy = Set(animalManager.animals.filter { $0.status == .healthy }.map { $0.name })
        let aiSickNames = Set(healthManager.healthEvents.filter { $0.animalName != "Unknown Animal" && $0.status != "Healthy" }.map { $0.animalName })
        return dbHealthy.subtracting(aiSickNames).count
    }
    
    private var sickCount: Int {
        var sickNames = Set(animalManager.animals.filter { $0.status == .sick }.map { $0.name })
        let aiSickNames = healthManager.healthEvents.filter { $0.animalName != "Unknown Animal" && $0.status != "Healthy" }.map { $0.animalName }
        sickNames.formUnion(aiSickNames)
        return sickNames.count
    }
    
    

    var body: some View {
        VStack(spacing: 16) {
            // Status Summary — real counts from backend
            HStack(spacing: 12) {
                healthStatusCard(count: healthyCount, label: "Healthy", color: .green)
                healthStatusCard(count: sickCount, label: "Sick", color: .red)
            }

            // Recent Events
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundColor(.red)
                    Text("Recent Health Events")
                        .font(.system(size: 16, weight: .bold))
                }

                VStack(spacing: 0) {
                    // Show Saved AI Events (Filtering out dummy "Unknown Animal" entries)
                    ForEach(healthManager.healthEvents.filter { $0.animalName != "Unknown Animal" }, id: \.id) { event in
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "cross.case.fill")
                                    .foregroundColor(.red.opacity(0.6))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.animalName).font(.system(size: 15, weight: .semibold))
                                Text(event.diseaseName).font(.system(size: 13)).foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(event.date)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text("AI: \(event.confidence)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }

                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        Divider()
                    }
                    
                    // Show Health Logs from LogsDataManager
                    ForEach(logsManager.logs.filter { $0.type == .health }) { log in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(log.animalId ?? "Farm Log").font(.system(size: 15, weight: .semibold))
                                Text(log.description).font(.system(size: 13)).foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(log.date)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text("Health Log")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        Divider()
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }

    private struct HealthEvent {
        let animal: String
        let note: String
        let date: String
        let status: String
        let statusColor: Color
    }

    private let staticEvents: [HealthEvent] = [
        HealthEvent(animal: "Daisy (A-102)", note: "Mastitis • Dr. Sharma", date: "Today", status: "Critical", statusColor: .red),
        HealthEvent(animal: "Rocky (A-105)", note: "Routine Checkup", date: "Yesterday", status: "Normal", statusColor: .green),
        HealthEvent(animal: "Luna (A-104)", note: "Vaccination (FMD)", date: "Mar 04", status: "Done", statusColor: .gray),
        HealthEvent(animal: "Max (A-103)", note: "Limping observed", date: "Mar 02", status: "Monitor", statusColor: .orange)
    ]

    @ViewBuilder
    private func healthStatusCard(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)").font(.system(size: 28, weight: .bold)).foregroundColor(color)
            Text(label).font(.system(size: 12, weight: .medium)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(14)
    }
}

// MARK: - Feeding Report Content

private struct FeedingReportContent: View {
    @ObservedObject var manager: FeedDataManager
    
    private var stockTotal: Double { manager.stockItems.reduce(0) { $0 + $1.quantityValue } }
    
    private var todayFeedingTotal: Double {
        let today = DateFormatter(); today.dateFormat = "yyyy-MM-dd"
        let todayStr = today.string(from: Date())
        return manager.feedingEntries
            .filter { $0.date == todayStr }
            .reduce(0) { $0 + $1.quantity }
    }
    
    private var todayFeedingCount: Int {
        let today = DateFormatter(); today.dateFormat = "yyyy-MM-dd"
        let todayStr = today.string(from: Date())
        return manager.feedingEntries.filter { $0.date == todayStr }.count
    }

    var body: some View {
        VStack(spacing: 16) {
                // Summary Card
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("STOCK REMAINING")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.orange.opacity(0.8))
                        Text("\(Int(stockTotal)) kg").font(.system(size: 24, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TODAY'S FEEDS")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.orange.opacity(0.8))
                        Text("\(todayFeedingCount)").font(.system(size: 24, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TOTAL FED (TODAY)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.orange.opacity(0.8))
                        Text("\(Int(todayFeedingTotal)) kg").font(.system(size: 24, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                }
                .padding(16)
                .background(Color.orange.opacity(0.08))
                .cornerRadius(16)

                // Breakdown
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.orange)
                        Text("Consumption Breakdown")
                            .font(.system(size: 16, weight: .bold))
                    }

                    VStack(spacing: 14) {
                        ForEach(Array(manager.stockItems), id: \.id) { item in
                            breakdownRow(for: item, stockTotal: stockTotal)
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                
                // Recent Feeding Logs
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.orange)
                        Text("Recent Feeding Logs")
                            .font(.system(size: 16, weight: .bold))
                    }

                    if manager.feedingEntries.isEmpty {
                        Text("No feeding entries recorded this week.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(manager.feedingEntries.prefix(5)) { entry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(entry.feedType.rawValue).font(.system(size: 15, weight: .semibold))
                                        Text(entry.time.rawValue).font(.system(size: 13)).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(entry.date).font(.system(size: 12)).foregroundColor(.secondary)
                                        Text("\(Int(entry.quantity)) kg")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.orange)
                                    }
                                }
                                .padding(.vertical, 10)
                                Divider()
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            }
        }
    }

    @ViewBuilder
    private func breakdownRow(for item: FeedStockItem, stockTotal: Double) -> some View {
        let total = stockTotal > 0 ? stockTotal : 1
        let itemValue = Double(item.quantityValue)
        let ratio = itemValue / total
        let percentString = "\(Int(ratio * 100))%"
        
        VStack(spacing: 6) {
            HStack {
                Text(item.name).font(.system(size: 14, weight: .medium))
                Spacer()
                Text("\(Int(item.quantityValue)) kg left").font(.system(size: 12)).foregroundColor(.secondary)
                Text("•").font(.system(size: 12)).foregroundColor(.secondary)
                Text(percentString).font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
            }
            GeometryReader { geo in
                let barWidth = geo.size.width * CGFloat(ratio)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(item.status.color)
                        .frame(width: barWidth, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

// MARK: - Visitor Report Content

private struct VisitorReportContent: View {
    @EnvironmentObject var visitorManager: VisitorDataManager

    var body: some View {
        VStack(spacing: 16) {
            // Summary Row
            HStack(spacing: 12) {
                summaryCard(label: "Total Today", value: "\(visitorManager.todayVisitorsCount)", color: .indigo)
                summaryCard(label: "Pending", value: "\(visitorManager.pendingCount)", color: .orange)
                summaryCard(label: "Checked Out", value: "\(visitorManager.checkedOutCount)", color: .gray)
            }

            // Traffic History
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.indigo)
                    Text("Visitor Log (Recent)")
                        .font(.system(size: 16, weight: .bold))
                }

                if visitorManager.visitors.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No visitors recorded")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    VStack(spacing: 0) {
                        ForEach(visitorManager.visitors.prefix(10)) { v in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(v.name).font(.system(size: 15, weight: .semibold))
                                    Text(v.purpose.isEmpty ? "No purpose" : v.purpose).font(.system(size: 13)).foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(v.entryTime.formattedTime())
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    Text(v.status.rawValue)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(v.status.color)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(v.status.color.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            Divider()
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }

    @ViewBuilder
    private func summaryCard(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 28, weight: .bold)).foregroundColor(color)
            Text(label).font(.system(size: 12, weight: .medium)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(14)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ReportsView()
            .environmentObject(NavigationRouter())
            .environmentObject(TransactionDataManager())
            .environmentObject(HealthDataManager())
    }
}
