//
//  TCA_PoCAppApp.swift
//  TCA_PoCApp
//
//  Created by Salvador on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCA_PoCAppApp: App {
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                AllDogsScreen(
                    store: Store(initialState: AllDogsFeature.State()) {
                        AllDogsFeature()
                    }
                )
            }       
        }
    }
}
