//
//  ReceiptParser.swift
//  RecieptScanner
//
//  Created by Delirious on 4/5/26.
//

import Foundation

struct ParsedReceipt {
    var merchantName: String
    var total: Double
    var date: Date?
}


struct ReceiptParser {
    
    static func parse(from text: String) -> ParsedReceipt {
        let merchantName = extractMerchantName(from: text)
        let total = extractTotal(from: text)
        let date = extractDate(from: text)
        
        return ParsedReceipt(
            merchantName: merchantName,
            total: total,
            date: date
        )
    }
    static func extractTotal(from text: String) -> Double {
        let lines = text.components(separatedBy: "\n")
        
        for (i, line) in lines.enumerated() {
            print("Line \(i): '\(line)'")
        }
        
        let totalKeywords = ["total", "amount due", "balance due",
                             "grand total", "total due", "sub total"]
        
        let pattern = #"\$?\d+\.\d{2}"#  // ✅ now handles $ sign too
        
        for (index, line) in lines.enumerated().reversed() {
            let lowercased = line.lowercased()
            
            guard totalKeywords.contains(where: { lowercased.contains($0) }) else { continue }
            
            let searchRange = (index + 1)..<min(index + 6, lines.count)
            for nextIndex in searchRange {
                let nextLine = lines[nextIndex]
                if let range = nextLine.range(of: pattern, options: .regularExpression) {
                let match = String(nextLine[range]).replacingOccurrences(of: "$", with: "")
                if let value = Double(match) {
                    return value
                }
            }
            
                }
            }
        
        return 0.0
    }
    static func extractMerchantName(from text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        
        let skipWords = ["welcome", "thank", "receipt", "order", "date",
                         "time", "item", "qty", "price", "total", "cash",
                         "change", "card", "tel", "www", "http"]
        for line in lines {
            let cleaned = line.trimmingCharacters(in: .whitespaces)
            let lowercased = cleaned.lowercased()
            
            // Skip empty lines with skip words
            guard !cleaned.isEmpty,
                  cleaned.count > 3,
                  !skipWords.contains(where: { lowercased.contains($0) })
            else { continue }
            
            return cleaned
        }
        return "Unknown Merchant"
    }
    static func extractDate(from text: String) -> Date? {
        let lines = text.components(separatedBy: "\n")
        let datePatterns = [
            #"\d{2}/\d{2}/\d{4}"#,   // 09/05/2026
            #"\d{2}-\d{2}-\d{4}"#,   // 09-05-2026
            #"\d{4}-\d{2}-\d{2}"#,   // 2026-09-05
        ]
        let formatter = DateFormatter()
        let formats = ["MM/dd/yyyy", "MM-dd-yyyy", "yyyy-MM-dd"]
        
        for line in lines {
            for (index, pattern) in datePatterns.enumerated() {
                if let range = line.range(of: pattern, options: .regularExpression) {
                    let match = String(line[range])
                    formatter.dateFormat = formats[index]
                    if let date = formatter.date(from: match) {
                        return date
                    }
                }
            }
        }
        return nil
    }
}
