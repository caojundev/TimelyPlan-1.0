//
//  WSTextStyleSelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/16.
//

import Foundation
import UIKit

/// 文本样式选择视图
class WSTextStyleSelectView: UIView {

    /// 选中文本样式回调
    var didSelectTextStyle: ((WSTextStyle) -> Void)?

    /// 当前选中的文本样式
    var selectedTextStyle: WSTextStyle = .body {
        didSet {
            updateStyleButtonsAppearance()
        }
    }

    /// 文本样式按钮
    private var styleButtons: [WSTextStyleButton] = []

    /// 布局尺寸
    private enum Metrics {

        /// 内间距
        static let padding = UIEdgeInsets(value: 8.0)

        /// 圆角半径
        static let cornerRadius = 12.0

        /// 按钮间距
        static let spacing: CGFloat = 8.0

        /// 列数
        static let columns = 3

        /// 按钮高度
        static let itemHeight: CGFloat = 44.0
    }

    /// 首选高度，与按钮行数对应
    static var preferredHeight: CGFloat {
        let rows = ceil(CGFloat(WSTextStyle.allCases.count) / CGFloat(Metrics.columns))
        return ceil(Metrics.padding.verticalLength + rows * Metrics.itemHeight + (rows - 1) * Metrics.spacing)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor = .secondarySystemGroupedBackground
        self.layer.cornerRadius = Metrics.cornerRadius
        self.padding = Metrics.padding

        for style in WSTextStyle.allCases {
            let button = WSTextStyleButton(style: style)
            button.addTarget(self, action: #selector(styleButtonTapped(_:)), for: .touchUpInside)
            styleButtons.append(button)
            addSubview(button)
        }

        updateStyleButtonsAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        guard layoutFrame.width > 0.0, !styleButtons.isEmpty else {
            return
        }

        let spacing = Metrics.spacing
        let columns = Metrics.columns
        let rows = Int(ceil(CGFloat(styleButtons.count) / CGFloat(columns)))
        let buttonWidth = (layoutFrame.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        let buttonHeight = (layoutFrame.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)

        for (index, button) in styleButtons.enumerated() {
            let row = index / columns
            let col = index % columns
            let x = layoutFrame.minX + CGFloat(col) * (spacing + buttonWidth)
            let y = layoutFrame.minY + CGFloat(row) * (spacing + buttonHeight)
            button.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
        }
    }

    @objc private func styleButtonTapped(_ sender: WSTextStyleButton) {
        TPImpactFeedback.impactWithSoftStyle()
        selectedTextStyle = sender.style
        didSelectTextStyle?(selectedTextStyle)
    }

    /// 根据当前的 selectedTextStyle 更新所有按钮的外观
    private func updateStyleButtonsAppearance() {
        for button in styleButtons {
            button.isSelected = button.style == selectedTextStyle
        }
    }
}

/// 文本样式选项按钮
class WSTextStyleButton: TPDefaultButton {

    /// 按钮标题统一字号
    private static let titleFontSize: CGFloat = 14.0

    private let selectedTextColor: UIColor = .white
    private let normalTextColor: UIColor = resGetColor(.title).withAlphaComponent(0.3)

    let style: WSTextStyle

    init(style: WSTextStyle) {
        self.style = style
        super.init(frame: .zero)

        self.title = style.shortTitle
        self.titleConfig.font = style.isBold ? UIFont.boldSystemFont(ofSize: Self.titleFontSize)
                                             : UIFont.systemFont(ofSize: Self.titleFontSize)
        self.titleConfig.textColor = normalTextColor
        self.titleConfig.highlightedTextColor = selectedTextColor
        self.titleConfig.selectedTextColor = selectedTextColor

        self.normalBackgroundColor = Color(0xcccccc, 0.1)
        self.selectedBackgroundColor = .primary
        self.cornerRadius = 8.0
        self.scaleMaxLength = 5.0
        self.preferredTappedScale = 0.95
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
