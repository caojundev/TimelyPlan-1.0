//
//  HabitHomeWeekListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

protocol HabitHomeWeekListViewDelegate: AnyObject {
    
    /// 点击更多
    func habitHomeWeekListView(_ listView: HabitHomeWeekListView,
                               didClickMore button: UIButton,
                               forTask task: HabitTask)
}

class HabitHomeWeekListView: HabitTaskBaseListView,
                                HabitHomeWeekListCellDelegate {
    
    weak var delegate: HabitHomeWeekListViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupData() {
        self.sectionLayout.preferredItemHeight = 210.0
    }
    
    override func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        let group = HabitTaskGroup(identifier: "anytime")
        group.iconName = "habit_time_morning_24"
        group.name = "测试分组"
        group.tasks = habit.activeTasks()
        return [group]
    }
    
    // MARK: - HabitHomeWeekListCellDelegate
    func habitHomeWeekListCell(_ cell: HabitHomeWeekListCell, didClickMore button: UIButton) {
        guard let task = cell.task else {
            return
        }
        
        self.delegate?.habitHomeWeekListView(self,
                                             didClickMore: button,
                                             forTask: task)
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitHomeWeekListCell.self
    }

    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let task = adapter.item(at: indexPath) as! HabitTask
        let cell = cell as! HabitHomeWeekListCell
        cell.delegate = self
        cell.task = task
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Header
    override func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        return HabitTaskListGroupHeaderView.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        if let headerView = headerView as? HabitTaskListGroupHeaderView {
            headerView.group = adapter.object(at: section) as? HabitTaskGroup
        }
    }
}
