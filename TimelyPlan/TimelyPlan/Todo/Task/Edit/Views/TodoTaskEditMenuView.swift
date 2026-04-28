//
//  TodoTaskEditMenuView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/26.
//

import Foundation
import UIKit

class TodoTaskEditMenuView: TPCollectionWrapperView,
                           TPCollectionViewAdapterDataSource,
                           TPCollectionViewAdapterDelegate {
    /// 选中编辑类型回调
    var didSelectEditType: ((TodoTaskEditType) -> Void)?
    
    private(set) var editTypes: [TodoTaskEditType] = TodoTaskEditType.allCases
    
    let cellContentPadding = UIEdgeInsets(horizontal: 16.0)
    
    let font: UIFont = BOLD_SMALL_SYSTEM_FONT
    
    let imageSize: CGSize = .size(5)
    
    let imageMargins: UIEdgeInsets = UIEdgeInsets(right: 8.0)
    
    /// 边界间距
    var edgeMargin: CGFloat = 12.0
    
    /// 间距
    var itemMargin: CGFloat = 8.0

    /// 条目高度
    var itemHeight: CGFloat = 36.0
    
    private lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.cornerRadius = 8.0
        style.borderWidth = 2.0
        style.borderColor = .secondaryLabel
        style.backgroundColor = .systemBackground
        style.selectedBackgroundColor = .systemBackground
        return style
    }()
    
    override init(frame: CGRect) {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        self.backgroundColor = .systemBackground
        self.addSeparator(position: .top)
        collectionConfiguration = { collectionView in
            collectionView.isPrefetchingEnabled = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
        }
 
        adapter.cellClass = TodoTaskEditMenuCell.self
        adapter.dataSource = self
        adapter.delegate = self
        adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setEditTypes(_ editTypes: [TodoTaskEditType], animated: Bool = false) {
        guard self.editTypes != editTypes else {
            return
        }
        
        self.editTypes = editTypes
        if animated {
            adapter.performUpdate()
        } else {
            adapter.reloadData()
        }
    }

    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }

    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return editTypes.map { TodoTaskEditMenuAction(editType: $0)}
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
        let action = adapter.item(at: indexPath) as! TodoTaskEditMenuAction
        var itemWidth = cellContentPadding.horizontalLength
        itemWidth += imageSize.width + imageMargins.horizontalLength
        itemWidth += action.title.width(with: self.font)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! TodoTaskEditMenuCell
        cell.contentPadding = self.cellContentPadding
        cell.font = self.font
        cell.imageSize = self.imageSize
        cell.imageMargins = self.imageMargins
        cell.cellStyle = self.cellStyle
        cell.action = adapter.item(at: indexPath) as? TodoTaskEditMenuAction
    }

    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        let action = adapter.item(at: indexPath) as! TodoTaskEditMenuAction
        didSelectEditType?(action.editType)
    }
}

class TodoTaskEditMenuCell: TPImageTitleCollectionCell {

    var font: UIFont = BOLD_SMALL_SYSTEM_FONT {
        didSet {
            imageTitleView.titleConfig.font = font
            setNeedsLayout()
        }
    }
    
    var imageSize: CGSize = .mini {
        didSet {
            imageTitleView.imageConfig.size = imageSize
            setNeedsLayout()
        }
    }
    
    var imageMargins: UIEdgeInsets = UIEdgeInsets(right: 4.0) {
        didSet {
            imageTitleView.imageConfig.margins = imageMargins
            setNeedsLayout()
        }
    }
    
    var contentPadding: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    var action: TodoTaskEditMenuAction? {
        didSet {
            imageTitleView.title = action?.title
            imageTitleView.image = action?.image
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageTitleView.accessoryPosition = .left
        let titleConfig = self.imageTitleView.titleConfig
        titleConfig.font = font
        titleConfig.textAlignment = .left
         
        let color: UIColor = .secondaryLabel
        titleConfig.textColor = color
        titleConfig.highlightedTextColor = color
        
        let imageConfig = self.imageTitleView.imageConfig
        imageConfig.size = imageSize
        imageConfig.margins = imageMargins
        imageConfig.color = color
        imageConfig.highlightedColor = color
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
