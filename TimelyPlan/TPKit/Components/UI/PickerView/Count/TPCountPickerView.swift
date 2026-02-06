//
//  TPCountPickerView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation
import UIKit

class TPCountPickerView: UIView,
                            TPLoopingPickerViewDataSource,
                            TPLoopingPickerViewDelegate {
    /// 当前数值
    var count: Int = 0

    /// 最小数目
    var minimumCount: Int = 1

    /// 最大数目
    var maximumCount: Int = 100

    /// 步长
    var stepCount: Int = 1

    /// 部件行高度
    var componentHeight: CGFloat = 50.0 {
        didSet {
            pickerView.borderHeight = componentHeight
        }
    }
    
    /// 边框颜色
    var borderColor: UIColor? {
        get {
            return pickerView.borderColor
        }
        
        set {
            pickerView.borderColor = newValue
        }
    }
    
    /// 边框圆角半径
    var borderCornerRadius: CGFloat {
        get {
            return pickerView.borderCornerRadius
        }
        
        set {
            pickerView.borderCornerRadius = newValue
        }
    }
    
    var font: UIFont = UIFont.preferredFont(forTextStyle: .title1)

    /// 选中数目回调
    var didPickCount: ((Int) -> Void)?
    
    var leadingTextForCount: ((Int) -> String?)?
    
    var tailingTextForCount: ((Int) -> String?)?
    
    // 头标签
    private(set) lazy var leadingLabel: UILabel = {
        let label = TPLabel()
        label.isUserInteractionEnabled = false
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.edgeInsets = UIEdgeInsets(left: 10.0, right: 5.0)
        label.font = BOLD_BODY_FONT
        return label
    }()
    
    // 尾标签
    private(set) lazy var tailingLabel: UILabel = {
        let label = TPLabel()
        label.isUserInteractionEnabled = false
        label.adjustsFontSizeToFitWidth = true
        label.edgeInsets = UIEdgeInsets(left: 5.0, right: 10.0)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = BOLD_BODY_FONT
        return label
    }()
    
    /// 选择器
    private var pickerView: TPLoopingPickerView!
    
    convenience init() {
        self.init(frame: .zero, style: .system)
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, style: .system)
    }
    
    convenience init(style: TPPickerViewStyle) {
        self.init(frame: .zero, style: style)
    }
    
    init(frame: CGRect, style: TPPickerViewStyle) {
        super.init(frame: frame)
        pickerView = TPLoopingPickerView(frame: bounds, style: style)
        pickerView.dataSource = self
        pickerView.delegate = self
        addSubview(pickerView)
        addSubview(leadingLabel)
        addSubview(tailingLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds
        let layoutFrame = bounds.inset(by: pickerView.layoutMargins)
        let labelWidth = layoutFrame.width / 3.0
        leadingLabel.width = labelWidth
        leadingLabel.height = componentHeight
        leadingLabel.left = layoutFrame.minX
        leadingLabel.alignVerticalCenter()
        
        tailingLabel.size = leadingLabel.size
        tailingLabel.right = layoutFrame.maxX
        tailingLabel.alignVerticalCenter()
    }
    
    // MARK: - 加载数据
    func reloadData() {
        pickerView.reloadAllComponents()
        selectCount(self.count, animated: false)
    }
    
    func selectCount(_ count: Int, animated: Bool) {
        self.count = min(max(count, minimumCount), maximumCount)
        let row = (self.count - minimumCount) / stepCount
        pickerView.selectRow(row, inComponent: 0, animated: animated)
        updateLeadingTailingText()
    }
    
    private func updateLeadingTailingText() {
        leadingLabel.text = leadingTextForCount?(count)
        tailingLabel.text = tailingTextForCount?(count)
    }
    
    // MARK: - TPLoopingPickerViewDataSource
    func numberOfComponents(in pickerView: TPLoopingPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rowsCount = (maximumCount + stepCount - minimumCount) / stepCount
        rowsCount = max(0, rowsCount)
        return rowsCount
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfLoopsInComponent component: Int) -> Int {
        return 100
    }
    
    // MARK: - TPLoopingPickerViewDelegate
    func pickerView(_ pickerView: TPLoopingPickerView, widthForComponent component: Int) -> CGFloat {
        return (self.width - pickerView.layoutMargins.horizontalLength) / 3.0
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return componentHeight
    }
 
    func pickerView(_ pickerView: TPLoopingPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        var label: UILabel
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
            label.adjustsFontSizeToFitWidth = true
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = self.font
        }
    
        let count = minimumCount + row * stepCount
        let title = "\(count)"
        label.text = title
        return label
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, didSelectRow row: Int, inComponent component: Int) {
        count = minimumCount + row * stepCount
        didPickCount?(count)
        updateLeadingTailingText()
    }
}
