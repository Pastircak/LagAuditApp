//
//  LagAuditAppApp.swift
//  LagAuditApp
//
//  Created by Ryan Pastircak on 7/19/25.
//

import SwiftUI

@main
struct LagAuditAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
