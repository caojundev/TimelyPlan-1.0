//
//  WSPluginContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

/// 工作台组件的内容视图。
///
/// 只负责渲染数据：数据由对应的 `WSPluginContentViewModel` 异步获取完成后，
/// 通过 `update(with:)` 下发；视图不关心数据从哪来、何时刷新。
class WSPluginContentView: UIView {
    
    /// 当前数据条目
    private(set) var dataItem: WSPluginDataItem?
    
    /// 内容交互器。
    ///
    /// 由 `WSPluginCell` 在创建交互器后注入。内容视图内的点击、按钮等交互直接交给它处理，
    /// 单元格无需关心内容视图内部是点击还是其它操作。
    weak var interactor: WSPluginContentInteractor?
    
    /// 更新数据条目。子类覆写后按需渲染，并调用 `super` 保留数据条目。
    func update(with dataItem: WSPluginDataItem?) {
        self.dataItem = dataItem
        setNeedsLayout()
    }
}
