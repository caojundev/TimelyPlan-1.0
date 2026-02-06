//
//  TPBasePopoverView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/25.
//

import Foundation
import UIKit

class TPBasePopoverView: UIView, TFPopoverContent {
    
    var cornerRadius: CGFloat = 16.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var popoverLayoutMargins: UIEdgeInsets = UIEdgeInsets(value: 5.0)
    
    var popoverView: UIView! {
        didSet {
            contentView.addSubview(popoverView)
        }
    }
    
    var containerView: UIView!
    
    var contentSize: CGSize = CGSize(width: 180.0, height:200.0)
    
    let contentView: UIView = UIView()
    
    private let contentWrapperView: UIView = UIView()
    
    /// 其它允许的弹窗位置
    var permittedPositions: [TPPopoverPosition] = TPPopoverPosition.allCases
    
    /// 首选弹窗位置
    var preferredPosition: TPPopoverPosition = .topRight
    
    /// 实际弹窗位置
    private var popoverPosition: TPPopoverPosition = .topRight
    
    /// 源视图
    var sourceView: UIView?
    
    /// 源坐标尺寸信息
    var sourceRect: CGRect = .zero
    
    /// 源视图是否被遮盖
    var isSourceViewCovered: Bool = false
    
    /// 是否动画关闭
    var isHideWithAnimation: Bool = true
    
    /// 正在执行隐藏动画中
    private(set) var isHiding: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        self.backgroundColor = .clear
        
        self.contentWrapperView.clipsToBounds = false
        self.contentWrapperView.backgroundColor = Color(light: 0xFEFFFF, dark: 0x1E1F20)
        addSubview(self.contentWrapperView)
        
        self.contentView.clipsToBounds = true
        self.contentWrapperView.addSubview(self.contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isHiding else {
            return
        }
        
        self.updateFrame(animated: false)
        self.contentWrapperView.frame = bounds
        self.contentWrapperView.layer.cornerRadius = cornerRadius
        self.contentWrapperView.layer.setBorderShadow(color: Color(0x000000, 0.2),
                                                      offset: .zero,
                                                      radius: cornerRadius,
                                                      roundCorners: .allCorners,
                                                      cornerRadius: cornerRadius)
        self.contentView.frame = bounds
        self.contentView.layer.cornerRadius = cornerRadius
        self.popoverView.frame = contentView.layoutFrame()
        self.updateContentSizeIfNeeded()
    }
    
    // MARK: - TFPopoverContent
    var popoverContentSize: CGSize {
        return CGSize(width: 180.0, height: 240.0)
    }
    
    /// 更新内容大小
    func updateContentSizeIfNeeded() {
        DispatchQueue.main.async {
            let contentSize = self.popoverContentSize
            if self.contentSize != contentSize {
                self.contentSize = contentSize
                self.setNeedsLayout()
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let isInside = super.point(inside: point, with: event)
        if !isInside {
            hide(animated: isHideWithAnimation)
            return true
        }
        
        return isInside
    }

    // MARK: - 布局相关
    func popoverFrameInContainerView() -> CGRect {
        /// 更新显示位置
        self.updatePopoverPosition()
        return availablePopoverFrame(for: contentSize, position: popoverPosition)
    }
    
    // MARK: - 显示，隐藏
    func show(from sourceView: UIView?,
              sourceRect: CGRect?,
              isCovered: Bool,
              preferredPosition: TPPopoverPosition,
              permittedPositions: [TPPopoverPosition] = TPPopoverPosition.allCases,
              animated: Bool) {
        guard let keyWindow = UIWindow.keyWindow else {
            return
        }
        
        self.sourceView = sourceView
        if let sourceRect = sourceRect {
            self.sourceRect = sourceRect
        } else {
            self.sourceRect = sourceView?.bounds ?? .zero
        }
        
        self.addSourceViewFrameObserver()
        self.preferredPosition = preferredPosition
        self.permittedPositions = permittedPositions
        self.isSourceViewCovered = isCovered
        self.containerView = keyWindow
        self.updateFrame(animated: false)
        self.containerView.addSubview(self)
        
        self.contentWrapperView.transform = .init(scaleX: 0.2, y: 0.2)
        self.contentWrapperView.alpha = 0.0
        let animations = {
            self.contentWrapperView.transform = .identity
            self.contentWrapperView.alpha = 1.0
        }
        
        if animated {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseIn,
                           animations: animations,
                           completion: nil)
        } else {
            animations()
        }
    }

    func hide(after duration: TimeInterval, animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.hide(animated: animated, completion: completion)
        }
    }
    
