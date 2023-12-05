//
//  FallingSpriteView.swift
//  MirrorMe
//
//  Created by Sam Hodak on 11/16/23.
//

import Foundation
import SwiftUI
import SpriteKit


struct FallingSpriteView: View {
    var scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .edgesIgnoringSafeArea(.all)
    }
}

class SpriteScene: SKScene {
    override func didMove(to view: SKView) {
        // Initialize and add sprite
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Here you can access the current position of mySprite
    }
}
