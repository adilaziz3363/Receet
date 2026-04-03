//
//  Receipt.swift
//  RecieptScanner
//
//  Created by Delirious on 4/4/26.
//

import SwiftUI
import SwiftData

@Model
class Receipt {
    var id: UUID
    var merchantName: String
    var total: Double
    var date: Date
    var imageData: Data?
    var rawText: String?
    var createdAt: Date
    
    init(
        merchantName: String, total: Double, date: Date, imageData: Data? = nil, rawText: String? = nil) {
        self.id = UUID()
        self.merchantName = merchantName
        self.total = total
        self.date = date
        self.imageData = imageData
            self.rawText = rawText
            self.createdAt = .now
            
    }
}
