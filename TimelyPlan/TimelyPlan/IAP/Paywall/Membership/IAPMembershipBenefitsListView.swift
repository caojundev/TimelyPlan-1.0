//
//  IAPMembershipBenefitsListView.swift
//  会员权益对比表格
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit

// MARK: - 数据模型

/// 权益列的取值：文本或图标
enum IAPMembershipBenefitValue: ExpressibleByStringLiteral {
    /// 文本内容，`color` 为 nil 时使用所在列的默认颜色
    case text(String, color: UIColor?)
    /// 图标名称，`color` 为 nil 时使用所在列的默认颜色
    case icon(String, color: UIColor?)
    
    /// 文本（使用所在列的默认颜色）
    static func text(_ value: String) -> IAPMembershipBenefitValue {
        .text(value, color: nil)
    }

    /// 图标（使用所在列的默认颜色）
    static func icon(_ name: String) -> IAPMembershipBenefitValue {
        .icon(name, color: nil)
    }

    static var basicText: IAPMembershipBenefitValue {
        return .text("Basic")
    }
    
    static var unlimitedText: IAPMembershipBenefitValue {
        return .text("Unlimited")
    }
    
    static var checkmark: IAPMembershipBenefitValue {
        return .icon("checkmark_circle_fill_24")
    }
    
    /// 字符串字面量按文本处理，便于直接书写
    init(stringLiteral value: String) {
        self = .text(value, color: nil)
    }
}

/// 权益行配置元组
/// - title: 权益名称（首列，决定行高）
/// - freeValue: 普通用户列内容（nil 显示横杠 "—"）
/// - proValue: 高级会员列内容（nil 显示对勾 "✓"）
typealias IAPMembershipBenefitRowTuple = (title: String,
                                          freeValue: IAPMembershipBenefitValue?,
                                          proValue: IAPMembershipBenefitValue?)

/// 单行权益数据
struct IAPMembershipBenefitRow {
    /// 权益名称（首列，决定行高）
    let title: String
    /// 普通用户列内容（传 nil 显示横杠 "—"）
    let freeValue: IAPMembershipBenefitValue?
    /// 高级会员列内容（传 nil 显示对勾 "✓"）
    let proValue: IAPMembershipBenefitValue?
}

extension IAPMembershipBenefitRow {

    /// 由配置元组创建，便于用简洁的元组数组配置行数据
    init(tuple: IAPMembershipBenefitRowTuple) {
        self.title = tuple.title
        self.freeValue = tuple.freeValue
        self.proValue = tuple.proValue
    }
}

// MARK: - 颜色常量

/// 权益对比表格配色（全部支持明暗模式）
enum MembershipColor {
    /// 页面背景
    static let background = Color(light: 0xF7F8FA, dark: 0x121214)
    /// 卡片背景：表头 / 行 / footer 统一使用，与商品卡片保持一致
    static let cardBackground = IAPColor.cardBackground
    /// 分隔线
    static let separator = Color(light: 0xE5E6EB, dark: 0x38383A, alpha: 0.6)
    /// 主文字
    static let title = Color(light: 0x1D2129, dark: 0xFFFFFF)
    /// 次要文字
    static let freeGray = Color(light: 0x86909C, dark: 0x8E8E93)
    
    /// 高亮色：与页面 Continue 按钮背景色保持一致
    static let highlight = IAPColor.primary
}

// MARK: - 布局常量

private enum Metric {
    /// 表格左右外边距
    static let horizontalInset: CGFloat = 0.0
    /// 表格圆角
    static let cornerRadius: CGFloat = 16
    /// 表格边框线条宽度
    static let borderWidth: CGFloat = 1.2
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
    /// 单元格内图标尺寸
    static let iconSize: CGFloat = 16.0
    
    /// 三列宽度占比（首列 0.40，后两列各 0.30）
    static let columnWeights: [CGFloat] = [0.40, 0.30, 0.30]
    /// 权益名称字体
    static let titleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    /// 内容字体
    static let valueFont = UIFont.systemFont(ofSize: 13.0, weight: .medium)
    /// 表头字体
    static let headerFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
}

// MARK: - 主表格视图

final class IAPMembershipBenefitsListView: UIView {

    // MARK: 公开属性

    /// 表格数据
    var rows: [IAPMembershipBenefitRow] = [] {
        didSet { setNeedsLayout() }
    }

