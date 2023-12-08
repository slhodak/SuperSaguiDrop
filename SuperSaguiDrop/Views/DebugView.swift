//
//  DebugView.swift
//  MirrorMe
//
//  Created by Sam Hodak on 11/16/23.
//

import Foundation
import SwiftUI


struct DebugView: View {
    var debugData: String
    
    var body: some View {
        Text(debugData)
            .background(.black)
            .font(.title2)
            .foregroundStyle(.white)
    }
}
