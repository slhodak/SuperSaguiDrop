//
//  Sagui.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/7/23.
//

import Foundation
import SpriteKit


class Sagui {
    var sprite: SKSpriteNode
    var id: UUID
    
    init(position: CGPoint) {
        self.sprite = SKSpriteNode()
        self.id = UUID()
        
        let isSpecial = Float.random(in: 0...1) > 0.9
        self.sprite = initializeSprite(position: position, isSpecial: isSpecial)
        
        if isSpecial {
            let downwardImpulse = CGVector(dx: 0, dy: -150)
            self.sprite.physicsBody?.applyImpulse(downwardImpulse)
        }
    }
    
    func initializeSprite(position: CGPoint, isSpecial: Bool) -> SKSpriteNode {
        let spriteFile = isSpecial ? "sagui-4" : "sagui-3"
        let sprite = SKSpriteNode(imageNamed: spriteFile)
        
        sprite.size = CGSize(width: 75, height: 75)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.affectedByGravity = true
        sprite.position = position
        
        return sprite
    }
}
