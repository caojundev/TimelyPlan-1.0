//
//  TPFlipContainerView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/4.
//

import Foundation
import UIKit

class TPFlipContainerView: UIView {
    
    /// 容器视图数组
    var views: [UIView] = [] {
        didSet {
            guard !views.elementsEqual(oldValue) else {
                return
            }
            
            self.activeView = nil
            self.contentView.removeAllSubviews()
            for view in views {
                view.isHidden = true
                contentView.addSubview(view)
            }

            setNeedsLayout()
        }
    }

    /// 当前活动视图
    var activeView: UIView?
    
    /// 内容视图
    private var contentView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = UIView(frame: bounds)
        addSubview(contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        for view in views {
            view.frame = bounds
        }
    }

    func hideAllViews() {
        for view in views {
            view.isHidden = true
        }
    }

    func setActiveView(_ activeView: UIView?, animated: Bool) {
        guard let activeView = activeView else {
            self.activeView?.isHidden = true
            self.activeView = nil
            return
        }

        if activeView == self.activeView || !views.contains(activeView) {
            return
        }

        let fromView = self.activeView
        let toView = activeView
        self.activeView = activeView
        guard let fromView = fromView else {
            activeView.isHidden = false
            return
        }

        let duration: TimeInterval = animated ? 0.35 : 0
        let options: UIView.AnimationOptions = animated ? [.transitionFlipFromLeft,.curveEaseInOut] : []
        willTransition(fromView: fromView, toView: toView)
        fromView.isHidden = true
        toView.isHidden = false
        UIView.transition(from: fromView, to: toView, duration: duration, options: options) { finished in
            self.didEndTransition(fromView: fromView, toView: toView)
        }
    }

    func willTransition(fromView: UIView, toView: UIView) {

    }

    func didEndTransition(fromView: UIView, toView: UIView) {

    }
}
