//
//  NBAApp.swift
//  NBA
//
//  Created by Ali Earp on 19/03/2024.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import GoogleMobileAds

@main
struct NBAApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(AuthModel())
                .onAppear {
                    Task { try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) }
                }
        }
    }
}
