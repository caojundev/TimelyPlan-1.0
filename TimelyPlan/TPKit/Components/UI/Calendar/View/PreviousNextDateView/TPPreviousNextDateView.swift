//
//  PreviousNextDateView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/11.
//

import Foundation
import UIKit

protocol TPPreviousNextDateViewDelegate: AnyObject {
    
    /// 是否可以选中日期
    func prviousNextDateView(_ view: TPPreviousNextDateView, canSelectDate date: Date) -> Bool
    
    /// 选中日期回调
    func prviousNextDateView(_ view: TPPreviousNextDateView, didSelectDate date: Date)
}

extension TPPreviousNextDateViewDelegate {
    
    func prviousNextDateView(_ view: TPPreviousNextDateView, canSelectDate date: Date) -> Bool {
        return true
    }
}

class TPPreviousNextDateView: UIView, TPAnimatedContainerViewDelegate {

    weak var delegate: TPPreviousNextDateViewDelegate?

    /// 是否可以后退
    var canGoPrevious: Bool = true {
        didSet {
            previousButton.isEnabled = canGoPrevious
        }
    }
    
    /// 是否可以前进
    var canGoNext: Bool = true {
        didSet {
            nextButton.isEnabled = canGoNext
        }
    }

    /// 动画容器视图
    private var containerView: TPAnimatedContainerView!
    
    // 当前日期按钮
    private var currentButton: TPDefaultButton!

    // 上一天按钮
    private lazy var previousButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.titleConfig.font = UIFont.boldSystemFont(ofSize: 12.0)
        button.imageConfig.margins = .zero
        button.image = resGetImage("chevron_left_24")
        button.imageConfig.color = .label
        button.addTarget(self, action: #selector(didClickPrevious(_:)), for: .touchUpInside)
        return button
    }()

    // 下一天日期
    private lazy var nextButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.imageConfig.margins = .zero
        button.image = resGetImage("chevron_right_24")
        button.imageConfig.color = .label
        button.addTarget(self, action: #selector(didClickNext(_:)), for: .touchUpInside)
        return button
    }()
    
    var color: UIColor? = resGetColor(.title) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var layoutMargins: UIEdgeInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        currentButton = newCurrentButton()
        containerView = TPAnimatedContainerView(frame: bounds)
        containerView.alphaAnimationEnabled = true
        containerView.delegate = self
        containerView.setContentView(currentButton)
        addSubview(containerView)
        addSubview(previousButton)
        addSubview(nextButton)
        
        canGoPrevious = true
        canGoNext = true
        date = Date()
        updateCurrentDateTitle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds.inset(by: layoutMargins)
        
        previousButton.sizeToFit()
        previousButton.left = layoutFrame.minX
        previousButton.centerY = layoutFrame.midY
        
        nextButton.sizeToFit()
        nextButton.right = layoutFrame.maxX
        nextButton.centerY = layoutFrame.midY
        
        containerView.width = nextButton.left - previousButton.right
        containerView.height = height
        containerView.left = previousButton.right
        
        previousButton.imageConfig.color = color
        nextButton.imageConfig.color = color
        currentButton.titleConfig.textColor = color ?? .label
    }

    // MARK: - Set Date
    var dateRange: DateRange {
        return self.date.rangeOfThisDay()
    }
    
    fileprivate lazy var _date: Date = {
        return validDate(for: Date())
    }()
    
    var date: Date {
        get { return _date }
        set { setDate(newValue, animated: false) }
    }
    
    func setDate(_ date: Date, animated: Bool) {
        let date = validDate(for: date)
        guard canChange(fromDate: self.date, toDate: date) else {
            return
        }
        
        let previousDateRange = self.dateRange
        let previousDate = _date
        _date = date
        guard self.dateRange != previousDateRange else {
            return
        }
        
        /// 切换新当前日期按钮
        let title = title(for: date)
        currentButton = newCurrentButton(title: title)
        if animated {
            let style = SlideStyle.horizontalStyle(fromValue: previousDate, toValue: date)
            containerView.setContentView(currentButton, animateStyle: style)
        } else {
            containerView.setContentView(currentButton)
        }
        
        self.setNeedsLayout()
    }

    private func newCurrentButton(title: String? = nil) -> TPDefaultButton {
        let button = TPDefaultButton()
        button.title = title
        button.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        button.padding = .zero
        button.imagePosition = .right
        button.addTarget(self,
                         action: #selector(didClickCurrent(_:)),
                         for: .touchUpInside)
        return button
    }
    
    /// 更新当前日期标题
    func updateCurrentDateTitle() {
        currentButton.title = title(for: date)
        setNeedsLayout()
    }
    
    func didSelectDate(_ date: Date) {
        guard canChange(fromDate: _date, toDate: date) else {
            return
        }
        
        setDate(date, animated: true)
        delegate?.prviousNextDateView(self, didSelectDate: date)
    }
    
    // MARK: - 子类重写
    /// 日期的显示文本
    func title(for date: Date) -> String? {
        return nil
    }

    /// 验证 date 并返回一个合法的日期
    func validDate(for date: Date) -> Date {
        return date
    }
    
    /// 是否可以从 fromDate 切换到 toDate，默认为 true
    func canChange(fromDate: Date, toDate: Date) -> Bool {
        let canSelect = delegate?.prviousNextDateView(self, canSelectDate: toDate) ?? true
        return canSelect
    }
    
    func previousDate() -> Date? {
        return nil
    }
    
    func nextDate() -> Date? {
        return nil
    }
    
    // MARK: - Event Response
    @objc func didClickPrevious(_ button: UIButton) {
        if let toDate = previousDate() {
            TPImpactFeedback.impactWithLightStyle()
            didSelectDate(toDate)
        }
    }

    @objc func didClickNext(_ button: UIButton) {
        if let toDate = nextDate() {
            TPImpactFeedback.impactWithLightStyle()
            didSelectDate(toDate)
        }
    }

    @objc func didClickCurrent(_ button: UIButton) {
        TPImpactFeedback.impactWithLightStyle()
    }

    // MARK: - TPAnimatedContainerViewDelegate
    func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        contentView.sizeToFit()
        let x = (containerView.width - contentView.width) / 2.0
        let y = (containerView.height - contentView.height) / 2.0
        let w = contentView.width
        let h = contentView.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
