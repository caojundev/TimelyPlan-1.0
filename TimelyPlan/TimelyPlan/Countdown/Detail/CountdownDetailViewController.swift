//
//  CountdownDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

/// 倒数日事项详情
class CountdownDetailViewController: UIViewController {
    
    struct Config {
        /// 关闭按钮尺寸
        static let closeButtonSize = CGSize(width: 36.0, height: 36.0)
        /// 关闭按钮边界间距
        static let closeButtonMargins = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 0.0, right: 0.0)
        /// 更多按钮尺寸
        static let moreButtonSize = CGSize(width: 36.0, height: 36.0)
        /// 更多按钮边界间距
        static let moreButtonMargins = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 0.0, right: 16.0)
        /// 触发下滑关闭的最小距离
        static let dismissTranslationThreshold: CGFloat = 120.0
        /// 触发下滑关闭的最小速度
        static let dismissVelocityThreshold: CGFloat = 800.0
        /// 下滑过程中的最小透明度
        static let draggingMinimumAlpha: CGFloat = 0.5
        /// 入场动画时长与逐项延迟
        static let entryAnimationDuration: TimeInterval = 0.6
        static let entryAnimationDelayStep: TimeInterval = 0.05
    }
    
    // MARK: - 交互器
    /// 倒数日事项交互器（提供最新事项并通知事项变更）
    private let interactor: CountdownEventInteractor
    
    // MARK: - 视图
    /// 内容视图（标题 / 提示 / 日期 / 天数）
    private let contentView = CountdownDetailContentView()
    
    /// 入场动画元素（依次淡入，天数最后出现）
    private var entryAnimationElements: [UIView] {
        return [contentView.titleLabel, contentView.tipLabel, contentView.dateLabel,
                closeButton, moreButton, contentView.daysLabel]
    }
    
    private lazy var closeButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("xmark_24")
        button.imageSize = .mini
        button.cornerRadius = .greatestFiniteMagnitude
        button.normalImageColor = .white
        button.normalBackgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.addTarget(self, action: #selector(clickClose(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var moreButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("ellipsis_24")
        button.imageSize = .mini
        button.cornerRadius = .greatestFiniteMagnitude
        button.normalImageColor = .white
        button.normalBackgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var backgroundView: CountdownBackgroundView = {
        /// 背景渐变色根据事项颜色动态计算
        return CountdownBackgroundView(frame: view.bounds,
                                       themeColor: interactor.event.color ?? interactor.event.type.color)
    }()
    
    /// 下滑关闭手势
    private lazy var dismissPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(handleDismissPanGesture(_:)))
        return gesture
    }()
    
    /// 是否已播放入场动画
    private var hasPlayedEntryAnimation = false
    
    // MARK: - 初始化
    init(event: CountdownEvent) {
        self.interactor = CountdownEventInteractor(event: event)
        super.init(nibName: nil, bundle: nil)
        configureInteractor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// 转场结束后再播放入场动画，避免被弹出转场覆盖
        animateEntryIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.frame = view.bounds
        contentView.frame = view.bounds
        layoutButtons()
    }
    
    // MARK: - UI
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(contentView)
        view.addSubview(closeButton)
        view.addSubview(moreButton)
        
        /// 内容：标题 / 提示 / 目标日期 / 天数
        updateContent()
        
        /// 入场前隐藏，由入场动画显示
        entryAnimationElements.forEach {
            $0.alpha = 0.0
        }
        
        /// 下滑关闭手势
        view.addGestureRecognizer(dismissPanGesture)
    }
    
    // MARK: - 交互器
    /// 配置交互器回调：事项改变刷新内容，事项删除则关闭当前视图
    private func configureInteractor() {
        interactor.onEventChange = { [weak self] _ in
            self?.updateContent()
        }
        
        interactor.onEventDeleted = { [weak self] in
            self?.dismissDetail()
        }
    }
    
    /// 刷新内容视图与背景
    private func updateContent() {
        let event = interactor.event
        contentView.apply(event: event)
        backgroundView.apply(themeColor: event.color ?? event.type.color)
    }
    
    // MARK: - 布局
    /// 布局顶部按钮（内容视图内部自行布局标签）
    private func layoutButtons() {
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        
        /// 关闭按钮：左上角
        closeButton.size = Config.closeButtonSize
        closeButton.left = safeFrame.minX + Config.closeButtonMargins.left
        closeButton.top = safeFrame.minY + Config.closeButtonMargins.top
        
        /// 更多按钮：右上角
        moreButton.size = Config.moreButtonSize
        moreButton.right = safeFrame.maxX - Config.moreButtonMargins.right
        moreButton.top = safeFrame.minY + Config.moreButtonMargins.top
    }
    
    // MARK: - 动画
    /// 播放入场动画（仅首次）
    private func animateEntryIfNeeded() {
        guard !hasPlayedEntryAnimation else {
            return
        }
        
        hasPlayedEntryAnimation = true
        
        /// 元素：自下而上淡入（天数最后出现）
        for (index, element) in entryAnimationElements.enumerated() {
            element.transform = CGAffineTransform(translationX: 0.0, y: 20.0)
            UIView.animate(withDuration: Config.entryAnimationDuration,
                           delay: Config.entryAnimationDelayStep * Double(index),
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [.allowUserInteraction]) {
                element.alpha = 1.0
                element.transform = .identity
            }
        }
    }
    
    // MARK: - Event Response
    /// 关闭详情
    @objc private func clickClose(_ sender: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: nil)
    }
    
    /// 更多操作：弹出事项菜单
    @objc private func clickMore(_ sender: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let menuController = CountdownEventMenuController(event: interactor.event)
        menuController.didSelectMenuActionType = { [weak self] type in
            self?.interactor.performMenuAction(type)
        }
        
        let sourceRect = sender.bounds.insetBy(dx: -5.0, dy: -5.0)
        menuController.showMenu(from: sender,
                                sourceRect: sourceRect,
                                isCovered: false)
    }
    
    /// 关闭当前详情页（事项被删除时调用）
    /// - Note: 删除确认弹窗等可能仍在显示，统一由其逐层关闭后再关闭详情页
    private func dismissDetail() {
        TPImpactFeedback.impactWithSoftStyle()
        dismissAll(animated: true)
    }
    
    // MARK: - 下滑关闭手势
    /// 处理下滑关闭手势
    @objc private func handleDismissPanGesture(_ gesture: UIPanGestureRecognizer) {
        /// 仅响应向下拖动
        let offset = max(0.0, gesture.translation(in: view).y)
        
        switch gesture.state {
        case .changed:
            view.transform = CGAffineTransform(translationX: 0.0, y: offset)
            /// 随拖动距离淡出
            let progress = min(1.0, offset / max(1.0, view.bounds.height * 0.8))
            view.alpha = max(Config.draggingMinimumAlpha, 1.0 - progress)
        case .ended, .cancelled, .failed:
            let velocity = gesture.velocity(in: view).y
            let shouldDismiss = offset > Config.dismissTranslationThreshold
                || velocity > Config.dismissVelocityThreshold
            if shouldDismiss {
                dismissByDragging()
            } else {
                resetDraggingState()
            }
        default:
            break
        }
    }
    
    /// 拖动关闭
    private func dismissByDragging() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0.0, y: self.view.bounds.height)
            self.view.alpha = 0.0
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    /// 拖动距离不足时复位
    private func resetDraggingState() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut],
                       animations: {
            self.view.transform = .identity
            self.view.alpha = 1.0
        })
    }
}
