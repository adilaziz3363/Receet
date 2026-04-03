import Vision
import UIKit

class ReceiptScanner {
    static func scanReceipt(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        let request = VNRecognizeTextRequest { request, error in
          if let error = error {
            print("OCR error: \(error.localizedDescription)")
            completion(nil)
            return
        }
            let recognizedText = request.results?
                .compactMap { $0 as? VNRecognizedTextObservation }
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            
            completion(recognizedText)
    }
        request.usesLanguageCorrection = true
        request.recognitionLevel = .accurate
            
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform OCR: \(error.localizedDescription)")
                completion(nil)
            }
        }
 }
}

