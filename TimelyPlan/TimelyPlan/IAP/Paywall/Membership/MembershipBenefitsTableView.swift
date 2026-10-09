//
//  MembershipBenefitsTableView.swift
//  会员权益对比表格 — UIKit 手动布局实现
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit

// MARK: - 数据模型

/// 单行权益数据
struct BenefitRow {
    /// 权益名称（首列，决定行高）
    let title: String
    /// 普通用户列内容（传 nil 显示横杠 "—"）
    let freeValue: String?
    /// 高级会员列内容（传 nil 显示对勾 "✓"）
    let proValue: String?
}

// MARK: - 颜色常量

enum MembershipColor {
    static let background      = UIColor.black
    static let cardBackground  = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)   // #1C1C1E
    static let headerBackground = UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)   // #2C2C2E
    static let separator       = UIColor(red: 0.22, green: 0.22, blue: 0.23, alpha: 1.0)   // #38383A
    static let titleWhite      = UIColor.white
    static let freeGray        = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)   // #8E8E93
    static let proGold         = UIColor(red: 1.00, green: 0.72, blue: 0.00, alpha: 1.0)   // #FFB800
    static let sectionOrange   = UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1.0)   // #FF9500
}

// MARK: - 布局常量

private enum Metric {
    /// 表格左右外边距
    static let horizontalInset: CGFloat = 0.0
    /// 表格圆角
    static let cornerRadius: CGFloat = 16
    /// 表头高度
    static let headerHeight: CGFloat = 56
    /// 展开/收起 footer 高度
    static let footerHeight: CGFloat = 48
    /// 行最小高度
    static let minRowHeight: CGFloat = 52
    /// 行最大高度
    static let maxRowHeight: CGFloat = 120
    /// 单元格左右内边距
    static let cellHorizontalPadding: CGFloat = 12
    /// 单元格上下内边距
    static let cellVerticalPadding: CGFloat = 12
    /// 三列宽度占比（首列 0.40，后两列各 0.30）
    static let columnWeights: [CGFloat] = [0.40, 0.30, 0.30]
    /// 权益名称字体
    static let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    /// 内容字体
    static let valueFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    /// 表头字体
    static let headerFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
}

// MARK: - 主表格视图

final class MembershipBenefitsTableView: UIView {

    // MARK: 公开属性

    /// 表格数据
    var rows: [BenefitRow] = [] {
        didSet { setNeedsLayout() }
    }

    /// 行最小高度（可外部调整）
    var minRowHeight: CGFloat = Metric.minRowHeight
    /// 行最大高度（可外部调整）
    var maxRowHeight: CGFloat = Metric.maxRowHeight
    /// 收起状态下最多显示的行数，超过则显示展开按钮（默认 10）
    var maxVisibleRows: Int = 10 {
        didSet { setNeedsLayout() }
    }
    /// 当前是否已展开
    private(set) var isExpanded = false
    
    /// 内容高度变化回调
    var onContentHeightChanged: ((CGFloat) -> Void)?

    // MARK: 私有子视图

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = BenefitHeaderView()
    private let footerView = ExpandFooterView()
    private var rowViews: [BenefitRowView] = []

    /// 是否需要显示 footer（行数超过阈值）
    private var shouldShowFooter: Bool { rows.count > maxVisibleRows }

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(scrollView)
        scrollView.backgroundColor = .clear
        scrollView.isScrollEnabled = false
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false

        contentView.addSubview(headerView)
        contentView.addSubview(footerView)
        contentView.layer.cornerRadius = Metric.cornerRadius
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        contentView.layer.backgroundColor = UIColor.clear.cgColor
        
