//
//  AllDogsFeature.swift
//  TCA_PoCApp
//
//  Created by Salvador on 9/10/23.
//

import Foundation
import ComposableArchitecture

struct AllDogsFeature: Reducer {
    struct State: Equatable {
        @PresentationState var dogDetail: DogDetailFeature.State?
        @PresentationState var alert: AlertState<Action.Alert>?
        var isLoading = false
        var dogBuckets = [DogBucket]()
    }
    
    enum Action: Equatable {
        case screenAppeared
        case retryButtonTapped
        case dogsResponse([Dog])
        case alert(PresentationAction<Alert>)
        case dogCellTapped(Dog)
        case dogDetail(PresentationAction<DogDetailFeature.Action>)
        enum Alert: Equatable {
            case networkError
        }
    }
    
    @Dependency(\.dogAPIClient) var dogAPIClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .screenAppeared, .retryButtonTapped:
                state.isLoading = true
                return .run { send in
                    do {
                        try await send(.dogsResponse(dogAPIClient.fetchAllDogs()))
                    } catch {
                        await send(.alert(.presented(.networkError)))
                    }
                }
            case let .dogsResponse(dogs):
                state.isLoading = false
                state.dogBuckets = bucketSortDogs(dogs)
                return .none
            case let .dogCellTapped(dog):
                state.dogDetail = DogDetailFeature.State(breed: dog.breed)
                return .none
            case .dogDetail:
                return .none
            case .alert(.presented(.networkError)):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("Network error")
                } message: {
                    TextState("An unexpected error occurred, please try again later")
                }
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.$dogDetail, action: /Action.dogDetail) {
            DogDetailFeature()
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
    
    private func bucketSortDogs(_ dogs: [Dog]) -> [DogBucket] {
        var dogsdDict = [String:[Dog]]()
        
        dogs.forEach { dogsdDict[$0.breed.first!.uppercased(), default: []].append($0) }
        var sorted = [DogBucket]()
        
        for (_, value) in dogsdDict.sorted(by: {$0.key < $1.key}) {
            sorted.append(DogBucket(dogs: value.sorted(by: { $0.breed < $1.breed })))
        }
        
        return sorted
    }
}

struct DogBucket: Identifiable, Equatable {
    let dogs: [Dog]
    
    var firstCharacter: String { dogs.first!.breed.first!.uppercased() }
    var id: String { firstCharacter }
}

struct Dog: Identifiable, Equatable {
    let breed: String
    let types: [String]
    
    var id: String { breed }
}

struct AllBreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}
