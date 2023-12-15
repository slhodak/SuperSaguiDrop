//
//  GameServer.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/15/23.
//

import Foundation


class GameServer {
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
            "duration": duration,
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
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                // Handle invalid response
                print("Invalid response")
                return
            }
            
            // Ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // Parse and use the data returned from the server
            guard let jsonString = String(data: content, encoding: .utf8) else { return }
            print("Server responded: \(jsonString)")
        }
        
        // Start the task
        task.resume()
    }
}
