//
//  GameServer.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/15/23.
//

import Foundation


class GameServer {
    
    func getServerUrl(path: String) -> String? {
        guard let config = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Config", ofType: "plist")!) else {
            print("Error building server URL string; could not find Config.plist")
            return nil
        }
        
        let serverIP = config["ServerIP"] as? String
        let serverPort = config["ServerPort"] as? String
        return "http://\(serverIP!):\(serverPort!)/\(path)"
    }
    
    func fetchScoresFor(userName: String, completion: @escaping ([Score]?) -> Void) {
        makeGetRequest(path: "recentScores", params: ["un": userName]) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let score = try decoder.decode([Score].self, from: data)
                    completion(score)
                } catch (let error) {
                    print("Error decoding response: \(error.localizedDescription)")
                    completion(nil)
                }
            case .failure(let error):
                print("Error sending request: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func postScore(score: Score) {
        makePostRequest(path: "score", payload: score.asDict)
    }
    
    func makeGetRequest(
        path: String,
        params: [String: Any],
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let baseUrl = getServerUrl(path: path) else { return }
        
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
        guard let urlString = getServerUrl(path: path) else { return }
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
