//
//  MonthWeekdaySelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/22.
//

import Foundation
import UIKit

class RepeatWeekdayOfMonthPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var didPickDayOfTheWeek: ((RepeatDayOfWeek) -> Void)?
    
    var dayOfTheWeek: RepeatDayOfWeek {
        return RepeatDayOfWeek(dayOfTheWeek: selectedWeekday, weekNumber: selectedWeekNumber.rawValue)
    }
    
    private var selectedWeekNumber: RepeatWeekNumber = .first
    
    private var selectedWeekday: Weekday = .monday
    
    private let weekNumbers: [RepeatWeekNumber] = [.first,
                                                   .second,
                                                   .third,
                                                   .fourth,
                                                   .fifth,
                                                   .last]
    private let weekdays = kSundayLastOrderedWeekdays
    
    private let defaultRowHeight = 40.0
    
    fileprivate lazy var pickerView: UIPickerView = {
        let view = UIPickerView()
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pickerView)
        reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return weekNumbers.count
        }
        
        return weekdays.count
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return defaultRowHeight
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? TPLabel) ?? TPLabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = BOLD_BODY_FONT
        if component == 0 {
            let weekNumber = weekNumbers[row]
            label.text = weekNumber.title
        } else {
            let weekday = weekdays[row]
            label.text = weekday.symbol
        }
        
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedWeekNumber = weekNumbers[row]
        } else {
            selectedWeekday = weekdays[row]
        }
    
        didPickDayOfTheWeek?(dayOfTheWeek)
    }

    // MARK: - Private Methods
    private func reloadData(animated: Bool = false) {
        pickerView.reloadAllComponents()
        updateSelectedWeekNumber(animated: animated)
        updateSelectedWeekday(animated: animated)
    }
    
    private func updateSelectedWeekNumber(animated: Bool) {
        let row = weekNumbers.firstIndex(of: selectedWeekNumber) ?? 0
        pickerView.selectRow(row, inComponent: 0, animated: animated)
    }
    
    private func updateSelectedWeekday(animated: Bool) {
        let row = weekdays.firstIndex(of: selectedWeekday) ?? 0
        pickerView.selectRow(row, inComponent: 1, animated: animated)
    }
    
    // MARK: - Public Methods
    func selectDayOfTheWeek(_ dayOfTheWeek: RepeatDayOfWeek, animated: Bool) {
        selectedWeekNumber = RepeatWeekNumber(rawValue: dayOfTheWeek.weekNumber) ?? .first
        selectedWeekday = dayOfTheWeek.dayOfTheWeek
        reloadData(animated: animated)
    }
}
