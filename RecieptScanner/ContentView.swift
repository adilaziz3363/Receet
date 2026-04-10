//
//  ContentView.swift
//  RecieptScanner
//
//  Created by Delirious on 4/2/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var viewModel = ReceiptViewModel()
    
    // Picker states
    @State private var showingImagePicker = false
    @State private var useCamera = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Receipt Image Area
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay {
                        VStack {
                            if viewModel.isScanning {
                                ProgressView("Scanning receipt...")
                                    .progressViewStyle(.circular)
                            } else if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding()
                            } else {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No receipt selected")
                                    .foregroundColor(.gray)
                                HStack(spacing: 16) {
                                    Button("Take Photo") {
                                        useCamera = true
                                        showingImagePicker = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                    
                                    Button("Choose from Library") {
                                        useCamera = false
                                        showingImagePicker = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .padding()
                            }
                        }
                    }
                    .padding()
                
                // Re-pick if image already selected
                if viewModel.selectedImage != nil {
                    HStack(spacing: 16) {
                        Button("Take Photo") {
                            useCamera = true
                            showingImagePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Choose Different Photo") {
                            useCamera = false
                            showingImagePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.bottom, 8)
                }
                
                Spacer()
                
                // Scanned Text Display
                if let text = viewModel.scannedText {
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
                
                // Parsed Receipt Display
                if let parsed = viewModel.parsedReceipt {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📍Merchant: \(parsed.merchantName)")
                        Text("💰Total: $\(String(format: "%.2f", parsed.total ?? 0.0))")
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
                
                // Save Button
                if viewModel.parsedReceipt != nil {
                    Button {
                        viewModel.saveReceipt(context: modelContext)
                    } label: {
                        Label("Save Receipt", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 8)
                }
                
                Spacer()
            }
            .navigationTitle("Receipt Scanner")
            .sheet(isPresented: $showingImagePicker) {
                if useCamera {
                    CameraPicker(image: $viewModel.selectedImage, sourceType: .camera)
                } else {
                    ImagePicker(image: $viewModel.selectedImage)
                }
            }
            .onChange(of: viewModel.selectedImage) { _, newImage in
                guard let newImage = newImage else { return }
                viewModel.selectedImage = newImage
                viewModel.scanReceipt()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Receipt.self, inMemory: true)
}
