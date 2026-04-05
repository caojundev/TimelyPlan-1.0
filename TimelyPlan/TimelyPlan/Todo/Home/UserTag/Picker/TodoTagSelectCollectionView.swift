//
//  TodoTagSelectCollectionView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/5.
//

import Foundation
import UIKit

protocol TodoTagSelectCollectionViewDelegate: AnyObject {
    
    /// 选中标签
    func selectCollectionView(_ view: TodoTagSelectCollectionView, didSelectTag tag: TodoTag)
    
    /// 是否是选中标签
    func selectCollectionView(_ view: TodoTagSelectCollectionView, isSelectedTag tag: TodoTag) -> Bool
}

class TodoTagSelectCollectionView: TPCollectionWrapperView,
                                   TPCollectionViewAdapterDataSource,
                                   TPCollectionViewAdapterDelegate {
    
    weak var delegate: TodoTagSelectCollectionViewDelegate?
    
    /// 原因标签数组
    var userTags: [TodoTag]?
    
    /// 列表区块布局
    private let preferredItemHeight = 50.0
    
    private lazy var layout: TPCollectionSectionLayout = {
        let layout = TPCollectionSectionLayout()
        layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        layout.minimumItemsCountPerRow = 2
        layout.maximumItemsCountPerRow = 2
        layout.lineSpacing = 10.0
        layout.interitemSpacing = 10.0
        layout.preferredItemHeight = preferredItemHeight
        return layout
    }()
    
    override init(frame: CGRect) {
        let collectionViewLayout = UICollectionViewLeftAlignedLayout()
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        self.collectionView.showsVerticalScrollIndicator = false
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.adapter.cellStyle.cornerRadius = 8.0
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.cellStyle.selectedBackgroundColor = .secondarySystemGroupedBackground
        self.adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return ["UserTagSection" as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return userTags
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
        return layout.constraintCellSize ?? .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TodoTagSelectCollectionCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! TodoTagSelectCollectionCell
        cell.userTag = adapter.item(at: indexPath) as? TodoTag
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        guard let userTag = adapter.item(at: indexPath) as? TodoTag else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        delegate?.selectCollectionView(self, didSelectTag: userTag)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        guard let userTag = adapter.item(at: indexPath) as? TodoTag else {
            return false
        }
        
        return delegate?.selectCollectionView(self, isSelectedTag: userTag) ?? false
    }
    
    func updateCheckmarks(for tags: [TodoTag]) {
        adapter.updateCheckmarks(for: tags, animated: true)
    }
}

class TodoTagSelectCollectionCell: TPDefaultInfoCollectionCell {
    
    var userTag: TodoTag? {
        didSet {
            self.infoView.title = userTag?.name ?? resGetString("Untitled")
            self.colorView.backgroundColor = userTag?.color ?? TodoTag.defaultColor
            setNeedsLayout()
        }
    }

    /// 颜色视图
    private(set) var colorView = UIView()
    
    private let colorSize = CGSize.size(2)
    
    private lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.isUserInteractionEnabled = false
        checkbox.outerLineWidth = 1.8
        return checkbox
    }()

    override func setupInfoView() {
        contentView.padding = UIEdgeInsets(left: 10.0, right: 10.0)
        self.colorView.clipsToBounds = true
        self.infoView.leftAccessoryView = self.colorView
        self.infoView.leftAccessorySize = colorSize
        self.infoView.leftAccessoryMargins = UIEdgeInsets(left: 4.0, right: 8.0)
        
        self.infoView.rightAccessoryView = self.checkbox
        self.infoView.rightAccessorySize = .size(4)
        self.infoView.rightAccessoryMargins = UIEdgeInsets(left: 4.0, right: 4.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = colorSize.halfWidth
        updateCheckboxStyle()
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkbox.setChecked(checked, animated: animated)
        updateCheckboxStyle()
    }
    
    private func updateCheckboxStyle() {
        checkbox.alpha = isChecked ? 1.0 : 0.2
        if isChecked {
            checkbox.innerColor = .primary
        } else {
            checkbox.innerColor = resGetColor(.title)
        }
        
        checkbox.outerColor = checkbox.innerColor
    }
}
