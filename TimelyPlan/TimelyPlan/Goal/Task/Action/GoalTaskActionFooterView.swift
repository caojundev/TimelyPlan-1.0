//
//  GoalTaskActionFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation
import UIKit

protocol GoalTaskActionFooterViewDelegate: AnyObject {
    /// 点击专注
    func goalTaskActionFooterViewDidClickFocus(_ view: GoalTaskActionFooterView)
    
    /// 点击更多按钮
    func goalTaskActionFooterViewDidClickMore(_ view: GoalTaskActionFooterView)
}

/// 目标任务操作弹窗底部视图
class GoalTaskActionFooterView: UIView {
    
    /// 日期类型
    enum DateType: Int {
        case created
        case completed
    }
    
    /// 代理对象
    weak var delegate: GoalTaskActionFooterViewDelegate?
    
    /// 目标任务
    var task: GoalTask?
    
    /// 专注按钮
    private(set) lazy var focusButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.image = resGetImage("focus_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self,
                         action: #selector(clickFocus(_:)),
                         for: .touchUpInside)
        return button
    }()

    /// 日期标签
    private lazy var dateLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    /// 更多按钮
    private(set) lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    /// 日期信息
    private var dateInfo: (date: Date, type: DateType)? {
        guard let task = task else {
            return nil
        }
        
        if task.isCompleted, let completionDate = task.completionDate {
            return (completionDate, .completed)
        } else if let creationDate = task.creationDate {
            return (creationDate, .created)
        }
        
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        self.padding = UIEdgeInsets(horizontal: 16.0)
        addSubview(focusButton)
        addSubview(dateLabel)
        addSubview(moreButton)
        addSeparator(position: .top)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = safeLayoutFrame()
        focusButton.size = .size(8)
        focusButton.left = layoutFrame.minX
        focusButton.centerY = layoutFrame.midY
        
        moreButton.size = .size(8)
        moreButton.right = layoutFrame.maxX
        moreButton.centerY = layoutFrame.midY
        
        /// 让日期在剩余空间内居中显示
        dateLabel.width = layoutFrame.width - moreButton.width
        dateLabel.height = layoutFrame.height
        dateLabel.left = layoutFrame.minX + (layoutFrame.width - dateLabel.width) / 2.0
        dateLabel.top = layoutFrame.minY
    }
    
    /// 更新日期文本
    func updateDateInfo() {
        guard let dateInfo = dateInfo else {
            dateLabel.text = nil
            setNeedsLayout()
            return
        }
        
        let format: String
        if dateInfo.type == .created {
            format = resGetString("Created %@")
        } else {
            format = resGetString("Completed %@")
        }
        
        let dateString = dateInfo.date.yearMonthDayTimeString(omitYear: true,
                                                              showRelativeDate: true)
        dateLabel.text = String(format: format, dateString)
        setNeedsLayout()
    }
    
    // MARK: - Event Response
    @objc func clickFocus(_ button: UIButton) {
        delegate?.goalTaskActionFooterViewDidClickFocus(self)
    }
    
    @objc func clickMore(_ button: UIButton) {
        delegate?.goalTaskActionFooterViewDidClickMore(self)
    }
}
