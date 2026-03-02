//
//  HabitDateRangeView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/5/24.
//

import Foundation
import UIKit

class HabitDateRangeView: UIView {
    
    let margin = 8.0
    
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
        button.headerText = resGetString("Start Date")
        button.addTarget(self,
                         action: #selector(clickStartDate),
                         for: .touchUpInside)
        return button
    }()
    
    /// 结束日期按钮
    lazy var endDateButton: HabitDateRangeInfoButton = {
        let button = HabitDateRangeInfoButton()
        button.headerText = resGetString("End Date")
        button.addTarget(self,
                         action: #selector(clickEndDate),
                         for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(value: margin)
        self.addSubview(self.startDateButton)
        self.addSubview(self.endDateButton)
        self.updateInfo()
        self.addSeparator(position: .bottom, color: Color(0x888888, 0.1))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        let buttonWidth = (layoutFrame.width - margin) / 2.0
        startDateButton.width = buttonWidth
        startDateButton.height = layoutFrame.height
        startDateButton.origin = layoutFrame.origin
        
        endDateButton.sizeEqualToView(startDateButton)
        endDateButton.topEqualToView(startDateButton)
        endDateButton.right = layoutFrame.maxX
    }
    
    // MARK: - Update
    func updateInfo() {
        startDateButton.title = dateRange.startDateText()
        startDateButton.subtitle = dateRange.startDateDescription()
        endDateButton.title = dateRange.endDateText()
        endDateButton.subtitle = dateRange.lastsCountDescription()
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
    
    var headerText: String? {
        get {
            return infoView.headerLabel.text
        }
        
        set {
            infoView.headerLabel.text = newValue
        }
    }
    
    var title: TextRepresentable? {
        get {
            return infoView.detailTitle
        }
        
        set {
            infoView.detailTitle = newValue
        }
    }
    
    var subtitle: TextRepresentable? {
        get {
            return infoView.detailSubtitle
        }
        
        set {
            infoView.detailSubtitle = newValue
        }
    }

    /// 信息视图
    private var infoView: HabitDateRangeInfoView = {
        let view = HabitDateRangeInfoView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.padding = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 5.0)
        self.contentView.addSubview(infoView)
        self.normalBackgroundColor = Color(0xcccccc, 0.1)
        self.selectedBackgroundColor = Color(0xcccccc, 0.2)
        self.borderWidth = 1.0
        self.normalBorderColor = Color(0xcccccc, 0.2)
        self.selectedBorderColor = Color(0xcccccc, 0.4)
        self.cornerRadius = 8.0
        self.preferredTappedScale = 0.95
        self.scaleMaxLength = 8.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = contentView.layoutFrame()
    }
}

class HabitDateRangeInfoView: UIView {
    
    var detailTitle: TextRepresentable? {
        get {
            return detailView.title
        }
        
        set {
            detailView.title = newValue
        }
    }
    
    var detailSubtitle: TextRepresentable? {
        get {
            return detailView.subtitle
        }
        
        set {
            detailView.subtitle = newValue
        }
    }
    
    private(set) lazy var headerLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = resGetColor(.title)
        label.alpha = 0.8
        return label
    }()
    
    /// 详细视图
    private(set) var detailView: TPInfoView = {
        let view = TPInfoView()
        view.isUserInteractionEnabled = false
        view.titleConfig.font = .boldSystemFont(ofSize: 15.0)
        view.titleConfig.adjustsFontSizeToFitWidth = true
        view.subtitleTopMargin = 8.0
        view.subtitleConfig.font = .boldSystemFont(ofSize: 12.0)
        view.subtitleLabel.alpha = 0.6
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.headerLabel)
        self.addSubview(self.detailView)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        headerLabel.width = layoutFrame.width
        headerLabel.height = layoutFrame.height * 0.4
        headerLabel.top = layoutFrame.minY
        headerLabel.left = layoutFrame.minX
        
        detailView.width = layoutFrame.width
        detailView.height = layoutFrame.height - headerLabel.height
        detailView.left = layoutFrame.minX
        detailView.top = headerLabel.bottom
    }
}
