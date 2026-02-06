//
//  TPContainerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/26.
//

import Foundation
import UIKit

class TPContainerViewController: TPViewController {
    
    let containerView = UIView()
    
    private var _contentViewController: UIViewController?
    var contentViewController: UIViewController? {
        get {
            return _contentViewController
        }
        
        set {
            guard let vc = newValue else {
                _contentViewController?.view.removeFromSuperview()
                removeSubViewController(_contentViewController)
                _contentViewController = nil
                return
            }
            
            setContentViewController(vc, withAnimationStyle: .none)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(containerView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        containerView.frame = view.bounds
        updateContentViewFrame()
    }
    
    func updateContentViewFrame() {
        if let contentView = contentViewController?.view {
            contentView.frame = contentViewFrame()
        }
    }
    
    /// 内容视图frame
    func contentViewFrame() -> CGRect {
        return view.bounds
    }
    
    func setContentViewController(_ viewController: UIViewController,
                                  withAnimationStyle style: SlideStyle = .none) {
        guard _contentViewController != viewController else { return }
        
        /// 旧视图
        let fromView = _contentViewController?.view
        removeSubViewController(_contentViewController)
        
        /// 添加新视图控制器
        addSubviewController(viewController, parent: containerView)
        _contentViewController = viewController
        let toView = viewController.view!
        
        if style == .none {
            fromView?.removeFromSuperview()
            toView.frame = contentViewFrame()
            return
        }
        
        let toEndFrame = contentViewFrame()
        var toBeginFrame = toEndFrame
        let fromBeginFrame = fromView?.frame ?? view.bounds
        var fromEndFrame = fromBeginFrame
        
        if style == .rightToLeft {
            toBeginFrame.origin.x += view.width
            fromEndFrame.origin.x -= view.width
        } else if style == .leftToRight {
            toBeginFrame.origin.x -= view.width
            fromEndFrame.origin.x += view.width
        }
        
        toView.frame = toBeginFrame
        UIView.animate(withDuration: 0.8,
                       delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut) {
            fromView?.frame = fromEndFrame
            toView.frame = toEndFrame
        } completion: { finished in
            /// 如果当前内容视图已经切换为fromView则不移除
            if fromView != self.contentViewController?.view {
                fromView?.removeFromSuperview()
            }
        }
    }
}

