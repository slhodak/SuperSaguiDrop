//
//  PoseEstimator.swift
//  MirrorMe
//
//  Created by Sam Hodak
//

import UIKit
import AVFoundation
import Vision
import Combine

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    @Published var handLandmarksA = [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]()
    @Published var handLandmarksB = [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]()
    
    let confidenceThreshold: Float = 0.5
    let sequenceHandler = VNSequenceRequestHandler()
    
    var onFrameUpdate: (() -> Void)?
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let humanHandRequest = VNDetectHumanHandPoseRequest(completionHandler: detectedHandPose)
        humanHandRequest.maximumHandCount = 2
        do {
            try sequenceHandler.perform(
                [humanHandRequest],
                on: sampleBuffer,
                orientation: .right)
            self.onFrameUpdate?()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func detectedHandPose(request: VNRequest, error: Error?) {
        guard let handPoseResults = request.results as? [VNHumanHandPoseObservation] else { return }
        guard let firstHandObservation = handPoseResults.first else { return }
        
        DispatchQueue.main.async {
            self.handLandmarksA = [:]
            self.handLandmarksB = [:]
            for handObservation in handPoseResults {
                guard let landmarks = try? handObservation.recognizedPoints(.all) else { continue }
                let handLandmarks = Dictionary(uniqueKeysWithValues: landmarks.filter {
                    jointName, recognizedPoint in
                    return recognizedPoint.confidence > self.confidenceThreshold
                })
                
                if self.handLandmarksA.isEmpty {
                    self.handLandmarksA = handLandmarks
                } else {
                    self.handLandmarksB = handLandmarks
                }
            }
        }
    }
}
