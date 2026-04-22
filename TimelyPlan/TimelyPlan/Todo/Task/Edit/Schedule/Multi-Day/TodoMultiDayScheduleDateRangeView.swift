//
//  TodoMultiDayScheduleDateRangeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/21.
//

import Foundation
import UIKit

class TodoMultiDayScheduleDateRangeView: UIView {
    
    /// 编辑类型
    var editType: DateRangeEditType {
        get {
            return segmentedView.editType
        }
        
        set {
            segmentedView.editType = newValue
        }
    }
    
    var dateInfo: TaskDateInfo? {
        get {
            return segmentedView.dateInfo
        }
        
        set {
            segmentedView.dateInfo = newValue
        }
    }
    
    /// 选中编辑类型回调
    var didSelectEditType: ((DateRangeEditType) -> Void)? {
        get {
            return segmentedView.didSelectEditType
        }
        
        set {
            segmentedView.didSelectEditType = newValue
        }
    }
    
    private let segmentedViewHeight = 80.0
    
    private lazy var segmentedView: TodoScheduleDateSegmentedView = {
        let view = TodoScheduleDateSegmentedView()
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.padding = UIEdgeInsets(value: 10.0)
        addSubview(segmentedView)
        addSeparator(position: .bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        segmentedView.frame = self.layoutFrame()
        segmentedView.layer.cornerRadius = 12.0
    }
    
}

class TodoScheduleDateSegmentedView: TPDateRangeSegmentedView {
    
    var dateInfo: TaskDateInfo? {
        didSet {
            if let dateRange = dateInfo?.dateRange {
                self.dateRange = dateRange
            }
        }
    }
    
    override func canDeleteStartDate() -> Bool {
        return false
    }
    
    override func canDeleteEndDate() -> Bool {
        return false
    }
    
    override func startDateSubitle() -> String? {
        guard let dateInfo = dateInfo else {
            return nil
        }

        var subtitles = [String]()
        if dateInfo.isAllDay {
            subtitles.append(resGetString("All-Day"))
        } else {
            subtitles.append(dateInfo.startDate.timeString)
        }
        
        subtitles.append(dateInfo.dateRange.startDateDescription())
        return subtitles.joined(separator: " • ")
    }
    
    override func endDateSubitle() -> String? {
        guard let dateInfo = dateInfo else {
            return nil
        }

        var subtitles = [String]()
        if dateInfo.isAllDay {
            subtitles.append(resGetString("All-Day"))
        } else {
            subtitles.append(dateInfo.endDate.timeString)
        }
        
        subtitles.append(dateInfo.dateRange.lastsCountDescription())
        return subtitles.joined(separator: " • ")
    }
}
