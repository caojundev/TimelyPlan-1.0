//
//  TPLodableCollectionView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/29.
//

import Foundation
import UIKit

protocol TPLoadableGroupCollectionViewDelegate: TPGroupCollectionViewDelegate {
    
    /// 异步获取分组数据
    func loadableGroupCollectionView(_ collectionView: TPLoadableGroupCollectionView,
                                   forceRefresh: Bool,
                                   fetchTaskGroups completion: @escaping ([GroupRepresentable]?) -> Void)
}

class TPLoadableGroupCollectionView: TPGroupCollectionView {

    private let requestManager = TPRequestManager()
    
    private(set) var refreshControl: UIRefreshControl?

    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            self.listPlaceholderProvider.state = state
            self.updatePlaceholderView()
        }
    }
    
    lazy var listPlaceholderProvider: TPLoadableListPlaceholderProvider = {
        let provider = TPLoadableListPlaceholderProvider()
        return provider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.placeholderProvider = self.listPlaceholderProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        self.setupRefreshControl()
        self.state = .initialLoading /// 初始化切换状态
    }

    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                action: #selector(handleRefresh),
                                 for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
        self.refreshControl = refreshControl
    }

    @objc func handleRefresh() {
        self.asyncReloadData()
    }

    // MARK: - Public Methods
    func asyncReloadData(forceRefresh: Bool = true, animateStyle: SlideStyle = .none) {
        self.groups = nil /// 分组置为空
        changeCollectionView(with: animateStyle)
        asyncReloadData(forceRefresh: forceRefresh)
    }
    
    func asyncReloadData(forceRefresh: Bool = true) {
        asyncLoadGroups(forceRefresh: forceRefresh) { isSuccess in
            if isSuccess {
                self.reloadData()
            }
        }
    }

    func asyncPerformUpdate(forceRefresh: Bool = true, completion: ((Bool) -> Void)? = nil) {
        asyncLoadGroups(forceRefresh: forceRefresh) { [weak self] isSuccess in
            if isSuccess {
                self?.performUpdate()
            }
            
            completion?(isSuccess)
        }
    }
    
    // MARK: - Data Loading Methods
    /// 异步加载任务分组
    /// - Parameter completion: 完成回调，参数为是否成功
    private func asyncLoadGroups(forceRefresh: Bool = true, completion: @escaping (Bool) -> Void) {
        let requestID = requestManager.executeRequest()
        guard let delegate = delegate as? TPLoadableGroupCollectionViewDelegate else {
            self.refreshControl?.endRefreshing()
            self.state = .loaded
            completion(true)
            return
        }
            
        delegate.loadableGroupCollectionView(self, forceRefresh: forceRefresh) { [weak self] groups in
            self?.refreshControl?.endRefreshing()
            guard let self = self else {
                completion(false)
                return
            }
            
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(false)
                return
            }
            
            self.state = .loaded
            self.groups = groups
            completion(true)
        }
    }
}
