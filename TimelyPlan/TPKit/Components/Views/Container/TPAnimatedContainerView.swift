//
//  TPAnimatedContainerView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/20.
//

import UIKit

protocol TPAnimatedContainerViewDelegate: AnyObject {
    
    /// 获取内容视图的位置和尺寸信息
    func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect
}

class TPAnimatedContainerView: UIView {
    
    /// 容器视图代理对象
    weak var delegate: TPAnimatedContainerViewDelegate?
    
    /// 内容视图
    fileprivate(set) var contentView: UIView?
    
    private(set) var isAnimating: Bool = false
    
    /// 是否伴随透明度变换
    var alphaAnimationEnabled: Bool = false
    var fromViewEndAlpha = 0.0
    var toViewBeginAlpha = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView?.frame = contentViewFrame()
    }
    
    /// 内容视图
    public func contentViewFrame() -> CGRect {
        var frame = CGRect.zero
        if let contentView = contentView {
            frame = delegate?.animatedContainerView(self, frameForContentView: contentView) ?? bounds
        }
        
        return frame
    }
    
    public func setContentView(_ view: UIView) {
        setContentView(view, animateStyle: .none, complection: nil)
    }
    
    public func setContentView(_ view: UIView, animateStyle: SlideStyle) {
        setContentView(view, animateStyle: animateStyle, complection: nil)
    }
    
    public func setContentView(_ view: UIView, animateStyle: SlideStyle, complection: ((Bool) -> ())?){
        guard contentView != view else { return }
        
        if isAnimating {
            for subview in subviews {
                subview.layer.removeAllAnimations()
                if subview != contentView {
                    subview.removeFromSuperview()
                }
            }
            
            contentView?.frame = contentViewFrame()
            isAnimating = false
        }
        
        /// 当前内容视图
        let fromView = contentView
        
        /// 新内容视图
        let toView = view
        contentView = toView
        let toEndFrame = contentViewFrame()
        
        if animateStyle == .none {
            /// 无动画
            fromView?.removeFromSuperview()
            toView.frame = toEndFrame
            insertSubview(toView, at: 0)
            complection?(true)
            return
        }
        
        var toBeginFrame = toEndFrame
        let fromBeginFrame = fromView?.frame ?? bounds
        var fromEndFrame = fromBeginFrame
        switch animateStyle {
        case .none:
            break
        case .rightToLeft:
            toBeginFrame.origin.x += width
            fromEndFrame.origin.x -= width
        case .leftToRight:
            toBeginFrame.origin.x -= width
            fromEndFrame.origin.x += width
        case .topToBottom:
            toBeginFrame.origin.y -= height
            fromEndFrame.origin.y += height
        case .bottomToTop:
            toBeginFrame.origin.y += height
            fromEndFrame.origin.y -= height
        }
 
        toView.alpha = alphaAnimationEnabled ? toViewBeginAlpha : 1.0
        toView.frame = toBeginFrame
        insertSubview(toView, at: 0) /// 添加toView
        
        self.isAnimating = true
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.beginFromCurrentState, .curveEaseInOut]) {
            fromView?.frame = fromEndFrame
            fromView?.alpha = self.alphaAnimationEnabled ? self.fromViewEndAlpha : 1.0
            
            toView.frame = toEndFrame
            toView.alpha = 1.0
        } completion: { finished in
            self.isAnimating = false
            
            /// 如果当前内容视图已经切换为fromView则不移除
            if fromView != self.contentView {
                fromView?.removeFromSuperview()
            }
        }
    }
}
