//
//  MyDayCountdownEventBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/23.
//

import Foundation
import UIKit

class MyDayCountdownEventBindViewController: TPViewController,
                                             TPGroupTableViewDelegate {

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
    private let groupIdentifier = "MyDayCountdownBindGroup"
    
    private let requestManager = TPRequestManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        let placeholderProvider = TPDefaultPlaceholderProvider()
        placeholderProvider.emptyTitle = resGetString("No Countdown")
        listView.placeholderProvider = placeholderProvider
        
        CountdownRepository.addUpdater(self, for: [.event])
        loadEvents()
    }
    
    deinit {
        CountdownRepository.removeUpdater(self)
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
        return MyDayCountdownEventBindCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! MyDayCountdownEventBindCell
        cell.style = cellStyle
        cell.event = tableView.item(at: indexPath) as? CountdownEvent
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let event = tableView.item(at: indexPath) as? CountdownEvent else {
            return false
        }
        
        return MyDayCountdownBindHandler.isAddedToMyDay(event)
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = tableView.item(at: indexPath) as? CountdownEvent else {
            return
        }
    
        TPImpactFeedback.impactWithSoftStyle()
        let sourceView = tableView.cell(for: event) ?? tableView
        MyDayCountdownBindHandler.handleSelection(of: event, from: sourceView)
    }
}

// MARK: - CountdownEventProcessorDelegate
extension MyDayCountdownEventBindViewController: CountdownEventProcessorDelegate {
    
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        loadEvents()
    }
    
    func didCreateCountdownEvent(_ event: CountdownEvent) {
        loadEvents()
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent, with change: CountdownEventChange) {
        guard case let .content(oldValue, newValue) = change,
              oldValue.myDayDisplayMode != newValue.myDayDisplayMode else {
            loadEvents()
            return
        }
        
        /// 仅「我的一天」显示方式变化时，同步本地数据并即时刷新选中状态
        if let index = self.events.firstIndex(where: { $0.identifier == event.identifier }) {
            self.events[index].myDayDisplayMode = newValue.myDayDisplayMode
        }
        
        DispatchQueue.main.async {
            self.listView.updateCheckmarks()
        }
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
