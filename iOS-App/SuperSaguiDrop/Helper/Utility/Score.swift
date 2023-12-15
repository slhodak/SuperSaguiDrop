//
//  Score.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/15/23.
//

import Foundation


struct Score: Identifiable, Decodable {
    let id = UUID()
    let userName: String
    let ts: Int
    let saguisSaved: Int
    let oncasTamed: Int
    let duration: Int
    let totalScore: Int
    
    enum CodingKeys: String, CodingKey {
        case userName = "un"
        case ts = "tis"
        case saguisSaved = "ss"
        case oncasTamed = "ot"
        case duration = "d"
        case totalScore = "tos"
    }
}
