//
//  CountdownBackgroundView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

/// 倒数日详情背景视图
/// 根据主题色（事项颜色）静态渲染渐变与光线
class CountdownBackgroundView: UIView {
    
    struct Config {
        /// 默认主题色（紫色）
        static let defaultThemeColor = Color(0x6B38AD)
        /// 渐变阶梯亮度比例（相对于主题色亮度，由深到浅）
        static let gradientBrightnessRatios: [CGFloat] = [0.18, 0.40, 0.70, 1.00]
        /// 渐变阶梯位置
        static let gradientLocations: [NSNumber] = [0.0, 0.35, 0.70, 1.00]
        /// 光线颜色与白色的混合比例
        static let lightBeamWhiteMixRatio: CGFloat = 0.45
        /// 光线颜色透明度
        static let lightBeamColorAlpha: CGFloat = 0.25
        /// 光线层透明度
        static let lightBeamOpacity: Float = 0.55
        /// 光线宽度
        static let lightBeamLineWidth: CGFloat = 180.0
    }
    
    // MARK: - 主题色
    /// 主题色（决定渐变与光线颜色）
    private(set) var themeColor: UIColor = Config.defaultThemeColor
    
    /// 应用主题色
    /// - Note: 初始化器中赋值不会触发属性观察器，颜色变更统一由此方法处理
    func apply(themeColor: UIColor) {
        self.themeColor = themeColor
        updateThemeColors()
    }
    
    // MARK: - 渐变层
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - 光线层
    private let lightBeamLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    /// 以指定主题色创建背景视图
    /// - Parameters:
    ///   - frame: 视图尺寸
    ///   - themeColor: 主题色（一般取倒数日事项颜色）
    convenience init(frame: CGRect, themeColor: UIColor) {
        self.init(frame: frame)
        apply(themeColor: themeColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        lightBeamLayer.frame = bounds
        /// 光束路径依赖当前尺寸
        updateLightBeamPath()
    }
    
    // MARK: - 图层
    private func setupLayers() {
        clipsToBounds = true
        setupGradient()
        setupLightBeam()
    }
    
    // MARK: - 主题色
    /// 依据主题色更新渐变与光线颜色
    private func updateThemeColors() {
        updateGradientColors()
        updateLightBeamColor()
    }
    
    // MARK: - 渐变
    private func setupGradient() {
        gradientLayer.locations = Config.gradientLocations
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        updateGradientColors()
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// 依据主题色更新渐变颜色
    private func updateGradientColors() {
        let brightness = themeColor.brightnessValue
        gradientLayer.colors = Config.gradientBrightnessRatios.map { ratio in
            return themeColor.withBrightness(min(1.0, brightness * ratio)).cgColor
        }
    }
    
    // MARK: - 光线
    private func setupLightBeam() {
        lightBeamLayer.lineWidth = Config.lightBeamLineWidth
        lightBeamLayer.lineCap = .round
        lightBeamLayer.fillColor = nil
        lightBeamLayer.opacity = Config.lightBeamOpacity
        updateLightBeamPath()
        updateLightBeamColor()
        
        layer.insertSublayer(lightBeamLayer, above: gradientLayer)
    }
    
    /// 更新光束路径（依赖当前尺寸）
    private func updateLightBeamPath() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width * 0.2, y: 0.0))
        path.addCurve(to: CGPoint(x: bounds.width * 0.8, y: bounds.height),
                      controlPoint1: CGPoint(x: bounds.width * 0.6, y: bounds.height * 0.3),
                      controlPoint2: CGPoint(x: bounds.width * 0.35, y: bounds.height * 0.7))
        
        lightBeamLayer.path = path.cgPath
    }
    
    /// 依据主题色更新光束颜色
    private func updateLightBeamColor() {
        lightBeamLayer.strokeColor = themeColor.mixed(with: .white,
                                                      ratio: Config.lightBeamWhiteMixRatio)
            .withAlphaComponent(Config.lightBeamColorAlpha).cgColor
    }
}

// MARK: - 颜色计算
private extension UIColor {
    
    /// 亮度（HSB 的 brightness）
    var brightnessValue: CGFloat {
        var brightness: CGFloat = 0.0
        getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness
    }
    
    /// 与指定颜色按比例混合（ratio 为 0 时返回自身，为 1 时返回目标色）
    func mixed(with color: UIColor, ratio: CGFloat) -> UIColor {
        let ratio = min(max(0.0, ratio), 1.0)
        
        var red1: CGFloat = 0.0, green1: CGFloat = 0.0, blue1: CGFloat = 0.0, alpha1: CGFloat = 0.0
        var red2: CGFloat = 0.0, green2: CGFloat = 0.0, blue2: CGFloat = 0.0, alpha2: CGFloat = 0.0
        getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return UIColor(red: red1 + (red2 - red1) * ratio,
                       green: green1 + (green2 - green1) * ratio,
                       blue: blue1 + (blue2 - blue1) * ratio,
                       alpha: alpha1 + (alpha2 - alpha1) * ratio)
    }
}
