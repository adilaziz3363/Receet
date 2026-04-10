//
//  RecieptScannerApp.swift
//  RecieptScanner
//
//  Created by Delirious on 4/2/26.
//

import SwiftUI
import SwiftData

@main
struct ReceiptScannerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Receipt.self,
        ])

        do {
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            return try ModelContainer(for: schema, configurations: [config])

        } catch {
            print("SwiftData error: \(error)")
            let fallbackConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            return try! ModelContainer(for: schema, configurations: [fallbackConfig])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
