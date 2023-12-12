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


struct GameView: View {
    @Binding var isGameRunning: Bool
    
    @StateObject var poseEstimator = PoseEstimator()
    @State private var saguis = [UUID: Sagui]()
    @State private var onca: Onca?
    @State private var saguisCaught: Int = 0
    @State private var oncasTamed: Int = 0
    // Using @State to make struct properties mutable might not be ideal; consider classes to manage
    @State private var saguiFrequency: Int = 4
    @State private var oncaLikelihood: Int = 20
    private var maxSaguisLost: Int = 3
    @State private var saguisLost: Int = 0
    
    func getScore() -> Int {
        return saguisCaught + (oncasTamed * 4) + (gameTimer.gameTick / 4)
    }
    
    var themeSongPlayer = ThemeSongPlayer()
    
    private let size: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.width * 1920 / 1080
    )
    private let gameTimer: GameTimer = GameTimer()
    
    init(isGameRunning: Binding<Bool>) {
        self._isGameRunning = isGameRunning
    }
    
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
        Sprite1: \(saguis.first?.value.sprite.position ?? CGPoint())
        """
    }
    
    var body: some View {
        VStack {
            HUDView(saguisCaught: saguisCaught, oncasTamed: oncasTamed)
            ZStack {
                CameraViewWrapper(poseEstimator: poseEstimator)
                StickFigureView(poseEstimator: poseEstimator, size: size)
                InteractiveSpritesView(scene: spriteScene)
//                DebugView(debugData: debugData)
            }.frame(
                width: size.width,
                height: size.height,
                alignment: .center)
        }
        .onAppear() {
            startGame()
        }
        .onDisappear() {
            stopGame()
        }
    }
    
    func startGame() {
        isGameRunning = true
        gameTimer.gameTickFunctions = gameTickFunctions
        poseEstimator.onFrameUpdate = onFrameUpdate
        themeSongPlayer.start()
    }
    
    func stopGame() {
        themeSongPlayer.stop()
        isGameRunning = false
    }
    
    func onFrameUpdate() -> Void {
        if isGameRunning {
            handleCollisions()
            runOncaLifecycle()
            removeLostSaguis()
            checkGameOver()
        }
    }
    
    func checkGameOver() -> Void {
        if gameIsOver() {
            print("Game over!")
            print("Saguis Saved: \(saguisCaught)")
            print("Oncas Tamed: \(oncasTamed)")
            print("Time Elapsed: \(gameTimer.gameTick)")
            print("Score: \(getScore())")
            isGameRunning = false
        }
    }
    
    func gameIsOver() -> Bool {
        if (saguisLost >= maxSaguisLost) {
            return true
        }
        return false
    }
    
    func gameTickFunctions() -> Void {
        if isGameRunning {
            if shouldCreateSagui() {
                createSagui()
            }
            if shouldCreateOnca() {
                createOnca()
            }
            if shouldIncreaseDifficulty() {
                increaseDifficulty()
            }
        }
    }
    
    func shouldIncreaseDifficulty() -> Bool {
        return gameTimer.gameTick % 10 == 0
    }
    
    func increaseDifficulty() {
        if oncaLikelihood < 100 {
            oncaLikelihood += 5
        }
        if saguiFrequency > 1 {
            saguiFrequency -= 1
        }
    }
    
    func shouldCreateSagui() -> Bool {
        return gameTimer.gameTick % saguiFrequency == 0
    }
    
    func createSagui() {
        let randomX = CGFloat.random(in: 0...size.width)
        let position = CGPoint(x: randomX, y: size.height + 200)
        let sagui = Sagui(position: position)
        
        saguis[sagui.id] = sagui
        spriteScene.addChild(sagui.sprite)
    }
    
    func removeLostSaguis() {
        var saguisToRemove: [Sagui] = []
        for (_, sagui) in saguis {
            if sagui.sprite.position.y < 0 {
                saguisToRemove.append(sagui)
            }
        }
        for sagui in saguisToRemove {
            saguis.removeValue(forKey: sagui.id)
            spriteScene.removeChildren(in: [sagui.sprite])
            saguisLost += 1
        }
    }
    
    func shouldCreateOnca() -> Bool {
        if onca != nil { return false }
        
        return Int.random(in: 0...100) < oncaLikelihood
    }
    
    func createOnca() {
        let randomX = CGFloat.random(in: 10...size.width-10)
        let facingLeft = randomX > (size.width / 2)
        let position = CGPoint(x: randomX, y: Onca.bottomY)
        self.onca = Onca(position: position, facingLeft: facingLeft)
        guard let onca = self.onca else { return }
        
        spriteScene.addChild(onca.sprite)
        onca.attack()
    }
    
    func runOncaLifecycle() {
        guard let onca = onca else { return }
        
        if onca.cannotBeTamed {
            spriteScene.removeChildren(in: [onca.sprite])
            self.onca = nil
        } else if onca.isExpired {
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
        for (id, sagui) in saguis {
            if eitherHandCollided(with: sagui.sprite) {
                spriteScene.removeChildren(in: [sagui.sprite])
                saguis.removeValue(forKey: id)
                saguisCaught += 1
            }
        }
    }
    
    func handleOncaCollisions() {
        guard let onca = onca else { return }
        
        if eitherHandCollided(with: onca.sprite) {
            if onca.canBePetted() {
                onca.bePetted()
                if onca.isTamed {
                    handleOncaTamed()
                }
            }
        }
    }
    
    func handleOncaTamed() {
        guard let onca = onca else { return }
        
        oncasTamed += 1
        onca.handleTamed(completion: {
            spriteScene.removeChildren(in: [onca.sprite])
            self.onca = nil
        })
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
        
        for (_, jointPosition) in handLandmarks {
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
