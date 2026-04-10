import Vision
import UIKit

struct ReceiptScanner {
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
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  !observations.isEmpty else {
                print("OCR: No text found in image")
                completion(nil)
                return
            }
            
            let recognizedText = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            
            completion(recognizedText)
    }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

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

