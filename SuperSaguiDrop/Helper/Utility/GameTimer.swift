//
//  GameTimer.swift
//  MirrorMe
//
//  Created by Sam Hodak on 11/16/23.
//

import Foundation
import SwiftUI


class GameTimer: ObservableObject {
    private var timer: Timer?
    private let timerQueue = DispatchQueue(
        label: "com.samhodak.super-sagui-drop.timer",
        qos: .background)
    var gameTickFunctions: (() -> Void)?
    var gameTick: Int = 0

    private let size: CGSize = UIScreen.main.bounds.size
    
    func startTimer() {
        resetTimer()
        timerQueue.async {
            let runLoop = RunLoop.current
            
            let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
                DispatchQueue.main.async {
                    guard let this = self else {
                        return
                    }
                    this.handleGameTick()
                }
            }
            
            runLoop.add(timer, forMode: .common)
            timer.fire()
            
            runLoop.run()
        }
    }
    
    func stopTimer() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func resetTimer() {
        gameTick = 0
    }

    func handleGameTick() -> Void {
        (self.gameTickFunctions ?? {})()
        gameTick += 1
    }
    
    deinit {
        stopTimer()
    }
}
