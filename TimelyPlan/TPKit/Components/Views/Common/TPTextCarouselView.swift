//
//  TPTextCarouselView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation
import UIKit

class TPTextInfo: NSObject {
    
    /// 标题
    var title: String?
    
    /// 副标题
    var subtitle: String?
}

class TPTextCarouselView: TPCollectionWrapperView,
                           TPCollectionSingleSectionListDataSource,
                           TPCollectionViewAdapterDelegate {
    
    /// 所有标题数组
    var actions: [TPTextInfo]?
    
    /// 区块内间距
    var sectionInset: UIEdgeInsets = UIEdgeInsets(horizontal: 6.0)
    
    /// 单元格内间距
    var itemPadding = UIEdgeInsets(horizontal: 10.0)
    
    /// 条目间距
    var itemMargin: CGFloat = 6.0
    
    /// 条目高度
    var itemHeight: CGFloat = 36.0
    
    var minimumItemWidth: CGFloat = 60.0
    
    var maximumItemWidth: CGFloat = 120.0
    
    /// 选中条目回调
    var didSelectItemAtIndex: ((Int) -> Void)?
    
    var titleFont: UIFont = BOLD_SMALL_SYSTEM_FONT
    
    var subtitleFont = UIFont.boldSystemFont(ofSize: 8.0)
    
    var subtitleTopMargin = 2.0
    
    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.borderWidth = 2.0
        style.backgroundColor = .clear
        style.selectedBackgroundColor = Color(0x888888, 0.1)
        style.borderColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.9)
        return style
    }()
    
    init(actions: [TPTextInfo]? = nil) {
        self.actions = actions
        super.init(frame: .zero)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        adapter.cellClass = TPDefaultInfoCollectionCell.self
        adapter.interitemSpacing = itemMargin
        adapter.lineSpacing = itemMargin
        adapter.dataSource = self
        adapter.delegate = self
        self.adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return self.actions
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        var inset = sectionInset
        
        /// 横向单行显示
        if scrollDirection == .horizontal {
            inset.top = (adapter.collectionViewSize().height - itemHeight) / 2.0
            inset.bottom = inset.top
        }
        
        return inset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return itemMargin
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let action = adapter.item(at: indexPath) as? TPTextInfo
        
        let layout = TPInfoViewLayout()
        layout.padding = itemPadding
        layout.titleContent = .withText(action?.title)
        layout.titleConfig.font = titleFont
        layout.subtitleContent = .withText(action?.subtitle)
        layout.subtitleConfig.font = subtitleFont
        layout.subtitleTopMargin = subtitleTopMargin
        let size = layout.sizeThatFits()
        let width = min(max(minimumItemWidth, size.width), maximumItemWidth)
        return CGSize(width: width, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let action = adapter.item(at: indexPath) as? TPTextInfo
        let cell = cell as! TPDefaultInfoCollectionCell
        cell.contentView.padding = itemPadding
        cell.cellStyle = cellStyle
        cell.titleConfig.font = titleFont
        cell.titleConfig.textAlignment = .center
        cell.subtitleConfig.font = subtitleFont
        cell.subtitleConfig.textAlignment = .center
        cell.infoView.title = action?.title
        cell.infoView.subtitle = action?.subtitle
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        didSelectItemAtIndex?(indexPath.item)
    }
}
