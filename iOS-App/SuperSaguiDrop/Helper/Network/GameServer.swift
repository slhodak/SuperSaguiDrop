//
//  GameServer.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/15/23.
//

import Foundation


class GameServer {
    func postScore(
        userName: String,
        ts: Int,
        saguisSaved: Int,
        oncasTamed: Int,
        duration: Int,
        totalScore: Int) {
            let payload: [String: Any] = [
                "user_name": userName,
                "ts": ts,
                "saguisSaved": saguisSaved,
                "oncasTamed": oncasTamed,
                "duration": duration,
                "totalScore": totalScore,
            ]
            makePostRequest(path: "score", payload: payload)
        }
    
    func fetchScore(userName: String, completion: @escaping (Score?) -> Void) {
        makeGetRequest(path: "score", params: ["userName": userName]) { result in
            switch result {
            case .success(let data):
                do {
                    // Must decode a list of Scores
                    let decoder = JSONDecoder()
                    let score = try decoder.decode(Score.self, from: data)
                    completion(score)
                } catch {
                    completion(nil)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func makeGetRequest(
        path: String,
        params: [String: Any],
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let baseUrl = "http://192.168.15.160:3000/\(path)"
        let queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value as? String ) }
        var urlComponents = URLComponents(string: baseUrl)!
        urlComponents.queryItems = queryItems
        let request = URLRequest(url: urlComponents.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            } else {
                // If there's no data and no error, create a custom error
                let noDataError = NSError(
                    domain: "com.samhodak.error",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey : "No data received"])
                completion(.failure(noDataError))
            }
        }
        task.resume()
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
