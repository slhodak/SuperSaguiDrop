//
//  TitleScreenView.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/12/23.
//

import Foundation
import SwiftUI


struct TitleScreenView: View {
    @Binding var gameState: GameState
    
    init(gameState: Binding<GameState>) {
        self._gameState = gameState
    }
    
    var body: some View {
        ZStack {
            Image("ssd-hills-background")
                .ignoresSafeArea()
            
            VStack {
                Image("ssd-logo-12dec23")
                    .resizable()
                    .frame(width: 400, height: 400)
                
                Image("ssd-play-button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(20)
                    .onTapGesture {
                        self.gameState = GameState.playing
                    }
            }
        }
    }
}
