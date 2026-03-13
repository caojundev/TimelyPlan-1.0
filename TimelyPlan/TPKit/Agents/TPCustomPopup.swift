//
//  TPCustomPopup.swift
//  TimelyPlan
//
//  Created on 2026/03/13.
//

import Foundation
import UIKit

// MARK: - TPCustomPopupQueue (主队列管理类)
class TPCustomPopupQueue: NSObject {
    
    enum Position {
        case top
        case middle
        case bottom
    }
    
    static let common = TPCustomPopupQueue()

    var edgeMargins = UIEdgeInsets(value: 20.0)
    
    /// 当前是否有信息显示
    var isShowing: Bool {
        return popupView != nil
    }
    
    /// 弹出条目队列
    private var popups: [TPCustomPopup] = []
    
    /// 弹出视图
    private var popupView: TPCustomPopupContainerView?
    
    // MARK: - Public Methods
    
    /// 弹出自定义视图（直接传入 UIView）
    public func showCustomView(_ customView: UIView & TPCustomPopupContent,
                               onView parentView: UIView? = nil,
                               position: Position = .middle,
                               duration: TimeInterval = 1.5) {
        
        let popup = TPCustomPopup(customView: customView,
                                  parentView: parentView,
                                  position: position,
                                  duration: duration)
        popups.append(popup)
        beginShowing()
    }
    
    // MARK: - Private Methods
    
    /// 开始显示
    private func beginShowing() {
        guard popups.count > 0 else {
            return
        }
        
        let popup = popups.removeFirst()
        showUp(popup)
    }
    
    private func showUp(_ popup: TPCustomPopup) {
        
        if popupView != nil {
            popupView?.removeFromSuperview()
            popupView = nil
        }
        
        guard let parentView = popup.parentView ?? UIWindow.keyWindow else {
            return
        }
        
        let popupView = TPCustomPopupContainerView(customView: popup.customView, popup: popup)
        parentView.addSubview(popupView)
        self.popupView = popupView
        
        /// 配置位置和尺寸
        let customView = popup.customView
        var popupWidth = parentView.width - edgeMargins.horizontalLength
        popupWidth = clampedValue(popupWidth, customView.minimumWidth, customView.maximumWidth)
        let popupHeight = customView.preferredHeight
        popupView.size = CGSize(width: popupWidth, height: popupHeight)
        
        switch popup.position {
        case .top:
            popupView.top = parentView.safeAreaFrame().minY + edgeMargins.top
        case .middle:
            popupView.alignVerticalCenter()
        case .bottom:
            popupView.bottom = parentView.safeAreaFrame().maxY - edgeMargins.bottom
        }
        
        popupView.alignHorizontalCenter()
        
        popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        popupView.alpha = 0.0
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut) {
            popupView.transform = .identity
            popupView.alpha = 1.0
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + popup.duration) {
                UIView.animate(withDuration: 0.2, animations: {
                    popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    popupView.alpha = 0.0
                }) { _ in
                    DispatchQueue.main.async {
                        popupView.removeFromSuperview()
                        self.popupView = nil
                        self.beginShowing() /// 继续显示
                    }
                }
           }
        }
    }
}

// MARK: - TPCustomPopup (弹窗配置模型)
class TPCustomPopup {
    
    /// 自定义视图
    let customView: UIView & TPCustomPopupContent
    
    /// 显示父视图
    let parentView: UIView?
    
    /// 位置
    let position: TPCustomPopupQueue.Position
    
    /// 显示时长
    let duration: TimeInterval
    
    init(customView: UIView & TPCustomPopupContent,
         parentView: UIView?,
         position: TPCustomPopupQueue.Position = .middle,
         duration: TimeInterval = 1.5) {
        
        self.customView = customView
        self.parentView = parentView
        self.position = position
        self.duration = duration
    }
}

// MARK: - 弹窗容器视图
class TPCustomPopupContainerView: UIView {
    
    let customView: UIView & TPCustomPopupContent
    let popup: TPCustomPopup
    
    init(customView: UIView & TPCustomPopupContent, popup: TPCustomPopup) {
        self.customView = customView
        self.popup = popup
        super.init(frame: .zero)
        self.addSubview(customView)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        customView.clipsToBounds = true
        customView.layer.cornerRadius = customView.cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.customView.frame = bounds
        self.layer.setBorderShadow(color: Color(0x000000, 0.25),
                                   offset: .zero,
                                   radius: 8.0,
                                   roundCorners: .allCorners,
                                   cornerRadius: customView.cornerRadius)
    }
}

protocol TPCustomPopupContent {
    
    /// 圆角半径
    var cornerRadius: CGFloat {get}
    
    /// 高度
    var preferredHeight: CGFloat {get}
    
    /// 最小宽度
    var minimumWidth: CGFloat {get}
  
    /// 最大宽度
    var maximumWidth: CGFloat {get}
}

extension TPCustomPopupContent {
    
    var cornerRadius: CGFloat {
        return 16.0
    }
    
    var preferredHeight: CGFloat {
        return 70.0
    }
    
    var minimumWidth: CGFloat {
        return 0.0
    }

    var maximumWidth: CGFloat {
        return .greatestFiniteMagnitude
    }
}
