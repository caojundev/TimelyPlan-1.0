//
//  CalendarExpandContainerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/8.
//

import UIKit

// 展示模式
enum CalendarExpandMode {
    case week
    case month
}

// 容器代理：外部提供视图、尺寸、偏移，接收切换回调
protocol CalendarExpandContainerDelegate: AnyObject {
    /// 获取对应模式的视图实例
    func container(_ container: CalendarExpandContainerView, viewFor mode: CalendarExpandMode) -> UIView
    
    /// 获取对应模式的容器高度
    func container(_ container: CalendarExpandContainerView, heightFor mode: CalendarExpandMode) -> CGFloat
    
    /// 获取周周在月视图的行
    func containerWeekRow(_ container: CalendarExpandContainerView) -> Int
    
    /// 切换动画完成回调
    func container(_ container: CalendarExpandContainerView, didFinishTransitionTo mode: CalendarExpandMode)
    
    /// 尺寸变化回调
    func containerFrameDidChange(_ container: CalendarExpandContainerView)
}

// 可选实现扩展
extension CalendarExpandContainerDelegate {
    func container(_ container: CalendarExpandContainerView, didFinishTransitionTo mode: CalendarExpandMode) {}
}

class CalendarExpandContainerView: UIView {
    
    // MARK: - 对外属性
    weak var delegate: CalendarExpandContainerDelegate?
    private(set) var currentMode: CalendarExpandMode
    
    // MARK: - 内部状态
    private var isAnimating = false
    private var isDragging = false
    
    // MARK: - 子视图
    private let contentContainer = UIView() // 裁剪容器，核心实现展开/收起视觉
    private var panGesture: UIPanGestureRecognizer!
    
    private(set) weak var currentView: UIView?   // 当前常驻显示的视图
    private weak var targetView: UIView?    // 过渡中临时存在的目标视图
    
    // MARK: - 动画配置
    private let expandThreshold: CGFloat = 0.5
    private let fastVelocity: CGFloat = 300
    private let animationDuration: TimeInterval = 0.3
    
    let grabberHeight = 20.0
    private let grabberView: TPGrabberView = .systemStyleGrabber()

    // 拖拽起始记录
    private var initialHeight: CGFloat = 0
    
    private var progress: CGFloat
    
