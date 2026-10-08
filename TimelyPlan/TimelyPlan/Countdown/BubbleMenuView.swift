//
//  BubbleMenuView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/13.
//

import Foundation
import UIKit

struct BubbleMenuItem {
    let title: String
    let icon: String
}

class BubbleMenuView: UIView {
    
    var onSelectMenuItem: ((BubbleMenuItem) -> Void)?
    
    var bubbleColor: UIColor = .primary {
        didSet {
            bubbleBackgroundView.backgroundColor = bubbleColor
        }
    }
    
    // MARK: - 配置
    private let buttonSize: CGFloat = 56.0
    private let menuItemHeight: CGFloat = 50.0
    private let menuWidth: CGFloat = 180.0
    private let menuSpacing: CGFloat = 20.0
    private let menuRightPadding: CGFloat = 24.0   // 菜单距屏幕右边距
    private let bubblePadding: CGFloat = 24.0      // 泡泡边缘超出菜单的留白
    
    private let menuItems: [BubbleMenuItem]
    private var triggerButtonFrame: CGRect = .zero
    private var bubbleCenter: CGPoint = .zero
    
    // MARK: - UI
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()
    
    private lazy var bubbleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = bubbleColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var closeButton: TPImageButton = {
        let btn = TPImageButton()
        btn.scaleMaxLength = 0.0
        btn.normalImage = resGetImage("xmark_32")
        btn.normalImageColor = .white
        btn.addTarget(self, action: #selector(closeMenu), for: .touchUpInside)
        return btn
    }()
    
    private var menuItemViews: [UIView] = []
    var onDismiss: (() -> Void)?
    
    /// 菜单内容容器：所有菜单项都添加在这里，
    /// 通过圆形遮罩跟随 bubbleBackgroundView 一起扩散 / 收缩
    private lazy var menuContentView: BubbleMenuContentView = {
        let view = BubbleMenuContentView()
        view.backgroundColor = .clear
        return view
    }()
    
    /// 菜单内容的圆形遮罩（圆心与半径始终与 bubbleBackgroundView 保持一致）
    private let menuContentMaskLayer = CAShapeLayer()
    
    /// 泡泡当前半径（动画进行中时取呈现层的半径）
    private var currentBubbleRadius: CGFloat {
        let layer = bubbleBackgroundView.layer.presentation() ?? bubbleBackgroundView.layer
        return layer.bounds.width / 2.0
    }
    
    // MARK: - Init
    let sourceView: UIView
    
    let containerView: UIView
    
    init(menuItems: [BubbleMenuItem], containerView: UIView, sourceView: UIView) {
        self.menuItems = menuItems
        self.containerView = containerView
        self.sourceView = sourceView
        super.init(frame: containerView.bounds)
        self.triggerButtonFrame = sourceView.convert(sourceView.bounds, toViewOrWindow: containerView)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(overlayView)
        addSubview(bubbleBackgroundView)
        addSubview(menuContentView)
        menuContentMaskLayer.fillColor = UIColor.black.cgColor
        menuContentView.layer.mask = menuContentMaskLayer
        addSubview(closeButton)
        for (index, item) in menuItems.enumerated() {
            let itemView = createMenuItemView(item: item, tag: index)
            menuContentView.addSubview(itemView)
            menuItemViews.append(itemView)
            itemView.alpha = 0
            itemView.isHidden = true
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
        overlayView.addGestureRecognizer(tap)
        
        layoutSubviewsManually()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsManually()
    }
    
    private func layoutSubviewsManually() {
        overlayView.frame = bounds
        closeButton.frame = triggerButtonFrame
        menuContentView.frame = bounds
        menuContentMaskLayer.frame = menuContentView.bounds
        
        bubbleCenter = CGPoint(x: triggerButtonFrame.midX, y: triggerButtonFrame.midY)
        
        if bubbleBackgroundView.bounds.size == .zero {
            bubbleBackgroundView.bounds = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
            bubbleBackgroundView.center = bubbleCenter
            bubbleBackgroundView.layer.cornerRadius = buttonSize / 2
            
            /// 遮罩初始为与触发按钮同大的圆
            setMenuContentMask(radius: buttonSize / 2)
        }
        
        // 菜单项布局：从触发按钮上方开始向上排列
        let menuRightX = bounds.width - menuRightPadding
        var currentY = triggerButtonFrame.minY - menuSpacing
        
        for itemView in menuItemViews.reversed() {
            currentY -= menuItemHeight
            let itemX = menuRightX - menuWidth
            itemView.frame = CGRect(x: itemX, y: currentY, width: menuWidth, height: menuItemHeight)
            currentY -= menuSpacing
        }
    }
    
    // MARK: - 半径计算（独立函数）
    /// 根据菜单项数量计算泡泡圆环扩散所需的最大半径
    /// - 圆心固定为触发按钮的中心（bubbleCenter）
    /// - 菜单区域从触发按钮上方依次向上排列
    /// - 返回能刚好包住所有菜单项的半径（加上 padding）
    private func calculateBubbleRadius() -> CGFloat {
        // 1. 计算菜单项总高度
        let count = menuItems.count
        guard count > 0 else {
            return buttonSize / 2 + bubblePadding
        }
        let totalMenuHeight = CGFloat(count) * menuItemHeight + CGFloat(count - 1) * menuSpacing
        
        // 2. 菜单区域边界（相对本视图坐标）
        let menuRightX = bounds.width - menuRightPadding
        let menuLeftX = menuRightX - menuWidth
        let menuTopY = triggerButtonFrame.minY - menuSpacing - totalMenuHeight
        
        // 3. 距离圆心最远的点：由于圆心在右下角，最远点一定是菜单区域左上角
        let farthestPoint = CGPoint(x: menuLeftX, y: menuTopY)
        
        // 4. 计算距离
        let dx = farthestPoint.x - bubbleCenter.x
        let dy = farthestPoint.y - bubbleCenter.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // 5. 加 padding，并保证最小半径不小于按钮半径 + padding
        let radius = distance + bubblePadding
        return max(radius, buttonSize / 2 + bubblePadding)
    }
    
    // MARK: - 泡泡与菜单内容遮罩（独立函数）
    /// 以 bubbleCenter 为圆心、指定半径的圆形路径（相对 menuContentView 坐标）
    private func menuContentMaskPath(radius: CGFloat) -> CGPath {
        let rect = CGRect(x: bubbleCenter.x - radius,
                          y: bubbleCenter.y - radius,
                          width: radius * 2.0,
                          height: radius * 2.0)
        return UIBezierPath(ovalIn: rect).cgPath
    }
    
    /// 直接设置遮罩半径（不带动画）
    private func setMenuContentMask(radius: CGFloat) {
        menuContentMaskLayer.removeAllAnimations()
        menuContentMaskLayer.path = menuContentMaskPath(radius: radius)
    }
    
    /// 生成同步动画：泡泡与遮罩各自取一份，参数完全相同，因此逐帧同步
    /// - Parameters:
    ///   - layer: 动画所属图层（用于把绝对时间换算成图层本地时间，保证不同图层的起点一致）
    ///   - keyPath / fromValue / toValue: 属性与其起止值
    ///   - duration / delay / timingFunction: 时长、延时与曲线（泡泡与遮罩传同一套参数）
    private func makeBubbleSyncAnimation(layer: CALayer,
                                         keyPath: String,
                                         fromValue: Any,
                                         toValue: Any,
                                         duration: CFTimeInterval,
                                         delay: CFTimeInterval,
                                         timingFunction: CAMediaTimingFunction) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) + delay
        animation.fillMode = .backwards
        animation.timingFunction = timingFunction
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    /// 同步驱动「泡泡」与「菜单内容遮罩」
    /// 两者使用同一套动画参数（时长 / 延时 / 曲线完全一致），
    /// 因此泡泡扩散或收缩时，遮罩始终与泡泡逐帧重合，菜单内容不会露在泡泡外面
    /// - Parameters:
    ///   - radius: 目标半径
    ///   - fromRadius: 起始半径
    ///   - duration / delay / timingFunction: 泡泡与遮罩共用的动画参数
    private func syncBubbleAndMask(radius: CGFloat,
                                   fromRadius: CGFloat,
                                   duration: CFTimeInterval,
                                   delay: CFTimeInterval,
                                   timingFunction: CAMediaTimingFunction) {
        let fromBubbleBounds = CGRect(x: 0, y: 0, width: fromRadius * 2.0, height: fromRadius * 2.0)
        let bubbleBounds = CGRect(x: 0, y: 0, width: radius * 2.0, height: radius * 2.0)
        let fromMaskPath = menuContentMaskPath(radius: fromRadius)
        let maskPath = menuContentMaskPath(radius: radius)
        
        /// 先落到最终状态，动画只负责呈现（避免动画结束后回跳）
        bubbleBackgroundView.bounds = bubbleBounds
        bubbleBackgroundView.center = bubbleCenter
        bubbleBackgroundView.layer.cornerRadius = radius
        menuContentMaskLayer.path = maskPath
        
        /// 泡泡：尺寸 + 圆角
        let bubbleLayer = bubbleBackgroundView.layer
        bubbleLayer.add(makeBubbleSyncAnimation(layer: bubbleLayer,
                                                keyPath: "bounds",
                                                fromValue: fromBubbleBounds,
                                                toValue: bubbleBounds,
                                                duration: duration,
                                                delay: delay,
                                                timingFunction: timingFunction),
                        forKey: "bubbleMenu.bounds")
        bubbleLayer.add(makeBubbleSyncAnimation(layer: bubbleLayer,
                                                keyPath: "cornerRadius",
                                                fromValue: fromRadius,
                                                toValue: radius,
                                                duration: duration,
                                                delay: delay,
                                                timingFunction: timingFunction),
                        forKey: "bubbleMenu.cornerRadius")
        
        /// 菜单内容遮罩：圆形路径
        menuContentMaskLayer.add(makeBubbleSyncAnimation(layer: menuContentMaskLayer,
                                                         keyPath: "path",
                                                         fromValue: fromMaskPath,
                                                         toValue: maskPath,
                                                         duration: duration,
                                                         delay: delay,
                                                         timingFunction: timingFunction),
                                 forKey: "bubbleMenu.mask")
    }
    
    private func createMenuItemView(item: BubbleMenuItem, tag: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .right
        
        let iconLabel = UILabel()
        iconLabel.text = item.icon
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.textAlignment = .right
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: menuWidth - 40, height: menuItemHeight)
        iconLabel.frame = CGRect(x: menuWidth - 30, y: 0, width: 30, height: menuItemHeight)
        
        container.addSubview(titleLabel)
        container.addSubview(iconLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(menuItemTapped(_:)))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        container.tag = tag
        
        return container
    }
    
