//
//  FocusUserTimerSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/30.
//

import Foundation

class FocusTimerListSectionLayout: TPCollectionSectionLayout {

    override init() {
        super.init()
        self.edgeMargins = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        self.minimumItemsCountPerRow = 1
        self.maximumItemsCountPerRow = 1
        self.lineSpacing = 10.0
        self.interitemSpacing = 10.0
        self.preferredItemHeight = 70.0
        self.preferredItemWidth = kFocusTimerListContentMaxWidth
    }
}

class FocusUserTimerCellStyle: TPCollectionCellStyle {
    
    override init() {
        super.init()
        self.backgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundColor = .tertiarySystemGroupedBackground
        self.cornerRadius = 12.0
    }
}

class FocusUserTimerListSectionController: TPCollectionBaseSectionController {
    
    let cellStyle = FocusUserTimerCellStyle()
    
    let layout = FocusTimerListSectionLayout()
    
    var timers: [FocusTimer]?
    
    override init() {
        super.init()
        self.cellStyle.selectedBackgroundColor = cellStyle.backgroundColor
        self.layout.preferredItemWidth = .greatestFiniteMagnitude
    }
    
    override var items: [ListDiffable]? {
        return self.timers
    }
    
    override func interitemSpacing() -> CGFloat {
        return layout.interitemSpacing
    }
    
    override func lineSpacing() -> CGFloat {
        return layout.lineSpacing
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return layout.sectionInset
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        layout.collectionViewSize = adapter?.collectionViewSize()
        return layout.constraintCellSize ?? .zero
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return FocusUserTimerInfoCell.self
    }

    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        if let cell = cell as? FocusUserTimerInfoCell {
            cell.timer = timer(at: index)
        }
    }
    
    override func didSelectItem(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        
        /// 通知delegate
        delegate?.collectionSectionController(self, didSelectItemAt: index)
    }
    
    override func styleForItem(at index: Int) -> TPCollectionCellStyle? {
        return cellStyle
    }
    
    // MARK: - Helpers
    func timer(at index: Int) -> FocusTimer {
        let timer = item(at: index) as! FocusTimer
        return timer
    }
    
    func index(of timer: FocusTimer) -> Int? {
        guard let timers = adapter?.items(for: self) as? [FocusTimer] else {
            return nil
        }
        
        return timers.indexOf(timer)
    }
}

class FocusUserTimerSelectSectionController: FocusUserTimerListSectionController {
    
    /// 显示头视图
    var showHeader: Bool = false 
    
    /// 头高度
    var headerHeight: CGFloat = 0.0
    
    private let requestManager = TPRequestManager()

    override func classForCell(at index: Int) -> AnyClass? {
        return FocusUserTimerSelectCell.self
    }

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
        return TPCollectionHeaderFooterView.self
    }

    override func didDequeHeader(_ headerView: UICollectionReusableView) {
       guard let headerView = headerView as? TPCollectionHeaderFooterView else {
          return
       }
        
        headerView.padding = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0, right: 15.0)
        headerView.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        headerView.titleConfig.textColor = resGetColor(.title)
        let timersCount = self.timers?.count ?? 0
        if timersCount > 0 {
            headerView.title = resGetString("Custom")
        } else  {
            headerView.title = nil
        }
    }

    func reloadData() {
        let requestID = requestManager.executeRequest()
        focus.fetchActiveTimers { timers in
            guard self.requestManager.shouldProceed(with: requestID) else {
                self.timers = nil
                self.adapter?.performUpdate()
                return
            }
            
            self.timers = timers
            self.adapter?.performSectionUpdate(forSectionObject: self)
        }
    }
}
