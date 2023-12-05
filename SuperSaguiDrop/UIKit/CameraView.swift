//
//  CameraView.swift
//  MirrorMe
//
//  Created by Sam Hodak
//

import UIKit
import AVKit

class CameraView: UIView {
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
