//
//  HUDView.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/7/23.
//

import Foundation
import SwiftUI


struct HUDView: View {
    @ObservedObject var handTracker: HandTracker
    
    var saguisCaught: Int
    var oncasTamed: Int
    
    init(handTracker: HandTracker, saguisCaught: Int, oncasTamed: Int) {
        self.handTracker = handTracker
        self.saguisCaught = saguisCaught
        self.oncasTamed = oncasTamed
    }
    
    var body: some View {
        HStack {
            HStack {
                Image("sagui-face-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                Text(String(saguisCaught))
                    .font(.title)
                    .foregroundStyle(Color.white)
            }
            
            HStack {
                Image("onca-face-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                Text(String(oncasTamed))
                    .font(.title)
                    .foregroundStyle(Color.white)
            }
            
            Spacer()
            
            handTracker.detectsAnyHands ?
            Image("hand-icon")
                .resizable()
                .scaledToFit()
                .frame(height: 50) :
            Image("dotted-hand-icon")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
        }
        .padding([.leading, .trailing], 20)
    }
}
