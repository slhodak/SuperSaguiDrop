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
    @State private var sprites = [UUID: SKSpriteNode]()
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
        Sprite1: \(self.sprites.first?.value.position ?? CGPoint())
        """
    }
    
    var body: some View {
        VStack {
            ZStack {
                CameraViewWrapper(poseEstimator: poseEstimator)
//                StickFigureView(poseEstimator: poseEstimator, size: size)
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
    }
    
    func gameTimedFunctions() -> Void {
        createAnimatedSpriteWithTimer()
    }
    
    func createAnimatedSpriteWithTimer() {
        let newID = UUID()
        let isSpecial = Float.random(in: 0...1) > 0.9
        let newSprite = createSagui(special: isSpecial)
        
        sprites[newID] = newSprite
        spriteScene.addChild(newSprite)
        
        if isSpecial {
            let downwardImpulse = CGVector(dx: 0, dy: -150)
            newSprite.physicsBody?.applyImpulse(downwardImpulse)
        }
        
        // Remove sprite after it falls off the screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            sprites.removeValue(forKey: newID)
        }
    }
    
    func createSagui(special: Bool = false) -> SKSpriteNode {
        let spriteFile = special ? "sagui-4" : "sagui-3"
        let sprite = SKSpriteNode(imageNamed: spriteFile)
        let randomX = CGFloat.random(in: 0...size.width)
        
        sprite.size = CGSize(width: 75, height: 75)
        sprite.position = CGPoint(x: randomX, y: size.height + 200)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.affectedByGravity = true
        
        return sprite
    }
    
    func handleCollisions() {
        for (spriteID, sprite) in sprites {
            if eitherHandCollided(with: sprite) {
                spriteScene.removeChildren(in: [sprite])
                sprites.removeValue(forKey: spriteID)
                self.targetsTouched += 1
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
