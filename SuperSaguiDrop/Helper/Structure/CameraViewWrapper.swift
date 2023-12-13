//
//  CameraViewWrapper.swift
//  MirrorMe
//
//  Created by Sam Hodak
//

import Foundation
import SwiftUI
import AVFoundation
import Vision

struct CameraViewWrapper : UIViewControllerRepresentable {
    
    @ObservedObject var handTracker : HandTracker
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let cvc = CameraViewController()
        cvc.delegate = handTracker
        return cvc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
}
