//
//  TPCollectionWrapperView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/10.
//

import Foundation
import UIKit

class TPCollectionWrapperView: UIView,
                               TPAnimatedContainerViewDelegate {
    
    /// 集合视图适配器
    let adapter: TPCollectionViewAdapter = TPCollectionViewAdapter()
    
    var refreshHandler: (() -> Void)?
    
    var contentSize: CGSize {
        return collectionView.contentSize
    }
    
    var contentInset: UIEdgeInsets {
        get {
            return collectionView.contentInset
        }
        
        set {
            collectionView.contentInset = newValue
        }
    }
    
    /// CollectionView 视图配置
    var collectionConfiguration: ((UICollectionView) -> Void)? {
        didSet {
            collectionConfiguration?(collectionView)
        }
    }

    var shouldShowPlaceholder: (() -> Bool)? {
        get {
            return collectionView.shouldShowPlaceholder
        }
        
        set {
            collectionView.shouldShowPlaceholder = newValue
        }
    }
    
    /// 提供占位视图
    var placeholderProvider: TPPlaceholderProviding? {
        didSet {
            updatePlaceholderView()
        }
    }
    
    /// 滚动方向
    var scrollDirection: UICollectionView.ScrollDirection {
        get {
            return flowLayout.scrollDirection
        }
        
        set {
            flowLayout.scrollDirection = newValue
        }
    }
    
    var flowLayout: UICollectionViewFlowLayout {
        return collectionViewLayout as! UICollectionViewFlowLayout
    }

    /// 容器视图
    private var containerView: TPAnimatedContainerView!
    
    /// 集合视图
    private(set) var collectionView: UICollectionView!
    
    /// 布局对象
    private(set) var collectionViewLayout: UICollectionViewLayout!

    private(set) var refreshControl: UIRefreshControl?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.collectionViewLayout = UICollectionViewFlowLayout()
        self.setupSubviews()
    }
    
    init(frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: frame)
        self.collectionViewLayout = collectionViewLayout
        self.setupSubviews()
    }
    
    func setupSubviews() {
        containerView = TPAnimatedContainerView(frame: bounds)
        containerView.delegate = self
        addSubview(containerView)
        
        setupCollectionView()
        containerView.setContentView(collectionView)
    }
    
    func setupCollectionView() {
        let bAddRefreshControl = self.refreshControl != nil
        var shouldShowPlaceholder: (() -> Bool)?
        if let collectionView = collectionView {
            shouldShowPlaceholder = collectionView.shouldShowPlaceholder
            removeRefreshControl()
            
//            /// 如果是切换collectionView将原来的dataSource和delegate设置为nil  
//            collectionView.dataSource = nil
//            collectionView.delegate = nil
        }
        
        self.collectionView = UICollectionView(frame: bounds,
                                               collectionViewLayout: self.collectionViewLayout)
        self.collectionView.isPrefetchingEnabled = false
        self.collectionView.backgroundColor = .clear
        self.collectionView.shouldShowPlaceholder = shouldShowPlaceholder
        self.collectionConfiguration?(self.collectionView)
        
        /// 设置适配器
        adapter.collectionView = self.collectionView
        updatePlaceholderView()
        
        if bAddRefreshControl {
            addRefreshControl()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionViewLayout.invalidateLayout()
        containerView.frame = bounds
    }

    func addRefreshControl() {
        self.removeRefreshControl()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                action: #selector(handleRefresh),
                                 for: .valueChanged)
        self.refreshControl = refreshControl
        self.collectionView.refreshControl = self.refreshControl
    }

    func removeRefreshControl() {
        self.collectionView.refreshControl?.endRefreshing()
        self.collectionView.refreshControl = nil
        self.refreshControl = nil
    }
    
    @objc func handleRefresh() {
        if let refreshHandler = self.refreshHandler {
            refreshHandler()
        } else {
            endRefreshing()
        }
    }
    
    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }

    func hideScrollIndicator() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func updatePlaceholderView() {
        collectionView.placeholderView = placeholderProvider?.placeholderView()
    }

    // MARK: - 设置布局对象
    func setCollectionViewLayout(_ layout: UICollectionViewLayout) {
        setCollectionViewLayout(layout, animated: false)
    }
    
    func setCollectionViewLayout(_ layout: UICollectionViewLayout, animated: Bool) {
        collectionViewLayout = layout
        collectionView.setCollectionViewLayout(layout, animated: animated)
    }

    /// 外部配置CollectionView
    func configure(_ config: (UICollectionView) -> Void) {
        config(collectionView)
    }
    
    func changeCollectionView(with animateStyle: SlideStyle) {
        if animateStyle != .none {
            setupCollectionView()
            containerView.setContentView(collectionView, animateStyle: animateStyle)
        }
    }
    
    // MARK: - 更新列表
    func reloadData() {
        adapter.reloadData()
        updatePlaceholderView()
        endRefreshing()
    }
    
    func reloadData(animateStyle: SlideStyle) {
        changeCollectionView(with: animateStyle)
        reloadData()
    }
    
    /// 执行更新操作
    func performUpdate(with completion: ((Bool) -> Void)? = nil) {
        adapter.performUpdate(completion: completion)
        updatePlaceholderView()
        endRefreshing()
    }
    
    func updateItemSize() {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    /// 聚焦显示
    func revealItem(_ item: ListDiffable, autoScroll: Bool = true) {
        self.adapter.revealItem(item, autoScroll: autoScroll)
    }
    
    // MARK: - TPAnimatedContainerViewDelegate
    func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        return bounds
    }
}
