//
//  StickFigureView.swift
//  MirrorMe
//
//  Created by Sam Hodak
//

import SwiftUI
import Vision

struct StickFigureView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    
    var body: some View {
        ZStack {
            if !poseEstimator.bodyParts.isEmpty {
                // Right arm
                drawLimb(joints: [.rightWrist, .rightElbow, .rightShoulder, .neck], color: .green)
                // Left arm
                drawLimb(joints: [.leftWrist, .leftElbow, .leftShoulder, .neck], color: .blue)
                // Root to nose
                drawLimb(joints: [.root, .neck, .nose], color: .red)
            }
            if !poseEstimator.handLandmarksA.isEmpty {
                drawHand(landmarks: poseEstimator.handLandmarksA, color: .orange)
            }
            if !poseEstimator.handLandmarksB.isEmpty {
                drawHand(landmarks: poseEstimator.handLandmarksB, color: .red)
            }

        }
    }
    
    private func drawLimb(joints: [VNHumanBodyPoseObservation.JointName], color: Color) -> some View {
        let points = pointsForBody(joints: joints)
        return Stick(points: points, size: size)
            .stroke(lineWidth: 5.0)
            .fill(color)
    }
    
    // Returns available CGPoints, if any, for a given set of joints
    private func pointsForBody(joints: [VNHumanBodyPoseObservation.JointName]) -> [CGPoint] {
        var points = [CGPoint]()
        for joint in joints {
            if let point = poseEstimator.detectedJoints[joint]?.location {
                points.append(point)
            }
        }
        return points
    }
    
    // For hand landmarks
    private func drawHand(landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint], color: Color) -> some View {
        let points = pointsForHand(landmarks: landmarks)
        return Dot(points: points, size: size, dotRadius: 0.02)
            .fill(color)
    }

    private func pointsForHand(landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> [CGPoint] {
        var points = [CGPoint]()
        for (_, point) in landmarks {
            points.append(point.location)
        }
        return points
    }
}
