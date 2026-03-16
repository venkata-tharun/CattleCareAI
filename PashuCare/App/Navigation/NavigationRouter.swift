//
//  NavigationRouter.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//

import SwiftUI
import Combine

class NavigationRouter: ObservableObject {

    @Published var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func popToWelcomeAndLogin() {
        path.removeLast(path.count)
        path.append(AppRoute.welcome)
        path.append(AppRoute.login)
    }

}