        // footer 点击事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleFooterTap))
        footerView.addGestureRecognizer(tap)
        footerView.isUserInteractionEnabled = true
    }

    @objc private func handleFooterTap() {
        toggleExpanded(animated: true)
    }

    /// 切换展开/收起状态
    func toggleExpanded(animated: Bool = true) {
        isExpanded.toggle()
        footerView.setExpanded(isExpanded)
        
        if animated {
            // 先布局所有视图到最终位置（但不改变高度）
            prepareLayoutForExpansion()
            
            // 获取目标高度
            let targetHeight = calculateContentHeight()
            
            // 动画调整 contentView 高度
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.contentView.frame.size.height = targetHeight
                self.scrollView.contentSize.height = targetHeight
                self.layoutIfNeeded()
            } completion: { _ in
                // 动画完成后通知外部
                self.onContentHeightChanged?(targetHeight)
            }
        } else {
            setNeedsLayout()
            layoutIfNeeded()
            onContentHeightChanged?(contentHeight)
        }
    }

    // MARK: 手动布局

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 仅在非动画状态下进行完整布局
        if !isAnimatingHeight {
            performFullLayout()
        }
    }
    
    private var isAnimatingHeight = false
    
    /// 执行完整布局
    private func performFullLayout() {
        // 1. scrollView 占满自身
        scrollView.frame = bounds

        // 2. 计算表格可用宽度
        let tableWidth = bounds.width - Metric.horizontalInset * 2
        guard tableWidth > 0 else { return }

        // 3. 计算每列宽度
        let colWidths = Metric.columnWeights.map { $0 * tableWidth }

        // 4. 表头位置（水平居中）
        let tableX = Metric.horizontalInset
        contentView.frame = CGRect(x: tableX, y: 0, width: tableWidth, height: 0)

        // 5. 布局表头
        headerView.frame = CGRect(x: 0, y: 0, width: tableWidth, height: Metric.headerHeight)
        headerView.setColumnWidths(colWidths)

        // 6. 计算实际显示的行数（收起时只显示前 maxVisibleRows 行）
        let visibleCount = isExpanded ? rows.count : min(rows.count, maxVisibleRows)

        // 7. 复用/创建行视图
        ensureRowViewCount(visibleCount)

        // 8. 逐行计算高度并布局
        var currentY: CGFloat = Metric.headerHeight
        for index in 0..<visibleCount {
            let row = rows[index]
            let rowView = rowViews[index]
            let rowHeight = calculateRowHeight(for: row, tableWidth: tableWidth)
            rowView.frame = CGRect(x: 0, y: currentY, width: tableWidth, height: rowHeight)
            rowView.configure(with: row, columnWidths: colWidths)
            currentY += rowHeight
        }

        // 9. 布局 footer（仅当行数超过阈值时显示）
        if shouldShowFooter {
            footerView.isHidden = false
            footerView.frame = CGRect(
                x: 0, y: currentY,
                width: tableWidth, height: Metric.footerHeight
            )
            currentY += Metric.footerHeight
        } else {
            footerView.isHidden = true
        }

        // 10. 更新 contentView 与 scrollView 内容大小
        contentView.frame.size.height = currentY
        scrollView.contentSize = CGSize(width: bounds.width, height: currentY)
    }
    
    /// 为展开动画准备布局（设置所有视图到最终位置，但不改变高度）
    private func prepareLayoutForExpansion() {
        scrollView.frame = bounds
        
        let tableWidth = bounds.width - Metric.horizontalInset * 2
        guard tableWidth > 0 else { return }
        
        let colWidths = Metric.columnWeights.map { $0 * tableWidth }
        let tableX = Metric.horizontalInset
        
        // 设置 contentView 位置和宽度（保持当前高度，稍后在动画中调整）
        contentView.frame = CGRect(x: tableX, y: 0, width: tableWidth, height: contentView.frame.height)
        
        // 布局表头
        headerView.frame = CGRect(x: 0, y: 0, width: tableWidth, height: Metric.headerHeight)
        headerView.setColumnWidths(colWidths)
        
        // 计算可见行数
        let visibleCount = isExpanded ? rows.count : min(rows.count, maxVisibleRows)
        let previousVisibleCount = isExpanded ? min(rows.count, maxVisibleRows) : rows.count
        
        // 确保行视图数量正确
        ensureRowViewCount(visibleCount)
        
        // 设置所有行视图到最终位置
        var currentY: CGFloat = Metric.headerHeight
        for index in 0..<visibleCount {
            let row = rows[index]
            let rowView = rowViews[index]
            let rowHeight = calculateRowHeight(for: row, tableWidth: tableWidth)
            
            // 设置完整的frame（包括宽度）
            rowView.frame = CGRect(x: 0, y: currentY, width: tableWidth, height: rowHeight)
            
            // 对于新添加的行，设置初始透明度为0
            if index >= previousVisibleCount {
                rowView.alpha = 0
            } else {
                rowView.alpha = 1
            }
            
            // 配置行内容（设置内部布局）
            rowView.configure(with: row, columnWidths: colWidths)
            currentY += rowHeight
        }
        
        // 布局 footer
        if shouldShowFooter {
            footerView.isHidden = false
            footerView.frame = CGRect(
                x: 0, y: currentY,
                width: tableWidth, height: Metric.footerHeight
            )
            currentY += Metric.footerHeight
        } else {
            footerView.isHidden = true
        }
        
        // 强制立即布局所有子视图
        contentView.layoutIfNeeded()
        
        // 在动画中更新高度和透明度
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.contentView.frame.size.height = currentY
            self.scrollView.contentSize = CGSize(width: self.bounds.width, height: currentY)
            
            // 显示所有行
            for rowView in self.rowViews {
                rowView.alpha = 1
            }
            
            self.layoutIfNeeded()
        } completion: { _ in
            self.onContentHeightChanged?(currentY)
        }
    }
    
    // MARK: 行高计算（核心：根据首列文本高度动态决定）

    private func calculateRowHeight(for row: BenefitRow, tableWidth: CGFloat) -> CGFloat {
        let firstColWidth = Metric.columnWeights[0] * tableWidth
        let textWidth = firstColWidth - Metric.cellHorizontalPadding * 2

        // 用首列文本计算多行高度
        let title = row.title as NSString
        let boundingRect = title.boundingRect(
            with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: Metric.titleFont],
            context: nil
        )

        let textHeight = ceil(boundingRect.height)
        let totalHeight = textHeight + Metric.cellVerticalPadding * 2

        // 约束在最小/最大高度之间
        return min(max(totalHeight, minRowHeight), maxRowHeight)
    }

    // MARK: 行视图复用管理

    private func ensureRowViewCount(_ count: Int) {
        if rowViews.count < count {
            for _ in rowViews.count..<count {
                let rowView = BenefitRowView()
                contentView.addSubview(rowView)
                rowViews.append(rowView)
            }
        } else if rowViews.count > count {
            for _ in count..<rowViews.count {
                rowViews.removeLast().removeFromSuperview()
            }
        }
    }

    /// 计算内容高度
    private func calculateContentHeight() -> CGFloat {
        let tableWidth = bounds.width - Metric.horizontalInset * 2
        guard tableWidth > 0 else { return Metric.headerHeight }
        var total = Metric.headerHeight
        let visibleCount = isExpanded ? rows.count : min(rows.count, maxVisibleRows)
        for index in 0..<visibleCount {
            total += calculateRowHeight(for: rows[index], tableWidth: tableWidth)
        }
        if shouldShowFooter {
            total += Metric.footerHeight
        }
        return total
    }
    
    /// 对外：获取内容总高度（用于外部布局参考）
    var contentHeight: CGFloat {
        return calculateContentHeight()
    }
}

