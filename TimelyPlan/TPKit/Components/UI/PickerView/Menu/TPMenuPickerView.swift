//
//  TPMenuPickerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/21.
//

import Foundation
import UIKit

class TPMenuPickerView<T: TPMenuRepresentable>: UIView,
                                                TPLoopingPickerViewDataSource,
                                                TPLoopingPickerViewDelegate {
    
    /// 菜单选项数组
    var menuItems: [T] = [] {
        didSet {
            // 只在视图已加载的情况下重新加载数据
            if pickerView != nil {
                reloadData()
            }
        }
    }
    
    /// 当前选中的菜单项
    private(set) var selectedItem: T? {
        didSet {
            // 只在选中项实际改变时才触发回调
            if let item = selectedItem, oldValue?.identifier != item.identifier {
                didPickItem?(item)
            }
        }
    }
    
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
    
    /// 数字字体（纯数字时显示的字体）
    var numberFont: UIFont = UIFont.preferredFont(forTextStyle: .title1) {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    /// 文本字体（其它文本显示的字体）
    var textFont: UIFont = UIFont.preferredFont(forTextStyle: .body) {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    /// 兼容性：保留原有的 font 属性
    var font: UIFont {
        get {
            return numberFont
        }
        
        set {
            numberFont = newValue
        }
    }
    
    /// 文本颜色
    var textColor: UIColor = .label {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    /// 数字文本颜色（纯数字时显示的颜色）
    var numberTextColor: UIColor? {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    /// 选中菜单项回调
    var didPickItem: ((T) -> Void)?
    
    /// 是否在菜单视图控制器dismiss前回调
    var handleBeforeDismiss: Bool = false
    
    /// 选择器
    private var pickerView: TPLoopingPickerView!
    
    // MARK: - 初始化方法
    
    convenience init() {
        self.init(frame: .zero, style: .system)
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, style: .system)
    }
    
    convenience init(style: TPPickerViewStyle) {
        self.init(frame: .zero, style: style)
    }
    
    convenience init(menuItems: [T]) {
        self.init(frame: .zero, style: .system)
        self.menuItems = menuItems
    }
    
    init(frame: CGRect, style: TPPickerViewStyle) {
        super.init(frame: frame)
        pickerView = TPLoopingPickerView(frame: bounds, style: style)
        pickerView.dataSource = self
        pickerView.delegate = self
        addSubview(pickerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds
    }
    
    // MARK: - 辅助方法
    
    /// 判断字符串是否为纯数字
    private func isNumericString(_ string: String) -> Bool {
        let numericSet = CharacterSet.decimalDigits
        let stringSet = CharacterSet(charactersIn: string)
        return !string.isEmpty && numericSet.isSuperset(of: stringSet)
    }
    
    /// 获取适合的字体
    private func appropriateFont(for text: String) -> UIFont {
        return isNumericString(text) ? numberFont : textFont
    }
    
    /// 获取适合的文本颜色
    private func appropriateTextColor(for text: String) -> UIColor {
        if isNumericString(text), let numberTextColor = numberTextColor {
            return numberTextColor
        }
        return textColor
    }
    
    // MARK: - 数据加载与选择
    
    /// 重新加载数据
    func reloadData() {
        pickerView.reloadAllComponents()
        if !menuItems.isEmpty {
            // 如果有选中的项，恢复选中状态
            if let selectedItem = selectedItem,
               let index = menuItems.firstIndex(where: { $0.identifier == selectedItem.identifier }) {
                selectItem(at: index, animated: false, triggerCallback: false)
            } else {
                // 默认选中第一个
                selectItem(at: 0, animated: false, triggerCallback: false)
            }
        }
    }
    
    /// 根据索引选择菜单项
    /// - Parameters:
    ///   - index: 菜单项索引
    ///   - animated: 是否动画
    ///   - triggerCallback: 是否触发回调
    func selectItem(at index: Int, animated: Bool, triggerCallback: Bool = true) {
        guard index >= 0 && index < menuItems.count else { return }
        let row = index
        pickerView.selectRow(row, inComponent: 0, animated: animated)
        
        let newItem = menuItems[index]
        if triggerCallback {
            selectedItem = newItem
        } else {
            // 直接设置，不触发回调
            let oldItem = selectedItem
            selectedItem = newItem
            if oldItem?.identifier == newItem.identifier {
                // 如果相同，恢复原值避免触发 didSet
                selectedItem = oldItem
            }
        }
    }
    
    /// 根据唯一标识符选择菜单项
    /// - Parameters:
    ///   - identifier: 菜单项唯一标识符
    ///   - animated: 是否动画
    func selectItem(withIdentifier identifier: String, animated: Bool) {
        guard let index = menuItems.firstIndex(where: { $0.identifier == identifier }) else { return }
        selectItem(at: index, animated: animated)
    }
    
    /// 根据标签选择菜单项
    /// - Parameters:
    ///   - tag: 菜单项标签
    ///   - animated: 是否动画
    func selectItem(withTag tag: Int, animated: Bool) {
        guard let index = menuItems.firstIndex(where: { $0.tag == tag }) else { return }
        selectItem(at: index, animated: animated)
    }
    
    /// 获取指定索引的菜单项
    /// - Parameter index: 索引
    /// - Returns: 菜单项，如果索引无效返回nil
    func menuItem(at index: Int) -> T? {
        guard index >= 0 && index < menuItems.count else { return nil }
        return menuItems[index]
    }
    
    // MARK: - TPLoopingPickerViewDataSource
    
    func numberOfComponents(in pickerView: TPLoopingPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfRowsInComponent component: Int) -> Int {
        return menuItems.count
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfLoopsInComponent component: Int) -> Int {
        return 100
    }
    
    // MARK: - TPLoopingPickerViewDelegate
    
    func pickerView(_ pickerView: TPLoopingPickerView, widthForComponent component: Int) -> CGFloat {
        return self.width - pickerView.layoutMargins.horizontalLength
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return componentHeight
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        
        guard row >= 0 && row < menuItems.count else { return nil }
        
        let item = menuItems[row]
        handleBeforeDismiss = item.handleBeforeDismiss
        
        // 尝试重用视图
        var label: UILabel
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
            label.adjustsFontSizeToFitWidth = true
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.minimumScaleFactor = 0.5
        }
        
        // 配置标签
        let title = item.title
        label.text = title
        
        // 根据内容类型设置字体
        label.font = appropriateFont(for: title)
        
        // 根据内容类型设置颜色
        label.textColor = appropriateTextColor(for: title)
        
        return label
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row >= 0 && row < menuItems.count else { return }
        selectedItem = menuItems[row]
    }
}

// MARK: - 便利扩展
extension TPMenuPickerView {
    
    /// 获取所有菜单项标题
    /// - Returns: 标题数组
    func getAllTitles() -> [String] {
        return menuItems.map { $0.title }
    }
    
    /// 获取当前选中项的索引
    /// - Returns: 索引，如果没有选中项则返回nil
    func selectedIndex() -> Int? {
        guard let selectedItem = selectedItem else { return nil }
        return menuItems.firstIndex(where: { $0.identifier == selectedItem.identifier })
    }
    
    /// 设置选中的菜单项
    /// - Parameters:
    ///   - item: 要选中的菜单项
    ///   - animated: 是否动画
    func selectItem(_ item: T, animated: Bool) {
        selectItem(withIdentifier: item.identifier, animated: animated)
    }
}
