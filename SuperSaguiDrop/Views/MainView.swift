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
                Image("ssd-logo-draft")
                    .resizable()
                    .frame(width: 400, height: 400)
                
                NavigationLink(destination: GameView(isGameRunning: $isGameRunning)) {
                    Image("ssd-play-button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .padding(20)
                }
            }
            .background(Color.green)
        }
    }
}
