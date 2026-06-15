//
//  CalendarScheduleDragView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/15.
//

import Foundation
import UIKit

// MARK: - Drag Mode Enum
enum CalendarScheduleDragMode {
    case none
    case move
    case resizeTopRight
    case resizeBottomLeft
}

class ScheduleDragView: UIView {
    
    var color: UIColor = .systemBlue {
        didSet {
            setNeedsLayout()
        }
    }
    
    var topRightHandleCenter: CGPoint {
        return topRightHandle.center
    }
    
    var bottomLeftHandleCenter: CGPoint {
        return bottomLeftHandle.center
    }
    
    // 拖拽点尺寸
    private let handleSize: CGFloat = 10.0
    private let handleBorderWidth: CGFloat = 2.0
    private let handleEdgeMargin = 12.0
    
    // 拖拽点视图
    private let topRightHandle: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.borderColor = UIColor.systemBlue.cgColor
        v.layer.borderWidth = 2
        v.isUserInteractionEnabled = false // 不拦截手势，由父视图统一处理
        return v
    }()
    
    private let bottomLeftHandle: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.borderWidth = 2
        v.isUserInteractionEnabled = false
        return v
    }()
    
    let contentView = UIView()
    
    var dateRange: DateInterval
    
    // MARK: - Initialization
    init(dateRange: DateInterval) {
        self.dateRange = dateRange
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topRightHandle.layer.borderColor = color.cgColor
        bottomLeftHandle.layer.borderColor = color.cgColor
        contentView.layer.borderColor = color.cgColor
        contentView.frame = bounds
        updateHandleFrames()
    }
    
    func setupView() {
        clipsToBounds = false
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = CalendarConstant.eventViewCornerRadius
        contentView.layer.borderWidth = 1.2
        contentView.backgroundColor = Color(light: 0xDAECFF,
                                            dark: 0x23303F,
                                            alpha: 0.9)
        addSubview(contentView)
        addSubview(topRightHandle)
        addSubview(bottomLeftHandle)
        updateHandleFrames()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isHidden {
            return super.point(inside: point, with: event)
        }
        
        let edgeInsets = UIEdgeInsets(horizontal: -10.0, vertical: -20.0)
        let hitTestFrame = self.bounds.inset(by: edgeInsets)
        return hitTestFrame.contains(point)
    }
    
    private func updateHandleFrames() {
        // 右上角拖拽点
        topRightHandle.frame = CGRect(
            x: bounds.width - handleSize - handleEdgeMargin, // 留一点边距
            y: -handleSize / 2.0,
            width: handleSize,
            height: handleSize
        )
        
        topRightHandle.layer.cornerRadius = handleSize / 2
        
        // 左下角拖拽点
        bottomLeftHandle.frame = CGRect(
            x: handleEdgeMargin,
            y: bounds.height - handleSize / 2.0,
            width: handleSize,
            height: handleSize
        )
        bottomLeftHandle.layer.cornerRadius = handleSize / 2
    }
    
    /// 获取触摸点的拖拽模式
    func dragMode(touchPoint: CGPoint) -> CalendarScheduleDragMode {
        if bounds.contains(touchPoint) {
            let moveFrame = CGRect(x: bounds.width / 4.0,
                                   y: 0.0,
                                   width: bounds.width / 2.0,
                                   height: bounds.height)
            if moveFrame.contains(touchPoint) {
                return .move
            }
        }
        
        let handleOuterHeight = 15.0
        /// 扩大响应区域
        let rect = bounds.insetBy(dx: 0.0, dy: -handleOuterHeight)
        guard rect.contains(touchPoint) else {
            return .none
        }
    
        let handleInnerHeight = 10.0
        let handleAreaHeight = handleInnerHeight + handleOuterHeight
        if touchPoint.x < bounds.width / 2.0 {
            /// 左下角
            let handleRect = CGRect(x: 0.0,
                                    y: bounds.height - handleInnerHeight,
                                    width: bounds.width,
                                    height: handleAreaHeight)
            if handleRect.contains(touchPoint) {
                return .resizeBottomLeft
            }
        } else {
            /// 右上角
            let handleRect = CGRect(x: 0.0,
                                    y: -handleOuterHeight,
                                    width: bounds.width,
                                    height: handleAreaHeight)
            if handleRect.contains(touchPoint) {
                return .resizeTopRight
            }
        }
        
        if bounds.contains(touchPoint) {
            return .move
        }
        
        return .none
    }
}
