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
        /// 天数自适应最小字号
        static let daysMinimumFontSize: CGFloat = 40.0
        /// 天数区域与屏幕两侧最小间距
        static let daysHorizontalMargin: CGFloat = 24.0
        /// 天数与单位间距
        static let daysUnitSpacing: CGFloat = 8.0
        /// 天数与单位底部对齐偏移比例（相对于天数字号）
        static let daysUnitBottomOffsetRatio: CGFloat = 0.25
    }
    
    // MARK: - 数据
    /// 倒数日事项
    let event: CountdownEvent
    
    // MARK: - 视图
    private let titleLabel = UILabel()
    private let tipLabel = UILabel()
    private let dateLabel = UILabel()
    private let daysLabel = UILabel()
    private let daysUnitLabel = UILabel()
    
    /// 天数基础字体（按可用宽度自适应缩放）
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
        return CountdownBackgroundView(frame: view.bounds)
    }()
    
    /// 下滑关闭手势
    private lazy var dismissPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(handleDismissPanGesture(_:)))
        return gesture
    }()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateEntry()
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
        view.addSubview(daysUnitLabel)
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
        
        /// 天数
        let days = abs(event.remainingDays)
        daysLabel.text = "\(days)"
        daysLabel.textColor = .white
        daysLabel.font = daysBaseFont
        daysLabel.textAlignment = .center
        /// 数字过大时自动缩小字号（布局阶段会按宽度精确计算）
        daysLabel.adjustsFontSizeToFitWidth = true
        daysLabel.minimumScaleFactor = Config.daysMinimumFontSize / Config.daysFontSize
        daysLabel.layer.shadowColor = color.cgColor
        daysLabel.layer.shadowRadius = 20.0
        daysLabel.layer.shadowOpacity = 0.5
        daysLabel.layer.shadowOffset = .zero
        
        /// 天数单位
        daysUnitLabel.text = resGetString(days == 1 ? "Day" : "Days")
        daysUnitLabel.textColor = color.withAlphaComponent(0.8)
        daysUnitLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        daysUnitLabel.textAlignment = .center
        
        /// 入场前隐藏，由入场动画显示
        [titleLabel, tipLabel, dateLabel, daysLabel, daysUnitLabel, closeButton].forEach {
            $0.alpha = 0.0
        }
        
        /// 下滑关闭手势
        view.addGestureRecognizer(dismissPanGesture)
    }
    
    // MARK: - 布局
    private func layoutElements() {
        let width = view.bounds.width
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        
        /// 关闭按钮：左上角
        closeButton.size = Config.closeButtonSize
        closeButton.left = safeFrame.minX + Config.closeButtonMargins.left
        closeButton.top = safeFrame.minY + Config.closeButtonMargins.top
        
        /// 天数：整体垂直居中，超出可用宽度时自动缩小字号
        let daysCenterY = view.bounds.midY
        
        let unitText = daysUnitLabel.text ?? ""
        let unitFont = daysUnitLabel.font ?? .systemFont(ofSize: 20.0, weight: .medium)
        let unitWidth = ceil(unitText.width(with: unitFont))
        let unitHeight = ceil(unitFont.lineHeight)
        /// 数字可用宽度：屏幕宽度去掉两侧间距与单位占用宽度
        let availableWidth = max(0.0, width - Config.daysHorizontalMargin * 2.0)
        let numberMaxWidth = max(0.0, availableWidth - unitWidth - Config.daysUnitSpacing)
        
        let numberText = daysLabel.text ?? ""
        let numberFont = daysBaseFont.fittingFont(for: numberText,
                                                  maxWidth: numberMaxWidth,
                                                  minimumSize: Config.daysMinimumFontSize)
        daysLabel.font = numberFont
        let numberWidth = min(ceil(numberText.width(with: numberFont)), numberMaxWidth)
        let numberHeight = ceil(numberFont.lineHeight)
        let numberTop = daysCenterY - numberHeight / 2.0
        
        /// 数字与单位作为整体水平居中
        let contentWidth = numberWidth + Config.daysUnitSpacing + unitWidth
        let contentLeft = max(Config.daysHorizontalMargin, (width - contentWidth) / 2.0)
        
        daysLabel.frame = CGRect(x: contentLeft,
                                 y: numberTop,
                                 width: numberWidth,
                                 height: numberHeight)
        
        /// 单位：紧贴数字右侧，底部与数字基线对齐
        let unitBottomOffset = numberFont.pointSize * Config.daysUnitBottomOffsetRatio
        daysUnitLabel.frame = CGRect(x: daysLabel.frame.maxX + Config.daysUnitSpacing,
                                     y: daysLabel.frame.maxY - unitBottomOffset - unitHeight,
                                     width: unitWidth,
                                     height: unitHeight)
        
        /// 提示：位于天数上方
        tipLabel.frame = CGRect(x: 0.0,
                                y: numberTop - 30.0,
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
    
    // MARK: - 入场动画
    private func animateEntry() {
        let elements = [titleLabel, tipLabel, daysLabel, daysUnitLabel, dateLabel, closeButton]
        for (index, element) in elements.enumerated() {
            element.transform = CGAffineTransform(translationX: 0.0, y: 20.0)
            UIView.animate(withDuration: 0.6,
                           delay: 0.05 * Double(index),
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5) {
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

// MARK: - 字号自适应
private extension UIFont {
    
    /// 使用相同字形特征创建指定字号的字体
    func sameStyleFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(descriptor: fontDescriptor.withSize(size), size: size)
    }
    
    /// 计算能容纳指定文本的最大字号（不低于最小字号）
    /// - Parameters:
    ///   - text: 文本
    ///   - maxWidth: 可用宽度
    ///   - minimumSize: 最小字号
    /// - Returns: 适配后的字体
    func fittingFont(for text: String, maxWidth: CGFloat, minimumSize: CGFloat) -> UIFont {
        guard maxWidth > 0.0, text.count > 0 else {
            return self
        }
        
        /// 二分查找最大可用字号
        var minimum = min(minimumSize, pointSize)
        var maximum = pointSize
        var fittedSize = minimum
        
        while maximum - minimum > 0.5 {
            let size = (minimum + maximum) / 2.0
            if text.width(with: sameStyleFont(ofSize: size)) <= maxWidth {
                fittedSize = size
                minimum = size
            } else {
                maximum = size
            }
        }
        
        return sameStyleFont(ofSize: fittedSize)
    }
}
