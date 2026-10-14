//
//  FocusDurationCardView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation
import UIKit

/// 专注时长卡片
class FocusDurationCardView: UIView {

    // MARK: - 布局常量

    enum Metrics {
        static let cornerRadius: CGFloat = 16.0
        /// 内容左右间距
        static let contentPadding: CGFloat = 16.0
        static let menuTop: CGFloat = 16.0
        static let menuHeight: CGFloat = 30.0
        static let minMenuWidth: CGFloat = 60.0
        static let menuToChart: CGFloat = 16.0
        static let chartHeight: CGFloat = 280.0
    }

    // MARK: - 数据

    /// 当前选中的统计类型
    private(set) var type: StatsType = .week

    /// 允许展示的统计类型
    var allowTypes: [StatsType] = [.week, .month, .year]

    /// 统计类型切换回调
    var didSelectType: ((StatsType) -> Void)?

    // MARK: - 子视图

    /// 周/月/年分段菜单
    lazy var menuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.buttonHeight = Metrics.menuHeight
        view.minButtonWidth = Metrics.minMenuWidth
        view.padding = UIEdgeInsets(value: 4.0)
        view.cornerRadius = .greatestFiniteMagnitude
        view.menuItems = allowTypes.segmentedMenuItems()
        view.didSelectMenuItem = { [weak self] menuItem in
            guard let type = StatsType(rawValue: menuItem.identifier) else {
                return
            }

            self?.select(type: type)
        }

        view.sizeToFit()
        return view
    }()

    /// 图表内容容器
    let chartContainerView = TPAnimatedContainerView()

    /// 卡片首选高度
    var preferredHeight: CGFloat {
        return Metrics.menuTop
            + menuView.height
            + Metrics.menuToChart
            + Metrics.chartHeight
            + Metrics.contentPadding
    }

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = Metrics.cornerRadius
        layer.masksToBounds = true

        addSubview(menuView)
        addSubview(chartContainerView)

        menuView.selectMenu(withTag: type.tag, animated: false)
        setChartView(for: type, animateStyle: .none)
    }

    // MARK: - 切换统计类型

    /// 切换统计类型
    func select(type: StatsType, animated: Bool = true) {
        guard self.type != type else { return }

        let style: SlideStyle
        if animated {
            style = SlideStyle.horizontalStyle(fromValue: self.type.index ?? 0,
                                               toValue: type.index ?? 0)
        } else {
            style = .none
        }

        self.type = type

        menuView.selectMenu(withTag: type.tag, animated: animated)
        setChartView(for: type, animateStyle: style)
        didSelectType?(type)
    }

    private func setChartView(for type: StatsType, animateStyle: SlideStyle) {
        chartContainerView.setContentView(chartView(for: type), animateStyle: animateStyle)
    }

    private func chartView(for type: StatsType) -> UIView {
        return FocusDurationChartContainerView(type: type)
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0.0 else { return }

        menuView.top = Metrics.menuTop
        menuView.alignHorizontalCenter()

        chartContainerView.frame = CGRect(x: Metrics.contentPadding,
                                          y: menuView.bottom + Metrics.menuToChart,
                                          width: max(bounds.width - Metrics.contentPadding * 2.0, 0.0),
                                          height: Metrics.chartHeight)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = size.width > 0.0 ? size.width : UIScreen.main.bounds.width
        return CGSize(width: width, height: preferredHeight)
    }
}