    // MARK: - 显示
    func show() {
        let parentView = containerView
        parentView.addSubview(self)
        self.frame = parentView.bounds
        self.layoutSubviewsManually()
        
        // 1. 遮罩淡入
        overlayView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 1
        }
        
        // 2. 关闭按钮：淡入 + 旋转
        // 关键：旋转必须「结束在 identity 对应的角度」（即 2π 的整数倍），
        // 否则「×」会被转成「+」，看起来就像关闭按钮没显示出来。
        // 这里用 layer 的 transform.rotation.z 做角度插值，
        // 避免 UIView 的 transform 矩阵插值导致中途缩放/角度不连续。
        bringSubviewToFront(closeButton)
        closeButton.layer.removeAllAnimations()
        closeButton.transform = .identity

        let showSpin = CABasicAnimation(keyPath: "transform.rotation.z")
        showSpin.fromValue = -CGFloat.pi / 4.0
        showSpin.toValue = CGFloat.pi / 2.0
        showSpin.duration = 0.45
        showSpin.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        showSpin.isRemovedOnCompletion = false
        closeButton.layer.add(showSpin, forKey: "bubbleMenu.showSpin")

        // 3. 泡泡圆形扩散（半径由 calculateBubbleRadius() 决定）
        let radius = calculateBubbleRadius()
        
