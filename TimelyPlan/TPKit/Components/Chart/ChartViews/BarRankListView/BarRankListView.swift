//
//  BarRankListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/28.
//

import Foundation
import UIKit

struct BarRankListItem {
    
    /// 排行切片
    var slices: [BarRankListSlice]
    
    /// 行高
    var rowHeight: CGFloat = 50.0
    
    init(slices: [BarRankListSlice],
         maxDisplayCount: Int? = 6,
         othersSliceUpdater:((BarRankListSlice) -> Void)? = nil) {
        self.slices = slices
        guard let maxCount = maxDisplayCount,
                maxCount > 0,
                slices.count > maxCount else {
            return
        }
        
        // 需要合并超出限制的切片到 Others
        var displaySlices = Array(slices.prefix(maxCount))
        let othersSlices = Array(slices.suffix(from: maxCount))
        
        let value = othersSlices.reduce(0.0) { $0 + $1.value }
        let othersSlice = BarRankListSlice(title: resGetString("Others"),
                                           detail: nil,
                                           value: value,
                                           threshold: value,
                                           barColor: .grayPrimary)
        if let othersSliceUpdater = othersSliceUpdater {
            othersSliceUpdater(othersSlice)
        }
        
        displaySlices.append(othersSlice)
        
        if let threshold = displaySlices.map({ $0.value }).max() {
            displaySlices.forEach { slice in
                slice.threshold = threshold
            }
        }

        self.slices = displaySlices
    }
    
}

class BarRankListSlice {
    var title: String      // 指标标题
    var detail: String?    // 详情信息
    var value: Double     // 指标数值
    var threshold: Double // 参考阈值
    var barColor: UIColor
    
    init(title: String,
         detail: String?,
         value: Double,
         threshold: Double,
         barColor: UIColor) {
        self.title = title
        self.detail = detail
        self.value = value
        self.threshold = threshold
        self.barColor = barColor
    }
}

class BarRankListView: TPCollectionWrapperView,
                       TPCollectionSectionControllersList {
    
    var listItem: BarRankListItem? {
        didSet {
            sectionController.layout.preferredItemHeight = rowHeight
        }
    }
    
    var rowHeight: CGFloat {
        return listItem?.rowHeight ?? 50.0
    }
    
    var sectionControllers: [TPCollectionBaseSectionController]?
    
    lazy var sectionController: TPCollectionItemSectionController = {
        let sectionController = TPCollectionItemSectionController()
        let layout = sectionController.layout
        layout.interitemSpacing = 0.0
        layout.lineSpacing = 0.0
        layout.edgeMargins = .zero
        layout.minimumItemsCountPerRow = 1
        layout.maximumItemsCountPerRow = 1
        layout.preferredItemHeight = rowHeight
        return sectionController
    }()
    
    private let defaultPlaceholderProvider = TPDefaultPlaceholderProvider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sectionControllers = [sectionController]
        defaultPlaceholderProvider.emptyTitle =  resGetString("NO DATA")
        placeholderProvider = defaultPlaceholderProvider
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        adapter.cellStyle.cornerRadius = 0.0
        adapter.cellStyle.backgroundColor = .clear
        adapter.cellStyle.selectedBackgroundColor = .clear
        adapter.dataSource = self
        adapter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellItems() {
        guard let slices = listItem?.slices else {
            sectionController.cellItems = []
            return
        }
        
        var cellItems = [TPCollectionCellItem]()
        for slice in slices {
            let cellItem = BarRankListCellItem(slice: slice)
            cellItems.append(cellItem)
        }
        
        sectionController.cellItems = cellItems
    }
    
    override func reloadData() {
        setupCellItems()
        super.reloadData()
    }
}

