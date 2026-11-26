//
//  WSSeparatorStyleSelectCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 分组

/// 分割线样式选择列表的分组。
class WSSeparatorStyleGroup: NSObject, GroupRepresentable {

    /// 分组唯一标识
    let identifier: String

    /// 分组内样式条目
    var styleItems: [WSSeparatorStyleItem]?

    init(identifier: String) {
        self.identifier = identifier
    }

    // MARK: - GroupRepresentable
    var items: [ListDiffable]? {
        return styleItems
    }

    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? WSSeparatorStyleGroup else {
            return false
        }

        return identifier == other.identifier
    }
}

// MARK: - 样式条目

/// 分割线样式选择列表的条目。列表数据需要 `ListDiffable`，这里对样式做一层包装。
class WSSeparatorStyleItem: NSObject {

    /// 样式
    let style: WSSeparatorStyle

    init(style: WSSeparatorStyle) {
        self.style = style
        super.init()
    }

    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return style.rawValue as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? WSSeparatorStyleItem else {
            return false
        }

        return style == other.style
    }
}

// MARK: - 列表单元格

/// 分割线样式选择列表的单元格。
///
/// 左侧固定宽度展示样式标题，中间用 `CAShapeLayer` 绘制该样式的分割线，右侧为选中对勾。
class WSSeparatorStyleSelectCell: TPBaseTableCell {

    /// 布局尺寸
    private enum Metrics {

        /// 左侧标题区域宽度
        static let titleWidth: CGFloat = 60.0

        /// 标题与分割线的间距
        static let titleLineSpacing: CGFloat = 8.0

        /// 分割线与对勾的间距
        static let lineCheckmarkSpacing: CGFloat = 12.0

        /// 对勾尺寸
        static let checkmarkSize = CGSize(width: 24.0, height: 24.0)

        /// 标题字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 13.0)
    }

    /// 样式标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    /// 样式预览：按样式绘制分割线
    private lazy var lineView = WSSeparatorLineView()

    /// 选中对勾
    private lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("checkmark_24")
        view.isHidden = true
        view.updateImage(withColor: .primary)
        return view
    }()

    /// 展示的样式
    var separatorStyle: WSSeparatorStyle? {
        didSet {
            titleLabel.text = separatorStyle?.title
            lineView.lineStyle = separatorStyle ?? .solid
            setNeedsLayout()
        }
    }

    // MARK: - 子视图
    override func setupContentSubviews() {
        super.setupContentSubviews()

        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(checkmarkView)
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = contentView.layoutFrame()
        guard layoutFrame.width > 0.0 else {
            return
        }

        titleLabel.frame = CGRect(x: layoutFrame.minX,
                                  y: layoutFrame.minY,
                                  width: Metrics.titleWidth,
                                  height: layoutFrame.height)

        let lineLeft = titleLabel.right + Metrics.titleLineSpacing
        let lineRight = layoutFrame.maxX - Metrics.checkmarkSize.width - Metrics.lineCheckmarkSpacing
        lineView.frame = CGRect(x: lineLeft,
                                y: layoutFrame.minY,
                                width: max(lineRight - lineLeft, 0.0),
                                height: layoutFrame.height)

        checkmarkView.size = Metrics.checkmarkSize
        checkmarkView.right = layoutFrame.maxX
        checkmarkView.centerY = layoutFrame.midY
    }

    // MARK: - 选中
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)

        checkmarkView.isHidden = !checked
    }
}
