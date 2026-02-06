//
//  TPYearMonthDatePickerView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/13.
//

import Foundation
import UIKit

enum TPYearMonthDatePickerMode {
    case yearAndMonth
    case yearOnly
}

class TPYearMonthDatePickerView: UIView,
                                 TPLoopingPickerViewDataSource,
                                 TPLoopingPickerViewDelegate {
    
    var mode: TPYearMonthDatePickerMode = .yearAndMonth
    
    private var yearComponent: Int = 0
    private var monthComponent: Int = 1

    private var pickerView: TPLoopingPickerView!
    
    private lazy var monthSymbols: [String] = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        if Language.isChinese {
            return dateFormatter.shortMonthSymbols ?? []
        } else {
            return dateFormatter.monthSymbols ?? []
        }
    }()
    
    private var fromYear: Int = 1
    private var toYear: Int = 10000

    private var _date: Date = Date()
    var date: Date {
        
        get {
            return _date
        }
        
        set {
            _date = newValue
            updateSelectedRow()
        }
    }
    
    var didPickDate: ((Date) -> Void)?
    
    convenience init() {
        self.init(frame: .zero, mode: .yearOnly)
    }
    
    convenience init(mode: TPYearMonthDatePickerMode) {
        self.init(frame: .zero, mode: mode)
    }
    
    init(frame: CGRect, mode: TPYearMonthDatePickerMode) {
        self.mode = mode
        if mode == .yearAndMonth && Language.isEnglish {
            swapValues(&yearComponent, &monthComponent)
        }
        
        super.init(frame: frame)
        
        self.pickerView = TPLoopingPickerView(frame: bounds, style: .system)
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.addSubview(self.pickerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pickerView.frame = self.bounds
    }
    
    // MARK: - TPLoopingPickerViewDataSource
    func numberOfComponents(in pickerView: TPLoopingPickerView) -> Int {
        if mode == .yearOnly {
            return 1
        } else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfLoopsInComponent component: Int) -> Int {
        if component == monthComponent {
            return 1000
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == monthComponent {
            return self.monthSymbols.count
        } else {
            return self.toYear - self.fromYear + 1
        }
    }
    
    // MARK: - TPLoopingPickerViewDelegate
    func pickerView(_ pickerView: TPLoopingPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == monthComponent {
            return self.monthSymbols[row]
        } else {
            let year = self.fromYear + row
            if Language.isChinese {
                return "\(year)年"
            } else {
                return "\(year)"
            }
        }
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, didSelectRow row: Int, inComponent component: Int) {
        let calendar = Calendar.current
        let unitFlags: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        var components = calendar.dateComponents(unitFlags, from: self.date)
        if component == monthComponent {
            let month = row + 1
            components.month = month
        } else {
            let year = self.fromYear + row
            components.year = year
        }
        
        if let newDate = calendar.date(from: components), _date != newDate {
            _date = newDate
            self.didPickDate?(_date)
        }
    }
    
    // MARK: - Private Methods
    private func updateSelectedRow() {
        let yearRow = targetRow(forYear: date.year)
        self.pickerView.selectRow(yearRow, inComponent: yearComponent, animated: true)
        
        if mode == .yearAndMonth {
            let monthRow = targetRow(forMonth: date.month)
            self.pickerView.selectRow(monthRow, inComponent: monthComponent, animated: true)
        }
    }
    
    private func targetRow(forYear year: Int) -> Int {
        let row = year - self.fromYear
        let maxRow = self.toYear - self.fromYear
        return min(maxRow, max(row, 0))
    }

    private func targetRow(forMonth month: Int) -> Int {
        let kMonthsCountInAYear: Int = 12
        let month = min(kMonthsCountInAYear, max(month, 1))
        return month - 1
    }
}
