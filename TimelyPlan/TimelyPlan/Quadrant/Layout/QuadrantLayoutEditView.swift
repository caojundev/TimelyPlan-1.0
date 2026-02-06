//
//  QuadrantLayoutEditView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/19.
//

import Foundation
import UIKit

class QuadrantLayoutEditView: TPCollectionWrapperView,
                              TPCollectionSingleSectionListDataSource,
                              TPCollectionViewAdapterDelegate,
                              TPCollectionDragExchangeReorderDelegate {
    
    /// 改版象限顺序
    var didChangeQuadrants: (([Quadrant]) -> Void)?
    
    /// 象限数组
    private(set) var quadrants: [Quadrant]

    /// 标题位置
    var titlePosition: QuadrantTitlePosition = .top

    /// 列表区块布局
    private lazy var layout: TPCollectionSectionLayout = {
        let layout = TPCollectionSectionLayout()
        layout.edgeMargins = UIEdgeInsets(horizontal: 20.0, vertical: 10.0)
        layout.minimumItemsCountPerRow = 2
        layout.maximumItemsCountPerRow = 2
        layout.lineSpacing = 10.0
        layout.interitemSpacing = 10.0
        return layout
    }()
    
    private let infoLabelHeight = 40.0
    private lazy var infoLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .center
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = resGetString("Long press and drag to rearrange the quadrant view")
        return label
    }()
    
    private var reorder: TPCollectionDragExchangeReorder?
    
    init(frame: CGRect, quadrants: [Quadrant]) {
        self.quadrants = quadrants
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        addSubview(infoLabel)
        adapter.cellClass = QuadrantLayoutEditCell.self
        adapter.dataSource = self
        adapter.delegate = self
        adapter.reloadData()
        hideScrollIndicator()
        setupReorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = bounds.inset(by: UIEdgeInsets(horizontal: 16.0))
        infoLabel.width = layoutFrame.width
        infoLabel.height = infoLabelHeight
        infoLabel.bottom = bounds.height
        infoLabel.left = layoutFrame.minX
    }
    
    override func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        let height = bounds.height - infoLabelHeight
        return CGRect(x: 0.0, y: 0.0, width: bounds.width, height: height)
    }
    
    func setupReorder() {
        let reorder = TPCollectionDragExchangeReorder(collectionView: collectionView)
        reorder.delegate = self
        reorder.isEnabled = true
        reorder.draggingViewCornerRadius = 12.0
        self.reorder = reorder
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return quadrants.map { return $0.rawValue as NSString }
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return layout.interitemSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return layout.lineSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return layout.sectionInset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        layout.collectionViewSize = bounds.size
        layout.preferredItemWidth = (collectionView.width - layout.interitemSpacing - layout.edgeMargins.horizontalLength) / 2.0
        layout.preferredItemHeight = (collectionView.height - layout.lineSpacing - layout.edgeMargins.verticalLength) / 2.0
        return layout.constraintCellSize ?? .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! QuadrantLayoutEditCell
        let quadrant = quadrants[indexPath.item]
        cell.quadrant = quadrant
        cell.titlePosition = titlePosition
        cell.cellStyle = cellStyle(for: quadrant)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    private func cellStyle(for quadrant: Quadrant) -> TPCollectionCellStyle {
        let cellStyle = TPCollectionCellStyle()
        cellStyle.cornerRadius = 12.0
        cellStyle.backgroundColor = .secondarySystemGroupedBackground
        cellStyle.selectedBackgroundColor = .secondarySystemGroupedBackground
        cellStyle.borderWidth = 1.0
        cellStyle.borderColor = quadrant.color.withAlphaComponent(0.3)
        cellStyle.selectedBorderColor = cellStyle.borderColor
        return cellStyle
    }
    
    // MARK: - TPCollectionDragExchangeReorderDelegate
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder, canMoveItemFrom fromIndexPath: IndexPath, to toIndexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder, moveItemFrom fromIndexPath: IndexPath, to toIndexPath: IndexPath) -> Bool {
        adapter.moveItem(at: fromIndexPath, to: toIndexPath)
        quadrants.moveObject(fromIndex: fromIndexPath.item, toIndex: toIndexPath.item)
        didChangeQuadrants?(quadrants)
        return true
    }
}
