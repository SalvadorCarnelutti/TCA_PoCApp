//
//  DogAPIClient.swift
//  TCA_PoCApp
//
//  Created by Salvador on 9/13/23.
//

import ComposableArchitecture
import Foundation

struct DogAPIClient {
    var fetchAllDogs: () async throws -> [Dog]
    var fetchDogImageURLs: (String) async throws -> [URL]
    
    private static func fetchDogs() async throws -> [Dog] {
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://dog.ceo/api/breeds/list/all")!)
        let dogs = try JSONDecoder().decode(AllBreedsResponse.self, from: data).message.map { key, value in Dog(breed: key, types: value) }
        
        return dogs
    }
    
    private static func fetchImageURLs(for breed: String) async throws -> [URL] {
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://dog.ceo/api/breed/\(breed)/images/random/3")!)
        
        let urls = try JSONDecoder().decode(RandomImagesResponse.self, from: data).message
        return urls.compactMap { URL(string: $0) }
    }
}

extension DogAPIClient: DependencyKey {
    static let liveValue = Self(
        fetchAllDogs: {
            let dogs = try await Self.fetchDogs()
            return dogs
        }, fetchDogImageURLs: { breed in
            let imageURLs = try await Self.fetchImageURLs(for: breed)
            return imageURLs
        }
    )
}

extension DependencyValues {
    var dogAPIClient: DogAPIClient {
        get { self[DogAPIClient.self] }
        set { self[DogAPIClient.self] = newValue }
    }
}

struct RandomImagesResponse: Codable {
    let message: [String]
    let status: String
}
