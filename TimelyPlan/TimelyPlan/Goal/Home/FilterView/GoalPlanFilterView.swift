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
    
    /// 该筛选类型对应的目标计划数目（nil 表示不展示）
    var count: Int?
    
    /// 数目文本
    var countText: String? {
        guard let count = count else {
            return nil
        }
        
        return "(\(count))"
    }
    
    let filterType: GoalPlanFilterType
    
    init(filterType: GoalPlanFilterType, count: Int? = nil) {
        self.filterType = filterType
        self.count = count
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
        return other.filterType == filterType && other.count == count
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
    
    /// 数目字体
    let countFont: UIFont = .systemFont(ofSize: 11.0, weight: .medium)
    
    /// 标题与数目间距
    var countSpacing: CGFloat = 6.0
    
    /// 目标计划数目提供者（按筛选类型返回对应数目，返回 nil 表示不展示数目）
    var countProvider: ((GoalPlanFilterType) -> Int?)? {
        didSet {
            adapter.reloadData()
        }
    }
    
    /// 边界间距
    var edgeMargin: CGFloat = 16.0
    
    /// 间距
    var itemMargin: CGFloat = 10.0
    
    /// 条目高度
    var itemHeight: CGFloat = 36.0
    
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
        return filterTypes.map { filterType in
            GoalPlanFilterAction(filterType: filterType,
                                 count: countProvider?(filterType))
        }
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
        if let countText = action.countText {
            itemWidth += countSpacing + countText.width(with: self.countFont)
        }
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! GoalPlanFilterCell
        cell.contentPadding = self.cellContentPadding
        cell.font = self.font
        cell.countFont = self.countFont
        cell.countSpacing = self.countSpacing
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
    
    /// 数目字体
    var countFont: UIFont = .systemFont(ofSize: 11.0, weight: .medium) {
        didSet {
            countLabel.font = countFont
            setNeedsLayout()
        }
    }
    
    /// 标题与数目间距
    var countSpacing: CGFloat = 6.0 {
        didSet {
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
            countLabel.text = action?.countText
            setNeedsLayout()
        }
    }
    
    /// 目标计划数目
    private(set) lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = countFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.alpha = 0.8
        return label
    }()
    
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
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(countLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.padding = self.contentPadding
        
        let layoutFrame = self.contentView.layoutFrame()
        countLabel.isHidden = (action?.countText == nil)
        
        /// 标题与数目整体在条目内居中
        imageTitleView.sizeToFit()
        countLabel.sizeToFit()
        let spacing = countLabel.isHidden ? 0.0 : countSpacing
        let totalWidth = imageTitleView.width + spacing + (countLabel.isHidden ? 0.0 : countLabel.width)
        let left = layoutFrame.minX + max(0.0, (layoutFrame.width - totalWidth) / 2.0)
        
        imageTitleView.left = left
        imageTitleView.centerY = layoutFrame.midY
        countLabel.left = imageTitleView.right + spacing
        countLabel.centerY = layoutFrame.midY
        
        /// 高亮 / 选中状态下的文本颜色
        let isActive = isHighlighted || isSelected || isChecked
        countLabel.textColor = isActive ? .white : .secondaryLabel
    }
}
