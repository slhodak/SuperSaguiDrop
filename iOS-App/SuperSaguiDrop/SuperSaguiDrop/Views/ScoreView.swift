//
//  ScoreView.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/12/23.
//

import Foundation
import SwiftUI
import SpriteKit


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
        ZStack {
            Image("jungle-background-2")
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    Image("square-plank-background")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 340)
                    
                    VStack {
                        ScoreItem(label: "Saguis Saved", value: saguisCaught)
                        ScoreItem(label: "Oncas Tamed", value: oncasTamed)
                        ScoreItem(label: "Time Elapsed", value: gameTick)
                        ScoreItem(label: "Final Score", value: calculateScore())
                    }
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
    
    func calculateScore() -> Int {
        return saguisCaught + (oncasTamed * 4) + (gameTick / 4)
    }
}


struct ScoreItem: View {
    var label: String
    var value: Int
    
    var body: some View {
        HStack {
            Text(label)
//                .foregroundColor(Color(red: 0.247, green: 0.890, blue: 0.204))
                .foregroundStyle(.white)
                .fontWeight(.bold)
                .font(.title)
            
            SSDNumber(number: value)
        }
    }
}
