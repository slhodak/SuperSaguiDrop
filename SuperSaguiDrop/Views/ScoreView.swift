//
//  ScoreView.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/12/23.
//

import Foundation
import SwiftUI


struct ScoreView: View {
    @Binding var gameState: GameState
    
    var saguisCaught: Int
    var oncasTamed: Int
    var gameTick: Int
    
    init(gameState: Binding<GameState>, saguisCaught: Int, oncasTamed: Int, gameTick: Int) {
        self._gameState = gameState
        self.saguisCaught = saguisCaught
        self.oncasTamed = oncasTamed
        self.gameTick = gameTick
    }
    
    var body: some View {
        VStack {
            Text("Final Score")
            Text("Saguis Saved: \(saguisCaught)")
            Text("Oncas Tamed: \(oncasTamed)")
            Text("Time Elapsed: \(gameTick)")
            Text("Score: \(calculateScore())")
            
            Button("Home") {
                self.gameState = GameState.initial
            }
        }
    }
    
    func calculateScore() -> Int {
        return saguisCaught + (oncasTamed * 4) + (gameTick / 4)
    }
    
}
