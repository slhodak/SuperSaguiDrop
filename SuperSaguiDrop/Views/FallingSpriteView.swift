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
}

class Onca {
    var sprite: SKSpriteNode
    var id: UUID
    var pets: Int = 0
    var attacks: Int = 0
    var isAttacking: Bool = false
    var isBeingPetted: Bool = false
    var isExpired: Bool {
        return attacks > 3
    }
    var isTamed: Bool {
        return pets > 2
    }
    
    init(sprite: SKSpriteNode) {
        self.sprite = sprite
        self.id = UUID()
    }
    
    // Onca attacks if it is idle, wild, and unexpired
    func canAttack() -> Bool {
        if self.isAttacking {
            return false
        }
        if self.isBeingPetted {
            return false
        }
        // If onca is petted 3 times, it is tamed
        if self.isTamed {
            return false
        }
        // If onca attacks 4 times, it expires
        if self.isExpired {
            return false
        }
        
        return true
    }
    
    func attack() {
        isAttacking = true
        let upDuration = 1.0
        let downDuration = 1.0
        let totalDuration = upDuration + downDuration
        
        let moveUp = SKAction.moveBy(
            x: 0, y: sprite.size.height, duration: upDuration
        )
        let moveDown = SKAction.moveBy(
            x: 0, y: -(sprite.size.height), duration: downDuration
        )
        let sequence = SKAction.sequence([moveUp, moveDown])
        
        sprite.run(sequence)
        attacks += 1
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration, execute: {
//            self.isAttacking = false
//        })
    }
    
    // Onca can only be petted if it is currently attacking
    func canBePetted() -> Bool {
        if self.isAttacking {
            return true
        }
        return false
    }
    
    func bePetted() {
        isAttacking = false
        isBeingPetted = true
        
        let changeTextureDuration = 0.1
        let pauseDuration = 0.5
        let descendDuration = 1.0
        let totalDuration = changeTextureDuration + pauseDuration + descendDuration
        
        let pettedOncaTexture = SKTexture(imageNamed: "onca_petted")
        let petAction = SKAction.animate(
            with: [pettedOncaTexture],
            timePerFrame: changeTextureDuration
        )
        let pauseAction = SKAction.wait(forDuration: pauseDuration)
        let descendAction = SKAction.moveBy(
            x: 0, y: -(sprite.size.height), duration: descendDuration
        )
        let sequence = SKAction.sequence(
            [petAction, pauseAction, descendAction])

        sprite.removeAllActions()
        sprite.run(sequence)

        sprite.xScale = 1.2
        sprite.yScale = 1.2

        pets += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration, execute: {
            self.isBeingPetted = false
            // also change sprite back to attacking
        })
    }
}
