//
//  GameTimer.swift
//  MirrorMe
//
//  Created by Sam Hodak on 11/16/23.
//

import Foundation
import SwiftUI


class GameTimer {
    private var timer: Timer?
    private let timerQueue = DispatchQueue(label: "com.samhodak.mirrorme.timer", qos: .background)
    var gameTimedFunctions: (() -> Void)?

    private let size: CGSize = UIScreen.main.bounds.size
    
    init() {
        startTimer()
    }
    
    func startTimer() {
        timerQueue.async {
            let runLoop = RunLoop.current
            
            let timer = Timer(timeInterval: 2, repeats: true) { [weak self] _ in
                DispatchQueue.main.async {
                    guard let this = self else {
                        return
                    }
                    (this.gameTimedFunctions ?? {})()
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
    
    deinit {
        stopTimer()
    }
}
