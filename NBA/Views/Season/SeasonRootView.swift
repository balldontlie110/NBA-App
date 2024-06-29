//
//  SeasonRootView.swift
//  NBA
//
//  Created by Ali Earp on 06/05/2024.
//

import SwiftUI

struct SeasonRootView: View {
    // MARK: - State Variables
    @State private var selectedView: String = "Games"
    
    // MARK: - Constants
    private let gamesTabLabel = "Games"
    private let gamesTabImage = "calendar"
    private let gamesTag = "Games"
    private let standingsTabLabel = "Standings"
    private let standingsTabImage = "chart.bar"
    private let standingsTag = "Standings"

    // MARK: - Initializer
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    var body: some View {
        TabView(selection: $selectedView) {
            gamesTab
            standingsTab
        }
    }
    
    // MARK: - Games Tab
    
    private var gamesTab: some View {
        ScoreboardView()
            .tabItem {
                Label(gamesTabLabel, systemImage: gamesTabImage)
            }
            .tag(gamesTag)
    }
    
    // MARK: - Standings Tab
    
    private var standingsTab: some View {
        StandingsView()
            .tabItem {
                Label(standingsTabLabel, systemImage: standingsTabImage)
            }
            .tag(standingsTag)
    }
}

// MARK: - Preview

#Preview {
    SeasonRootView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
