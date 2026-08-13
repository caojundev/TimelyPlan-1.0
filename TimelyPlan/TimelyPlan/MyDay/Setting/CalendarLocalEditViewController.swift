//
//  CalendarLocalEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/13.
//

import Foundation
import EventKit
import UIKit

class CalendarLocalEditViewController: TPTableSectionsViewController,
                                       CalendarSystemManagerDelegate {

    private let placeholderProvider = CalendarPermissionDeniedPlaceholderProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Local Calendars")
        wrapperView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.01))
        wrapperView.placeholderProvider = placeholderProvider
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        CalendarSystemManager.shared.addDelegate(self)
        CalendarSystemManager.shared.requestAccess { granted in
            self.placeholderProvider.state = .loaded
            self.wrapperView.updatePlaceholderView()
            guard granted else {
                self.reloadData()
                return
            }
            
            CalendarVisibilityManager.shared.resolveVisibleCalendars()
            CalendarSystemManager.shared.fetchSortedGroupedCalendars { result in
                self.reloadData(with: result)
            }
        }
    }
    

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    func reloadData(with result: [(EKSource, [EKCalendar])]) {
        var sectionControllers = [TPTableBaseSectionController]()
        for (source, calendars) in result {
            let sectionController = CalendarSourceSectionController(source: source,
                                                                    calendars: calendars)
            sectionControllers.append(sectionController)
        }
        
        self.sectionControllers = sectionControllers
        reloadData()
    }
    
    // MARK: - CalendarSystemManagerDelegate
    func calendarSystemManagerDidUpdate(_ manager: CalendarSystemManager) {
        CalendarSystemManager.shared.fetchSortedGroupedCalendars { result in
            self.reloadData(with: result)
        }
    }
}

class CalendarPermissionDeniedPlaceholderProvider: TPPlaceholderProviding {
    
    var state: TPListLoadingState = .initialLoading

    func newEmptyPlaceholderView() -> TPPermissionDeniedView {
        let view = TPPermissionDeniedView()
        view.titleLabel.text = resGetString("Calendar Access Required")
        view.subtitleLabel.text = resGetString("Please enable calendar access in Settings to view and manage your events.")
        view.imageView.image = resGetImage("placeholder_calendar_80")
        return view
    }
    
    func newLoadingPlaceholderView() -> TPDefaultPlaceholderView {
        let view = TPDefaultPlaceholderView()
        view.titleColor = .secondaryLabel
        view.titleFont = .boldSystemFont(ofSize: 15.0)
        view.title = resGetString("Loading......")
        return view
    }
    
    func placeholderView() -> UIView? {
        if state == .initialLoading || state == .loading {
            return newLoadingPlaceholderView()
        } else {
            return newEmptyPlaceholderView()
        }
    }
}
