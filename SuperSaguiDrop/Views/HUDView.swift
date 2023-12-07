//
//  HUDView.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/7/23.
//

import Foundation
import SwiftUI


struct HUDView: View {
    var saguisCaught: Int
    var oncasTamed: Int
    
    init(saguisCaught: Int, oncasTamed: Int) {
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
            .padding([.leading], 15)
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
        }
        .background(Image("2d-jungle").offset(x: 0, y: 275))
    }
}
