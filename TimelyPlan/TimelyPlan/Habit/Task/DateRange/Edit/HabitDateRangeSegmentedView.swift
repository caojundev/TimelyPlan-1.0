//
//  HabitDateRangeSegmentedView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/13.
//

import Foundation
import QuartzCore
import UIKit

class HabitDateRangeSegmentedView: UIView {
    
    /// 编辑类型
    var editType: DateRangeEditType = .end {
        didSet {
            updateSelectedButton()
        }
    }
    
    /// 日期范围
    var dateRange: DateRange = DateRange() {
        didSet {
            updateDate()
        }
    }
    
    /// 点击删除
    var didClickDelete: ((DateRangeEditType) -> Void)?
    
    /// 选中编辑类型回调
    var didSelectEditType: ((DateRangeEditType) -> Void)?
    
    /// 箭头宽度
    private let arrowWidth = 20.0

    /// 开始日期
    lazy var startDateButton: HabitDateRangeSegmentedButton = {
        let button = HabitDateRangeSegmentedButton(style: .start)
        button.addTarget(self, action: #selector(clickStart(_:)), for: .touchUpInside)
        button.didClickDelete = { [weak self] in
            self?.didClickDelete?(.start)
        }
        
        return button
    }()
    
    /// 截止日期
    lazy var endDateButton: HabitDateRangeSegmentedButton = {
        let button = HabitDateRangeSegmentedButton(style: .end)
        button.didClickDelete = { [weak self] in
            self?.didClickDelete?(.end)
        }
        
        button.addTarget(self, action: #selector(clickEnd(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemFill
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
        startDateButton.width = halfWidth + arrowWidth / 2.0
        startDateButton.height = height
        endDateButton.size = startDateButton.size
        endDateButton.right = width
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 80.0)
    }
    
    /// 更新选中按钮
    private func updateSelectedButton() {
        startDateButton.isSelected = editType == .start
        endDateButton.isSelected = !startDateButton.isSelected
    }
    
    /// 更新日期
    private func updateDate() {
        startDateButton.dateText = dateRange.startDateText()
        startDateButton.dateDescription = dateRange.startDateDescription()
        startDateButton.showDelete = false
        
        endDateButton.dateText = dateRange.endDateText()
        endDateButton.dateDescription = dateRange.lastsCountDescription()
        endDateButton.showDelete = dateRange.endDate != nil
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

class HabitDateRangeSegmentedButton: UIButton {
    
    enum Style {
        case start
        case end
    }
    
    /// 样式
    var style: Style = .start
    
    /// 点击删除按钮回调
    var didClickDelete: (() -> Void)?
    
    var showDelete: Bool = false
    
    var dateText: String? {
        get {
            return infoView.dateLabel.text
        }
        
        set {
            infoView.dateLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    var dateDescription: String? {
        get {
            return infoView.infoLabel.text
        }
        
        set {
            infoView.infoLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    /// 正常背景色
    var normalBackgroundColor = Color(0xaaaaaa, 0.1)
    
    /// 选中背景颜色
    var selectedBackgroundColor = UIColor.primary

    /// 背景图片视图
    private var backgroundImageView = UIImageView()
    
    /// 删除按钮
    private lazy var deleteButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("xmark_circle_fill_24")
        button.imageSize = .size(6)
        button.addTarget(self, action: #selector(clickDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 信息视图
    private var infoView: HabitDateRangeInfoView = {
        let view = HabitDateRangeInfoView()
        view.isUserInteractionEnabled = false
        view.headerLabel.alpha = 0.8
        view.infoLabel.alpha = 0.6
        return view
    }()
    
    convenience init(style: Style = .start) {
        self.init(frame: .zero, style: style)
    }
    
    init(frame: CGRect, style: Style = .start) {
        self.style = style
        super.init(frame: frame)
        self.addSubview(backgroundImageView)
        self.addSubview(infoView)
        self.addSubview(deleteButton)
        var backgroundImage: UIImage?
        if style == .start {
            let image = resGetImage("habit_dateRange_background_start")
            backgroundImage = image?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 40)
            self.padding = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 25.0)
            self.infoView.headerLabel.text = resGetString("Start Date")
        } else {
            let image = resGetImage("habit_dateRange_background_end")
            backgroundImage = image?.stretchableImage(withLeftCapWidth: 30, topCapHeight: 40)
            self.padding = UIEdgeInsets(top: 5.0, left: 25.0, bottom: 5.0, right: 10.0)
            self.infoView.headerLabel.text = resGetString("End Date")
        }
    
        self.backgroundImageView.image = backgroundImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundImageView.frame = bounds
        let layoutFrame = layoutFrame()
        /// 删除按钮布局
        self.deleteButton.size = .size(6)
        self.deleteButton.centerY = layoutFrame.midY
        if showDelete {
            self.deleteButton.isHidden = false
            self.deleteButton.right = layoutFrame.maxX
        } else {
            self.deleteButton.isHidden = true
            self.deleteButton.left = layoutFrame.maxX
        }
        
        /// 信息视图
        self.infoView.width = deleteButton.left - layoutFrame.minX
        self.infoView.height = layoutFrame.height
        self.infoView.left = layoutFrame.minX
        self.infoView.alignVerticalCenter()
        
        /// 更新颜色
        self.updateColor()
    }
    
    private func updateColor() {
        /// 更新颜色
        let backgroundColor = isSelected ? selectedBackgroundColor : normalBackgroundColor
        self.backgroundImageView.updateImage(withColor: backgroundColor)
        
        let color: UIColor = isSelected ? .white : resGetColor(.title)
        self.deleteButton.normalImageColor = color
        self.infoView.headerLabel.textColor = color
        self.infoView.dateLabel.textColor = color
        self.infoView.infoLabel.textColor = color
    }
    
    @objc func clickDelete(_ button: UIButton){
        didClickDelete?()
    }
}
