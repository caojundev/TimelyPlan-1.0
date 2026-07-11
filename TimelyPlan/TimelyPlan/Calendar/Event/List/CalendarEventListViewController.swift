//
//  CalendarEventListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/28.
//

import Foundation
import UIKit

class CalendarEventListViewController: TPViewController {
    
    let headerViewHeight: CGFloat = 50.0
    
    private lazy var headerView: CalendarEventListHeaderView = {
        let view = CalendarEventListHeaderView()
        return view
    }()
    
    private lazy var eventListView: CalendarEventListView = {
        let view = CalendarEventListView(frame: view.bounds)
        return view
    }()
    
    private let eventProcessor = CalendarEventProcessor()

    let options: CalendarEventListOptions
    
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
        view.addSubview(eventListView)
        
        eventListView.onEventSelected = { [weak self] event in
            self?.selectEvent(event)
        }
        
        eventListView.reloadEvents(options: options)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.bounds.inset(by: UIEdgeInsets(top: 20.0))
        
        headerView.frame = CGRect(
            x: layoutFrame.origin.x,
            y: layoutFrame.origin.y,
            width: layoutFrame.width,
            height: headerViewHeight
        )
        
        eventListView.frame = CGRect(
            x: layoutFrame.origin.x,
            y: headerView.frame.maxY,
            width: layoutFrame.width,
            height: layoutFrame.height - headerViewHeight
        )
    }
    
    private func selectEvent(_ event: CalendarEvent) {
        TPImpactFeedback.impactWithSoftStyle()
        eventProcessor.clickEvent(event)
    }
}
