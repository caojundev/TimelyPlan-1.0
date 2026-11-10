//
//  WSHeadlineContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 标题组件的内容视图。
///
/// 标题在上、描述在下，标题使用 Headline 文本样式。
/// 组件高度由布局按宽度计算后下发，内容按实际行数自上而下排列。
class WSHeadlineContentView: WSPluginContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)

        /// 标题与描述的间距
        static let spacing: CGFloat = 4.0

        /// 标题字号
        static let titleFont = UIFont.preferredFont(forTextStyle: .headline)

        /// 描述字号
        static let subtitleFont = UIFont.preferredFont(forTextStyle: .subheadline)

        /// 标题最大行数
        static let titleNumberOfLines = 2

        /// 描述最大行数，避免长文本把组件撑得过高
        static let subtitleNumberOfLines = 4
    }

    /// 标题
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.textColor = .label
        label.numberOfLines = Metrics.titleNumberOfLines
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    /// 描述
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.subtitleFont
        label.textColor = .secondaryLabel
        label.numberOfLines = Metrics.subtitleNumberOfLines
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding

        addSubview(titleLabel)
        addSubview(subtitleLabel)
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

        /// 标题按实际行数占位，描述占据剩余高度，内容超出时自然裁切
        let titleSize = titleLabel.sizeThatFits(CGSize(width: contentFrame.width,
                                                        height: .greatestFiniteMagnitude))
        let titleHeight = min(ceil(titleSize.height), contentFrame.height)
        titleLabel.frame = CGRect(x: contentFrame.minX,
                                  y: contentFrame.minY,
                                  width: contentFrame.width,
                                  height: titleHeight)

        let subtitleTop = titleLabel.bottom + Metrics.spacing
        subtitleLabel.frame = CGRect(x: contentFrame.minX,
                                     y: subtitleTop,
                                     width: contentFrame.width,
                                     height: max(contentFrame.maxY - subtitleTop, 0.0))
    }

    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSHeadlineDataItem else {
            titleLabel.text = nil
            subtitleLabel.text = nil
            setNeedsLayout()
            return
        }

        titleLabel.text = dataItem.title
        subtitleLabel.text = dataItem.subtitle
        setNeedsLayout()
    }

    // MARK: - 高度计算
    /// 标题与描述在给定宽度下所需的高度。
    ///
    /// 与 `layoutSubviews` 使用同一套字体与间距，保证布局给出的高度与实际渲染一致。
    static func preferredHeight(forWidth width: CGFloat, dataItem: WSHeadlineDataItem) -> CGFloat {
        let contentWidth = max(width - Metrics.padding.horizontalLength, 0.0)
        let titleHeight = min(measuredHeight(of: dataItem.title, font: Metrics.titleFont, width: contentWidth),
                              ceil(Metrics.titleFont.lineHeight * CGFloat(Metrics.titleNumberOfLines)))
        let subtitleHeight = min(measuredHeight(of: dataItem.subtitle, font: Metrics.subtitleFont, width: contentWidth),
                                 ceil(Metrics.subtitleFont.lineHeight * CGFloat(Metrics.subtitleNumberOfLines)))

        return ceil(Metrics.padding.verticalLength + titleHeight + Metrics.spacing + subtitleHeight)
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

/// 标题组件的高度计算对象。按配置中的文案测量高度
struct WSHeadlineHeightCalculator: WSPluginHeightCalculating {

    /// 组件配置
    let configuration: WSHeadlineConfiguration?

    func height(forWidth width: CGFloat) -> CGFloat {
        return WSHeadlineContentView.preferredHeight(forWidth: width,
                                                     dataItem: WSHeadlineDataItem(configuration: configuration))
    }
}
