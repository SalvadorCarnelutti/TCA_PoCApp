//
//  DogDetailScreen.swift
//  TCA_PoCApp
//
//  Created by Salvador on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

struct DogDetailScreen: View {
    let store: StoreOf<DogDetailFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                VStack(alignment: .center) {
                    ForEach(viewStore.dogImageURLs, id: \.self) { dogImageURL in
                        AsyncImage(url: dogImageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                                .controlSize(.large)
                        }
                        .shadow(radius: 1)
                    }
                }
                
                Spacer()
                
                Button("Refresh") {
                    viewStore.send(.refreshButtonTapped)
                }
                .buttonStyle(.borderedProminent)
                .navigationTitle(viewStore.breed.capitalized)
            }
            .task {
                viewStore.send(.screenAppeared)
            }
            .alert(
                store: self.store.scope(
                    state: \.$alert,
                    action: { .alert($0) }
                )
            )
        }
    }
}

#Preview {
    NavigationStack {
        DogDetailScreen(
            store: Store(initialState: DogDetailFeature.State(breed: "australian")) {
                DogDetailFeature()
            }
        )
    }
}
