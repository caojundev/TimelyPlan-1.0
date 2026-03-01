//
//  HabitDateRangeView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/5/24.
//

import Foundation
import UIKit

class HabitDateRangeView: UIView {
    
    let itemMargin = 10.0
    
    /// 日期范围
    var dateRange: DateRange = DateRange() {
        didSet {
            updateInfo()
        }
    }

    /// 结束编辑回调
    var didEndEditing: ((DateRange) -> ())?

    /// 开始日期按钮
    lazy var startDateButton: HabitDateRangeInfoButton = {
        let button = HabitDateRangeInfoButton()
        button.headerLabel.text = resGetString("Start Date")
        button.headerLabel.textAlignment = .left
        button.dateLabel.textAlignment = .left
        button.infoLabel.textAlignment = .left
        button.addTarget(self,
                         action: #selector(clickStartDate),
                         for: .touchUpInside)
        return button
    }()
    
    /// 结束日期按钮
    lazy var endDateButton: HabitDateRangeInfoButton = {
        let button = HabitDateRangeInfoButton()
        button.headerLabel.text = resGetString("End Date")
        button.addTarget(self,
                         action: #selector(clickEndDate),
                         for: .touchUpInside)
        return button
    }()
    
    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = resGetImage("habit_dateRange_arrow")
        imageView.updateImage(withColor: Color(0x888888, 0.2))
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.arrowImageView)
        self.addSubview(self.startDateButton)
        self.addSubview(self.endDateButton)
        self.padding = UIEdgeInsets(horizontal: 16.0, vertical: 20.0)
        self.updateInfo()
        self.separatorEdgeInset = UIEdgeInsets(horizontal: 20.0)
        self.addSeparator(position: .bottom, color: Color(0x888888, 0.1))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        arrowImageView.width = 20.0
        arrowImageView.height = layoutFrame.height
        arrowImageView.top = layoutFrame.minY
        arrowImageView.centerX = layoutFrame.midX
        
        let buttonWidth = (layoutFrame.width - arrowImageView.width) / 2.0
        startDateButton.width = buttonWidth
        startDateButton.height = layoutFrame.height
        startDateButton.origin = layoutFrame.origin
        
        endDateButton.sizeEqualToView(startDateButton)
        endDateButton.topEqualToView(startDateButton)
        endDateButton.right = layoutFrame.maxX
    }
    
    // MARK: - Update
    func updateInfo() {
        startDateButton.dateText = dateRange.startDateText()
        startDateButton.infoLabel.text = dateRange.startDateDescription()
        endDateButton.dateText = dateRange.endDateText()
        endDateButton.infoLabel.text = dateRange.lastsCountDescription()
    }
    
    // MARK: - Event Response
    @objc func clickStartDate() {
        TPImpactFeedback.impactWithLightStyle()
        editDateRangeWithType(.start)
    }

    @objc func clickEndDate() {
        TPImpactFeedback.impactWithLightStyle()
        editDateRangeWithType(.end)
    }

    // MARK: - Edit
    func editDateRangeWithType(_ type: DateRangeEditType) {
        let vc = HabitDateRangeEditViewController(dateRange: dateRange,
                                                  editType: type)
        vc.didEndEditing = { dateRange in
            self.dateRange = dateRange
            self.didEndEditing?(dateRange)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
}

class HabitDateRangeInfoButton: TPBaseButton {

    var dateText: String? {
        didSet {
            dateLabel.text = dateText
            setNeedsLayout()
        }
    }

    var dateLabel: TPLabel {
        return infoView.dateLabel
    }
    
    var headerLabel: TPLabel {
        return infoView.headerLabel
    }
    
    var infoLabel: TPLabel {
        return infoView.infoLabel
    }
    
    private let infoView = HabitDateRangeInfoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(infoView)
        self.normalBackgroundColor = .clear
        self.selectedBackgroundColor = .clear
        self.preferredTappedScale = 0.95
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = layoutFrame()
    }
}

class HabitDateRangeInfoView: UIView {

    var dateText: String? {
        didSet {
            dateLabel.text = dateText
            setNeedsLayout()
        }
    }
    
    /// 日期标签
    lazy var dateLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SYSTEM_FONT
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = resGetColor(.title)
        return label
    }()
    
    lazy var headerLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = resGetColor(.title)
        label.alpha = 0.8
        return label
    }()
    
    lazy var infoLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 10.0)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.headerLabel)
        self.addSubview(self.dateLabel)
        self.addSubview(self.infoLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        headerLabel.width = layoutFrame.width
        headerLabel.height = layoutFrame.height * 0.25
        headerLabel.top = layoutFrame.minY
        headerLabel.left = layoutFrame.minX
        
        dateLabel.width = layoutFrame.width
        dateLabel.height = layoutFrame.height * 0.5
        dateLabel.left = layoutFrame.minX
        dateLabel.top = headerLabel.bottom
    
        infoLabel.width = layoutFrame.width
        infoLabel.height = layoutFrame.height * 0.25
        infoLabel.left = layoutFrame.minX
        infoLabel.top = dateLabel.bottom
    }
}
