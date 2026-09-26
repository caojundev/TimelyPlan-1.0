//
//  CountdownBackgroundView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

final class CountdownBackgroundView: UIView {
    
    // MARK: - 样式枚举
    enum BackgroundStyle: Int, CaseIterable {
        case diagonalLight    // 斜向流体光带
        case radialGlow       // 径向圆形光晕
        case frostedRects     // 错落磨砂矩形
        case bezierFluid      // 贝塞尔曲面流体
        case bezierBeam       // 贝塞尔曲线光束
    }
    
    // MARK: - 配置
    struct Config {
        /// 基础渐变亮度比例（相对主色亮度，由深到浅）
        static let gradientBrightnessRatios: [CGFloat] = [0.18, 0.40, 0.70, 1.00]
        /// 基础渐变阶梯位置
        static let gradientLocations: [NSNumber] = [0.0, 0.35, 0.70, 1.00]
        /// 光束颜色与白色的混合比例
        static let lightBeamWhiteMixRatio: CGFloat = 0.45
        /// 光束颜色透明度
        static let lightBeamColorAlpha: CGFloat = 0.25
        /// 光束层透明度
        static let lightBeamOpacity: Float = 0.55
        /// 光束宽度
        static let lightBeamLineWidth: CGFloat = 180.0
    }
    
    // MARK: - 公共属性
    /// 主色调：所有渐变、图案颜色将基于此色动态计算同色系层次
    var mainColor: UIColor = .systemPurple {
        didSet { updateColorScheme() }
    }
    
    /// 当前背景样式，切换自动重绘
    var style: BackgroundStyle = .diagonalLight {
        didSet { applyStyle() }
    }
    
    // MARK: - 私有图层
    private let baseGradient = CAGradientLayer()
    private let patternContainer = CALayer()
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseLayers()
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBaseLayers()
        applyStyle()
    }
    
    // MARK: - 尺寸更新时自动重绘
    override func layoutSubviews() {
        super.layoutSubviews()
        baseGradient.frame = bounds
        patternContainer.frame = bounds
        applyStyle()
    }
}

// MARK: - 基础配置与颜色计算
private extension CountdownBackgroundView {
    
    func setupBaseLayers() {
        // 基础纵向渐变层
        baseGradient.startPoint = CGPoint(x: 0.5, y: 0)
        baseGradient.endPoint = CGPoint(x: 0.5, y: 1)
        baseGradient.locations = Config.gradientLocations
        layer.addSublayer(baseGradient)
        
        // 图案容器层
        patternContainer.opacity = 0.8
        layer.addSublayer(patternContainer)
        
        updateColorScheme()
    }
    
    /// 基于主色生成指定亮度、饱和度、透明度的同色系颜色
    func adjustedColor(
        brightness: CGFloat? = nil,
        saturation: CGFloat? = nil,
        alpha: CGFloat = 1
    ) -> UIColor {
        var hue: CGFloat = 0
        var baseSaturation: CGFloat = 0
        var baseBrightness: CGFloat = 0
        var baseAlpha: CGFloat = 0
        
        guard mainColor.getHue(&hue, saturation: &baseSaturation, brightness: &baseBrightness, alpha: &baseAlpha) else {
            return mainColor.withAlphaComponent(alpha)
        }
        
        let finalSaturation = saturation ?? baseSaturation
        let finalBrightness = brightness ?? baseBrightness
        
        return UIColor(
            hue: hue,
            saturation: finalSaturation,
            brightness: finalBrightness,
            alpha: alpha
        )
    }
    
    /// 基于主色亮度按比例缩放的同色系颜色（用于由深到浅的过渡）
    /// - Note: 亮度以主色的 HSB 亮度为基准乘以倍率并截断到 1.0，而非指定绝对亮度，
    ///         避免生成的颜色整体过暗
    func scaledColor(brightnessRatio: CGFloat, alpha: CGFloat = 1) -> UIColor {
        var hue: CGFloat = 0
        var baseSaturation: CGFloat = 0
        var baseBrightness: CGFloat = 0
        var baseAlpha: CGFloat = 0
        
        guard mainColor.getHue(&hue, saturation: &baseSaturation, brightness: &baseBrightness, alpha: &baseAlpha) else {
            return mainColor.withAlphaComponent(alpha)
        }
        
        return UIColor(hue: hue,
                       saturation: baseSaturation,
                       brightness: min(1.0, baseBrightness * brightnessRatio),
                       alpha: alpha)
    }
    
