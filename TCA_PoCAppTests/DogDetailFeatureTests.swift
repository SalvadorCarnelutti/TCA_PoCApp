//
//  DogDetailFeatureTests.swift
//  TCA_PoCAppTests
//
//  Created by Salvador on 9/16/23.
//

import XCTest
import ComposableArchitecture
@testable import TCA_PoCApp

@MainActor
final class DogDetailFeatureTests: XCTestCase {
    static let URLs = [
        "https://images.dog.ceo/breeds/hound-basset/n02088238_11124.jpg",
        "https://images.dog.ceo/breeds/hound-english/n02089973_243.jpg",
        "https://images.dog.ceo/breeds/hound-walker/n02089867_146.jpg"
    ]
    static let breed = "hound"
    
    func testDogDetail() async {
        let store = TestStore(initialState: DogDetailFeature.State(breed: Self.breed)) {
            DogDetailFeature()
        } withDependencies: {
            $0.dogAPIClient.fetchDogImageURLs = { breen in Self.URLs }
        }
        
        await store.send(.screenAppeared) {
            $0.isLoading = true
        }
        
        await store.receive(.imageURLsResponse(Self.URLs)) {
            $0.isLoading = false
            $0.dogImageURLs = Self.URLs.compactMap { URL(string: $0) }
        }
    }
}

