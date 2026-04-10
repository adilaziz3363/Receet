//
//  ReceiptViewModel.swift
//  RecieptScanner
//
//  Created by Delirious on 4/6/26.
//

import SwiftUI
import SwiftData

@Observable
class ReceiptViewModel {
    var selectedImage: UIImage?
    var scannedText: String?
    var parsedReceipt: ParsedReceipt?
    var isScanning: Bool = false
    var errorMessage: String?

    func scanReceipt() {
        guard let image = selectedImage else { return }

        isScanning = true
        errorMessage = nil
        
        // IMPORTANT: reset old results first
        scannedText = nil
        parsedReceipt = nil

        ReceiptScanner.scanReceipt(from: image) { text in
            DispatchQueue.main.async {
                self.isScanning = false

                guard let text = text, !text.isEmpty else {
                    self.errorMessage = "No text found in image"
                    self.scannedText = nil
                    return
                }

                self.scannedText = text
                self.parsedReceipt = ReceiptParser.parse(from: text)

               
            }
        }
    }
    
    func saveReceipt(context: ModelContext) {
        guard let parsed = parsedReceipt else { return }
        
        let receipt = Receipt(
            merchantName: parsed.merchantName,
            total: parsed.total ?? 0.0,
            date: parsed.date ?? .now,
            imageData: selectedImage?.jpegData(compressionQuality: 0.8),
            rawText: scannedText
        )
        context.insert(receipt)
        clearState()
    }
    func clearState() {
        selectedImage = nil
        scannedText = nil
        parsedReceipt = nil
    }
}
    
    
    
    
    
    
    
    
    
    
    
    

