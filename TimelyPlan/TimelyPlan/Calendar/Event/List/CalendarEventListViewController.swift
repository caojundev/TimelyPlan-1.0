//
//  CalendarEventListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/28.
//

import Foundation

class CalendarEventListViewController: TPViewController,
                                        TPGroupTableViewDelegate {
    
    let options: CalendarEventListOptions
    
    /// 事件供应者
    private let eventsViewModel = CalendarEventsViewModel()
    
    /// 事件处理器
    private let eventProcessor = CalendarEventProcessor()
    
    private lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .systemBackground
        style.selectedBackgroundColor = .secondarySystemBackground
        return style
    }()
    
    let headerViewHeight = 50.0
    
    private lazy var headerView: CalendarEventListHeaderView = {
        let view = CalendarEventListHeaderView()
        return view
    }()
    
    private lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: view.bounds, style: .grouped)
        view.delegate = self
        return view
    }()
    
    init(options: CalendarEventListOptions) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.date = options.date
        view.addSubview(headerView)
        
        let placeholderProvider = eventsViewModel.placeholderProvider
        placeholderProvider.emptyTitle = resGetString("No Events")
        placeholderProvider.emptyImage = resGetImage("todo_smartlist_today_80")
        listView.placeholderProvider = placeholderProvider
        view.addSubview(listView)
        eventsViewModel.onEventsChanged = { [weak self] in
            self?.eventsChanged()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventsViewModel.loadEvents(in: options.dateRange)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.bounds.inset(by: UIEdgeInsets(top: 20.0))
        headerView.width = layoutFrame.width
        headerView.height = headerViewHeight
        headerView.origin = layoutFrame.origin
        
        listView.width = layoutFrame.width
        listView.height = layoutFrame.height - headerViewHeight
        listView.top = headerView.bottom
    }
    
    private func eventsChanged() {
        let group = CalendarEventGroup(identifier: "EventGroup")
        group.events = eventsViewModel.events
        DispatchQueue.main.async {
            self.listView.groups = [group]
            self.listView.reloadData()
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
        cell.date = options.date
        cell.event = event
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = tableView.item(at: indexPath) as? CalendarEvent else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        eventProcessor.clickEvent(event)
    }
    
}
