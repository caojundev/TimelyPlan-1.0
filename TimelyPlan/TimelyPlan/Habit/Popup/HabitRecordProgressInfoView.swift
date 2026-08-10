//
//  HabitRecordProgressInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/7.
//

import Foundation
import UIKit

class HabitRecordProgressInfoView: UIView, TPCustomPopupContent {
    
    let task: HabitTask
    
    let record: HabitRecord
    
    let change: HabitRecordChange
    
    let date: Date
    
    private let detailProvider = HabitTaskDetailProvider()
    private let infoView = HabitTaskProgressInfoView()
    private lazy var valueLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 13.0)
        label.textColor = .label
        label.textAlignment = .center
        label.backgroundColor = task.color.withAlphaComponent(0.2)
        label.textColor = task.color
        label.clipsToBounds = true
        label.edgeInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 2.0, right: 8.0)
        return label
    }()
    
    var maximumWidth: CGFloat {
        return 560.0
    }
    
    init(task: HabitTask,
         record: HabitRecord,
         change: HabitRecordChange,
         date: Date) {
        self.task = task
        self.record = record
        self.change = change
        self.date = date
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.backgroundColor = Color(light: 0xFFFFFF, dark: 0x232323)
        self.padding = UIEdgeInsets(left: 16.0, right: 16.0)
        addSubview(infoView)
        addSubview(valueLabel)
        updateInfo()
        updateValue()
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        valueLabel.sizeToFit()
        valueLabel.layer.cornerRadius = valueLabel.halfHeight
        valueLabel.right = layoutFrame.maxX
        valueLabel.centerY = layoutFrame.midY
        
        infoView.width = valueLabel.left - layoutFrame.minX
        infoView.height = layoutFrame.height
        infoView.origin = layoutFrame.origin
    }
    
    private func updateInfo() {
        infoView.iconView.icon = task.icon
        infoView.iconView.font = .boldSystemFont(ofSize: 24.0)
        infoView.titleView.title = task.displayName
        
        
        let subtitle = detailProvider.detail(for: task,
                                                on: date,
                                                with: record,
                                                color: .secondaryLabel,
                                                addToMyDayIncluded: false)
        infoView.titleView.subtitle = subtitle
        
        let status = task.status(with: record)
        infoView.statusView.setStatus(status)
    
        /// 更新进度
        let progressView = infoView.progressView
        progressView.backLineColor = Color(0x000000, 0.4)
        progressView.progressLineColor = task.color
        progressView.progress = task.progress(with: record)
    }
    
    private func updateValue() {
        guard case let .amountChanged(oldValue, newValue) = change else {
            return
        }
        
        let value = newValue - oldValue
        if value >= 0 {
            valueLabel.text = "+\(value)"
        } else {
            valueLabel.text = "\(value)"
        }
    }
}
