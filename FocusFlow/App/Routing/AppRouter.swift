//
//  AppRoute.swift
//  		
//
//  Created by formando on 10/11/2025.
//

import SwiftUI


final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }
    func pop() {
        if !path.isEmpty { path.removeLast() }
    }
    func popToRoot() {
        path.removeLast(path.count)
    }
}
