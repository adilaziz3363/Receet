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
    
    func scanReceipt() {
        guard let image = selectedImage else { return }
            isScanning = true
        
        ReceiptScanner.scanReceipt(from: image) { text in
            DispatchQueue.main.async {
                self.scannedText = text
                if let text = text {
                    print("===Raw Text===")
                    print(text)
                    print("===END===")
                }
                self.scannedText = text
                if let text = text {
                    self.parsedReceipt = ReceiptParser.parse(from: text)
                }
                self.isScanning = false
            }
            
        }
    }
    func saveReceipt(context: ModelContext) {
        guard let parsed = parsedReceipt else { return }
        
        let receipt = Receipt(
            merchantName: parsed.merchantName,
            total: parsed.total,
            date: parsed.date ?? .now,
            imageData: selectedImage?.jpegData(compressionQuality: 0.8),
            rawText: scannedText
        )
        context.insert(receipt)
        selectedImage = nil
        scannedText = nil
        parsedReceipt = nil
    }
    
    
}
