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
    static var maxAttacks = 4
    static var petsToTame = 3
    
    var sprite: SKSpriteNode
    var id: UUID
    var petsRemaining: Int = Onca.petsToTame
    var attacksRemaining: Int = Onca.maxAttacks
    var isAttacking: Bool = false
    var isBeingPetted: Bool = false
    var isExpired: Bool {
        return attacksRemaining == 0
    }
    var isTamed: Bool {
        return petsRemaining == 0
    }
    // When it is too late to tame this Onca
    var cannotBeTamed: Bool {
        return attacksRemaining < petsRemaining
    }
    
    init(position: CGPoint, facingLeft: Bool) {
        self.sprite = SKSpriteNode(imageNamed: "onca_wild")
        self.id = UUID()
        
        initializeSprite(position: position, facingLeft: facingLeft)
    }
    
    func initializeSprite(position: CGPoint, facingLeft: Bool) {
        sprite.size = Onca.wildSize
        sprite.position = position
        if facingLeft {
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
        
        isAttacking = true
        
        sprite.removeAllActions()
        setSpriteTexture(
            imageName: "onca_wild",
            duration: changeTextureDuration,
            size: Onca.wildSize
        )
        
        let ascendAction = SKAction.moveBy(
            x: 0, y: Onca.wildSize.height, duration: 1.0
        )
        let descendAction = SKAction.moveBy(
            x: 0, y: -(Onca.wildSize.height), duration: 1.0
        )
        let sequence = SKAction.sequence([ascendAction, descendAction, SKAction.run({
            self.isAttacking = false
            self.attacksRemaining -= 1 // Attack not counted until animation completes
        })])
        
        sprite.run(sequence)
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
        
        isAttacking = false
        isBeingPetted = true
        
        sprite.removeAllActions()
        setSpriteTexture(
            imageName: "onca_petted",
            duration: changeTextureDuration,
            size: Onca.pettedSize
        )
        
        let pauseAction = SKAction.wait(forDuration: 0.5)
        let descendAction = SKAction.move(
            to: CGPoint(x: sprite.position.x, y: Onca.bottomY),
            duration: 1.0
        )
        let sequence = SKAction.sequence([pauseAction, descendAction, SKAction.run({
            self.isBeingPetted = false
        })])
        sprite.run(sequence)
        
        petsRemaining -= 1
    }
    
    func handleTamed(completion: @escaping () -> Void = {}) {
        sprite.removeAllActions()
        setSpriteTexture(
            imageName: "onca_tame",
            duration: 0.1,
            size: Onca.tameSize
        )
        
        let pauseAction = SKAction.wait(forDuration: 0.5)
        let shrinkAction = SKAction.scale(
            to: 0.0001,
            duration: 1.0
        )
        let sequence = SKAction.sequence([
            pauseAction, shrinkAction, SKAction.run(completion)
        ])
        sprite.run(sequence)
    }
}
