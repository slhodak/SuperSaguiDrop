//
//  SSDNumber.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/12/23.
//

import Foundation
import SwiftUI


// Display a number using the included digit images
struct SSDNumber: View {
    var number: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(digits(from: number), id: \.self) { digit in
                Image("ssd-\(digit)")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
        }
    }
    
    func digits(from: Int) -> [Int] {
        return String(number).compactMap { $0.wholeNumberValue }
    }
}
