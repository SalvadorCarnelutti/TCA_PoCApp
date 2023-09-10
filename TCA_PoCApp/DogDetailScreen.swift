//
//  DogDetailScreen.swift
//  TCA_PoCApp
//
//  Created by Salvador on 9/9/23.
//

import SwiftUI

struct DogDetailScreen: View {
    @State private var dogImageURLs = [String]()
    
    let breed: String
    
    var body: some View {
        VStack {
            ForEach(dogImageURLs, id: \.self) { dogImageURL in
                AsyncImage(url: URL(string: dogImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
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
                
            }
        }
    }
    
    private func fetchImageURLs() async throws {
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://dog.ceo/api/breed/\(breed)/images/random/3")!)
        
        let urls = try JSONDecoder().decode(RandomImagesResponse.self, from: data).message
        dogImageURLs = urls
    }
}

struct RandomImagesResponse: Codable {
    let message: [String]
    let status: String
}

#Preview {
    DogDetailScreen(breed: "Akita")
}
