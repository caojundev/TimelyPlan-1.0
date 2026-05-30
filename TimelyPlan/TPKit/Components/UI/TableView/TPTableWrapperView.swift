//
//  TPTableWrapperView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/31.
//

import Foundation
import UIKit

class TPTableWrapperView: UIView, TPAnimatedContainerViewDelegate {

    var refreshHandler: (() -> Void)?

    /// 集合视图适配器
    let adapter = TPTableViewAdapter()
    
    /// 提供占位视图
    var placeholderProvider: TPPlaceholderProviding? {
        didSet {
            updatePlaceholderView()
        }
    }
    
    var shouldShowPlaceholder: (() -> Bool)? {
        didSet {
            tableView.shouldShowPlaceholder = shouldShowPlaceholder
        }
    }
    
    var tableHeaderView: UIView? {
        didSet {
            tableView.tableHeaderView = tableHeaderView
        }
    }

    /// 动画容器视图
    private var containerView: TPAnimatedContainerView!
    
    /// 集合视图
    fileprivate(set) var tableView: UITableView!

    private lazy var keyboardAdjuster: TPTableKeyboardAdjuster = {
        return TPTableKeyboardAdjuster(tableView: tableView)
    }()
    
    var keyboardAdjusterInsetBottom: CGFloat {
        get {
            return keyboardAdjuster.keyboardIntersectionBottom
        }
        
        set {
            keyboardAdjuster.keyboardIntersectionBottom = newValue
        }
    }
    
    var keyboardDismissMode: UIScrollView.KeyboardDismissMode {
        get {
            return tableView.keyboardDismissMode
        }
        
        set {
            tableView.keyboardDismissMode = newValue
        }
    }
    
    var isKeyboardAdjusterEnabled: Bool = false {
        didSet {
            keyboardAdjuster.isEnabled = isKeyboardAdjusterEnabled
        }
    }
    
    /// TableView 视图配置
    var tableViewConfiguration: ((UITableView) -> Void)? {
        didSet {
            tableViewConfiguration?(tableView)
        }
    }

    /// TableView 样式
    private(set) var style: UITableView.Style = .grouped

    private(set) var refreshControl: UIRefreshControl?
    
    var contentSize: CGSize {
        return tableView.contentSize
    }
    
    convenience init(style: UITableView.Style = .grouped) {
        self.init(frame: .zero, style: style)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame)
        self.style = style
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }
    
    func addRefreshControl() {
        self.removeRefreshControl()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                action: #selector(handleRefresh),
                                 for: .valueChanged)
        self.refreshControl = refreshControl
        self.tableView.refreshControl = self.refreshControl
    }

    func removeRefreshControl() {
        self.tableView.refreshControl?.endRefreshing()
        self.tableView.refreshControl = nil
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
    
    func setupSubviews() {
        self.containerView = TPAnimatedContainerView(frame: bounds)
        self.containerView.delegate = self
        self.addSubview(self.containerView)
        
        self.setupTableView()
        self.containerView.setContentView(self.tableView)
    }
    
    func setupTableView() {
        let bAddRefreshControl = self.refreshControl != nil
        var shouldShowPlaceholder: (() -> Bool)?
        if let tableView = tableView {
            shouldShowPlaceholder = tableView.shouldShowPlaceholder
            removeRefreshControl()
            keyboardAdjuster.isEnabled = false
        }

        tableView = UITableView(frame: bounds, style: style)
        tableView.isPrefetchingEnabled = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.shouldShowPlaceholder = shouldShowPlaceholder
        tableViewConfiguration?(tableView)
        
        /// 设置适配器
        adapter.tableView = tableView
        keyboardAdjuster = TPTableKeyboardAdjuster(tableView: tableView)
        keyboardAdjuster.isEnabled = isKeyboardAdjusterEnabled
        updatePlaceholderView()
        if bAddRefreshControl {
            addRefreshControl()
        }
    }
    
    func updatePlaceholderView() {
        tableView.placeholderView = placeholderProvider?.placeholderView()
    }
    
    func reloadData() {
        adapter.reloadData()
        updatePlaceholderView()
        endRefreshing()
    }
    
    func reloadData(animateStyle: SlideStyle) {
        setupTableView()
        containerView.setContentView(tableView, animateStyle: animateStyle)
        reloadData()
    }
    
    /// 执行更新操作
    func performUpdate(with completion: ((Bool) -> Void)? = nil) {
        adapter.performUpdate(completion: completion)
        updatePlaceholderView()
        endRefreshing()
    }
    
    /// 外部配置TableView
    func configure(_ config: (UITableView) -> Void) {
        config(tableView)
    }
    
    func setEditing(_ editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: - TPAnimatedContainerViewDelegate
    func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        return bounds
    }
}
