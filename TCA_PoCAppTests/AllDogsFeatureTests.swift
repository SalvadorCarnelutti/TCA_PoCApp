//
//  TCA_PoCAppTests.swift
//  TCA_PoCAppTests
//
//  Created by Salvador on 9/13/23.
//

import XCTest
import ComposableArchitecture
@testable import TCA_PoCApp

@MainActor
final class AllDogsFeatureTests: XCTestCase {
    static let australian = Dog(breed: "australian", types: ["shepherd"])
    static let bulldog = Dog(breed: "bulldog", types: ["boston", "english", "french"])
    static var dogs: [Dog] { [Self.bulldog, Self.australian] }
    
    func testAllDogs() async {
        let store = TestStore(initialState: AllDogsFeature.State()) {
            AllDogsFeature()
        } withDependencies: {
            $0.dogAPIClient.fetchAllDogs = { Self.dogs }
        }
        
        await store.send(.screenAppeared) {
            $0.isLoading = true
        }
        
        await store.receive(.dogsResponse(Self.dogs)) {
            $0.isLoading = false
            $0.dogBuckets = [DogBucket(dogs: [Self.australian]), DogBucket(dogs: [Self.bulldog])]
        }
    }
}

