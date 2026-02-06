//
//  TPCalendarViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/11.
//

import Foundation
import UIKit

class TPCalendarViewController: UIViewController {
    
    /// 选中日期回调
    var didSelectDate: ((Date) -> Void)?

    /// 日历尺寸
    var calendarSize: CGSize = CGSize(width: 480.0, height: 480.0)
    
    var calendarView: TPCalendarView!
    
    var contentView: UIView {
        let view = self.view as! UIVisualEffectView
        return view.contentView
    }
    
    override func loadView() {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        self.view = UIVisualEffectView(effect: blurEffect)
    }
    
    var selection: TPCalendarSingleDateSelection
    
    init(date: Date? = nil) {
        let date = date ?? Date()
        let selection = TPCalendarSingleDateSelection()
        selection.selectDate(date.yearMonthDayComponents)
        self.selection = selection
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = calendarSize
        selection.delegate = self
        
        calendarView = TPCalendarView(frame: view.bounds)
        calendarView.selection = selection
        contentView.addSubview(calendarView)
        
        let visibleDateComponents = selection.selectedDate ?? Date.now.components
        calendarView.setVisibleDateComponents(visibleDateComponents.yearMonthDateComponents)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calendarView.frame = contentView.bounds
    }
}

extension TPCalendarViewController: TPCalendarSingleDateSelectionDelegate {
    
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        dismiss(animated: true, completion: nil)
        didSelectDate?(Date.dateFromComponents(date)!)
    }
}
