//
//  AppRoute.swift
//  FocusFlow
//
//  Created by formando on 10/11/
import Foundation

/// Enum das rotas da aplicação
enum AppRoute: Hashable, Codable {
    case dashboard
    case planner
    case reports
    case settings
}
enum MainTab: Hashable {
    case dashboard
    case motivation
    case blocked
    case settings
}
