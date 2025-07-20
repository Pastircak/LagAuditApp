//
//  LagAuditAppApp.swift
//  LagAuditApp
//
//  Created by Ryan Pastircak on 7/19/25.
//

import SwiftUI
import CoreData

@main
struct LagAuditAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // Initialize sample data if needed
                    initializeSampleDataIfNeeded()
                }
        }
    }
    
    private func initializeSampleDataIfNeeded() {
        let context = persistenceController.container.viewContext
        
        // Check if we have any farms
        let farmRequest: NSFetchRequest<Farm> = Farm.fetchRequest()
        let farmCount = (try? context.count(for: farmRequest)) ?? 0
        
        if farmCount == 0 {
            // Create sample farm
            let sampleFarm = Farm(context: context)
            sampleFarm.id = UUID()
            sampleFarm.name = "Sample Dairy Farm"
            sampleFarm.location = "123 Dairy Lane, Farmville, CA"
            sampleFarm.contactPerson = "John Smith"
            sampleFarm.phone = "(555) 123-4567"
            sampleFarm.createdAt = Date()
            
            do {
                try context.save()
                print("Sample farm created successfully")
            } catch {
                print("Failed to create sample farm: \(error)")
            }
        }
    }
}
