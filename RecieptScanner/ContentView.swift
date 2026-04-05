//
//  ContentView.swift
//  RecieptScanner
//
//  Created by Delirious on 4/2/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var scannedText: String?
    @State private var isScanning: Bool = false
    @State private var parsedReceipt: ParsedReceipt?
    
    var body: some View {
        NavigationStack {
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            if isScanning {
                                ProgressView("Scanning receipt...")
                                    .progressViewStyle(.circular)
                            } else
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding()
                            } else {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No reciept selected")
                                    .foregroundColor(.gray)
                                Button("Select Reciept Photo") {
                                    showingImagePicker = true
                                    
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                            }
                        }
                    )
                    .padding()
                // Show button to re-pick if image already selected
                if selectedImage != nil {
                    Button("Choose Different Photo") {
                        showingImagePicker = true
                    }
                    .padding(.bottom, 8)
                }
                Spacer()
                
                if let text = scannedText {
                    ScrollView {
                        Text(text)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                    }
                
                    if let parsed = parsedReceipt {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📍Merchant: \(parsed.merchantName)")
                            Text("💰Total: $\(String(format: "%.2f", parsed.total))")
                            if let date = parsed.date {
                                Text("📅 Date: \(date.formatted(date: .abbreviated, time: .omitted))")
                            }
                        }
                        
                        .padding()
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                    }
                    Spacer()
                }
            
                    .navigationTitle("Reciept Scanner")
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $selectedImage)
                    }
                    .onChange(of: selectedImage) { _, newImage in
                        guard let image = newImage else { return }
                        isScanning = true
                        ReceiptScanner.scanReceipt(from: image) { text in
                            DispatchQueue.main.async {
                                scannedText = text
                                if let text  = text {
                                    parsedReceipt = ReceiptParser.parse(from: text)
                                    print("Merchant: \(parsedReceipt?.merchantName ?? "nil")")
                                    print("Total: \(parsedReceipt?.total ?? 0.0)")
                                    print("Date: \(String(describing: parsedReceipt?.date))")
                                }
                                isScanning = false
                            }
                            
                        }
                    }
            }
        }
    }

#Preview {
    ContentView()
        .modelContainer(for: Receipt.self, inMemory: true)
}

