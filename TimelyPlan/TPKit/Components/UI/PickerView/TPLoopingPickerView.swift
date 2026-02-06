//
//  TPLoopingPickerView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/19.
//

import Foundation
import UIKit

enum TPPickerViewStyle: Int {
    case system /// 系统默认样式
    case backgroundColorCleared /// 清除背景样式
    case roundedBorder /// 自定义圆角边框
}

@objc protocol TPLoopingPickerViewDataSource {
    
    // 返回列数，默认为1
    @objc optional func numberOfComponents(in pickerView: TPLoopingPickerView) -> Int

    // 返回列对应的循环次数，默认为1
    @objc optional func pickerView(_ pickerView: TPLoopingPickerView, numberOfLoopsInComponent component: Int) -> Int
    
    // 返回每列行数
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfRowsInComponent component: Int) -> Int
    
}

@objc protocol TPLoopingPickerViewDelegate {
    
    // 设置每行的宽度
    @objc optional func pickerView(_ pickerView: TPLoopingPickerView, widthForComponent component: Int) -> CGFloat
    
    // 设置每行的高度
    @objc optional func pickerView(_ pickerView: TPLoopingPickerView, rowHeightForComponent component: Int) -> CGFloat

    @objc optional func pickerView(_ pickerView: TPLoopingPickerView, titleForRow row: Int, forComponent component: Int) -> String?

    @objc optional func pickerView(_ pickerView: TPLoopingPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView?
    
    @objc optional func pickerView(_ pickerView: TPLoopingPickerView, didSelectRow row: Int, inComponent component: Int)
}

@objcMembers
class TPLoopingPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    weak var dataSource: TPLoopingPickerViewDataSource?
    weak var delegate: TPLoopingPickerViewDelegate?
    let defaultRowHeight = 55.0
    
    /// 边框颜色
    var borderColor: UIColor? = .primary

    /// 边框高度
    var borderHeight: CGFloat = 55.0
    
    /// 边框圆角半径
    var borderCornerRadius: CGFloat = 12.0
    
    /// 指示器图层
    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 2.4
        layer.opacity = 0.9
        return layer
    }()

    fileprivate lazy var pickerView: UIPickerView = {
        let view = UIPickerView()
        return view
    }()
    
    let style: TPPickerViewStyle
    
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
        self.style = style
        super.init(frame: frame)
        pickerView.dataSource = self
        pickerView.delegate = self
        addSubview(pickerView)
        
        if style == .roundedBorder {
            layer.addSublayer(borderLayer)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds
        
        guard style != .system else {
            return
        }
        
        clearSelectedRowBackColor()
        
        guard style == .roundedBorder else {
            return
        }
        
        let layoutFrame = layoutFrame()
        let borderLayerY = (bounds.height - borderHeight) / 2.0
        borderLayer.frame = CGRect(x: layoutFrame.minX,
                                   y: borderLayerY,
                                    width: layoutFrame.width,
                                    height: borderHeight)
        let cornerRadius = min(borderHeight / 2.0, borderCornerRadius)
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds,
                                        cornerRadius: cornerRadius).cgPath
        borderLayer.strokeColor = (borderColor ?? tintColor)?.cgColor
    }

    /// 清除选中行背景色
    private func clearSelectedRowBackColor() {
        for view in self.pickerView.subviews {
            view.backgroundColor = UIColor.clear
            view.layer.backgroundColor = UIColor.clear.cgColor
        }
    }

    
    private func targetRow(forWheelRow row: Int, inComponent component: Int) -> Int {
        let rowsCount = dataSource?.pickerView(self, numberOfRowsInComponent: component) ?? 0
        if rowsCount < 1 {
            return -1
        }
        
        return row % rowsCount
    }
    
    private func updateSelectedRow(inComponent component: Int, animated: Bool) {
        let targetRow = selectedRow(inComponent: component)
        selectRow(targetRow, inComponent: component, animated: animated)
    }
    
    private func loopsCountInComponent(_ component: Int) -> Int {
        let loopsCount = dataSource?.pickerView?(self, numberOfLoopsInComponent: component) ?? 1
        return max(1, loopsCount)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        let count = dataSource?.numberOfComponents?(in: self) ?? 1
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let count = dataSource?.pickerView(self, numberOfRowsInComponent: component) ?? 0
        return count * loopsCountInComponent(component) /// 增加数目
    }
    
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if let width = delegate?.pickerView?(self, widthForComponent: component) {
            return width
        }
        
        /// 计算宽度
        let componentsCount = numberOfComponents(in: pickerView)
        if componentsCount > 1 {
            return bounds.width / CGFloat(componentsCount)
        }
        
        return bounds.width
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        if let rowHeight = delegate?.pickerView?(self, rowHeightForComponent: component){
            return rowHeight
        }
        
        return defaultRowHeight
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let targetRow = targetRow(forWheelRow: row, inComponent: component)
        if let view = delegate?.pickerView?(self, viewForRow: targetRow, forComponent: component, reusing: view){
            
            return view
        }
    
        let label = (view as? UILabel) ?? UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.text = delegate?.pickerView?(self, titleForRow: targetRow, forComponent: component)
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let targetRow = targetRow(forWheelRow: row, inComponent: component)
        selectRow(targetRow, inComponent: component, animated: false)
        
        /// 通知代理对象
        delegate?.pickerView?(self, didSelectRow: targetRow, inComponent: component)
    }

    // MARK: - Public methods
    public func reloadAllComponents(){
        pickerView.reloadAllComponents()
        
        let count = numberOfComponents(in: pickerView)
        for i in 0 ..< count {
            updateSelectedRow(inComponent: i, animated: false)
        }
    }
    
    public func reloadComponent(_ component: Int){
        pickerView.reloadComponent(component)
        updateSelectedRow(inComponent: component, animated: false)
    }
 
    /// 选中行
    public func selectRow(_ row: Int, inComponent component: Int, animated: Bool){
        if row < 0 {
            return
        }
        
        let rowsCount = dataSource?.pickerView(self, numberOfRowsInComponent: component) ?? 0
        if rowsCount < 1 {
            return
        }
        
        var targetRow = row
        if row >= rowsCount {
            targetRow = rowsCount - 1
        }
        
        let loopsCount = loopsCountInComponent(component)
        targetRow = rowsCount * (loopsCount / 2) + targetRow
        pickerView.selectRow(targetRow, inComponent: component, animated: animated)
    }

    // 返回选中行索引，没有选择则返回 -1
    public func selectedRow(inComponent component: Int) -> Int {
        let row = pickerView.selectedRow(inComponent: component)
        return targetRow(forWheelRow: row, inComponent: component)
    }
}
