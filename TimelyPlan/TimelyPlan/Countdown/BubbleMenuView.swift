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
    
    // MARK: - 配置
    private let buttonSize: CGFloat = 56.0
    private let menuItemHeight: CGFloat = 50.0
    private let menuWidth: CGFloat = 180.0
    private let menuSpacing: CGFloat = 20.0
    private let menuRightPadding: CGFloat = 24.0   // 菜单距屏幕右边距
    private let bubblePadding: CGFloat = 24.0      // 泡泡边缘超出菜单的留白
    private let bubbleColor = UIColor(red: 0.55, green: 0.45, blue: 0.95, alpha: 1.0)
    
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
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(closeMenu), for: .touchUpInside)
        return btn
    }()
    
    private var menuItemViews: [UIView] = []
    var onDismiss: (() -> Void)?
    
    // MARK: - Init
    init(frame: CGRect, triggerButtonFrame: CGRect, menuItems: [BubbleMenuItem]) {
        self.triggerButtonFrame = triggerButtonFrame
        self.menuItems = menuItems
        super.init(frame: frame)
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
        addSubview(closeButton)
        for (index, item) in menuItems.enumerated() {
            let itemView = createMenuItemView(item: item, tag: index)
            addSubview(itemView)
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
        
        bubbleCenter = CGPoint(x: triggerButtonFrame.midX, y: triggerButtonFrame.midY)
        
        if bubbleBackgroundView.bounds.size == .zero {
            bubbleBackgroundView.bounds = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
            bubbleBackgroundView.center = bubbleCenter
            bubbleBackgroundView.layer.cornerRadius = buttonSize / 2
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
    func show(in parentView: UIView) {
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
        
        // 确保初始状态是小圆
        bubbleBackgroundView.bounds = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        bubbleBackgroundView.center = bubbleCenter
        bubbleBackgroundView.layer.cornerRadius = buttonSize / 2
        
        // 动画到大圆
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut) {
            self.bubbleBackgroundView.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
            self.bubbleBackgroundView.center = self.bubbleCenter
            self.bubbleBackgroundView.layer.cornerRadius = radius
        }
        
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

        // 泡泡收缩
        UIView.animate(withDuration: 0.35, delay: 0.1, options: .curveEaseIn) {
            self.bubbleBackgroundView.bounds = CGRect(x: 0, y: 0, width: self.buttonSize, height: self.buttonSize)
            self.bubbleBackgroundView.center = self.bubbleCenter
            self.bubbleBackgroundView.layer.cornerRadius = self.buttonSize / 2
        }
        
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
