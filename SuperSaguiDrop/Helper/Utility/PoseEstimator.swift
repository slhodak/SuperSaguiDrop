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

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject{
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]()
    @Published var handLandmarksA = [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]()
    @Published var handLandmarksB = [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]()
    
    let confidenceThreshold: Float = 0.5
    
    var detectedJoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] {
        return Dictionary(uniqueKeysWithValues: bodyParts.filter { jointName, recognizedPoint in
            return recognizedPoint.confidence > confidenceThreshold
        })
    }
    
    let sequenceHandler = VNSequenceRequestHandler()
    
    var onFrameUpdate: (() -> Void)?
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectedBodyPose)
        let humanHandRequest = VNDetectHumanHandPoseRequest(completionHandler: detectedHandPose)
        humanHandRequest.maximumHandCount = 2
        do {
            try sequenceHandler.perform(
                [
//                    humanBodyRequest,
                    humanHandRequest
                ],
                on: sampleBuffer,
                orientation: .right)
            self.onFrameUpdate?()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func detectedBodyPose(request: VNRequest, error: Error?) {
        guard let bodyPoseResults = request.results as? [VNHumanBodyPoseObservation] else { return }
        guard let bodyParts = try? bodyPoseResults.first?.recognizedPoints(.all) else { return }
        
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
        }
    }
    
    func detectedHandPose(request: VNRequest, error: Error?) {
        guard let handPoseResults = request.results as? [VNHumanHandPoseObservation] else { return }
        guard let firstHandObservation = handPoseResults.first else { return }
        guard let landmarks = try? firstHandObservation.recognizedPoints(.all) else { return }
        
        DispatchQueue.main.async {
            self.handLandmarksA = [:]
            self.handLandmarksB = [:]
            for handObservation in handPoseResults {
                guard let landmarks = try? handObservation.recognizedPoints(.all) else { continue }
                
                if self.handLandmarksA.isEmpty {
                    self.handLandmarksA = Dictionary(uniqueKeysWithValues: landmarks.filter { jointName, recognizedPoint in
                        return recognizedPoint.confidence > self.confidenceThreshold
                    })
                } else {
                    self.handLandmarksB = Dictionary(uniqueKeysWithValues: landmarks.filter { jointName, recognizedPoint in
                        return recognizedPoint.confidence > self.confidenceThreshold
                    })
                }
            }
        }
    }
}
