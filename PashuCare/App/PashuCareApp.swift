//
//  PashuCareApp.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//

import SwiftUI

@main
struct PashuCareApp: App {
    @StateObject private var router = NavigationRouter()
    @StateObject private var healthManager = HealthDataManager()
    @StateObject private var transactionManager = TransactionDataManager()
    @StateObject private var feedManager = FeedDataManager()
    @StateObject private var milkManager = MilkDataManager()
    @StateObject private var calvingManager = CalvingDataManager()
    @StateObject private var visitorManager = VisitorDataManager()
    @StateObject private var sanitationManager = SanitationDataManager()
    @StateObject private var logsManager = LogsDataManager()
    @StateObject private var animalManager = AnimalDataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router) // ✅ inject once globally
                .environmentObject(healthManager)
                .environmentObject(transactionManager)
                .environmentObject(feedManager)
                .environmentObject(milkManager)
                .environmentObject(calvingManager)
                .environmentObject(visitorManager)
                .environmentObject(sanitationManager)
                .environmentObject(logsManager)
                .environmentObject(animalManager)
        }
    }
}