        /// 泡泡与菜单内容遮罩使用完全相同的动画同步扩散
        /// 曲线为轻微回弹的 spring 感（结尾约 0.7% 过冲），保证遮罩与泡泡逐帧重合
        syncBubbleAndMask(radius: radius,
                          fromRadius: buttonSize / 2,
                          duration: 0.6,
                          delay: 0,
                          timingFunction: CAMediaTimingFunction(controlPoints: 0.2, 0.1, 0.5, 1.1))
        
        // 4. 菜单项滑入
        for (index, itemView) in menuItemViews.enumerated() {
            itemView.isHidden = false
            itemView.transform = CGAffineTransform(translationX: 60, y: 0)
            itemView.alpha = 0
            
            UIView.animate(withDuration: 0.6,
                           delay: 0.2 + Double(index) * 0.05,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseOut) {
                itemView.transform = .identity
                itemView.alpha = 1
            }
        }
    }
    
    // MARK: - 关闭
    @objc func closeMenu() {
        /// 收缩前的泡泡半径（需在泡泡收缩动画设置 bounds 之前取值，用于菜单内容遮罩）
        let currentRadius = currentBubbleRadius
        
        for (index, itemView) in menuItemViews.enumerated() {
            UIView.animate(withDuration: 0.2, delay: Double(menuItemViews.count - 1 - index) * 0.03, options: .curveEaseIn) {
                itemView.alpha = 0.0
            } completion: { _ in
                itemView.isHidden = true
            }
        }
        
        // 2. 关闭按钮
        let hiddenAngle = CGFloat.pi * 0.75
        let hideSpin = CABasicAnimation(keyPath: "transform.rotation.z")
        hideSpin.fromValue = 0
        hideSpin.toValue = hiddenAngle
        hideSpin.duration = 0.4
        hideSpin.timingFunction = CAMediaTimingFunction(name: .easeIn)
        hideSpin.fillMode = .forwards
        hideSpin.isRemovedOnCompletion = false
        closeButton.layer.add(hideSpin, forKey: "bubbleMenu.hideSpin")

        /// 泡泡与菜单内容遮罩使用完全相同的动画同步收缩
        /// 遮罩与泡泡逐帧重合，因此收缩过程中菜单内容不会露在泡泡外面
        syncBubbleAndMask(radius: buttonSize / 2,
                          fromRadius: currentRadius,
                          duration: 0.35,
                          delay: 0.1,
                          timingFunction: CAMediaTimingFunction(name: .easeIn))
        
        UIView.animate(withDuration: 0.3, delay: 0.15) {
            self.overlayView.alpha = 0
        } completion: { _ in
            self.onDismiss?()
            self.removeFromSuperview()
        }
    }
    
    @objc private func menuItemTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        let menuItem = menuItems[index]
        onSelectMenuItem?(menuItem)
        closeMenu()
    }
}

/// 菜单内容容器
/// 仅菜单项本身响应点击，容器空白区域的点击透传给下层的 overlayView（用于点击空白关闭菜单）
private class BubbleMenuContentView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view === self ? nil : view
    }
}
