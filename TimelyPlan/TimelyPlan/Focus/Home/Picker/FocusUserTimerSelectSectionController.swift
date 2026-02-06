//
//  FocusUserTimerSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/30.
//

import Foundation

class FocusUserTimerSelectSectionController: FocusUserTimerListSectionController {
    
    /// 显示头视图
    var showHeader: Bool = false
    
    var headerHeight: CGFloat = 0.0
    
    override init() {
        super.init()
        self.cellStyle.selectedBackgroundColor = cellStyle.backgroundColor
        self.layout.preferredItemWidth = .greatestFiniteMagnitude
    }
    
    // MARK: - Header
    override func layoutMarginsForHeaderFooterView(_ view: TPCollectionHeaderFooterView) -> UIEdgeInsets {
        var layoutMargins = layout.sectionInset
        layoutMargins.top = 0.0
        layoutMargins.left = 5.0
        layoutMargins.bottom = 0.0
        return layoutMargins
    }
    
    override func sizeForHeader() -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: headerHeight)
    }
    
    override func classForHeader() -> AnyClass? {
        guard showHeader, itemsCount > 0 else {
            return UICollectionReusableView.self
        }
        
        return TPCollectionHeaderFooterView.self
    }
    
    override func didDequeHeader(_ headerView: UICollectionReusableView) {
        if let headerView = headerView as? TPCollectionHeaderFooterView {
            headerView.delegate = self
            headerView.padding = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0, right: 15.0)
            headerView.titleConfig.font = .boldSystemFont(ofSize: 16.0)
            headerView.titleConfig.textColor = resGetColor(.title)
            headerView.title = resGetString("Custom Timer")
        }
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return FocusUserTimerSelectCell.self
    }
    
    override func didSelectItem(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        
        /// 通知delegate
        delegate?.collectionSectionController(self, didSelectItemAt: index)
    }
}
