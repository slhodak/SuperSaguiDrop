//
//  RecentScoresView.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/14/23.
//

import Foundation
import SwiftUI

let mockScores = [
    Score(userName: "me",
          timestamp: 1010,
          saguisSaved: 15,
          oncasTamed: 2,
          duration: 26,
          totalScore: 30)
]

struct RecentScoresView: View {
    @Binding var gameState: GameState
    @State var recentScores: [Score]
    let gameServer = GameServer()
    
    init(gameState: Binding<GameState>, recentScores: [Score]) {
        self._gameState = gameState
        self.recentScores = []
        self.gameServer.fetchScore(userName: "me", completion: self.updateScore)
    }
    
    func updateScore(score: Score?) {
        guard let score = score else { return }
        
        recentScores.append(score)
    }
    
    var body: some View {
        ZStack {
            Image("ssd-hills-background")
                .ignoresSafeArea()
            
            VStack {
                ForEach(recentScores) { score in
                    RecentScoreView(score: score)
                }
                
                Image("home-jungle-button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .onTapGesture {
                        self.gameState = GameState.initial
                    }
            }
        }
    }
}

struct RecentScoreView: View {
    var score: Score
    
    var body: some View {
        HStack {
            Text("Score")
            Text(String(score.totalScore))
        }
    }
}

