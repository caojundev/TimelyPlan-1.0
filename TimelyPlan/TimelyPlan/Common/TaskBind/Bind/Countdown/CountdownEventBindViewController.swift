//
//  CountdownEventBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/20.
//

import Foundation
import UIKit

class CountdownEventBindViewController: TPViewController,
                                        TPGroupTableViewDelegate {
    
    weak var delegate: TaskBindViewControllerDelegate?
    
    /// 当前选中任务特征值
    private(set) var selectedFeature: TaskFeature?
    
    lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: view.bounds, style: .insetGrouped)
        view.delegate = self
        return view
    }()
    
    lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()
    
    /// 分组标识
    private let groupIdentifier = "CountdownBindGroup"
    
    /// 数据源
    private let viewModel = CountdownEventSelectionViewModel()
    
    init(selectedFeature: TaskFeature?) {
        self.selectedFeature = selectedFeature
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.stopObserving()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        let placeholderProvider = TPDefaultPlaceholderProvider()
        placeholderProvider.emptyImage = resGetImage("countdown_placeholder_80")
        placeholderProvider.emptyTitle = resGetString("No Countdown")
        listView.placeholderProvider = placeholderProvider
        
        viewModel.didChangeEvents = { [weak self] _ in
            self?.reloadList()
        }
        
        viewModel.startObserving()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.listView.frame = self.view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 刷新列表
    private func reloadList() {
        let group = CountdownEventGroup(identifier: groupIdentifier)
        group.events = viewModel.events
        listView.groups = [group]
        listView.reloadData()
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CountdownEventBindCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! CountdownEventBindCell
        cell.style = cellStyle
        cell.event = tableView.item(at: indexPath) as? CountdownEvent
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let event = tableView.item(at: indexPath) as? CountdownEvent else {
            return false
        }
        
        return event.identifier == selectedFeature?.identifier
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = tableView.item(at: indexPath) as? CountdownEvent else {
            return
        }
    
        TPImpactFeedback.impactWithSoftStyle()
        selectedFeature = event.feature
        delegate?.taskBindViewController(self, didSelectTask: event)
        tableView.updateCheckmarks()
    }
}
