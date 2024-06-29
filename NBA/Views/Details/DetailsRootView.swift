//
//  DetailsRootView.swift
//  NBA
//
//  Created by Ali Earp on 22/05/2024.
//

import SwiftUI

struct DetailsRootView: View {
    // MARK: - State Variables
    @State var view: String = "Leaders"
    
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
        TabView(selection: $view) {
            leadersTab
            playersTab
            teamsTab
        }
    }
    
    // MARK: - Leaders Tab
    
    private var leadersTab: some View {
        LeadersView()
            .tabItem {
                Label("Leaders", systemImage: "trophy")
            }
            .tag("Leaders")
    }
    
    // MARK: - Players Tab
    
    private var playersTab: some View {
        AllPlayersView()
            .tabItem {
                Label("Players", systemImage: "person")
            }
            .tag("Players")
    }
    
    // MARK: - Teams Tab
    
    private var teamsTab: some View {
        AllTeamsView()
            .tabItem {
                Label("Teams", systemImage: "person.3")
            }
            .tag("Teams")
    }
}

#Preview {
    DetailsRootView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
