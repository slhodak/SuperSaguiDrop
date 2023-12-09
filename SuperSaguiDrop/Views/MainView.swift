//
//  MainView.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/8/23.
//

import Foundation
import SwiftUI


struct MainView: View {
    @State private var isGameRunning: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: GameView(isGameRunning: $isGameRunning)) {
                    Text("Play").font(.title)
                }
            }
        }
    }
}
