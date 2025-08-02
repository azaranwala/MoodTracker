//
//  MoodTrackerApp.swift
//  MoodTracker
//
//  Created by Mustufa Zaranwala on 7/27/25.
//

import SwiftUI

@main
struct MoodTrackerApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        print("🚀 MoodTrackerApp initializing...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    print("🖥️ ContentView appeared")
                    print("📱 Device: \(UIDevice.current.model) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))")
                }
        }
    }
}
