//
//  GoalPlanFilterView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/6.
//

import Foundation
import UIKit

/// 目标计划筛选条目
class GoalPlanFilterAction: NSObject {
    
    /// 标题
    var title: String {
        return filterType.title
    }
    
    let filterType: GoalPlanFilterType
    
    init(filterType: GoalPlanFilterType) {
        self.filterType = filterType
        super.init()
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return filterType.identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? GoalPlanFilterAction else {
            return false
        }
        return other.filterType == filterType
    }
}

class GoalPlanFilterView: TPCollectionWrapperView,
                          TPCollectionViewAdapterDataSource,
                          TPCollectionViewAdapterDelegate {
    
    /// 选中筛选类型回调
    var didSelectFilterType: ((GoalPlanFilterType) -> Void)?
    
    /// 所有筛选类型
    private(set) var filterTypes: [GoalPlanFilterType] = GoalPlanFilterType.allCases
    
    /// 当前选中的筛选类型
    var selectedFilterType: GoalPlanFilterType = .all {
        didSet {
            guard selectedFilterType != oldValue else {
                return
            }
            adapter.updateCheckmarks()
        }
    }
    
    /// 条目内容间距
    let cellContentPadding = UIEdgeInsets(horizontal: 16.0)
    
    /// 标题字体
    let font: UIFont = BOLD_SMALL_SYSTEM_FONT
    
    /// 边界间距
    var edgeMargin: CGFloat = 16.0
    
    /// 间距
    var itemMargin: CGFloat = 10.0
    
    /// 条目高度
    var itemHeight: CGFloat = 32.0
    
    private lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.cornerRadius = .greatestFiniteMagnitude
        style.borderWidth = 0.0
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .primary
        return style
    }()
    
    override init(frame: CGRect) {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        self.backgroundColor = .clear
        collectionConfiguration = { collectionView in
            collectionView.isPrefetchingEnabled = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
        }
        
        adapter.cellClass = GoalPlanFilterCell.self
        adapter.dataSource = self
        adapter.delegate = self
        adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /// 垂直居中条目
        let verticalInset = max(0.0, (bounds.height - itemHeight) / 2.0)
        collectionView.contentInset = UIEdgeInsets(top: verticalInset,
                                                   left: 0.0,
                                                   bottom: verticalInset,
                                                   right: 0.0)
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return filterTypes.map { GoalPlanFilterAction(filterType: $0) }
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(horizontal: edgeMargin, vertical: 0.0)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return itemMargin
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return itemMargin
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let action = adapter.item(at: indexPath) as! GoalPlanFilterAction
        var itemWidth = cellContentPadding.horizontalLength
        itemWidth += action.title.width(with: self.font)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! GoalPlanFilterCell
        cell.contentPadding = self.cellContentPadding
        cell.font = self.font
        cell.cellStyle = self.cellStyle
        cell.action = adapter.item(at: indexPath) as? GoalPlanFilterAction
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        guard let action = adapter.item(at: indexPath) as? GoalPlanFilterAction else {
            return false
        }
        return action.filterType == selectedFilterType
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        let action = adapter.item(at: indexPath) as! GoalPlanFilterAction
        guard action.filterType != selectedFilterType else {
            return
        }
        
        selectedFilterType = action.filterType
        didSelectFilterType?(action.filterType)
    }
}

class GoalPlanFilterCell: TPImageTitleCollectionCell {
    
    var font: UIFont = BOLD_SMALL_SYSTEM_FONT {
        didSet {
            imageTitleView.titleConfig.font = font
            setNeedsLayout()
        }
    }
    
    var contentPadding: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    var action: GoalPlanFilterAction? {
        didSet {
            imageTitleView.title = action?.title
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageTitleView.accessoryPosition = .left
        let titleConfig = self.imageTitleView.titleConfig
        titleConfig.font = font
        titleConfig.textAlignment = .center
        titleConfig.textColor = .secondaryLabel
        titleConfig.highlightedTextColor = .white
        titleConfig.selectedTextColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.padding = self.contentPadding
        self.imageTitleView.frame = self.contentView.layoutFrame()
    }
}
