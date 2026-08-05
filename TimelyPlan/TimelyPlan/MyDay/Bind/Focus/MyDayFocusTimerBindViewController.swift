//
//  MyDayFocusTimerBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/4.
//

import Foundation
import UIKit

class MyDayFocusTimerBindViewController: TPViewController,
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

    var viewModel = FocusUserTimerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        let placeholderProvider = viewModel.placeholderProvider
        placeholderProvider.emptyTitle = resGetString("No Timer")
        listView.placeholderProvider = placeholderProvider
        viewModel.timersDidChange = { [weak self] change in
            self?.tasksChanged(change)
        }
        
        viewModel.loadTimers()
    }
    
    private func tasksChanged(_ change: FocusUserTimerChange?) {
        DispatchQueue.main.async {
            let group = FocusTimerGroup(identifier: "User")
            group.timers = self.viewModel.timers
            self.listView.groups = [group]
            if case .update(_) = change {
                self.listView.performUpdate(with: .none, completion: nil)
                self.listView.updateCheckmarks()
            } else {
                self.listView.reloadData()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.listView.frame = self.view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return MyDayFocusTimerBindCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! MyDayFocusTimerBindCell
        cell.style = cellStyle
        cell.timer = tableView.item(at: indexPath) as? FocusTimer
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let timer = tableView.item(at: indexPath) as? FocusTimer else {
            return false
        }
        
        return timer.isAddedToMyDay
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let timer = tableView.item(at: indexPath) as? FocusTimer else {
            return
        }
    
        TPImpactFeedback.impactWithSoftStyle()
        let isAddedToMyDay = !timer.isAddedToMyDay
        FocusRepository.updateTimer(timer, isAddedToMyDay: isAddedToMyDay)
    }
}

