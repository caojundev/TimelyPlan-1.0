//
//  TPYearMonthDatePickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/13.
//

import Foundation
import UIKit

class TPYearMonthDatePickerViewController: UIViewController {
    let kPreferredContentSize = CGSize(width: 400.0, height: 300.0)
    let kButtonMargin: CGFloat = 15.0
    let kButtonHeight: CGFloat = 56.0

    var date: Date = Date()
    
    var didPickDate: ((Date) -> Void)?
    
    var datePickerView: TPYearMonthDatePickerView!
    
    lazy var currentDateButton: TPDefaultButton = {
        let color = UIColor.label.withAlphaComponent(0.6)
        let button = TPDefaultButton.outlineButton(withTitle: nil,
                                                   textColor: color,
                                                   borderColor: color)
        button.selectedBackgroundColor = .clear
        button.borderWidth = 2.4
        button.titleConfig.font = BOLD_BODY_FONT
        button.imagePosition = .left
        button.imageConfig.margins = UIEdgeInsets(right: 5.0)
        button.addTarget(self, action: #selector(clickCurrent(_:)), for: .touchUpInside)
        return button
    }()

    lazy var doneButton: TPDefaultButton = {
        let color = UIColor.label.withAlphaComponent(0.6)
        let button = TPDefaultButton.outlineButton(withTitle: resGetString("Confirm"),
                                                   textColor: color,
                                                   borderColor: color)
        button.selectedBackgroundColor = .clear
        button.borderWidth = 2.4
        button.titleConfig.font = BOLD_BODY_FONT
        button.imagePosition = .left
        button.imageConfig.margins = UIEdgeInsets(right: 5.0)
        button.addTarget(self, action: #selector(clickDone(_:)), for: .touchUpInside)
        return button
    }()

    var contentView: UIView {
        let view = self.view as! UIVisualEffectView
        return view.contentView
    }
    
    let mode: TPYearMonthDatePickerMode
    
    convenience init() {
        self.init(mode: .yearAndMonth)
    }
    
    init(mode: TPYearMonthDatePickerMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        self.view = UIVisualEffectView(effect: blurEffect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = kPreferredContentSize
        self.datePickerView = TPYearMonthDatePickerView(mode: mode)
        self.datePickerView.date = self.date
        self.datePickerView.didPickDate = { [weak self] date in
            self?.didPickDate(date: date)
        }
    
        contentView.addSubview(self.datePickerView)
        contentView.addSubview(self.currentDateButton)
        contentView.addSubview(self.doneButton)
        
        if mode == .yearAndMonth {
            currentDateButton.title = resGetString("Current Month")
        } else {
            currentDateButton.title = resGetString("This Year")
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let layoutFrame = view.bounds.inset(by: UIEdgeInsets(value: 15.0))
        let buttonWidth = (layoutFrame.width - kButtonMargin) / 2.0
        
        currentDateButton.width = buttonWidth
        currentDateButton.height = kButtonHeight
        
        let isCurrentDateButtonHidden = (mode == .yearAndMonth && date.isInCurrentMonth) ||
                                        (mode == .yearOnly && date.isInCurrentYear)
        if isCurrentDateButtonHidden {
            currentDateButton.alpha = 0.0
            currentDateButton.right = layoutFrame.minX
            currentDateButton.bottom = layoutFrame.maxY
            
            doneButton.width = layoutFrame.width
            doneButton.height = kButtonHeight
            doneButton.left = layoutFrame.minX
            doneButton.bottom = layoutFrame.maxY
        } else {
            currentDateButton.alpha = 1.0
            currentDateButton.left = layoutFrame.minX
            currentDateButton.bottom = layoutFrame.maxY
            
            doneButton.frame = currentDateButton.frame
            doneButton.left = currentDateButton.right + kButtonMargin
        }
        
        currentDateButton.cornerRadius = .greatestFiniteMagnitude
        doneButton.cornerRadius = .greatestFiniteMagnitude

        datePickerView.frame = layoutFrame
        datePickerView.height = doneButton.top - kButtonMargin - layoutFrame.minY
    }
    
    func didPickDate(date: Date) {
        if self.date.isInSameMonthAs(date) {
            return
        }
        
        self.date = date
        view.animateLayout(withDuration: 0.25)
    }
    
    @objc func clickCurrent(_ button: TPDefaultButton) {
        TPImpactFeedback.impactWithSoftStyle()
        self.date = Date()
        datePickerView.date = self.date
        view.animateLayout(withDuration: 0.25)
    }
    
    @objc func clickDone(_ button: TPDefaultButton) {
        TPImpactFeedback.impactWithSoftStyle()
        let date = self.datePickerView.date
        self.didPickDate?(date)
        self.dismiss(animated: true, completion: nil)
    }
}
