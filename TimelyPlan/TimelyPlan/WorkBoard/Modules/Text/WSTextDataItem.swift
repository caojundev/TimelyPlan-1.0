//
//  WSTextDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation

// MARK: - 数据条目

/// 文本组件数据。
///
/// 承载一段文本，未配置或配置为空时使用默认文案。
class WSTextDataItem: NSObject, WSPluginDataItem {

    /// 文本内容
    let text: String

    /// 文本样式
    let textStyle: WSTextStyle

    /// 文本对齐方式
    let textAlignment: WSTextAlignment

    init(text: String,
         textStyle: WSTextStyle = .body,
         textAlignment: WSTextAlignment = .left) {
        self.text = text
        self.textStyle = textStyle
        self.textAlignment = textAlignment
        super.init()
    }

    /// 由组件配置生成展示数据。配置为空时使用默认的「文本」
    convenience init(configuration: WSTextConfiguration?) {
        let text = configuration?.text?.whitespacesAndNewlinesTrimmedString ?? ""
        self.init(text: text.isEmpty ? resGetString("Text") : text,
                  textStyle: configuration?.textStyle ?? .body,
                  textAlignment: configuration?.textAlignment ?? .left)
    }
}
