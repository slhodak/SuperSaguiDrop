//
//  Onca.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/7/23.
//

import Foundation
import SpriteKit


class Onca {
    static var wildSize = CGSize(width: 125, height: 150)
    static var pettedSize = CGSize(width: 150, height: 175)
    static var tameSize = CGSize(width: 125, height: 150)
    static var bottomY = -(wildSize.height / 2)
    
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
    
    init(position: CGPoint, facingLeft: Bool) {
        self.sprite = SKSpriteNode(imageNamed: "onca_wild")
        self.id = UUID()
        
        initializeSprite(position: position, facingLeft: facingLeft)
    }
    
    func initializeSprite(position: CGPoint, facingLeft: Bool) {
        sprite.size = Onca.wildSize
        sprite.position = position
        if !facingLeft {
            sprite.xScale = -1
        }
    }
    
    func setSpriteTexture(imageName: String, duration: Double, size: CGSize) {
        let oncaTexture = SKTexture(imageNamed: imageName)
        let changeTextureAction = SKAction.animate(
            with: [oncaTexture],
            timePerFrame: duration
        )
        sprite.run(changeTextureAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
            self.sprite.size = size
        })
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
        let changeTextureDuration = 0.1
        let upDuration = 1.0
        let downDuration = 1.0
        let totalDuration = upDuration + downDuration
        
        isAttacking = true
        
        sprite.removeAllActions()
        setSpriteTexture(
            imageName: "onca_wild",
            duration: changeTextureDuration,
            size: Onca.wildSize
        )
        
        let ascendAction = SKAction.moveBy(
            x: 0, y: Onca.wildSize.height, duration: upDuration
        )
        let descendAction = SKAction.moveBy(
            x: 0, y: -(Onca.wildSize.height), duration: downDuration
        )
        let sequence = SKAction.sequence([ascendAction, descendAction])
        
        sprite.run(sequence)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration, execute: {
            self.isAttacking = false
            self.attacks += 1
        })
    }
    
    // Onca can only be petted if it is currently attacking
    func canBePetted() -> Bool {
        if self.isAttacking {
            return true
        }
        return false
    }
    
    func bePetted() {
        let changeTextureDuration = 0.1
        let pauseDuration = 0.5
        let descendDuration = 1.0
        let totalDuration = changeTextureDuration + pauseDuration + descendDuration
        
        isAttacking = false
        isBeingPetted = true
        
        sprite.removeAllActions()
        setSpriteTexture(
            imageName: "onca_petted",
            duration: changeTextureDuration,
            size: Onca.pettedSize
        )
        
        let pauseAction = SKAction.wait(forDuration: pauseDuration)
        let descendAction = SKAction.move(
            to: CGPoint(x: sprite.position.x, y: Onca.bottomY),
            duration: descendDuration
        )
        let sequence = SKAction.sequence([pauseAction, descendAction])
        sprite.run(sequence)
        
        pets += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration, execute: {
            self.isBeingPetted = false
        })
    }
    
    func handleTamed() {
        sprite.removeAllActions()
        setSpriteTexture(
            imageName: "onca_tame",
            duration: 0.1,
            size: Onca.tameSize
        )
        
        let pauseAction = SKAction.wait(forDuration: 0.5)
        let descendAction = SKAction.move(
            to: CGPoint(x: 0, y: Onca.bottomY),
            duration: 1.0
        )
        let sequence = SKAction.sequence([pauseAction, descendAction])
        sprite.run(sequence)
    }
}