    func hide(animated: Bool, completion: (() -> Void)? = nil) {
        if isHiding {
            return
        }
        
        self.isHiding = true
        self.removeSourceViewFrameObserver()
        let animations = {
            self.contentWrapperView.transform = .init(scaleX: 0.2, y: 0.2)
            self.contentWrapperView.alpha = 0.0
        }
        
        if animated {
            UIView.animate(withDuration: 0.6,
                           delay: 0.0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.0,
                           options: [.beginFromCurrentState, .curveEaseOut],
                           animations: animations) { _ in
                self.removeFromSuperview()
                completion?()
            }
        } else {
            animations()
            self.removeFromSuperview()
            completion?()
        }
    }
    
    // MARK: -
    func updateFrame(animated: Bool) {
        let newFrame = popoverFrameInContainerView()
        self.contentWrapperView.layer.anchorPoint = anchorPoint(for: popoverPosition)
        if self.frame == newFrame {
            return
        }
   
        let animations = {
            self.frame = newFrame
        }
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: animations,
                           completion: nil)
        } else {
            animations()
        }
    }
    
    // MARK: - 锚点
    func anchorPoint(for position: TPPopoverPosition) -> CGPoint {
        var anchorPoint: CGPoint = .zero
        switch position {
        case .center:
            anchorPoint = CGPoint(0.5, 0.5)
        case .topLeft:
            anchorPoint = CGPoint(1.0, 1.0)
        case .topCenter:
            anchorPoint = CGPoint(0.5, 1.0)
        case .topRight:
            anchorPoint = CGPoint(0.0, 1.0)
        case .bottomLeft:
            anchorPoint = CGPoint(1.0, 0.0)
        case .bottomCenter:
            anchorPoint = CGPoint(0.5, 0.0)
        case .bottomRight:
            anchorPoint = CGPoint(0.0, 0.0)
        case .centerLeft:
            anchorPoint = CGPoint(1.0, 0.5)
        case .centerRight:
            anchorPoint = CGPoint(0.0, 0.5)
        }
        
        return anchorPoint
    }
    
    // MARK: - 更新位置
    private func updatePopoverPosition() {
        self.popoverPosition = preferredPosition /// 设置实际位置首选位置
        var popoverFrame = availablePopoverFrame(for: contentSize, position: preferredPosition)
        if popoverFrame.size == contentSize {
            return
        }
        
        /// 首选位置不满足条件，检查其它允许弹窗位置
        for position in permittedPositions {
            if position == preferredPosition {
                continue
            }
            
            let frame = availablePopoverFrame(for: contentSize, position: position)
            if frame.size == contentSize {
                self.popoverPosition = position
                break
            }
            
            /// 计算显示区域面积，查找最优显示位置
            if (frame.width * frame.height > popoverFrame.width * popoverFrame.height)
            {
                self.popoverPosition = position
                popoverFrame = frame
            }
        }
    }
    
    /// 获取对应位置布局区域信息
    func availablePopoverFrame(for contentSize: CGSize, position: TPPopoverPosition) -> CGRect {
        var fromPoint = fromPoint(for: sourceView,
                                     sourceRect: sourceRect,
                                     position: position,
                                     isCovered: isSourceViewCovered)
        let layoutFrame = containerView.safeAreaFrame().inset(by: popoverLayoutMargins)
        if !layoutFrame.contains(fromPoint) {
            /// 调整fromPoint位置
            fromPoint.x = min(layoutFrame.maxX, max(layoutFrame.minX, fromPoint.x))
            fromPoint.y = min(layoutFrame.maxY, max(layoutFrame.minY, fromPoint.y))
        }
        
        let popoverFrame = popoverFrame(from: fromPoint,
                                        contentSize: contentSize,
                                        position: position)
        return layoutFrame.intersection(popoverFrame)
    }

    func fromPoint(for sourceView: UIView?,
                   sourceRect: CGRect,
                   position: TPPopoverPosition,
                   isCovered: Bool = false) -> CGPoint {
        let fromRect = self.fromRect(for: sourceView, sourceRect: sourceRect)
        var fromPoint: CGPoint

        switch position {
        case .topLeft:
            fromPoint = isCovered ? fromRect.bottomRight : fromRect.topRight
            
        case .topCenter:
            fromPoint = isCovered ? fromRect.bottomMid : fromRect.topMid
            
        case .topRight:
            fromPoint = isCovered ? fromRect.bottomLeft : fromRect.topLeft
            
        case .bottomLeft:
            fromPoint = isCovered ? fromRect.topRight : fromRect.bottomRight
            
        case .bottomCenter:
            fromPoint = isCovered ? fromRect.topMid : fromRect.bottomMid
            
        case .bottomRight:
            fromPoint = isCovered ? fromRect.topLeft : fromRect.bottomRight
            
        case .centerLeft:
            fromPoint = isCovered ? fromRect.rightMid : fromRect.leftMid
            
        case .centerRight:
            fromPoint = isCovered ? fromRect.leftMid : fromRect.rightMid
            
        default:
            fromPoint = fromRect.center
        }

        return fromPoint
    }

    func fromRect(for sourceView: UIView?, sourceRect: CGRect) -> CGRect {
        var fromRect: CGRect
        if let sourceView = sourceView {
            let fromOrigin = sourceView.convert(CGPoint.zero, toViewOrWindow: containerView)
            fromRect = CGRect(x: fromOrigin.x + sourceRect.origin.x,
                              y: fromOrigin.y + sourceRect.origin.y,
                              width: sourceRect.width,
                              height: sourceRect.height)
        } else {
            fromRect = containerView.safeAreaFrame().inset(by: popoverLayoutMargins)
        }
        
        return fromRect;
    }

    /// 获取弹窗区域信息
    /// @param point 弹窗点
    /// @param contentSize 窗口内容大小
    /// @param position 弹窗显示位置
    func popoverFrame(from point: CGPoint, contentSize: CGSize, position: TPPopoverPosition) -> CGRect {
        let w = contentSize.width
        let h = contentSize.height
        var frame = CGRect(x: 0, y: 0, size: contentSize)

        switch position {
        case .topLeft:
            frame.origin = CGPoint(x: point.x - w, y: point.y - h)
            
        case .topCenter:
            frame.origin = CGPoint(x: point.x - w / 2.0, y: point.y - h)
            
        case .topRight:
            frame.origin = CGPoint(x: point.x, y: point.y - h)
            
        case .bottomLeft:
            frame.origin = CGPoint(x: point.x - w, y: point.y)
            
        case .bottomCenter:
            frame.origin = CGPoint(x: point.x - w / 2.0, y: point.y)
            
        case .bottomRight:
            frame.origin = point
            
        case .centerLeft:
            frame.origin = CGPoint(x: point.x - w, y: point.y - h / 2.0)
            
        case .centerRight:
            frame.origin = CGPoint(x: point.x, y: point.y - h / 2.0)
            
        default:
            frame.origin = CGPoint(x: point.x - w / 2.0, y: point.y - h / 2.0)
        }

        return frame
    }

    // MARK: - Frame Observer
    private func iterateSubviews(_ sourceView: UIView?, action: (UIView) -> Void) {
        guard let sourceView = sourceView else {
            return
        }

        var nextResponder = sourceView.next
        while nextResponder != nil {
            if let view = nextResponder as? UIView {
                action(view)
            } else if let viewController = nextResponder as? UIViewController {
                action(viewController.view)
            }

            nextResponder = nextResponder?.next
        }
    }

    var observeViews: [UIView] = []
    func addSourceViewFrameObserver() {
        iterateSubviews(sourceView) { view in
            view.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
            observeViews.append(view)
        }
    }

    func removeSourceViewFrameObserver() {
        for view in observeViews {
            view.removeObserver(self, forKeyPath: "frame")
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if isHiding {
            return
        }
        
        updateFrame(animated: false)
    }
    
}
