//
//  TPTableWrapperView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/31.
//

import Foundation
import UIKit

class TPTableWrapperView: UIView, TPAnimatedContainerViewDelegate {
    
    /// 集合视图适配器
    let adapter = TPTableViewAdapter()
    
    /// 动画容器视图
    private var containerView: TPAnimatedContainerView!
    
    /// 集合视图
    fileprivate(set) var tableView: UITableView!
    
    private var keyboardAdjuster: TPKeyboardAdjuster?
    var isKeyboardAdjusterEnabled: Bool = false {
        didSet {
            setupKeyboardAdjuster()
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
    
    var contentSize: CGSize {
        return tableView.contentSize
    }
    
    deinit {
        tableView.removeKeyboardNotification()
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
    
    private func setupKeyboardAdjuster() {
        if isKeyboardAdjusterEnabled {
            let adjuster = TPKeyboardAdjuster(scrollView: tableView)
            adjuster.isEnabled = true
            self.keyboardAdjuster = adjuster
        } else {
            self.keyboardAdjuster = nil
        }
    }
    
    func setupSubviews() {
        self.containerView = TPAnimatedContainerView(frame: bounds)
        self.containerView.delegate = self
        self.addSubview(self.containerView)
        
        self.setupTableView()
        self.containerView.setContentView(self.tableView)
    }
    
    func setupTableView() {
        if let tableView = tableView {
            /// 移除原tableView的键盘监听
            tableView.removeKeyboardNotification()
        }
        
        tableView = UITableView(frame: bounds, style: style)
        if #available(iOS 15.0, *) {
            tableView.isPrefetchingEnabled = false
        }
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.addKeyboardNotification() /// 添加新的键盘监听
        tableViewConfiguration?(tableView)
        
        /// 设置适配器
        adapter.tableView = tableView
        setupKeyboardAdjuster()
    }

    /// 外部配置TableView
    func configure(_ config: (UITableView) -> Void) {
        config(tableView)
    }
    
    func reloadData() {
        adapter.reloadData()
    }
    
    func reloadData(animateStyle: SlideStyle) {
        setupTableView()
        containerView.setContentView(tableView, animateStyle: animateStyle)
        adapter.reloadData()
    }
    
    func setEditing(_ editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: - TPAnimatedContainerViewDelegate
    func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        return bounds
    }
}
