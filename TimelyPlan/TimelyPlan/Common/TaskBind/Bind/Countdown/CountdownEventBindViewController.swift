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
    
    /// 当前展示的倒数日事项
    private(set) var events: [CountdownEvent] = []
    
    /// 分组标识
    private let groupIdentifier = "CountdownBindGroup"
    
    private let requestManager = TPRequestManager()
    
    init(selectedFeature: TaskFeature?) {
        self.selectedFeature = selectedFeature
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        CountdownRepository.removeUpdater(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        let placeholderProvider = TPDefaultPlaceholderProvider()
        placeholderProvider.emptyImage = resGetImage("countdown_placeholder_80")
        placeholderProvider.emptyTitle = resGetString("No Countdown")
        listView.placeholderProvider = placeholderProvider
        
        CountdownRepository.addUpdater(self, for: [.event])
        loadEvents()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.listView.frame = self.view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 加载倒数日事项
    private func loadEvents() {
        let requestID = requestManager.executeRequest()
        CountdownRepository.fetchActiveEvents { [weak self] events in
            guard let self = self,
                  self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            DispatchQueue.main.async {
                self.events = events ?? []
                self.reloadList()
            }
        }
    }
    
    /// 刷新列表
    private func reloadList() {
        let group = CountdownEventGroup(identifier: groupIdentifier)
        group.events = self.events
        listView.groups = [group]
        listView.reloadData()
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
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

// MARK: - CountdownEventProcessorDelegate
extension CountdownEventBindViewController: CountdownEventProcessorDelegate {
    
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        loadEvents()
    }
    
    func didCreateCountdownEvent(_ event: CountdownEvent) {
        loadEvents()
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent, with change: CountdownEventChange) {
        loadEvents()
    }
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {
        loadEvents()
    }
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {
        loadEvents()
    }
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {
        loadEvents()
    }
}
