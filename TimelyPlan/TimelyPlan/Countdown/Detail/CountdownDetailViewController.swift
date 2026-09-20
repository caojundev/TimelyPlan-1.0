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
        /// 触发下滑关闭的最小距离
        static let dismissTranslationThreshold: CGFloat = 120.0
        /// 触发下滑关闭的最小速度
        static let dismissVelocityThreshold: CGFloat = 800.0
        /// 下滑过程中的最小透明度
        static let draggingMinimumAlpha: CGFloat = 0.5
        /// 天数默认字号
        static let daysFontSize: CGFloat = 120.0
        /// 天数单位字号
        static let daysUnitFont = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        /// 天数区域与屏幕两侧最小间距
        static let daysHorizontalMargin: CGFloat = 24.0
        /// 天数自适应最小缩放比例
        static let daysMinimumScaleFactor: CGFloat = 0.34
        /// 天数光晕呼吸动画的透明度范围
        static let daysGlowMinOpacity: CGFloat = 0.3
        static let daysGlowMaxOpacity: CGFloat = 0.7
        /// 天数光晕呼吸周期
        static let daysGlowAnimationDuration: CFTimeInterval = 1.5
        /// 入场动画时长与逐项延迟
        static let entryAnimationDuration: TimeInterval = 0.6
        static let entryAnimationDelayStep: TimeInterval = 0.05
    }
    
    /// 动画键
    private enum AnimationKey {
        static let daysGlow = "daysGlowPulse"
    }
    
    // MARK: - 数据
    /// 倒数日事项
    let event: CountdownEvent
    
    // MARK: - 视图
    private let titleLabel = UILabel()
    private let tipLabel = UILabel()
    private let dateLabel = UILabel()
    private let daysLabel = UILabel()
    
    /// 天数基础字体（宽度不足时由 adjustsFontSizeToFitWidth 缩放）
    private let daysBaseFont = UIFont.monospacedDigitSystemFont(ofSize: Config.daysFontSize,
                                                              weight: .black)
    
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
    
    private lazy var backgroundView: CountdownBackgroundView = {
        /// 背景渐变色根据事项颜色动态计算
        return CountdownBackgroundView(frame: view.bounds,
                                       themeColor: event.color ?? event.type.color)
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
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasPlayedEntryAnimation {
            /// 重新开始光晕呼吸，保证后台返回后动画仍在播放
            startDaysGlowPulse()
        } else {
            /// 转场结束后再播放入场动画，避免被弹出转场覆盖
            animateEntryIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 通知
    private func addNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    /// 回到前台：系统会移除后台期间的动画，需重新开始光晕呼吸
    @objc private func appWillEnterForeground() {
        guard hasPlayedEntryAnimation else {
            return
        }
        
        startDaysGlowPulse()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.frame = view.bounds
        layoutElements()
    }
    
    // MARK: - UI
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(titleLabel)
        view.addSubview(tipLabel)
        view.addSubview(dateLabel)
        view.addSubview(daysLabel)
        view.addSubview(closeButton)
        
        /// 事件颜色：用于天数光晕与单位文本
        let color = event.color ?? event.type.color
        
        /// 标题：表情 + 名称
        titleLabel.text = "\(event.emoji ?? event.type.emoji) \(event.displayName)"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 28.0, weight: .bold)
        titleLabel.textAlignment = .center
        
        /// 提示：未到期为“距离目标还有”，已过期为“已经过去”
        tipLabel.text = event.isExpired ? resGetString("Days Passed") : resGetString("Days Remaining")
        tipLabel.textColor = .white
        tipLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        tipLabel.textAlignment = .center
        
        /// 目标日期
        dateLabel.text = event.occuranceDate.displayText
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        dateLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        dateLabel.textAlignment = .center
        
        /// 天数：数值 + 单位组合为富文本，宽度不足时自动缩小字号
        let days = abs(event.remainingDays)
        daysLabel.attributedText = daysText(days: days, unitColor: color)
        daysLabel.textAlignment = .center
        daysLabel.numberOfLines = 1
        daysLabel.adjustsFontSizeToFitWidth = true
        daysLabel.minimumScaleFactor = Config.daysMinimumScaleFactor
        daysLabel.layer.shadowColor = color.cgColor
        daysLabel.layer.shadowRadius = 20.0
        daysLabel.layer.shadowOpacity = 0.5
        daysLabel.layer.shadowOffset = .zero
        
        /// 入场前隐藏，由入场动画显示
        [titleLabel, tipLabel, dateLabel, daysLabel, closeButton].forEach {
            $0.alpha = 0.0
        }
        
        /// 下滑关闭手势
        view.addGestureRecognizer(dismissPanGesture)
    }
    
    /// 天数文本（数值大字号 + 单位小字号，同一基线）
    private func daysText(days: Int, unitColor: UIColor) -> NSAttributedString {
        let text = NSMutableAttributedString(string: "\(days)",
                                             attributes: [.font: daysBaseFont,
                                                          .foregroundColor: UIColor.white])
        let unit = " " + resGetString(days == 1 ? "Day" : "Days")
        text.append(NSAttributedString(string: unit,
                                       attributes: [.font: Config.daysUnitFont,
                                                    .foregroundColor: unitColor.withAlphaComponent(0.8)]))
        return text
    }
    
    // MARK: - 布局
    private func layoutElements() {
        let width = view.bounds.width
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        
        /// 关闭按钮：左上角
        closeButton.size = Config.closeButtonSize
        closeButton.left = safeFrame.minX + Config.closeButtonMargins.left
        closeButton.top = safeFrame.minY + Config.closeButtonMargins.top
        
        /// 天数：整体垂直居中，左右保留间距，超出宽度由 adjustsFontSizeToFitWidth 缩放
        let daysHeight = ceil(daysBaseFont.lineHeight)
        let daysTop = view.bounds.midY - daysHeight / 2.0
        daysLabel.frame = CGRect(x: Config.daysHorizontalMargin,
                                 y: daysTop,
                                 width: max(0.0, width - Config.daysHorizontalMargin * 2.0),
                                 height: daysHeight)
        
        /// 提示：位于天数上方
        tipLabel.frame = CGRect(x: 0.0,
                                y: daysTop - 30.0,
                                width: width,
                                height: 20.0)
        
        /// 标题：位于提示上方
        titleLabel.frame = CGRect(x: 0.0,
                                  y: tipLabel.frame.minY - 46.0,
                                  width: width,
                                  height: 34.0)
        
        /// 日期：位于天数下方
        dateLabel.frame = CGRect(x: 0.0,
                                 y: daysLabel.frame.maxY + 10.0,
                                 width: width,
                                 height: 20.0)
    }
    
    // MARK: - 动画
    /// 播放入场动画（仅首次）
    private func animateEntryIfNeeded() {
        guard !hasPlayedEntryAnimation else {
            return
        }
        
        hasPlayedEntryAnimation = true
        
        /// 元素：自下而上淡入（天数最后出现）
        let elements: [UIView] = [titleLabel, tipLabel, dateLabel, closeButton, daysLabel]
        for (index, element) in elements.enumerated() {
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
        
        /// 天数光晕呼吸
        startDaysGlowPulse(delay: Config.entryAnimationDuration)
    }
    
    /// 天数光晕呼吸动画
    private func startDaysGlowPulse(delay: TimeInterval = 0.0) {
        daysLabel.layer.removeAnimation(forKey: AnimationKey.daysGlow)
        
        let pulse = CABasicAnimation(keyPath: "shadowOpacity")
        pulse.fromValue = Config.daysGlowMinOpacity
        pulse.toValue = Config.daysGlowMaxOpacity
        pulse.duration = Config.daysGlowAnimationDuration
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.beginTime = CACurrentMediaTime() + delay
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        daysLabel.layer.add(pulse, forKey: AnimationKey.daysGlow)
    }
    
    // MARK: - Event Response
    /// 关闭详情
    @objc private func clickClose(_ sender: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: nil)
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
