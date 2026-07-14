//
//  CalendarEventListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/10.
//

import Foundation
import UIKit

class CalendarEventListView: UIView, TPGroupTableViewDelegate {
    
    // MARK: - Properties
    var onEventSelected: ((CalendarEvent) -> Void)?
    
    private let eventsViewModel = CalendarEventsViewModel()
    
    private lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .systemBackground
        style.selectedBackgroundColor = .secondarySystemBackground
        return style
    }()
    
    private lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: bounds, style: .grouped)
        view.tableViewConfiguration = { tableView in
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.1))
            tableView.contentInset = UIEdgeInsets(bottom: 120.0)
        }
    
        view.delegate = self

        let placeholderProvider = eventsViewModel.placeholderProvider
        placeholderProvider.emptyTitle = resGetString("No Events")
        placeholderProvider.emptyImage = resGetImage("placeholder_calendar_80")
        view.placeholderProvider = placeholderProvider
        return view
    }()
    
    private(set) var options: CalendarEventListOptions?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(listView)
    }
    
    private func setupBindings() {
        eventsViewModel.onEventsChanged = { [weak self] in
            self?.handleEventsChanged()
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        listView.frame = bounds
    }
    
    // MARK: - Public Methods
    func reloadEvents(options: CalendarEventListOptions,
                      animated: Bool = false) {
        var animateStyle: SlideStyle = .none
        if animated, let oldOptions = self.options {
            animateStyle = .horizontalStyle(fromValue: oldOptions.date, toValue: options.date)
        }
        
        self.options = options
        
        listView.groups = nil
        listView.reloadData(animateStyle: animateStyle)
        eventsViewModel.loadEvents(in: options.dateRange)
        listView.updatePlaceholderView()
    }
    
    // MARK: - Private Methods
    private func handleEventsChanged() {
        let group = CalendarEventGroup(identifier: "EventGroup")
        group.events = eventsViewModel.events
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.listView.groups = [group]
            self.listView.performUpdate(with: .fade, completion: nil)
        }
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarEventListCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarEventListCell,
              let event = tableView.item(at: indexPath) as? CalendarEvent else {
            return
        }
        
        cell.style = cellStyle
        cell.date = options?.date
        cell.event = event
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = tableView.item(at: indexPath) as? CalendarEvent else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        onEventSelected?(event)
    }
}

