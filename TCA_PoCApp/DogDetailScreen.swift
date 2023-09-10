//
//  DogDetailScreen.swift
//  TCA_PoCApp
//
//  Created by Salvador on 9/9/23.
//

import SwiftUI

struct DogDetailScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var dogImageURLs = [String]()
    @State var isAlertPresented: Bool = false
    
    let breed: String
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center) {
                ForEach(dogImageURLs, id: \.self) { dogImageURL in
                    AsyncImage(url: URL(string: dogImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                            .controlSize(.large)
                    }
                }
            }
            
            Spacer()
            
            Button("Refresh") {
                Task {
                    do {
                        try await fetchImageURLs()
                    } catch {
                        
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .navigationTitle(breed.capitalized)
        }
        .task {
            do {
                try await fetchImageURLs()
            } catch {
                isAlertPresented = true
            }
        }
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text("Network error"),
                  message: Text("An unexpected error occurred, please try again later"),
                  dismissButton: .cancel(Text("Ok"), action: { dismiss() }))
        }
    }
    
    private func fetchImageURLs() async throws {
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://dog.ceo/api/breed/\(breed)/images/random/3")!)
        
        let urls = try JSONDecoder().decode(RandomImagesResponse.self, from: data).message
        dogImageURLs = urls
    }
}

#Preview {
    DogDetailScreen(breed: "Akita")
}

struct RandomImagesResponse: Codable {
    let message: [String]
    let status: String
}
