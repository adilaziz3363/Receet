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
        return ParsedReceipt(merchantName: merchantName, total: total, date: date)
    }

    static func extractTotal(from text: String) -> Double {
        let lines = text.components(separatedBy: "\n")
        
        let totalKeywords = ["total amount", "grand total", "total due",
                             "amount due", "sub total", "subtotal", "total"]
        
        let skipWords = ["tax", "tip", "change", "cash", "tend",
                         "visa", "debit", "credit", "saving", "coupon",
                         "rate", "discoun", "%"]
        
        let pattern = #"[\$S]?\s*\d+\.\d{2}"#
        
        func extractNumber(from line: String) -> Double? {
            let lowercased = line.lowercased()
            if skipWords.contains(where: { lowercased.contains($0) }) { return nil }
            if let range = line.range(of: pattern, options: .regularExpression) {
                let match = String(line[range])
                    .replacingOccurrences(of: "S", with: "")
                    .replacingOccurrences(of: "$", with: "")
                    .trimmingCharacters(in: .whitespaces)
                return Double(match)
            }
            return nil
        }
        
        // Pass 1 — keyword then number within 5 lines
        for (index, line) in lines.enumerated() {
            let lowercased = line.lowercased()
            guard totalKeywords.contains(where: { lowercased.contains($0) }) else { continue }
            if skipWords.contains(where: { lowercased.contains($0) }) { continue }
            if let value = extractNumber(from: line), value > 1 { return value }
            let searchRange = (index + 1)..<min(index + 6, lines.count)
            for nextIndex in searchRange {
                if let value = extractNumber(from: lines[nextIndex]), value > 1 { return value }
            }
        }
        
        // Pass 2 — number before keyword
        for (index, line) in lines.enumerated() {
            let lowercased = line.lowercased()
            guard totalKeywords.contains(where: { lowercased.contains($0) }) else { continue }
            let searchRange = max(0, index - 3)..<index
            for prevIndex in searchRange.reversed() {
                if let value = extractNumber(from: lines[prevIndex]), value > 1 { return value }
            }
        }
        
        // Pass 3 — largest number fallback
        var largest: Double = 0.0
        for line in lines {
            if let value = extractNumber(from: line), value > largest { largest = value }
        }
        return largest
    }

    static func extractMerchantName(from text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        let skipWords = ["welcome", "thank", "receipt", "order", "date",
                         "time", "item", "qty", "price", "total", "cash",
                         "change", "card", "tel", "www", "http"]
        for line in lines {
            let cleaned = line.trimmingCharacters(in: .whitespaces)
            let lowercased = cleaned.lowercased()
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
            #"\d{2}/\d{2}/\d{4}"#,
            #"\d{2}-\d{2}-\d{4}"#,
            #"\d{4}-\d{2}-\d{2}"#,
        ]
        let formatter = DateFormatter()
        let formats = ["MM/dd/yyyy", "MM-dd-yyyy", "yyyy-MM-dd"]
        for line in lines {
            for (index, pattern) in datePatterns.enumerated() {
                if let range = line.range(of: pattern, options: .regularExpression) {
                    let match = String(line[range])
                    formatter.dateFormat = formats[index]
                    if let date = formatter.date(from: match) { return date }
                }
            }
        }
        return nil
    }
}
