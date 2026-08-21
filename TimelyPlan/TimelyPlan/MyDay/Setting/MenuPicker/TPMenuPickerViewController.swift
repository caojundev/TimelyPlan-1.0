//
//  TPMenuPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/21.
//

import Foundation
import UIKit

class TPMenuPickerViewController<T: TPMenuRepresentable>: TPViewController {
    
    /// 菜单选项数组
    var menuItems: [T] = [] {
        didSet {
            if isViewLoaded {
                reloadData()
            }
        }
    }
    
    /// 当前选中的菜单项
    var selectedItem: T? {
        didSet {
            if isViewLoaded && oldValue?.identifier != selectedItem?.identifier {
                reloadData()
            }
        }
    }
    
    /// 选中菜单项回调
    var didPickItem: ((T) -> Void)?
    
    /// 内容尺寸
    var contentSize: CGSize = CGSize(width: AppLayout.Popover.preferredContentWidth, height: 260.0)
    
    /// 部件行高度
    var componentHeight: CGFloat {
        get {
            return pickerView.componentHeight
        }
        
        set {
            pickerView.componentHeight = newValue
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
    var numberFont: UIFont {
        get {
            return pickerView.numberFont
        }
        
        set {
            pickerView.numberFont = newValue
        }
    }
    
    /// 文本字体（其它文本显示的字体）
    var textFont: UIFont {
        get {
            return pickerView.textFont
        }
        
        set {
            pickerView.textFont = newValue
        }
    }
    
    /// 兼容性：保留原有的 font 属性
    var font: UIFont {
        get {
            return pickerView.font
        }
        
        set {
            pickerView.font = newValue
        }
    }
    
    /// 文本颜色
    var textColor: UIColor {
        get {
            return pickerView.textColor
        }
        
        set {
            pickerView.textColor = newValue
        }
    }
    
    /// 数字文本颜色（纯数字时显示的颜色）
    var numberTextColor: UIColor? {
        get {
            return pickerView.numberTextColor
        }
        
        set {
            pickerView.numberTextColor = newValue
        }
    }
    
    /// 是否在菜单视图控制器dismiss前回调
    var handleBeforeDismiss: Bool {
        return pickerView.handleBeforeDismiss
    }
    
    private lazy var pickerView: TPMenuPickerView<T> = {
        let view = TPMenuPickerView<T>()
        return view
    }()

    private var contentView: UIView {
        let view = view as! UIVisualEffectView
        return view.contentView
    }
    
    // MARK: - 初始化方法
    
    convenience init(menuItems: [T]) {
        self.init()
        self.menuItems = menuItems
        if let firstItem = menuItems.first {
            self.selectedItem = firstItem
        }
    }
    
    convenience init(menuItems: [T], selectedItem: T?) {
        self.init()
        self.menuItems = menuItems
        self.selectedItem = selectedItem ?? menuItems.first
    }
    
    // MARK: - 生命周期
    
    override func loadView() {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        self.view = UIVisualEffectView(effect: blurEffect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.padding = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 0.0, right: 10.0)
        contentView.addSubview(pickerView)
        setupActionsBar(actions: [doneAction])
        actionsBar?.padding = UIEdgeInsets(vertical: 10.0)
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.layoutFrame()
        pickerView.frame = layoutFrame
        pickerView.height = layoutFrame.height - actionsBarHeight
        updatePopoverContentSize()
    }
    
    override var popoverContentSize: CGSize {
        return contentSize
    }
    
    // MARK: - 数据加载与选择
    
    func reloadData() {
        pickerView.menuItems = menuItems
        
        // 如果有选中的菜单项，则选中它
        if let selectedItem = selectedItem {
            pickerView.selectItem(withIdentifier: selectedItem.identifier, animated: false)
        }
    }
    
    /// 根据索引选择菜单项
    /// - Parameters:
    ///   - index: 菜单项索引
    ///   - animated: 是否动画
    func selectItem(at index: Int, animated: Bool) {
        guard index >= 0 && index < menuItems.count else { return }
        selectedItem = menuItems[index]
        pickerView.selectItem(at: index, animated: animated)
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
    
    // MARK: - 完成按钮回调
    
    override func clickDone() {
        if let selectedItem = pickerView.selectedItem {
            didPickItem?(selectedItem)
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - 便利扩展
extension TPMenuPickerViewController {
    
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
}