    /// 主色与白色按比例混合（ratio 为 0 时返回主色，为 1 时返回白色）
    func mixedWithWhite(ratio: CGFloat, alpha: CGFloat = 1) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var baseAlpha: CGFloat = 0
        
        guard mainColor.getRed(&red, green: &green, blue: &blue, alpha: &baseAlpha) else {
            return mainColor.withAlphaComponent(alpha)
        }
        
        let ratio = min(max(0.0, ratio), 1.0)
        return UIColor(red: red + (1.0 - red) * ratio,
                       green: green + (1.0 - green) * ratio,
                       blue: blue + (1.0 - blue) * ratio,
                       alpha: alpha)
    }
    
    /// 更新整体配色方案
    func updateColorScheme() {
        // 基础背景：以主色亮度为基准，按比例由深 → 浅过渡（与旧实现一致）
        baseGradient.colors = Config.gradientBrightnessRatios.map {
            scaledColor(brightnessRatio: $0).cgColor
        }
        applyStyle()
    }
    
    /// 清空当前图案
    func clearPattern() {
        patternContainer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
}

// MARK: - 五种样式实现
private extension CountdownBackgroundView {
    
    func applyStyle() {
        clearPattern()
        switch style {
        case .diagonalLight: applyDiagonalLight()
        case .radialGlow:    applyRadialGlow()
        case .frostedRects:  applyFrostedRects()
        case .bezierFluid:   applyBezierFluid()
        case .bezierBeam:    applyBezierBeam()
        }
    }
    
    // MARK: 1. 斜向流体光带
    func applyDiagonalLight() {
        // 主光带：左下 → 右上 亮主色渐变
        let mainBand = CAGradientLayer()
        mainBand.colors = [
            adjustedColor(brightness: 0.8, alpha: 0.5).cgColor,
            adjustedColor(brightness: 0.6, alpha: 0.3).cgColor,
            UIColor.clear.cgColor
        ]
        mainBand.locations = [0, 0.6, 1]
        mainBand.startPoint = CGPoint(x: 0, y: 1)
        mainBand.endPoint = CGPoint(x: 1, y: 0)
        mainBand.frame = CGRect(
            x: -bounds.width * 0.25,
            y: bounds.height * 0.1,
            width: bounds.width * 1.1,
            height: bounds.height * 0.6
        )
        
        // 副光带：辅助色偏移
        let subBand = CAGradientLayer()
        subBand.colors = [
            adjustedColor(brightness: 0.75, saturation: 0.9, alpha: 0.22).cgColor,
            UIColor.clear.cgColor
        ]
        subBand.startPoint = CGPoint(x: 0.2, y: 1)
        subBand.endPoint = CGPoint(x: 0.8, y: 0)
        subBand.frame = CGRect(
            x: bounds.width * 0.1,
            y: bounds.height * 0.35,
            width: bounds.width * 0.95,
            height: bounds.height * 0.4
        )
        
        patternContainer.addSublayer(mainBand)
        patternContainer.addSublayer(subBand)
    }
    
    // MARK: 2. 径向圆形光晕
    func applyRadialGlow() {
        // 中心主光晕
        let centerGlow = CAGradientLayer()
        centerGlow.type = .radial
        centerGlow.colors = [
            adjustedColor(brightness: 0.85, alpha: 0.4).cgColor,
            adjustedColor(brightness: 0.5, alpha: 0.2).cgColor,
            UIColor.clear.cgColor
        ]
        centerGlow.locations = [0, 0.5, 1]
        centerGlow.startPoint = CGPoint(x: 0.5, y: 0.45)
        centerGlow.endPoint = CGPoint(x: 1, y: 1)
        centerGlow.frame = bounds
        
        // 底部暗部压边，增强层次感
        let bottomGlow = CAGradientLayer()
        bottomGlow.type = .radial
        bottomGlow.colors = [
            UIColor.clear.cgColor,
            adjustedColor(brightness: 0.08, alpha: 0.5).cgColor
        ]
        bottomGlow.startPoint = CGPoint(x: 0.5, y: 1.2)
        bottomGlow.endPoint = CGPoint(x: 0, y: 0)
        bottomGlow.frame = bounds
        
        patternContainer.addSublayer(centerGlow)
        patternContainer.addSublayer(bottomGlow)
    }
    