    // MARK: - 初始化
    init(initialMode: CalendarExpandMode) {
        self.currentMode = initialMode
        self.progress = initialMode == .week ? 0.0 : 1.0
        super.init(frame: .zero)
        setupCommon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 基础搭建
    private func setupCommon() {
        // 内容裁剪：超出可视区域的部分隐藏，实现展开收起效果
        contentContainer.clipsToBounds = true
        contentContainer.backgroundColor = .systemBackground
        addSubview(contentContainer)
        
        grabberView.backgroundColor = .systemBackground
        grabberView.onTap = { [weak self] in
            self?.toggleMode()
        }
        
        addSubview(grabberView)
        addSeparator(position: .bottom)
        
        // 拖动手势
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    /// 外部调用：加载初始视图（设置delegate后调用一次）
    func loadInitialView() {
        guard let delegate = delegate else { return }
        let initialView = delegate.container(self, viewFor: currentMode)
        let height = delegate.container(self, heightFor: currentMode)
        contentContainer.addSubview(initialView)
        currentView = initialView
        
        frame.size.height = height + grabberHeight
        contentContainer.frame.size.height = height
        initialView.frame = contentContainer.bounds
    }
    
    // MARK: - 手动布局
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutContentContainer()
        layoutGrabberView()
        layoutContentView(with: progress)
    }
    
    private func layoutContentContainer() {
        var contentFrame = bounds
        contentFrame.size.height = bounds.height - grabberHeight
        contentContainer.frame = contentFrame
    }
    
    private func layoutGrabberView() {
        grabberView.frame = CGRect(
            x: 0,
            y: contentContainer.bottom,
            width: bounds.width,
            height: grabberHeight
        )
    }

    private func layoutContentView(with progress: CGFloat) {
        guard let delegate = delegate else { return }
    
        let weekView = currentMode == .week ? currentView : targetView
        let monthView = currentMode == .week ? targetView : currentView
        
        if let weekView = weekView {
            weekView.alpha = 1 - progress
            let weekHeight = delegate.container(self, heightFor: .week)
            weekView.width = bounds.width
            weekView.height = weekHeight
            weekView.top = offsetY(for: .week, progress: progress)
        }

        if let monthView = monthView {
            monthView.alpha = progress
            let monthHeight = delegate.container(self, heightFor: .month)
            monthView.width = bounds.width
            monthView.height = monthHeight
            monthView.top = offsetY(for: .month, progress: progress)
        }
    }
    
    private func offsetY(for mode: CalendarExpandMode,
                         progress: CGFloat) -> CGFloat {
        guard let delegate = delegate else { return 0.0 }
        let weekRow = delegate.containerWeekRow(self)
        let weekHeight = delegate.container(self, heightFor: .week)
        if mode == .week {
            return CGFloat(weekRow) * weekHeight * progress
        } else {
            return CGFloat(weekRow) * weekHeight * (progress - 1.0)
        }
    }
    
    private func progress(of height: CGFloat) -> CGFloat {
        guard let delegate = delegate else { return 0.0 }
        let weekHeight = delegate.container(self, heightFor: .week)
        let monthHeight = delegate.container(self, heightFor: .month)
        let progress = (height - weekHeight) / (monthHeight - weekHeight)
        return validatedProgress(progress)
    }
    
    private func contentHeight(of progress: CGFloat) -> CGFloat {
        guard let delegate = delegate else { return 0.0 }
        let weekHeight = delegate.container(self, heightFor: .week)
        let monthHeight = delegate.container(self, heightFor: .month)
        return weekHeight + progress * (monthHeight - weekHeight)
    }
    
    /// 添加目标视图并设置初始偏移
    private func addTargetView(_ targetView: UIView,
                               targetMode: CalendarExpandMode,
                               progress: CGFloat) {
        self.targetView = targetView
        
        targetView.alpha = 0.0
        targetView.isUserInteractionEnabled = false
        targetView.width = bounds.width
        targetView.height = delegate?.container(self, heightFor: targetMode) ?? 0.0
        targetView.top = offsetY(for: targetMode, progress: progress)
        targetView.layoutIfNeeded()
        contentContainer.addSubview(targetView)
        
        // 首次布局（建立 frame 和子视图布局）
        targetView.setNeedsLayout()
        targetView.layoutIfNeeded()
       
        // 延迟再次布局（处理无限滚动）
        DispatchQueue.main.async { [weak targetView] in
             guard let targetView = targetView else { return }
           
            // 第二次布局
            targetView.setNeedsLayout()
            targetView.layoutIfNeeded()
        }
    }
    
    /// 完成过渡：清理旧视图，更新常驻视图
    private func finishTransition(to mode: CalendarExpandMode) {
        currentView?.isUserInteractionEnabled = true
        targetView?.isUserInteractionEnabled = true
        // 移除旧的常驻视图
        currentView?.removeFromSuperview()
        // 目标视图升级为常驻视图
        currentView = targetView
        targetView = nil
        currentView?.frame = contentContainer.bounds
        
        currentMode = mode
        isAnimating = false
        isDragging = false
        
        delegate?.container(self, didFinishTransitionTo: mode)
    }
    
    /// 回弹取消过渡
    private func cancelTransition() {
        currentView?.isUserInteractionEnabled = true
        targetView?.isUserInteractionEnabled = true
        targetView?.removeFromSuperview()
        targetView = nil
        isAnimating = false
        isDragging = false
    }
    
    // MARK: - 对外手动切换方法
    func toggleMode(animated: Bool = true) {
        TPImpactFeedback.impactWithSoftStyle()
        let targetMode: CalendarExpandMode = currentMode == .week ? .month : .week
        switchToMode(targetMode, animated: animated)
    }
    
    func switchToMode(_ mode: CalendarExpandMode, animated: Bool) {
        guard mode != currentMode, !isAnimating, !isDragging else { return }
        guard let delegate = delegate else { return }
        
        let targetView = delegate.container(self, viewFor: mode)
        let currentProgress = currentMode == .week ? 0.0 : 1.0
        addTargetView(targetView, targetMode: mode, progress: currentProgress)
        
        let targetProgress = mode == .week ? 0.0 : 1.0
        let targetContentHeight = contentHeight(of: targetProgress)
        self.progress = targetProgress
        let transition = {
            self.frame.size.height = targetContentHeight + self.grabberHeight
            self.setNeedsLayout()
            self.layoutIfNeeded()
            delegate.containerFrameDidChange(self)
        }
        
        if animated {
            isAnimating = true
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut) {
                transition()
            } completion: { _ in
                self.finishTransition(to: mode)
            }
        } else {
            transition()
            finishTransition(to: mode)
        }
    }
}

