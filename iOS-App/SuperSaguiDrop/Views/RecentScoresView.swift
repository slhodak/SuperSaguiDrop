//
//  RecentScoresView.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/14/23.
//

import Foundation
import SwiftUI


struct RecentScoresView: View {
    @Binding var gameState: GameState
    var recentScores = [Score(score: 100), Score(score: 90), Score(score: 80)]
    
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
            Text(String(score.score))
        }
    }
}

struct Score: Identifiable {
    let id = UUID()
    let score: Int
}
