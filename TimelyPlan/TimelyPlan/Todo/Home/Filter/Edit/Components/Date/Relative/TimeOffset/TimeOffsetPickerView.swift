//
//  TimeOffsetPickerView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/15.
//

import Foundation
import UIKit

class TimeOffsetPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var didChangeTimeOffset: ((TimeOffset) -> Void)?
    
    var minimumCount = 0
    
    var maximumCount = 999
    
    var units: [TimeUnit] = [.day, .week, .month, .year]
    
    var timeOffset = TimeOffset()
    
    private let defaultRowHeight = 50.0
    
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
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return TimeOffset.Direction.allCases.count
        } else if component == 1 {
            return maximumCount - minimumCount + 1
        } else {
            return units.count
        }
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
            let direction = TimeOffset.Direction.allCases[row]
            label.text = direction.title
        } else if component == 1 {
            label.text = "\(minimumCount + row)"
        } else {
            let unit = units[row]
            let amount = timeOffset.amount ?? 0
            label.text = unit.localizedUnit(for: amount)
        }
        
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var bChanged = false
        if component == 0 {
            let direction = TimeOffset.Direction.allCases[row]
            if timeOffset.direction != direction {
                timeOffset.direction = direction
                bChanged = true
            }
        } else if component == 1 {
            let amount = minimumCount + row
            if timeOffset.amount != amount {
                timeOffset.amount = amount
                bChanged = true
                
                /// 重新加载单位
                pickerView.reloadComponent(2)
            }
        } else {
            let unit = units[row]
            if timeOffset.unit != unit {
                timeOffset.unit = unit
                bChanged = true
            }
        }
                
        if bChanged {
            didChangeTimeOffset?(timeOffset)
        }
    }

    // MARK: - Private Methods
    func reloadData(animated: Bool = false) {
        pickerView.reloadAllComponents()

        let direction = timeOffset.direction ?? .after
        let directionRow = TimeOffset.Direction.allCases.firstIndex(of: direction) ?? 0
        pickerView.selectRow(directionRow, inComponent: 0, animated: animated)

        var amount = timeOffset.amount ?? 0
        amount = min(max(minimumCount, amount), maximumCount)
        let amountRow = amount - minimumCount
        pickerView.selectRow(amountRow, inComponent: 1, animated: animated)
        
        /// unit
        let unit = timeOffset.unit ?? units[0]
        let unitRow = units.firstIndex(of: unit) ?? 0
        pickerView.selectRow(unitRow, inComponent: 2, animated: animated)
    }
}