// MARK: - 拖动手势处理
extension CalendarExpandContainerView {
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !isAnimating, let delegate = delegate else { return }
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .began:
            // 判断滑动方向是否有效
            let targetMode: CalendarExpandMode
            if currentMode == .week, translation.y >= 0 {
                targetMode = .month
            } else if currentMode == .month, translation.y <= 0 {
                targetMode = .week
            } else {
                return // 方向错误，不触发
            }
            
            isDragging = true
            initialHeight = bounds.height - grabberHeight
            progress = progress(of: initialHeight)
            currentView?.isUserInteractionEnabled = false
            
            // 获取目标视图并添加
            let targetView = delegate.container(self, viewFor: targetMode)
            addTargetView(targetView, targetMode: targetMode, progress: progress)
        case .changed:
            guard isDragging else { return }
            let targetMode: CalendarExpandMode = currentMode == .week ? .month : .week
            let targetHeight = delegate.container(self, heightFor: targetMode)
            
            let dy = translation.y
            let totalDistance = targetHeight - initialHeight
            let factor = max(0, min(1, dy / totalDistance))
            
            // 同步更新容器高度
            let currentHeight = initialHeight + totalDistance * factor
            progress = progress(of: currentHeight)
            frame.size.height = currentHeight + grabberHeight
            layoutContentContainer()
            layoutContentView(with: progress)
            layoutGrabberView()
            delegate.containerFrameDidChange(self)
        case .ended, .cancelled:
            guard isDragging else { return }
            let targetMode: CalendarExpandMode = currentMode == .week ? .month : .week
            let targetHeight = delegate.container(self, heightFor: targetMode)
            
            // 判断最终吸附方向
            let finalMode: CalendarExpandMode
            if velocity.y > fastVelocity {
                finalMode = .month
            } else if velocity.y < -fastVelocity {
                finalMode = .week
            } else {
                let progress = (bounds.height - initialHeight) / (targetHeight - initialHeight)
                finalMode = progress >= expandThreshold ? targetMode : currentMode
            }
            
            isAnimating = true
            progress = finalMode == .week ? 0.0 : 1.0
            let contentHeight = contentHeight(of: progress)
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut) {
                self.frame.size.height = contentHeight + self.grabberHeight
                self.setNeedsLayout()
                self.layoutIfNeeded()
                delegate.containerFrameDidChange(self)
            } completion: { _ in
                if finalMode == self.currentMode {
                    self.cancelTransition()
                } else {
                    self.finishTransition(to: finalMode)
                }
            }
        default: break
        }
    }
}

// MARK: - 手势冲突处理
extension CalendarExpandContainerView: UIGestureRecognizerDelegate {
    /// 仅竖向滑动触发手势
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pan.velocity(in: self)
        return abs(velocity.y) > abs(velocity.x)
    }
    
    /// 允许与横向ScrollView共存
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
