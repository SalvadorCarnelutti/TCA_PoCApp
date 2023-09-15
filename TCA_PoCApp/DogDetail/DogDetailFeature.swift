//
//  DogDetailFeature.swift
//  TCA_PoCApp
//
//  Created by Salvador on 9/15/23.
//

import Foundation
import ComposableArchitecture

struct DogDetailFeature: Reducer {
    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        var breed: String
        var isLoading = false
        var dogImageURLs = [URL]()
    }

    enum Action: Equatable {
        case screenAppeared
        case imageURLsResponse([URL])
        case refreshButtonTapped
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case networkError
            case dismiss
        }
    }
    
    @Dependency(\.dogAPIClient) var dogAPIClient
    @Dependency(\.dismiss) var dismiss


    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .screenAppeared, .refreshButtonTapped:
                state.isLoading = true
                return .run { [breed = state.breed] send in
                    do {
                        try await send(.imageURLsResponse(dogAPIClient.fetchDogImageURLs(breed)))
                    } catch {
                        await send(.alert(.presented(.networkError)))
                    }
                }
            case let .imageURLsResponse(imageURLs):
                state.dogImageURLs = imageURLs
                return .none
            case .alert(.presented(.networkError)):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("Network error")
                } actions: {
                    ButtonState(action: .dismiss) {
                        TextState("OK")
                    }
                } message: {
                    TextState("An unexpected error occurred, please try again later")
                }
                return .none
            case .alert(.presented(.dismiss)):
                return .run { _ in await dismiss() }
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
