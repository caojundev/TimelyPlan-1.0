//
//  TPTableViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation
import UIKit

class TPTableViewController: TPViewController {
    
    var adapter: TPTableViewAdapter {
        return wrapperView.adapter
    }
    
    /// tableView 样式
    private(set) var style: UITableView.Style = .insetGrouped
    
    /// tableView 封装视图
    private(set) lazy var wrapperView: TPTableWrapperView = {
        let view = TPTableWrapperView(frame: view.bounds, style: style)
        return view
    }()
    
    var tableView: UITableView {
        return wrapperView.tableView
    }

    init(style: UITableView.Style) {
        super.init(nibName: nil, bundle: nil)
        self.style = style
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.wrapperView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        wrapperView.frame = tableViewFrame()
    }
    
    func tableViewFrame() -> CGRect {
        return view.bounds
    }
    
    func reloadData() {
        adapter.reloadData()
    }
}


class TPTableSectionsViewController: TPTableViewController,
                                     TPTableSectionControllersList {

    var sectionControllers: [TPTableBaseSectionController]?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.dataSource = self
        adapter.delegate = self
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let actionsBar = actionsBar {
            actionsBar.backgroundColor = view.backgroundColor
            wrapperView.height = actionsBar.top - wrapperView.top
        }
    }
    
}
