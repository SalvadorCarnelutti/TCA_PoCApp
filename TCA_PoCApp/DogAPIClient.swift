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
    
    private static func fetchDogs() async throws -> [Dog] {
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://dog.ceo/api/breeds/list/all")!)
        let dogs = try JSONDecoder().decode(AllBreedsResponse.self, from: data).message.map { key, value in Dog(breed: key, types: value) }
        
        return dogs
    }
}

extension DogAPIClient: DependencyKey {
  static let liveValue = Self(
    fetchAllDogs: {
        let dogs = try await Self.fetchDogs()
        return dogs
    }
  )
}

extension DependencyValues {
  var dogAPIClient: DogAPIClient {
    get { self[DogAPIClient.self] }
    set { self[DogAPIClient.self] = newValue }
  }
}
