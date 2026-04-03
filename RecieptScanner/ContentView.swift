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
    var body: some View {
        NavigationStack {
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(
                        VStack {
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
                    )
                    .padding()
                Spacer()
            }
            .navigationTitle("Reciept Scanner")
            .sheet(isPresented: $showingImagePicker) {
                Text("Photo picker will go here")
            }
        }
    }
}
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
