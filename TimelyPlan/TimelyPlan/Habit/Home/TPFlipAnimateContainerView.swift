//
//  TPFlipAnimateContainerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//

import Foundation
import UIKit

/// 支持翻转动画的容器视图
/// 可以在多个子视图之间进行流畅的翻转切换动画
public class TPFlipAnimateContainerView: UIView {
    
    // MARK: - Properties
    
    /// 容器视图数组
    public var views: [UIView] = [] {
        didSet {
            guard !views.elementsEqual(oldValue, by: { $0 === $1 }) else { return }
            setupViews()
        }
    }
    
    /// 当前活动视图
    public private(set) var activeView: UIView?
    
    /// 内容容器视图
    private let contentView = UIView()
    
    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Public Methods
    
    /// 设置当前视图，对日期之间的过渡进行动画处理
    /// - Parameters:
    ///   - activeView: 要激活的视图
    ///   - animated: 是否使用动画
    public func setActiveView(_ activeView: UIView?, animated: Bool = false) {
        guard let newActiveView = activeView else {
            self.activeView?.isHidden = true
            self.activeView = nil
            return
        }
        
        // 检查是否是同一个视图或不在容器中
        guard self.activeView !== newActiveView,
              views.contains(where: { $0 === newActiveView }) else {
            return
        }
        
        let fromView = self.activeView
        let toView = newActiveView
        self.activeView = toView
        
        let duration: TimeInterval = animated ? 0.35 : 0
        let options: UIView.AnimationOptions = animated ? 
            [.transitionFlipFromLeft, .curveEaseInOut] : []
        
        willTransition(fromView: fromView, toView: toView)
        
        fromView?.isHidden = true
        toView.isHidden = false
        
        UIView.transition(from: fromView ?? UIView(),
                         to: toView,
                         duration: duration,
                         options: options) { [weak self] finished in
            self?.didEndTransition(fromView: fromView, toView: toView)
        }
    }
    
    // MARK: - Override Methods
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        views.forEach { $0.frame = bounds }
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupViews() {
        activeView = nil
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        views.forEach { view in
            view.isHidden = true
            contentView.addSubview(view)
        }
        
        setNeedsLayout()
    }
    
    private func hideAllViews() {
        views.forEach { $0.isHidden = true }
    }
    
    // MARK: - Subclass Hooks
    
    /// 将要从fromView切换到toView通知
    /// 子类可以重写此方法来处理切换前的逻辑
    /// - Parameters:
    ///   - fromView: 即将隐藏的视图
    ///   - toView: 即将显示的视图
    open func willTransition(fromView: UIView?, toView: UIView?) {
        // 子类可以重写此方法
    }
    
    /// 从fromView切换到toView动画结束通知
    /// 子类可以重写此方法来处理切换后的逻辑
    /// - Parameters:
    ///   - fromView: 已隐藏的视图
    ///   - toView: 已显示的视图
    open func didEndTransition(fromView: UIView?, toView: UIView?) {
        // 子类可以重写此方法
    }
}
