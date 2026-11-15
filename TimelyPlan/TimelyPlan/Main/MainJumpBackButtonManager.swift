//
//  MainJumpBackButtonManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/15.
//

import Foundation
import UIKit

/// 工作台返回按钮位置
struct JumpBackButtonPosition: Codable {

    /// 水平吸附位置
    enum HorizontalPosition: Int, Codable {
        case left
        case right
    }

    /// 水平吸附位置
    var horizontal: HorizontalPosition = .left

    /// 竖直相对位置，范围在 0 到 1 之间
    var vertical: CGFloat = 0.5
}

/// 工作台返回按钮管理器，负责按钮的显隐、拖动吸附与位置保存
class MainJumpBackButtonManager {

    /// 是否显示中
    private(set) var isShowing = false

    /// 点击按钮回调
    var clickHandler: (() -> Void)?

    /// 按钮宿主视图
    private lazy var hostView: JumpBackButtonHostView = {
        let view = JumpBackButtonHostView(frame: .zero)
        view.position = AppState.shared.jumpBackButtonPosition
        view.onClick = { [weak self] in
            self?.clickHandler?()
        }
        view.onDragEnd = { position in
            AppState.shared.jumpBackButtonPosition = position
        }
        return view
    }()

    // MARK: - Public Methods
    /// 触摸是否落在按钮上，用于屏蔽侧边栏手势
    func isTouchInsideButton(_ touch: UITouch) -> Bool {
        guard isShowing else {
            return false
        }

        return hostView.containsButtonTouch(touch)
    }

    /// 在指定容器中显示按钮
    func show(in containerView: UIView, animated: Bool = true) {
        guard !isShowing else {
            hostView.setNeedsLayout()
            return
        }

        isShowing = true
        hostView.removeFromSuperview()
        hostView.frame = containerView.bounds
        hostView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(hostView)
        hostView.layoutIfNeeded()

        guard animated else {
            hostView.alpha = 1.0
            return
        }

        hostView.alpha = 0.0
        hostView.playShowTransition()
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseOut) {
            self.hostView.alpha = 1.0
        }
    }

    /// 移除按钮
    func hide(animated: Bool = true) {
        guard isShowing else {
            return
        }

        isShowing = false
        guard animated else {
            hostView.removeFromSuperview()
            return
        }

        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .beginFromCurrentState) {
            self.hostView.alpha = 0.0
        } completion: { _ in
            guard !self.isShowing else {
                return
            }

            self.hostView.removeFromSuperview()
        }
    }
}

/// 返回工作台按钮的宿主视图，负责按钮布局与拖动吸附
private class JumpBackButtonHostView: UIView {

    /// 按钮尺寸
    private let buttonSize = CGSize(width: 30.0, height: 60.0)

    /// 按钮位置
    var position = JumpBackButtonPosition() {
        didSet {
            setNeedsLayout()
        }
    }

    /// 点击按钮回调
    var onClick: (() -> Void)?

    /// 拖动结束回调，用于保存位置
    var onDragEnd: ((JumpBackButtonPosition) -> Void)?

    /// 是否正在拖动
    private var isDragging = false

    /// 吸附在内容区边缘的按钮
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        let image = resGetImage("chevron_left_24")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryLabel
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = buttonSize.width / 2.0
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 6.0
        button.layer.shadowOffset = CGSize(width: 2.0, height: 0.0)
        button.addTarget(self, action: #selector(clickButton(_:)), for: .touchUpInside)
        return button
    }()

    /// 拖动按钮调整位置
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        return recognizer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(button)
        button.addGestureRecognizer(panGestureRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 仅响应按钮上的触摸，其余触摸交给下层视图
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view === self ? nil : view
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isDragging else {
            return
        }

        layoutButton()
    }

    /// 从吸附的边缘外侧滑入
    func playShowTransition() {
        let offset = position.horizontal == .left ? -button.frame.maxX : bounds.width - button.frame.minX
        button.transform = CGAffineTransform(translationX: offset, y: 0.0)
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseOut) {
            self.button.transform = .identity
        }
    }

    // MARK: - 布局
    private var layoutFrame: CGRect {
        return bounds.inset(by: safeAreaInsets)
    }

    private func layoutButton() {
        let frame = layoutFrame
        let originX: CGFloat
        switch position.horizontal {
        case .left:
            originX = frame.minX
        case .right:
            originX = frame.maxX - buttonSize.width
        }

        let minCenterY = frame.minY + buttonSize.height / 2.0
        let maxCenterY = frame.maxY - buttonSize.height / 2.0
        let centerY = minCenterY + (maxCenterY - minCenterY) * position.vertical
        let buttonFrame = CGRect(x: originX,
                                 y: centerY - buttonSize.height / 2.0,
                                 width: buttonSize.width,
                                 height: buttonSize.height)
        if button.frame != buttonFrame {
            button.frame = buttonFrame
        }

        updateButtonCorners()
    }

    /// 贴边时只圆角朝内两个角，脱离边缘时四角皆为圆角
    private func updateButtonCorners() {
        let frame = layoutFrame
        let corners: CACornerMask
        if abs(button.left - frame.minX) < 0.5 {
            corners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        } else if abs(button.right - frame.maxX) < 0.5 {
            corners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        } else {
            corners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                       .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        if button.layer.maskedCorners != corners {
            button.layer.maskedCorners = corners
        }
    }

    // MARK: - 拖动
    @objc private func clickButton(_ button: UIButton) {
        TPImpactFeedback.impactWithLightStyle()
        onClick?()
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            isDragging = true
            button.layer.removeAllAnimations()
            recognizer.setTranslation(.zero, in: self)
        case .changed:
            let translation = recognizer.translation(in: self)
            button.center = CGPoint(x: button.center.x + translation.x,
                                    y: button.center.y + translation.y)
            recognizer.setTranslation(.zero, in: self)
            clampButton()
            updateButtonCorners()
        default:
            isDragging = false
            snapToClosestEdge()
        }
    }

    private func clampButton() {
        let frame = layoutFrame
        button.left = max(frame.minX, button.left)
        button.right = min(frame.maxX, button.right)
        button.top = max(frame.minY, button.top)
        button.bottom = min(frame.maxY, button.bottom)
    }

    /// 松手后吸附到更近的一侧边缘，并回调保存竖直位置
    private func snapToClosestEdge() {
        let frame = layoutFrame
        let leftDistance = button.centerX - frame.minX
        let rightDistance = frame.maxX - button.centerX

        position.horizontal = leftDistance < rightDistance ? .left : .right
        position.vertical = verticalRatio(of: button.centerY, in: frame)
        onDragEnd?(position)

        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.curveEaseInOut, .allowUserInteraction]) {
            self.layoutButton()
        }
    }

    private func verticalRatio(of centerY: CGFloat, in frame: CGRect) -> CGFloat {
        let minCenterY = frame.minY + buttonSize.height / 2.0
        if centerY <= minCenterY {
            return 0.0
        }

        let maxCenterY = frame.maxY - buttonSize.height / 2.0
        if centerY >= maxCenterY {
            return 1.0
        }

        return (centerY - minCenterY) / (maxCenterY - minCenterY)
    }

    /// 触摸是否落在按钮上
    func containsButtonTouch(_ touch: UITouch) -> Bool {
        guard button.superview != nil else {
            return false
        }

        return button.bounds.contains(touch.location(in: button))
    }
}
