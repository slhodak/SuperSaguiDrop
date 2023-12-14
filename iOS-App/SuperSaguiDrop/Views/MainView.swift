//
//  MainView.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/8/23.
//

import Foundation
import SwiftUI


struct MainView: View {
    @State private var gameState: GameState = GameState.initial
    @State var saguisCaught: Int = 0
    @State var oncasTamed: Int = 0
    @StateObject var gameTimer: GameTimer = GameTimer()
    
    var body: some View {
        NavigationStack {
            switch gameState {
            case GameState.initial:
                TitleScreenView(gameState: $gameState)
            case GameState.playing:
                GameView(gameState: $gameState,
                         saguisCaught: $saguisCaught,
                         oncasTamed: $oncasTamed,
                         gameTimer: gameTimer)
            case GameState.score:
                ScoreView(gameState: $gameState,
                          saguisCaught: saguisCaught,
                          oncasTamed: oncasTamed,
                          gameTick: gameTimer.gameTick)
            case GameState.recentScores:
                RecentScoresView(gameState: $gameState)
            }
        }
    }
}
