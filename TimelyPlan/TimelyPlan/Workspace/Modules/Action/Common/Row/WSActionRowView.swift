//
//  WSActionRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/13.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 动作行视图，列表与网格共用。
///
/// 内容由 `TPColorInfoView` 承载：左侧为动作颜色竖条，中间为动作名称，
/// 右侧图标区分动作方式，添加为加号、跳转为箭头。
class WSActionRowView: WSRowView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与行边缘的间距
        static let contentInsets = UIEdgeInsets(top: 2.0, left: 8.0, bottom: 2.0, right: 8.0)

        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0

        /// 名称字号
        static let titleFont = UIFont.systemFont(ofSize: 15.0, weight: .medium)

        /// 颜色竖条尺寸及其与名称的间距
        static let colorBarSize = CGSize(width: 6.0, height: 16.0)
        static let colorBarMargins = UIEdgeInsets(left: 2.0, right: 8.0)

        /// 右侧图标尺寸及其外间距
        static let iconSize = CGSize(width: 16.0, height: 16.0)
        static let iconMargins = UIEdgeInsets(left: 6.0, right: 2.0)
    }

    /// 当前展示的动作
    private(set) var action: WSActionItem?

    /// 颜色竖条 + 名称 + 图标
    let contentView = TPColorInfoView()

    /// 右侧图标：添加为加号，跳转为箭头
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14.0,
                                                                            weight: .semibold)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentCornerRadius = Metrics.cornerRadius

        contentView.titleConfig = .withFont(Metrics.titleFont,
                                            textColor: .label,
                                            adjustsFontSizeToFitWidth: true,
                                            minimumScaleFactor: 0.8)
        contentView.rightAccessoryView = iconView
        contentView.rightAccessorySize = Metrics.iconSize
        contentView.rightAccessoryMargins = Metrics.iconMargins

        addSubview(contentView)
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

        contentView.frame = frame
    }

    // MARK: - 渲染
    /// 更新展示的动作。传 nil 时清空内容
    func update(with action: WSActionItem?) {
        self.action = action

        guard let action = action else {
            contentView.colorConfig = nil
            contentView.title = nil
            iconView.image = nil
            return
        }

        let colorConfig = TPColorAccessoryConfig()
        colorConfig.color = action.color ?? .primary
        colorConfig.size = Metrics.colorBarSize
        colorConfig.margins = Metrics.colorBarMargins
        contentView.colorConfig = colorConfig

        contentView.title = action.title
        iconView.image = UIImage(systemName: action.mode == .add ? "plus" : "arrow.right")
    }
}
