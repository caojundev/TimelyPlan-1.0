//
//  WSActionListFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/16.
//

import Foundation
import UIKit

/// 动作配置列表的底部操作栏：添加动作与跳转动作，图标与动作行保持一致
class WSActionListFooterView: UIView {

    /// 布局尺寸
    private enum Metrics {

        /// 按钮高度
        static let buttonHeight: CGFloat = 50.0

        /// 按钮间距
        static let buttonSpacing: CGFloat = 10.0

        /// 内容与列表边缘的间距，与分组列表的内容边距对齐
        static let contentInsets = UIEdgeInsets(horizontal: 20.0, vertical: 16.0)

        /// 按钮圆角
        static let cornerRadius: CGFloat = 12.0

        /// 图标尺寸及其与标题的间距
        static let iconMargins = UIEdgeInsets(right: 6.0)

        /// 图标字号
        static let iconPointSize: CGFloat = 14.0

        /// 标题字号
        static let titleFont = UIFont.systemFont(ofSize: 15.0, weight: .medium)
    }

    /// 选择动作方式的回调
    var didSelectMode: ((WSActionMode) -> Void)?

    /// 操作栏高度，供列表作为底部视图使用
    static var footerHeight: CGFloat {
        return Metrics.buttonHeight + Metrics.contentInsets.verticalLength
    }

    /// 添加动作按钮
    private lazy var addButton: TPDefaultButton = {
        let button = makeButton(mode: .add)
        return button
    }()

    /// 跳转动作按钮
    private lazy var navigateButton: TPDefaultButton = {
        let button = makeButton(mode: .navigate)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(addButton)
        addSubview(navigateButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = bounds.inset(by: Metrics.contentInsets)
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        let buttonWidth = max((frame.width - Metrics.buttonSpacing) / 2.0, 0.0)
        addButton.frame = CGRect(x: frame.minX,
                                 y: frame.minY,
                                 width: buttonWidth,
                                 height: frame.height)
        navigateButton.frame = CGRect(x: frame.minX + buttonWidth + Metrics.buttonSpacing,
                                      y: frame.minY,
                                      width: buttonWidth,
                                      height: frame.height)
    }

    // MARK: - 按钮
    private func makeButton(mode: WSActionMode) -> TPDefaultButton {
        let button = TPDefaultButton()
        button.cornerRadius = Metrics.cornerRadius
        button.normalBackgroundColor = .secondarySystemGroupedBackground
        button.selectedBackgroundColor = .tertiarySystemFill

        button.titleConfig.font = Metrics.titleFont
        button.titleConfig.textColor = .label
        button.titleConfig.highlightedTextColor = .label

        button.imageConfig.size = .mini
        button.imageConfig.margins = Metrics.iconMargins
        button.imageConfig.color = .secondaryLabel
        button.imageConfig.highlightedColor = .secondaryLabel

        button.image = mode.iconImage
        button.title = mode.title
        button.didClickHandler = { [weak self] in
            self?.didSelectMode?(mode)
        }

        return button
    }
}
