//
//  AppTab.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//


import SwiftUI
import Combine

enum AppTab: Hashable {
    case home, aiAnalysis, reports, settings
}

final class TabRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    func select(_ tab: AppTab) { selectedTab = tab }
}
