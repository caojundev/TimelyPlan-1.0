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
    
    var contentSize: CGSize {
        return collectionView.contentSize
    }
    
    /// CollectionView 视图配置
    var collectionConfiguration: ((UICollectionView) -> Void)? {
        didSet {
            collectionConfiguration?(collectionView)
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
        if let collectionView = collectionView {
            /// 如果是切换collectionView将原来的dataSource和delegate设置为nil  
            collectionView.dataSource = nil
            collectionView.delegate = nil
        }
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.isPrefetchingEnabled = false
        collectionView.backgroundColor = .clear
        collectionConfiguration?(collectionView)
        
        /// 设置适配器
        adapter.collectionView = collectionView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionViewLayout.invalidateLayout()
        containerView.frame = bounds
    }

    func hideScrollIndicator() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
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
    
    func reloadData() {
        adapter.reloadData()
    }
    
    func reloadData(animateStyle: SlideStyle) {
        if animateStyle != .none {
            setupCollectionView()
            containerView.setContentView(collectionView, animateStyle: animateStyle)
        }
        
        adapter.reloadData()
    }
    
    func updateItemSize() {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    // MARK: - TPAnimatedContainerViewDelegate
    func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        return bounds
    }
}
