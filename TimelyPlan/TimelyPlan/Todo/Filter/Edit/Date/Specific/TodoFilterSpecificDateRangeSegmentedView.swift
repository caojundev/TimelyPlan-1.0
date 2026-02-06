//
//  TodoFilterSpecificDateRangeSegmentedView.swift
//  iTimeFlow
//
//  Created by caojun on 2024/1/13.
//

import Foundation
import UIKit

class TodoFilterSpecificDateRangeSegmentedView: UIView {
    
    /// 点击删除
    var didClickDelete: ((DateRangeEditType) -> Void)?
    
    /// 选中编辑类型回调
    var didSelectEditType: ((DateRangeEditType) -> Void)?
    
    /// 编辑类型
    var editType: DateRangeEditType = .end {
        didSet {
            updateSelectedButton()
        }
    }
    
    /// 日期范围
    var dateRange: DateRange? {
        didSet {
            updateDate()
        }
    }
    
    var isDeleteButtonHidden: Bool = false {
        didSet {
            startDateButton.isDeleteButtonHidden = isDeleteButtonHidden
            endDateButton.isDeleteButtonHidden = isDeleteButtonHidden
        }
    }

    var cornerRadius: CGFloat = 8.0 {
        didSet {
            if cornerRadius != oldValue {
                startDateButton.cornerRadius = cornerRadius
                endDateButton.cornerRadius = cornerRadius
            }
        }
    }
    
    /// 开始日期
    private lazy var startDateButton: DateRangeSegmentedButton = {
        let button = DateRangeSegmentedButton(style: .start)
        button.cornerRadius = cornerRadius
        button.addTarget(self, action: #selector(clickStart(_:)), for: .touchUpInside)
        button.didClickDelete = { [weak self] in
            self?.didClickDelete?(.start)
        }
        
        return button
    }()
    
    /// 结束日期
    private lazy var endDateButton: DateRangeSegmentedButton = {
        let button = DateRangeSegmentedButton(style: .due)
        button.cornerRadius = cornerRadius
        button.didClickDelete = { [weak self] in
            self?.didClickDelete?(.end)
        }
        
        button.addTarget(self, action: #selector(clickEnd(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(startDateButton)
        addSubview(endDateButton)
        updateSelectedButton()
        updateDate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margin = 6.0
        let buttonWidth = (width - margin) / 2.0
        startDateButton.width = buttonWidth
        startDateButton.height = height
        endDateButton.size = startDateButton.size
        endDateButton.right = width
    }

    /// 更新选中按钮
    private func updateSelectedButton() {
        startDateButton.isSelected = editType == .start
        endDateButton.isSelected = editType == .end
    }
    
    /// 更新日期
    private func updateDate() {
        let isAllDay = dateRange?.isAllDay() ?? false
        startDateButton.isAllDay = isAllDay
        startDateButton.date = dateRange?.startDate
        startDateButton.isDeleteButtonHidden = isDeleteButtonHidden
        startDateButton.reloadData()
        
        endDateButton.isAllDay = isAllDay
        endDateButton.isDeleteButtonHidden = isDeleteButtonHidden
        endDateButton.date = dateRange?.endDate
        endDateButton.reloadData()
        setNeedsLayout()
    }
    
    // MARK: - Event Response
    @objc func clickStart(_ button: UIButton){
        if editType != .start {
            TPImpactFeedback.impactWithSoftStyle()
            editType = .start
            didSelectEditType?(.start)
        }
    }
    
    @objc func clickEnd(_ button: UIButton){
        if editType != .end {
            TPImpactFeedback.impactWithSoftStyle()
            editType = .end
            didSelectEditType?(.end)
        }
    }
}

class DateRangeSegmentedButton: TPBaseButton {
    
    enum Style {
        case start
        case due
    }
    
    /// 样式
    let style: Style
    
    /// 点击删除按钮回调
    var didClickDelete: (() -> Void)?
    
    /// 日期
    var date: Date?
    
    /// 是否为全天
    var isAllDay: Bool = false
    
    /// 使用隐藏删除按钮
    var isDeleteButtonHidden: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 删除按钮
    private lazy var deleteButton: TPImageButton = {
        let button = TPImageButton()
        button.padding = .zero
        button.hitTestEdgeInsets = UIEdgeInsets(value: -8.0)
        button.normalImage = resGetImage("xmark_16")
        button.normalImageColor = resGetColor(.title)
        button.selectedImageColor = .white
        button.addTarget(self, action: #selector(clickDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 是否显示删除按钮
    var shouldShowDelete: Bool {
        guard !isDeleteButtonHidden else {
            return false
        }
        
        return date != nil
    }
    
    /// 信息视图
    private var infoView: TPImageInfoView = {
        let view = TPImageInfoView()
        view.isUserInteractionEnabled = false
        view.titleConfig.font = SYSTEM_FONT
        view.titleConfig.adjustsFontSizeToFitWidth = true
        view.titleConfig.textColor = resGetColor(.title)
        view.titleConfig.selectedTextColor = .white
        
        view.subtitleConfig.font = SMALL_SYSTEM_FONT
        view.subtitleConfig.adjustsFontSizeToFitWidth = true
        view.subtitleConfig.textColor = view.titleConfig.textColor
        view.subtitleConfig.selectedTextColor = view.titleConfig.selectedTextColor
        
        view.imageConfig.color = view.titleConfig.textColor
        view.imageConfig.selectedColor = view.titleConfig.selectedTextColor
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            infoView.isSelected = isSelected
            deleteButton.isSelected = isSelected
        }
    }
    
    convenience init(style: Style = .start) {
        self.init(frame: .zero, style: style)
    }
    
    init(frame: CGRect, style: Style = .start) {
        self.style = style
        super.init(frame: frame)
        self.normalBackgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundColor = .primary
        self.preferredTappedScale = 1.0
        self.scaleMaxLength = 0.0
        self.addSubview(deleteButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.isUserInteractionEnabled = true
        contentView.addSubview(infoView)
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let shouldShowDelete = shouldShowDelete
        if shouldShowDelete {
            self.padding = UIEdgeInsets(horizontal: 8.0)
        } else {
            self.padding = UIEdgeInsets(horizontal: 4.0)
        }
        
        let layoutFrame = layoutFrame()
        /// 删除按钮布局
        deleteButton.size = .size(4)
        deleteButton.centerY = layoutFrame.midY
        if shouldShowDelete {
            deleteButton.isHidden = false
            deleteButton.right = layoutFrame.maxX
        } else {
            deleteButton.isHidden = true
            deleteButton.left = layoutFrame.maxX
        }
        
        /// 信息视图
        let infoWidth = deleteButton.left - layoutFrame.minX
        infoView.width = bounds.width
        infoView.sizeToFit()
        infoView.width = min(infoView.width, infoWidth)
        infoView.centerX = layoutFrame.minX + infoWidth / 2.0
        infoView.alignVerticalCenter()
    }
    
    func reloadData() {
        if let date = date {
            infoView.title = date.yearMonthDayString(omitYear: true, showRelativeDate: false)
            infoView.subtitle = date.weekdaySymbol(style: .short)
            infoView.imageConfig.size = .zero
            infoView.imageContent = nil
        } else {
            if style == .start {
                infoView.title = resGetString("Start Date")
            } else {
                infoView.title = resGetString("End Date")
            }
            
            infoView.subtitle = nil
            infoView.imageConfig.size = .mini
            infoView.imageContent = .withName("plus_24")
        }
        
        /// 重新布局
        setNeedsLayout()
    }
    
    @objc func clickDelete(_ button: UIButton){
        didClickDelete?()
    }
}
