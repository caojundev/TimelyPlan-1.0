//
//  WSBodyDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation

// MARK: - 数据条目

/// 正文组件数据。
///
/// 承载一段正文文本，未配置或配置为空时使用默认文案。
class WSBodyDataItem: NSObject, WSPluginDataItem {

    /// 正文文本
    let text: String

    init(text: String) {
        self.text = text
        super.init()
    }

    /// 由组件配置生成展示数据。配置为空时使用默认的「正文」
    convenience init(configuration: WSBodyConfiguration?) {
        let text = configuration?.text?.whitespacesAndNewlinesTrimmedString ?? ""
        self.init(text: text.isEmpty ? resGetString("Body Text") : text)
    }
}
