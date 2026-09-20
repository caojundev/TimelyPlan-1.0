//
//  CountdownBackgroundView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

class CountdownBackgroundView: UIView {

    // MARK: - 渐变层
    private let gradientLayer = CAGradientLayer()

    // MARK: - 粒子容器
    private let particleEmitter = CAEmitterLayer()

    // MARK: - 光线层
    private let lightBeamLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        setupLightBeam()
        setupParticles()
        startAnimations()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
        setupLightBeam()
        setupParticles()
        startAnimations()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
        lightBeamLayer.frame = bounds
        particleEmitter.frame = bounds
    }
}

// MARK: - 背景渐变
extension CountdownBackgroundView {

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.06, green: 0.04, blue: 0.12, alpha: 1.0).cgColor,
            UIColor(red: 0.12, green: 0.08, blue: 0.28, alpha: 1.0).cgColor,
            UIColor(red: 0.24, green: 0.12, blue: 0.48, alpha: 1.0).cgColor,
            UIColor(red: 0.42, green: 0.22, blue: 0.68, alpha: 1.0).cgColor
        ]

        gradientLayer.locations = [0.0, 0.35, 0.7, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - 光线效果
extension CountdownBackgroundView {

    private func setupLightBeam() {
        let beamPath = UIBezierPath()
        beamPath.move(to: CGPoint(x: bounds.width * 0.2, y: 0))
        beamPath.addCurve(
            to: CGPoint(x: bounds.width * 0.8, y: bounds.height),
            controlPoint1: CGPoint(x: bounds.width * 0.6, y: bounds.height * 0.3),
            controlPoint2: CGPoint(x: bounds.width * 0.35, y: bounds.height * 0.7)
        )

        lightBeamLayer.path = beamPath.cgPath
        lightBeamLayer.strokeColor = UIColor(red: 0.7, green: 0.5, blue: 1.0, alpha: 0.25).cgColor
        lightBeamLayer.lineWidth = 180
        lightBeamLayer.lineCap = .round
        lightBeamLayer.fillColor = nil
        lightBeamLayer.opacity = 0.55

        layer.insertSublayer(lightBeamLayer, above: gradientLayer)
    }
}

// MARK: - 粒子效果
extension CountdownBackgroundView {

    private func setupParticles() {
        let cell = CAEmitterCell()
        cell.name = "lightParticle"
        cell.birthRate = 2.5
        cell.lifetime = 14.0
        cell.lifetimeRange = 6.0
        cell.velocity = 55
        cell.velocityRange = 40
        cell.emissionLongitude = CGFloat.pi / 2.2
        cell.emissionRange = CGFloat.pi / 3.5
        cell.scale = 0.12
        cell.scaleRange = 0.1
        cell.scaleSpeed = 0.008
        cell.alphaSpeed = 0.015
        cell.color = UIColor(red: 0.85, green: 0.75, blue: 1.0, alpha: 0.6).cgColor
        cell.contents = createParticleImage()

        particleEmitter.emitterPosition = CGPoint(x: bounds.width / 2.0, y: -40)
        particleEmitter.emitterSize = CGSize(width: bounds.width * 0.7, height: 12)
        particleEmitter.emitterMode = .surface
        particleEmitter.renderMode = .backToFront
        particleEmitter.shadowColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.8).cgColor
        particleEmitter.shadowRadius = 12
        particleEmitter.shadowOpacity = 0.35
        particleEmitter.emitterCells = [cell]
        layer.insertSublayer(particleEmitter, above: lightBeamLayer)
    }

    private func createParticleImage() -> UIImage {
        let size = CGSize(width: 22, height: 22)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let glow = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.white.cgColor,
                    UIColor(red: 0.9, green: 0.85, blue: 1.0, alpha: 0.35).cgColor,
                    UIColor(red: 0.7, green: 0.5, blue: 1.0, alpha: 0.0).cgColor
                ] as CFArray,
                locations: [0, 0.4, 1]
            )

            context.cgContext.drawRadialGradient(
                glow!,
                startCenter: center,
                startRadius: 2,
                endCenter: center,
                endRadius: 11,
                options: .drawsAfterEndLocation
            )
        }
    }
}

// MARK: - 动画启动
extension CountdownBackgroundView {

    private func startAnimations() {
        startGradientShift()
        startLightBeamMove()
        startParticleDrift()
    }

    private func startGradientShift() {
        let colorShift = CABasicAnimation(keyPath: "colors")
        colorShift.duration = 14
        colorShift.repeatCount = .infinity
        colorShift.autoreverses = true
        colorShift.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        colorShift.fromValue = [
            UIColor(red: 0.06, green: 0.04, blue: 0.12, alpha: 1.0).cgColor,
            UIColor(red: 0.12, green: 0.08, blue: 0.28, alpha: 1.0).cgColor,
            UIColor(red: 0.24, green: 0.12, blue: 0.48, alpha: 1.0).cgColor,
            UIColor(red: 0.42, green: 0.22, blue: 0.68, alpha: 1.0).cgColor
        ]

        colorShift.toValue = [
            UIColor(red: 0.08, green: 0.06, blue: 0.22, alpha: 1.0).cgColor,
            UIColor(red: 0.16, green: 0.1, blue: 0.38, alpha: 1.0).cgColor,
            UIColor(red: 0.32, green: 0.18, blue: 0.58, alpha: 1.0).cgColor,
            UIColor(red: 0.52, green: 0.32, blue: 0.78, alpha: 1.0).cgColor
        ]

        gradientLayer.add(colorShift, forKey: "gradientShift")
    }

    private func startLightBeamMove() {
        let beamMove = CABasicAnimation(keyPath: "opacity")
        beamMove.duration = 5
        beamMove.fromValue = 0.4
        beamMove.toValue = 0.8
        beamMove.repeatCount = .infinity
        beamMove.autoreverses = true
        beamMove.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        lightBeamLayer.add(beamMove, forKey: "lightBeamPulse")
    }

    private func startParticleDrift() {
        let drift = CABasicAnimation(keyPath: "emitterPosition.x")
        drift.duration = 9
        drift.fromValue = bounds.width * 0.25
        drift.toValue = bounds.width * 0.75
        drift.repeatCount = .infinity
        drift.autoreverses = true
        drift.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        particleEmitter.add(drift, forKey: "particleDrift")
    }
}
