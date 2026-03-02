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
        button.addTarget(self,
                         action: #selector(clickStartDate),
                         for: .touchUpInside)
        return button
    }()
    
    /// 结束日期按钮
    lazy var endDateButton: HabitDateRangeInfoButton = {
        let button = HabitDateRangeInfoButton()
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
        self.padding = UIEdgeInsets(horizontal: 5.0, vertical: 10.0)
        self.updateInfo()
        self.separatorEdgeInset = UIEdgeInsets(horizontal: 10.0)
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
    
    var title: TextRepresentable? {
        get {
            return infoView.title
        }
        
        set {
            infoView.title = newValue
        }
    }
    
    var subtitle: TextRepresentable? {
        get {
            return infoView.subtitle
        }
        
        set {
            infoView.subtitle = newValue
        }
    }
    
    /// 信息视图
    private var infoView: TPInfoView = {
        let view = TPInfoView()
        view.padding = UIEdgeInsets(left: 15.0, right: 10.0)
        view.isUserInteractionEnabled = false
        view.titleConfig.font = .boldSystemFont(ofSize: 15.0)
        view.subtitleTopMargin = 8.0
        view.subtitleConfig.font = .boldSystemFont(ofSize: 12.0)
        view.subtitleLabel.alpha = 0.6
        return view
    }()
    
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
