//
//  TPLoadingIndicator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/17.
//

import Foundation
import UIKit

/// 全局加载指示器管理器
class TPLoadingIndicator {
    
    // MARK: - Singleton
    static let shared = TPLoadingIndicator()
    private init() {}
    
    // MARK: - Properties
    private var loadingCount = 0
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    private var messageLabel: UILabel?
    private let tag = 99999
    
    // MARK: - Public Methods
    
    /// 显示加载指示器
    /// - Parameters:
    ///   - message: 可选的提示文字
    ///   - allowUserInteraction: 是否允许用户交互（默认 false，阻止用户操作）
    func show(message: String? = nil, allowUserInteraction: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.loadingCount += 1
            
            // 如果已经显示，只更新消息
            if self.loadingView != nil {
                self.messageLabel?.text = message
                return
            }
            
            guard let window = self.getKeyWindow() else { return }
            
            // 创建背景视图
            let backgroundView = UIView(frame: window.bounds)
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            backgroundView.tag = self.tag
            backgroundView.isUserInteractionEnabled = !allowUserInteraction
            
            // 创建容器视图
            let containerView = UIView()
            containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
            containerView.layer.cornerRadius = 12
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
            containerView.layer.shadowRadius = 8
            containerView.layer.shadowOpacity = 0.2
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            // 创建活动指示器
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .systemBlue
            indicator.startAnimating()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            
            // 创建消息标签
            let label = UILabel()
            label.text = message
            label.textColor = .label
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            
            // 添加到视图层级
            containerView.addSubview(indicator)
            containerView.addSubview(label)
            backgroundView.addSubview(containerView)
            window.addSubview(backgroundView)
            
            // 设置约束
            NSLayoutConstraint.activate([
                // 容器视图约束
                containerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
                containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
                containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                
                // 指示器约束
                indicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
                indicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                // 标签约束
                label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 12),
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
            ])
            
            // 添加动画
            backgroundView.alpha = 0
            containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.2) {
                backgroundView.alpha = 1
                containerView.transform = .identity
            }
            
            self.loadingView = backgroundView
            self.activityIndicator = indicator
            self.messageLabel = label
        }
    }
    
    /// 隐藏加载指示器
    func hide() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.loadingCount = max(0, self.loadingCount - 1)
            
            // 如果还有未完成的加载请求，不隐藏
            guard self.loadingCount == 0, let loadingView = self.loadingView else { return }
            
            UIView.animate(withDuration: 0.2, animations: {
                loadingView.alpha = 0
                loadingView.subviews.first?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                loadingView.removeFromSuperview()
                self.loadingView = nil
                self.activityIndicator = nil
                self.messageLabel = nil
            }
        }
    }
    
    /// 强制隐藏所有加载指示器
    func hideAll() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingCount = 0
            self.loadingView?.removeFromSuperview()
            self.loadingView = nil
            self.activityIndicator = nil
            self.messageLabel = nil
        }
    }
    
    /// 更新消息
    func updateMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel?.text = message
        }
    }
    
    // MARK: - Private Methods
    
    private func getKeyWindow() -> UIWindow? {
        return UIWindow.keyWindow
    }
}

// MARK: - 便捷扩展
extension TPLoadingIndicator {
    
    /// 显示带默认消息的加载指示器
    static func showLoading(_ message: String = "加载中...") {
        shared.show(message: message)
    }
    
    /// 隐藏加载指示器
    static func hideLoading() {
        shared.hide()
    }
    
    /// 强制隐藏所有
    static func hideAllLoading() {
        shared.hideAll()
    }
}
