//
//  TodoMultiDayScheduleDateRangeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/21.
//

import Foundation
import UIKit

class TodoMultiDayScheduleDateRangeView: UIView {
    
    let segmentedViewHeight = 80.0
    
    private(set) lazy var segmentedView: TodoScheduleDateSegmentedView = {
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

class TodoScheduleDateSegmentedView: HabitDateRangeSegmentedView {
    
    override func canDeleteStartDate() -> Bool {
        return false
    }
    
    override func canDeleteEndDate() -> Bool {
        return false
    }
    
}
