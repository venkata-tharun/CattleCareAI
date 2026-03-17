//
//  FarmAppRootTabs.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//

import SwiftUI
import Combine

struct FarmAppRootTabs: View {
    @EnvironmentObject var tabRouter: TabRouter
    @StateObject private var homeRouter = NavigationRouter()
    @StateObject private var aiRouter = NavigationRouter()
    @StateObject private var reportsRouter = NavigationRouter()
    @StateObject private var settingsRouter = NavigationRouter()
    @StateObject private var feedManager = FeedDataManager()

    var body: some View {
        TabView(selection: $tabRouter.selectedTab) {

            // MARK: - Home Tab
            NavigationStack(path: $homeRouter.path) {
                    FarmDashboardView()
                        .environmentObject(tabRouter)
                        .environmentObject(homeRouter)
                        .environmentObject(feedManager)
                        .navigationDestination(for: AppRoute.self) { route in
                            homeDestination(route: route, router: homeRouter)
                        }
            }
            .tag(AppTab.home)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            // MARK: - AI Analysis Tab
            NavigationStack(path: $aiRouter.path) {
                DiseasePredictionView()
                    .environmentObject(tabRouter)
                    .environmentObject(aiRouter)
                    .navigationDestination(for: AppRoute.self) { route in
                        aiDestination(route: route, router: aiRouter)
                    }
            }
            .tag(AppTab.aiAnalysis)
            .tabItem {
                Image(systemName: "sparkles")
                Text("AI Analysis")
            }

            // MARK: - Reports Tab
            NavigationStack(path: $reportsRouter.path) {
                ReportsView()
                    .environmentObject(reportsRouter)
                    .environmentObject(tabRouter)
                    .environmentObject(feedManager)
                    .navigationDestination(for: AppRoute.self) { route in
                        reportsDestination(route: route, router: reportsRouter)
                    }
            }
            .tag(AppTab.reports)
            .tabItem {
                Image(systemName: "doc.text.fill")
                Text("Reports")
            }

            // MARK: - Settings Tab
            NavigationStack(path: $settingsRouter.path) {
                SettingsView()
                    .environmentObject(settingsRouter)
                    .navigationDestination(for: AppRoute.self) { route in
                        settingsDestination(route: route, router: settingsRouter)
                    }
            }
            .tag(AppTab.settings)
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
        .tint(Color(red: 0.08, green: 0.64, blue: 0.30))
        .environmentObject(tabRouter)
    }

    // MARK: - Home Tab Destinations
    @ViewBuilder
    private func homeDestination(route: AppRoute, router: NavigationRouter) -> some View {
        switch route {
        case .milk:
            NewMilkEntryView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .editMilk(let entry):
            NewMilkEntryView(existingEntry: entry)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .milkRecordList:
            MilkRecordListView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .res(let entry):
            TotalMilkProductionView(entry: entry)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .animalsList:
            AnimalMainView()
                .environmentObject(router)
                .environmentObject(tabRouter)
                .toolbar(.hidden, for: .tabBar)
        case .animalDetail(let animal):
            AnimalDetailView(animal: animal)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .addAnimal:
            AddAnimalView()
                .toolbar(.hidden, for: .tabBar)
        case .addHealthRecord(let animal):
            AddHealthRecordView(animal: animal)
                .toolbar(.hidden, for: .tabBar)
        case .editHealthRecord(let animal, let record):
            AddHealthRecordView(animal: animal, recordToEdit: record)
                .toolbar(.hidden, for: .tabBar)
        case .addVaccineRecord(let animal):
            AddVaccineRecordView(animal: animal)
                .toolbar(.hidden, for: .tabBar)
        case .editVaccineRecord(let animal, let vax):
            AddVaccineRecordView(animal: animal, recordToEdit: vax)
                .toolbar(.hidden, for: .tabBar)
        case .visitors:
            VisitorsView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .visitorList:
            VisitorListView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .addVisitor:
            AddVisitorView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .visitorDetail(let visitor):
            VisitorDetailView(visitorParam: visitor)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .editVisitor(let visitor):
            AddVisitorView(existingVisitor: visitor)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .feeding:
            FeedingHubView()
                .environmentObject(router)
                .environmentObject(feedManager)
                .toolbar(.hidden, for: .tabBar)
        case .feedingEntry:
            FeedingEntryView()
                .environmentObject(router)
                .environmentObject(feedManager)
                .toolbar(.hidden, for: .tabBar)
        case .feedStock:
            FeedStockView()
                .environmentObject(router)
                .environmentObject(feedManager)
                .toolbar(.hidden, for: .tabBar)
        case .feedingSchedule:
            FeedingScheduleView()
                .environmentObject(router)
                .environmentObject(feedManager)
                .toolbar(.hidden, for: .tabBar)
        case .sanitation:
            SanitationHubView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .sanitationChecklist:
            SanitationChecklistView()
                .toolbar(.hidden, for: .tabBar)
        case .biosecurityCheck:
            BiosecurityChecklistView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .reportsList:
            ReportsView()
                .environmentObject(router)
                .environmentObject(tabRouter)
                .toolbar(.hidden, for: .tabBar)
        case .reportDetail(let type):
            ReportDetailView(reportType: type)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .logs:
            LogsView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .logDetail(let log):
            LogDetailView(log: log)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .addLog:
            AddLogView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .editLog(let log):
            AddLogView(existingLog: log)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .addStock:
            AddStockView()
                .environmentObject(router)
                .environmentObject(feedManager)
                .toolbar(.hidden, for: .tabBar)
        case .updateSchedule(let schedule):
            UpdateScheduleView(existingSchedule: schedule)
                .environmentObject(router)
                .environmentObject(feedManager)
                .toolbar(.hidden, for: .tabBar)
        case .transactions:
            TransactionsView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .newTransaction(let category):
            NewTransactionView(category: category)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .calvingTrackerHome:
            CalvingTrackerHomeView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .addCalvingRecord:
            AddCalvingRecordView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .calvingRecordsList:
            CalvingRecordsListView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .calvingRecordDetail(let r):
            CalvingRecordDetailView(record: r)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .editCalvingRecord(let r):
            EditCalvingRecordView(record: r)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .equipments:
            EquipmentsHomeView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .chaffCutterDetail:
            ChaffCutterDetailView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .milkingMachineDetail:
            MilkingMachineDetailView()
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        default:
            EmptyView()
        }
    }

    // MARK: - AI Analysis Tab Destinations
    @ViewBuilder
    private func aiDestination(route: AppRoute, router: NavigationRouter) -> some View {
        switch route {
        case .aiDiseasePrediction:
            DiseasePredictionView()
                .environmentObject(router)
        case .aiImagePreview(let image):
            ImageScanningView(image: image)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        case .aiPredictionResult(let image, let prediction):
            PredictionResultView(image: image, prediction: prediction)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        default:
            EmptyView()
        }
    }

    // MARK: - Reports Tab Destinations
    @ViewBuilder
    private func reportsDestination(route: AppRoute, router: NavigationRouter) -> some View {
        switch route {
        case .reportDetail(let type):
            ReportDetailView(reportType: type)
                .environmentObject(router)
                .toolbar(.hidden, for: .tabBar)
        default:
            EmptyView()
        }
    }

    // MARK: - Settings Tab Destinations
    @ViewBuilder
    private func settingsDestination(route: AppRoute, router: NavigationRouter) -> some View {
        switch route {
        case .profileSettings:
            ProfileSettingsView()
                .toolbar(.hidden, for: .tabBar)
        case .notificationSettings:
            NotificationSettingsView()
                .toolbar(.hidden, for: .tabBar)
        case .helpSupport:
            HelpSupportView()
                .toolbar(.hidden, for: .tabBar)
        default:
            EmptyView()
        }
    }
}

#Preview {
    FarmAppRootTabs()
        .environmentObject(TabRouter())
}
