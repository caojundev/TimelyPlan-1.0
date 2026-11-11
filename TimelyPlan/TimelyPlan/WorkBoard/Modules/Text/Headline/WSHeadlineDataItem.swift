//
//  WSHeadlineDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation

// MARK: - 数据条目

/// 标题组件数据。
///
/// 承载标题与描述两段文案，未配置或配置为空时使用默认文案。
class WSHeadlineDataItem: NSObject, WSPluginDataItem {

    /// 标题
    let title: String

    /// 描述
    let subtitle: String

    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        super.init()
    }

    /// 由组件配置生成展示数据。配置为空时使用默认的「标题」「描述」
    convenience init(configuration: WSHeadlineConfiguration?) {
        let title = configuration?.title?.whitespacesAndNewlinesTrimmedString ?? ""
        let subtitle = configuration?.subtitle?.whitespacesAndNewlinesTrimmedString ?? ""

        self.init(title: title.isEmpty ? resGetString("Title") : title,
                  subtitle: subtitle.isEmpty ? resGetString("Description") : subtitle)
    }
}
