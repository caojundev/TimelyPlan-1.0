//
//  MyDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation
import UIKit

// MARK: - MyDayTimelineView

class MyDayTimelineView: TimelineView {
    
    override func eventCellClass(for item: TimelineItem) -> AnyClass {
        guard let event = item.event else {
            return MyDayTodoTimelineCell.self
        }
        
        switch event.source {
        case .todo:
            return MyDayTodoTimelineCell.self
        case .focus:
            return MyDayFocusTimelineCell.self
        case .habit:
            return MyDayHabitTimelineCell.self
        }
    }
    
    override func configureEventCell(_ cell: TimelineCell, with item: TimelineItem) {
        // 根据不同类型进行特定配置
        if let todoCell = cell as? MyDayTodoTimelineCell {
            todoCell.configure(with: item)
        } else if let focusCell = cell as? MyDayFocusTimelineCell {
            focusCell.configure(with: item)
        } else if let habitCell = cell as? MyDayHabitTimelineCell {
            habitCell.configure(with: item)
        } else {
            cell.configure(with: item)
        }
    }
}
