//
//  TaskDateRangeView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/5/24.
//

import Foundation
import UIKit

class TaskDateRangeView: UIView {
    
    let margin = 8.0
    
    /// 日期范围
    var dateRange: DateRange = DateRange() {
        didSet {
            updateInfo()
        }
    }
    
    var canDeleteStart: Bool = false
    var canDeleteEnd: Bool = true

    /// 结束编辑回调
    var didEndEditing: ((DateRange) -> ())?

    /// 开始日期按钮
    lazy var startDateButton: TaskDateRangeInfoButton = {
        let button = TaskDateRangeInfoButton()
        button.headerText = resGetString("Start Date")
        button.addTarget(self,
                         action: #selector(clickStartDate),
                         for: .touchUpInside)
        return button
    }()
    
    /// 结束日期按钮
    lazy var endDateButton: TaskDateRangeInfoButton = {
        let button = TaskDateRangeInfoButton()
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
        let vc = TaskDateRangeEditViewController(dateRange: dateRange,
                                                  editType: type)
        vc.canDeleteStart = canDeleteStart
        vc.canDeleteEnd = canDeleteEnd
        vc.didEndEditing = { dateRange in
            self.dateRange = dateRange
            self.didEndEditing?(dateRange)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
}

class TaskDateRangeInfoButton: TPBaseButton {
    
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
    private var infoView: TPDateRangeInfoView = {
        let view = TPDateRangeInfoView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.padding = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 5.0)
        self.contentView.addSubview(infoView)
        self.normalBackgroundColor = .primary
        self.selectedBackgroundColor = .primary.darkerColor
        self.infoView.headerTextColor = Color(0xFFFFFF, 0.7)
        self.infoView.titleTextColor = Color(0xFFFFFF, 0.9)
        self.infoView.subtitleTextColor = Color(0xFFFFFF, 0.8)
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
