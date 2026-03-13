//
//  HabitReasonTagSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/13.
//


import Foundation
import UIKit

class HabitReasonTagSelectViewController: TPCollectionViewController,
                                            TPCollectionViewAdapterDataSource,
                                            TPCollectionViewAdapterDelegate {
        
    /// 选中标签回调
    var didSelectTag: ((ReasonTag) -> Void)?
    
    /// 原因标签数组
    var reasonTags: [ReasonTag]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.reasonTags = HabitReasonTagManager.getReasonTags()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.collectionViewLayout = UICollectionViewLeftAlignedLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Tag")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.preferredContentSize = CGSize(width: 400.0, height: 420.0)
        self.collectionView.showsVerticalScrollIndicator = false
        self.actionsBar?.actionsCountPerRow = 1
        let newAction = TPButtonAction(title: resGetString("New Tag")) { [weak self] action in
            self?.addReasonTag()
        }
        
        self.setupActionsBar(actions: [newAction])
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.adapter.cellStyle.cornerRadius = 8.0
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.cellStyle.selectedBackgroundColor = Color(0xccccc, 0.1)
        self.adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func collectionViewFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: 0.0,
                      width: view.width,
                      height: view.height - actionsBarHeight)
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return ["ReasonTagSection" as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return reasonTags
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
        layout.collectionViewSize = view.bounds.size
        layout.preferredItemWidth = (collectionView.width - layout.interitemSpacing - layout.edgeMargins.horizontalLength) / 2.0
        return layout.constraintCellSize ?? .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitReasonTagCollectionCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitReasonTagCollectionCell
        cell.reasonTag = adapter.item(at: indexPath) as? ReasonTag
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        let tag = adapter.item(at: indexPath) as! ReasonTag
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: {
            self.didSelectTag?(tag)
        })
    }
    
    // MARK: - 标签操作
    func addReasonTag() {
        HabitReasonTagManager.editTag(type: .create, emoji: nil, reason: nil) { newEmoji, newReason in
            self.didCreateNewTag(emoji: String(newEmoji), reason: newReason)
        }
    }
    
    func saveReasonTags() {
        HabitReasonTagManager.saveReasonTags(reasonTags)
    }
    
    /// 点击新标签按钮
    func didCreateNewTag(emoji: String, reason: String) {
        let tag = ReasonTag(emoji: emoji, reason: reason)
        let scrollAndCommitFocusAnimation = {
            self.adapter.scrollToItem(tag, at: .centeredVertically, animated: true) { _ in
                self.adapter.commitFocusAnimation(for: tag)
            }
        }
        
        guard !(reasonTags.contains(tag)) else {
            scrollAndCommitFocusAnimation()
            return
        }
        
        /// 添加到顶部
        reasonTags.insert(tag, at: 0)
        adapter.performUpdate { _ in
            scrollAndCommitFocusAnimation()
        }
        
        saveReasonTags()
    }
}

class HabitReasonTagCollectionCell: TPDefaultInfoCollectionCell {
    
    var reasonTag: ReasonTag? {
        didSet {
            emojiLabel.text = reasonTag?.emoji
            title = reasonTag?.reason
        }
    }
    
    let emojiSize = CGSize.size(10)
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textAlignment = .center
        return label
    }()
    
    override func setupInfoView() {
        self.infoView.leftAccessoryView = emojiLabel
        self.infoView.leftAccessorySize = emojiSize
        self.infoView.leftAccessoryMargins = UIEdgeInsets(left: 6.0, right: 12.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.emojiLabel.layer.backgroundColor = UIColor.tertiarySystemGroupedBackground.cgColor
        self.emojiLabel.layer.cornerRadius = emojiSize.halfHeight
    }
}
