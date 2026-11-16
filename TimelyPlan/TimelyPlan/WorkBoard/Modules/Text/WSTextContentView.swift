//
//  WSTextContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 文本组件的内容视图。
///
/// 只展示一个文本标签，字体与对齐方式取自组件配置。
/// 组件高度由布局按宽度计算后下发，内容按实际行数自上而下排列。
class WSTextContentView: WSPluginContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)

        /// 默认文本字号
        static let textFont = UIFont.preferredFont(forTextStyle: .body)

        /// 文本最大行数，避免长文本把组件撑得过高
        static let maximumNumberOfLines = 8
    }

    /// 文本
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.textFont
        label.textColor = .label
        label.numberOfLines = Metrics.maximumNumberOfLines
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding

        addSubview(textLabel)
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

        /// 文本按实际行数占位并自上而下排列，剩余高度留白
        let textSize = textLabel.sizeThatFits(CGSize(width: contentFrame.width,
                                                      height: .greatestFiniteMagnitude))
        textLabel.frame = CGRect(x: contentFrame.minX,
                                 y: contentFrame.minY,
                                 width: contentFrame.width,
                                 height: min(ceil(textSize.height), contentFrame.height))
    }

    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSTextDataItem else {
            textLabel.font = Metrics.textFont
            textLabel.textAlignment = .left
            textLabel.text = nil
            setNeedsLayout()
            return
        }

        textLabel.font = dataItem.textStyle.font
        textLabel.textAlignment = dataItem.textAlignment.textAlignment
        textLabel.text = dataItem.text
        setNeedsLayout()
    }

    // MARK: - 高度计算
    /// 文本在给定宽度下所需的高度。
    ///
    /// 与 `layoutSubviews` 使用同一套字体与间距，保证布局给出的高度与实际渲染一致。
    static func preferredHeight(forWidth width: CGFloat, dataItem: WSTextDataItem) -> CGFloat {
        let contentWidth = max(width - Metrics.padding.horizontalLength, 0.0)
        let font = dataItem.textStyle.font
        let textHeight = min(measuredHeight(of: dataItem.text, font: font, width: contentWidth),
                             ceil(font.lineHeight * CGFloat(Metrics.maximumNumberOfLines)))

        return ceil(Metrics.padding.verticalLength + textHeight)
    }

    /// 单段文本在给定宽度下换行后的高度
    private static func measuredHeight(of text: String, font: UIFont, width: CGFloat) -> CGFloat {
        guard !text.isEmpty, width > 0.0 else {
            return 0.0
        }

        let boundingRect = (text as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                            attributes: [.font: font],
                                                            context: nil)
        return ceil(boundingRect.height)
    }
}

// MARK: - 高度计算对象

/// 文本组件的高度计算对象。按配置中的文本测量高度
struct WSTextHeightCalculator: WSPluginHeightCalculating {

    /// 组件配置
    let configuration: WSTextConfiguration?

    func height(forWidth width: CGFloat) -> CGFloat {
        return WSTextContentView.preferredHeight(forWidth: width,
                                                 dataItem: WSTextDataItem(configuration: configuration))
    }
}
