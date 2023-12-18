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
    @State var recentScores: [Score] = []
    let gameServer = GameServer()
    
    init(gameState: Binding<GameState>) {
        self._gameState = gameState
    }
    
    func updateScores(scores: [Score]?) {
        guard let scores = scores else {
            print("No scores returned")
            return
        }
        
        recentScores = scores
    }
    
    var body: some View {
        ZStack {
            Image("ssd-hills-background")
                .ignoresSafeArea()
            
            VStack {
                Image("scores-title-text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                
                ScrollView {
                    ForEach(recentScores) { score in
                        RecentScoreView(score: score)
                    }
                }
                .frame(height: 400)
                
                Image("home-jungle-button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .onTapGesture {
                        self.gameState = GameState.initial
                    }
            }
        }
        .onAppear() {
            gameServer.fetchScoresFor(userName: "testUser", completion: self.updateScores)
        }
    }
}

struct RecentScoreView: View {
    var score: Score
    
    var body: some View {
        VStack {
            Text(formattedTimestamp(score.ts))
                .foregroundStyle(.green)
                .fontWeight(.bold)
                .font(.title2)
            ScoreItem(label: "Saguis Saved", value: score.saguisSaved, textColor: .black, numberHeight: 30)
            ScoreItem(label: "Oncas Tamed", value: score.oncasTamed, textColor: .black, numberHeight: 30)
            ScoreItem(label: "Time Elapsed", value: score.duration, textColor: .black, numberHeight: 30)
            ScoreItem(label: "Final Score", value: score.totalScore, textColor: .black, numberHeight: 30)
        }
    }
    
    func formattedTimestamp(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d, yyyy, h:mm a" // Sat March 4, 2023, 2:34 PM
        return dateFormatter.string(from: date)
    }
}
