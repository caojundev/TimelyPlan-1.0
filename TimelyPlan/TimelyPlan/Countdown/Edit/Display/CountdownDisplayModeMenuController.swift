//
//  CountdownDisplayModeMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/25.
//

import Foundation
import UIKit

/// 倒数日显示方式菜单管理类
///
/// 封装“预设显示方式 + 自定义提前天数”的菜单选择逻辑：
/// 由外部传入当前显示方式，用户在菜单中选中后通过 `didSelectDisplayMode` 回调返回结果。
final class CountdownDisplayModeMenuController: TPMenuListViewController {
    
    /// 菜单内容宽度
    static let contentWidth = 180.0
    
    /// 当前显示方式（用于勾选与自定义天数回显）
    private let currentDisplayMode: CountdownDisplayMode
    
    /// 选中显示方式回调
    var didSelectDisplayMode: ((CountdownDisplayMode) -> Void)?
    
    // MARK: - 初始化
    /// - Parameter currentDisplayMode: 当前显示方式
    init(currentDisplayMode: CountdownDisplayMode) {
        self.currentDisplayMode = currentDisplayMode
        super.init(nibName: nil, bundle: nil)
        menuContentWidth = Self.contentWidth
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuItems = [displayModeMenuItem()]
        reloadData()
    }
    
    // MARK: - 显示菜单
    /// 从指定视图弹出显示方式菜单
    /// - Parameters:
    ///   - sourceView: 菜单锚点视图
    ///   - sourceRect: 锚点区域，默认取 `sourceView.bounds`
    ///   - isSourceViewCovered: 锚点视图是否被菜单遮挡
    ///   - preferredPosition: 首选弹出位置
    ///   - permittedPositions: 允许的弹出位置
    func show(from sourceView: UIView,
              sourceRect: CGRect? = nil,
              isSourceViewCovered: Bool = false,
              preferredPosition: TPPopoverPosition = .bottomLeft,
              permittedPositions: [TPPopoverPosition] = [.bottomLeft, .topLeft]) {
        popoverShow(from: sourceView,
                    sourceRect: sourceRect ?? sourceView.bounds,
                    isSourceViewCovered: isSourceViewCovered,
                    preferredPosition: preferredPosition,
                    permittedPositions: permittedPositions)
    }
    
    // MARK: - 菜单条目
    /// 显示方式菜单条目（预设模式 + 自定义提前天数）
    private func displayModeMenuItem() -> TPMenuItem {
        var actions = CountdownDisplayMode.presetModes.map { preset -> TPMenuAction in
            let action = TPMenuAction()
            action.title = preset.title
            action.handleBeforeDismiss = true
            action.isChecked = preset == currentDisplayMode
            action.handler = { [weak self] _ in
                self?.didSelectDisplayMode?(preset)
            }
            
            return action
        }
        
        // 自定义提前天数：当前天数不属于预设模式时展示具体天数并选中
        let isCustomAdvanceDays = !CountdownDisplayMode.presetModes.contains(currentDisplayMode)
        let customAction = TPMenuAction()
        customAction.title = resGetString("Custom")
        customAction.subtitle = isCustomAdvanceDays ? currentDisplayMode.title : nil
        customAction.isChecked = isCustomAdvanceDays
        customAction.handler = { [weak self] _ in
            self?.editCustomAdvanceDays()
        }
        actions.append(customAction)
        
        let menuItem = TPMenuItem()
        menuItem.actions = actions
        return menuItem
    }
    
    // MARK: - 自定义提前天数
    /// 编辑自定义提前天数（1...99）
    private func editCustomAdvanceDays() {
        // 菜单会随选择自定义后被销毁，此处强引用回调以避免选择结果丢失
        guard let didSelectDisplayMode = didSelectDisplayMode else {
            return
        }
        
        let pickerVC = TPCountPickerViewController()
        pickerVC.minimumCount = CountdownDisplayMode.daysRange.lowerBound
        pickerVC.maximumCount = CountdownDisplayMode.daysRange.upperBound
        pickerVC.count = CountdownDisplayMode.validDays(currentDisplayMode.advanceDays ?? pickerVC.minimumCount)
        pickerVC.tailingTextForCount = { _ in
            return resGetString("Days")
        }
        
        pickerVC.didPickCount = { days in
            didSelectDisplayMode(.daysBefore(days))
        }
        
        pickerVC.popoverShow()
    }
}