    /// 行最小高度（可外部调整）
    var minRowHeight: CGFloat = Metric.minRowHeight
    /// 行最大高度（可外部调整）
    var maxRowHeight: CGFloat = Metric.maxRowHeight
    /// 收起状态下最多显示的行数，超过则显示展开按钮（默认 10）
    var maxVisibleRows: Int = 5 {
        didSet { setNeedsLayout() }
    }
    /// 当前是否已展开
    private(set) var isExpanded = false
    
    /// 内容高度变化回调
    var onContentHeightChanged: ((CGFloat) -> Void)?

    // MARK: 私有子视图

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = IAPMembershipBenefitHeaderView()
    private let footerView = IAPMembershipExpandFooterView()
    private var rowViews: [IAPMembershipBenefitRowView] = []
    /// 覆盖表头 / 行 / footer 整块卡片的圆角边框
    private let borderView = UIView()

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
        
        // 整块卡片的圆角边框
        borderView.backgroundColor = .clear
        borderView.isUserInteractionEnabled = false
        borderView.layer.cornerRadius = Metric.cornerRadius
        borderView.layer.borderWidth = Metric.borderWidth
        borderView.layer.borderColor = IAPColor.cardBorder.cgColor
        contentView.addSubview(borderView)
        
        // footer 点击事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleFooterTap))
        footerView.addGestureRecognizer(tap)
        footerView.isUserInteractionEnabled = true
    }

    @objc private func handleFooterTap() {
        toggleExpanded(animated: true)
    }

    /// 展开/收起动画时长。外部整体布局需使用相同时长，保证同步。
    static let expansionDuration: TimeInterval = 0.3

    /// 切换展开/收起状态
    func toggleExpanded(animated: Bool = true) {
        isExpanded.toggle()
        footerView.setExpanded(isExpanded)
        
        guard animated else {
            setNeedsLayout()
            layoutIfNeeded()
            onContentHeightChanged?(contentHeight)
            return
        }
        
        // 行高（0 ↔ 实际高度）、footer 位置与 contentView 高度在同一动画里连续变化：
        // footer 始终紧贴最后一行，会被「推着」平滑移动，既不会跳变也不会留下空白
        UIView.animate(withDuration: Self.expansionDuration,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        // 立即通知外部：外层高度与下方视图以同样时长同步移动
        onContentHeightChanged?(contentHeight)
    }

    // MARK: 手动布局

    override func layoutSubviews() {
        super.layoutSubviews()
        performFullLayout()
    }
    
    /// 该行当前是否需要占据高度（收起状态下只显示前 `maxVisibleRows` 行）
    private func isRowDisplayed(at index: Int) -> Bool {
        isExpanded || index < maxVisibleRows
    }

    /// 某一行当前应占据的高度；收起状态下超出 `maxVisibleRows` 的行为 0
    ///
    /// 收起时不移除行视图，而是把高度收成 0：这样展开/收起可以连续动画，
    /// footer 也能紧贴最后一行平滑移动。
    private func displayedRowHeight(at index: Int, tableWidth: CGFloat) -> CGFloat {
        guard isRowDisplayed(at: index) else { return 0 }
        return calculateRowHeight(for: rows[index], tableWidth: tableWidth)
    }

    /// 执行完整布局（动画与非动画共用同一份布局逻辑）
    private func performFullLayout() {
        // 1. scrollView 占满自身
        scrollView.frame = bounds

        // 2. 计算表格可用宽度
        let tableWidth = bounds.width - Metric.horizontalInset * 2
        guard tableWidth > 0 else { return }

        // 3. 计算每列宽度
        let colWidths = Metric.columnWeights.map { $0 * tableWidth }

        // 4. 布局表头
        headerView.frame = CGRect(x: 0, y: 0, width: tableWidth, height: Metric.headerHeight)
        headerView.setColumnWidths(colWidths)

        // 5. 所有行都保留视图，收起时多余行高为 0（由 contentView 裁掉）
        ensureRowViewCount(rows.count)

        var currentY: CGFloat = Metric.headerHeight
        for index in 0..<rows.count {
            let rowView = rowViews[index]
            let naturalHeight = calculateRowHeight(for: rows[index], tableWidth: tableWidth)
            let rowHeight = isRowDisplayed(at: index) ? naturalHeight : 0

            // 内容始终按自然高度预先布局（收起时行高为 0，仅靠裁剪隐藏）：
            // 这样首次展开时只有行高在动画，不会出现文字/数值「从左向右长出来」
            rowView.contentHeight = naturalHeight
            rowView.frame = CGRect(x: 0, y: currentY, width: tableWidth, height: rowHeight)
            rowView.configure(with: rows[index], columnWidths: colWidths)
            currentY += rowHeight
        }

        // 6. footer 紧跟在最后一行之后
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

        // 7. contentView 与 scrollView 内容大小（一次性赋值，便于动画插值）
        contentView.frame = CGRect(
            x: Metric.horizontalInset, y: 0,
            width: tableWidth, height: currentY
        )
        scrollView.contentSize = CGSize(width: bounds.width, height: currentY)

        // 8. 圆角边框覆盖整块卡片（表头 / 行 / footer），始终置于最上层
        borderView.layer.borderColor = IAPColor.cardBorder.cgColor
        contentView.bringSubviewToFront(borderView)
        borderView.frame = contentView.bounds
    }
    
    // MARK: 行高计算（核心：根据首列文本高度动态决定）

    private func calculateRowHeight(for row: IAPMembershipBenefitRow, tableWidth: CGFloat) -> CGFloat {
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
                let rowView = IAPMembershipBenefitRowView()
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
        for index in 0..<rows.count {
            total += displayedRowHeight(at: index, tableWidth: tableWidth)
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

private final class IAPMembershipBenefitHeaderView: UIView {

    private let titleLabel = TPLabel()
    private let freeLabel = TPLabel()
    private let proLabel = TPLabel()
    private var columnWidths: [CGFloat] = []
    private let edgeInsets = UIEdgeInsets(horizontal: 12.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = MembershipColor.cardBackground
        
        titleLabel.edgeInsets = edgeInsets
        titleLabel.text = resGetString("Features")
        titleLabel.textColor = MembershipColor.title
        titleLabel.font = Metric.headerFont
        titleLabel.textAlignment = .left
        addSubview(titleLabel)

        freeLabel.edgeInsets = edgeInsets
        freeLabel.text = resGetString("Free")
        freeLabel.textColor = MembershipColor.freeGray
        freeLabel.font = Metric.headerFont
        freeLabel.textAlignment = .center
        addSubview(freeLabel)

        proLabel.edgeInsets = edgeInsets
        proLabel.text = resGetString("Pro")
        proLabel.textColor = MembershipColor.highlight
        proLabel.font = Metric.headerFont
        proLabel.textAlignment = .center
        addSubview(proLabel)
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

        // 第二列：普通用户
        freeLabel.frame = CGRect(
            x: titleLabel.right,
            y: 0,
            width: columnWidths[1], height: bounds.height
        )

        // 第三列：高级会员（图标 + 文字，整体居中）
        proLabel.frame = CGRect(
            x: freeLabel.right,
            y: 0,
            width: columnWidths[2], height: bounds.height
        )
    }
}

// MARK: - 单行视图

private final class IAPMembershipBenefitRowView: UIView {

    private let titleLabel = UILabel()
    private let freeLabel = UILabel()
    private let proLabel = UILabel()
    private let freeIcon = UIImageView()
    private let proIcon = UIImageView()
    
    private let topSeparator = UIView()
    private var columnWidths: [CGFloat] = []

    var contentHeight: CGFloat = 0 {
        didSet {
            if contentHeight != oldValue { setNeedsLayout() }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // 行背景与商品卡片一致
        backgroundColor = MembershipColor.cardBackground
        // 收起状态下本行高度会被动画收缩到 0，需要裁剪内容
        clipsToBounds = true

        titleLabel.font = Metric.titleFont
        titleLabel.textColor = MembershipColor.title
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        addSubview(titleLabel)

        freeLabel.font = Metric.valueFont
        freeLabel.textColor = MembershipColor.freeGray
        freeLabel.textAlignment = .center
        addSubview(freeLabel)
        configIcon(freeIcon, color: MembershipColor.freeGray)

        proLabel.font = Metric.valueFont
        proLabel.textColor = MembershipColor.highlight
        proLabel.textAlignment = .center
        addSubview(proLabel)
        configIcon(proIcon, color: MembershipColor.highlight)

        // 顶部分隔线
        topSeparator.backgroundColor = MembershipColor.separator
        addSubview(topSeparator)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with row: IAPMembershipBenefitRow, columnWidths: [CGFloat]) {
        self.columnWidths = columnWidths
        titleLabel.text = row.title

        // 普通用户列：无值显示横杠（图标默认用普通列颜色）
        apply(row.freeValue,
              placeholder: "—",
              label: freeLabel,
              icon: freeIcon,
              defaultColor: MembershipColor.freeGray)
        
        // 高级会员列：无值显示对勾（图标默认用高亮色）
        apply(row.proValue,
              placeholder: "✓",
              label: proLabel,
              icon: proIcon,
              defaultColor: MembershipColor.highlight)
        
        setNeedsLayout()
    }

    /// 按取值显示文本或图标
    /// - Parameter defaultColor: 未指定自定义颜色时使用的列默认色
    private func apply(_ value: IAPMembershipBenefitValue?,
                       placeholder: String,
                       label: UILabel,
                       icon: UIImageView,
                       defaultColor: UIColor) {
        switch value {
        case .text(let text, let color) where !text.isEmpty:
            label.text = text
            label.textColor = color ?? defaultColor
            label.isHidden = false
            icon.isHidden = true
        case .icon(let name, let color):
            icon.image = resGetImage(name, color: color ?? defaultColor)
            icon.isHidden = false
            label.isHidden = true
        case .text, .none:
            // 空文本或未配置：显示占位符
            label.text = placeholder
            label.textColor = defaultColor
            label.isHidden = false
            icon.isHidden = true
        }
    }

    private func configIcon(_ icon: UIImageView, color: UIColor) {
        icon.contentMode = .scaleAspectFit
        icon.tintColor = color
        icon.isHidden = true
        addSubview(icon)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard columnWidths.count == 3, bounds.width > 0 else { return }

        // 内容按 contentHeight 排布（收起时自身高度为 0，但内容仍按自然高度就位）
        let layoutHeight = contentHeight > 0 ? contentHeight : bounds.height
        guard layoutHeight > 0 else { return }

        let pad = Metric.cellHorizontalPadding

        // 第一列：权益名称（左对齐，垂直居中）
        let titleX = pad
        let titleWidth = columnWidths[0] - pad * 2
        let titleSize = titleLabel.sizeThatFits(
            CGSize(width: titleWidth, height: .greatestFiniteMagnitude)
        )
        let titleHeight = max(0, min(titleSize.height, layoutHeight - pad * 2))
        titleLabel.frame = CGRect(
            x: titleX,
            y: (layoutHeight - titleHeight) / 2,
            width: titleWidth,
            height: titleHeight
        )

        // 第二列：普通用户（居中，文本或图标）
        layout(freeLabel, icon: freeIcon, in: CGRect(
            x: columnWidths[0], y: 0,
            width: columnWidths[1], height: layoutHeight
        ))

        // 第三列：高级会员（居中，文本或图标）
        layout(proLabel, icon: proIcon, in: CGRect(
            x: columnWidths[0] + columnWidths[1], y: 0,
            width: columnWidths[2], height: layoutHeight
        ))


        // 顶部分隔线（横跨整个表格宽度）
        topSeparator.frame = CGRect(
            x: 0, y: 0,
            width: bounds.width, height: 0.5
        )
    }

    /// 在给定列区域内居中排布文本或图标
    private func layout(_ label: UILabel, icon: UIImageView, in columnFrame: CGRect) {
        label.frame = columnFrame

        guard !icon.isHidden else { return }
        icon.frame = CGRect(
            x: columnFrame.midX - Metric.iconSize / 2,
            y: columnFrame.midY - Metric.iconSize / 2,
            width: Metric.iconSize,
            height: Metric.iconSize
        )
    }
}

// MARK: - 展开/收起 Footer

private final class IAPMembershipExpandFooterView: UIView {

    private let titleLabel = UILabel()
    private let arrowIcon = UIImageView()
    private let topSeparator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = MembershipColor.cardBackground

        topSeparator.backgroundColor = MembershipColor.separator
        addSubview(topSeparator)

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = MembershipColor.highlight
        titleLabel.text = resGetString("View more pro features")
        addSubview(titleLabel)

        arrowIcon.image = resGetImage("triangle_down_12", color: MembershipColor.highlight)
        addSubview(arrowIcon)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setExpanded(_ expanded: Bool) {
        titleLabel.text = expanded ? resGetString("Collapse") : resGetString("View more pro features")
        if expanded {
            arrowIcon.image = resGetImage("triangle_up_12", color: MembershipColor.highlight)
        } else {
            arrowIcon.image = resGetImage("triangle_down_12", color: MembershipColor.highlight)
        }
        
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        topSeparator.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.5)
        titleLabel.sizeToFit()
        titleLabel.alignCenter()
        arrowIcon.size = .size(3)
        arrowIcon.right = titleLabel.left - 4.0
        arrowIcon.centerY = titleLabel.centerY
    }
}