    // MARK: 3. 错落磨砂矩形
    func applyFrostedRects() {
        let configs: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, brightness: CGFloat, alpha: CGFloat)] = [
            (0.1, 0.15, 0.35, 0.25, 0.6, 0.13),
            (0.55, 0.1, 0.3, 0.3, 0.7, 0.12),
            (0.05, 0.5, 0.4, 0.3, 0.5, 0.1),
            (0.6, 0.55, 0.35, 0.28, 0.65, 0.14)
        ]
        
        for config in configs {
            let rect = CALayer()
            rect.backgroundColor = adjustedColor(
                brightness: config.brightness,
                alpha: config.alpha
            ).cgColor
            rect.cornerRadius = 24
            rect.borderWidth = 0.5
            rect.borderColor = adjustedColor(brightness: 0.8, alpha: 0.2).cgColor
            rect.frame = CGRect(
                x: bounds.width * config.x,
                y: bounds.height * config.y,
                width: bounds.width * config.w,
                height: bounds.height * config.h
            )
            patternContainer.addSublayer(rect)
        }
    }
    
    // MARK: 4. 贝塞尔曲面流体
    func applyBezierFluid() {
        // 下层大曲面
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: 0, y: bounds.height * 0.7))
        path1.addCurve(
            to: CGPoint(x: bounds.width, y: bounds.height * 0.6),
            controlPoint1: CGPoint(x: bounds.width * 0.3, y: bounds.height * 0.5),
            controlPoint2: CGPoint(x: bounds.width * 0.7, y: bounds.height * 0.8)
        )
        path1.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        path1.addLine(to: CGPoint(x: 0, y: bounds.height))
        path1.close()
        
        let mask1 = CAShapeLayer()
        mask1.path = path1.cgPath
        
        let gradient1 = CAGradientLayer()
        gradient1.colors = [
            adjustedColor(brightness: 0.6, alpha: 0.5).cgColor,
            adjustedColor(brightness: 0.4, alpha: 0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradient1.locations = [0, 0.6, 1]
        gradient1.startPoint = CGPoint(x: 0.5, y: 0)
        gradient1.endPoint = CGPoint(x: 0.5, y: 1)
        gradient1.frame = bounds
        gradient1.mask = mask1
        
        // 上层反向小曲面
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: 0, y: bounds.height * 0.3))
        path2.addCurve(
            to: CGPoint(x: bounds.width, y: bounds.height * 0.2),
            controlPoint1: CGPoint(x: bounds.width * 0.4, y: bounds.height * 0.4),
            controlPoint2: CGPoint(x: bounds.width * 0.6, y: bounds.height * 0.1)
        )
        path2.addLine(to: CGPoint(x: bounds.width, y: 0))
        path2.addLine(to: CGPoint(x: 0, y: 0))
        path2.close()
        
        let mask2 = CAShapeLayer()
        mask2.path = path2.cgPath
        
        let gradient2 = CAGradientLayer()
        gradient2.colors = [
            adjustedColor(brightness: 0.7, alpha: 0.35).cgColor,
            UIColor.clear.cgColor
        ]
        gradient2.startPoint = CGPoint(x: 0.5, y: 1)
        gradient2.endPoint = CGPoint(x: 0.5, y: 0)
        gradient2.frame = bounds
        gradient2.mask = mask2
        
        patternContainer.addSublayer(gradient1)
        patternContainer.addSublayer(gradient2)
    }
    
    // MARK: 5. 贝塞尔曲线光束
    func applyBezierBeam() {
        // 光束路径：一条自上而下穿过屏幕的三次贝塞尔曲线（随尺寸变化）
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width * 0.2, y: 0.0))
        path.addCurve(to: CGPoint(x: bounds.width * 0.8, y: bounds.height),
                      controlPoint1: CGPoint(x: bounds.width * 0.6, y: bounds.height * 0.3),
                      controlPoint2: CGPoint(x: bounds.width * 0.35, y: bounds.height * 0.7))
        
        // 与白色混合后以较低透明度描边，形成柔和光线
        let beam = CAShapeLayer()
        beam.path = path.cgPath
        beam.fillColor = nil
        beam.strokeColor = mixedWithWhite(ratio: Config.lightBeamWhiteMixRatio,
                                          alpha: Config.lightBeamColorAlpha).cgColor
        beam.lineWidth = Config.lightBeamLineWidth
        beam.lineCap = .round
        beam.opacity = Config.lightBeamOpacity
        
        patternContainer.addSublayer(beam)
    }

}

/*
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
*/
