//
//  ContentView.swift
//  TCA_PoCApp
//
//  Created by Salvador on 9/9/23.
//

import SwiftUI

struct ContentView: View {
    @State private var dogBuckets = [[Dog]]()
    @State var isRequestInProgress: Bool = true
    @State var isAlertPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(dogBuckets, id: \.self) { dogBucket in
                        Section(dogBucket.first!.breed.first!.uppercased()) {
                            ForEach(dogBucket) { dog in
                                NavigationLink(destination: DogDetailScreen(breed: dog.breed)) {
                                    VStack(alignment: .leading) {
                                        Text(dog.breed.capitalized).font(.title)
                                        Text(dog.types.map { $0.capitalized }.joined(separator: ", "))
                                    }
                                }
                            }
                        }
                    }
                }
                
                if isRequestInProgress {
                    ProgressView()
                        .controlSize(.extraLarge)
                }
            }
            .navigationTitle("All dogs")
            .task {
                do {
                    try await fetchDogs()
                } catch {
                    isAlertPresented = true
                }
            }
            .alert(isPresented: $isAlertPresented) {
                Alert(title: Text("Network error"),
                      message: Text("An unexpected error occurred, please try again later"))
            }
        }
    }
    
    private func fetchDogs() async throws {
        guard dogBuckets.isEmpty else { return }
        
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://dog.ceo/api/breeds/list/all")!)
        let dogs = try JSONDecoder().decode(AllBreedsResponse.self, from: data).message.map { key, value in Dog(breed: key, types: value) }
        
        isRequestInProgress = false
        dogBuckets = bucketSortDogs(dogs)
    }
    
    private func bucketSortDogs(_ dogs: [Dog]) -> [[Dog]] {
        var dogsdDict = [String:[Dog]]()
        
        dogs.forEach { dogsdDict[$0.breed.first!.uppercased(), default: []].append($0) }
        var sorted = [[Dog]]()
        
        for (_, value) in dogsdDict.sorted(by: {$0.key < $1.key}) {
            sorted.append(value.sorted(by: { $0.breed < $1.breed }))
        }
        
        return sorted
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Dog: Hashable, Identifiable {
    let id = UUID()
    let breed: String
    let types: [String]
}

struct AllBreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}
