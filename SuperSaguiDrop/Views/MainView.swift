//
//  SampleView.swift
//  MirrorMe
//
//  Created by Sam Hodak
//

import Foundation
import SwiftUI
import AVFoundation
import AVKit
import Vision
import Combine
import CoreGraphics
import SpriteKit

struct MainView: View {
    @StateObject var poseEstimator = PoseEstimator()
    @State private var saguis = [UUID: SKSpriteNode]()
    @State private var onca: Onca?
    @State private var targetsTouched: Int = 0

    private let size: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.width * 1920 / 1080
    )
    private let gameTimer: GameTimer = GameTimer()

    var spriteScene: SKScene = {
        let scene = SpriteScene()
        // Computed again because self.size is not available yet
        scene.size = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width * 1920 / 1080
        )
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.5)
        return scene
    }()
    
    var debugData: String {
        """
        Sprite1: \(self.saguis.first?.value.position ?? CGPoint())
        """
    }
    
    var body: some View {
        VStack {
            ZStack {
                CameraViewWrapper(poseEstimator: poseEstimator)
                StickFigureView(poseEstimator: poseEstimator, size: size)
                FallingSpriteView(scene: spriteScene)
//                DebugView(debugData: debugData)
//                    .font(.title2)
//                    .foregroundStyle(.white)
            }.frame(
                width: size.width,
                height: size.height,
                alignment: .center)
            
            HStack {
                Text("Points:")
                    .font(.title)
                Text(String(targetsTouched))
                    .font(.title)
            }
        }
        .onAppear() {
            self.gameTimer.gameTimedFunctions = gameTimedFunctions
            self.poseEstimator.onFrameUpdate = onFrameUpdate
        }
    }
    
    func onFrameUpdate() -> Void {
        self.handleCollisions()
        self.runOncaLifecycle()
    }
    
    func gameTimedFunctions() -> Void {
        if self.gameTimer.gameTick % 2 == 0 {
            createSagui()
        }
        if self.gameTimer.gameTick % 3 == 0 {
            createOnca()
        }
    }
    
    func createSagui() {
        let id = UUID()
        let isSpecial = Float.random(in: 0...1) > 0.9
        let sprite = createSaguiSprite(special: isSpecial)
        
        saguis[id] = sprite
        spriteScene.addChild(sprite)
        
        if isSpecial {
            let downwardImpulse = CGVector(dx: 0, dy: -150)
            sprite.physicsBody?.applyImpulse(downwardImpulse)
        }
        
        // Remove sprite after it falls off the screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            saguis.removeValue(forKey: id)
            spriteScene.removeChildren(in: [sprite])
        }
    }
    
    func createSaguiSprite(special: Bool = false) -> SKSpriteNode {
        let spriteFile = special ? "sagui-4" : "sagui-3"
        let sprite = SKSpriteNode(imageNamed: spriteFile)
        let randomX = CGFloat.random(in: 0...size.width)
        
        sprite.size = CGSize(width: 75, height: 75)
        sprite.position = CGPoint(x: randomX, y: size.height + 200)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.affectedByGravity = true
        
        return sprite
    }
    
    func createOnca() {
        let onca = Onca(sprite: createOncaSprite())
        self.onca = onca
        spriteScene.addChild(onca.sprite)
        onca.attack()
    }
    
    func createOncaSprite() -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: "onca_wild")
        let randomX = CGFloat.random(in: 10...size.width-10)
        
        sprite.size = CGSize(width: 125, height: 150)
        sprite.position = CGPoint(x: randomX, y: -(sprite.size.height * 0.5))
        if randomX > self.size.width / 2 {
            sprite.xScale = -1
        }
        
        return sprite
    }

    func runOncaLifecycle() {
        guard let onca = onca else {
            return
        }
        
        if onca.isExpired {
            spriteScene.removeChildren(in: [onca.sprite])
            self.onca = nil
        } else if onca.canAttack() {
            onca.attack()
        }
    }
    
    func handleCollisions() {
        handleSaguiCollisions()
        handleOncaCollisions()
    }
    
    func handleSaguiCollisions() {
        for (spriteID, sprite) in saguis {
            if eitherHandCollided(with: sprite) {
                spriteScene.removeChildren(in: [sprite])
                saguis.removeValue(forKey: spriteID)
                self.targetsTouched += 1
            }
        }
    }
    
    func handleOncaCollisions() {
        guard let onca = onca else {
            return
        }
        if eitherHandCollided(with: onca.sprite) {
            if onca.canBePetted() {
                onca.bePetted()
            }
        }
    }
    
    func eitherHandCollided(with sprite: SKSpriteNode) -> Bool {
        return handCollided(
                    with: sprite,
                    handLandmarks: poseEstimator.handLandmarksA) ||
                handCollided(
                    with: sprite,
                    handLandmarks: poseEstimator.handLandmarksB)
    }
    
    func handCollided(with sprite: SKSpriteNode, handLandmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> Bool {
        for (_, jointPosition) in poseEstimator.handLandmarksA {
            let jointPositionSpriteXY = scaleVNPointToSpriteView(vnPoint: jointPosition)
            let distance = hypot(
                jointPositionSpriteXY.x - sprite.position.x,
                jointPositionSpriteXY.y - sprite.position.y
            )
            
            if distance < 20 { // Collision threshold
                return true
            }
        }
        return false
    }
    
    func scaleVNPointToSpriteView(vnPoint: VNPoint) -> CGPoint {
        return CGPoint(
            x: (1 - vnPoint.x) * size.width,
            y: vnPoint.y * size.height
        )
    }
}
