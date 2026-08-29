//
//  GanttEventListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation
import UIKit

// MARK: - 左侧任务名称 Cell
class GanttEventListCell: UICollectionViewCell {
    static let reuseIdentifier = "GanttEventListCell"
    
    private let indicatorSize = CGSize(width: 5.0, height: 18.0)
    
    private let infoView = TPColorInfoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // 自定义普通背景视图
        let normalBackground = UIView()
        normalBackground.backgroundColor = GanttTimelineConfig.taskListOddRowColor
        backgroundView = normalBackground

        // 自定义选中背景视图（选中高亮）
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = GanttTimelineConfig.taskListSelectedRowColor
        selectedBackgroundView = selectedBackground

        infoView.padding = UIEdgeInsets(left: 8.0, right: 12.0)
        infoView.titleConfig.font = .systemFont(ofSize: 13.0, weight: .medium)
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = contentView.layoutFrame()
    }
    
    func configure(task: GanttEvent) {
        infoView.colorConfig = .withColor(task.color, size: indicatorSize)
        infoView.title = task.name
    }

    /// 设置普通（未选中）背景色，用于区分奇偶行
    func setRowBackgroundColor(_ color: UIColor) {
        backgroundView?.backgroundColor = color
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        infoView.title = nil
        infoView.colorConfig = nil
    }
}

// MARK: - 左侧任务列表视图
class GanttEventListView: UIView {
    
    // 布局
    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!
    
    // 布局常量
    private var rowHeight: CGFloat = GanttRowHeightType.medium.rowHeight
    private let columnWidth: CGFloat = GanttTimelineConfig.taskListWidth
    private let separatorLine = UIView()
    // 数据
    var tasks: [GanttEvent] = [] {
        didSet {
            reloadData()
        }
    }
    
    // 滚动同步回调
    var onVerticalScroll: ((CGFloat) -> Void)?

    /// 点击某个任务时的回调
    var onTaskSelect: ((GanttEvent) -> Void)?
    
    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = GanttTimelineConfig.taskListBackgroundColor
        clipsToBounds = false
        setupCollectionView()
        separatorLine.backgroundColor = GanttTimelineConfig.taskListSeparatorColor
        addSubview(separatorLine)
    }
    
    private func setupCollectionView() {
        let placeholderView = TPDefaultPlaceholderView()
        placeholderView.title = resGetString("No Event")
        placeholderView.titleColor = .label
        placeholderView.titleLabel.alpha = 0.6
        
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: columnWidth, height: rowHeight)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.headerReferenceSize = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.placeholderView = placeholderView
        collectionView.backgroundColor = GanttTimelineConfig.taskListBackgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(bottom: GanttTimelineConfig.insetBottom)
        collectionView.register(GanttEventListCell.self, forCellWithReuseIdentifier: GanttEventListCell.reuseIdentifier)
        
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        separatorLine.frame = CGRect(
            x: bounds.width - 1,
            y: 0,
            width: 1,
            height: bounds.height)
    }
    
    // MARK: - 行高设置

    /// 设置行高类型（宽松/中等/紧凑）
    func setRowHeightType(_ type: GanttRowHeightType) {
        setRowHeight(type.rowHeight)
    }

    /// 设置行高
    func setRowHeight(_ height: CGFloat) {
        guard rowHeight != height else { return }
        rowHeight = height
        flowLayout.itemSize = CGSize(width: columnWidth, height: height)
        collectionView.reloadData()
    }

    // MARK: - 公共方法
    
    var contentOffset: CGPoint {
        get { return collectionView.contentOffset }
        set { collectionView.contentOffset = newValue }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func scrollToRow(at indexPath: IndexPath, animated: Bool = false) {
        collectionView.scrollToItem(at: indexPath, at: .top, animated: animated)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension GanttEventListView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GanttEventListCell.reuseIdentifier,
            for: indexPath
        ) as! GanttEventListCell
        
        if indexPath.item < tasks.count {
            cell.configure(task: tasks[indexPath.item])
        }
        
        cell.setRowBackgroundColor(indexPath.item % 2 == 0
            ? GanttTimelineConfig.taskListOddRowColor
            : GanttTimelineConfig.taskListEvenRowColor)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard indexPath.item < tasks.count else { return }
        
        let task = tasks[indexPath.item]
        onTaskSelect?(task)
    }
}

// MARK: - UIScrollViewDelegate
extension GanttEventListView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onVerticalScroll?(scrollView.contentOffset.y)
        notifyVerticalContentOffsetChanged()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        notifyVerticalScrollWillBegin()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyVerticalScrollDidEnd()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifyVerticalScrollDidEnd()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        notifyVerticalScrollDidEnd()
    }
}

// MARK: - VerticalScrollSyncable
extension GanttEventListView: VerticalScrollSyncable {
    
    var yOffset: CGFloat {
        get {
            return collectionView.contentOffset.y
        }
        set {
            collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: newValue)
        }
    }
    
    func setYOffset(_ yOffset: CGFloat, animated: Bool) {
        collectionView.setContentOffset(
            CGPoint(x: collectionView.contentOffset.x, y: yOffset),
            animated: animated
        )
    }
    
    var verticalScrollSyncDelegate: VerticalScrollSyncDelegate? {
        get {
            return collectionView.verticalScrollSyncDelegate
        }
        set {
            collectionView.verticalScrollSyncDelegate = newValue
        }
    }
    
    func notifyVerticalScrollWillBegin() {
        verticalScrollSyncDelegate?.verticalScrollSyncViewWillBeginScrolling(self)
    }
    
    func notifyVerticalScrollDidEnd() {
        verticalScrollSyncDelegate?.verticalScrollSyncViewDidEndScrolling(self)
    }
    
    func notifyVerticalContentOffsetChanged() {
        verticalScrollSyncDelegate?.verticalScrollSyncView(self, didChangeYOffset: yOffset)
    }
}
