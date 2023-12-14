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
    
    let gameServerAPI = GameServerAPI()
    
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
                
                Button(action: {
                    gameServerAPI.postScore(user: "me",
                                          timestamp: 1010,
                                          saguisSaved: saguisCaught,
                                          oncasTamed: oncasTamed,
                                          duration: gameTick,
                                          totalScore: calculateScore())
                }) {
                    Text("Save Score")
                        .font(.largeTitle)
                }
                .frame(width: 100, height: 50)
                
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


class GameServerAPI {
    func postScore(
        user_name: String,
        ts: Int,
        saguisSaved: Int,
        oncasTamed: Int,
        duration: Int,
        totalScore: Int) {
        let payload: [String: Any] = [
            "user_name": user_name,
            "ts": ts,
            "saguisSaved": saguisSaved,
            "oncasTamed": oncasTamed,
            "totalScore": totalScore,
        ]
            makePostRequest(path: "score", payload: payload)
    }
    
    func makePostRequest(path: String, payload: [String: Any]) {
        let urlString = "http://192.168.15.160:3000/\(path)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Ensure there is no error for this HTTP response
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            
            // Ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // Parse and use the data returned from the server
            guard let jsonString = String(data: content, encoding: .utf8) else { return }
            print(jsonString)
        }
        
        // Start the task
        task.resume()
    }
}
