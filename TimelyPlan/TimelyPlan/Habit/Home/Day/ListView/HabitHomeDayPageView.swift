//
//  HabitHomeDayPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

class HabitHomeDayPageView: CalendarDatePageView {
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitHomeDayPageCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? HabitHomeDayPageCell else {
            return
        }
        
        let date = adapter.item(at: indexPath) as! Date
        cell.date = date
    }
}

class HabitHomeDayPageCell: CalendarDatePageCell {
    
    lazy var listView: HabitHomeDayListView = {
        let view = HabitHomeDayListView(frame:bounds)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(listView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.listView.frame = bounds
    }
}
