//
//  TPButtonActionsView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/23.
//

import Foundation

class TPButtonActionsView: TPCollectionWrapperView,
                           TPCollectionViewAdapterDataSource,
                           TPCollectionViewAdapterDelegate {

    var actions: [TPButtonAction]
    
    /// 每行按钮数目
    var actionsCountPerRow: Int = 2
    
    /// 边界间距
    var edgeMargin: CGFloat = 0.0
    
    /// 条目间距
    var itemMargin: CGFloat = 10.0
    
    /// 条目高度
    var itemHeight: CGFloat = 60.0
    
    /// 行间距
    var lineSpacing: CGFloat = 10.0
    
    /// 圆角半径
    var itemCornerRadius: CGFloat = .greatestFiniteMagnitude {
        didSet {
            for action in actions {
                action.style.cornerRadius = itemCornerRadius
            }
        }
    }

    /// 选中动作回调
    var didSelectAction: ((TPButtonAction) -> Void)?
    
    convenience init() {
        self.init(frame: .zero, actions: [])
    }
    
    convenience init(actions: [TPButtonAction]) {
        self.init(frame: .zero, actions: actions)
    }
    
    init(frame: CGRect, actions: [TPButtonAction]) {
        self.actions = actions
        super.init(frame: frame)
        
        collectionConfiguration = { collectionView in
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.bounces = false
        }
        
        adapter.cellClass = TPButtonActionCell.self
        adapter.dataSource = self
        adapter.delegate = self
        adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }

    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return actions
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(horizontal: edgeMargin)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return itemMargin
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = adapter.collectionViewSize()
        let contentWidth = collectionViewSize.width - 2 * edgeMargin
        let actionsCountPerRow = CGFloat(actionsCountPerRow)
        let interItemSpacing = itemMargin
        let itemWidth = (contentWidth - (actionsCountPerRow - 1) * interItemSpacing) / actionsCountPerRow
        let itemHeight = min(itemHeight, collectionViewSize.height)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! TPButtonActionCell
        let action = adapter.item(at: indexPath) as! TPButtonAction
        cell.action = action
        cell.cellStyle = action.style
        
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let action = adapter.item(at: indexPath) as! TPButtonAction
        return action.isEnabled
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let action = adapter.item(at: indexPath) as! TPButtonAction
        if let didSelectAction = self.didSelectAction {
            /// 交由外部调用处理
            didSelectAction(action)
        } else {
            /// 直接处理动作
            action.handler?(action)
        }
    }
}
