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
    @State private var saguisCaught: Int = 0
    @State private var oncasTamed: Int = 0

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
            HUDView(saguisCaught: saguisCaught, oncasTamed: oncasTamed)
            ZStack {
                CameraViewWrapper(poseEstimator: poseEstimator)
//                    .position(x: size.width / 2,
//                              y: (size.height / 2) + 20)
                StickFigureView(poseEstimator: poseEstimator, size: size)
                InteractiveSpritesView(scene: spriteScene)
//                DebugView(debugData: debugData)
//                    .font(.title2)
//                    .foregroundStyle(.white)
            }.frame(
                width: size.width,
                height: size.height,
                alignment: .center)
        }
        .onAppear() {
            self.gameTimer.gameTickFunctions = gameTickFunctions
            self.poseEstimator.onFrameUpdate = onFrameUpdate
        }
    }
    
    func onFrameUpdate() -> Void {
        self.handleCollisions()
        self.runOncaLifecycle()
    }
    
    func gameTickFunctions() -> Void {
        if shouldCreateSagui() {
            createSagui()
        }
        if shouldCreateOnca() {
            createOnca()
        }
    }
    
    func shouldCreateSagui() -> Bool {
        return  self.gameTimer.gameTick % 2 == 0
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
    
    func shouldCreateOnca() -> Bool {
        if self.onca != nil { return false }
        
        return Int.random(in: 0...100) > 75
    }
    
    func createOnca() {
        let randomX = CGFloat.random(in: 10...size.width-10)
        let facingLeft = randomX > size.width / 2
        let position = CGPoint(x: randomX, y: Onca.bottomY)
        self.onca = Onca(position: position, facingLeft: facingLeft)
        guard let onca = self.onca else { return }
        
        spriteScene.addChild(onca.sprite)
        onca.attack()
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
                saguisCaught += 1
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
                if onca.isTamed {
                    onca.handleTamed()
                    oncasTamed += 1
                    self.onca = nil
                }
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
        // Cache sprite coordinates to reduce property lookups within loop
        let spriteX = sprite.position.x
        let spriteY = sprite.position.y
        
        for (_, jointPosition) in poseEstimator.handLandmarksA {
            let jointPositionSpriteXY = scaleVNPointToSpriteView(vnPoint: jointPosition)
            let distance = hypot(
                jointPositionSpriteXY.x - spriteX,
                jointPositionSpriteXY.y - spriteY
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
