//
//  CameraViewController.swift
//  MirrorMe
//
//  Created by Sam Hodak
//

import UIKit
import AVFoundation
import AVKit
import Vision

class CameraViewController: UIViewController {
    
    private var cameraSession : AVCaptureSession?
    var delegate : AVCaptureVideoDataOutputSampleBufferDelegate?
    
    private let cameraQueue = DispatchQueue(label: "CameraOutput", qos: .userInteractive)
    
    private var cameraView : CameraView {
        view as! CameraView
    }
    
    override func loadView() {
        view = CameraView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraSession == nil {
                try prepareAVSession()
                cameraView.previewLayer.session = cameraSession
//                
//                let size = cameraView.previewLayer.bounds.size
//                print("Preview Layer Size: \(size.width) x \(size.height)")
//                
                cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            DispatchQueue.global(qos: .userInitiated).async {
                self.cameraSession?.startRunning()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // cameraSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func prepareAVSession() throws {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front) else { return }
        
          // Retrieve dimensions from the videoDevice's active format
//        let dimensions = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
//        print("Width: \(dimensions.width), Height: \(dimensions.height)")
        
        guard let deviceInput = try? AVCaptureDeviceInput(
            device: videoDevice) else { return }
        
        guard session.canAddInput(deviceInput) else { return }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.setSampleBufferDelegate(delegate, queue: cameraQueue)
        } else {
            return
        }
        
        session.commitConfiguration()
        cameraSession = session
    }
}
