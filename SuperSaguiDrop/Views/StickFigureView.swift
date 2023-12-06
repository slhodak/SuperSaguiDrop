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
            if !poseEstimator.handLandmarksA.isEmpty {
                drawHand(landmarks: poseEstimator.handLandmarksA, color: .orange)
            }
            if !poseEstimator.handLandmarksB.isEmpty {
                drawHand(landmarks: poseEstimator.handLandmarksB, color: .red)
            }

        }
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
