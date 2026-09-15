//
//  TPLunarDatePickerTableCellItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation
import UIKit

/// 农历日期选择单元格条目
class TPLunarDatePickerTableCellItem: TPBaseTableCellItem {
    
    /// 当前选中的日期（以公历存储）
    var date: Date = Date().endOfDay()
    
    /// 日期变化回调
    var dateChanged: ((Date) -> Void)?
    
    override init() {
        super.init()
        registerClass = TPLunarDatePickerTableViewCell.self
        selectionStyle = .none
        height = 220.0
    }
}

/// 农历日期选择单元格
class TPLunarDatePickerTableViewCell: TPBaseTableCell,
                                      UIPickerViewDataSource,
                                      UIPickerViewDelegate {
    
    /// 可选年份范围（以当前年份为基准前后各 100 年）
    private let yearRange = 100
    
    /// 行文本字体
    static let rowFont = UIFont.systemFont(ofSize: 18.0)
    
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    /// 可选农历年份（以对应公历年份表示）
    private var years: [Int] = []
    
    /// 当前农历年可选月份
    private var months: [TPLunarMonth] = []
    
    /// 当前农历月可选天数
    private var days: [Int] = []
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            reloadData(animated: true)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupYears()
        contentView.addSubview(pickerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds
    }
    
    /// 初始化可选年份
    private func setupYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear - yearRange)...(currentYear + yearRange))
    }
    
    /// 重新加载选中日期
    func reloadData(animated: Bool) {
        guard let cellItem = cellItem as? TPLunarDatePickerTableCellItem,
              let lunar = TPLunarDateHelper.lunarComponents(from: cellItem.date) else {
            return
        }
        
        updateMonths(ofLunarYear: lunar.year)
        updateDays(month: lunar.month, isLeapMonth: lunar.isLeapMonth)
        pickerView.reloadAllComponents()
        
        if let yearRow = years.firstIndex(of: lunar.year) {
            pickerView.selectRow(yearRow, inComponent: 0, animated: animated)
        }
        
        let monthRow = months.firstIndex {
            $0.month == lunar.month && $0.isLeapMonth == lunar.isLeapMonth
        }
        if let monthRow = monthRow {
            pickerView.selectRow(monthRow, inComponent: 1, animated: animated)
        }
        
        if let dayRow = days.firstIndex(of: lunar.day) {
            pickerView.selectRow(dayRow, inComponent: 2, animated: animated)
        }
    }
    
    private func updateMonths(ofLunarYear year: Int) {
        months = TPLunarDateHelper.months(ofLunarYear: year)
    }
    
    private func updateDays(month: Int, isLeapMonth: Bool) {
        let numberOfDays = months.first {
            $0.month == month && $0.isLeapMonth == isLeapMonth
        }?.numberOfDays ?? 30
        days = Array(1...max(numberOfDays, 1))
    }
    
    /// 年份或月份变化时刷新天数（必要时同步刷新月份）
    private func refreshDaysIfNeeded(forComponent component: Int) {
        switch component {
        case 0:
            /// 年份改变，重新计算月份并保持当前选中月份
            let monthRow = pickerView.selectedRow(inComponent: 1)
            guard let year = years[safe: pickerView.selectedRow(inComponent: 0)] else {
                return
            }
            
            updateMonths(ofLunarYear: year)
            pickerView.reloadComponent(1)
            pickerView.selectRow(min(monthRow, max(months.count - 1, 0)), inComponent: 1, animated: false)
            refreshDays()
        case 1:
            refreshDays()
        default:
            break
        }
    }
    
    /// 刷新天数并保持当前选中天数
    private func refreshDays() {
        let dayRow = pickerView.selectedRow(inComponent: 2)
        let month = months[safe: pickerView.selectedRow(inComponent: 1)]
        updateDays(month: month?.month ?? 1, isLeapMonth: month?.isLeapMonth ?? false)
        pickerView.reloadComponent(2)
        pickerView.selectRow(min(dayRow, max(days.count - 1, 0)), inComponent: 2, animated: false)
    }
    
    /// 通知选中日期变化
    private func notifyDateChanged() {
        guard let cellItem = cellItem as? TPLunarDatePickerTableCellItem,
              let year = years[safe: pickerView.selectedRow(inComponent: 0)],
              let month = months[safe: pickerView.selectedRow(inComponent: 1)],
              let day = days[safe: pickerView.selectedRow(inComponent: 2)],
              let date = TPLunarDateHelper.gregorianDate(lunarYear: year,
                                                         month: month.month,
                                                         day: day,
                                                         isLeapMonth: month.isLeapMonth) else {
            return
        }
        
        cellItem.date = date
        cellItem.dateChanged?(date)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return years.count
        case 1:
            return months.count
        default:
            return days.count
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            /// 年份需要同时展示干支与公历年份，如：甲辰年(2024)
            return 160.0
        case 1:
            return 110.0
        default:
            return 90.0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
            label.textAlignment = .center
            label.numberOfLines = 1
            /// 宽度不足时自动缩小字体，避免出现省略号
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.6
            label.lineBreakMode = .byClipping
        }
        
        label.font = Self.rowFont
        label.text = title(forRow: row, inComponent: component)
        return label
    }
    
    /// 指定行列的显示文本
    private func title(forRow row: Int, inComponent component: Int) -> String? {
        switch component {
        case 0:
            guard let year = years[safe: row] else {
                return nil
            }
            
            /// 显示为干支 + 公历年份，如：甲辰年(2024)
            return "\(LunarCalendar.getChineseYearStemBranch(year: year))年(\(year))"
        case 1:
            return months[safe: row]?.displayName
        default:
            guard let day = days[safe: row] else {
                return nil
            }
            
            return TPLunarDateHelper.dayName(day: day)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        refreshDaysIfNeeded(forComponent: component)
        notifyDateChanged()
    }
}
