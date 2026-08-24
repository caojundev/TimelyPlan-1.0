//
//  GanttTaskListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation
import UIKit

// MARK: - 左侧任务名称 Cell
class GanttTaskListCell: UICollectionViewCell {
    static let reuseIdentifier = "GanttTaskListCell"
    
    private let nameLabel = UILabel()
    private let expandButton = UIButton(type: .system)
    private let separatorLine = UIView()
    
    var onExpandTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        expandButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        expandButton.tintColor = .gray
        expandButton.addTarget(self, action: #selector(expandTapped), for: .touchUpInside)
        expandButton.isHidden = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.textColor = .darkText
        nameLabel.numberOfLines = 2
        
        separatorLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        contentView.addSubview(expandButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(separatorLine)
    }
    
    func configure(task: GanttTask, indent: Int) {
        nameLabel.text = task.name
        
        let baseX: CGFloat = task.isGroup ? 28 : 8
        let xPosition = baseX + CGFloat(indent) * 16
        
        nameLabel.frame = CGRect(
            x: xPosition,
            y: 0,
            width: bounds.width - xPosition - 8,
            height: bounds.height
        )
        
        expandButton.isHidden = !task.isGroup
        expandButton.frame = CGRect(
            x: 4 + CGFloat(indent) * 16,
            y: (bounds.height - 20) / 2,
            width: 20,
            height: 20
        )
        let imageName = task.isExpanded ? "chevron.down" : "chevron.right"
        expandButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        separatorLine.frame = CGRect(x: bounds.width - 1, y: 0, width: 1, height: bounds.height)
    }
    
    @objc private func expandTapped() {
        onExpandTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        expandButton.isHidden = true
    }
}

// MARK: - 左侧任务列表视图
class GanttTaskListView: UIView {
    
    // 布局
    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!
    
    // 布局常量
    private let rowHeight: CGFloat = 44
    private let columnWidth: CGFloat = 180
    
    // 数据
    var tasks: [GanttTask] = [] {
        didSet {
            reloadData()
        }
    }
    
    // 滚动同步回调
    var onVerticalScroll: ((CGFloat) -> Void)?
    
    // 展开/折叠回调
    var onExpandTapped: ((Int) -> Void)?
    
    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        clipsToBounds = true
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: columnWidth, height: rowHeight)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.headerReferenceSize = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.register(GanttTaskListCell.self, forCellWithReuseIdentifier: GanttTaskListCell.reuseIdentifier)
        
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
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
    
    // MARK: - 内部方法
    
    private func flattenTasks() -> [(task: GanttTask, indent: Int)] {
        var result: [(task: GanttTask, indent: Int)] = []
        
        func addTask(_ task: GanttTask, indent: Int) {
            result.append((task: task, indent: indent))
            if task.isExpanded, let children = task.children {
                for child in children {
                    addTask(child, indent: indent + 1)
                }
            }
        }
        
        for task in tasks {
            addTask(task, indent: 0)
        }
        
        return result
    }
    
    private var flattenedTasks: [(task: GanttTask, indent: Int)] {
        return flattenTasks()
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension GanttTaskListView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flattenedTasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GanttTaskListCell.reuseIdentifier,
            for: indexPath
        ) as! GanttTaskListCell
        
        let items = flattenedTasks
        if indexPath.item < items.count {
            let item = items[indexPath.item]
            cell.configure(task: item.task, indent: item.indent)
            cell.onExpandTapped = { [weak self] in
                self?.onExpandTapped?(indexPath.item)
            }
        }
        
        cell.backgroundColor = indexPath.item % 2 == 0 ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension GanttTaskListView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onVerticalScroll?(scrollView.contentOffset.y)
    }
}