// MARK: - 表头视图

private final class BenefitHeaderView: UIView {

    private let titleLabel = UILabel()
    private let freeLabel = UILabel()
    private let proLabel = UILabel()
    private let freeIcon = UIImageView()
    private let proIcon = UIImageView()
    private var columnWidths: [CGFloat] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = MembershipColor.headerBackground

        titleLabel.text = "权益"
        titleLabel.textColor = MembershipColor.titleWhite
        titleLabel.font = Metric.headerFont
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        freeLabel.text = "普通用户"
        freeLabel.textColor = MembershipColor.freeGray
        freeLabel.font = Metric.headerFont
        addSubview(freeLabel)

        proLabel.text = "高级会员"
        proLabel.textColor = MembershipColor.proGold
        proLabel.font = Metric.headerFont
        addSubview(proLabel)

        // 皇冠图标（用 SF Symbol）
        if #available(iOS 13.0, *) {
            freeIcon.image = UIImage(systemName: "crown.fill")?
                .withTintColor(MembershipColor.freeGray, renderingMode: .alwaysOriginal)
            proIcon.image = UIImage(systemName: "crown.fill")?
                .withTintColor(MembershipColor.proGold, renderingMode: .alwaysOriginal)
        }
        addSubview(freeIcon)
        addSubview(proIcon)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setColumnWidths(_ widths: [CGFloat]) {
        columnWidths = widths
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard columnWidths.count == 3 else { return }

        // 第一列：权益（居中）
        titleLabel.frame = CGRect(
            x: 0, y: 0,
            width: columnWidths[0], height: bounds.height
        )

        // 第二列：普通用户（图标 + 文字，整体居中）
        let freeText = "普通用户" as NSString
        let freeTextWidth = freeText.size(withAttributes: [.font: Metric.headerFont]).width
        let iconSize: CGFloat = 20
        let spacing: CGFloat = 6
        let freeTotalWidth = iconSize + spacing + freeTextWidth
        let freeStartX = columnWidths[0] + (columnWidths[1] - freeTotalWidth) / 2

        freeIcon.frame = CGRect(
            x: freeStartX,
            y: (bounds.height - iconSize) / 2,
            width: iconSize, height: iconSize
        )
        freeLabel.frame = CGRect(
            x: freeStartX + iconSize + spacing,
            y: 0,
            width: freeTextWidth, height: bounds.height
        )

        // 第三列：高级会员（图标 + 文字，整体居中）
        let proText = "高级会员" as NSString
        let proTextWidth = proText.size(withAttributes: [.font: Metric.headerFont]).width
        let proTotalWidth = iconSize + spacing + proTextWidth
        let proStartX = columnWidths[0] + columnWidths[1] + (columnWidths[2] - proTotalWidth) / 2

        proIcon.frame = CGRect(
            x: proStartX,
            y: (bounds.height - iconSize) / 2,
            width: iconSize, height: iconSize
        )
        proLabel.frame = CGRect(
            x: proStartX + iconSize + spacing,
            y: 0,
            width: proTextWidth, height: bounds.height
        )
    }
}

