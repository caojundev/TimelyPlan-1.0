//
//  FocusTimerSelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/29.
//

import Foundation
import UIKit

class FocusTimerSelectView: TPGroupCollectionView {
    
    var showSectionHeader: Bool = false
    
    private var sectionHeaderHeight = 40.0
    
    private let cellStyle = FocusUserTimerCellStyle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.cellStyle.selectedBackgroundColor = .secondarySystemGroupedBackground
        self.preferredItemWidth = .greatestFiniteMagnitude
        self.preferredItemHeight = 70.0
        self.addRefreshControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func showHeaderOfGroup(_ group: FocusTimerGroup) -> Bool {
        return showSectionHeader && group.identifier == FocusTimerGroupIdentifier.user.rawValue
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        let item = adapter.item(at: indexPath)
        if item is FocusTimer {
            return FocusUserTimerSelectCell.self
        } else if item is FocusSystemTimer {
            return FocusDefaultTimerSelectCell.self
        }
        
        return TPCollectionCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        if let cell = cell as? TPCollectionCell {
            cell.cellStyle = cellStyle
        }
        
        if let cell = cell as? FocusUserTimerSelectCell {
            cell.timer = adapter.item(at: indexPath) as? FocusTimer
        } else if let cell = cell as? FocusDefaultTimerSelectCell {
            cell.timer = adapter.item(at: indexPath) as? FocusSystemTimer
        }
    }

    override func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        guard let group = adapter.object(at: section) as? FocusTimerGroup else {
            return .zero
        }
        
        let headerHeight = showHeaderOfGroup(group) ? sectionHeaderHeight : 0.0
        return CGSize(width: .greatestFiniteMagnitude, height: headerHeight)
    }

    override func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        guard let group = adapter.object(at: section) as? FocusTimerGroup else {
            return UICollectionReusableView.self
        }
        
        if showHeaderOfGroup(group) {
            return TPCollectionHeaderFooterView.self
        }
        
        return UICollectionReusableView.self
    }

    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        guard let headerView = headerView as? TPCollectionHeaderFooterView else {
            return
        }
        
        headerView.padding = UIEdgeInsets(top: 5.0, left: 8.0, bottom: 0, right: 15.0)
        headerView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        headerView.titleConfig.textColor = resGetColor(.title)
        
        if let group = adapter.object(at: section) as? FocusTimerGroup {
            headerView.title = group.name
        } else {
            headerView.title = nil
        }
    }
}
