//
//  AllDogsScreen.swift
//  TCA_PoCApp
//
//  Created by Salvador on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

struct AllDogsScreen: View {
    let store: StoreOf<AllDogsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    List {
                        ForEach(viewStore.dogBuckets) { dogBucket in
                            Section(dogBucket.firstCharacter) {
                                ForEach(dogBucket.dogs) { dog in
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
                    
                    if viewStore.isLoading {
                        ProgressView()
                            .controlSize(.extraLarge)
                    }
                }
                .overlay {
                    if !viewStore.isLoading && viewStore.dogBuckets.isEmpty {
                        ContentUnavailableView {
                            Label("No dogs at the moment", systemImage: "pawprint")
                        } actions: {
                            Button("Retry") {
                                viewStore.send(.retryButtonTapped)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .navigationTitle("All dogs")
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
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllDogsScreen(, store: <#StoreOf<AllDogsFeature>#>)
//    }
//}