// MARK: - 单行视图

private final class BenefitRowView: UIView {

    private let titleLabel = UILabel()
    private let freeLabel = UILabel()
    private let proLabel = UILabel()
    private let underlineView = DashedUnderlineView()
    private let topSeparator = UIView()
    private var columnWidths: [CGFloat] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        titleLabel.font = Metric.titleFont
        titleLabel.textColor = MembershipColor.titleWhite
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        addSubview(titleLabel)

        freeLabel.font = Metric.valueFont
        freeLabel.textColor = MembershipColor.freeGray
        freeLabel.textAlignment = .center
        addSubview(freeLabel)

        proLabel.font = Metric.valueFont
        proLabel.textColor = MembershipColor.proGold
        proLabel.textAlignment = .center
        addSubview(proLabel)

        // 权益名称下方的虚线下划线
        addSubview(underlineView)

        // 顶部分隔线
        topSeparator.backgroundColor = MembershipColor.separator
        addSubview(topSeparator)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with row: BenefitRow, columnWidths: [CGFloat]) {
        self.columnWidths = columnWidths
        titleLabel.text = row.title

        // 普通用户列：有值显示值，无值显示横杠
        if let free = row.freeValue, !free.isEmpty {
            freeLabel.text = free
        } else {
            freeLabel.text = "—"
        }

        // 高级会员列：有值显示值，无值显示对勾
        if let pro = row.proValue, !pro.isEmpty {
            proLabel.text = pro
        } else {
            proLabel.text = "✓"
        }

        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard columnWidths.count == 3 else { return }

        let pad = Metric.cellHorizontalPadding

        // 第一列：权益名称（左对齐，垂直居中）
        let titleX = pad
        let titleWidth = columnWidths[0] - pad * 2
        let titleSize = titleLabel.sizeThatFits(
            CGSize(width: titleWidth, height: .greatestFiniteMagnitude)
        )
        let titleHeight = min(titleSize.height, bounds.height - pad * 2)
        titleLabel.frame = CGRect(
            x: titleX,
            y: (bounds.height - titleHeight) / 2,
            width: titleWidth,
            height: titleHeight
        )

        // 虚线下划线（紧贴文字底部，宽度与文字一致）
        let textWidth = (titleLabel.text as NSString?)?
            .size(withAttributes: [.font: Metric.titleFont]).width ?? titleWidth
        let underlineW = min(textWidth, titleWidth)
        underlineView.frame = CGRect(
            x: titleX,
            y: titleLabel.frame.maxY + 2,
            width: underlineW,
            height: 2
        )

        // 第二列：普通用户（居中）
        freeLabel.frame = CGRect(
            x: columnWidths[0],
            y: 0,
            width: columnWidths[1],
            height: bounds.height
        )

        // 第三列：高级会员（居中）
        proLabel.frame = CGRect(
            x: columnWidths[0] + columnWidths[1],
            y: 0,
            width: columnWidths[2],
            height: bounds.height
        )

        // 顶部分隔线（横跨整个表格宽度）
        topSeparator.frame = CGRect(
            x: 0, y: 0,
            width: bounds.width, height: 0.5
        )
    }
}

