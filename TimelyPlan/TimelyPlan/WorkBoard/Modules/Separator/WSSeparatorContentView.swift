//
//  WSSeparatorContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 分割线组件的内容视图。
///
/// 只在组件中部绘制一条分割线，样式由配置决定。
class WSSeparatorContentView: WSPluginContentView {

    /// 组件高度。分割线先使用固定高度，后续如需自适应可改为按宽度计算
    static let preferredHeight: CGFloat = 24.0

    /// 布局尺寸
    private enum Metrics {

        /// 分割线两侧与组件边缘的间距
        static let padding = UIEdgeInsets(horizontal: 16.0)
    }

    /// 分割线
    private let lineView = WSSeparatorLineView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding

        addSubview(lineView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }

        lineView.frame = contentFrame
    }

    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSSeparatorDataItem else {
            lineView.lineStyle = .solid
            setNeedsLayout()
            return
        }

        lineView.lineStyle = dataItem.style
        setNeedsLayout()
    }
}

// MARK: - 高度计算对象

/// 分割线组件的高度计算对象。当前使用固定高度
struct WSSeparatorHeightCalculator: WSPluginHeightCalculating {

    func height(forWidth width: CGFloat) -> CGFloat {
        return WSSeparatorContentView.preferredHeight
    }
}