// MARK: - 虚线下划线

private final class DashedUnderlineView: UIView {
    override class var layerClass: AnyClass { CAShapeLayer.self }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let shapeLayer = layer as? CAShapeLayer else { return }
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = MembershipColor.titleWhite.withAlphaComponent(0.4).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [3, 3]
        shapeLayer.fillColor = nil
    }
}

// MARK: - 展开/收起 Footer

private final class ExpandFooterView: UIView {

    private let titleLabel = UILabel()
    private let arrowIcon = UIImageView()
    private let topSeparator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = MembershipColor.cardBackground

        topSeparator.backgroundColor = MembershipColor.separator
        addSubview(topSeparator)

        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = MembershipColor.proGold
        titleLabel.text = "展开全部"
        addSubview(titleLabel)

        if #available(iOS 13.0, *) {
            arrowIcon.image = UIImage(systemName: "chevron.down")?
                .withTintColor(MembershipColor.proGold, renderingMode: .alwaysOriginal)
        }
        addSubview(arrowIcon)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setExpanded(_ expanded: Bool) {
        titleLabel.text = expanded ? "收起" : "展开全部"
        if #available(iOS 13.0, *) {
            let image = expanded
                ? UIImage(systemName: "chevron.up")
                : UIImage(systemName: "chevron.down")
            arrowIcon.image = image?.withTintColor(MembershipColor.proGold, renderingMode: .alwaysOriginal)
        }
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        topSeparator.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.5)

        let iconSize: CGFloat = 16
        let spacing: CGFloat = 6
        let text = (titleLabel.text ?? "") as NSString
        let textWidth = text.size(withAttributes: [.font: titleLabel.font!]).width
        let totalWidth = iconSize + spacing + textWidth
        let startX = (bounds.width - totalWidth) / 2
        let centerY = bounds.midY

        arrowIcon.frame = CGRect(
            x: startX,
            y: centerY - iconSize / 2,
            width: iconSize, height: iconSize
        )
        titleLabel.frame = CGRect(
            x: startX + iconSize + spacing,
            y: 0,
            width: textWidth, height: bounds.height
        )
    }
}
